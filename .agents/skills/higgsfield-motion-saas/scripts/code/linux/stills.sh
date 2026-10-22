#!/usr/bin/env bash
# Exact stills of a film page at given times + one labelled sheet you can open with Read.
# Bash port of ../stills.sh, which is zsh-only.
#   stills.sh <page.html[?query]> <out_dir> t1,t2,...   e.g. stills.sh "film/index.html?only=s3" stills/s3 3.0,3.4,3.9
set -euo pipefail
LINUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODE_DIR="$(cd "$LINUX_DIR/.." && pwd)"
# shellcheck source=/dev/null
source "$LINUX_DIR/env-linux.sh" >/dev/null
PAGE="${1:?usage: stills.sh <page.html> <out_dir> t1,t2,...}"
OUT="$(realpath -m "${2:?missing out_dir}")"
TIMES="${3:?missing times}"
rm -rf "$OUT"; mkdir -p "$OUT"
CAP_TMP="$OUT" "$NODE" "$CODE_DIR/capture.mjs" "$PAGE" "$OUT" --stills "$TIMES" 2>&1 | grep -v "^comp:" | tail -4
python3 "$CODE_DIR/sheet.py" "$OUT" "$OUT/sheet.jpg" --cols 3 --width 640
