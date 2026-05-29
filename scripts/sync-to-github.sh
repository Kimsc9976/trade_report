#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

BRANCH="${GIT_BRANCH:-$(git branch --show-current)}"
PATHS=(daily-report journal)
LOCK_FILE="${REPO_ROOT}/.sync-to-github.lock"

cleanup() {
  rm -f "$LOCK_FILE"
}
trap cleanup EXIT

if [[ -f "$LOCK_FILE" ]]; then
  echo "sync already running, skipping"
  exit 0
fi
echo $$ >"$LOCK_FILE"

if ! git status --porcelain "${PATHS[@]}" | grep -q .; then
  exit 0
fi

git add "${PATHS[@]}"

if git diff --cached --quiet; then
  exit 0
fi

if git rev-parse --abbrev-ref "@{u}" >/dev/null 2>&1; then
  git pull --rebase origin "$BRANCH"
fi

MSG="auto: sync $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$MSG"
git push origin "$BRANCH"

echo "pushed to origin/$BRANCH at $(date '+%Y-%m-%d %H:%M:%S')"
