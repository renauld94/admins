MCP server access via SSH tunnel (VM159)
======================================

This folder contains example configuration and helper scripts to make an MCP
server running on VM159 (ubuntuai-1000110) reachable from your local MCP
manager via an SSH ProxyJump.


Files added

- `scripts/mcp_tunnel_check.sh` - simple loop that ensures a local tunnel is
  present and checks the `/api/tags` health endpoint. Configure via
  environment variables or edit defaults in the script.

- `systemd/mcp-tunnel.service` - example systemd unit to keep an ssh tunnel up.
  Edit the `ExecStart` line to set the correct identity/private key and user.



Quick Start & Workflow
---------------------

1. **Create SSH key for tunnel (if not already):**

  ```bash
  ssh-keygen -t ed25519 -C "mcp-agent@local" -f ~/.ssh/id_ed25519_mcp
  ```

2. **Copy public key to remote VM via jump host:**

  ```bash
  ssh-copy-id -o ProxyJump=root@136.243.155.166:2222 -i ~/.ssh/id_ed25519_mcp.pub simonadmin@10.0.0.110
  ```

3. **Verify non-interactive SSH:**

  ```bash
  ssh -J root@136.243.155.166:2222 -i ~/.ssh/id_ed25519_mcp simonadmin@10.0.0.110 'echo ok'
  ```

4. **Start tunnel (systemd recommended):**

  - Use the provided monitor script and systemd user service for resilience:

    ```bash
    systemctl --user start mcp-tunnel-check.service
    systemctl --user status mcp-tunnel-check.service --no-pager -l
    ss -ltnp | grep 11434
    ```

  - Or run manually:

    ```bash
    bash scripts/mcp_tunnel_check.sh
    ```

5. **Test MCP health endpoint locally:**

  ```bash
  curl -sS http://127.0.0.1:11434/api/tags | head -20
  ```

6. **Configure MCP Server Manager:**

  - Use `.continue/mcpServers/new-mcp-server.yaml` with a single SSE entry:

    ```yaml
    mcpServers:
     - name: Remote MCP via SSH tunnel (SSE)
      type: sse
      url: http://127.0.0.1:11434/mcp/sse
    ```

  - Start MCP Server Manager and connect to the local endpoint.


Agent Workflow
--------------

1. **Start/verify tunnel** (systemd service should be running).

2. **Confirm MCP endpoint is reachable locally** (`curl` test above).

3. **Launch MCP Server Manager** using the updated YAML config.

4. **Agents** (if needed):

   - Place agent configs/scripts in `.continue/agents/` (create if missing).
   - Document agent connection details (SSE, HTTP, etc.) and tasks.
   - Example agent config:

     ```yaml
     agent:
       name: ExampleAgent
       type: python
       entry: agents/example_agent.py
       connect_url: http://127.0.0.1:11434/mcp/sse
     ```

   - Monitor agent logs and status as needed.


Optional Improvements
---------------------

- Add log rotation for debug logs (move to `~/.local/state/` and rotate daily or by size).

- Enable user linger for auto-start at boot:

  ```bash
  loginctl enable-linger $USER
  ```

- Add remote health checks (run `ss`/`curl` via SSH to confirm remote MCP is listening).


Troubleshooting
---------------

- If you see a password prompt, ensure SSH key-based auth is set up.

- If MCP Manager reports "Connection closed", check tunnel status and health endpoint.

- Use journalctl and debug logs for diagnosis:

  ```bash
  journalctl --user -u mcp-tunnel-check.service -n 100 --no-pager
  tail -n 100 /tmp/mcp_tunnel_debug.log
  ```
