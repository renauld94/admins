#!/bin/bash

echo "🌐 CT 150 PORTFOLIO WEBSITE UPDATE SCRIPT"
echo "========================================="
echo "Website: https://www.simondatalab.de/"
echo "Server: portfolio-web-1000150 (10.0.0.150)"
echo "Proxmox Node: pve"
echo "Date: $(date)"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root or with sudo"
    exit 1
fi

print_status "Starting CT 150 portfolio website update process..."

# 1. System Update
print_status "Step 1: Updating system packages..."
apt update && apt upgrade -y
if [ $? -eq 0 ]; then
    print_success "System packages updated successfully"
else
    print_error "Failed to update system packages"
    exit 1
fi

# 2. Check NGINX Status
print_status "Step 2: Checking NGINX status..."
systemctl status nginx --no-pager
if systemctl is-active --quiet nginx; then
    print_success "NGINX is running"
else
    print_warning "NGINX is not running, attempting to start..."
    systemctl start nginx
    if [ $? -eq 0 ]; then
        print_success "NGINX started successfully"
    else
        print_error "Failed to start NGINX"
    fi
fi

# 3. Check NGINX Configuration
print_status "Step 3: Checking NGINX configuration..."
nginx -t
if [ $? -eq 0 ]; then
    print_success "NGINX configuration is valid"
    print_status "Reloading NGINX configuration..."
    systemctl reload nginx
    print_success "NGINX configuration reloaded"
else
    print_error "NGINX configuration has errors"
    print_status "Current NGINX configuration:"
    cat /etc/nginx/sites-available/default
fi

# 4. Check Portfolio Website Files
print_status "Step 4: Checking portfolio website files..."
WEB_ROOT="/var/www/html"

if [[ -d "$WEB_ROOT" ]]; then
    print_success "Web root directory exists: $WEB_ROOT"
    print_status "Portfolio files:"
    ls -la "$WEB_ROOT"
    
    # Check for index.html
    if [[ -f "$WEB_ROOT/index.html" ]]; then
        print_success "index.html found"
        print_status "File size: $(du -h $WEB_ROOT/index.html | cut -f1)"
        print_status "Last modified: $(stat -c %y $WEB_ROOT/index.html)"
        
        # Check if it's the portfolio website
        if grep -q "Simon Renauld" "$WEB_ROOT/index.html"; then
            print_success "Portfolio website content detected"
        else
            print_warning "Portfolio content may not be present"
        fi
    else
        print_error "index.html not found in web root"
    fi
    
    # Check for CSS files
    if [[ -f "$WEB_ROOT/styles.css" ]] || [[ -f "$WEB_ROOT/professional-portfolio.css" ]]; then
        print_success "CSS files found"
    else
        print_warning "CSS files not found"
    fi
    
    # Check for JS files
    if [[ -f "$WEB_ROOT/app.js" ]] || [[ -f "$WEB_ROOT/hero-performance.js" ]]; then
        print_success "JavaScript files found"
    else
        print_warning "JavaScript files not found"
    fi
    
    # Check for assets directory
    if [[ -d "$WEB_ROOT/assets" ]]; then
        print_success "Assets directory found"
        print_status "Assets:"
        ls -la "$WEB_ROOT/assets/"
    else
        print_warning "Assets directory not found"
    fi
else
    print_error "Web root directory not found: $WEB_ROOT"
fi

# 5. Check SSL Certificates
print_status "Step 5: Checking SSL certificates..."
if [ -d "/etc/letsencrypt/live/simondatalab.de" ]; then
    print_success "SSL certificates found for simondatalab.de"
    print_status "Certificate expiry:"
    openssl x509 -in /etc/letsencrypt/live/simondatalab.de/fullchain.pem -noout -dates
else
    print_warning "No SSL certificates found for simondatalab.de"
fi

# 6. Check Cloudflare Integration
print_status "Step 6: Checking Cloudflare integration..."
print_status "Current NGINX real IP configuration:"
grep -A 10 "real_ip" /etc/nginx/nginx.conf || echo "No real_ip configuration found"

# Update Cloudflare IP Ranges
print_status "Updating Cloudflare IP ranges..."
CLOUDFLARE_IPS="/etc/nginx/cloudflare-ips.conf"
if [ ! -f "$CLOUDFLARE_IPS" ]; then
    print_status "Creating Cloudflare IP ranges file..."
    touch "$CLOUDFLARE_IPS"
fi

# Download latest Cloudflare IP ranges
print_status "Downloading latest Cloudflare IP ranges..."
curl -s https://www.cloudflare.com/ips-v4 > /tmp/cloudflare-ips-v4.txt
curl -s https://www.cloudflare.com/ips-v6 > /tmp/cloudflare-ips-v6.txt

if [ -s /tmp/cloudflare-ips-v4.txt ] && [ -s /tmp/cloudflare-ips-v6.txt ]; then
    cat /tmp/cloudflare-ips-v4.txt /tmp/cloudflare-ips-v6.txt > "$CLOUDFLARE_IPS"
    print_success "Cloudflare IP ranges updated"
    
    # Update NGINX configuration to use Cloudflare IPs
    print_status "Updating NGINX configuration for Cloudflare..."
    cat > /etc/nginx/conf.d/cloudflare.conf << 'EOF'
# Cloudflare IP ranges
include /etc/nginx/cloudflare-ips.conf;

# Set real IP from Cloudflare
set_real_ip_from 0.0.0.0/0;
real_ip_header CF-Connecting-IP;
EOF
    
    # Test and reload NGINX
    nginx -t && systemctl reload nginx
    print_success "NGINX Cloudflare configuration updated"
else
    print_warning "Failed to download Cloudflare IP ranges"
fi

# 7. Check Website Response
print_status "Step 7: Checking website response..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    print_success "Website is responding on localhost"
else
    print_warning "Website may not be responding on localhost"
fi

# Check external access
print_status "Checking external website access..."
if curl -s -o /dev/null -w "%{http_code}" https://www.simondatalab.de/ | grep -q "200"; then
    print_success "Website is accessible externally"
else
    print_warning "Website may not be accessible externally"
fi

# 8. Check Port Rules and Firewall
print_status "Step 8: Checking firewall and port rules..."
print_status "Active iptables rules:"
iptables -L -n -v

print_status "Listening ports:"
netstat -tlnp | grep -E ':(80|443|22)'

# 9. Check NAT Rules
print_status "Step 9: Checking NAT rules..."
iptables -t nat -L -n -v

# 10. Performance Check
print_status "Step 10: Checking system performance..."
print_status "Memory usage:"
free -h
print_status "CPU load:"
uptime
print_status "Active connections:"
ss -tuln | wc -l

# 11. Log Analysis
print_status "Step 11: Analyzing recent logs..."
print_status "Recent NGINX access logs (last 10 lines):"
tail -10 /var/log/nginx/access.log 2>/dev/null || print_warning "No NGINX access logs found"

print_status "Recent NGINX error logs (last 10 lines):"
tail -10 /var/log/nginx/error.log 2>/dev/null || print_warning "No NGINX error logs found"

# 12. Check for Common Issues
print_status "Step 12: Checking for common portfolio issues..."

# Check if website shows "Professional Learning Platform" instead of portfolio
if [[ -f "$WEB_ROOT/index.html" ]]; then
    if grep -q "Professional Learning Platform" "$WEB_ROOT/index.html"; then
        print_warning "Website shows Moodle content instead of portfolio"
        print_status "This suggests the wrong index.html is being served"
    elif grep -q "Simon Renauld" "$WEB_ROOT/index.html"; then
        print_success "Portfolio content is correctly displayed"
    else
        print_warning "Cannot determine website content type"
    fi
fi

# Check for missing assets
print_status "Checking for missing portfolio assets..."
MISSING_ASSETS=0

if [[ ! -f "$WEB_ROOT/professional-portfolio.css" ]]; then
    print_warning "professional-portfolio.css not found"
    MISSING_ASSETS=$((MISSING_ASSETS + 1))
fi

if [[ ! -f "$WEB_ROOT/legacy-theme-overrides.css" ]]; then
    print_warning "legacy-theme-overrides.css not found"
    MISSING_ASSETS=$((MISSING_ASSETS + 1))
fi

if [[ ! -f "$WEB_ROOT/Simon_Renauld_Data_Engineering_Analytics_Lead.pdf" ]]; then
    print_warning "Resume PDF not found"
    MISSING_ASSETS=$((MISSING_ASSETS + 1))
fi

if [ $MISSING_ASSETS -eq 0 ]; then
    print_success "All portfolio assets are present"
else
    print_warning "Found $MISSING_ASSETS missing assets"
fi

# 13. Final Status
print_status "Step 13: Final system status..."
print_status "Services status:"
systemctl is-active nginx 2>/dev/null || true

print_status "Port status:"
ss -tuln | grep -E ':(80|443|22)'

echo ""
echo "========================================="
print_success "CT 150 Portfolio Update Complete!"
echo "========================================="
print_status "Portfolio website: https://www.simondatalab.de/"
print_status "Next steps:"
echo "1. Purge Cloudflare cache manually or via API"
echo "2. Test website: https://www.simondatalab.de/"
echo "3. Monitor logs for any issues"
echo "4. Check SSL certificate renewal schedule"
echo ""
print_status "Cloudflare Cache Purge Commands:"
echo "curl -X POST \"https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache\" \\"
echo "     -H \"Authorization: Bearer YOUR_API_TOKEN\" \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     --data '{\"purge_everything\":true}'"
echo ""
print_status "Manual Cloudflare cache purge:"
echo "Visit: https://dash.cloudflare.com/ → Caching → Configuration → Purge Everything"
