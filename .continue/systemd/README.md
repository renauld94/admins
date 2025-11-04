MCP systemd user services
=========================

This folder contains user-level systemd units used to run the MCP agent and
maintain an SSH tunnel to your VM, plus a periodic health-check timer.

Files
- `mcp-tunnel.service` : keeps an SSH tunnel alive to the remote Ollama VM
- `mcp-agent.service`  : runs the local MCP FastAPI agent (ollama_code_assistant.py)
- `mcp-health.service` : runs the health-check script once
- `mcp-health.timer`   : schedules the health-check every 5 minutes

Enable services (once)
-----------------------

Run the following to enable and start the user services and timer:

```bash
systemctl --user daemon-reload
systemctl --user enable --now mcp-tunnel.service
systemctl --user enable --now mcp-agent.service
systemctl --user enable --now mcp-health.timer
```

Run on boot without interactive login
------------------------------------

If you want these to run even when you're not logged in, enable linger:

```bash
sudo loginctl enable-linger $(whoami)
```

SSH key recommendation
----------------------

For the `mcp-tunnel.service` to run non-interactively, configure an SSH key
pair and copy the public key to the remote host (via the jump host). If you
created a key named `~/.ssh/id_ed25519_mcp`, update the `ExecStart` in
`mcp-tunnel.service` to include `-i /home/simon/.ssh/id_ed25519_mcp`.
