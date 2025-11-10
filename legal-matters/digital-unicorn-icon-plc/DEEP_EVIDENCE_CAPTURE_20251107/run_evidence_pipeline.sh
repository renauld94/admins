#!/usr/bin/env bash
set -euo pipefail
# Simple orchestrator to run the evidence extraction, ranking and exhibit creation locally.

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

TAKEOUT_ZIP="/tmp/fab_takeouts/takeout-20251104T155928Z-2-001.zip"
MBOX_REL="Takeout/Mail/All mail Including Spam and Trash.mbox"
MBOX_DEST="$ROOT_DIR/AllMail.mbox"
OUT_DIR="$ROOT_DIR/mbox_matches"

echo "Evidence pipeline starting. Root: $ROOT_DIR"
mkdir -p "$OUT_DIR"

if [ ! -s "$MBOX_DEST" ]; then
  if [ -f "$TAKEOUT_ZIP" ]; then
    echo "Extracting mbox from $TAKEOUT_ZIP to $MBOX_DEST (this may take a few minutes)..."
    unzip -p "$TAKEOUT_ZIP" "$MBOX_REL" > "$MBOX_DEST"
    echo "MBOX extracted."
  else
    echo "Warning: takeout ZIP not found at $TAKEOUT_ZIP. If you already have AllMail.mbox place it at: $MBOX_DEST"
  fi
else
  echo "MBOX already exists at $MBOX_DEST — skipping extraction."
fi

echo "Running Python: extract_bounces.py"
python3 "$SCRIPTS_DIR/extract_bounces.py" --mbox "$MBOX_DEST" --outdir "$OUT_DIR"

echo "Running Python: rank_bounces.py"
python3 "$SCRIPTS_DIR/rank_bounces.py" --manifest "$OUT_DIR/mbox_manifest.csv" --outdir "$OUT_DIR"

echo "Running Python: make_exhibit.py (autoselect Oct 29 candidates)"
python3 "$SCRIPTS_DIR/make_exhibit.py" --candidates "$OUT_DIR/candidates_bounce_top20.csv" --outdir "$ROOT_DIR"

echo "Pipeline complete. Key artifacts:"
echo " - $OUT_DIR/mbox_manifest.csv"
echo " - $OUT_DIR/candidates_bounce_top20.csv"
echo " - $OUT_DIR/CANDIDATE_BOUNCE_EXHIBITS.md"
echo " - $ROOT_DIR/EXHIBIT_LUCAS_OCT29_BOUNCE.txt (if created)"
