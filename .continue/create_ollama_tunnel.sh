#!/bin/bash
# Create SSH tunnel to VM 159 Ollama through jump host

JUMP_HOST="root@136.243.155.166"
JUMP_PORT="2222"
VM_IP="10.0.0.110"
OLLAMA_PORT="11434"
LOCAL_PORT="11434"

echo "🚀 Setting up SSH tunnel to VM 159 Ollama"
echo "=========================================="
echo ""
echo "Jump Host: $JUMP_HOST:$JUMP_PORT"
echo "Target VM: $VM_IP:$OLLAMA_PORT"
echo "Local Port: $LOCAL_PORT"
echo ""

# Check if tunnel already exists
if lsof -ti:$LOCAL_PORT > /dev/null 2>&1; then
    echo "⚠️  Port $LOCAL_PORT is already in use"
    echo ""
    read -p "Kill existing process and restart tunnel? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Killing process on port $LOCAL_PORT..."
        kill $(lsof -ti:$LOCAL_PORT) 2>/dev/null
        sleep 1
    else
        echo "Exiting..."
        exit 0
    fi
fi

echo "🔌 Creating SSH tunnel..."
echo ""
echo "This will forward:"
echo "  localhost:$LOCAL_PORT → $VM_IP:$OLLAMA_PORT (via jump host)"
echo ""

# Create the tunnel in background
ssh -f -N -L $LOCAL_PORT:$VM_IP:$OLLAMA_PORT -p $JUMP_PORT $JUMP_HOST

if [ $? -eq 0 ]; then
    echo "✅ SSH tunnel established!"
    echo ""
    echo "📋 Tunnel active:"
    ps aux | grep "ssh.*$LOCAL_PORT:$VM_IP:$OLLAMA_PORT" | grep -v grep
    echo ""
    echo "🧪 Testing connection..."
    sleep 2
    curl -s http://localhost:$LOCAL_PORT/api/tags | head -10
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Successfully connected to VM 159 Ollama!"
        echo ""
        echo "💡 You can now use Ollama at: http://localhost:11434"
        echo ""
        echo "🎯 To close the tunnel later:"
        echo "   kill \$(lsof -ti:$LOCAL_PORT)"
        echo ""
        echo "📝 The tunnel will stay open in the background."
    else
        echo ""
        echo "❌ Tunnel created but cannot reach Ollama"
        echo "   Check if Ollama is running on VM 159"
    fi
else
    echo "❌ Failed to create SSH tunnel"
    echo "   Check your SSH keys and jump host access"
    exit 1
fi
