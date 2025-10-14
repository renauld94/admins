#!/bin/bash

echo "🔧 FIXING MOODLE REDIRECTIONS ON VM 9001"
echo "========================================"
echo "Moodle: https://moodle.simondatalab.de/"
echo "VM 9001: simonadmin@10.0.0.104"
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

print_status "Starting Moodle redirection fix process..."

# 1. Check current network configuration
print_status "Step 1: Checking current network configuration..."
print_status "Network interfaces:"
ip addr show

print_status "Routing table:"
ip route show

print_status "Current iptables rules:"
iptables -L -n -v

print_status "NAT rules:"
iptables -t nat -L -n -v

# 2. Check Moodle configuration
print_status "Step 2: Checking Moodle configuration..."
MOODLE_CONFIG="/var/www/html/moodle/config.php"
if [[ -f "$MOODLE_CONFIG" ]]; then
    print_success "Moodle config found: $MOODLE_CONFIG"
    print_status "Current Moodle configuration:"
    grep -E "(wwwroot|dataroot|dbhost|dbname)" "$MOODLE_CONFIG" | head -10
else
    print_warning "Moodle config not found at $MOODLE_CONFIG"
    print_status "Searching for Moodle installation..."
    find /var/www -name "config.php" -type f 2>/dev/null | head -5
fi

# 3. Check NGINX configuration
print_status "Step 3: Checking NGINX configuration..."
NGINX_CONFIG="/etc/nginx/sites-available/default"
if [[ -f "$NGINX_CONFIG" ]]; then
    print_success "NGINX config found: $NGINX_CONFIG"
    print_status "Current NGINX configuration:"
    cat "$NGINX_CONFIG"
else
    print_warning "NGINX config not found at $NGINX_CONFIG"
    print_status "Searching for NGINX configs..."
    find /etc/nginx -name "*.conf" -type f 2>/dev/null | head -5
fi

# 4. Check for redirect rules
print_status "Step 4: Checking for redirect rules..."
print_status "Searching for redirects in NGINX configs:"
grep -r "return 301\|return 302\|rewrite.*permanent" /etc/nginx/ 2>/dev/null || echo "No redirects found in NGINX"

print_status "Searching for redirects in Apache configs:"
grep -r "Redirect\|RewriteRule.*R=" /etc/apache2/ 2>/dev/null || echo "No redirects found in Apache"

# 5. Check Moodle redirect settings
print_status "Step 5: Checking Moodle redirect settings..."
if [[ -f "$MOODLE_CONFIG" ]]; then
    MOODLE_WWWROOT=$(grep "wwwroot" "$MOODLE_CONFIG" | head -1 | cut -d"'" -f2)
    print_status "Moodle wwwroot: $MOODLE_WWWROOT"
    
    if [[ "$MOODLE_WWWROOT" == *"simondatalab.de"* ]]; then
        print_success "Moodle is correctly configured for simondatalab.de"
    else
        print_warning "Moodle wwwroot may be misconfigured: $MOODLE_WWWROOT"
    fi
fi

# 6. Fix iptables rules
print_status "Step 6: Fixing iptables rules..."

# Backup current iptables
print_status "Creating iptables backup..."
iptables-save > /var/backups/iptables-backup-$(date +%Y%m%d_%H%M%S).rules

# Clear existing rules (be careful!)
print_status "Clearing existing iptables rules..."
iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X

# Set default policies
print_status "Setting default policies..."
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Allow loopback
print_status "Allowing loopback traffic..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
print_status "Allowing established connections..."
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
print_status "Allowing SSH..."
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP and HTTPS
print_status "Allowing HTTP and HTTPS..."
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow Cloudflare IPs (basic set)
print_status "Allowing Cloudflare IPs..."
CLOUDFLARE_IPS=(
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"
)

for ip in "${CLOUDFLARE_IPS[@]}"; do
    iptables -A INPUT -s "$ip" -j ACCEPT
done

# NAT rules for port forwarding
print_status "Setting up NAT rules..."
# Forward HTTP to local web server
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.104:80
iptables -t nat -A POSTROUTING -p tcp -d 10.0.0.104 --dport 80 -j MASQUERADE

# Forward HTTPS to local web server
iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 10.0.0.104:443
iptables -t nat -A POSTROUTING -p tcp -d 10.0.0.104 --dport 443 -j MASQUERADE

# Save iptables rules
print_status "Saving iptables rules..."
iptables-save > /etc/iptables/rules.v4
if command -v netfilter-persistent &> /dev/null; then
    netfilter-persistent save
fi

print_success "iptables rules configured"

# 7. Fix NGINX configuration
print_status "Step 7: Fixing NGINX configuration..."

# Create proper NGINX config for Moodle
cat > /etc/nginx/sites-available/moodle << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name moodle.simondatalab.de;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

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
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # Moodle root
    root /var/www/html/moodle;
    index index.php index.html index.htm;
    
    # PHP handling
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Moodle specific configuration
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # Deny access to sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ /(config|install|lib|lang|pix|theme|backup|admin|cache|local|mod|blocks|question|user|calendar|cohort|course|enrol|files|grade|message|notes|report|repository|search|tag|user|webservice)/ {
        deny all;
    }
    
    # Logging
    access_log /var/log/nginx/moodle_access.log;
    error_log /var/log/nginx/moodle_error.log;
}
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/moodle /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test NGINX configuration
print_status "Testing NGINX configuration..."
nginx -t
if [ $? -eq 0 ]; then
    print_success "NGINX configuration is valid"
    systemctl reload nginx
    print_success "NGINX reloaded"
else
    print_error "NGINX configuration has errors"
    exit 1
fi

# 8. Fix Moodle configuration
print_status "Step 8: Fixing Moodle configuration..."
if [[ -f "$MOODLE_CONFIG" ]]; then
    # Backup Moodle config
    cp "$MOODLE_CONFIG" "$MOODLE_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Update Moodle wwwroot to correct URL
    sed -i "s|wwwroot.*|wwwroot = 'https://moodle.simondatalab.de/moodle';|g" "$MOODLE_CONFIG"
    
    print_success "Moodle configuration updated"
    print_status "New Moodle wwwroot:"
    grep "wwwroot" "$MOODLE_CONFIG"
else
    print_warning "Moodle config not found, skipping Moodle configuration update"
fi

# 9. Check services
print_status "Step 9: Checking services..."
print_status "NGINX status:"
systemctl status nginx --no-pager

print_status "PHP-FPM status:"
systemctl status php8.2-fpm --no-pager

print_status "MySQL status:"
systemctl status mysql --no-pager

# 10. Test connectivity
print_status "Step 10: Testing connectivity..."
print_status "Local HTTP test:"
curl -I http://localhost 2>/dev/null || print_warning "Local HTTP test failed"

print_status "Local HTTPS test:"
curl -I https://localhost 2>/dev/null || print_warning "Local HTTPS test failed"

print_status "External test:"
curl -I https://moodle.simondatalab.de/ 2>/dev/null || print_warning "External test failed"

# 11. Final status
print_status "Step 11: Final status check..."
print_status "Current iptables rules:"
iptables -L -n -v

print_status "Current NAT rules:"
iptables -t nat -L -n -v

print_status "NGINX sites enabled:"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "========================================"
print_success "Moodle redirection fix completed!"
echo "========================================"
print_status "Moodle should now be accessible at: https://moodle.simondatalab.de/"
print_status "Portfolio should be accessible at: https://www.simondatalab.de/"
print_status "Next steps:"
echo "1. Test Moodle: https://moodle.simondatalab.de/"
echo "2. Test Portfolio: https://www.simondatalab.de/"
echo "3. Purge Cloudflare cache if needed"
echo "4. Check logs: tail -f /var/log/nginx/moodle_error.log"
