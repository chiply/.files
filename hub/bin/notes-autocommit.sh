#!/usr/bin/env bash
# Daily snapshot of the notes tree into the hub-local git timeline.
set -euo pipefail
cd "${SYNC_DIR:-$HOME/kb}"
[ -d .git ] || exit 0
git add -A
git diff --cached --quiet && exit 0
git commit -qm "auto: $(date -I)"
