#!/usr/bin/env bash
# Install every skill in this repository at USER level, so it is available in all future
# sessions on this machine regardless of which directory or project you are working in.
#
# Project level (what committing to this repo already gives you) only applies to sessions
# working inside this repository. User level applies everywhere on the machine.
#
#   bash scripts/install-skills.sh            # install / refresh
#   bash scripts/install-skills.sh --link     # symlink instead of copy (edits track the repo)
#   bash scripts/install-skills.sh --list     # show what is installed, change nothing
#   CLAUDE_SKILLS_DIR=/path bash scripts/install-skills.sh   # override the destination
#
# Idempotent: re-running refreshes in place. Only skills that came from this repo are
# replaced; anything else already in the destination is left untouched.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/.agents/skills"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
MODE="copy"

for arg in "$@"; do
  case "$arg" in
    --link) MODE="link" ;;
    --list) MODE="list" ;;
    -h|--help) sed -n '2,16p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

if [ ! -d "$SRC" ]; then
  echo "error: no skills directory at $SRC" >&2
  exit 1
fi

if [ "$MODE" = "list" ]; then
  echo "source:      $SRC  ($(find "$SRC" -mindepth 1 -maxdepth 1 -type d | wc -l) skills)"
  echo "destination: $DEST"
  if [ -d "$DEST" ]; then
    echo "installed:   $(find "$DEST" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) | wc -l)"
  else
    echo "installed:   none (destination does not exist)"
  fi
  exit 0
fi

mkdir -p "$DEST" || { echo "error: cannot create $DEST" >&2; exit 1; }

count=0
for dir in "$SRC"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  target="$DEST/$name"
  rm -rf "$target"
  if [ "$MODE" = "link" ]; then
    ln -s "${dir%/}" "$target"
  else
    cp -a "${dir%/}" "$target"
  fi
  count=$((count + 1))
done

echo "installed $count skills ($MODE) -> $DEST"
echo
echo "These are now available in every session on this machine."
echo "Note: on an ephemeral cloud container the home directory is NOT preserved between"
echo "sessions. To make this automatic there, set it as the environment's Setup script:"
echo "    bash \"$REPO/scripts/install-skills.sh\""
