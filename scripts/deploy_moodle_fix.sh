#!/bin/bash

echo "🚀 DEPLOYING MOODLE REDIRECTION FIX TO VM 9001"
echo "=============================================="
echo "Target: VM 9001 (simonadmin@10.0.0.104)"
echo "Moodle: https://moodle.simondatalab.de/"
echo "Date: $(date)"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "scripts/fix_moodle_redirections.sh" ]]; then
    print_error "fix_moodle_redirections.sh not found in scripts directory"
    print_status "Please run this script from the Learning-Management-System-Academy directory"
    exit 1
fi

print_status "Step 1: Copying fix script to VM 9001..."

# Copy the fix script to VM 9001 via proxy jump
if scp -J root@136.243.155.166 scripts/fix_moodle_redirections.sh simonadmin@10.0.0.104:/tmp/ 2>/dev/null; then
    print_success "Fix script copied to VM 9001"
else
    print_warning "Direct copy failed, trying alternative method..."
    print_status "Manual copy commands:"
    echo "scp -J root@136.243.155.166 fix_moodle_redirections.sh simonadmin@10.0.0.104:/tmp/"
    echo ""
    print_status "Or copy via Proxmox:"
    echo "scp fix_moodle_redirections.sh root@136.243.155.166:/tmp/"
    echo "ssh root@136.243.155.166 'scp /tmp/fix_moodle_redirections.sh simonadmin@10.0.0.104:/tmp/'"
fi

print_status "Step 2: Connecting to VM 9001 to run fix..."

# Try to connect and run the fix
if ssh -J root@136.243.155.166 simonadmin@10.0.0.104 "sudo bash /tmp/fix_moodle_redirections.sh" 2>/dev/null; then
    print_success "Moodle redirection fix applied successfully!"
else
    print_warning "Direct execution failed. Manual steps required:"
    echo ""
    print_status "Manual execution steps:"
    echo "1. Connect to VM 9001:"
    echo "   ssh -J root@136.243.155.166 simonadmin@10.0.0.104"
    echo ""
    echo "2. Run the fix script:"
    echo "   sudo bash /tmp/fix_moodle_redirections.sh"
    echo ""
    print_status "Alternative connection methods:"
    echo "Method 1: Two-step connection"
    echo "   ssh root@136.243.155.166"
    echo "   ssh simonadmin@10.0.0.104"
    echo "   sudo bash /tmp/fix_moodle_redirections.sh"
    echo ""
    echo "Method 2: Proxmox console access"
    echo "   - Go to https://136.243.155.166:8006"
    echo "   - Login to Proxmox"
    echo "   - Go to VM 9001"
    echo "   - Click Console"
    echo "   - Run: sudo bash /tmp/fix_moodle_redirections.sh"
fi

print_status "Step 3: Testing the fix..."

# Wait a moment for changes to take effect
sleep 3

# Test Moodle
print_status "Testing Moodle after fix..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://moodle.simondatalab.de/)
if [ "$HTTP_CODE" = "200" ]; then
    print_success "Moodle is responding (HTTP $HTTP_CODE)"
else
    print_warning "Moodle returned HTTP $HTTP_CODE"
fi

# Test Portfolio
print_status "Testing Portfolio after fix..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://www.simondatalab.de/)
if [ "$HTTP_CODE" = "200" ]; then
    print_success "Portfolio is responding (HTTP $HTTP_CODE)"
else
    print_warning "Portfolio returned HTTP $HTTP_CODE"
fi

# Check for redirects
print_status "Checking for redirects..."
MOODLE_REDIRECT=$(curl -s -I https://moodle.simondatalab.de/ | grep -i "location:" || echo "No redirect")
PORTFOLIO_REDIRECT=$(curl -s -I https://www.simondatalab.de/ | grep -i "location:" || echo "No redirect")

if [[ "$MOODLE_REDIRECT" == "No redirect" ]]; then
    print_success "✅ Moodle has no redirects"
else
    print_warning "Moodle still has redirects: $MOODLE_REDIRECT"
fi

if [[ "$PORTFOLIO_REDIRECT" == "No redirect" ]]; then
    print_success "✅ Portfolio has no redirects"
else
    print_warning "Portfolio still has redirects: $PORTFOLIO_REDIRECT"
fi

print_status "Step 4: Cloudflare cache purge instructions..."

print_warning "IMPORTANT: Purge Cloudflare cache to see changes:"
echo ""
echo "Option 1: Cloudflare Dashboard"
echo "1. Go to: https://dash.cloudflare.com/"
echo "2. Select domain: simondatalab.de"
echo "3. Go to Caching → Configuration"
echo "4. Click 'Purge Everything'"
echo ""
echo "Option 2: API (if you have API credentials)"
echo "bash scripts/cloudflare_purge_api.sh"

echo ""
echo "=============================================="
print_success "Moodle redirection fix deployment completed!"
echo "=============================================="
print_status "Next steps:"
echo "1. Test Moodle: https://moodle.simondatalab.de/"
echo "2. Test Portfolio: https://www.simondatalab.de/"
echo "3. Purge Cloudflare cache"
echo "4. Check logs on VM 9001 if issues persist"
echo ""
print_status "If you need to restore the previous configuration:"
echo "ssh -J root@136.243.155.166 simonadmin@10.0.0.104 'sudo iptables-restore < /var/backups/iptables-backup-*'"
