#!/bin/bash
# Continue + MCP + Agents Health Check

echo "🔍 CONTINUE HEALTH CHECK"
echo "========================"
echo ""

# 1. Check Ollama
echo "1️⃣ Ollama Status:"
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "   ✅ Ollama running on localhost:11434"
    echo "   📦 Available models:"
    curl -s http://localhost:11434/api/tags | jq -r '.models[].name' | sed 's/^/      - /'
else
    echo "   ❌ Ollama not responding on localhost:11434"
fi
echo ""

# 2. Check MCP Agent
echo "2️⃣ MCP Agent Status:"
if systemctl --user is-active --quiet mcp-agent.service; then
    echo "   ✅ MCP agent running"
    pid=$(systemctl --user show -p MainPID --value mcp-agent.service)
    echo "   📌 PID: $pid"
else
    echo "   ❌ MCP agent not running"
fi
echo ""

# 3. Check All Agents
echo "3️⃣ Agent Services:"
systemctl --user list-units 'agent-*' --no-legend | while read unit load active sub desc; do
    if [[ "$active" == "active" ]]; then
        echo "   ✅ $unit"
    else
        echo "   ❌ $unit ($active)"
    fi
done
echo ""

# 4. Check MCP SSE Endpoint
echo "4️⃣ MCP SSE Endpoint:"
if timeout 2 curl -s http://127.0.0.1:5000/mcp/sse > /dev/null 2>&1; then
    echo "   ✅ MCP SSE responding at http://127.0.0.1:5000/mcp/sse"
else
    echo "   ❌ MCP SSE not responding"
fi
echo ""

# 5. Check Continue Config
echo "5️⃣ Continue Configuration:"
if [[ -f ~/.continue/config.json ]]; then
    echo "   ✅ Config found at ~/.continue/config.json"
    model_count=$(jq '.models | length' ~/.continue/config.json 2>/dev/null || echo "0")
    echo "   📊 Configured models: $model_count"
else
    echo "   ❌ Continue config not found"
fi
echo ""

# 6. Summary
echo "📋 SUMMARY"
echo "=========="
ollama_ok=$(curl -s http://localhost:11434/api/tags > /dev/null 2>&1 && echo "OK" || echo "FAIL")
mcp_ok=$(systemctl --user is-active --quiet mcp-agent.service && echo "OK" || echo "FAIL")
agents_ok=$(systemctl --user list-units 'agent-*' --no-legend | grep -q active && echo "OK" || echo "FAIL")

if [[ "$ollama_ok" == "OK" && "$mcp_ok" == "OK" && "$agents_ok" == "OK" ]]; then
    echo "✅ All systems operational"
    exit 0
else
    echo "⚠️ Some systems need attention:"
    [[ "$ollama_ok" != "OK" ]] && echo "   - Ollama"
    [[ "$mcp_ok" != "OK" ]] && echo "   - MCP Agent"
    [[ "$agents_ok" != "OK" ]] && echo "   - Agent Services"
    exit 1
fi
