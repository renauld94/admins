#!/bin/bash
# Install models on VM 159 via SSH jump host

set -e

JUMP_HOST="root@136.243.155.166"
JUMP_PORT="2222"
VM_USER="simonadmin"
VM_IP="10.0.0.110"

echo "🚀 Installing Ollama Models on VM 159"
echo "======================================"
echo ""
echo "Target: $VM_USER@$VM_IP (via $JUMP_HOST:$JUMP_PORT)"
echo ""

# Test connection
echo "🔌 Testing SSH connection..."
if ! ssh -J $JUMP_HOST:$JUMP_PORT $VM_USER@$VM_IP "echo 'SSH OK'" 2>/dev/null; then
    echo "❌ Cannot SSH to VM. Check your SSH keys."
    exit 1
fi

echo "✅ SSH connection OK!"
echo ""

# Show current models
echo "📋 Current models on VM:"
ssh -J $JUMP_HOST:$JUMP_PORT $VM_USER@$VM_IP "ollama list"
echo ""

# Menu
echo "Choose installation set:"
echo ""
echo "1. OPTIMAL SET (Recommended) - ~30GB"
echo "   • Qwen2.5-Coder 7B (best coder) - 4.7GB"
echo "   • DeepSeek-Coder-V2 16B (advanced) - 9GB"
echo "   • Llama 3.2 3B (fast) - 2GB"
echo "   • CodeGemma 7B (autocomplete) - 5GB"
echo "   • Mistral 7B (reasoning) - 4.1GB"
echo "   • Nomic Embed Text (embeddings) - 0.3GB"
echo "   • Gemma2 9B (Vietnamese) - 5.4GB"
echo ""
echo "2. MINIMAL SET - ~12GB"
echo "   • Qwen2.5-Coder 7B (best coder)"
echo "   • Llama 3.2 3B (fast)"
echo "   • Nomic Embed Text (embeddings)"
echo "   • Gemma2 9B (Vietnamese)"
echo ""
echo "3. CODING POWERHOUSE - ~20GB"
echo "   • Qwen2.5-Coder 7B"
echo "   • DeepSeek-Coder-V2 16B"
echo "   • CodeGemma 7B"
echo "   • Nomic Embed Text"
echo ""
echo "4. Just Embeddings Model (Required) - 0.3GB"
echo ""
echo "5. EXIT"
echo ""

read -p "Enter choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🎯 Installing OPTIMAL SET..."
        echo "This will take 20-30 minutes depending on connection speed."
        echo ""
        
        ssh -J $JUMP_HOST:$JUMP_PORT $VM_USER@$VM_IP bash << 'ENDSSH'
set -e
echo "🚀 Starting installation on VM..."
echo ""

echo "[1/7] Qwen2.5-Coder 7B (Best Coder)..."
ollama pull qwen2.5-coder:7b

echo ""
echo "[2/7] DeepSeek-Coder-V2 16B (Advanced)..."
ollama pull deepseek-coder-v2:16b

echo ""
echo "[3/7] Llama 3.2 3B (Fast Queries)..."
ollama pull llama3.2:3b

echo ""
echo "[4/7] CodeGemma 7B (Autocomplete)..."
ollama pull codegemma:7b

echo ""
echo "[5/7] Mistral 7B (Reasoning)..."
ollama pull mistral:7b-instruct-v0.3

echo ""
echo "[6/7] Nomic Embed Text (Embeddings)..."
ollama pull nomic-embed-text

echo ""
echo "[7/7] Gemma2 9B (Vietnamese AI)..."
ollama pull gemma2:9b

echo ""
echo "✅ All models installed!"
ENDSSH
        ;;
        
    2)
        echo ""
        echo "⚡ Installing MINIMAL SET..."
        echo ""
        
        ssh -J $JUMP_HOST:$JUMP_PORT $VM_USER@$VM_IP bash << 'ENDSSH'
set -e
echo "[1/4] Qwen2.5-Coder 7B..."
ollama pull qwen2.5-coder:7b

echo ""
echo "[2/4] Llama 3.2 3B..."
ollama pull llama3.2:3b

echo ""
echo "[3/4] Nomic Embed Text..."
ollama pull nomic-embed-text

echo ""
echo "[4/4] Gemma2 9B..."
ollama pull gemma2:9b

echo ""
echo "✅ Minimal set installed!"
ENDSSH
        ;;
        
    3)
        echo ""
        echo "💻 Installing CODING POWERHOUSE..."
        echo ""
        
        ssh -J $JUMP_HOST:$JUMP_PORT $VM_USER@$VM_IP bash << 'ENDSSH'
set -e
echo "[1/4] Qwen2.5-Coder 7B..."
ollama pull qwen2.5-coder:7b

echo ""
echo "[2/4] DeepSeek-Coder-V2 16B (This is big!)..."
ollama pull deepseek-coder-v2:16b

echo ""
echo "[3/4] CodeGemma 7B..."
ollama pull codegemma:7b

echo ""
echo "[4/4] Nomic Embed Text..."
ollama pull nomic-embed-text

echo ""
echo "✅ Coding powerhouse installed!"
ENDSSH
        ;;
        
    4)
        echo ""
        echo "📦 Installing Nomic Embed Text..."
        echo ""
        
        ssh -J $JUMP_HOST:$JUMP_PORT $VM_USER@$VM_IP "ollama pull nomic-embed-text"
        
        echo ""
        echo "✅ Embeddings model installed!"
        ;;
        
    5)
        echo "Exiting..."
        exit 0
        ;;
        
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "✅ Installation Complete!"
echo ""
echo "📋 All models on VM 159:"
ssh -J $JUMP_HOST:$JUMP_PORT $VM_USER@$VM_IP "ollama list"
echo ""
echo "💡 Next Steps:"
echo "1. Models are ready on VM 159"
echo "2. SSH tunnel is already running (localhost:11434 → VM)"
echo "3. Restart VS Code to use new models"
echo ""
echo "🚀 Your Epic Private Copilot is ready!"
