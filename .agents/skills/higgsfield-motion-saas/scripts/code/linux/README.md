# Linux port of the higgsfield-motion-saas code pipeline

The originals are Swift on **AVFoundation** plus **zsh** scripts, so `build_tools.sh` and
`render_film.sh` cannot run on Linux. These replacements are backed by **ffmpeg** and **bash**.

Install with `../../setup-linux.sh`. It puts `encode`, `mux` and `extract` into
`scripts/code/bin/` under the same names `render_film.sh` already expects.

| Original | Linux replacement |
|---|---|
| `code/encode.swift` | `linux/encode` — ffmpeg libx264, High, BT.709, keyframe every 2 s, CFR |
| `code/mux.swift` | `linux/mux` — `-c:v copy` + AAC-LC 256k/48k stereo, trimmed to the picture |
| `code/extract.swift` | `linux/extract` — time-step stills (`step_s/from_s/to_s/max_px`), the saas CLI |
| `code/render_film.sh` (zsh) | `linux/render_film.sh` (bash), same arguments and env vars |
| `code/stills.sh` (zsh) | `linux/stills.sh` (bash) |
| `code/env.sh` (macOS paths) | `linux/env-linux.sh` |
| `code/build_tools.sh` | `../setup-linux.sh` |

`extract` here is **not** the same tool as `extract` in the `higgsfield-motion` skill. This one
samples a film at fixed time steps into a contact sheet; that one turns a clip into a numbered
frame sequence. Same name, different jobs, as in the Swift originals.

## What does NOT port

**After Effects.** `scripts/ae.sh`, `scripts/saas_motion.jsx`, `scripts/probe.jsx` and
`examples/*.jsx` drive After Effects through ExtendScript. After Effects has no Linux build, so
this half of the skill is macOS/Windows only. Use the code pipeline instead — it covers the same
launch-film job end to end.

## Requirements

- **ffmpeg + ffprobe** — replaces AVFoundation.
- **Node 21+** and a Chromium browser.
- **numpy + Pillow** — `blend.py` (sub-frame motion blur), `lens.py`, `sheet.py`, `stills.py`.

```bash
python3 -m pip install --ignore-installed numpy Pillow
```

Use `python3 -m pip`, never a bare `pip`: they can be different interpreters (here `pip` was
Python 3.13 while `python3` was 3.11), and the mismatched wheel then imports as a package but
fails on `from PIL import Image`. The setup script imports the submodules to catch exactly this.

## The root/Chromium trap

Chromium refuses to start as root without `--no-sandbox` (crbug.com/638180), which is the normal
case in a container. The failure surfaces far from its cause — `capture.mjs` just reports
`browser did not start on port 9600`, then a `TypeError: Invalid URL` from the WebSocket.

`setup-linux.sh` writes `code/bin/chrome-wrapper`, a one-line script that execs the real browser
with `--no-sandbox --disable-dev-shm-usage --disable-gpu`, and `env-linux.sh` prefers it. Nothing
in `capture.mjs` or `cdp.mjs` is modified.

## Verified on this container

ffmpeg 6.1.1, Node 22.22, Python 3.11, numpy 2.4.6, Pillow 13, Playwright Chromium.

- `encode` / `mux` / `extract` on a 72-frame sequence: MP4 written, audio muxed, 5 time-step stills.
- `render_film.sh` on `assets/film-template`: headless Chromium across 2 parallel workers,
  continuity gate passed, 15 frames encoded.
- With `sub=4` motion blur: `blend.py` blended 4 sub-frames per frame through numpy, 12 frames at
  1920×1080 encoded; `probe` confirms 24 fps nominal and measured, constant frame rate, BT.709 tags.
