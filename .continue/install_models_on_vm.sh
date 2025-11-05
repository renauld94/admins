#!/bin/bash
# Install Epic Copilot Models on VM 159 (10.0.0.110)

set -e

VM_IP="10.0.0.110"
VM_USER="simonadmin"

echo "🚀 Epic Copilot - VM Installation"
echo "=================================="
echo ""
echo "Target VM: $VM_USER@$VM_IP"
echo ""

# Test VPN connection
echo "🔌 Testing VPN connection..."
if ! ping -c 1 -W 2 $VM_IP &> /dev/null; then
    echo "❌ Cannot reach VM at $VM_IP"
    echo ""
    echo "VPN might not be connected. Try:"
    echo "  sudo systemctl start wg-quick@wg0"
    echo ""
    echo "Or connect your VPN manually, then run this script again."
    exit 1
fi

echo "✅ VM is reachable!"
echo ""

# Test SSH connection
echo "🔐 Testing SSH connection..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes $VM_USER@$VM_IP "echo 'SSH OK'" &> /dev/null; then
    echo "❌ Cannot SSH to VM. You may need to:"
    echo "  1. Add your SSH key: ssh-copy-id $VM_USER@$VM_IP"
    echo "  2. Or run with password authentication"
    echo ""
    read -p "Try with password? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ SSH connection OK!"
echo ""

# Show current models on VM
echo "📋 Current models on VM:"
ssh $VM_USER@$VM_IP "ollama list" 2>/dev/null || echo "Cannot query Ollama on VM"
echo ""

# Ask which set to install
echo "Choose installation set:"
echo ""
echo "1. OPTIMAL SET (Recommended) - ~30GB"
echo "   - Qwen2.5-Coder 7B (best coder)"
echo "   - DeepSeek-Coder-V2 16B (advanced)"
echo "   - Llama 3.2 3B (fast queries)"
echo "   - CodeGemma 7B (autocomplete)"
echo "   - Mistral 7B (reasoning)"
echo "   - Nomic Embed Text (embeddings)"
echo "   - Keep existing Gemma2 9B (Vietnamese)"
echo ""
echo "2. MINIMAL SET - ~12GB"
echo "   - Qwen2.5-Coder 7B (best coder)"
echo "   - Llama 3.2 3B (fast queries)"
echo "   - Nomic Embed Text (embeddings)"
echo "   - Keep existing Gemma2 9B"
echo ""
echo "3. CODING FOCUSED - ~20GB"
echo "   - Qwen2.5-Coder 7B"
echo "   - DeepSeek-Coder-V2 16B"
echo "   - CodeGemma 7B"
echo "   - Nomic Embed Text"
echo "   - Keep existing Gemma2 9B"
echo ""
echo "4. EXIT"
echo ""

read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🎯 Installing OPTIMAL SET on VM..."
        echo ""
        
        ssh $VM_USER@$VM_IP << 'ENDSSH'
echo "Installing models on VM..."
echo ""

echo "1/6 Installing Qwen2.5-Coder 7B (Best for Code)..."
ollama pull qwen2.5-coder:7b

echo ""
echo "2/6 Installing DeepSeek-Coder-V2 16B (Advanced)..."
ollama pull deepseek-coder-v2:16b

echo ""
echo "3/6 Installing Llama 3.2 3B (Fast Queries)..."
ollama pull llama3.2:3b

echo ""
echo "4/6 Installing CodeGemma 7B (Autocomplete)..."
ollama pull codegemma:7b

echo ""
echo "5/6 Installing Mistral 7B (Reasoning)..."
ollama pull mistral:7b-instruct-v0.3

echo ""
echo "6/6 Installing Nomic Embed Text (Embeddings)..."
ollama pull nomic-embed-text

echo ""
echo "✅ All models installed!"
ollama list
ENDSSH
        ;;
        
    2)
        echo ""
        echo "⚡ Installing MINIMAL SET on VM..."
        echo ""
        
        ssh $VM_USER@$VM_IP << 'ENDSSH'
echo "Installing minimal model set on VM..."
echo ""

echo "1/3 Installing Qwen2.5-Coder 7B..."
ollama pull qwen2.5-coder:7b

echo ""
echo "2/3 Installing Llama 3.2 3B..."
ollama pull llama3.2:3b

echo ""
echo "3/3 Installing Nomic Embed Text..."
ollama pull nomic-embed-text

echo ""
echo "✅ Minimal set installed!"
ollama list
ENDSSH
        ;;
        
    3)
        echo ""
        echo "💻 Installing CODING FOCUSED SET on VM..."
        echo ""
        
        ssh $VM_USER@$VM_IP << 'ENDSSH'
echo "Installing coding-focused models on VM..."
echo ""

echo "1/4 Installing Qwen2.5-Coder 7B..."
ollama pull qwen2.5-coder:7b

echo ""
echo "2/4 Installing DeepSeek-Coder-V2 16B..."
ollama pull deepseek-coder-v2:16b

echo ""
echo "3/4 Installing CodeGemma 7B..."
ollama pull codegemma:7b

echo ""
echo "4/4 Installing Nomic Embed Text..."
ollama pull nomic-embed-text

echo ""
echo "✅ Coding set installed!"
ollama list
ENDSSH
        ;;
        
    4)
        echo "Exiting..."
        exit 0
        ;;
        
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "✅ Installation Complete on VM!"
echo ""
echo "📋 Models on VM $VM_IP:"
ssh $VM_USER@$VM_IP "ollama list"
echo ""
echo "💡 Next Steps:"
echo "1. Models are now running on VM 159"
echo "2. Your Continue config already points to the VM"
echo "3. Update ~/.continue/config.json with new model list"
echo "4. Restart VS Code: Ctrl+Shift+P → 'Developer: Reload Window'"
echo ""
echo "🎯 To test VM Ollama:"
echo "   curl http://10.0.0.110:11434/api/tags | jq"
echo ""
echo "🚀 Your Epic Private Copilot is ready on VM!"
