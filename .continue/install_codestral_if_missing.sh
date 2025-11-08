#!/bin/bash
# install_codestral_if_missing.sh
# Idempotent installer for Codestral 22B into Ollama
# Usage: bash .continue/install_codestral_if_missing.sh
# Logs: ~/.continue/install_logs/codestral_install_$(date +%s).log

set -e

LOG_DIR="$HOME/.continue/install_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/codestral_install_$(date +%s).log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Codestral 22B installation check..." | tee "$LOG_FILE"

# 1. Check if Ollama is running
if ! curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
  echo "[ERROR] Ollama HTTP API not responding at http://127.0.0.1:11434" | tee -a "$LOG_FILE"
  exit 1
fi
echo "[OK] Ollama HTTP API is running" | tee -a "$LOG_FILE"

# 2. Check if Codestral is already installed
INSTALLED_MODELS=$(curl -s http://127.0.0.1:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "")

if echo "$INSTALLED_MODELS" | grep -q "codestral"; then
  echo "[OK] Codestral is already installed" | tee -a "$LOG_FILE"
  MODEL_NAME=$(echo "$INSTALLED_MODELS" | grep "codestral" | head -1)
  echo "Model: $MODEL_NAME" | tee -a "$LOG_FILE"
  exit 0
fi

echo "[INFO] Codestral not found. Starting download..." | tee -a "$LOG_FILE"

# 3. Check disk space (Codestral needs ~6-10GB)
AVAILABLE_GB=$(df "$HOME" | awk 'NR==2 {print int($4/1024/1024)}')
echo "[INFO] Available disk space: ${AVAILABLE_GB}GB" | tee -a "$LOG_FILE"

if [ "$AVAILABLE_GB" -lt 15 ]; then
  echo "[WARNING] Less than 15GB available. Installation may fail." | tee -a "$LOG_FILE"
fi

# 4. Pull Codestral (q4_0 quantization = ~6-7GB)
echo "[INFO] Pulling codestral:22b-v0.1-q4_0..." | tee -a "$LOG_FILE"
if ollama pull codestral:22b-v0.1-q4_0 2>&1 | tee -a "$LOG_FILE"; then
  echo "[OK] Codestral successfully installed" | tee -a "$LOG_FILE"
else
  echo "[ERROR] Failed to install Codestral" | tee -a "$LOG_FILE"
  exit 1
fi

# 5. Verify installation
FINAL_MODELS=$(curl -s http://127.0.0.1:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "")
if echo "$FINAL_MODELS" | grep -q "codestral"; then
  echo "[OK] Verification successful - Codestral is now available" | tee -a "$LOG_FILE"
  echo "Final models:" | tee -a "$LOG_FILE"
  echo "$FINAL_MODELS" | sed 's/^/  - /' | tee -a "$LOG_FILE"
else
  echo "[ERROR] Verification failed - Codestral not in model list" | tee -a "$LOG_FILE"
  exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installation complete!" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
