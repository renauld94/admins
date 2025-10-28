#!/bin/bash
set -euo pipefail

# This script is intended to be uploaded to the remote VM to fix nginx/mcp setup.
# It will:
#  - place a correct /etc/nginx/sites-available/mcp.conf
#  - backup and disable default site
#  - create a self-signed cert under /etc/nginx/ssl/mcp if missing
#  - test and restart nginx
#  - open UFW 443
#  - create /opt/mcp/full scaffold (minimal express server listening on 3001)
#  - create and enable mcp-full.service
# Run this as a user with sudo privileges (the uploader will run it with sudo).

TMP_CONF=/tmp/mcp.conf

# Expect the mcp.conf to already be uploaded to $TMP_CONF. If not present, exit.
if [ ! -f "$TMP_CONF" ]; then
  echo "ERROR: $TMP_CONF missing. Upload corrected mcp.conf to the VM before running this script." >&2
  exit 2
fi

set -x

# Backup existing files
if [ -f /etc/nginx/sites-available/mcp.conf ]; then
  cp -a /etc/nginx/sites-available/mcp.conf /etc/nginx/sites-available/mcp.conf.bak.$(date -u +%Y%m%dT%H%M%SZ)
fi
if [ -L /etc/nginx/sites-enabled/default ] || [ -f /etc/nginx/sites-enabled/default ]; then
  mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.disabled || true
fi

# Place mcp.conf
mv "$TMP_CONF" /etc/nginx/sites-available/mcp.conf
ln -sf /etc/nginx/sites-available/mcp.conf /etc/nginx/sites-enabled/mcp.conf

# Ensure cert dir exists
mkdir -p /etc/nginx/ssl/mcp
if [ ! -f /etc/nginx/ssl/mcp/mcp.key ] || [ ! -f /etc/nginx/ssl/mcp/mcp.crt ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/mcp/mcp.key -out /etc/nginx/ssl/mcp/mcp.crt \
    -subj "/CN=mcp.local/O=learning-academy/C=US"
  chmod 600 /etc/nginx/ssl/mcp/mcp.key
fi

# Test nginx config and restart
nginx -t
systemctl restart nginx

# Ensure UFW allows 443
if command -v ufw >/dev/null 2>&1; then
  ufw allow 443/tcp || true
fi

# Create minimal full MCP scaffold under /opt/mcp/full (idempotent)
mkdir -p /opt/mcp/full
chown -R mcp:mcp /opt/mcp/full || true

# Create package.json if missing
if [ ! -f /opt/mcp/full/package.json ]; then
  sudo -u mcp bash -lc "cd /opt/mcp/full && npm init -y >/dev/null"
fi
# Install minimal runtime dependencies (non-fatal)
sudo -u mcp bash -lc "cd /opt/mcp/full && npm install express || true"

cat > /opt/mcp/full/full-server.js <<'JS'
const express = require('express')
const app = express()
const port = process.env.PORT || 3001

app.get('/health', (req, res) => res.json({ok: true, server: 'full-mcp-scaffold'}))
app.get('/', (req, res) => res.send('Full MCP scaffold running on '+port))

app.listen(port, () => console.log('Full MCP scaffold listening', port))
JS

chown mcp:mcp /opt/mcp/full/full-server.js || true
chmod 644 /opt/mcp/full/full-server.js || true

# Create systemd unit
cat > /etc/systemd/system/mcp-full.service <<'SERVICE'
[Unit]
Description=Full MCP Scaffold Server
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
systemctl enable --now mcp-full || true

# Print statuses and listening ports
systemctl status nginx --no-pager || true
systemctl status mcp --no-pager || true
systemctl status mcp-full --no-pager || true
ss -tunlp | egrep '(:3000|:3001|:443)' || true

echo "DONE"
