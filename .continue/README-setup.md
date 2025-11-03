# Setup notes for CONTINUE proxy + autossh + agents

This short guide captures the essential steps to provision the local environment so the MCP Server Manager and local agents can connect to a remote MCP via an SSH tunnel and a poll->SSE proxy.

Overview
- Proxy (gunicorn) listens on 127.0.0.1:11434 and serves SSE at /mcp/sse
- autossh forwards local 127.0.0.1:11435 to remote 127.0.0.1:11434 through a jump host
- poll_to_sse polls the forwarded address (http://127.0.0.1:11435/api/tags) and emits SSE on 11434

Key files
- `.continue/agents/poll_to_sse.py` — proxy/poller
- `.continue/agents/example_agent.py` — example SSE client (now supports `--once` and writes `.continue/latest_models.json`)
- `.continue/systemd/poll-to-sse.gunicorn.service` — proxy unit (user)
- `.continue/systemd/mcp-tunnel-autossh.service` — autossh unit (user)
- `.continue/systemd/example-agent.service` — example agent unit (user template)
- `.continue/systemd/example-agent.timer` — example timer (created in repo; copy to user systemd to enable periodic runs)
- `.continue/logrotate/poll-to-sse` — logrotate template

SSH key and jump host
- Ensure the identity referenced in the autossh env (IDENTITY) exists and has 600 permissions.
- Copy the public key to the jump host and onward to the target host so passwordless ProxyJump works.

Systemd user setup (copy files to your user systemd dir)

```bash
mkdir -p ~/.config/systemd/user
cp .continue/systemd/poll-to-sse.gunicorn.service ~/.config/systemd/user/
cp .continue/systemd/mcp-tunnel-autossh.service ~/.config/systemd/user/
cp .continue/systemd/example-agent.service ~/.config/systemd/user/
cp .continue/systemd/example-agent.timer ~/.config/systemd/user/  # optional
systemctl --user daemon-reload
systemctl --user enable --now poll-to-sse.gunicorn.service
systemctl --user enable --now mcp-tunnel-autossh.service
systemctl --user enable --now example-agent.timer   # if you copied the timer
```

Install logrotate (requires sudo)

```bash
sudo cp .continue/logrotate/poll-to-sse /etc/logrotate.d/poll-to-sse
sudo chown root:root /etc/logrotate.d/poll-to-sse
sudo chmod 644 /etc/logrotate.d/poll-to-sse
```

Notes and troubleshooting
- If you see "Address already in use" in autossh logs, ensure the LOCAL_PORT is different from the proxy port (LOCAL_PORT=11435, proxy=11434).
- If systemd user unit fails to start because it can't load env files, ensure the path in `EnvironmentFile=` exists (e.g. `~/.config/systemd/user/mcp-tunnel.env`).
- Use `journalctl --user -u <unit>` to inspect unit logs.

Security: don't commit private keys to the repo. Use `ssh-agent` or protected files and add the public key to the jump host.
