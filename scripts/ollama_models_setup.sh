#!/usr/bin/env bash
#
# Ollama + OpenWebUI model setup helper
# - Pulls a curated set of models for OpenWebUI
# - Safe to re-run; skips already-present models
#
# Usage (run on the server that runs Ollama/OpenWebUI):
#   bash scripts/ollama_models_setup.sh
#
set -euo pipefail

echo "[info] Checking ollama..."
if ! command -v ollama >/dev/null 2>&1; then
  echo "[error] ollama is not installed or not in PATH. See https://ollama.com/download" >&2
  exit 1
fi

# Ensure the daemon is running (best-effort)
if ! curl -sS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "[warn] ollama daemon not responding on :11434; attempting to start in background..."
  nohup ollama serve >/dev/null 2>&1 &
  # Give it a moment
  for i in {1..10}; do
    if curl -sS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then break; fi
    sleep 1
  done
  if ! curl -sS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[error] ollama daemon not reachable on :11434. Start it manually (e.g., 'systemctl start ollama') and retry." >&2
    exit 1
  fi
fi

models=(
  "llama3.1:8b"
  "mistral:7b"
  "qwen2.5:7b-instruct"
  "phi3:mini"
  "minicpm-lm-2"
  "deepseek-coder:6.7b"
  # Optional/code:
  "codellama:7b"
)

echo "[info] Pulling curated models for OpenWebUI..."
for m in "${models[@]}"; do
  echo "[info] -> ollama pull $m"
  if ! ollama pull "$m"; then
    echo "[warn] Failed to pull $m. Continuing with the rest."
  fi
done

echo "[info] Done. In OpenWebUI, go to Settings → Models → Providers and ensure the Ollama endpoint (http://127.0.0.1:11434) is configured."
echo "[info] If you intended 'MiniMax M2' as MiniCPM-LM-2, it's included as 'minicpm-lm-2' in Ollama."
echo "[info] If you meant MiniMax cloud models, add them as an OpenAI-compatible provider in OpenWebUI (see docs/OPENWEBUI_OLLAMA_MODELS.md)."
