#!/bin/bash
# Epic Private Copilot - Model Installation Script
# For Intel Xeon + NVIDIA Quadro RTX 3000 setup

set -e

echo "🚀 Epic Private Copilot - Model Installation"
echo "=============================================="
echo ""
echo "Your Hardware:"
echo "  CPU: Intel Xeon W-10855M (6 cores, 12 threads)"
echo "  GPU: NVIDIA Quadro RTX 3000 (6GB VRAM)"
echo "  RAM: 30GB total"
echo "  Disk: 174GB available"
echo ""

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "❌ Error: Ollama is not running!"
    echo "Start Ollama first: systemctl --user start ollama"
    exit 1
fi

echo "✅ Ollama is running"
echo ""

# Show current models
echo "📋 Current models:"
ollama list
echo ""

# Ask user which set to install
echo "Choose installation set:"
echo ""
echo "1. OPTIMAL SET (Recommended) - ~16GB"
echo "   - Qwen2.5-Coder 7B (best coder)"
echo "   - Llama 3.2 3B (fast queries)"
echo "   - CodeGemma 7B (autocomplete)"
echo "   - Mistral 7B (reasoning)"
echo "   - Nomic Embed Text (embeddings)"
echo ""
echo "2. MINIMAL SET - ~7GB"
echo "   - Qwen2.5-Coder 7B only (best coder)"
echo "   - Nomic Embed Text (embeddings)"
echo ""
echo "3. AGGRESSIVE SET - ~29GB"
echo "   - All optimal models PLUS:"
echo "   - DeepSeek-Coder-V2 16B (advanced)"
echo "   - Phi 3.5 3.8B (efficient)"
echo ""
echo "4. CUSTOM - Choose individual models"
echo ""
echo "5. EXIT"
echo ""

read -p "Enter choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🎯 Installing OPTIMAL SET..."
        echo ""
        
        echo "1/5 Installing Qwen2.5-Coder 7B (Best for Code)..."
        ollama pull qwen2.5-coder:7b
        
        echo ""
        echo "2/5 Installing Llama 3.2 3B (Fast Queries)..."
        ollama pull llama3.2:3b
        
        echo ""
        echo "3/5 Installing CodeGemma 7B (Autocomplete)..."
        ollama pull codegemma:7b
        
        echo ""
        echo "4/5 Installing Mistral 7B (Reasoning)..."
        ollama pull mistral:7b-instruct-v0.3
        
        echo ""
        echo "5/5 Installing Nomic Embed Text (Embeddings)..."
        ollama pull nomic-embed-text
        ;;
        
    2)
        echo ""
        echo "⚡ Installing MINIMAL SET..."
        echo ""
        
        echo "1/2 Installing Qwen2.5-Coder 7B..."
        ollama pull qwen2.5-coder:7b
        
        echo ""
        echo "2/2 Installing Nomic Embed Text..."
        ollama pull nomic-embed-text
        ;;
        
    3)
        echo ""
        echo "🔥 Installing AGGRESSIVE SET..."
        echo ""
        
        echo "1/7 Installing Qwen2.5-Coder 7B..."
        ollama pull qwen2.5-coder:7b
        
        echo ""
        echo "2/7 Installing DeepSeek-Coder-V2 16B (This is BIG!)..."
        ollama pull deepseek-coder-v2:16b
        
        echo ""
        echo "3/7 Installing Llama 3.2 3B..."
        ollama pull llama3.2:3b
        
        echo ""
        echo "4/7 Installing CodeGemma 7B..."
        ollama pull codegemma:7b
        
        echo ""
        echo "5/7 Installing Mistral 7B..."
        ollama pull mistral:7b-instruct-v0.3
        
        echo ""
        echo "6/7 Installing Phi 3.5 3.8B..."
        ollama pull phi3.5:3.8b
        
        echo ""
        echo "7/7 Installing Nomic Embed Text..."
        ollama pull nomic-embed-text
        ;;
        
    4)
        echo ""
        echo "🎨 CUSTOM INSTALLATION"
        echo ""
        
        models=("qwen2.5-coder:7b" "deepseek-coder-v2:16b" "llama3.2:3b" "codegemma:7b" "mistral:7b-instruct-v0.3" "phi3.5:3.8b" "command-r:35b" "llama3.1:8b" "nomic-embed-text")
        descriptions=("Qwen2.5-Coder 7B (Best coder)" "DeepSeek-Coder-V2 16B (Advanced)" "Llama 3.2 3B (Fast)" "CodeGemma 7B (Autocomplete)" "Mistral 7B (Reasoning)" "Phi 3.5 3.8B (Efficient)" "Command-R 35B (Powerhouse)" "Llama 3.1 8B (General)" "Nomic Embed Text (Required)")
        
        for i in "${!models[@]}"; do
            echo "$((i+1)). ${descriptions[$i]}"
        done
        
        echo ""
        read -p "Enter model numbers to install (space-separated, e.g., 1 3 4): " selections
        
        echo ""
        for num in $selections; do
            if [[ $num -ge 1 && $num -le ${#models[@]} ]]; then
                idx=$((num-1))
                echo "Installing ${descriptions[$idx]}..."
                ollama pull "${models[$idx]}"
                echo ""
            fi
        done
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
echo "📋 All installed models:"
ollama list
echo ""
echo "💡 Next Steps:"
echo "1. The models are ready to use!"
echo "2. Reload VS Code to use them in Continue"
echo "3. Check ~/.continue/config.json to configure model preferences"
echo ""
echo "🎯 To test a model:"
echo "   ollama run qwen2.5-coder:7b"
echo ""
echo "📊 GPU Status:"
nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader 2>/dev/null || echo "Run 'nvidia-smi' to check GPU usage"
echo ""
echo "🚀 Your Epic Private Copilot is ready!"
