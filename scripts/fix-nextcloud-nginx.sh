#!/bin/bash
# Fix Nextcloud Nginx Configuration on 136.243.155.166

set -e

echo "=========================================="
echo "Nextcloud Nginx Configuration Fix"
echo "=========================================="
echo ""

echo "This script will:"
echo "1. Create nginx server block for nextcloud.simondatalab.de"
echo "2. Proxy requests to VM200 port 9020"
echo "3. Enable configuration and reload nginx"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "Creating nginx configuration..."

ssh root@136.243.155.166 'bash -s' << 'ENDSSH'
# Create nextcloud nginx config
cat > /etc/nginx/sites-available/nextcloud << '\''EOF'\''
server {
    listen 80;
    listen [::]:80;
    server_name nextcloud.simondatalab.de;
    
    # Cloudflare proxy handles SSL, this receives HTTP from Cloudflare
    location / {
        proxy_pass http://10.0.0.103:9020;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Host $host;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts for large file uploads
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
        send_timeout 600;
        
        # Client body size (for file uploads)
        client_max_body_size 10G;
    }
}
EOF

echo "✅ Created /etc/nginx/sites-available/nextcloud"

# Enable configuration
if [ ! -L /etc/nginx/sites-enabled/nextcloud ]; then
    ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/
    echo "✅ Enabled nextcloud configuration"
else
    echo "ℹ️  Configuration already enabled"
fi

# Test nginx configuration
echo ""
echo "Testing nginx configuration..."
if nginx -t; then
    echo "✅ Nginx configuration is valid"
    
    # Reload nginx
    echo ""
    echo "Reloading nginx..."
    systemctl reload nginx
    echo "✅ Nginx reloaded"
else
    echo "❌ Nginx configuration test failed"
    exit 1
fi

# Show status
echo ""
echo "=========================================="
echo "Configuration Applied"
echo "=========================================="
echo ""
echo "Nginx is now configured to proxy:"
echo "  nextcloud.simondatalab.de -> http://10.0.0.103:9020"
echo ""

# Test the configuration
echo "Testing local configuration..."
curl -s -H "Host: nextcloud.simondatalab.de" http://localhost | head -20 | grep -i nextcloud && echo "✅ Configuration working!" || echo "⚠️  Check if Nextcloud is running on VM200 port 9020"

ENDSSH

echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "1. Clear browser cache (Ctrl+Shift+Del)"
echo "2. Wait 30 seconds for Cloudflare cache to clear"
echo "3. Visit: https://nextcloud.simondatalab.de/"
echo "4. Should now see Nextcloud instead of portfolio"
echo ""
echo "If still showing portfolio:"
echo "- Wait a few minutes for Cloudflare cache"
echo "- Check if Nextcloud container is running on VM200"
echo "- Verify port 9020 is accessible internally"
echo ""
