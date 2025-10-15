#!/bin/bash

#####################################################################
# Run Diagnostic on Proxmox Host (136.243.155.166)
# This will identify the redirect conflict
#####################################################################

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTIC_SCRIPT="$SCRIPT_DIR/diagnose_redirect_conflict.sh"
PROXMOX_HOST="136.243.155.166"
OUTPUT_FILE="/tmp/simondatalab_diagnostic_$(date +%Y%m%d_%H%M%S).log"

echo "========================================================================="
echo "🚀 Run Diagnostic on Proxmox Host"
echo "========================================================================="
echo ""

if [ ! -f "$DIAGNOSTIC_SCRIPT" ]; then
    print_error "Diagnostic script not found: $DIAGNOSTIC_SCRIPT"
    exit 1
fi

print_status "Diagnostic script: $DIAGNOSTIC_SCRIPT"
print_status "Target: root@$PROXMOX_HOST"
print_status "Output will be saved to: $OUTPUT_FILE"
echo ""

# Try to copy and execute
print_status "Attempting to run diagnostic..."
echo ""

if timeout 60 bash -c "
    scp -o ConnectTimeout=20 -o StrictHostKeyChecking=no '$DIAGNOSTIC_SCRIPT' root@${PROXMOX_HOST}:/tmp/diagnose.sh && \
    ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no root@${PROXMOX_HOST} 'chmod +x /tmp/diagnose.sh && /tmp/diagnose.sh' 2>&1
" | tee "$OUTPUT_FILE"; then
    print_success "Diagnostic completed!"
    echo ""
    print_status "Results saved to: $OUTPUT_FILE"
    echo ""
    print_status "Key findings to look for:"
    echo "- iptables rules with DNAT to 10.0.0.104:80"
    echo "- Nginx/Caddy default_server pointing to moodle"
    echo "- Cloudflare tunnel config routing simondatalab.de"
else
    print_error "Failed to connect to Proxmox host"
    echo ""
    print_status "Manual execution:"
    echo "1. Copy script to Proxmox:"
    echo "   scp $DIAGNOSTIC_SCRIPT root@$PROXMOX_HOST:/tmp/diagnose.sh"
    echo ""
    echo "2. SSH to Proxmox and run:"
    echo "   ssh root@$PROXMOX_HOST"
    echo "   chmod +x /tmp/diagnose.sh"
    echo "   /tmp/diagnose.sh > /tmp/diagnostic.log 2>&1"
    echo "   cat /tmp/diagnostic.log"
    exit 1
fi
