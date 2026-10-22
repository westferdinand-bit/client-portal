#!/bin/bash
# higgsfield-motion setup, Linux. Run once per machine. Idempotent.
# The macOS path (setup.sh) compiles scripts/*.swift with swiftc and relies on AVFoundation and
# afconvert. Neither exists on Linux, so this installs the ffmpeg-backed ports in scripts/linux/
# into ${HFT_BIN:-~/.cache/higgsfield-motion/bin} under the SAME tool names, so every $B/<tool>
# invocation in SKILL.md works unchanged.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="${HFT_BIN:-$HOME/.cache/higgsfield-motion/bin}"
mkdir -p "$BIN"
ok=1

NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)
if [ "$NODE_MAJOR" -ge 22 ] 2>/dev/null; then echo "node      ok ($(node -v))"; else echo "node      FAIL: need Node 22+ (global WebSocket), found ${NODE_MAJOR}"; ok=0; fi

if command -v ffmpeg >/dev/null && command -v ffprobe >/dev/null; then
  echo "ffmpeg    ok ($(ffmpeg -version | head -1 | cut -d' ' -f3))"
else
  echo "ffmpeg    FAIL: install ffmpeg (apt install ffmpeg) - it replaces AVFoundation here"; ok=0
fi

# Import Image, not just PIL: a Pillow whose compiled _imaging is missing or built for another
# Python ABI imports as a package and fails only here. Always install with `python3 -m pip`, never
# a bare `pip`, which may belong to a different interpreter and fetch an incompatible wheel.
if python3 -c 'from PIL import Image, ImageChops, ImageStat' 2>/dev/null; then
  echo "pillow    ok ($(python3 -c 'from PIL import Image; print(Image.__version__)'))"
else
  echo "pillow    FAIL: python3 -m pip install --ignore-installed Pillow (frame checks and fdiff need it)"; ok=0
fi

# Chromium: honour HFT_BROWSER, else the usual Linux names, else a Playwright bundle.
BR="${HFT_BROWSER:-}"
if [ -z "$BR" ]; then
  for p in chromium chromium-browser google-chrome google-chrome-stable brave-browser microsoft-edge; do
    c=$(command -v "$p" 2>/dev/null) && [ -n "$c" ] && BR="$c" && break
  done
fi
if [ -z "$BR" ] && [ -n "${PLAYWRIGHT_BROWSERS_PATH:-}" ]; then
  for p in "$PLAYWRIGHT_BROWSERS_PATH"/chromium*/chrome-linux/chrome "$PLAYWRIGHT_BROWSERS_PATH"/chromium; do
    [ -x "$p" ] && BR="$p" && break
  done
fi
if [ -n "$BR" ]; then echo "browser   ok ($BR)"; else echo "browser   FAIL: install chromium or set HFT_BROWSER"; ok=0; fi

for t in encode encode_av mux extract probe master fdiff; do
  src="$DIR/linux/$t"
  if [ ! -f "$src" ]; then echo "tool      MISSING $t"; ok=0; continue; fi
  install -m 0755 "$src" "$BIN/$t"
  echo "tool      installed $t"
done
install -m 0644 "$DIR/linux/_hfcommon.py" "$BIN/_hfcommon.py"

echo "bin dir:  $BIN   (use as \$B)"
[ -n "$BR" ] && echo "browser:  export HFT_BROWSER=\"$BR\""
[ "$ok" = 1 ] && echo "setup OK" || { echo "setup finished with problems"; exit 1; }
