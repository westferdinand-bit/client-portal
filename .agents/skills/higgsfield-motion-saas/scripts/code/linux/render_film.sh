#!/usr/bin/env bash
# Render a code-built film page to MP4: N parallel headless browsers (interleaved frames) ->
# sub-frame motion blur -> H.264. Bash port of ../render_film.sh, which is zsh-only.
#   render_film.sh <page.html[?query]> <out.mp4> [sub=4] [workers=8] [subhi=0] [hiwin="a-b,c-d"]
#   draft (no blur, fast):   render_film.sh film/index.html film/draft.mp4 1 8
#   final:                   render_film.sh film/index.html film/final.mp4 4 8 10 "1.8-3.2,9.3-10.4"
# env: FPS (30)  MBPS (24)  FROM/TO (seconds, partial render)  WORK (frame dir)
#      KEEP=1 keeps the blended PNGs.  LENS=1 runs lens.py (LENS_ARGS="--sched film/lens.json").
#      NODE / HFT_BROWSER from linux/env-linux.sh.
set -euo pipefail

LINUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # zsh ${0:A:h}
CODE_DIR="$(cd "$LINUX_DIR/.." && pwd)"
# shellcheck source=/dev/null
source "$LINUX_DIR/env-linux.sh" >/dev/null

PAGE="${1:?usage: render_film.sh <page.html> <out.mp4> [sub] [workers] [subhi] [hiwin]}"
OUTMP4="$(realpath -m "${2:?missing out.mp4}")"             # zsh ${2:A}; encode needs it absolute
SUB=${3:-4}; WK=${4:-8}; SUBHI=${5:-0}; HIWIN="${6:-}"
FPS=${FPS:-30}; MBPS=${MBPS:-24}

WORK="${WORK:-${OUTMP4%.*}.work}"; rm -rf "$WORK"; mkdir -p "$WORK/sub" "$WORK/frames" "$WORK/tmp"
[ -x "$CODE_DIR/bin/encode" ] || { echo "render_film: no $CODE_DIR/bin/encode - run scripts/setup-linux.sh" >&2; exit 1; }
export CAP_TMP="$WORK/tmp"

EXTRA=()
[ -n "${TO:-}" ] && EXTRA+=(--to "$TO")
[ "$SUBHI" -gt 0 ] && EXTRA+=(--subhi "$SUBHI" --hiwin "$HIWIN")
DEST="$WORK/sub"; { [ "$SUB" -le 1 ] && [ "$SUBHI" -le 0 ]; } && DEST="$WORK/frames"

for i in $(seq 0 $((WK - 1))); do
  F=$(python3 -c "print((round(${FROM:-0}*$FPS)+$i)/$FPS)")
  CAP_PORT=$((9600 + i * 13)) "$NODE" "$CODE_DIR/capture.mjs" "$PAGE" "$DEST" \
    --from "$F" --every "$WK" --sub "$SUB" "${EXTRA[@]+"${EXTRA[@]}"}" --jpg \
    > "$WORK/log_$i.txt" 2>&1 &
done
wait

grep -h "SCENE ERRORS\|EXC\|did not" "$WORK"/log_*.txt | sort -u | head -8 || true

if [ "$DEST" = "$WORK/sub" ]; then
  python3 "$CODE_DIR/blend.py" "$WORK/sub" "$WORK/frames"
  rm -rf "$WORK/sub"
fi

# Continuity gate: a hung or crashed worker leaves holes, and encoding a sequence with holes
# silently shortens the film.
END=${TO:-$(grep -ho '"duration":[0-9.]*' "$WORK"/log_0.txt | head -1 | cut -d: -f2)}
python3 - "$WORK/frames" "$FPS" "${FROM:-0}" "$END" <<'PY'
import os, sys, re
d, fps, a, b = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), sys.argv[4]
have = sorted(int(re.match(r'f_(\d+)', f).group(1)) for f in os.listdir(d) if f.startswith('f_'))
if not have: sys.exit('render_film: no frames rendered - see the log_*.txt files')
n0, n1 = round(a * fps), (round(float(b) * fps) if b else have[-1] + 1)
miss = [n for n in range(n0, n1) if n not in set(have)]
if miss: sys.exit(f'render_film: {len(miss)} frames missing, e.g. {miss[:8]} - re-capture that range (a worker hung?) before encoding')
PY

[ "${LENS:-0}" = 1 ] && python3 "$CODE_DIR/lens.py" "$WORK/frames" --fps "$FPS" ${LENS_ARGS:-}

"$CODE_DIR/bin/encode" "$WORK/frames" "$FPS" "$OUTMP4" "$MBPS"
[ "${KEEP:-0}" = 1 ] || rm -rf "$WORK/frames"
echo "render_film: $OUTMP4"
