#!/bin/bash
#
# Alternative Connection Methods for Proxmox Targets Fix
#

echo "🔍 PROMETHEUS TARGETS - CONNECTION DIAGNOSTICS"
echo "=============================================="
echo ""

# Test basic connectivity
echo "1️⃣  Testing Network Connectivity"
echo "------------------------------"

# Test ping to Proxmox host
echo "Testing Proxmox host (136.243.155.166):"
if ping -c 2 136.243.155.166 >/dev/null 2>&1; then
    echo "   ✅ Ping successful"
    
    # Test SSH port
    if timeout 3 nc -zv 136.243.155.166 22 2>/dev/null; then
        echo "   ✅ SSH port (22) is open"
    else
        echo "   ❌ SSH port (22) is not accessible"
        echo "   💡 Try: ssh -p 2222 root@136.243.155.166 (alternative port)"
    fi
else
    echo "   ❌ Ping failed - host not reachable"
fi

echo ""

# Test ping to VM159
echo "Testing VM159 (10.0.0.110):"
if ping -c 2 10.0.0.110 >/dev/null 2>&1; then
    echo "   ✅ Ping successful"
    
    # Test SSH port
    if timeout 3 nc -zv 10.0.0.110 22 2>/dev/null; then
        echo "   ✅ SSH port (22) is open"
    else
        echo "   ❌ SSH port (22) is not accessible"
    fi
    
    # Test direct HTTP endpoints
    echo "   Testing HTTP endpoints:"
    if timeout 3 curl -s http://10.0.0.110:8080/metrics >/dev/null 2>&1; then
        echo "   ✅ cAdvisor (8080) is already working!"
    else
        echo "   ❌ cAdvisor (8080) not responding"
    fi
    
    if timeout 3 curl -s http://10.0.0.110:9100/metrics >/dev/null 2>&1; then
        echo "   ✅ Node Exporter (9100) is working"
    else
        echo "   ❌ Node Exporter (9100) not responding"
    fi
else
    echo "   ❌ Ping failed - host not reachable from this network"
fi

echo ""
echo "2️⃣  Alternative Connection Methods"
echo "--------------------------------"

echo "If standard SSH doesn't work, try these alternatives:"
echo ""
echo "🔧 Method 1: Different SSH ports"
echo "ssh -p 2222 root@136.243.155.166  # Common alternative SSH port"
echo "ssh -p 22222 root@136.243.155.166 # Another common alternative"
echo ""
echo "🔧 Method 2: SSH via Proxmox web interface"
echo "1. Open https://136.243.155.166:8006 in browser"
echo "2. Login to Proxmox web UI"
echo "3. Click on host node > Shell"
echo "4. Run the PVE exporter commands directly in web shell"
echo ""
echo "🔧 Method 3: VNC/Console access"
echo "Access VM159 through Proxmox web interface:"
echo "1. Go to VM 159 in Proxmox UI"
echo "2. Click Console tab"
echo "3. Login and run cAdvisor commands"
echo ""

echo "3️⃣  Direct Fix Commands (Copy-Paste Ready)"
echo "==========================================="
echo ""
echo "📋 For PVE Exporter (run on Proxmox host):"
echo "----------------------------------------"
cat << 'EOF'
pip3 install prometheus-pve-exporter
cat > /etc/pve_exporter.yml << 'PVEEOF'
default:
    user: root@pam
    verify_ssl: false
PVEEOF
cat > /etc/systemd/system/pve_exporter.service << 'SERVICEEOF'
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
SERVICEEOF
systemctl daemon-reload && systemctl enable pve_exporter && systemctl start pve_exporter
curl http://127.0.0.1:9221/metrics | head -5
EOF

echo ""
echo "📋 For cAdvisor (run on VM159):"
echo "------------------------------"
cat << 'EOF'
docker stop cadvisor 2>/dev/null || true
docker rm cadvisor 2>/dev/null || true
docker run -d --name=cadvisor --restart=unless-stopped --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --privileged --device=/dev/kmsg gcr.io/cadvisor/cadvisor:latest
sleep 5
docker ps | grep cadvisor
curl http://localhost:8080/metrics | head -5
EOF

echo ""
echo "4️⃣  Verification Steps"
echo "--------------------"
echo "After running the commands:"
echo "1. Wait 2 minutes"
echo "2. Check https://prometheus.simondatalab.de/targets"
echo "3. All 4 targets should show UP"
echo ""

echo "5️⃣  Network Requirements Check"
echo "-----------------------------"
echo "If you're not able to connect, you might need:"
echo "• VPN access to the internal network (10.0.0.0/24)"
echo "• SSH key authentication set up"
echo "• Firewall rules allowing your IP"
echo "• Access through a jump host/bastion"
echo ""

echo "Your current public IP (for firewall whitelist):"
curl -s ifconfig.me 2>/dev/null || echo "Unable to detect public IP"
echo ""