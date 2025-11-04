#!/bin/bash
# 🤖 Deploy AI Services Stack to VM 10.0.0.110
# Created: November 4, 2025
# Purpose: Install and configure AI-powered Vietnamese course services

set -e

VM_HOST="10.0.0.110"
VM_USER="simonadmin"
JUMP_HOST="root@136.243.155.166:2222"
SSH_CMD="ssh -J $JUMP_HOST $VM_USER@$VM_HOST"

echo "================================================"
echo "🤖 AI SERVICES DEPLOYMENT - VM 10.0.0.110"
echo "================================================"
echo ""

# Test connectivity
echo "⏳ Testing VM connectivity..."
if $SSH_CMD "echo 'VM Online!'" 2>/dev/null; then
    echo "✅ VM 10.0.0.110 is reachable!"
else
    echo "❌ VM not ready yet. Please wait for reboot to complete."
    exit 1
fi

# Check system resources
echo ""
echo "📊 System Resources:"
$SSH_CMD "echo '  OS:' && cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2"
$SSH_CMD "echo '  RAM:' && free -h | grep Mem | awk '{print \$2, \"total,\", \$3, \"used\"}'"
$SSH_CMD "echo '  Disk:' && df -h / | tail -1 | awk '{print \$2, \"total,\", \$3, \"used,\", \$5, \"usage\"}'"
$SSH_CMD "echo '  CPU:' && nproc && echo 'cores'"

# Check for GPU
echo ""
echo "🎮 Checking for GPU..."
if $SSH_CMD "command -v nvidia-smi" 2>/dev/null; then
    echo "✅ NVIDIA GPU detected!"
    $SSH_CMD "nvidia-smi --query-gpu=name,memory.total --format=csv,noheader"
else
    echo "ℹ️  No GPU detected (will use CPU for inference)"
fi

# Install Ollama
echo ""
echo "🚀 Installing Ollama..."
$SSH_CMD "curl -fsSL https://ollama.com/install.sh | sh" || echo "Ollama may already be installed"

# Start Ollama service
echo ""
echo "🔧 Starting Ollama service..."
$SSH_CMD "sudo systemctl enable ollama && sudo systemctl start ollama && sudo systemctl status ollama --no-pager" || true

# Wait for Ollama to be ready
echo ""
echo "⏳ Waiting for Ollama to be ready..."
sleep 5

# Pull Vietnamese-capable models
echo ""
echo "📥 Pulling AI models (this may take 10-20 minutes)..."
echo "  - qwen2.5:7b (~4.5GB) - Fast responses, good Vietnamese"
$SSH_CMD "ollama pull qwen2.5:7b" || echo "Failed to pull qwen2.5:7b, continuing..."

echo "  - qwen2.5:14b (~9GB) - Better accuracy, slower"
$SSH_CMD "ollama pull qwen2.5:14b" || echo "Failed to pull qwen2.5:14b, continuing..."

# Test Ollama
echo ""
echo "🧪 Testing Ollama..."
$SSH_CMD "ollama run qwen2.5:7b 'Translate to Vietnamese: Hello, how are you?' --verbose" || echo "Test may have failed"

# Install Python dependencies
echo ""
echo "🐍 Installing Python environment..."
$SSH_CMD "sudo apt update && sudo apt install -y python3-pip python3-venv ffmpeg portaudio19-dev postgresql"

# Create AI services directory
echo ""
echo "📁 Creating AI services directory..."
$SSH_CMD "mkdir -p ~/vietnamese-ai/{conversation,learning,content,pronunciation,grammar}"

# Upload service files
echo ""
echo "📤 Uploading AI service code..."
# We'll create these files next
echo "  (Service files will be created in next step)"

echo ""
echo "📦 Installing Python packages..."
# Install Python packages
echo ""
echo "📦 Installing Python packages..."
$SSH_CMD "cd ~/vietnamese-ai && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip"
$SSH_CMD "cd ~/vietnamese-ai && source venv/bin/activate && pip install fastapi uvicorn[standard] websockets python-multipart"
$SSH_CMD "cd ~/vietnamese-ai && source venv/bin/activate && pip install ollama librosa dtaidistance numpy pandas scikit-learn"
# Use gTTS as a lightweight, Python-3.12-compatible TTS fallback instead of 'TTS' which may
# have incompatible binary wheels for some Python versions. If you need higher-quality
# TTS later, consider running Coqui TTS in Docker or using a GPU-enabled VM.
$SSH_CMD "cd ~/vietnamese-ai && source venv/bin/activate && pip install sqlalchemy asyncpg gTTS pydub || echo 'Some optional packages failed to install, continuing...'"

# Setup PostgreSQL database
echo ""
echo "🗄️  Setting up PostgreSQL database..."
$SSH_CMD "sudo -u postgres psql -c \"CREATE DATABASE vietnamese_learning;\" || echo 'DB may exist'"
$SSH_CMD "sudo -u postgres psql -c \"CREATE USER aiuser WITH PASSWORD 'ai_secure_pass_2025';\" || echo 'User may exist'"
$SSH_CMD "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE vietnamese_learning TO aiuser;\""

echo ""
echo "================================================"
echo "✅ AI STACK INSTALLATION COMPLETE!"
echo "================================================"
echo ""
echo "Next Steps:"
echo "1. Deploy service code"
echo "2. Configure nginx reverse proxy"
echo "3. Start services"
echo "4. Integrate into Moodle"
echo ""
