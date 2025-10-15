#!/bin/bash

#####################################################################
# Diagnose simondatalab.de → moodle.simondatalab.de Redirect Conflict
# Check: Proxmox host NAT rules, iptables, nginx, caddy
# Targets: VM 9001 (10.0.0.104 - moodle) vs CT 150 (10.0.0.150 - portfolio)
#####################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "========================================================================="
echo "🔍 DIAGNOSING SIMONDATALAB.DE REDIRECT CONFLICT"
echo "========================================================================="
echo "Issue: simondatalab.de redirects to moodle.simondatalab.de"
echo "Expected: simondatalab.de → CT 150 (10.0.0.150 - portfolio)"
echo "Conflicting: moodle.simondatalab.de → VM 9001 (10.0.0.104 - moodle)"
echo ""
echo "Host: $(hostname)"
echo "Date: $(date)"
echo "User: $(whoami)"
echo ""

#####################################################################
# SECTION 1: SYSTEM OVERVIEW
#####################################################################
echo "========================================================================="
echo "📋 SECTION 1: SYSTEM OVERVIEW"
echo "========================================================================="
echo ""

print_status "Checking running services..."
echo ""
echo "Web Servers:"
systemctl list-units --type=service --state=running | grep -E "nginx|apache|caddy|httpd" || echo "  No web servers found in systemctl"
echo ""

echo "Running processes:"
ps aux | grep -E "nginx|apache|caddy|httpd" | grep -v grep || echo "  No web server processes found"
echo ""

print_status "Checking listening ports..."
echo ""
netstat -tuln | grep -E ":80 |:443 |:8006 " || echo "  No listeners on ports 80, 443, 8006"
echo ""

#####################################################################
# SECTION 2: IPTABLES NAT RULES
#####################################################################
echo "========================================================================="
echo "📋 SECTION 2: IPTABLES NAT RULES (Most Critical)"
echo "========================================================================="
echo ""

print_status "Checking iptables NAT table..."
echo ""
echo "PREROUTING chain (incoming traffic routing):"
iptables -t nat -L PREROUTING -n -v --line-numbers
echo ""

echo "POSTROUTING chain (outgoing traffic):"
iptables -t nat -L POSTROUTING -n -v --line-numbers
echo ""

echo "OUTPUT chain:"
iptables -t nat -L OUTPUT -n -v --line-numbers
echo ""

print_warning "Looking for conflicts on port 80/443..."
iptables -t nat -L -n -v | grep -E "dpt:80|dpt:443" || echo "  No rules for ports 80/443"
echo ""

#####################################################################
# SECTION 3: NGINX CONFIGURATION
#####################################################################
echo "========================================================================="
echo "📋 SECTION 3: NGINX CONFIGURATION"
echo "========================================================================="
echo ""

if command -v nginx &> /dev/null; then
    print_success "Nginx is installed"
    echo ""
    
    print_status "Nginx version and status:"
    nginx -v 2>&1
    systemctl status nginx --no-pager -l | head -20
    echo ""
    
    print_status "Nginx configuration test:"
    nginx -t 2>&1
    echo ""
    
    print_status "Nginx listening addresses:"
    nginx -T 2>/dev/null | grep -E "listen.*80|listen.*443" | head -20
    echo ""
    
    print_status "Nginx server_name directives:"
    nginx -T 2>/dev/null | grep -E "server_name" | head -30
    echo ""
    
    print_status "Checking for simondatalab.de in nginx configs:"
    grep -r "simondatalab.de" /etc/nginx/ 2>/dev/null || echo "  No matches found"
    echo ""
    
    print_status "Checking for moodle in nginx configs:"
    grep -r "moodle" /etc/nginx/ 2>/dev/null || echo "  No matches found"
    echo ""
    
    print_status "Enabled sites:"
    ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "  No sites-enabled directory"
    echo ""
    
    if [ -d "/etc/nginx/sites-enabled/" ]; then
        print_status "Content of enabled site configs:"
        for site in /etc/nginx/sites-enabled/*; do
            if [ -f "$site" ]; then
                echo "--- $site ---"
                cat "$site"
                echo ""
            fi
        done
    fi
else
    print_warning "Nginx is not installed"
fi

echo ""

#####################################################################
# SECTION 4: CADDY CONFIGURATION
#####################################################################
echo "========================================================================="
echo "📋 SECTION 4: CADDY CONFIGURATION"
echo "========================================================================="
echo ""

if command -v caddy &> /dev/null; then
    print_success "Caddy is installed"
    echo ""
    
    print_status "Caddy version:"
    caddy version 2>&1
    echo ""
    
    print_status "Caddy status:"
    systemctl status caddy --no-pager -l | head -20
    echo ""
    
    print_status "Caddy configuration locations:"
    find /etc/caddy /etc/Caddyfile* ~ -name "*Caddyfile*" 2>/dev/null || echo "  No Caddyfile found"
    echo ""
    
    print_status "Checking Caddy config files:"
    if [ -f "/etc/caddy/Caddyfile" ]; then
        echo "--- /etc/caddy/Caddyfile ---"
        cat /etc/caddy/Caddyfile
        echo ""
    fi
    
    if [ -f "/etc/Caddyfile" ]; then
        echo "--- /etc/Caddyfile ---"
        cat /etc/Caddyfile
        echo ""
    fi
    
    print_status "Checking for simondatalab.de in Caddy configs:"
    grep -r "simondatalab.de" /etc/caddy/ /etc/Caddyfile* 2>/dev/null || echo "  No matches found"
    echo ""
    
else
    print_warning "Caddy is not installed"
fi

echo ""

#####################################################################
# SECTION 5: APACHE CONFIGURATION
#####################################################################
echo "========================================================================="
echo "📋 SECTION 5: APACHE CONFIGURATION"
echo "========================================================================="
echo ""

if command -v apache2 &> /dev/null || command -v httpd &> /dev/null; then
    print_success "Apache is installed"
    echo ""
    
    APACHE_CMD="apache2"
    if command -v httpd &> /dev/null; then
        APACHE_CMD="httpd"
    fi
    
    print_status "Apache version:"
    $APACHE_CMD -v 2>&1 | head -5
    echo ""
    
    print_status "Apache status:"
    systemctl status $APACHE_CMD --no-pager -l | head -20 || service $APACHE_CMD status | head -20
    echo ""
    
    print_status "Checking for simondatalab.de in Apache configs:"
    grep -r "simondatalab.de" /etc/apache2/ /etc/httpd/ 2>/dev/null || echo "  No matches found"
    echo ""
    
else
    print_warning "Apache is not installed"
fi

echo ""

#####################################################################
# SECTION 6: PROXMOX CONTAINER/VM CHECK
#####################################################################
echo "========================================================================="
echo "📋 SECTION 6: PROXMOX VMs AND CONTAINERS"
echo "========================================================================="
echo ""

if command -v pct &> /dev/null; then
    print_success "Proxmox detected - listing containers"
    echo ""
    
    print_status "Container 150 (portfolio-web):"
    pct status 150 || echo "  Container 150 not found/running"
    pct config 150 | grep -E "net|ip" || true
    echo ""
    
    print_status "Container 104 (moodle):"
    pct status 104 || echo "  Container 104 not found"
    pct config 104 | grep -E "net|ip" || true
    echo ""
    
    print_status "All running containers:"
    pct list
    echo ""
fi

if command -v qm &> /dev/null; then
    print_status "VM 9001 (moodle-lms):"
    qm status 9001 || echo "  VM 9001 not found"
    qm config 9001 | grep -E "net|ip" || true
    echo ""
    
    print_status "All running VMs:"
    qm list
    echo ""
fi

echo ""

#####################################################################
# SECTION 7: NETWORK ROUTING
#####################################################################
echo "========================================================================="
echo "📋 SECTION 7: NETWORK ROUTING & INTERFACES"
echo "========================================================================="
echo ""

print_status "Network interfaces:"
ip addr show | grep -E "inet |vmbr|veth"
echo ""

print_status "Routing table:"
ip route show
echo ""

print_status "IP forwarding status:"
sysctl net.ipv4.ip_forward
echo ""

#####################################################################
# SECTION 8: CLOUDFLARE TUNNEL
#####################################################################
echo "========================================================================="
echo "📋 SECTION 8: CLOUDFLARE TUNNEL"
echo "========================================================================="
echo ""

print_status "Checking for cloudflared service..."
systemctl status cloudflared --no-pager -l 2>&1 | head -20 || echo "  cloudflared service not found"
echo ""

if command -v cloudflared &> /dev/null; then
    print_status "Cloudflared version:"
    cloudflared version
    echo ""
fi

print_status "Checking for cloudflared configuration:"
find /etc/cloudflared /root/.cloudflared ~ -name "config.yml" -o -name "*.json" 2>/dev/null | while read config; do
    echo "--- $config ---"
    cat "$config"
    echo ""
done

echo ""

#####################################################################
# SECTION 9: DNS RESOLUTION
#####################################################################
echo "========================================================================="
echo "📋 SECTION 9: DNS RESOLUTION TEST"
echo "========================================================================="
echo ""

print_status "Testing DNS resolution:"
echo ""
echo "simondatalab.de:"
dig +short simondatalab.de A || nslookup simondatalab.de || echo "  DNS query failed"
echo ""

echo "www.simondatalab.de:"
dig +short www.simondatalab.de A || nslookup www.simondatalab.de || echo "  DNS query failed"
echo ""

echo "moodle.simondatalab.de:"
dig +short moodle.simondatalab.de A || nslookup moodle.simondatalab.de || echo "  DNS query failed"
echo ""

#####################################################################
# SECTION 10: LOCAL HTTP TESTS
#####################################################################
echo "========================================================================="
echo "📋 SECTION 10: LOCAL HTTP TESTS"
echo "========================================================================="
echo ""

print_status "Testing localhost HTTP response:"
echo ""
curl -sI http://localhost/ 2>&1 | head -10 || echo "  No response from localhost"
echo ""

print_status "Testing with Host header - simondatalab.de:"
curl -sI -H "Host: simondatalab.de" http://localhost/ 2>&1 | head -10 || echo "  No response"
echo ""

print_status "Testing with Host header - www.simondatalab.de:"
curl -sI -H "Host: www.simondatalab.de" http://localhost/ 2>&1 | head -10 || echo "  No response"
echo ""

print_status "Testing with Host header - moodle.simondatalab.de:"
curl -sI -H "Host: moodle.simondatalab.de" http://localhost/ 2>&1 | head -10 || echo "  No response"
echo ""

#####################################################################
# SUMMARY AND RECOMMENDATIONS
#####################################################################
echo "========================================================================="
echo "📋 DIAGNOSTIC SUMMARY"
echo "========================================================================="
echo ""

print_status "Key areas to check:"
echo ""
echo "1. IPTABLES NAT RULES:"
echo "   - Look for DNAT/REDIRECT rules sending port 80 traffic"
echo "   - Check if rules point to 10.0.0.104 (moodle) instead of 10.0.0.150 (portfolio)"
echo ""
echo "2. REVERSE PROXY (Nginx/Caddy):"
echo "   - Check for default_server or catch-all configs"
echo "   - Verify server_name directives match correctly"
echo "   - Look for proxy_pass pointing to moodle"
echo ""
echo "3. CLOUDFLARE TUNNEL:"
echo "   - Verify route configuration in Cloudflare dashboard"
echo "   - Check local tunnel config points to correct IPs"
echo ""
echo "Expected routing:"
echo "  simondatalab.de     → 10.0.0.150:80 (CT 150 - portfolio)"
echo "  www.simondatalab.de → 10.0.0.150:80 (CT 150 - portfolio)"
echo "  moodle.simondatalab.de → 10.0.0.104:80 (VM 9001 - moodle)"
echo ""

echo "========================================================================="
print_success "Diagnostic complete! Review output above for conflicts."
echo "========================================================================="
echo ""
echo "Save this output to a file for analysis:"
echo "  ./diagnose_redirect_conflict.sh > /tmp/diagnostic_$(date +%Y%m%d_%H%M%S).log 2>&1"
echo ""
