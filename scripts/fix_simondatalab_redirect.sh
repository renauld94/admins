#!/bin/bash

#####################################################################
# Fix simondatalab.de and www.simondatalab.de Redirect Issue
# Target: CT 150 (10.0.0.150) - portfolio-web-1000150
# Issue: www.simondatalab.de not redirecting properly
#####################################################################

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=========================================="
echo "🔧 simondatalab.de Redirect Fix Script"
echo "=========================================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo ""

# Step 1: Check which web server is running
print_status "Step 1: Detecting web server..."
if systemctl is-active --quiet nginx; then
    WEB_SERVER="nginx"
    print_success "Detected: Nginx"
elif systemctl is-active --quiet apache2; then
    WEB_SERVER="apache2"
    print_success "Detected: Apache2"
else
    print_error "No web server detected (neither nginx nor apache2 is running)"
    print_status "Checking installed packages..."
    if command -v nginx &> /dev/null; then
        WEB_SERVER="nginx"
        print_warning "Nginx is installed but not running. Starting..."
        systemctl start nginx
    elif command -v apache2 &> /dev/null; then
        WEB_SERVER="apache2"
        print_warning "Apache2 is installed but not running. Starting..."
        systemctl start apache2
    else
        print_error "No web server installed. Please install nginx or apache2 first."
        exit 1
    fi
fi

# Step 2: Check iptables NAT rules
print_status "Step 2: Checking iptables NAT rules..."
echo "Current NAT rules:"
iptables -t nat -L -n -v | grep -E "DNAT|REDIRECT|80|443" || echo "No NAT rules found for ports 80/443"

# Step 3: Check if port 80 is listening
print_status "Step 3: Checking port 80 listener..."
if netstat -tuln | grep -q ":80 "; then
    print_success "Port 80 is listening"
    netstat -tuln | grep ":80 "
else
    print_error "Port 80 is NOT listening!"
fi

# Step 4: Fix based on web server type
if [ "$WEB_SERVER" = "nginx" ]; then
    print_status "Step 4: Fixing Nginx configuration..."
    
    # Backup existing config
    BACKUP_DIR="/var/backups/nginx-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r /etc/nginx/sites-available /etc/nginx/sites-enabled "$BACKUP_DIR/" 2>/dev/null || true
    print_success "Backup created: $BACKUP_DIR"
    
    # Check if configuration exists
    if [ -f "/etc/nginx/sites-available/simondatalab.de" ]; then
        print_status "Found existing simondatalab.de configuration"
        cat /etc/nginx/sites-available/simondatalab.de
    else
        print_warning "No existing configuration found. Creating new nginx config..."
        
        # Create nginx configuration for simondatalab.de
        cat > /etc/nginx/sites-available/simondatalab.de << 'EOF'
# Main website configuration for simondatalab.de
server {
    listen 80;
    listen [::]:80;
    
    server_name simondatalab.de www.simondatalab.de;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    # Access and error logs
    access_log /var/log/nginx/simondatalab.de.access.log;
    error_log /var/log/nginx/simondatalab.de.error.log;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Main location
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Static file caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
}
EOF
        print_success "Created nginx configuration"
        
        # Enable the site
        ln -sf /etc/nginx/sites-available/simondatalab.de /etc/nginx/sites-enabled/simondatalab.de
        print_success "Enabled simondatalab.de site"
    fi
    
    # Test nginx configuration
    print_status "Testing nginx configuration..."
    if nginx -t; then
        print_success "Nginx configuration is valid"
        
        # Reload nginx
        print_status "Reloading nginx..."
        systemctl reload nginx
        print_success "Nginx reloaded"
    else
        print_error "Nginx configuration test failed!"
        print_status "Restoring backup..."
        cp -r "$BACKUP_DIR/sites-available/"* /etc/nginx/sites-available/ 2>/dev/null || true
        cp -r "$BACKUP_DIR/sites-enabled/"* /etc/nginx/sites-enabled/ 2>/dev/null || true
        systemctl reload nginx
        exit 1
    fi
    
elif [ "$WEB_SERVER" = "apache2" ]; then
    print_status "Step 4: Fixing Apache2 configuration..."
    
    # Backup existing config
    BACKUP_DIR="/var/backups/apache2-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r /etc/apache2/sites-available /etc/apache2/sites-enabled "$BACKUP_DIR/" 2>/dev/null || true
    print_success "Backup created: $BACKUP_DIR"
    
    # Check if configuration exists
    if [ -f "/etc/apache2/sites-available/simondatalab.de.conf" ]; then
        print_status "Found existing simondatalab.de.conf configuration"
        cat /etc/apache2/sites-available/simondatalab.de.conf
    else
        print_warning "No existing configuration found. Creating new Apache config..."
        
        # Create Apache configuration (use the one from your workspace)
        cat > /etc/apache2/sites-available/simondatalab.de.conf << 'EOF'
<VirtualHost *:80>
    ServerName simondatalab.de
    ServerAlias www.simondatalab.de
    
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Security headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options SAMEORIGIN
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    
    ErrorLog  /var/log/apache2/simondatalab.de.error.log
    CustomLog /var/log/apache2/simondatalab.de.access.log combined
</VirtualHost>
EOF
        print_success "Created Apache configuration"
        
        # Enable the site
        a2ensite simondatalab.de.conf
        print_success "Enabled simondatalab.de site"
    fi
    
    # Test Apache configuration
    print_status "Testing Apache configuration..."
    if apachectl configtest; then
        print_success "Apache configuration is valid"
        
        # Reload Apache
        print_status "Reloading Apache..."
        systemctl reload apache2
        print_success "Apache reloaded"
    else
        print_error "Apache configuration test failed!"
        exit 1
    fi
fi

# Step 5: Check document root
print_status "Step 5: Checking document root..."
if [ -d "/var/www/html" ]; then
    print_success "Document root exists: /var/www/html"
    print_status "Contents:"
    ls -lah /var/www/html/ | head -20
    
    # Check for index file
    if ls /var/www/html/index.* 1> /dev/null 2>&1; then
        print_success "Index file found"
    else
        print_warning "No index file found in /var/www/html/"
        print_status "Creating placeholder index.html..."
        cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simon Data Lab - Portfolio</title>
</head>
<body>
    <h1>Welcome to Simon Data Lab</h1>
    <p>Portfolio website is being configured...</p>
</body>
</html>
EOF
        print_success "Created placeholder index.html"
    fi
else
    print_error "Document root /var/www/html does not exist!"
    print_status "Creating document root..."
    mkdir -p /var/www/html
    chown -R www-data:www-data /var/www/html
    print_success "Created /var/www/html"
fi

# Step 6: Test web server response
print_status "Step 6: Testing web server response..."
echo ""
print_status "Testing localhost..."
curl -sI http://localhost/ | head -10 || print_error "Localhost test failed"

echo ""
print_status "Testing simondatalab.de..."
curl -sI -H "Host: simondatalab.de" http://localhost/ | head -10 || print_error "simondatalab.de test failed"

echo ""
print_status "Testing www.simondatalab.de..."
curl -sI -H "Host: www.simondatalab.de" http://localhost/ | head -10 || print_error "www.simondatalab.de test failed"

# Step 7: Summary
echo ""
echo "=========================================="
print_success "Fix script completed!"
echo "=========================================="
print_status "Summary:"
echo "- Web server: $WEB_SERVER"
echo "- Status: $(systemctl is-active $WEB_SERVER)"
echo "- Port 80: $(netstat -tuln | grep ":80 " | wc -l) listener(s)"
echo "- Document root: /var/www/html"
echo ""
print_status "Next steps:"
echo "1. Verify website works: curl -H 'Host: www.simondatalab.de' http://10.0.0.150/"
echo "2. Check Cloudflare Tunnel is routing traffic properly"
echo "3. Purge Cloudflare cache if needed"
echo "4. Test from external browser: https://www.simondatalab.de/"
echo ""
print_status "Logs to check:"
if [ "$WEB_SERVER" = "nginx" ]; then
    echo "- tail -f /var/log/nginx/simondatalab.de.access.log"
    echo "- tail -f /var/log/nginx/simondatalab.de.error.log"
else
    echo "- tail -f /var/log/apache2/simondatalab.de.access.log"
    echo "- tail -f /var/log/apache2/simondatalab.de.error.log"
fi

