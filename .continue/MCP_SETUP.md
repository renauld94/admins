# Continue MCP Integration - Complete Setup Guide

Complete guide for integrating Continue with local Ollama models via the Model Context Protocol (MCP).

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        VS Code / Continue                        │
│                 (MCP Client - SSE Connection)                    │
└────────────────────────────┬────────────────────────────────────┘
                             │ http://localhost:5000/mcp/sse
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              Local MCP Agent (FastAPI Server)                    │
│         ollama_code_assistant.py - Port 5000                     │
│    Tools: generate_code, review_code, explain_code, list_models │
└────────────────────────────┬────────────────────────────────────┘
                             │ http://localhost:11434/api/*
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SSH Tunnel (systemd)                          │
│      localhost:11434 → 10.0.0.110:11434 (via jump host)        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Remote Ollama   │
                    │  VM (10.0.0.110) │
                    │                  │
                    │  Models:         │
                    │  • gemma2:9b     │
                    │  • mistral:7b    │
                    │  • qwen2.5:7b    │
                    │  • deepseek:6.7b │
                    │  • llama3.1:8b   │
                    └──────────────────┘
```

## Quick Start

```bash
# 1. Install systemd services
cd /home/simon/Learning-Management-System-Academy/.continue/systemd
for unit in *.service *.timer; do
  ln -sf "$(pwd)/$unit" ~/.config/systemd/user/
done

# 2. Enable and start services
systemctl --user daemon-reload
systemctl --user enable --now mcp-agent.service mcp-tunnel.service mcp-health.timer

# 3. Verify everything is running
bash ~/.continue/scripts/mcp_health_check.sh
```

## Components

### 1. MCP Agent (`ollama_code_assistant.py`)

FastAPI server providing MCP tools for code assistance.

**Endpoints:**
- `GET /mcp/sse` - Server-Sent Events (tool discovery)
- `POST /mcp/call` - JSON-RPC 2.0 (tool invocation)
- `GET /health` - Health check endpoint

**Available Tools:**
- `generate_code` - Generate code using AI models
- `review_code` - Review code quality and security
- `explain_code` - Explain code functionality
- `list_models` - List available Ollama models

**Configuration:**
```python
Host: 127.0.0.1
Port: 5000
Default Model: deepseek-coder:6.7b
Ollama URL: http://localhost:11434
```

### 2. SSH Tunnel (`mcp-tunnel.service`)

Persistent SSH tunnel to remote Ollama server.

**Connection:**
```
Local: localhost:11434
→ Jump: root@136.243.155.166:2222
→ Remote: simonadmin@10.0.0.110:11434
```

**Features:**
- Key-based authentication (`~/.ssh/id_ed25519_mcp`)
- Auto-reconnect with keepalives
- Managed by systemd (survives network disruptions)

### 3. Health Monitoring

Automated health checks every 5 minutes.

**Monitors:**
- SSE endpoint availability
- Ollama API connectivity

**Auto-Recovery:**
- Restarts services on failure
- Retries for up to 20 seconds
- Logs all actions to systemd journal

## Installation

### Prerequisites

```bash
# Install Python dependencies
pip3 install fastapi uvicorn requests pydantic

# Ensure systemd user services enabled
systemctl --user status
```

### SSH Key Setup

```bash
# 1. Create dedicated SSH key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_mcp -N ""

# 2. Copy to remote server via jump host
ssh-copy-id -o ProxyJump=root@136.243.155.166:2222 \
  -i ~/.ssh/id_ed25519_mcp.pub simonadmin@10.0.0.110

# 3. Test connection
ssh -i ~/.ssh/id_ed25519_mcp \
  -J root@136.243.155.166:2222 \
  simonadmin@10.0.0.110 echo "Connected"
```

### Service Installation

```bash
# 1. Navigate to systemd directory
cd /home/simon/Learning-Management-System-Academy/.continue/systemd

# 2. Link all units to user systemd
for unit in *.service *.timer; do
  ln -sf "$(pwd)/$unit" ~/.config/systemd/user/
done

# 3. Reload and enable services
systemctl --user daemon-reload
systemctl --user enable --now mcp-agent.service
systemctl --user enable --now mcp-tunnel.service
systemctl --user enable --now mcp-health.timer

# 4. Verify services started
systemctl --user status mcp-agent.service
systemctl --user status mcp-tunnel.service
systemctl --user list-timers
```

## Continue Configuration

Update `.continue/config.json`:

```json
{
  "models": [
    {
      "title": "DeepSeek Coder (VM)",
      "provider": "ollama",
      "model": "deepseek-coder:6.7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Llama 3.1 (VM)",
      "provider": "ollama",
      "model": "llama3.1:8b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "mcpServers": [
    {
      "type": "sse",
      "url": "http://127.0.0.1:5000/mcp/sse",
      "name": "ollama-code-assistant"
    }
  ],
  "modelRoles": {
    "default": "DeepSeek Coder (VM)",
    "chat": "Llama 3.1 (VM)"
  }
}
```

## Testing & Verification

### Manual Tests

```bash
# Test SSE endpoint
curl -N http://localhost:5000/mcp/sse

# Test JSON-RPC
curl -X POST http://localhost:5000/mcp/call \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

# Test Ollama via tunnel
curl http://localhost:11434/api/tags

# Run health check
bash ~/.continue/scripts/mcp_health_check.sh
```

### Verify in VS Code

1. Open VS Code
2. Reload window: `Ctrl+Shift+P` → "Developer: Reload Window"
3. Open Continue panel
4. Check for "ollama-code-assistant" in MCP servers list
5. Try using a tool or model

## Service Management

### Status & Logs

```bash
# Check service status
systemctl --user status mcp-agent.service
systemctl --user status mcp-tunnel.service
systemctl --user status mcp-health.timer

# View logs (live)
journalctl --user -u mcp-agent.service -f
journalctl --user -u mcp-tunnel.service -f
journalctl --user -u mcp-health.service -f

# View recent logs
journalctl --user -u mcp-agent.service -n 100
journalctl --user -u mcp-health.service -n 50

# Check log files
tail -f ~/.local/state/mcp-agent.log
tail -f ~/.local/state/mcp-agent.err
```

### Start/Stop/Restart

```bash
# Restart a service
systemctl --user restart mcp-agent.service

# Stop all services
systemctl --user stop mcp-agent.service mcp-tunnel.service

# Start all services
systemctl --user start mcp-agent.service mcp-tunnel.service

# Reload after config changes
systemctl --user daemon-reload
systemctl --user restart mcp-agent.service
```

## Troubleshooting

### Port 5000 Already in Use

```bash
# Find process using port
lsof -ti:5000

# Kill all matching processes
pkill -9 -f ollama_code_assistant.py

# Restart service
systemctl --user restart mcp-agent.service
```

### SSH Tunnel Not Working

```bash
# Check tunnel status
systemctl --user status mcp-tunnel.service

# View tunnel logs
journalctl --user -u mcp-tunnel.service -n 50

# Test SSH connection manually
ssh -i ~/.ssh/id_ed25519_mcp \
  -J root@136.243.155.166:2222 \
  simonadmin@10.0.0.110 echo "OK"

# Restart tunnel
systemctl --user restart mcp-tunnel.service
```

### Health Checks Failing

```bash
# Run health check manually
bash ~/.continue/scripts/mcp_health_check.sh

# Check if services are running
systemctl --user is-active mcp-agent.service
systemctl --user is-active mcp-tunnel.service

# Test endpoints directly
curl -s --max-time 5 http://127.0.0.1:5000/mcp/sse | head -n 5
curl -s --max-time 5 http://127.0.0.1:11434/api/tags
```

### Continue Not Connecting

**Steps to resolve:**

1. Verify services running:
   ```bash
   systemctl --user status mcp-agent.service
   ```

2. Test SSE endpoint:
   ```bash
   curl -N http://localhost:5000/mcp/sse
   ```

3. Check Continue config has correct URL:
   - Should be: `http://127.0.0.1:5000/mcp/sse`

4. Reload VS Code window:
   - `Ctrl+Shift+P` → "Developer: Reload Window"

5. Check Continue Output panel:
   - View → Output → Select "Continue" from dropdown

## Advanced Configuration

### Enable User Linger (Survive Reboots)

```bash
# Enable so services start without login
loginctl enable-linger simon

# Verify
loginctl show-user simon | grep Linger
```

### SSH Connection Multiplexing

Add to `~/.ssh/config`:

```ssh-config
Host 136.243.155.166
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m
```

### Environment Variables

Add to service files via drop-ins:

```bash
# Create drop-in directory
mkdir -p ~/.config/systemd/user/mcp-agent.service.d

# Add environment
cat > ~/.config/systemd/user/mcp-agent.service.d/env.conf <<EOF
[Service]
Environment="NEURO_AGENT_TOKEN=your-secret-token"
EOF

# Reload and restart
systemctl --user daemon-reload
systemctl --user restart mcp-agent.service
```

## Available Models

| Model | Size | Best For |
|-------|------|----------|
| deepseek-coder:6.7b | 6.7B | Code generation (default) |
| llama3.1:8b | 8B | Code review, chat |
| qwen2.5:7b-instruct | 7B | Code explanation |
| mistral:7b-instruct | 7B | General purpose |
| gemma2:9b | 9B | Advanced tasks |

## Files & Directories

```
.continue/
├── MCP_SETUP.md                      # This file
├── README.md                         # Legacy setup docs
├── config.json                       # Continue config
├── agents/
│   └── agents_continue/
│       └── ollama_code_assistant.py  # MCP agent
├── mcpServers/
│   └── new-mcp-server.yaml          # MCP server definition
├── systemd/                         # User systemd units
│   ├── mcp-agent.service            # MCP agent service
│   ├── mcp-tunnel.service           # SSH tunnel
│   ├── mcp-health.service           # Health check
│   └── mcp-health.timer             # Health timer
└── scripts/
    └── mcp_health_check.sh          # Health check script
```

## Systemd Unit Details

### mcp-agent.service

```ini
[Unit]
Description=MCP Ollama Code Assistant (user service)
After=network.target

[Service]
Type=simple
WorkingDirectory=/home/simon/Learning-Management-System-Academy
ExecStart=/usr/bin/python3 .continue/agents/agents_continue/ollama_code_assistant.py
Restart=on-failure
RestartSec=5
KillMode=control-group
TimeoutStopSec=15
ExecStopPost=/bin/sh -c 'pkill -f "ollama_code_assistant.py" || true'
StandardOutput=append:~/.local/state/mcp-agent.log
StandardError=append:~/.local/state/mcp-agent.err

[Install]
WantedBy=default.target
```

### mcp-tunnel.service

```ini
[Unit]
Description=SSH tunnel for Ollama MCP (user service)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/ssh -i ~/.ssh/id_ed25519_mcp \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=3 \
  -N -L 11434:10.0.0.110:11434 \
  -J root@136.243.155.166:2222 simonadmin@10.0.0.110
Restart=always
RestartSec=10
StandardError=append:~/.local/state/mcp-tunnel.err

[Install]
WantedBy=default.target
```

## Diagnostic Commands

Get full system status:

```bash
echo "=== Services ===" && \
systemctl --user status mcp-agent.service mcp-tunnel.service --no-pager && \
echo -e "\n=== Ports ===" && \
ss -ltnp | grep -E "5000|11434" && \
echo -e "\n=== Health ===" && \
bash ~/.continue/scripts/mcp_health_check.sh && \
echo -e "\n=== Models ===" && \
curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "jq not installed"
```

## Security Notes

1. **SSH Keys**: `id_ed25519_mcp` is passphrase-less for automation
2. **Local Only**: MCP agent binds to `127.0.0.1` (not exposed)
3. **Authentication**: Optional bearer token via env variable
4. **Network**: All traffic over localhost or SSH tunnel

## Maintenance

### Regular Tasks

- **Weekly**: Review health check logs
- **Monthly**: Update Continue extension
- **Quarterly**: Rotate SSH keys

### Updates

```bash
# Pull latest changes
cd /home/simon/Learning-Management-System-Academy
git pull

# Restart services
systemctl --user daemon-reload
systemctl --user restart mcp-agent.service

# Verify
curl http://localhost:5000/health
```

## Changelog

### 2025-11-05

- Initial MCP agent setup with FastAPI
- SSH tunnel with key-based auth
- Health monitoring with systemd timer
- Fixed systemd restart issues (KillMode=control-group)
- Fixed health-check SIGPIPE issue
- Added comprehensive documentation

## Support

For issues or questions:

1. Check logs: `journalctl --user -xe`
2. Run diagnostics: See "Diagnostic Commands" section
3. Review troubleshooting guide above
4. Check Continue Output panel in VS Code

## License

Internal use - Learning Management System Academy project.
