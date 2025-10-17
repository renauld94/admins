#!/bin/bash
#
# Check and restart PVE Exporter on Proxmox host
# Run this script on your Proxmox host to enable Proxmox-specific metrics
#

set -e

echo "🔧 Setting up PVE Exporter on Proxmox Host"
echo "="
echo ""

# Check if pve_exporter is installed
echo "1️⃣  Checking for pve_exporter..."
if command -v pve_exporter >/dev/null 2>&1; then
    echo "   ✅ pve_exporter is installed"
    PVE_VERSION=$(pve_exporter --version 2>&1 | head -1 || echo "unknown")
    echo "   ℹ️  Version: $PVE_VERSION"
else
    echo "   ⚠️  pve_exporter not found! Installing..."
    
    # Install using pip
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install prometheus-pve-exporter
        echo "   ✅ Installed prometheus-pve-exporter"
    else
        echo "   ❌ pip3 not found! Install manually:"
        echo "      apt-get update && apt-get install -y python3-pip"
        echo "      pip3 install prometheus-pve-exporter"
        exit 1
    fi
fi

echo ""
echo "2️⃣  Checking pve_exporter service status..."
if systemctl is-active --quiet pve_exporter 2>/dev/null; then
    echo "   ✅ pve_exporter service is running"
    systemctl restart pve_exporter
    echo "   🔄 Restarted pve_exporter"
else
    echo "   ⚠️  pve_exporter service not running or doesn't exist"
    echo "   ℹ️  Creating systemd service..."
    
    # Create systemd service file
    cat > /etc/systemd/system/pve_exporter.service <<'EOF'
[Unit]
Description=Proxmox VE Exporter for Prometheus
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/pve_exporter --address 127.0.0.1:9221 --config-file /etc/pve_exporter.yml
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    
    # Create config file
    cat > /etc/pve_exporter.yml <<'EOF'
default:
    user: root@pam
    verify_ssl: false
EOF
    
    echo "   ✅ Created systemd service"
    systemctl daemon-reload
    systemctl enable pve_exporter
    systemctl start pve_exporter
    echo "   ✅ Started pve_exporter service"
fi

echo ""
echo "3️⃣  Verifying pve_exporter is responding..."
sleep 2

if curl -s http://127.0.0.1:9221/metrics >/dev/null 2>&1; then
    echo "   ✅ PVE exporter metrics endpoint is responding!"
    METRIC_COUNT=$(curl -s http://127.0.0.1:9221/metrics | grep -c "^pve_" || echo "0")
    echo "   ℹ️  Found $METRIC_COUNT PVE-specific metrics"
else
    echo "   ❌ PVE exporter not responding at http://127.0.0.1:9221"
    echo "   ℹ️  Check logs: journalctl -u pve_exporter -n 50"
fi

echo ""
echo "="
echo "✅ Done! PVE Exporter should now be accessible at http://127.0.0.1:9221"
echo "   Wait 30 seconds for Prometheus to scrape metrics, then refresh Grafana"
echo ""
echo "📝 To view logs: journalctl -u pve_exporter -f"
echo ""
