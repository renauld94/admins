#!/bin/bash

echo "🌐 CLOUDFLARE CACHE PURGE SCRIPT"
echo "================================"
echo "Domain: simondatalab.de"
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

# Check if required tools are installed
if ! command -v curl &> /dev/null; then
    print_error "curl is required but not installed"
    exit 1
fi

# Cloudflare API configuration
DOMAIN="simondatalab.de"
API_EMAIL="sn.renauld@gmail.com"  # Replace with your Cloudflare email
API_KEY=""  # You need to set this with your Global API Key
ZONE_ID=""  # You need to set this with your Zone ID

# Check if API credentials are set
if [ -z "$API_KEY" ] || [ -z "$ZONE_ID" ]; then
    print_warning "API credentials not set in script"
    print_status "To get your API credentials:"
    echo "1. Go to https://dash.cloudflare.com/profile/api-tokens"
    echo "2. Get your Global API Key"
    echo "3. Go to https://dash.cloudflare.com/"
    echo "4. Select your domain and get Zone ID from the right sidebar"
    echo "5. Update this script with your credentials"
    echo ""
    print_status "Manual cache purge options:"
    echo "1. Visit: https://dash.cloudflare.com/ → Caching → Configuration → Purge Everything"
    echo "2. Or use the Cloudflare API directly:"
    echo ""
    echo "curl -X POST \"https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache\" \\"
    echo "     -H \"X-Auth-Email: $API_EMAIL\" \\"
    echo "     -H \"X-Auth-Key: YOUR_API_KEY\" \\"
    echo "     -H \"Content-Type: application/json\" \\"
    echo "     --data '{\"purge_everything\":true}'"
    echo ""
    exit 1
fi

# Method 1: Purge everything
print_status "Method 1: Purging entire cache..."
PURGE_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "X-Auth-Email: $API_EMAIL" \
     -H "X-Auth-Key: $API_KEY" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}')

if echo "$PURGE_RESPONSE" | grep -q '"success":true'; then
    print_success "Cache purged successfully!"
    print_status "Response: $PURGE_RESPONSE"
else
    print_error "Failed to purge cache"
    print_status "Response: $PURGE_RESPONSE"
fi

# Method 2: Purge specific files
print_status "Method 2: Purging specific files..."
SPECIFIC_FILES='["https://www.simondatalab.de/", "https://www.simondatalab.de/index.html", "https://www.simondatalab.de/lms/"]'

PURGE_FILES_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "X-Auth-Email: $API_EMAIL" \
     -H "X-Auth-Key: $API_KEY" \
     -H "Content-Type: application/json" \
     --data "{\"files\":$SPECIFIC_FILES}")

if echo "$PURGE_FILES_RESPONSE" | grep -q '"success":true'; then
    print_success "Specific files purged successfully!"
    print_status "Response: $PURGE_FILES_RESPONSE"
else
    print_error "Failed to purge specific files"
    print_status "Response: $PURGE_FILES_RESPONSE"
fi

# Method 3: Purge by tags (if using Cloudflare Workers or Page Rules)
print_status "Method 3: Purging by tags..."
PURGE_TAGS_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "X-Auth-Email: $API_EMAIL" \
     -H "X-Auth-Key: $API_KEY" \
     -H "Content-Type: application/json" \
     --data '{"tags":["simondatalab","portfolio"]}')

if echo "$PURGE_TAGS_RESPONSE" | grep -q '"success":true'; then
    print_success "Cache purged by tags successfully!"
    print_status "Response: $PURGE_TAGS_RESPONSE"
else
    print_warning "Tag-based purge may not be configured"
    print_status "Response: $PURGE_TAGS_RESPONSE"
fi

# Verify cache status
print_status "Checking cache status..."
CACHE_STATUS=$(curl -s -I "https://www.simondatalab.de/" | grep -i "cf-cache-status" || echo "No cache status header found")
print_status "Cache status: $CACHE_STATUS"

# Test website response
print_status "Testing website response..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/")
if [ "$HTTP_CODE" = "200" ]; then
    print_success "Website is responding with HTTP 200"
else
    print_warning "Website returned HTTP $HTTP_CODE"
fi

echo ""
print_success "Cloudflare cache purge process completed!"
print_status "Note: It may take a few minutes for changes to propagate globally"
print_status "You can check cache status at: https://dash.cloudflare.com/"
