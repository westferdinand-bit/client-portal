"""Shared helpers for the Linux (ffmpeg) port of the higgsfield-motion Swift tools.

The Swift originals use AVFoundation, which exists only on macOS. These helpers back the
same command-line contracts with ffmpeg/ffprobe so SKILL.md instructions run unchanged.
"""

import json
import os
import re
import subprocess
import sys
import tempfile

FRAME_RE = re.compile(r"^f_(\d+)\.(png|jpg|jpeg)$", re.IGNORECASE)


def die(msg):
    """Fail loudly instead of writing a silently broken film."""
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def warn(msg):
    print(f"warning: {msg}", file=sys.stderr)


def run(cmd, capture=True):
    """Run a command, dying with its stderr if it fails."""
    p = subprocess.run(cmd, capture_output=capture, text=True)
    if p.returncode != 0:
        tail = (p.stderr or "").strip().splitlines()[-12:]
        die(f"{cmd[0]} failed:\n" + "\n".join(tail))
    return p.stdout or ""


def ffprobe_json(path, *extra):
    out = run(["ffprobe", "-v", "error", "-print_format", "json", *extra, path])
    try:
        return json.loads(out)
    except json.JSONDecodeError:
        die(f"could not parse ffprobe output for {path}")


def collect_frames(frames_dir, lenient=False):
    """Return numerically ordered f_<n>.png|jpg paths, applying the documented checks.

    Rejects: an empty directory, a gap in the frame index (a uniform step such as
    --every 2 is accepted), and a frame whose size differs from the first.
    """
    if not os.path.isdir(frames_dir):
        die(f"not a directory: {frames_dir}")

    found = []
    for name in os.listdir(frames_dir):
        m = FRAME_RE.match(name)
        if m:
            found.append((int(m.group(1)), os.path.join(frames_dir, name)))
    if not found:
        die(f"no f_<n>.png or f_<n>.jpg frames in {frames_dir}")
    found.sort(key=lambda t: t[0])

    idx = [n for n, _ in found]
    if len(idx) > 1:
        steps = {b - a for a, b in zip(idx, idx[1:])}
        if len(steps) > 1:
            msg = (
                f"gap in the frame index: steps {sorted(steps)} between f_{idx[0]} and "
                f"f_{idx[-1]} ({len(idx)} frames). A uniform step is fine; a missing frame is not."
            )
            if lenient:
                warn(msg)
            else:
                die(msg)

    paths = [p for _, p in found]
    check_uniform_size(paths, lenient)

    # _comp.json, when the capture wrote one, states how many frames to expect.
    comp = os.path.join(frames_dir, "_comp.json")
    if os.path.isfile(comp):
        try:
            with open(comp) as fh:
                want = json.load(fh).get("frames")
            if isinstance(want, int) and want != len(paths):
                msg = f"_comp.json expects {want} frames, found {len(paths)}"
                warn(msg) if lenient else die(msg)
        except (OSError, json.JSONDecodeError):
            warn("could not read _comp.json")

    return paths


def check_uniform_size(paths, lenient=False):
    """Every frame must match the first, or the encoder silently rescales."""
    try:
        from PIL import Image
    except ImportError:
        warn("Pillow not installed; skipping the frame-size check")
        return
    first = None
    for p in paths:
        try:
            with Image.open(p) as im:
                size = im.size
        except Exception as exc:  # unreadable frame
            die(f"unreadable frame {os.path.basename(p)}: {exc}")
        if first is None:
            first, first_path = size, p
        elif size != first:
            msg = (
                f"{os.path.basename(p)} is {size[0]}x{size[1]} but "
                f"{os.path.basename(first_path)} is {first[0]}x{first[1]}"
            )
            warn(msg) if lenient else die(msg)
    return first


def sequence_dir(paths):
    """Symlink frames into a temp dir as f_%06d.<ext> so ffmpeg's image2 reader sees a
    clean, gap-free, zero-based run whatever the original numbering was."""
    tmp = tempfile.mkdtemp(prefix="hfseq_")
    ext = os.path.splitext(paths[0])[1].lower()
    for i, src in enumerate(paths):
        os.symlink(os.path.abspath(src), os.path.join(tmp, f"f_{i:06d}{ext}"))
    return tmp, f"f_%06d{ext}"


def x264_args(fps, mbps):
    """H.264 High, BT.709 tags, a keyframe every 2 s, constant frame rate."""
    gop = max(1, round(fps * 2))
    return [
        "-c:v", "libx264",
        "-profile:v", "high",
        "-pix_fmt", "yuv420p",
        "-b:v", f"{mbps}M",
        "-maxrate", f"{mbps * 2}M",
        "-bufsize", f"{mbps * 4}M",
        "-x264-params", f"keyint={gop}:min-keyint={gop}:scenecut=0",
        "-color_primaries", "bt709",
        "-color_trc", "bt709",
        "-colorspace", "bt709",
        "-fps_mode", "cfr",
        "-r", str(fps),
        "-movflags", "+faststart",
    ]


AAC_ARGS = ["-c:a", "aac", "-b:a", "256k", "-ar", "48000", "-ac", "2"]


def media_duration(path):
    info = ffprobe_json(path, "-show_format")
    try:
        return float(info["format"]["duration"])
    except (KeyError, TypeError, ValueError):
        return None


def stream(path, kind):
    """First stream of kind 'v' or 'a', or None."""
    info = ffprobe_json(path, "-show_streams", "-select_streams", kind)
    streams = info.get("streams") or []
    return streams[0] if streams else None


def parse_rational(text, default=0.0):
    try:
        if "/" in str(text):
            num, den = str(text).split("/")
            return float(num) / float(den) if float(den) else default
        return float(text)
    except (ValueError, ZeroDivisionError):
        return default
