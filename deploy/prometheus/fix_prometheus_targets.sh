#!/bin/bash
#
# Fix Prometheus Targets - Comprehensive diagnostic and repair script
# This script will identify and fix issues with Prometheus scrape targets
#

set -e

echo "🔧 Fixing Prometheus Targets"
echo "============================"
echo ""

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
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

# Check current location and available services
echo "1️⃣  Environment Check"
echo "-------------------"
print_status "info" "Current host: $(hostname)"
print_status "info" "Current IP: $(hostname -I | awk '{print $1}')"
print_status "info" "Current user: $(whoami)"

# Check if we're on the Proxmox host (136.243.155.166)
CURRENT_IP=$(hostname -I | awk '{print $1}')
if [[ "$CURRENT_IP" == "136.243.155.166" ]]; then
    ON_PROXMOX_HOST=true
    print_status "ok" "Running on Proxmox host"
else
    ON_PROXMOX_HOST=false
    print_status "warn" "Not on Proxmox host (IP: $CURRENT_IP)"
fi

echo ""
echo "2️⃣  Checking Prometheus Configuration"
echo "-----------------------------------"

# Check Prometheus config
if [[ -f "/home/simon/Learning-Management-System-Academy/deploy/prometheus/prometheus.yml" ]]; then
    print_status "ok" "Found Prometheus config"
    print_status "info" "Current targets configured:"
    grep -A 2 "targets:" /home/simon/Learning-Management-System-Academy/deploy/prometheus/prometheus.yml | grep -E "(targets:|job_name)" | sed 's/^/    /'
else
    print_status "error" "Prometheus config not found"
fi

echo ""
echo "3️⃣  Testing Target Connectivity"
echo "-----------------------------"

# Test each target
declare -A targets=(
    ["proxmox-host"]="136.243.155.166:9100"
    ["pve_exporter"]="127.0.0.1:9221"
    ["vm159-cadvisor"]="10.0.0.110:8080"
    ["vm159-node"]="10.0.0.110:9100"
)

for job_name in "${!targets[@]}"; do
    target=${targets[$job_name]}
    echo "Testing $job_name ($target):"
    
    # Extract host and port
    host=$(echo $target | cut -d: -f1)
    port=$(echo $target | cut -d: -f2)
    
    # Test basic connectivity
    if timeout 3 nc -zv $host $port 2>/dev/null; then
        print_status "ok" "  Network connectivity: PASS"
        
        # Test HTTP endpoint
        if curl -s -m 5 "http://$target/metrics" >/dev/null 2>&1; then
            print_status "ok" "  HTTP metrics endpoint: PASS"
        else
            print_status "error" "  HTTP metrics endpoint: FAIL"
        fi
    else
        print_status "error" "  Network connectivity: FAIL"
        
        # Suggest fixes based on target
        case $job_name in
            "pve_exporter")
                print_status "info" "  💡 Fix: Run setup_pve_exporter.sh on Proxmox host"
                ;;
            "vm159-cadvisor")
                print_status "info" "  💡 Fix: SSH to VM159 and run restart_cadvisor.sh"
                ;;
            "vm159-node")
                print_status "info" "  💡 Fix: Install node_exporter on VM159"
                ;;
        esac
    fi
    echo ""
done

echo "4️⃣  Automated Fixes"
echo "-------------------"

# Fix 1: PVE Exporter (if on Proxmox host)
if [[ "$ON_PROXMOX_HOST" == "true" ]]; then
    echo "Attempting to fix PVE Exporter..."
    
    # Check if pve_exporter is installed
    if command -v pve_exporter >/dev/null 2>&1; then
        print_status "ok" "pve_exporter is installed"
    else
        print_status "warn" "Installing pve_exporter..."
        pip3 install prometheus-pve-exporter 2>/dev/null && print_status "ok" "Installed pve_exporter"
    fi
    
    # Check service status
    if systemctl is-active --quiet pve_exporter 2>/dev/null; then
        print_status "ok" "pve_exporter service is running"
    else
        print_status "warn" "Starting pve_exporter service..."
        if [[ -f "/home/simon/Learning-Management-System-Academy/deploy/prometheus/setup_pve_exporter.sh" ]]; then
            bash /home/simon/Learning-Management-System-Academy/deploy/prometheus/setup_pve_exporter.sh
        fi
    fi
else
    print_status "info" "Run this script on Proxmox host (136.243.155.166) to fix pve_exporter"
fi

echo ""
echo "5️⃣  Remote Fix Commands"
echo "----------------------"

# Generate commands for remote execution
echo "To fix VM159 services, run these commands:"
echo ""
echo "# SSH to VM159 and fix cAdvisor:"
echo "ssh root@10.0.0.110 'docker run -d --name=cadvisor --restart=unless-stopped --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --privileged --device=/dev/kmsg gcr.io/cadvisor/cadvisor:latest'"
echo ""
echo "# SSH to VM159 and install node_exporter:"
echo "ssh root@10.0.0.110 'wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz && tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz && sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/ && sudo useradd -rs /bin/false node_exporter && sudo systemctl daemon-reload && sudo systemctl enable node_exporter && sudo systemctl start node_exporter'"
echo ""

# Create service files for future reference
echo "6️⃣  Creating Service Templates"
echo "-----------------------------"

# Create node_exporter service file template
cat > /tmp/node_exporter.service <<'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:9100
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

print_status "ok" "Created node_exporter service template at /tmp/node_exporter.service"

echo ""
echo "7️⃣  Summary & Next Steps"
echo "----------------------"
print_status "info" "1. For pve_exporter: Run this script on Proxmox host (136.243.155.166)"
print_status "info" "2. For VM159 services: SSH to 10.0.0.110 and run the provided commands"
print_status "info" "3. Wait 1-2 minutes after fixes for Prometheus to detect changes"
print_status "info" "4. Refresh Prometheus targets page: https://prometheus.simondatalab.de/targets"

echo ""
echo "📋 Current Status Summary:"
echo "========================="
for job_name in "${!targets[@]}"; do
    target=${targets[$job_name]}
    host=$(echo $target | cut -d: -f1)
    port=$(echo $target | cut -d: -f2)
    
    if timeout 3 nc -zv $host $port 2>/dev/null; then
        print_status "ok" "$job_name ($target) - UP"
    else
        print_status "error" "$job_name ($target) - DOWN"
    fi
done

echo ""
print_status "info" "Script completed. Check Prometheus targets in 2-3 minutes."