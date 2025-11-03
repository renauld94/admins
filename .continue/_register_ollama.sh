#!/usr/bin/env bash
set -euo pipefail
FILE=/mnt/newdisk/ollama/models/mistral-7b-v0.1.gguf
if [ ! -f "$FILE" ]; then
  echo "file $FILE not found" >&2
  exit 1
fi
SHA=$(sha256sum "$FILE" | awk '{print $1}')
SIZE=$(stat -c%s "$FILE")
echo "sha=$SHA size=$SIZE"

BLOBS_DIR=/mnt/newdisk/ollama/models/blobs
MANIFESTS_DIR=/mnt/newdisk/ollama/models/manifests/registry.ollama.ai/library
mkdir -p "$BLOBS_DIR" "$MANIFESTS_DIR"

DEST="$BLOBS_DIR/sha256-$SHA"
if [ ! -f "$DEST" ]; then
  echo "copying $FILE -> $DEST"
  cp -v "$FILE" "$DEST"
  chown root:root "$DEST" || true
  chmod 644 "$DEST" || true
else
  echo "blob already exists at $DEST"
fi

MANIFEST_DIR=$MANIFESTS_DIR/mistral-7b-v0.1
DEEPSEQ_MANIFEST=$MANIFESTS_DIR/deepseek-coder/6.7b
if [ ! -f "$DEEPSEQ_MANIFEST" ]; then
  echo "deepseek manifest template not found at $DEEPSEQ_MANIFEST" >&2
  exit 1
fi

mkdir -p "$MANIFEST_DIR"
cp -v "$DEEPSEQ_MANIFEST" "$MANIFEST_DIR/latest"
# Replace an existing known digest & size with the new model's
sed -i "s/59bb50d8116b6a1f9bfbb940d6bb946a05554e591e30c8c2429ed6c854867ecb/$SHA/g" "$MANIFEST_DIR/latest" || true
sed -i "s/3827819904/$SIZE/g" "$MANIFEST_DIR/latest" || true
chown root:root "$MANIFEST_DIR/latest" || true
chmod 644 "$MANIFEST_DIR/latest" || true

echo "manifest installed at $MANIFEST_DIR/latest"

echo "restarting ollama container"
docker restart ollama || true
sleep 3

echo '--- ollama list ---'
docker exec ollama ollama list || true

echo '--- remote ollama /api/tags via proxy ---'
curl -sS http://127.0.0.1:11434/api/tags || true
