#!/bin/bash
# Setup and start Ollama Code Assistant Agent

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$SCRIPT_DIR/agents/agents_continue"
SYSTEMD_DIR="$SCRIPT_DIR/systemd"

echo "=========================================="
echo "🤖 Ollama Code Assistant Agent Setup"
echo "=========================================="

# 1. Check Python dependencies
echo ""
echo "📦 Checking Python dependencies..."
if ! python3 -c "import fastapi" 2>/dev/null; then
    echo "Installing fastapi..."
    pip3 install fastapi uvicorn requests --user
else
    echo "✅ Dependencies already installed"
fi

# 2. Test Ollama connection
echo ""
echo "🔌 Testing Ollama connection (10.0.0.110:11434)..."
if curl -s -m 5 http://10.0.0.110:11434/api/tags > /dev/null; then
    echo "✅ Ollama is reachable"
    MODELS=$(curl -s http://10.0.0.110:11434/api/tags | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data.get('models', [])))")
    echo "   Found $MODELS models"
else
    echo "⚠️  Warning: Cannot reach Ollama at 10.0.0.110:11434"
    echo "   The agent will start but may not function correctly"
fi

# 3. Create context directory
echo ""
echo "📁 Creating context directory..."
mkdir -p "$SCRIPT_DIR/workspace/agents/context/ollama-code-assistant"
echo "✅ Context directory ready"

# 4. Install systemd service (optional)
echo ""
echo "🔧 Systemd service setup..."
if [ -f "$SYSTEMD_DIR/ollama-code-assistant.service" ]; then
    echo "Service file found: $SYSTEMD_DIR/ollama-code-assistant.service"
    echo "To install system-wide:"
    echo "   sudo cp $SYSTEMD_DIR/ollama-code-assistant.service /etc/systemd/system/"
    echo "   sudo systemctl daemon-reload"
    echo "   sudo systemctl enable ollama-code-assistant"
    echo "   sudo systemctl start ollama-code-assistant"
else
    echo "⚠️  Service file not found"
fi

# 5. Start agent in background
echo ""
echo "🚀 Starting Ollama Code Assistant Agent..."
echo "   Agent will run on http://127.0.0.1:5110"

cd "$AGENT_DIR"

# Check if already running
if pgrep -f "ollama_code_assistant.py" > /dev/null; then
    echo "⚠️  Agent already running! Stopping it first..."
    pkill -f "ollama_code_assistant.py"
    sleep 2
fi

# Start in background
nohup python3 ollama_code_assistant.py > /tmp/ollama-agent.log 2>&1 &
AGENT_PID=$!

sleep 3

# 6. Verify agent started
echo ""
echo "✅ Agent started with PID: $AGENT_PID"
echo "   Logs: /tmp/ollama-agent.log"

if curl -s -m 5 http://127.0.0.1:5110/health > /dev/null; then
    echo "   Health check: ✅ PASSED"
    
    # Show available endpoints
    echo ""
    echo "📡 Available endpoints:"
    echo "   GET  /health          - Health check"
    echo "   GET  /models          - List Ollama models"
    echo "   POST /generate        - Generate code"
    echo "   POST /review          - Review code"
    echo "   POST /explain         - Explain code"
    echo "   POST /improve         - Improve code"
    echo "   POST /debug           - Debug code"
else
    echo "   Health check: ❌ FAILED"
    echo "   Check logs: tail -f /tmp/ollama-agent.log"
fi

echo ""
echo "=========================================="
echo "📝 Quick Test"
echo "=========================================="
echo "Run the test suite:"
echo "   cd $SCRIPT_DIR/agents"
echo "   python3 test_ollama_agent.py"
echo ""
echo "Or make API calls directly:"
echo '   curl -X POST http://127.0.0.1:5110/generate \'
echo '     -H "Content-Type: application/json" \'
echo '     -d '"'"'{"prompt": "write hello world", "language": "python"}'"'"
echo ""
echo "To stop the agent:"
echo "   pkill -f ollama_code_assistant.py"
echo "=========================================="
