#!/bin/bash
# Quick test of Continue setup

echo "🧪 Testing Continue Setup"
echo "========================="
echo ""

echo "1️⃣ Testing SSH Tunnel..."
if curl -s --connect-timeout 3 http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✅ SSH tunnel is working"
else
    echo "❌ SSH tunnel not working"
    echo "   Run: ssh -f -N -L 11434:10.0.0.110:11434 -p 2222 root@136.243.155.166"
    exit 1
fi

echo ""
echo "2️⃣ Checking Models on VM..."
MODELS=$(curl -s http://localhost:11434/api/tags | jq -r '.models[] | .name' | wc -l)
echo "   Found $MODELS models"
curl -s http://localhost:11434/api/tags | jq -r '.models[] | "   • \(.name)"'

echo ""
echo "3️⃣ Testing Model Response..."
RESPONSE=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b",
  "prompt": "Say hello",
  "stream": false
}' | jq -r '.response')

if [ ! -z "$RESPONSE" ]; then
    echo "✅ Model responds: $RESPONSE"
else
    echo "❌ Model not responding"
fi

echo ""
echo "4️⃣ Checking MCP Agent Services..."
AGENTS=$(systemctl --user list-units 'agent-*' --no-legend | grep running | wc -l)
echo "   Running agents: $AGENTS/7"
systemctl --user list-units 'agent-*' --no-legend | grep running | awk '{print "   • " $1}'

echo ""
echo "5️⃣ Checking Continue Config..."
if [ -f ~/.continue/config.json ]; then
    echo "✅ Continue config exists"
    CONFIGURED_MODELS=$(jq -r '.models | length' ~/.continue/config.json)
    echo "   Configured models: $CONFIGURED_MODELS"
    MCP_SERVERS=$(jq -r '.mcpServers | length' ~/.continue/config.json)
    echo "   MCP servers: $MCP_SERVERS"
else
    echo "❌ Continue config not found"
fi

echo ""
echo "6️⃣ GPU Status (VM 159)..."
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 "nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv,noheader" 2>/dev/null || echo "   Cannot check GPU (VM might not have GPU)"

echo ""
echo "============================================"
echo "✅ Continue Setup Test Complete!"
echo ""
echo "🚀 Next Steps:"
echo "1. Open VS Code"
echo "2. Press Ctrl+L to open Continue"
echo "3. Type: 'Write a hello world function in Python'"
echo "4. Watch the magic! ✨"
