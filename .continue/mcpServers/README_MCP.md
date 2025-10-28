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

Quick start (on your local machine)
1. Create an SSH key for the tunnel (if not already):

   ssh-keygen -t ed25519 -C "mcp-agent@local" -f ~/.ssh/id_ed25519_mcp

2. Copy the public key to the remote VM via the jump host:

   ssh-copy-id -o ProxyJump=root@136.243.155.166:2222 -i ~/.ssh/id_ed25519_mcp.pub simonadmin@10.0.0.110

3. Verify non-interactive SSH:

   ssh -J root@136.243.155.166:2222 -i ~/.ssh/id_ed25519_mcp simonadmin@10.0.0.110 'echo ok'

4a. Start a background tunnel manually (temporary):

   ssh -f -N -o ProxyJump=root@136.243.155.166:2222 -i ~/.ssh/id_ed25519_mcp -L 11434:127.0.0.1:11434 simonadmin@10.0.0.110

   Then test locally:
   curl -sS http://127.0.0.1:11434/api/tags | head -20

4b. Run the monitor script (keeps attempting to create tunnel and checks health):

   bash scripts/mcp_tunnel_check.sh

5. Optional: install systemd service (make sure ExecStart identity path is correct):

   sudo cp systemd/mcp-tunnel.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now mcp-tunnel.service

Config notes
- The manager can now connect to `http://127.0.0.1:11434` (or append the SSE
  path if your MCP server exposes an SSE endpoint, e.g. `/mcp/sse`).
- If your MCP manager expects to spawn a remote process rather than using a
  tunnel, provide the exact remote start command and ensure key-based SSH is
  configured; the project already contains a `new-mcp-server.yaml` ssh-wrapper
  example you can adapt.
