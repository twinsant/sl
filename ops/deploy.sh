#!/usr/bin/env bash
# Sync the Godot web export to game.twinsant.com and refresh the .gz files served by nginx gzip_static.
set -euo pipefail
cd "$(dirname "$0")/.."
HOST="${DEPLOY_HOST:-t}"
DEST="${DEPLOY_DEST:-/root/projects/sl}"
rsync -avz --checksum index.* "$HOST:$DEST/"
ssh "$HOST" "cd '$DEST' && for f in index.wasm index.pck index.js index.html; do gzip -9 -c \"\$f\" > \"\$f.gz.tmp\" && mv \"\$f.gz.tmp\" \"\$f.gz\"; done"
