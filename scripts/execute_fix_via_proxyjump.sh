#!/bin/bash

#####################################################################
# Execute Fix Script on CT 150 via Proxy Jump
# Multiple connection methods and fallbacks
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
echo "🚀 Execute Fix via Proxy Jump"
echo "=========================================="
echo "Date: $(date)"
echo ""

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIX_SCRIPT="$SCRIPT_DIR/fix_simondatalab_redirect.sh"
PROXMOX_HOST="136.243.155.166"
CT150_IP="10.0.0.150"

# Read the fix script content
FIX_SCRIPT_CONTENT=$(cat "$FIX_SCRIPT")

# Array of connection attempts
declare -a USERS=("root" "simonadmin")
declare -a METHODS=(
    "ProxyJump with root"
    "ProxyJump with simonadmin"
    "Two-step via Proxmox"
    "Direct SSH to Proxmox then CT150"
)

print_status "Fix script loaded: $FIX_SCRIPT"
print_status "Target: CT 150 at $CT150_IP via $PROXMOX_HOST"
echo ""

#####################################################################
# Method 1: Direct ProxyJump as root
#####################################################################
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "Method 1: ProxyJump as root@CT150"
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if timeout 30 bash -c "
    cat '$FIX_SCRIPT' | ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no -o ProxyJump=root@${PROXMOX_HOST} root@${CT150_IP} 'cat > /tmp/fix_simondatalab_redirect.sh && chmod +x /tmp/fix_simondatalab_redirect.sh && bash /tmp/fix_simondatalab_redirect.sh'
" 2>&1; then
    print_success "✅ Method 1 succeeded!"
    exit 0
else
    print_warning "Method 1 failed, trying next method..."
fi

echo ""

#####################################################################
# Method 2: Direct ProxyJump as simonadmin
#####################################################################
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "Method 2: ProxyJump as simonadmin@CT150"
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if timeout 30 bash -c "
    cat '$FIX_SCRIPT' | ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no -o ProxyJump=root@${PROXMOX_HOST} simonadmin@${CT150_IP} 'cat > /tmp/fix_simondatalab_redirect.sh && chmod +x /tmp/fix_simondatalab_redirect.sh && sudo bash /tmp/fix_simondatalab_redirect.sh'
" 2>&1; then
    print_success "✅ Method 2 succeeded!"
    exit 0
else
    print_warning "Method 2 failed, trying next method..."
fi

echo ""

#####################################################################
# Method 3: Two-step execution via Proxmox
#####################################################################
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "Method 3: Two-step via Proxmox (root user)"
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if timeout 60 bash -c "
    # Copy script to Proxmox
    scp -o ConnectTimeout=20 -o StrictHostKeyChecking=no '$FIX_SCRIPT' root@${PROXMOX_HOST}:/tmp/fix_simondatalab_redirect.sh 2>&1 && \
    # Execute on CT150 from Proxmox
    ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no root@${PROXMOX_HOST} '
        chmod +x /tmp/fix_simondatalab_redirect.sh && \
        scp -o StrictHostKeyChecking=no /tmp/fix_simondatalab_redirect.sh root@${CT150_IP}:/tmp/ && \
        ssh -o StrictHostKeyChecking=no root@${CT150_IP} \"bash /tmp/fix_simondatalab_redirect.sh\"
    '
" 2>&1; then
    print_success "✅ Method 3 succeeded!"
    exit 0
else
    print_warning "Method 3 failed, trying next method..."
fi

echo ""

#####################################################################
# Method 4: Interactive two-step with detailed output
#####################################################################
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "Method 4: Interactive execution"
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

print_status "Step 1: Connecting to Proxmox..."
if timeout 30 ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no root@${PROXMOX_HOST} "echo 'Connected to Proxmox successfully'" 2>&1; then
    print_success "Connected to Proxmox"
    
    print_status "Step 2: Copying script to Proxmox..."
    if timeout 30 scp -o ConnectTimeout=20 -o StrictHostKeyChecking=no "$FIX_SCRIPT" root@${PROXMOX_HOST}:/tmp/fix_simondatalab_redirect.sh 2>&1; then
        print_success "Script copied to Proxmox"
        
        print_status "Step 3: Testing CT150 connectivity from Proxmox..."
        if timeout 30 ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no root@${PROXMOX_HOST} "ping -c 2 ${CT150_IP}" 2>&1; then
            print_success "CT150 is reachable from Proxmox"
            
            print_status "Step 4: Copying script to CT150..."
            if timeout 30 ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no root@${PROXMOX_HOST} "scp -o StrictHostKeyChecking=no /tmp/fix_simondatalab_redirect.sh root@${CT150_IP}:/tmp/" 2>&1; then
                print_success "Script copied to CT150"
                
                print_status "Step 5: Executing script on CT150..."
                ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no root@${PROXMOX_HOST} "ssh -o StrictHostKeyChecking=no root@${CT150_IP} 'chmod +x /tmp/fix_simondatalab_redirect.sh && bash /tmp/fix_simondatalab_redirect.sh'" 2>&1
                
                if [ $? -eq 0 ]; then
                    print_success "✅ Method 4 succeeded!"
                    exit 0
                else
                    print_error "Script execution on CT150 failed"
                fi
            else
                print_error "Failed to copy script to CT150"
            fi
        else
            print_error "CT150 not reachable from Proxmox"
        fi
    else
        print_error "Failed to copy script to Proxmox"
    fi
else
    print_error "Cannot connect to Proxmox"
fi

echo ""

#####################################################################
# Method 5: Using Proxmox vzctl to execute in container
#####################################################################
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "Method 5: Direct container execution via Proxmox"
print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

print_status "Attempting to execute directly in CT150 container..."
if timeout 60 bash -c "
    # Copy script to Proxmox
    scp -o ConnectTimeout=20 -o StrictHostKeyChecking=no '$FIX_SCRIPT' root@${PROXMOX_HOST}:/tmp/fix_ct150.sh 2>&1 && \
    # Execute using pct exec
    ssh -o ConnectTimeout=20 -o StrictHostKeyChecking=no root@${PROXMOX_HOST} '
        # Copy script into container
        pct push 150 /tmp/fix_ct150.sh /tmp/fix_simondatalab_redirect.sh && \
        # Execute in container
        pct exec 150 -- bash /tmp/fix_simondatalab_redirect.sh
    '
" 2>&1; then
    print_success "✅ Method 5 succeeded!"
    exit 0
else
    print_warning "Method 5 failed"
fi

echo ""

#####################################################################
# All methods failed - provide manual instructions
#####################################################################
print_error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_error "All automated methods failed"
print_error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_status "Please try manual execution:"
echo ""
echo "Option A - Via SSH:"
echo "════════════════════"
echo "1. ssh root@${PROXMOX_HOST}"
echo "2. scp /tmp/fix_simondatalab_redirect.sh root@${CT150_IP}:/tmp/"
echo "3. ssh root@${CT150_IP}"
echo "4. bash /tmp/fix_simondatalab_redirect.sh"
echo ""
echo "Option B - Via Proxmox Console:"
echo "═══════════════════════════════"
echo "1. Open https://${PROXMOX_HOST}:8006"
echo "2. Navigate to CT 150 (portfolio-web-1000150)"
echo "3. Click 'Console'"
echo "4. Run the fix script content directly"
echo ""
echo "Option C - Via pct exec:"
echo "════════════════════════"
echo "1. ssh root@${PROXMOX_HOST}"
echo "2. pct exec 150 -- bash -c 'cat > /tmp/fix.sh << \"EOF\""
echo "   <paste fix script content>"
echo "   EOF'"
echo "3. pct exec 150 -- bash /tmp/fix.sh"
echo ""
print_status "Fix script location: $FIX_SCRIPT"
echo ""

exit 1
