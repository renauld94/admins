#!/bin/bash
#
# Remote Prometheus Targets Fix - Execute fixes on remote hosts
#

set -e

echo "🔧 Remote Prometheus Targets Fix"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    local status=$1
    local message=$2
    case $status in
        "ok") echo -e "${GREEN}✅ $message${NC}" ;;
        "warn") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "error") echo -e "${RED}❌ $message${NC}" ;;
        "info") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

print_status "info" "Script directory: $SCRIPT_DIR"
echo ""

# Test SSH connectivity first
echo "1️⃣  Testing SSH Connectivity"
echo "---------------------------"

# Test Proxmox host
print_status "info" "Testing SSH to Proxmox host (136.243.155.166)..."
if timeout 10 ssh -o ConnectTimeout=5 -o BatchMode=yes root@136.243.155.166 'echo "SSH OK"' 2>/dev/null; then
    print_status "ok" "Proxmox host SSH: CONNECTED"
    PROXMOX_SSH=true
else
    print_status "error" "Proxmox host SSH: FAILED"
    print_status "info" "Make sure SSH key is added or use: ssh-copy-id root@136.243.155.166"
    PROXMOX_SSH=false
fi

# Test VM159
print_status "info" "Testing SSH to VM159 (10.0.0.110)..."
if timeout 10 ssh -o ConnectTimeout=5 -o BatchMode=yes root@10.0.0.110 'echo "SSH OK"' 2>/dev/null; then
    print_status "ok" "VM159 SSH: CONNECTED"
    VM159_SSH=true
else
    print_status "error" "VM159 SSH: FAILED"
    print_status "info" "Make sure SSH key is added or use: ssh-copy-id root@10.0.0.110"
    VM159_SSH=false
fi

echo ""

# Fix PVE Exporter
echo "2️⃣  Fixing PVE Exporter"
echo "----------------------"

if [[ "$PROXMOX_SSH" == "true" ]]; then
    print_status "info" "Uploading and executing PVE exporter fix script..."
    
    # Upload and execute the script
    if scp "$SCRIPT_DIR/fix_pve_exporter.sh" root@136.243.155.166:/tmp/fix_pve_exporter.sh 2>/dev/null; then
        print_status "ok" "Script uploaded successfully"
        
        # Execute the script
        if ssh root@136.243.155.166 'chmod +x /tmp/fix_pve_exporter.sh && /tmp/fix_pve_exporter.sh' 2>/dev/null; then
            print_status "ok" "PVE exporter fixed successfully!"
        else
            print_status "error" "Failed to execute PVE exporter fix"
        fi
    else
        print_status "error" "Failed to upload PVE exporter script"
    fi
else
    print_status "warn" "Skipping PVE exporter fix - SSH not available"
    echo "Manual command:"
    echo "ssh root@136.243.155.166 'pip3 install prometheus-pve-exporter && systemctl restart pve_exporter'"
fi

echo ""

# Fix cAdvisor
echo "3️⃣  Fixing cAdvisor"
echo "------------------"

if [[ "$VM159_SSH" == "true" ]]; then
    print_status "info" "Uploading and executing cAdvisor fix script..."
    
    # Upload and execute the script
    if scp "$SCRIPT_DIR/fix_cadvisor.sh" root@10.0.0.110:/tmp/fix_cadvisor.sh 2>/dev/null; then
        print_status "ok" "Script uploaded successfully"
        
        # Execute the script
        if ssh root@10.0.0.110 'chmod +x /tmp/fix_cadvisor.sh && /tmp/fix_cadvisor.sh' 2>/dev/null; then
            print_status "ok" "cAdvisor fixed successfully!"
        else
            print_status "error" "Failed to execute cAdvisor fix"
        fi
    else
        print_status "error" "Failed to upload cAdvisor script"
    fi
else
    print_status "warn" "Skipping cAdvisor fix - SSH not available"
    echo "Manual command:"
    echo "ssh root@10.0.0.110 'docker run -d --name=cadvisor --restart=unless-stopped --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --privileged --device=/dev/kmsg gcr.io/cadvisor/cadvisor:latest'"
fi

echo ""

# Final verification
echo "4️⃣  Final Verification"
echo "---------------------"

print_status "info" "Waiting 10 seconds for services to stabilize..."
sleep 10

# Test endpoints
echo ""
print_status "info" "Testing endpoints:"

# Test PVE exporter via Proxmox host
if [[ "$PROXMOX_SSH" == "true" ]]; then
    if ssh root@136.243.155.166 'curl -s -m 5 http://127.0.0.1:9221/metrics >/dev/null' 2>/dev/null; then
        print_status "ok" "PVE exporter (127.0.0.1:9221) - RESPONDING"
    else
        print_status "error" "PVE exporter (127.0.0.1:9221) - NOT RESPONDING"
    fi
fi

# Test cAdvisor
if timeout 5 curl -s http://10.0.0.110:8080/metrics >/dev/null 2>&1; then
    print_status "ok" "cAdvisor (10.0.0.110:8080) - RESPONDING"
else
    print_status "error" "cAdvisor (10.0.0.110:8080) - NOT RESPONDING"
fi

# Test node exporter on Proxmox host
if timeout 5 curl -s http://136.243.155.166:9100/metrics >/dev/null 2>&1; then
    print_status "ok" "Proxmox node_exporter (136.243.155.166:9100) - RESPONDING"
else
    print_status "error" "Proxmox node_exporter (136.243.155.166:9100) - NOT RESPONDING"
fi

echo ""
echo "5️⃣  Summary & Next Steps"
echo "----------------------"

print_status "info" "✨ Fixes completed!"
print_status "info" "🕐 Wait 1-2 minutes for Prometheus to detect the changes"
print_status "info" "🌐 Check status at: https://prometheus.simondatalab.de/targets"
print_status "info" "📊 All targets should show as UP (green)"

echo ""
echo "📋 Manual verification commands:"
echo "curl http://136.243.155.166:9221/metrics  # PVE exporter"
echo "curl http://10.0.0.110:8080/metrics       # cAdvisor"
echo "curl http://136.243.155.166:9100/metrics  # Node exporter"

echo ""
print_status "info" "If issues persist, check the individual fix scripts:"
print_status "info" "- $SCRIPT_DIR/fix_pve_exporter.sh"
print_status "info" "- $SCRIPT_DIR/fix_cadvisor.sh"
echo ""