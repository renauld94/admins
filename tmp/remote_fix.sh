#!/bin/bash
set -euo pipefail

# Backup default site if present
if [ -e /etc/nginx/sites-enabled/default ]; then
  mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.disabled || true
fi

# Move uploaded mcp.conf into place
if [ -f /tmp/mcp.conf ]; then
  mv /tmp/mcp.conf /etc/nginx/sites-available/mcp.conf
fi
ln -sf /etc/nginx/sites-available/mcp.conf /etc/nginx/sites-enabled/mcp.conf

# Test and (re)start nginx
nginx -t
systemctl restart nginx || journalctl -u nginx -n 200 --no-pager

# Allow HTTPS
ufw allow 443/tcp || true

# Scaffold full MCP server
mkdir -p /opt/mcp/full
chown -R mcp:mcp /opt/mcp/full || true
cd /opt/mcp/full
if [ ! -f package.json ]; then
  sudo -u mcp npm init -y
fi
# Try to install packages; allow failure (may not be published)
sudo -u mcp npm install @modelcontextprotocol/server-core @modelcontextprotocol/server-filesystem express jsonwebtoken || true

cat > /opt/mcp/full/full-server.js <<'JS'
const { ServerCore } = require('@modelcontextprotocol/server-core')
const fsProvider = require('@modelcontextprotocol/server-filesystem')

;(async () => {
  const core = new ServerCore({ port: 3001 })
  core.registerProvider('filesystem', fsProvider)
  await core.start()
  console.log('Full MCP server started on 3001')
})().catch(err => { console.error(err); process.exit(1) })
JS

chown mcp:mcp /opt/mcp/full/full-server.js || true
chmod 644 /opt/mcp/full/full-server.js || true

# Create systemd unit
cat > /etc/systemd/system/mcp-full.service <<'SERVICE'
[Unit]
Description=Full MCP Server (scaffold)
After=network.target

[Service]
Type=simple
User=mcp
WorkingDirectory=/opt/mcp/full
ExecStart=/usr/bin/node /opt/mcp/full/full-server.js
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl start mcp-full || true

# Output statuses and config for verification
systemctl status nginx --no-pager || true
systemctl status mcp --no-pager || true
systemctl status mcp-full --no-pager || true
sed -n '1,200p' /etc/nginx/sites-available/mcp.conf || true

exit 0
