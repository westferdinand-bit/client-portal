# Source this on Linux: finds node (22+), a Chromium browser and the python deps for the code
# pipeline.   source scripts/code/linux/env-linux.sh
# Linux counterpart of ../env.sh, which only looks in macOS /Applications paths.
for n in "${NODE:-}" "$(command -v node)" /opt/node22/bin/node /usr/local/bin/node /usr/bin/node; do
  [ -n "$n" ] && [ -x "$n" ] && "$n" -e 'process.exit(+process.versions.node.split(".")[0] >= 21 ? 0 : 1)' 2>/dev/null && { export NODE="$n"; break; }
done

# setup-linux.sh writes a wrapper that adds --no-sandbox, which Chromium requires when running
# as root in a container. Prefer it over the raw binary.
if [ -z "${HFT_BROWSER:-}" ]; then
  _wrap="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)/bin/chrome-wrapper"
  [ -x "$_wrap" ] && export HFT_BROWSER="$_wrap"
fi
if [ -z "${HFT_BROWSER:-}" ]; then
  for b in chromium chromium-browser google-chrome google-chrome-stable brave-browser microsoft-edge; do
    c="$(command -v "$b" 2>/dev/null)" && [ -n "$c" ] && { export HFT_BROWSER="$c"; break; }
  done
fi
# Playwright bundles a Chromium; this container ships one at PLAYWRIGHT_BROWSERS_PATH.
if [ -z "${HFT_BROWSER:-}" ] && [ -n "${PLAYWRIGHT_BROWSERS_PATH:-}" ]; then
  for b in "$PLAYWRIGHT_BROWSERS_PATH"/chromium*/chrome-linux/chrome "$PLAYWRIGHT_BROWSERS_PATH"/chromium; do
    [ -x "$b" ] && { export HFT_BROWSER="$b"; break; }
  done
fi

echo "NODE=${NODE:-MISSING (need Node >= 21 with global fetch/WebSocket)}"
echo "HFT_BROWSER=${HFT_BROWSER:-MISSING (any Chromium-based browser)}"
# Import the submodules, not just the packages: a Pillow built for another Python ABI imports
# as a package and fails only here. Install with `python3 -m pip`, never a bare `pip`.
python3 -c "import numpy; from PIL import Image" 2>/dev/null \
  && echo "python: numpy+PIL ok" \
  || echo "python: need numpy + Pillow -> python3 -m pip install --ignore-installed numpy Pillow"
command -v ffmpeg >/dev/null \
  && echo "ffmpeg: ok (replaces AVFoundation)" \
  || echo "ffmpeg: MISSING -> apt install ffmpeg"
