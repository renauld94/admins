#!/usr/bin/env bash
set -euxo pipefail
MODEL_DIR=/mnt/newdisk/models/mistral-7b-v0.1
FILE="$MODEL_DIR/mistral-7b-v0.1.gguf"
URL="https://huggingface.co/mistralai/mistral-7b-v0.1/resolve/main/mistral-7b-v0.1.gguf"

mkdir -p "$MODEL_DIR"
# disk check
echo "Disk space at target:"; df -h "$MODEL_DIR" || true
# try to download
if command -v aria2c >/dev/null 2>&1; then
  echo "Using aria2c to download"
  aria2c -x 16 -s 16 -k 1M -d "$MODEL_DIR" -o "mistral-7b-v0.1.gguf" "$URL"
else
  echo "Using curl to download"
  curl -C - -L --retry 5 --retry-delay 5 -o "$FILE" "$URL"
fi
# show result
ls -lh "$FILE" || true
file "$FILE" || true
chmod 644 "$FILE" || true

echo "Download finished (if successful). Next steps: register the model with your runtime (ollama/OpenWebUI) or place the file into the runtime-specific models dir." 
