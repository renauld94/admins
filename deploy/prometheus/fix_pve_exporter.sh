#!/bin/bash
#
# Fix PVE Exporter - Run this on Proxmox host (136.243.155.166)
#

set -e

echo "🔧 Fixing PVE Exporter on Proxmox Host"
echo "======================================"

# Check if we're on the right host
CURRENT_IP=$(hostname -I | awk '{print $1}')
if [[ "$CURRENT_IP" != "136.243.155.166" ]]; then
    echo "❌ This script must be run on the Proxmox host (136.243.155.166)"
    echo "   Current IP: $CURRENT_IP"
    echo ""
    echo "Run this command to fix from remote:"
    echo "ssh root@136.243.155.166 'bash -s' < $0"
    exit 1
fi

echo "✅ Running on correct host ($CURRENT_IP)"
echo ""

# Install PVE exporter
echo "1️⃣  Installing PVE Exporter..."
if command -v pve_exporter >/dev/null 2>&1; then
    echo "   ✅ pve_exporter already installed"
else
    echo "   📥 Installing prometheus-pve-exporter..."
    pip3 install prometheus-pve-exporter
    echo "   ✅ Installed successfully"
fi

# Create config file
echo ""
echo "2️⃣  Creating configuration..."
cat > /etc/pve_exporter.yml <<'EOF'
default:
    user: root@pam
    verify_ssl: false
EOF
echo "   ✅ Config created at /etc/pve_exporter.yml"

# Create systemd service
echo ""
echo "3️⃣  Creating systemd service..."
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
echo "   ✅ Service file created"

# Enable and start service
echo ""
echo "4️⃣  Starting service..."
systemctl daemon-reload
systemctl enable pve_exporter
systemctl restart pve_exporter

# Wait a moment for service to start
sleep 3

# Verify service is running
if systemctl is-active --quiet pve_exporter; then
    echo "   ✅ Service started successfully"
else
    echo "   ❌ Service failed to start"
    echo "   📋 Check logs: journalctl -u pve_exporter -n 20"
    exit 1
fi

# Test endpoint
echo ""
echo "5️⃣  Testing endpoint..."
if curl -s -m 5 http://127.0.0.1:9221/metrics >/dev/null; then
    METRICS_COUNT=$(curl -s http://127.0.0.1:9221/metrics | grep -c "^pve_" || echo "0")
    echo "   ✅ Endpoint responding with $METRICS_COUNT PVE metrics"
else
    echo "   ❌ Endpoint not responding"
    echo "   📋 Check service: systemctl status pve_exporter"
    exit 1
fi

echo ""
echo "🎉 PVE Exporter fixed successfully!"
echo "   📊 Metrics available at: http://127.0.0.1:9221/metrics"
echo "   📈 Check Prometheus targets in 1-2 minutes"
echo ""