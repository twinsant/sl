#!/usr/bin/env bash
# Sync the Godot web export to game.twinsant.com and refresh the .gz files served by nginx gzip_static.
set -euo pipefail
cd "$(dirname "$0")/.."
HOST="${DEPLOY_HOST:-t}"
DEST="${DEPLOY_DEST:-/root/projects/sl}"
# The exporter re-encodes the boot splash as a ~1.8MB RGB PNG; shrink it back to a
# 1280px palette PNG before syncing. Skipped when Pillow is unavailable.
python3 - <<'PY' 2>/dev/null || true
from PIL import Image
Image.open("index.png").resize((1280, 720), Image.LANCZOS).quantize(
    colors=256, method=Image.Quantize.MEDIANCUT
).save("index.png", optimize=True)
PY
rsync -avz --checksum index.* "$HOST:$DEST/"
ssh "$HOST" "cd '$DEST' && for f in index.wasm index.pck index.js index.html; do gzip -9 -c \"\$f\" > \"\$f.gz.tmp\" && mv \"\$f.gz.tmp\" \"\$f.gz\"; done"
