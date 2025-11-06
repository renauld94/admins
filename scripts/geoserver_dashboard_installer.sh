#!/bin/bash
# GeoServer Epic Dashboard Installer
# Target: VM106 (vm106-geoneural1000111) on Proxmox node 'pve'
# User: simonadmin@<IP_TO_DETERMINE>

set -e

PROXY_JUMP="root@136.243.155.166:2222"
TARGET_VM="simonadmin@10.0.0.111"  # Update if needed

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         EPIC GEOSERVER DASHBOARD INSTALLER                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Verify connectivity
echo "📡 Testing connection to GeoServer VM..."
if ! ssh -J "$PROXY_JUMP" "$TARGET_VM" 'echo "Connection successful"' 2>/dev/null; then
    echo "❌ Cannot reach $TARGET_VM via $PROXY_JUMP"
    echo ""
    echo "Please verify the correct IP address by checking Proxmox:"
    echo "  1. SSH to Proxmox: ssh -p 2222 root@136.243.155.166"
    echo "  2. Run: qm list | grep 106"
    echo "  3. Or: pct list | grep 106"
    echo "  4. Get IP: qm guest cmd 106 network-get-interfaces"
    echo ""
    echo "Then update TARGET_VM in this script and re-run."
    exit 1
fi

echo "✅ Connected to GeoServer VM"
echo ""

# Step 2: Gather system information
echo "🔍 Gathering system information..."
ssh -J "$PROXY_JUMP" "$TARGET_VM" 'bash -s' << 'ENDSSH'
    echo "=== OS Information ==="
    cat /etc/os-release | head -5
    echo ""
    
    echo "=== Java Version ==="
    if command -v java &> /dev/null; then
        java -version 2>&1 | head -3
    else
        echo "Java not installed"
    fi
    echo ""
    
    echo "=== System Resources ==="
    echo "Disk:"
    df -h / | tail -1
    echo "Memory:"
    free -h | grep Mem
    echo ""
    
    echo "=== GeoServer Status ==="
    if systemctl is-active --quiet geoserver 2>/dev/null; then
        echo "✅ GeoServer service running"
        sudo systemctl status geoserver --no-pager -l | head -10
    elif systemctl is-active --quiet tomcat* 2>/dev/null; then
        echo "✅ Tomcat running (likely serving GeoServer)"
        sudo systemctl status tomcat* --no-pager -l | head -10
    else
        echo "⚠️  GeoServer/Tomcat service not detected"
    fi
    echo ""
    
    echo "=== Open Ports ==="
    sudo ss -tlnp | grep LISTEN | awk '{print $4, $6}' | sort -u | head -15
    echo ""
    
    echo "=== Installed Web Servers ==="
    for cmd in nginx apache2 httpd; do
        if command -v $cmd &> /dev/null; then
            echo "✅ $cmd installed"
        fi
    done
    echo ""
    
    echo "=== GeoServer Installation ==="
    for dir in /opt/geoserver /usr/share/geoserver /var/lib/tomcat*/webapps/geoserver; do
        if [ -d "$dir" ]; then
            echo "Found: $dir"
            du -sh "$dir" 2>/dev/null || echo "  (size unknown)"
        fi
    done
ENDSSH

echo ""
echo "✅ System audit complete"
echo ""
echo "📋 Next: Review the information above to plan dashboard architecture"
echo ""
echo "Would you like to proceed with installing dashboard components? (Run with --install flag)"
