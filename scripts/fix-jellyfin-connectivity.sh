#!/bin/bash
#
# Jellyfin Live TV Connectivity Fix
# Fixes DNS resolution and network issues in Jellyfin container
# Run this script ON the Proxmox host (136.243.155.166) or inside CT 200
#
# Usage: 
#   On Proxmox host: bash fix-jellyfin-connectivity.sh
#   Inside container: bash fix-jellyfin-connectivity.sh --inside-container
#

set -e

CONTAINER_ID=200
INSIDE_CONTAINER=false

if [[ "$1" == "--inside-container" ]]; then
    INSIDE_CONTAINER=true
fi

echo "🔧 Jellyfin Live TV Connectivity Fix"
echo "===================================="
echo ""

# Function to run commands inside or outside container
run_cmd() {
    if [[ "$INSIDE_CONTAINER" == "true" ]]; then
        eval "$1"
    else
        pct exec $CONTAINER_ID -- bash -c "$1"
    fi
}

# 1. Check current DNS configuration
echo "📋 Step 1: Checking current DNS configuration..."
if [[ "$INSIDE_CONTAINER" == "true" ]]; then
    cat /etc/resolv.conf
else
    pct exec $CONTAINER_ID -- cat /etc/resolv.conf
fi
echo ""

# 2. Test DNS resolution
echo "🔍 Step 2: Testing DNS resolution..."
echo "Testing viamotionhsi.netplus.ch..."
if run_cmd "dig +short viamotionhsi.netplus.ch" 2>/dev/null; then
    echo "✅ DNS resolution working!"
else
    echo "❌ DNS resolution FAILED - Applying fix..."
    
    # Backup current resolv.conf
    run_cmd "cp /etc/resolv.conf /etc/resolv.conf.backup-$(date +%s)"
    
    # Update DNS to use Cloudflare and Google
    echo "📝 Setting DNS to Cloudflare (1.1.1.1) and Google (8.8.8.8)..."
    run_cmd "cat > /etc/resolv.conf << 'EOF'
# Cloudflare DNS (primary)
nameserver 1.1.1.1
nameserver 1.0.0.1

# Google DNS (backup)
nameserver 8.8.8.8
nameserver 8.8.4.4

# Options
options timeout:2 attempts:3 rotate
EOF"
    
    echo "✅ DNS configuration updated"
    
    # Test again
    echo "🔍 Testing DNS again..."
    if run_cmd "dig +short viamotionhsi.netplus.ch"; then
        echo "✅ DNS now working!"
    else
        echo "⚠️  DNS still failing - may need firewall/network fix"
    fi
fi
echo ""

# 3. Test HTTPS connectivity
echo "🌐 Step 3: Testing HTTPS connectivity to IPTV sources..."
echo "Testing viamotionhsi.netplus.ch..."
if run_cmd "curl -I --connect-timeout 5 https://viamotionhsi.netplus.ch/live/eds/3sathd/browser-HLS8/3sathd.m3u8" 2>/dev/null | grep -q "HTTP"; then
    echo "✅ HTTPS connectivity working!"
else
    echo "❌ HTTPS connectivity FAILED"
    echo "⚠️  This may require firewall configuration on the host"
    echo ""
    echo "Possible causes:"
    echo "  - Outbound port 443 blocked"
    echo "  - NAT/routing misconfiguration"
    echo "  - Cloudflare tunnel interfering"
    echo ""
fi
echo ""

# 4. Check Jellyfin service status
echo "📊 Step 4: Checking Jellyfin service..."
if run_cmd "systemctl is-active jellyfin" | grep -q "active"; then
    echo "✅ Jellyfin is running"
    
    # Restart Jellyfin to apply DNS changes
    echo "🔄 Restarting Jellyfin to apply changes..."
    run_cmd "systemctl restart jellyfin"
    sleep 3
    
    if run_cmd "systemctl is-active jellyfin" | grep -q "active"; then
        echo "✅ Jellyfin restarted successfully"
    else
        echo "❌ Jellyfin failed to restart"
        run_cmd "systemctl status jellyfin"
    fi
else
    echo "❌ Jellyfin is not running"
    echo "Starting Jellyfin..."
    run_cmd "systemctl start jellyfin"
fi
echo ""

# 5. Install network diagnostic tools if missing
echo "🛠️  Step 5: Ensuring diagnostic tools are installed..."
if ! run_cmd "command -v dig" &>/dev/null; then
    echo "Installing dnsutils..."
    run_cmd "apt-get update -qq && apt-get install -y dnsutils"
fi

if ! run_cmd "command -v curl" &>/dev/null; then
    echo "Installing curl..."
    run_cmd "apt-get update -qq && apt-get install -y curl"
fi
echo "✅ Diagnostic tools ready"
echo ""

# 6. Test key IPTV endpoints
echo "🎬 Step 6: Testing IPTV endpoints..."
IPTV_SOURCES=(
    "viamotionhsi.netplus.ch"
    "africa24.vedge.infomaniak.com"
    "i.imgur.com"
    "i.postimg.cc"
    "upload.wikimedia.org"
)

FAILED=0
for source in "${IPTV_SOURCES[@]}"; do
    echo -n "Testing $source... "
    if run_cmd "dig +short $source" | grep -q "[0-9]"; then
        echo "✅"
    else
        echo "❌"
        ((FAILED++))
    fi
done
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ All IPTV sources reachable!"
else
    echo "⚠️  $FAILED/$((${#IPTV_SOURCES[@]})) sources failed DNS lookup"
fi
echo ""

# 7. Check for port conflicts
echo "🔌 Step 7: Checking for port conflicts..."
if run_cmd "netstat -tlnp 2>/dev/null | grep ':8096'" | grep -q "jellyfin"; then
    echo "✅ Jellyfin listening on port 8096"
else
    echo "⚠️  Jellyfin not listening on port 8096"
fi
echo ""

# 8. Summary and next steps
echo "═══════════════════════════════════"
echo "📋 Fix Summary"
echo "═══════════════════════════════════"
echo ""
echo "DNS Configuration:"
run_cmd "cat /etc/resolv.conf | grep nameserver"
echo ""
echo "Jellyfin Status:"
run_cmd "systemctl status jellyfin --no-pager -l | head -n 5"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ All checks passed!"
    echo ""
    echo "Next steps:"
    echo "1. Clear browser cache (Ctrl+Shift+R)"
    echo "2. Reload Jellyfin web UI"
    echo "3. Try playing a Live TV channel"
    echo ""
    echo "If issues persist:"
    echo "- Check Jellyfin logs: journalctl -u jellyfin -f"
    echo "- Verify firewall: iptables -L -n"
    echo "- Check routes: ip route show"
else
    echo "⚠️  Some issues detected"
    echo ""
    echo "Manual steps required:"
    echo "1. Check host firewall rules"
    echo "2. Verify NAT configuration"
    echo "3. Test outbound HTTPS: curl -I https://1.1.1.1"
    echo "4. Review Jellyfin logs for errors"
fi
echo ""
echo "🔧 Fix script complete!"
