#!/usr/bin/env bash
set -euxo pipefail
MODELS=(
  'mistral/mistral-7b-instruct'
  'mistral/mistral-7b-v0.1'
  'mistralai/mistral-7b-instruct'
  'mistral-7b-instruct'
  'mistral-7b-v0.1'
)
for m in "${MODELS[@]}"; do
  echo "--- trying: $m ---"
  if sudo docker exec ollama ollama pull "$m"; then
    echo "PULLED: $m"
    sudo docker exec ollama ollama list || true
    exit 0
  else
    echo "NOT_AVAILABLE: $m" >&2
  fi
done
# none available
sudo docker exec ollama ollama list || true
exit 2
