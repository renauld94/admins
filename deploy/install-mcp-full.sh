#!/usr/bin/env bash
set -euo pipefail

# Usage: ./install-mcp-full.sh
# This script copies the mcp-full.service to /etc/systemd/system, reloads systemd, enables and starts the service.
# It requires sudo privileges on the target (VM). Run this command locally using your ProxyJump:
#  ssh -o ProxyJump=root@136.243.155.166:2222 simonadmin@10.0.0.110 'bash -s' < ./deploy/install-mcp-full.sh

UNIT_PATH="/etc/systemd/system/mcp-full.service"

# copy unit
sudo tee "${UNIT_PATH}" > /dev/null <<'EOF'
[Unit]
Description=Full MCP shim (full-server.js)
After=network.target

[Service]
Type=simple
User=mcp
Group=mcp
WorkingDirectory=/opt/mcp/full
Environment=PORT=3002
ExecStart=/usr/bin/node /opt/mcp/full/full-server.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production
LimitNOFILE=65536
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now mcp-full
sudo systemctl status mcp-full --no-pager || true

echo "To follow logs: sudo journalctl -u mcp-full -f --no-pager"
