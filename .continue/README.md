# Continue MCP Integration - Local Setup Guide

This document describes the complete setup for integrating Continue with local Ollama models via the Model Context Protocol (MCP), including the MCP agent, SSH tunnel, and health monitoring.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [MCP Agent Setup](#mcp-agent-setup) ⭐ NEW
- [Legacy: poll->SSE proxy and autossh tunnel](#legacy-pollsse-proxy-and-autossh-tunnel)

Summary
- Proxy (gunicorn + Flask) serves SSE on 127.0.0.1:11434
- Local autossh forward binds 127.0.0.1:11435 and forwards to remote 127.0.0.1:11434
- The proxy polls the forwarded address (http://127.0.0.1:11435/api/tags) and emits SSE on /mcp/sse

Port mapping (final, canonical)
- 11434 — local proxy listening for SSE (gunicorn) at http://127.0.0.1:11434
- 11435 — local autossh forward (LOCAL_PORT) that connects to the remote MCP's 11434

Why this layout
- Keep the proxy (SSE endpoint) and the polled API separate to avoid self-polling and port bind conflicts.
- The proxy listens on 11434. autossh uses 11435 locally to forward remote 11434 through the jump host.

Files of interest
- `.continue/agents/poll_to_sse.py` — poller and SSE app (env-configurable POLL_URL / POLL_INTERVAL)
- `.continue/agents/example_agent.py` — example SSE client used to validate connectivity
- `.continue/mcpServers/new-mcp-server.yaml` — MCP Server Manager entry (points to http://127.0.0.1:11434/mcp/sse)
- `.continue/systemd/poll-to-sse.gunicorn.service` — user systemd unit for the proxy
- `.continue/systemd/mcp-tunnel-autossh.service` — user systemd unit for autossh tunnel
- `~/.config/systemd/user/mcp-tunnel.env` or the drop-in file — environment used by the autossh unit

Quick reproducible steps (user systemd, per-user)

1) Ensure dependencies (user-level):

```bash
# install python deps for the proxy/agent (adjust to your venv or user pip)
pip3 install --user gunicorn requests sseclient
sudo apt install -y autossh    # or use your distro's package manager
```

2) Ensure the proxy code and systemd unit are present in the repo under `.continue` (copied to user systemd dir):

```bash
# copy service files into user systemd dir (repository -> user config)
mkdir -p ~/.config/systemd/user
cp .continue/systemd/poll-to-sse.gunicorn.service ~/.config/systemd/user/
cp .continue/systemd/mcp-tunnel-autossh.service ~/.config/systemd/user/
mkdir -p ~/.config/systemd/user/mcp-tunnel-autossh.service.d
# drop-in env.conf (optional) or create ~/.config/systemd/user/mcp-tunnel.env (see below)
cp .continue/systemd/mcp-tunnel-autossh.service.d/env.conf ~/.config/systemd/user/mcp-tunnel-autossh.service.d/ || true
```

3) Create the env file (if you prefer a single file) used by the autossh unit or adjust the drop-in:

```bash
cat > ~/.config/systemd/user/mcp-tunnel.env <<'EOF'
REMOTE_USER=simonadmin
REMOTE_HOST=10.0.0.110
PROXY_JUMP=root@136.243.155.166:2222
IDENTITY=/home/simon/.ssh/id_ed25519_lms_academy
LOCAL_PORT=11435
REMOTE_PORT=11434
EOF
chmod 600 ~/.config/systemd/user/mcp-tunnel.env
```

4) Reload user systemd and start services:

```bash
systemctl --user daemon-reload
systemctl --user enable --now poll-to-sse.gunicorn.service
systemctl --user enable --now mcp-tunnel-autossh.service
```

5) Verify services and ports:

```bash
# proxy should be listening on 11434
ss -ltnp | grep 11434
# autossh should have created an ssh child and forward 11435
ss -ltnp | grep 11435
# view unit status and logs
systemctl --user status poll-to-sse.gunicorn.service mcp-tunnel-autossh.service
journalctl --user -u poll-to-sse.gunicorn.service -f
journalctl --user -u mcp-tunnel-autossh.service -f
```

6) Quick functional test (from the same host):

```bash
# Check the remote /api/tags via the forward (polled target)
curl -sS http://127.0.0.1:11435/api/tags | jq .

# Connect to SSE endpoint (should show a model-list event emitted by proxy)
curl -N http://127.0.0.1:11434/mcp/sse

# Or run the example agent which connects to the SSE endpoint and prints events
python3 .continue/agents/example_agent.py
```

Troubleshooting notes
- If systemd user unit fails with "Failed to load environment files: No such file or directory" make sure the path referenced in `EnvironmentFile=` exists (e.g. `~/.config/systemd/user/mcp-tunnel.env`).
- Bind conflict: if autossh tries to forward the same port the proxy is listening on (11434) you'll see "Address already in use". Use LOCAL_PORT=11435 and leave proxy bound to 11434.
- Authentication: ensure the identity path (`IDENTITY`) is correct and the key has proper permissions. For ProxyJump usage ensure the jump host accepts the key.
- Stale autossh/ssh processes: if there were many restart attempts you may have old ssh processes; list them with `ps aux | grep autossh` and carefully kill the stale PIDs.

Log rotation and maintenance
- A template for a logrotate file was added under `.continue/logrotate/poll-to-sse` — copy it to `/etc/logrotate.d/poll-to-sse` as root if you want system-wide rotation.

Security and next steps
- Consider using `ssh-agent` or restricted key files and avoid storing private keys in repo or world-readable locations.
- Optionally, create a short `README-setup.md` for other team members including the identity/key provisioning and how to add the public key to the jump host.

If you want, I can now:
- run the example agent to verify end-to-end connectivity and paste the output here,
- list and optionally clean up stale autossh/ssh PIDs,
- or install the logrotate file into `/etc/logrotate.d` (requires sudo).

---
Generated: concise reproduction & verification instructions for the poll->SSE + autossh layout.
