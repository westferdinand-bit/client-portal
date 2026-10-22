# Linux port of the higgsfield-motion tools

The original tools are Swift and use **AVFoundation** plus **afconvert**, both macOS-only, so on
Linux `scripts/setup.sh` cannot build anything. These are drop-in replacements backed by
**ffmpeg/ffprobe**, installed by `../setup-linux.sh` into `${HFT_BIN:-~/.cache/higgsfield-motion/bin}`
under the **same names**, so every `"$B"/<tool>` line in `SKILL.md` works unchanged.

| Tool | Original | Linux implementation |
|---|---|---|
| `encode` | AVAssetWriter | ffmpeg `libx264`, High profile, BT.709 tags, keyframe every 2 s, CFR |
| `encode_av` | AVAssetWriter, two tracks | ffmpeg, one pass, `apad` + `-t` trims audio to exactly `frames / fps` |
| `mux` | AVAssetExportSession | ffmpeg `-c:v copy` (picture untouched) + AAC-LC 256k/48k stereo |
| `extract` | AVAssetImageGenerator | ffmpeg `-fps_mode passthrough`, writes the same `_clip.json` |
| `probe` | AVAsset inspection | ffprobe, plus per-packet timing for the constant-frame-rate check |
| `master` | custom BS.1770-4 | ffmpeg `loudnorm` (two-pass, the same ITU-R BS.1770-4) + `astats` for sample peak and clipped samples |
| `fdiff` | CoreImage luma grid | ffmpeg decode to a 384-px grey raw stream; MAD and 12×12 `blockmax` via Pillow |

CLI flags, output formats, stdout reports and exit codes follow the Swift headers. Tools exit 1
with a message on stderr rather than writing a silently broken film.

## Requirements

- **ffmpeg + ffprobe** — replaces AVFoundation and afconvert entirely.
- **Node 22+** and a Chromium browser — unchanged from macOS; `setup-linux.sh` also finds a
  Playwright bundle via `PLAYWRIGHT_BROWSERS_PATH` and prints the `HFT_BROWSER` line to export.
- **Pillow** — the frame-size check and `fdiff` only. Without it `encode`/`encode_av` still run and
  warn; `fdiff` exits with an install hint.

### Installing Pillow: the trap

Install it with **`python3 -m pip`**, never a bare `pip`:

```bash
python3 -m pip install --ignore-installed Pillow
```

A bare `pip` may belong to a different interpreter (seen here: `pip` was Python 3.13 while `python3`
was 3.11). It then installs cp313 `.so` files that 3.11 cannot load, and Pillow fails in a way that
looks like it is installed — `import PIL` succeeds while `from PIL import Image` raises
`ImportError: cannot import name '_imaging'`. `setup-linux.sh` imports `Image` precisely to catch this.

## Differences from the Swift tools, stated plainly

- `encode`/`encode_av` target an **average** bitrate (x264 ABR with a 2× `maxrate` cap). The Swift
  tools ask AVFoundation for the same nominal figure; exact bit allocation differs slightly.
- `master` reports `loudnorm`'s measurements. Integrated LUFS, LRA and true peak follow the same
  standard, but the last decimal can differ from the Swift implementation.
- `fdiff` thresholds (`--spike`, `--freeze`, `--still`, `--dead`) keep their meaning and defaults;
  absolute MAD values depend on the decode path, so recalibrate if you tuned them on macOS.
- Frames are symlinked into a temp directory as `f_%06d` before encoding, so an arbitrary start
  index or a uniform step (`--every 2`) encodes correctly.

## Verified on this container

ffmpeg 6.1.1, Node 22.22, Python 3.11, Pillow 13: 72 frames at 24 fps round-tripped through
`encode` → `probe` → `extract` with 72 frames out, constant frame rate and BT.709 tags intact;
`master` took a −24.95 LUFS bed to −14.05 LUFS at −13.11 dBTP; `fdiff` found an injected one-frame
flash and a 19-frame freeze and exited 1 under `--fail`.
