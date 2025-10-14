#!/bin/bash

echo "🔧 FIXING PORTFOLIO REDIRECT ISSUE"
echo "=================================="
echo "Website: https://www.simondatalab.de/"
echo "Issue: Redirecting to Moodle instead of portfolio"
echo "Date: $(date)"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root or with sudo"
    exit 1
fi

print_status "Starting portfolio redirect fix process..."

# 1. Backup current NGINX configuration
print_status "Step 1: Creating backup of NGINX configuration..."
BACKUP_DIR="/var/backups/nginx-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r /etc/nginx/ "$BACKUP_DIR/"
print_success "NGINX configuration backed up to: $BACKUP_DIR"

# 2. Check current NGINX configuration
print_status "Step 2: Analyzing current NGINX configuration..."
print_status "Current sites-available/default:"
cat /etc/nginx/sites-available/default

print_status "Searching for redirect rules..."
grep -r "moodle.simondatalab.de" /etc/nginx/ || print_warning "No Moodle redirects found in NGINX config"

# 3. Check if portfolio files exist
print_status "Step 3: Checking portfolio files..."
WEB_ROOT="/var/www/html"

if [[ -d "$WEB_ROOT" ]]; then
    print_success "Web root directory exists: $WEB_ROOT"
    print_status "Current files in web root:"
    ls -la "$WEB_ROOT"
    
    # Check for portfolio files
    if [[ -f "$WEB_ROOT/index.html" ]]; then
        print_success "index.html found"
        if grep -q "Simon Renauld" "$WEB_ROOT/index.html"; then
            print_success "Portfolio content detected in index.html"
        else
            print_warning "Portfolio content not found in index.html"
            print_status "First 10 lines of index.html:"
            head -10 "$WEB_ROOT/index.html"
        fi
    else
        print_error "index.html not found in web root"
    fi
else
    print_error "Web root directory not found: $WEB_ROOT"
fi

# 4. Create proper NGINX configuration for portfolio
print_status "Step 4: Creating proper NGINX configuration for portfolio..."

# Create the correct NGINX configuration
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name simondatalab.de www.simondatalab.de;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name simondatalab.de www.simondatalab.de;
    
    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;
    
    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Root directory
    root /var/www/html;
    index index.html index.htm;
    
    # Main location block
    location / {
        try_files $uri $uri/ =404;
        
        # Cache static assets
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header Vary "Accept-Encoding";
        }
        
        # Cache HTML files for shorter period
        location ~* \.html$ {
            expires 1h;
            add_header Cache-Control "public";
        }
    }
    
    # Handle PDF files
    location ~* \.pdf$ {
        expires 1y;
        add_header Cache-Control "public";
        add_header Content-Disposition "inline";
    }
    
    # Security: Deny access to hidden files
    location ~ /\. {
        deny all;
    }
    
    # Security: Deny access to backup files
    location ~ ~$ {
        deny all;
    }
    
    # Logging
    access_log /var/log/nginx/simondatalab_access.log;
    error_log /var/log/nginx/simondatalab_error.log;
}

# Moodle server (separate subdomain)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name moodle.simondatalab.de;
    
    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;
    
    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Moodle root (adjust path as needed)
    root /var/www/moodle;
    index index.php index.html index.htm;
    
    # PHP handling
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
    
    # Moodle specific configuration
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # Logging
    access_log /var/log/nginx/moodle_access.log;
    error_log /var/log/nginx/moodle_error.log;
}
EOF

print_success "NGINX configuration created for portfolio"

# 5. Test NGINX configuration
print_status "Step 5: Testing NGINX configuration..."
nginx -t
if [ $? -eq 0 ]; then
    print_success "NGINX configuration is valid"
else
    print_error "NGINX configuration has errors"
    print_status "Restoring backup..."
    cp -r "$BACKUP_DIR/nginx/"* /etc/nginx/
    exit 1
fi

# 6. Ensure portfolio files are in place
print_status "Step 6: Ensuring portfolio files are in place..."

# Check if we have the portfolio files from our local directory
if [[ -f "/home/simon/Learning-Management-System-Academy/index.simondatalab.html" ]]; then
    print_status "Found portfolio file locally, copying to web root..."
    cp "/home/simon/Learning-Management-System-Academy/index.simondatalab.html" "$WEB_ROOT/index.html"
    print_success "Portfolio file copied to web root"
else
    print_warning "Portfolio file not found locally, checking if it exists in web root..."
    if [[ -f "$WEB_ROOT/index.html" ]]; then
        print_success "Portfolio file already exists in web root"
    else
        print_error "No portfolio file found. Creating placeholder..."
        cat > "$WEB_ROOT/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simon Renauld - Portfolio</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        h1 { color: #333; }
        .status { background: #f0f0f0; padding: 20px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Simon Renauld - Portfolio</h1>
        <div class="status">
            <h2>Portfolio Update in Progress</h2>
            <p>Your portfolio is being updated. Please check back soon.</p>
            <p>Date: $(date)</p>
        </div>
    </div>
</body>
</html>
EOF
        print_success "Placeholder portfolio created"
    fi
fi

# 7. Set correct permissions
print_status "Step 7: Setting correct permissions..."
chown -R www-data:www-data "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"
print_success "Permissions set correctly"

# 8. Reload NGINX
print_status "Step 8: Reloading NGINX..."
systemctl reload nginx
if [ $? -eq 0 ]; then
    print_success "NGINX reloaded successfully"
else
    print_error "Failed to reload NGINX"
    systemctl restart nginx
    if [ $? -eq 0 ]; then
        print_success "NGINX restarted successfully"
    else
        print_error "Failed to restart NGINX"
        exit 1
    fi
fi

# 9. Test the fix
print_status "Step 9: Testing the fix..."
sleep 2

# Test local access
print_status "Testing local access..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    print_success "Local access working"
else
    print_warning "Local access may have issues"
fi

# Test external access
print_status "Testing external access..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://www.simondatalab.de/)
if [ "$HTTP_CODE" = "200" ]; then
    print_success "External access working (HTTP $HTTP_CODE)"
else
    print_warning "External access returned HTTP $HTTP_CODE"
fi

# Check if redirect is gone
print_status "Checking if redirect is resolved..."
REDIRECT_CHECK=$(curl -s -I https://www.simondatalab.de/ | grep -i "location:" || echo "No redirect found")
if [[ "$REDIRECT_CHECK" == "No redirect found" ]]; then
    print_success "Redirect issue resolved!"
else
    print_warning "Redirect still present: $REDIRECT_CHECK"
fi

# 10. Check content
print_status "Step 10: Checking portfolio content..."
CONTENT_CHECK=$(curl -s https://www.simondatalab.de/ | head -5)
if echo "$CONTENT_CHECK" | grep -q "Simon Renauld\|Portfolio"; then
    print_success "Portfolio content is being served"
else
    print_warning "Portfolio content may not be correct"
    print_status "First 5 lines of content:"
    echo "$CONTENT_CHECK"
fi

# 11. Purge Cloudflare cache
print_status "Step 11: Instructions for Cloudflare cache purge..."
print_warning "IMPORTANT: You need to purge Cloudflare cache manually:"
echo "1. Go to: https://dash.cloudflare.com/"
echo "2. Select your domain: simondatalab.de"
echo "3. Go to Caching → Configuration"
echo "4. Click 'Purge Everything'"
echo ""
print_status "Or use the API:"
echo "curl -X POST \"https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache\" \\"
echo "     -H \"Authorization: Bearer YOUR_API_TOKEN\" \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     --data '{\"purge_everything\":true}'"

echo ""
echo "=================================="
print_success "Portfolio redirect fix completed!"
echo "=================================="
print_status "Next steps:"
echo "1. Purge Cloudflare cache (see instructions above)"
echo "2. Test website: https://www.simondatalab.de/"
echo "3. Verify portfolio content is displayed"
echo "4. Check that Moodle is accessible at: https://moodle.simondatalab.de/"
echo ""
print_status "Backup location: $BACKUP_DIR"
print_status "If issues occur, restore with: cp -r $BACKUP_DIR/nginx/* /etc/nginx/"
