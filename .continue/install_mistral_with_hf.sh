#!/usr/bin/env bash
set -euo pipefail
MODEL_DIR=/mnt/newdisk/models/mistral-7b-v0.1
FILE="$MODEL_DIR/mistral-7b-v0.1.gguf"
URL="https://huggingface.co/mistralai/mistral-7b-v0.1/resolve/main/mistral-7b-v0.1.gguf"

mkdir -p "$MODEL_DIR"

echo "Target: $FILE"

if [ -z "${HF_TOKEN:-}" ]; then
  echo "No HF_TOKEN provided in the environment. Public download likely requires authentication for large files."
  echo "Two options:"
  echo "  1) Export HF_TOKEN=your_token and run this script (it will use the token to download)."
  echo "  2) Provide a direct MODEL_URL to a hosted GGUF file and run: MODEL_URL=... ./install_mistral_with_hf.sh"
  exit 1
fi

# Use curl with Authorization header (supports resume)
echo "Downloading with HF token (not echoed)."
mkdir -p "$MODEL_DIR"

# Use a temp file to avoid partial confusion
TMP="$FILE.part"

curl -C - -L -H "Authorization: Bearer $HF_TOKEN" --retry 5 --retry-delay 5 -o "$TMP" "$URL"
# move into place
mv "$TMP" "$FILE"

# sanity check: file should be >100MB (quick check)
SIZE=$(stat -c%s "$FILE" || echo 0)
if [ "$SIZE" -lt $((100*1024*1024)) ]; then
  echo "Downloaded file is smaller than 100MB ($SIZE bytes). This probably failed. Aborting and leaving file in place for inspection." >&2
  exit 2
fi

ls -lh "$FILE"
file "$FILE" || true
chmod 644 "$FILE" || true

echo "Download complete. Next: import this GGUF into your runtime (OpenWebUI or Ollama). I can help wire OpenWebUI to load it or attempt to register with Ollama if you want."