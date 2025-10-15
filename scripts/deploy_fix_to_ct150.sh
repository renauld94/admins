#!/bin/bash

#####################################################################
# Deploy and Run Fix Script on CT 150
# This script copies the fix script to CT 150 and executes it
#####################################################################

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=========================================="
echo "🚀 Deploy Fix to CT 150"
echo "=========================================="
echo "Date: $(date)"
echo ""

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIX_SCRIPT="$SCRIPT_DIR/fix_simondatalab_redirect.sh"
PROXMOX_HOST="136.243.155.166"
PROXMOX_USER="root"
CT150_IP="10.0.0.150"
CT150_USER="root"

# Check if fix script exists
if [ ! -f "$FIX_SCRIPT" ]; then
    print_error "Fix script not found: $FIX_SCRIPT"
    exit 1
fi

print_success "Fix script found: $FIX_SCRIPT"

# Method 1: Try direct ProxyJump
print_status "Method 1: Attempting deployment via ProxyJump..."
if timeout 20 scp -o ConnectTimeout=15 -o StrictHostKeyChecking=no -o ProxyJump=${PROXMOX_USER}@${PROXMOX_HOST} "$FIX_SCRIPT" ${CT150_USER}@${CT150_IP}:/tmp/fix_simondatalab_redirect.sh 2>/dev/null; then
    print_success "Script copied to CT 150 via ProxyJump"
    
    print_status "Making script executable..."
    ssh -o ConnectTimeout=15 -o StrictHostKeyChecking=no -o ProxyJump=${PROXMOX_USER}@${PROXMOX_HOST} ${CT150_USER}@${CT150_IP} "chmod +x /tmp/fix_simondatalab_redirect.sh"
    
    print_status "Running fix script on CT 150..."
    ssh -o ConnectTimeout=15 -o StrictHostKeyChecking=no -o ProxyJump=${PROXMOX_USER}@${PROXMOX_HOST} ${CT150_USER}@${CT150_IP} "/tmp/fix_simondatalab_redirect.sh"
    
    print_success "Fix script executed successfully via ProxyJump!"
    exit 0
fi

# Method 2: Try two-step approach via Proxmox
print_warning "ProxyJump failed. Trying two-step deployment via Proxmox..."

print_status "Step 1: Copying script to Proxmox..."
if timeout 20 scp -o ConnectTimeout=15 -o StrictHostKeyChecking=no "$FIX_SCRIPT" ${PROXMOX_USER}@${PROXMOX_HOST}:/tmp/fix_simondatalab_redirect.sh 2>/dev/null; then
    print_success "Script copied to Proxmox"
    
    print_status "Step 2: Copying script from Proxmox to CT 150..."
    ssh -o ConnectTimeout=15 -o StrictHostKeyChecking=no ${PROXMOX_USER}@${PROXMOX_HOST} "scp -o ConnectTimeout=15 -o StrictHostKeyChecking=no /tmp/fix_simondatalab_redirect.sh ${CT150_USER}@${CT150_IP}:/tmp/"
    
    print_status "Step 3: Running fix script on CT 150..."
    ssh -o ConnectTimeout=15 -o StrictHostKeyChecking=no ${PROXMOX_USER}@${PROXMOX_HOST} "ssh -o ConnectTimeout=15 -o StrictHostKeyChecking=no ${CT150_USER}@${CT150_IP} 'chmod +x /tmp/fix_simondatalab_redirect.sh && /tmp/fix_simondatalab_redirect.sh'"
    
    print_success "Fix script executed successfully via two-step method!"
    exit 0
fi

# Method 3: Manual instructions
print_error "Automated deployment failed. Please deploy manually."
echo ""
print_status "Manual deployment steps:"
echo ""
echo "1. Copy script to Proxmox:"
echo "   scp $FIX_SCRIPT root@${PROXMOX_HOST}:/tmp/"
echo ""
echo "2. Connect to Proxmox:"
echo "   ssh root@${PROXMOX_HOST}"
echo ""
echo "3. From Proxmox, copy to CT 150:"
echo "   scp /tmp/fix_simondatalab_redirect.sh root@${CT150_IP}:/tmp/"
echo ""
echo "4. From Proxmox, connect to CT 150 and run:"
echo "   ssh root@${CT150_IP}"
echo "   chmod +x /tmp/fix_simondatalab_redirect.sh"
echo "   /tmp/fix_simondatalab_redirect.sh"
echo ""
print_status "Or use Proxmox web console:"
echo "1. Go to https://${PROXMOX_HOST}:8006"
echo "2. Select CT 150 (portfolio-web-1000150)"
echo "3. Click Console"
echo "4. Paste the fix script content or upload it"
echo ""

exit 1
