#!/bin/bash
#
# Jellyfin DNS Fix via SSH to Nextcloud VM
# Connects to VM 200 (nextcloud-vm) on port 2222
#
# Usage: bash fix-jellyfin-vm200.sh
#

VM_HOST="136.243.155.166"
VM_PORT="2222"
VM_USER="Simonadmin"
VM_IP="10.0.0.103"

echo "🔧 Jellyfin Live TV Connectivity Fix - VM 200"
echo "=============================================="
echo "Connecting to: $VM_USER@$VM_HOST:$VM_PORT"
echo "Target VM: nextcloud-vm-10-0-0-103 (10.0.0.103)"
echo ""

# Test SSH connectivity
echo "📡 Testing SSH connection..."
if ! ssh -p $VM_PORT -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_HOST "echo 'SSH OK'" 2>/dev/null; then
    echo "⚠️  SSH test failed, trying with password prompt..."
    if ! ssh -p $VM_PORT $VM_USER@$VM_HOST "echo 'Connected!'" 2>/dev/null; then
        echo "❌ Cannot connect to VM"
        echo ""
        echo "Please verify:"
        echo "  - Port 2222 is accessible on $VM_HOST"
        echo "  - Username: $VM_USER"
        echo "  - VM is running (Status: running)"
        exit 1
    fi
fi
echo "✅ SSH connection successful"
echo ""

# Execute fix commands
echo "🚀 Executing DNS fix on VM..."
ssh -p $VM_PORT $VM_USER@$VM_HOST /bin/bash << 'ENDSSH'

set -e

echo "📋 Step 1: Checking if Jellyfin is running..."
if systemctl is-active jellyfin >/dev/null 2>&1; then
    echo "✅ Jellyfin service found"
    SERVICE_EXISTS=true
elif systemctl is-active jellyfin.service >/dev/null 2>&1; then
    echo "✅ Jellyfin service found"
    SERVICE_EXISTS=true
elif docker ps | grep -q jellyfin; then
    echo "✅ Jellyfin running in Docker"
    SERVICE_EXISTS=docker
else
    echo "⚠️  Jellyfin service not found on this VM"
    echo "Checking system info..."
    hostname
    ip addr show | grep "inet " | grep -v "127.0.0.1"
    SERVICE_EXISTS=false
fi
echo ""

if [ "$SERVICE_EXISTS" = "true" ] || [ "$SERVICE_EXISTS" = "docker" ]; then
    echo "📋 Step 2: Checking current DNS configuration..."
    cat /etc/resolv.conf
    echo ""

    echo "🔍 Step 3: Testing DNS resolution..."
    if dig +short viamotionhsi.netplus.ch 2>/dev/null | grep -q "[0-9]"; then
        echo "✅ DNS resolution working!"
    else
        echo "❌ DNS resolution FAILED - Applying fix..."
        
        # Backup current resolv.conf
        sudo cp /etc/resolv.conf /etc/resolv.conf.backup-$(date +%s)
        
        # Update DNS
        echo "📝 Setting DNS to Cloudflare and Google..."
        sudo bash -c 'cat > /etc/resolv.conf << EOF
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
        if dig +short viamotionhsi.netplus.ch 2>/dev/null | grep -q "[0-9]"; then
            echo "✅ DNS now working!"
            DNS_IP=$(dig +short viamotionhsi.netplus.ch)
            echo "   Resolved to: $DNS_IP"
        else
            echo "⚠️  DNS still failing"
        fi
    fi
    echo ""

    echo "🌐 Step 4: Testing HTTPS connectivity..."
    if curl -I --connect-timeout 5 https://viamotionhsi.netplus.ch/live/eds/3sathd/browser-HLS8/3sathd.m3u8 2>/dev/null | grep -q "HTTP"; then
        echo "✅ HTTPS connectivity working!"
    else
        echo "⚠️  HTTPS connectivity may need additional configuration"
    fi
    echo ""

    echo "📊 Step 5: Restarting Jellyfin..."
    if [ "$SERVICE_EXISTS" = "docker" ]; then
        echo "Restarting Jellyfin Docker container..."
        docker restart $(docker ps -q -f name=jellyfin) 2>/dev/null || sudo docker restart $(docker ps -q -f name=jellyfin)
    else
        sudo systemctl restart jellyfin
    fi
    sleep 3

    if [ "$SERVICE_EXISTS" = "docker" ]; then
        if docker ps | grep -q jellyfin; then
            echo "✅ Jellyfin Docker container restarted successfully"
        fi
    else
        if systemctl is-active jellyfin >/dev/null 2>&1; then
            echo "✅ Jellyfin restarted successfully"
        else
            echo "❌ Jellyfin may have failed to restart"
        fi
    fi
    echo ""

    echo "🎬 Step 6: Testing IPTV endpoints..."
    SOURCES=("viamotionhsi.netplus.ch" "africa24.vedge.infomaniak.com" "i.imgur.com" "i.postimg.cc")
    for source in "${SOURCES[@]}"; do
        echo -n "  Testing $source... "
        if dig +short $source 2>/dev/null | grep -q "[0-9]"; then
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
    cat /etc/resolv.conf | grep nameserver
    echo ""
    
    if [ "$SERVICE_EXISTS" = "docker" ]; then
        echo "Jellyfin Docker Status:"
        docker ps | grep jellyfin || echo "No Jellyfin container running"
    else
        echo "Jellyfin Status:"
        systemctl status jellyfin --no-pager -l 2>/dev/null | head -n 3 || echo "Unable to get status"
    fi
    echo ""
else
    echo "❌ This VM doesn't appear to be running Jellyfin"
    echo ""
    echo "This is VM 200 (nextcloud-vm-10-0-0-103)"
    echo "Jellyfin might be running:"
    echo "  - In a different VM or container"
    echo "  - On the Proxmox host directly (pct exec 200)"
    echo "  - In a Docker container with a different name"
    echo ""
    echo "System Information:"
    echo "-------------------"
    echo "Hostname: $(hostname)"
    echo "IP Addresses:"
    ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "  " $2}'
    echo ""
    echo "Running services:"
    systemctl list-units --type=service --state=running | grep -E "(jellyfin|plex|emby)" || echo "  No media server services found"
    echo ""
    echo "Docker containers:"
    docker ps 2>/dev/null | grep -E "(jellyfin|plex|emby)" || echo "  No media server containers found (or Docker not available)"
fi

ENDSSH

echo ""
echo "🎉 Fix execution complete!"
echo ""
echo "If Jellyfin was found and fixed:"
echo "  1. Clear browser cache (Ctrl+Shift+R)"
echo "  2. Reload Jellyfin web UI at https://jellyfin.simondatalab.de"
echo "  3. Try playing a Live TV channel"
echo ""
echo "If Jellyfin was NOT on this VM:"
echo "  - Jellyfin might be in a container on the Proxmox host"
echo "  - Try: ssh root@136.243.155.166 'pct exec 200 -- systemctl status jellyfin'"
