#!/usr/bin/env bash
set -euo pipefail

# This script updates the nginx proxy in-place to point /staging-mcp/ to 127.0.0.1:3002
# It writes to /etc/nginx/sites-available/mcp.conf (overwrites the proxy lines); run with sudo

sudo tee /etc/nginx/sites-available/mcp.conf > /dev/null <<'EOF'
server {
    listen 80;
    listen 443 ssl;
    server_name openwebui.simondatalab.de;

    ssl_certificate /etc/nginx/ssl/mcp/mcp.crt;
    ssl_certificate_key /etc/nginx/ssl/mcp/mcp.key;

    location /staging-mcp/ {
        proxy_pass http://127.0.0.1:3002/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

sudo nginx -t
sudo systemctl reload nginx

echo "nginx reloaded; /staging-mcp/ now proxies to 127.0.0.1:3002"
