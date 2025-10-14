#!/bin/bash

echo "🚀 DEPLOYING PORTFOLIO REDIRECT FIX TO CT 150"
echo "============================================="
echo "Target: CT 150 (portfolio-web-1000150)"
echo "Issue: Redirecting to Moodle instead of portfolio"
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
if [[ ! -f "fix_portfolio_redirect.sh" ]]; then
    print_error "fix_portfolio_redirect.sh not found in current directory"
    print_status "Please run this script from the Learning-Management-System-Academy directory"
    exit 1
fi

print_status "Step 1: Copying fix script to CT 150..."

# Copy the fix script to CT 150
if scp fix_portfolio_redirect.sh ct150:/tmp/ 2>/dev/null; then
    print_success "Fix script copied to CT 150"
else
    print_warning "Direct copy failed, trying alternative method..."
    print_status "Manual copy command:"
    echo "scp fix_portfolio_redirect.sh ct150:/tmp/"
    echo ""
    print_status "Or copy via Proxmox:"
    echo "scp fix_portfolio_redirect.sh root@136.243.155.166:/tmp/"
    echo "ssh root@136.243.155.166 'scp /tmp/fix_portfolio_redirect.sh simonadmin@10.0.0.150:/tmp/'"
fi

print_status "Step 2: Connecting to CT 150 to run fix..."

# Try to connect and run the fix
if ssh ct150 "sudo bash /tmp/fix_portfolio_redirect.sh" 2>/dev/null; then
    print_success "Portfolio redirect fix applied successfully!"
else
    print_warning "Direct execution failed. Manual steps required:"
    echo ""
    print_status "Manual execution steps:"
    echo "1. Connect to CT 150:"
    echo "   ssh -J root@136.243.155.166 simonadmin@10.0.0.150"
    echo ""
    echo "2. Run the fix script:"
    echo "   sudo bash /tmp/fix_portfolio_redirect.sh"
    echo ""
    print_status "Alternative connection methods:"
    echo "Method 1: Two-step connection"
    echo "   ssh root@136.243.155.166"
    echo "   ssh simonadmin@10.0.0.150"
    echo "   sudo bash /tmp/fix_portfolio_redirect.sh"
    echo ""
    echo "Method 2: Proxmox console access"
    echo "   - Go to https://136.243.155.166:8006"
    echo "   - Login to Proxmox"
    echo "   - Go to CT 1000150 (portfolio-web)"
    echo "   - Click Console"
    echo "   - Run: sudo bash /tmp/fix_portfolio_redirect.sh"
fi

print_status "Step 3: Testing the fix..."

# Wait a moment for changes to take effect
sleep 3

# Test the website
print_status "Testing website after fix..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://www.simondatalab.de/)
if [ "$HTTP_CODE" = "200" ]; then
    print_success "Website is responding (HTTP $HTTP_CODE)"
    
    # Check if redirect is gone
    REDIRECT_CHECK=$(curl -s -I https://www.simondatalab.de/ | grep -i "location:" || echo "No redirect")
    if [[ "$REDIRECT_CHECK" == "No redirect" ]]; then
        print_success "✅ Redirect issue FIXED! Portfolio should now display correctly"
    else
        print_warning "Redirect still present: $REDIRECT_CHECK"
        print_status "You may need to purge Cloudflare cache"
    fi
else
    print_warning "Website returned HTTP $HTTP_CODE"
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
echo "curl -X POST \"https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache\" \\"
echo "     -H \"Authorization: Bearer YOUR_API_TOKEN\" \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     --data '{\"purge_everything\":true}'"

echo ""
echo "============================================="
print_success "Portfolio redirect fix deployment completed!"
echo "============================================="
print_status "Next steps:"
echo "1. Purge Cloudflare cache (see instructions above)"
echo "2. Test website: https://www.simondatalab.de/"
echo "3. Verify portfolio content is displayed"
echo "4. Check Moodle is accessible at: https://moodle.simondatalab.de/"
echo ""
print_status "If you need to restore the previous configuration:"
echo "ssh ct150 'sudo cp -r /var/backups/nginx-* /etc/nginx/ && sudo systemctl reload nginx'"
