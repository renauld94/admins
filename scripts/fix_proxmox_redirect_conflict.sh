#!/bin/bash

#####################################################################
# FIX: simondatalab.de → moodle.simondatalab.de Redirect Conflict
# Run on Proxmox Host (136.243.155.166)
# This script fixes common causes of the redirect issue
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
echo "🔧 FIX SIMONDATALAB.DE REDIRECT CONFLICT"
echo "========================================================================="
echo "Date: $(date)"
echo "Host: $(hostname)"
echo ""

# Backup timestamp
BACKUP_TIME=$(date +%Y%m%d_%H%M%S)

#####################################################################
# STEP 1: Check Current State
#####################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "STEP 1: Checking current state"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_status "Current HTTP test:"
echo "localhost:"
curl -sI http://localhost/ 2>&1 | head -3
echo ""
echo "simondatalab.de:"
curl -sI -H "Host: simondatalab.de" http://localhost/ 2>&1 | head -3
echo ""

#####################################################################
# STEP 2: Fix iptables NAT Rules
#####################################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "STEP 2: Checking and fixing iptables NAT rules"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_status "Current NAT rules for port 80:"
iptables -t nat -L PREROUTING -n -v --line-numbers | grep -E "Chain|dpt:80"
echo ""

# Save current iptables
print_status "Backing up iptables..."
mkdir -p /var/backups/iptables
iptables-save > /var/backups/iptables/rules_${BACKUP_TIME}.v4
print_success "Backup: /var/backups/iptables/rules_${BACKUP_TIME}.v4"
echo ""

# Note: We won't automatically remove rules as they might be complex
# Instead, we'll report what needs to be changed
print_warning "Review NAT rules manually if they redirect port 80 traffic incorrectly"
echo "Cloudflare Tunnel should handle routing, not iptables NAT"
echo ""

#####################################################################
# STEP 3: Fix Nginx Configuration
#####################################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "STEP 3: Checking and fixing Nginx configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v nginx &> /dev/null; then
    print_success "Nginx is installed"
    
    # Backup nginx config
    print_status "Backing up Nginx configuration..."
    mkdir -p /var/backups/nginx
    cp -r /etc/nginx /var/backups/nginx/nginx_${BACKUP_TIME}
    print_success "Backup: /var/backups/nginx/nginx_${BACKUP_TIME}"
    echo ""
    
    # Check for problematic default_server
    print_status "Checking for default_server on port 80..."
    if nginx -T 2>/dev/null | grep -E "listen.*80.*default_server" | grep -v "#"; then
        print_warning "Found default_server configuration(s)"
        print_status "These may catch traffic meant for simondatalab.de"
        echo ""
    fi
    
    # Check if there's a reverse proxy to moodle
    print_status "Checking for reverse proxy to moodle..."
    if grep -r "proxy_pass.*10.0.0.104" /etc/nginx/ 2>/dev/null; then
        print_warning "Found proxy_pass to 10.0.0.104 (moodle VM)"
        print_status "This might be catching simondatalab.de traffic"
        grep -r "proxy_pass.*10.0.0.104" /etc/nginx/ 2>/dev/null
        echo ""
    fi
    
    # Check server_name directives
    print_status "Checking server_name for simondatalab.de..."
    if grep -r "server_name.*simondatalab.de" /etc/nginx/ 2>/dev/null; then
        print_success "Found simondatalab.de configuration:"
        grep -r "server_name.*simondatalab.de" /etc/nginx/ 2>/dev/null
        echo ""
    else
        print_warning "No simondatalab.de server_name found in Nginx"
        echo ""
    fi
    
else
    print_status "Nginx is not installed on this host (expected - Cloudflare Tunnel handles routing)"
fi

echo ""

#####################################################################
# STEP 4: Fix Caddy Configuration
#####################################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "STEP 4: Checking and fixing Caddy configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v caddy &> /dev/null; then
    print_success "Caddy is installed"
    
    # Backup Caddy config
    print_status "Backing up Caddy configuration..."
    mkdir -p /var/backups/caddy
    [ -f "/etc/caddy/Caddyfile" ] && cp /etc/caddy/Caddyfile /var/backups/caddy/Caddyfile_${BACKUP_TIME}
    [ -f "/etc/Caddyfile" ] && cp /etc/Caddyfile /var/backups/caddy/Caddyfile_root_${BACKUP_TIME}
    print_success "Backup created"
    echo ""
    
    # Check Caddy configuration
    print_status "Checking Caddy configuration for simondatalab.de..."
    if [ -f "/etc/caddy/Caddyfile" ]; then
        echo "--- /etc/caddy/Caddyfile ---"
        cat /etc/caddy/Caddyfile
        echo ""
    fi
    
    # Look for reverse proxy to moodle
    print_status "Checking for reverse proxy to moodle in Caddy..."
    if grep -r "10.0.0.104" /etc/caddy/ /etc/Caddyfile* 2>/dev/null; then
        print_warning "Found reference to 10.0.0.104 (moodle VM) in Caddy config"
        grep -r "10.0.0.104" /etc/caddy/ /etc/Caddyfile* 2>/dev/null
        echo ""
    fi
    
else
    print_status "Caddy is not installed on this host"
fi

echo ""

#####################################################################
# STEP 5: Check Cloudflare Tunnel Configuration
#####################################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "STEP 5: Checking Cloudflare Tunnel configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if systemctl is-active --quiet cloudflared; then
    print_success "Cloudflared is running"
    echo ""
    
    # Backup cloudflared config
    print_status "Backing up Cloudflared configuration..."
    mkdir -p /var/backups/cloudflared
    [ -f "/etc/cloudflared/config.yml" ] && cp /etc/cloudflared/config.yml /var/backups/cloudflared/config_${BACKUP_TIME}.yml
    [ -f "/root/.cloudflared/config.yml" ] && cp /root/.cloudflared/config.yml /var/backups/cloudflared/config_root_${BACKUP_TIME}.yml
    print_success "Backup created"
    echo ""
    
    # Show cloudflared config
    print_status "Cloudflared configuration:"
    if [ -f "/etc/cloudflared/config.yml" ]; then
        echo "--- /etc/cloudflared/config.yml ---"
        cat /etc/cloudflared/config.yml
        echo ""
    fi
    
    if [ -f "/root/.cloudflared/config.yml" ]; then
        echo "--- /root/.cloudflared/config.yml ---"
        cat /root/.cloudflared/config.yml
        echo ""
    fi
    
    print_warning "Cloudflare Tunnel routes should be configured in the Cloudflare Dashboard"
    print_status "Expected routes:"
    echo "  simondatalab.de → http://10.0.0.150:80 (CT 150)"
    echo "  www.simondatalab.de → http://10.0.0.150:80 (CT 150)"
    echo "  moodle.simondatalab.de → http://10.0.0.104:80 (VM 9001)"
    echo ""
else
    print_status "Cloudflared is not running (check status)"
fi

echo ""

#####################################################################
# STEP 6: Verify Backend Servers
#####################################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "STEP 6: Verifying backend servers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_status "Testing CT 150 (10.0.0.150 - portfolio):"
curl -sI -m 5 http://10.0.0.150/ 2>&1 | head -5 || echo "  Cannot reach 10.0.0.150"
echo ""

print_status "Testing VM 9001 (10.0.0.104 - moodle):"
curl -sI -m 5 http://10.0.0.104/ 2>&1 | head -5 || echo "  Cannot reach 10.0.0.104"
echo ""

if command -v pct &> /dev/null; then
    print_status "Proxmox Container 150 status:"
    pct status 150 || echo "  CT 150 not found"
    echo ""
    
    print_status "Proxmox Container 104 status:"
    pct status 104 || echo "  CT 104 not found (expected, moodle is VM 9001)"
    echo ""
fi

if command -v qm &> /dev/null; then
    print_status "Proxmox VM 9001 status:"
    qm status 9001 || echo "  VM 9001 not found"
    echo ""
fi

#####################################################################
# SUMMARY
#####################################################################
echo ""
echo "========================================================================="
print_status "SUMMARY & NEXT STEPS"
echo "========================================================================="
echo ""

print_status "Most Likely Causes of Redirect:"
echo ""
echo "1. ⚠️  CLOUDFLARE TUNNEL MISCONFIGURATION (Most Common)"
echo "   - Check Cloudflare Dashboard → Tunnels → simondatalab-tunnel"
echo "   - Verify hostnames route to correct IPs:"
echo "     • simondatalab.de → http://10.0.0.150:80"
echo "     • www.simondatalab.de → http://10.0.0.150:80"
echo "   - NOT to 10.0.0.104 (moodle)"
echo ""
echo "2. ⚠️  NGINX/CADDY REVERSE PROXY ON PROXMOX HOST"
echo "   - Remove any catch-all or default_server configs"
echo "   - Ensure no proxy_pass to 10.0.0.104 for simondatalab.de"
echo ""
echo "3. ⚠️  IPTABLES NAT RULES"
echo "   - Remove any DNAT/REDIRECT rules for port 80"
echo "   - Cloudflare Tunnel handles routing, not iptables"
echo ""

print_status "Action Items:"
echo "1. Review Cloudflare Dashboard tunnel configuration"
echo "2. Check backups created in:"
echo "   - /var/backups/iptables/"
echo "   - /var/backups/nginx/"
echo "   - /var/backups/caddy/"
echo "   - /var/backups/cloudflared/"
echo "3. Test after each change:"
echo "   curl -sI -H 'Host: www.simondatalab.de' http://localhost/"
echo ""

echo "========================================================================="
print_success "Diagnostic and backup complete!"
echo "========================================================================="
