# Continue MCP Testing Guide

## Current Status (Nov 5, 2025)

✅ **Working MCP Server**: `ollama-code-assistant`
- Type: SSE (Server-Sent Events)
- URL: http://127.0.0.1:5000/mcp/sse
- Status: Active and responding

## Available MCP Tools

The MCP server provides 4 tools for AI-assisted coding:

### 1. generate_code
Generate code using AI models (Python, JavaScript, Java, C++, etc.)

**Usage in Continue:**
```
@ollama-code-assistant generate a Python function to calculate fibonacci numbers
```

**Parameters:**
- `prompt` (required): Description of code to generate
- `language` (optional): Programming language (default: python)
- `model` (optional): AI model to use (default: deepseek-coder:6.7b)

### 2. review_code
Review code for quality, bugs, performance, and security issues

**Usage in Continue:**
```
@ollama-code-assistant review this code for security issues
```

**Parameters:**
- `code` (required): Code to review
- `language` (optional): Programming language

### 3. explain_code
Explain what code does in plain English

**Usage in Continue:**
```
@ollama-code-assistant explain what this function does
```

**Parameters:**
- `code` (required): Code to explain
- `language` (optional): Programming language

### 4. list_models
List available Ollama models

**Usage in Continue:**
```
@ollama-code-assistant list available models
```

## Quick Tests

### Test 1: Check MCP Connection in Continue
1. Open Continue panel in VS Code (Ctrl+Shift+P → "Continue: Open")
2. Look for "ollama-code-assistant" in the Configs dropdown
3. Should show as connected (no timeout error)

### Test 2: Generate Simple Code
In Continue chat:
```
@ollama-code-assistant generate a Python hello world function
```

Expected: Should generate a simple Python function

### Test 3: List Available Models
In Continue chat:
```
@ollama-code-assistant list models
```

Expected: Should return list of 5 Ollama models:
- gemma2:9b
- mistral:7b-instruct
- qwen2.5:7b-instruct
- deepseek-coder:6.7b
- llama3.1:8b

## Manual Testing (CLI)

### Test SSE Endpoint
```bash
curl -s http://127.0.0.1:5000/mcp/sse | head -10
```

Expected output:
```
event: connect
data: {"type": "connect", "timestamp": "..."}

event: tools
data: {"jsonrpc": "2.0", "method": "tools/list", ...}
```

### Test JSON-RPC Call Endpoint
```bash
curl -s -X POST http://127.0.0.1:5000/mcp/call \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' | python3 -m json.tool
```

Expected: JSON response with list of 4 tools

### Test Code Generation (Full Example)
```bash
curl -s -X POST http://127.0.0.1:5000/mcp/call \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "generate_code",
      "arguments": {
        "prompt": "write a function to reverse a string",
        "language": "python",
        "model": "deepseek-coder:6.7b"
      }
    },
    "id": 2
  }' | python3 -m json.tool
```

## Troubleshooting

### Issue: "Connection timed out" in Continue

**Solution:**
1. Check services are running:
   ```bash
   systemctl --user status mcp-agent.service mcp-tunnel.service
   ```

2. Test endpoints manually (see Manual Testing above)

3. Check for duplicate MCP configurations:
   ```bash
   find ~/.continue -name "*.yaml" -o -name "*.yml" | xargs grep -l "mcpServers"
   ```
   Should only find archived files, not active configs.

4. Verify `config.json` has correct MCP server entry:
   ```bash
   grep -A 5 "mcpServers" ~/.continue/config.json
   ```

5. Reload VS Code: `Ctrl+Shift+P` → "Developer: Reload Window"

### Issue: Service not responding

**Solution:**
```bash
# Restart MCP agent
systemctl --user restart mcp-agent.service

# Check logs
journalctl --user -u mcp-agent.service -n 50 --no-pager

# Check port is bound
lsof -i :5000
```

### Issue: Ollama connection fails

**Solution:**
```bash
# Check SSH tunnel
systemctl --user status mcp-tunnel.service

# Test Ollama directly
curl -s http://localhost:11434/api/version

# Restart tunnel
systemctl --user restart mcp-tunnel.service
```

## Configuration Files

### Active Config
- **Main config**: `.continue/config.json`
  - Contains `experimental.mcpServers.ollama-code-assistant`

### Archived Configs (Not in use)
- `.continue/archived/example_agent-duplicate-*.yaml`
- `.continue/archived/new-mcp-server-duplicate-*.yaml`
- `.continue/archived/new-mcp-server-1.yaml`

These were causing duplicate MCP server registrations and have been archived.

## Service Maintenance

### Check Health
```bash
bash ~/.continue/scripts/mcp_health_check.sh
```

### View Service Status
```bash
systemctl --user status mcp-agent.service mcp-tunnel.service mcp-health.timer
```

### View Recent Logs
```bash
journalctl --user -u mcp-agent.service --since "10 minutes ago"
```

### Restart All Services
```bash
systemctl --user restart mcp-agent.service mcp-tunnel.service
```

## Next Steps After Testing

Once you've verified Continue MCP connection works:

1. **Test with real code**: Try generating, reviewing, and explaining actual code from your workspace
2. **Test different models**: Use the `model` parameter to try different Ollama models
3. **Integration**: Use MCP tools in your normal coding workflow
4. **Performance**: Monitor response times and adjust models if needed

## Available Models

All models are accessible through the SSH tunnel to the remote Ollama server:

| Model | Size | Best For | Speed |
|-------|------|----------|-------|
| deepseek-coder:6.7b | 6.7B | Code generation, editing | Fast |
| gemma2:9b | 9B | Reasoning, complex logic | Medium |
| mistral:7b-instruct | 7B | General purpose, instructions | Fast |
| qwen2.5:7b-instruct | 7B | Multilingual, summarization | Fast |
| llama3.1:8b | 8B | Chat, general tasks | Medium |

Default for MCP tools: `deepseek-coder:6.7b`

## Support

For issues, check:
- Main setup guide: `.continue/MCP_SETUP.md`
- VS Code setup: `.continue/VSCODE_SETUP.md`
- Service logs: `journalctl --user -u mcp-agent.service`
