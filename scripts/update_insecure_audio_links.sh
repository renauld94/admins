#!/usr/bin/env bash
set -euo pipefail

# Replace insecure audio links (http://136.243.155.166:8086/vietnamese-audio/...) with
# proxied HTTPS paths (https://moodle.simondatalab.de/vietnamese-audio/...) in a limited set of directories.
# This is a repo-only change and will create a git commit. Review the diff before pushing.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PATTERN='http://136.243.155.166:8086/vietnamese-audio/'
REPL='https://moodle.simondatalab.de/vietnamese-audio/'

TARGET_DIRS=(
  "$REPO_ROOT/moodle-homepage"
  "$REPO_ROOT/course-improvements"
)

echo "Searching and replacing in: ${TARGET_DIRS[*]}"
cd "$REPO_ROOT"

FILES_TO_UPDATE=()
for d in "${TARGET_DIRS[@]}"; do
  if [ -d "$d" ]; then
    while IFS= read -r -d $'\0' f; do
      FILES_TO_UPDATE+=("$f")
    done < <(grep -RIl --exclude-dir=.git --exclude=*.bin --exclude=*.png --exclude=*.jpg --exclude=*.jpeg "$PATTERN" "$d" -z || true)
  fi
done

if [ ${#FILES_TO_UPDATE[@]} -eq 0 ]; then
  echo "No files found with pattern $PATTERN in target directories. Nothing to do."
  exit 0
fi

echo "Found ${#FILES_TO_UPDATE[@]} files. Running replacements..."
for f in "${FILES_TO_UPDATE[@]}"; do
  echo "- $f"
  sed -i.bak "s|$PATTERN|$REPL|g" "$f"
  rm -f "$f.bak"
done

git add "${FILES_TO_UPDATE[@]}"
git commit -m "fix: replace insecure vietnamese-audio http links with proxied https paths"

echo "Done. Review the commit. To push the changes run: git push"
