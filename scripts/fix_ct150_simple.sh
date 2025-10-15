#!/bin/bash

#####################################################################
# Simple Fix Script for CT 150 - Copy/Paste Ready
# Run this directly on CT 150 via Proxmox console or SSH session
#####################################################################

echo "=========================================="
echo "🔧 simondatalab.de Fix Script for CT 150"
echo "=========================================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""

# Detect web server
if systemctl is-active --quiet nginx; then
    WEB_SERVER="nginx"
    echo "✓ Detected: Nginx"
elif systemctl is-active --quiet apache2; then
    WEB_SERVER="apache2"
    echo "✓ Detected: Apache2"
elif command -v nginx &> /dev/null; then
    WEB_SERVER="nginx"
    echo "⚠ Nginx installed but not running. Starting..."
    systemctl start nginx
elif command -v apache2 &> /dev/null; then
    WEB_SERVER="apache2"
    echo "⚠ Apache2 installed but not running. Starting..."
    systemctl start apache2
else
    echo "❌ No web server found!"
    exit 1
fi

echo ""
echo "━━━ Checking Current Status ━━━"
echo "Web Server: $WEB_SERVER"
echo "Status: $(systemctl is-active $WEB_SERVER)"
echo ""

# Check port 80
echo "Port 80 status:"
netstat -tuln | grep ":80 " || echo "⚠ Port 80 not listening!"
echo ""

# For Nginx
if [ "$WEB_SERVER" = "nginx" ]; then
    echo "━━━ Configuring Nginx ━━━"
    
    # Backup
    mkdir -p /var/backups/nginx-$(date +%Y%m%d_%H%M%S)
    cp -r /etc/nginx/sites-* /var/backups/nginx-$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
    
    # Create config
    cat > /etc/nginx/sites-available/simondatalab.de << 'NGINX_EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name simondatalab.de www.simondatalab.de _;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    access_log /var/log/nginx/simondatalab.de.access.log;
    error_log /var/log/nginx/simondatalab.de.error.log;
    
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
        expires 1y;
        add_header Cache-Control "public";
    }
}
NGINX_EOF
    
    ln -sf /etc/nginx/sites-available/simondatalab.de /etc/nginx/sites-enabled/simondatalab.de
    
    # Remove default if it conflicts
    rm -f /etc/nginx/sites-enabled/default
    
    echo "✓ Nginx config created"
    
    # Test and reload
    if nginx -t 2>&1; then
        echo "✓ Config valid"
        systemctl reload nginx
        echo "✓ Nginx reloaded"
    else
        echo "❌ Config test failed!"
        exit 1
    fi
fi

# For Apache
if [ "$WEB_SERVER" = "apache2" ]; then
    echo "━━━ Configuring Apache2 ━━━"
    
    # Backup
    mkdir -p /var/backups/apache2-$(date +%Y%m%d_%H%M%S)
    cp -r /etc/apache2/sites-* /var/backups/apache2-$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
    
    # Create config
    cat > /etc/apache2/sites-available/simondatalab.de.conf << 'APACHE_EOF'
<VirtualHost *:80>
    ServerName simondatalab.de
    ServerAlias www.simondatalab.de
    
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options SAMEORIGIN
    
    ErrorLog  /var/log/apache2/simondatalab.de.error.log
    CustomLog /var/log/apache2/simondatalab.de.access.log combined
</VirtualHost>
APACHE_EOF
    
    a2ensite simondatalab.de.conf
    a2dissite 000-default.conf 2>/dev/null || true
    
    echo "✓ Apache config created"
    
    # Test and reload
    if apachectl configtest 2>&1; then
        echo "✓ Config valid"
        systemctl reload apache2
        echo "✓ Apache reloaded"
    else
        echo "❌ Config test failed!"
        exit 1
    fi
fi

# Ensure document root exists
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# Create index if missing
if ! ls /var/www/html/index.* 1> /dev/null 2>&1; then
    echo "Creating placeholder index.html..."
    cat > /var/www/html/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simon Data Lab</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #2c3e50; }
        .status { background: #e8f5e9; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>🚀 Simon Data Lab</h1>
    <div class="status">
        <strong>Status:</strong> Portfolio website is configured and running!
    </div>
    <p>Date: $(date)</p>
    <p>Server: $(hostname)</p>
</body>
</html>
HTML_EOF
fi

echo ""
echo "━━━ Testing ━━━"
echo ""
echo "Test 1 - Localhost:"
curl -sI http://localhost/ | head -5
echo ""
echo "Test 2 - simondatalab.de:"
curl -sI -H "Host: simondatalab.de" http://localhost/ | head -5
echo ""
echo "Test 3 - www.simondatalab.de:"
curl -sI -H "Host: www.simondatalab.de" http://localhost/ | head -5
echo ""

echo "=========================================="
echo "✅ Fix Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Test from browser: https://www.simondatalab.de/"
echo "2. Check Cloudflare cache and purge if needed"
echo "3. Verify Cloudflare Tunnel is routing correctly"
echo ""
echo "Logs:"
if [ "$WEB_SERVER" = "nginx" ]; then
    echo "  tail -f /var/log/nginx/simondatalab.de.access.log"
    echo "  tail -f /var/log/nginx/simondatalab.de.error.log"
else
    echo "  tail -f /var/log/apache2/simondatalab.de.access.log"
    echo "  tail -f /var/log/apache2/simondatalab.de.error.log"
fi
