#!/usr/bin/env bash
# Package each skill in this repository as a .skill bundle ready to upload to your
# claude.ai account, which is the only tier that follows you into EVERY future session
# on every machine and project.
#
#   bash scripts/package-skills.sh            # package all skills
#   bash scripts/package-skills.sh seo-audit copywriting   # package only these
#
# Output: dist/skills/<name>.skill — a zip whose root is <name>/SKILL.md, the same shape
# as the .skill files you already uploaded. dist/ is git-ignored; regenerate any time.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/.agents/skills"
OUT="$REPO/dist/skills"

command -v zip >/dev/null || { echo "error: 'zip' is not installed" >&2; exit 1; }
[ -d "$SRC" ] || { echo "error: no skills directory at $SRC" >&2; exit 1; }

mkdir -p "$OUT"

if [ "$#" -gt 0 ]; then
  names=("$@")
else
  names=()
  for d in "$SRC"/*/; do names+=("$(basename "$d")"); done
fi

made=0 skipped=0
for name in "${names[@]}"; do
  dir="$SRC/$name"
  if [ ! -d "$dir" ]; then
    echo "skip   $name (no such skill)" >&2; skipped=$((skipped + 1)); continue
  fi
  if [ ! -f "$dir/SKILL.md" ]; then
    echo "skip   $name (no SKILL.md)" >&2; skipped=$((skipped + 1)); continue
  fi
  rm -f "$OUT/$name.skill"
  # Zip from the skills dir so the archive root is <name>/, matching the uploaded bundles.
  ( cd "$SRC" && zip -q -r "$OUT/$name.skill" "$name" -x '*.DS_Store' ) || {
    echo "FAIL   $name" >&2; skipped=$((skipped + 1)); continue
  }
  size=$(du -h "$OUT/$name.skill" | cut -f1)
  printf 'built  %-32s %s\n' "$name" "$size"
  made=$((made + 1))
done

echo
echo "$made bundle(s) in $OUT${skipped:+, $skipped skipped}"
echo
echo "Upload them at claude.ai -> Settings -> Capabilities -> Skills."
echo "Account-level skills sync into every future session automatically, on any machine"
echo "and in any project - the same way your existing synced skills already arrive."
