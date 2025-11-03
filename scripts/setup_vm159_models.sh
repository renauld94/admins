#!/usr/bin/env bash
#
# Complete setup for VM 159: Start Ollama, pull models, configure OpenWebUI
# Run from your local machine (will prompt for simonadmin password once)
#
set -euo pipefail

echo "=== VM 159 (ubuntuai) Setup: Ollama + Models ==="
echo ""
echo "This script will:"
echo "  1. Start and enable Ollama service"
echo "  2. Pull 7 curated models (llama3.1, mistral, qwen2.5, phi3, minicpm, deepseek-coder, codellama)"
echo "  3. Verify they're available"
echo ""
echo "Note: Model pulls may take 10-20 minutes depending on bandwidth."
echo ""

SSH_CMD="ssh -J root@136.243.155.166:2222 -o StrictHostKeyChecking=no simonadmin@10.0.0.110"

echo "=== Step 1: Start Ollama service ==="
$SSH_CMD "sudo systemctl start ollama && sudo systemctl enable ollama && sleep 2 && sudo systemctl status ollama --no-pager | head -20"

echo ""
echo "=== Step 2: Pull models (this will take a while...) ==="

models=(
  "llama3.1:8b"
  "mistral:7b"
  "qwen2.5:7b-instruct"
  "phi3:mini"
  "minicpm-lm-2"
  "deepseek-coder:6.7b"
  "codellama:7b"
)

for model in "${models[@]}"; do
  echo ""
  echo ">>> Pulling $model..."
  $SSH_CMD "ollama pull $model" || echo "Warning: Failed to pull $model"
done

echo ""
echo "=== Step 3: Verify models ==="
$SSH_CMD "ollama list"

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "  1. Open https://openwebui.simondatalab.de"
echo "  2. Go to Settings → Models → Connections"
echo "  3. Click 'Add Connection' or edit existing Ollama connection"
echo "  4. Set URL to: http://127.0.0.1:11434"
echo "  5. Click 'Verify Connection' then Save"
echo "  6. Models should appear in the dropdown automatically"
echo ""
echo "To verify via API after syncing in UI, run:"
echo "  OPENWEBUI_URL=https://openwebui.simondatalab.de \\"
echo "  OPENWEBUI_TOKEN=YOUR_JWT \\"
echo "  python3 scripts/list_openwebui_models.py"
