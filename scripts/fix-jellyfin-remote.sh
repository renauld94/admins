#!/bin/bash
#
# Remote Jellyfin Live TV Connectivity Fix
# Executes fix on Proxmox host via SSH
#
# Usage: bash fix-jellyfin-remote.sh [proxmox-host]
#

PROXMOX_HOST="${1:-136.243.155.166}"
CONTAINER_ID=200

echo "🔧 Jellyfin Remote Live TV Connectivity Fix"
echo "============================================="
echo "Target: $PROXMOX_HOST (Container $CONTAINER_ID)"
echo ""

# Test SSH connectivity
echo "📡 Testing SSH connection to $PROXMOX_HOST..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes root@$PROXMOX_HOST "echo 'SSH OK'" 2>/dev/null; then
    echo "❌ Cannot connect to $PROXMOX_HOST via SSH"
    echo ""
    echo "Possible solutions:"
    echo "1. Check if SSH port 22 is open"
    echo "2. Verify firewall rules"
    echo "3. Try with proxy jump: ssh -J user@jumphost root@$PROXMOX_HOST"
    echo "4. Run fix manually on the Proxmox host console"
    exit 1
fi
echo "✅ SSH connection successful"
echo ""

# Execute fix on remote host
echo "🚀 Executing fix on remote host..."
ssh root@$PROXMOX_HOST /bin/bash << 'ENDSSH'

set -e

CONTAINER_ID=200

echo "📋 Step 1: Checking current DNS configuration..."
pct exec $CONTAINER_ID -- cat /etc/resolv.conf
echo ""

echo "🔍 Step 2: Testing DNS resolution..."
if pct exec $CONTAINER_ID -- dig +short viamotionhsi.netplus.ch 2>/dev/null | grep -q "[0-9]"; then
    echo "✅ DNS resolution working!"
else
    echo "❌ DNS resolution FAILED - Applying fix..."
    
    # Backup current resolv.conf
    pct exec $CONTAINER_ID -- cp /etc/resolv.conf /etc/resolv.conf.backup-$(date +%s)
    
    # Update DNS
    echo "📝 Setting DNS to Cloudflare and Google..."
    pct exec $CONTAINER_ID -- bash -c 'cat > /etc/resolv.conf << EOF
# Cloudflare DNS (primary)
nameserver 1.1.1.1
nameserver 1.0.0.1

# Google DNS (backup)
nameserver 8.8.8.8
nameserver 8.8.4.4

# Options
options timeout:2 attempts:3 rotate
EOF'
    
    echo "✅ DNS configuration updated"
    
    # Test again
    echo "🔍 Testing DNS again..."
    if pct exec $CONTAINER_ID -- dig +short viamotionhsi.netplus.ch 2>/dev/null | grep -q "[0-9]"; then
        echo "✅ DNS now working!"
    else
        echo "⚠️  DNS still failing"
    fi
fi
echo ""

echo "🌐 Step 3: Testing HTTPS connectivity..."
if pct exec $CONTAINER_ID -- curl -I --connect-timeout 5 https://viamotionhsi.netplus.ch/live/eds/3sathd/browser-HLS8/3sathd.m3u8 2>/dev/null | grep -q "HTTP"; then
    echo "✅ HTTPS connectivity working!"
else
    echo "⚠️  HTTPS connectivity may need firewall configuration"
fi
echo ""

echo "📊 Step 4: Restarting Jellyfin..."
pct exec $CONTAINER_ID -- systemctl restart jellyfin
sleep 3

if pct exec $CONTAINER_ID -- systemctl is-active jellyfin 2>/dev/null | grep -q "active"; then
    echo "✅ Jellyfin restarted successfully"
else
    echo "❌ Jellyfin failed to restart"
fi
echo ""

echo "🎬 Step 5: Testing IPTV endpoints..."
for source in viamotionhsi.netplus.ch africa24.vedge.infomaniak.com i.imgur.com; do
    echo -n "  Testing $source... "
    if pct exec $CONTAINER_ID -- dig +short $source 2>/dev/null | grep -q "[0-9]"; then
        echo "✅"
    else
        echo "❌"
    fi
done
echo ""

echo "═══════════════════════════════════"
echo "📋 Fix Complete!"
echo "═══════════════════════════════════"
echo ""
echo "Current DNS Configuration:"
pct exec $CONTAINER_ID -- cat /etc/resolv.conf | grep nameserver
echo ""
echo "Jellyfin Status:"
pct exec $CONTAINER_ID -- systemctl status jellyfin --no-pager -l | head -n 3
echo ""
echo "✅ Fix applied successfully!"
echo ""
echo "Next steps:"
echo "1. Clear browser cache (Ctrl+Shift+R)"
echo "2. Reload Jellyfin web UI"
echo "3. Try playing a Live TV channel"

ENDSSH

echo ""
echo "🎉 Remote fix execution complete!"
