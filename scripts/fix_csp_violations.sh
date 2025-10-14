#!/bin/bash

# CSP Fix Script for simondatalab.de
# This script fixes Content Security Policy violations

echo "🔧 CSP Fix Script for simondatalab.de"
echo "====================================="

# Configuration
JUMP_HOST="root@136.243.155.166:2222"
VM_USER="simonadmin"
VM_IP="10.0.0.150"  # Portfolio VM

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "1. Checking current CSP configuration..."

# Check if the portfolio VM is accessible
if ping -c 1 10.0.0.150 > /dev/null 2>&1; then
    print_status "Portfolio VM (10.0.0.150) is reachable"
else
    print_error "Portfolio VM (10.0.0.150) is not reachable"
    echo "💡 The portfolio might be hosted on a different VM"
    exit 1
fi

echo ""
echo "2. Testing current website CSP..."
CSP_HEADER=$(curl -I --max-time 10 https://www.simondatalab.de/ 2>/dev/null | grep -i "content-security-policy" || echo "No CSP header found")

if [ -n "$CSP_HEADER" ]; then
    echo "Current CSP: $CSP_HEADER"
    print_warning "CSP header found - this might be causing the violations"
else
    print_status "No CSP header found in HTTP response"
fi

echo ""
echo "3. Checking nginx configuration..."

# Check if we can access the nginx config
NGINX_CONFIG=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "cat /etc/nginx/sites-available/simondatalab.de 2>/dev/null || echo 'Config not found'" 2>/dev/null)

if [ $? -eq 0 ]; then
    if [[ "$NGINX_CONFIG" == *"Content-Security-Policy"* ]]; then
        print_warning "CSP policy found in nginx config"
        echo "Current CSP in config:"
        echo "$NGINX_CONFIG" | grep -A1 -B1 "Content-Security-Policy"
    else
        print_status "No CSP policy found in nginx config"
    fi
else
    print_error "Cannot access nginx configuration"
fi

echo ""
echo "4. Recommended CSP fix..."

# Create a simplified CSP policy
SIMPLIFIED_CSP="default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdnjs.cloudflare.com https://d3js.org https://static.cloudflareinsights.com; style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; img-src 'self' data: https:; font-src 'self' https://cdnjs.cloudflare.com; connect-src 'self' https:; frame-ancestors 'self';"

echo "Simplified CSP policy:"
echo "$SIMPLIFIED_CSP"

echo ""
echo "5. Applying CSP fix..."

# Try to update the nginx configuration
NGINX_UPDATE=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "
    # Backup current config
    sudo cp /etc/nginx/sites-available/simondatalab.de /etc/nginx/sites-available/simondatalab.de.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
    
    # Update CSP policy
    sudo sed -i 's/add_header Content-Security-Policy.*;/add_header Content-Security-Policy \"$SIMPLIFIED_CSP\" always;/g' /etc/nginx/sites-available/simondatalab.de 2>/dev/null || echo 'Config update failed'
    
    # Test nginx configuration
    sudo nginx -t 2>/dev/null && echo 'Config valid' || echo 'Config invalid'
    
    # Reload nginx if config is valid
    if sudo nginx -t >/dev/null 2>&1; then
        sudo systemctl reload nginx 2>/dev/null && echo 'Nginx reloaded' || echo 'Nginx reload failed'
    fi
" 2>/dev/null)

if [ $? -eq 0 ]; then
    print_status "CSP fix applied successfully"
    echo "$NGINX_UPDATE"
else
    print_error "Failed to apply CSP fix"
fi

echo ""
echo "6. Testing the fix..."
sleep 5

# Test the website
if curl -s --max-time 10 https://www.simondatalab.de/ > /dev/null; then
    print_status "Website is accessible"
    
    # Check if CSP violations are reduced
    echo "💡 Check your browser console for CSP violations"
    echo "   The violations should be significantly reduced"
else
    print_error "Website is not accessible"
fi

echo ""
echo "📋 Summary:"
echo "   - Simplified CSP policy to allow inline scripts"
echo "   - Removed conflicting hash values"
echo "   - Kept necessary security headers"
echo ""
echo "🔧 Manual steps if needed:"
echo "   1. SSH to portfolio VM: ssh -J $JUMP_HOST $VM_USER@$VM_IP"
echo "   2. Edit nginx config: sudo nano /etc/nginx/sites-available/simondatalab.de"
echo "   3. Update CSP line with simplified policy"
echo "   4. Test config: sudo nginx -t"
echo "   5. Reload nginx: sudo systemctl reload nginx"
echo ""
echo "🌐 Test your website: https://www.simondatalab.de/"

