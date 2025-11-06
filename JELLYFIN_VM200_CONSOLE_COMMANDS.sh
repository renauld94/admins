#!/bin/bash
#
# Commands to run in the Proxmox VM 200 console
# Copy/paste these directly into the terminal shown in the screenshot
#

echo "=== Jellyfin DNS Fix - VM 200 Console ==="
echo ""

# Step 1: Check current DNS
echo "Step 1: Current DNS configuration"
cat /etc/resolv.conf
echo ""

# Step 2: Test current DNS resolution
echo "Step 2: Testing DNS resolution (before fix)"
dig +short viamotionhsi.netplus.ch 2>&1 || echo "dig command not available, trying host..."
host viamotionhsi.netplus.ch 2>&1 || echo "DNS resolution failed"
echo ""

# Step 3: Check if Jellyfin is running here
echo "Step 3: Checking for Jellyfin service"
systemctl status jellyfin 2>&1 | head -n 5 || echo "Jellyfin not found as systemd service"
docker ps 2>&1 | grep jellyfin || echo "Jellyfin not found in Docker"
echo ""

# Step 4: Backup and update DNS
echo "Step 4: Updating DNS configuration"
sudo cp /etc/resolv.conf /etc/resolv.conf.backup-$(date +%s)
echo "Backup created"

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
echo "DNS updated"
echo ""

# Step 5: Test DNS after fix
echo "Step 5: Testing DNS resolution (after fix)"
dig +short viamotionhsi.netplus.ch 2>&1 || host viamotionhsi.netplus.ch 2>&1
echo ""

# Step 6: Test HTTPS connectivity
echo "Step 6: Testing HTTPS connectivity"
curl -I --connect-timeout 5 https://viamotionhsi.netplus.ch/live/eds/3sathd/browser-HLS8/3sathd.m3u8 2>&1 | head -n 3
echo ""

# Step 7: Show new DNS config
echo "Step 7: New DNS configuration"
cat /etc/resolv.conf | grep nameserver
echo ""

echo "=== Fix Complete ==="
echo ""
echo "If Jellyfin is running on this VM, restart it with:"
echo "  sudo systemctl restart jellyfin"
echo ""
echo "If Jellyfin is elsewhere, you may need to run these commands there."
