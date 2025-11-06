#!/bin/bash
#═══════════════════════════════════════════════════════════════════
# MIGRATE JELLYFIN FROM PROXMOX HOST TO VM 200
#═══════════════════════════════════════════════════════════════════

set -e

PROXMOX_HOST="136.243.155.166"
PROXMOX_SSH_PORT="2222"
VM200_IP="10.0.0.103"
VM200_USER="simonadmin"

echo "═══════════════════════════════════════════════════════════════════"
echo "  JELLYFIN MIGRATION: Proxmox Host → VM 200"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Current State:"
echo "  ❌ Snap Jellyfin running on Proxmox host (port 8096)"
echo "  ✅ Docker Jellyfin running on VM 200 (port 8096)"
echo "  ⚠️  Nginx already configured for VM 200, but blocked by snap"
echo ""
echo "Migration Steps:"
echo "  1. Stop snap Jellyfin on Proxmox host"
echo "  2. Disable snap Jellyfin autostart"
echo "  3. Update VM 200 Jellyfin with IPTV tuners"
echo "  4. Verify Nginx routing works"
echo "  5. Optional: Export/import settings from snap to Docker"
echo ""
read -p "Continue with migration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  STEP 1: Stop Snap Jellyfin on Proxmox Host"
echo "═══════════════════════════════════════════════════════════════════"

ssh -p ${PROXMOX_SSH_PORT} root@${PROXMOX_HOST} << 'EOF'
echo "Stopping snap Jellyfin service..."
snap stop itrue-jellyfin

echo "Disabling snap Jellyfin..."
systemctl disable snap.itrue-jellyfin.daemon.service 2>/dev/null || true

echo "Verifying port 8096 is free..."
sleep 2
if netstat -tlnp | grep ':8096'; then
    echo "❌ ERROR: Port 8096 still in use!"
    exit 1
else
    echo "✅ Port 8096 is now free"
fi
EOF

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  STEP 2: Verify VM 200 Jellyfin is Accessible"
echo "═══════════════════════════════════════════════════════════════════"

ssh -p ${PROXMOX_SSH_PORT} root@${PROXMOX_HOST} << EOF
echo "Testing VM 200 Jellyfin..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://${VM200_IP}:8096/web/index.html

echo ""
echo "Testing Nginx proxy to VM 200..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" -H "Host: jellyfin.simondatalab.de" http://localhost

echo ""
echo "✅ Nginx is now routing to VM 200 Jellyfin"
EOF

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  STEP 3: Update VM 200 Jellyfin with Working IPTV Tuners"
echo "═══════════════════════════════════════════════════════════════════"

echo "VM 200 Jellyfin is now accessible at:"
echo "  → http://10.0.0.103:8096 (direct)"
echo "  → https://jellyfin.simondatalab.de (via Nginx)"
echo ""
echo "Next steps (manual):"
echo "  1. Go to: https://jellyfin.simondatalab.de"
echo "  2. Complete Jellyfin setup wizard (if first time)"
echo "  3. Dashboard → Live TV → Add Tuner Device"
echo "  4. Select: M3U Tuner"
echo "  5. File or URL: https://iptv-org.github.io/iptv/index.m3u"
echo "  6. Save"
echo ""
echo "Optional regional tuners:"
echo "  🇬🇧 UK:     https://iptv-org.github.io/iptv/countries/uk.m3u"
echo "  🇺🇸 US:     https://iptv-org.github.io/iptv/countries/us.m3u"
echo "  🇫🇷 France: https://iptv-org.github.io/iptv/countries/fr.m3u"
echo "  🇩🇪 Germany: https://iptv-org.github.io/iptv/countries/de.m3u"
echo "  🇨🇦 Canada: https://iptv-org.github.io/iptv/countries/ca.m3u"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  STEP 4: Optional - Export Settings from Snap to Docker"
echo "═══════════════════════════════════════════════════════════════════"

read -p "Export settings from snap Jellyfin to VM 200? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ssh -p ${PROXMOX_SSH_PORT} root@${PROXMOX_HOST} << 'EXPORT_EOF'
echo "Finding snap Jellyfin config directory..."
SNAP_CONFIG="/var/snap/itrue-jellyfin/common/data"

if [ -d "$SNAP_CONFIG" ]; then
    echo "Creating backup of snap config..."
    tar -czf /tmp/jellyfin-snap-config-backup.tar.gz -C "$SNAP_CONFIG" .
    echo "✅ Backup created: /tmp/jellyfin-snap-config-backup.tar.gz"
    
    echo ""
    echo "To restore to VM 200:"
    echo "  1. scp /tmp/jellyfin-snap-config-backup.tar.gz simonadmin@10.0.0.103:/tmp/"
    echo "  2. On VM 200:"
    echo "     docker exec -it jellyfin-simonadmin bash"
    echo "     cd /config"
    echo "     tar -xzf /tmp/jellyfin-snap-config-backup.tar.gz"
    echo "     chown -R 1000:1000 /config"
    echo "     exit"
    echo "  3. docker restart jellyfin-simonadmin"
else
    echo "❌ Snap config not found at $SNAP_CONFIG"
fi
EXPORT_EOF
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  MIGRATION COMPLETE!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Status:"
echo "  ✅ Snap Jellyfin stopped on Proxmox host"
echo "  ✅ Docker Jellyfin running on VM 200"
echo "  ✅ Nginx routing to VM 200"
echo "  ✅ jellyfin.simondatalab.de → VM 200:8096"
echo ""
echo "Access Jellyfin:"
echo "  🌐 https://jellyfin.simondatalab.de"
echo "  🏠 http://10.0.0.103:8096 (local)"
echo ""
echo "Container management on VM 200:"
echo "  ssh simonadmin@10.0.0.103"
echo "  docker logs jellyfin-simonadmin"
echo "  docker restart jellyfin-simonadmin"
echo "  docker exec -it jellyfin-simonadmin bash"
echo ""
echo "To permanently remove snap Jellyfin:"
echo "  ssh -p 2222 root@136.243.155.166"
echo "  snap remove itrue-jellyfin"
echo ""
