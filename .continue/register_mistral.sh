#!/usr/bin/env bash
set -euxo pipefail

MODEL=/mnt/newdisk/models/mistral-7b-v0.1/mistral-7b-v0.1.gguf

if [ ! -f "$MODEL" ]; then
  echo "Model file not found at $MODEL"
  echo "Place the GGUF at that path or run the HF installer script first (/mnt/newdisk/install_mistral_with_hf.sh)"
  exit 2
fi

# Create destination dirs
sudo mkdir -p /opt/openwebui-data/models
sudo mkdir -p /opt/ollama/models

# Copy model into OpenWebUI data dir
sudo cp -v "$MODEL" /opt/openwebui-data/models/
sudo chown root:root /opt/openwebui-data/models/$(basename "$MODEL")
sudo chmod 644 /opt/openwebui-data/models/$(basename "$MODEL")

# Copy into Ollama models dir
sudo cp -v "$MODEL" /opt/ollama/models/
sudo chown root:root /opt/ollama/models/$(basename "$MODEL")
sudo chmod 644 /opt/ollama/models/$(basename "$MODEL")

# Restart containers to pick up new files
# Try restarting both; ignore failures for one or the other
sudo docker restart ollama || true
sudo docker restart open-webui || true

# wait a bit for services
sleep 6

echo "--- ollama list ---"
sudo docker exec ollama ollama list || true

echo "--- remote ollama /api/tags ---"
# The ollama service typically exposes an API on 127.0.0.1:11434 inside the host
curl -sS http://127.0.0.1:11434/api/tags || true

echo "Registration script finished. If the model does not appear in ollama list, check ollama logs and whether Ollama supports direct GGUF placement or requires an import process."
