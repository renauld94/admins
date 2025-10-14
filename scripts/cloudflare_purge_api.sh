#!/bin/bash

echo "🌐 CLOUDFLARE CACHE PURGE VIA API"
echo "================================="
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
API_EMAIL="sn.renauld@gmail.com"

# You need to set these values
ZONE_ID=""
API_TOKEN=""

# Check if API credentials are provided
if [ -z "$ZONE_ID" ] || [ -z "$API_TOKEN" ]; then
    print_warning "API credentials not set in script"
    print_status "To get your API credentials:"
    echo ""
    echo "1. Go to: https://dash.cloudflare.com/profile/api-tokens"
    echo "2. Click 'Create Token'"
    echo "3. Use 'Custom token' template"
    echo "4. Set permissions:"
    echo "   - Zone:Zone:Read"
    echo "   - Zone:Cache Purge:Edit"
    echo "5. Zone Resources: Include - Specific zone - simondatalab.de"
    echo "6. Copy the token"
    echo ""
    echo "7. Get Zone ID:"
    echo "   - Go to: https://dash.cloudflare.com/"
    echo "   - Select your domain"
    echo "   - Right sidebar shows Zone ID"
    echo ""
    print_status "Then update this script with your credentials:"
    echo "ZONE_ID=\"your_zone_id_here\""
    echo "API_TOKEN=\"your_api_token_here\""
    echo ""
    print_status "Or run the API commands manually:"
    echo ""
    echo "# Purge everything"
    echo "curl -X POST \"https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache\" \\"
    echo "     -H \"Authorization: Bearer YOUR_API_TOKEN\" \\"
    echo "     -H \"Content-Type: application/json\" \\"
    echo "     --data '{\"purge_everything\":true}'"
    echo ""
    echo "# Purge specific files"
    echo "curl -X POST \"https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache\" \\"
    echo "     -H \"Authorization: Bearer YOUR_API_TOKEN\" \\"
    echo "     -H \"Content-Type: application/json\" \\"
    echo "     --data '{\"files\":[\"https://www.simondatalab.de/\", \"https://www.simondatalab.de/index.html\"]}'"
    echo ""
    exit 1
fi

print_status "Using Zone ID: $ZONE_ID"
print_status "Using API Token: ${API_TOKEN:0:10}..."

# Method 1: Purge everything
print_status "Method 1: Purging entire cache..."
PURGE_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}')

if echo "$PURGE_RESPONSE" | grep -q '"success":true'; then
    print_success "✅ Entire cache purged successfully!"
    print_status "Response: $PURGE_RESPONSE"
else
    print_error "❌ Failed to purge entire cache"
    print_status "Response: $PURGE_RESPONSE"
    print_status "Checking API token permissions..."
fi

# Method 2: Purge specific files
print_status "Method 2: Purging specific portfolio files..."
SPECIFIC_FILES='["https://www.simondatalab.de/", "https://www.simondatalab.de/index.html", "https://simondatalab.de/", "https://simondatalab.de/index.html"]'

PURGE_FILES_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"files\":$SPECIFIC_FILES}")

if echo "$PURGE_FILES_RESPONSE" | grep -q '"success":true'; then
    print_success "✅ Specific files purged successfully!"
    print_status "Response: $PURGE_FILES_RESPONSE"
else
    print_error "❌ Failed to purge specific files"
    print_status "Response: $PURGE_FILES_RESPONSE"
fi

# Method 3: Purge by hostname
print_status "Method 3: Purging by hostname..."
PURGE_HOSTNAME_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"hosts":["www.simondatalab.de", "simondatalab.de"]}')

if echo "$PURGE_HOSTNAME_RESPONSE" | grep -q '"success":true'; then
    print_success "✅ Hostname cache purged successfully!"
    print_status "Response: $PURGE_HOSTNAME_RESPONSE"
else
    print_warning "⚠️  Hostname purge may not be supported or configured"
    print_status "Response: $PURGE_HOSTNAME_RESPONSE"
fi

# Verify cache status
print_status "Checking cache status after purge..."
sleep 2

# Test website response
print_status "Testing website response..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/")
if [ "$HTTP_CODE" = "200" ]; then
    print_success "✅ Website is responding with HTTP $HTTP_CODE"
else
    print_warning "⚠️  Website returned HTTP $HTTP_CODE"
fi

# Check cache headers
print_status "Checking cache headers..."
CACHE_STATUS=$(curl -s -I "https://www.simondatalab.de/" | grep -i "cf-cache-status" || echo "No cache status header found")
print_status "Cache status: $CACHE_STATUS"

# Check if redirect is resolved
print_status "Checking if redirect issue is resolved..."
REDIRECT_CHECK=$(curl -s -I "https://www.simondatalab.de/" | grep -i "location:" || echo "No redirect found")
if [[ "$REDIRECT_CHECK" == "No redirect found" ]]; then
    print_success "✅ Redirect issue appears to be resolved!"
else
    print_warning "⚠️  Redirect still present: $REDIRECT_CHECK"
    print_status "You may need to fix the NGINX configuration first"
fi

# Check content
print_status "Checking website content..."
CONTENT_CHECK=$(curl -s "https://www.simondatalab.de/" | head -5)
if echo "$CONTENT_CHECK" | grep -q "Simon Renauld\|Portfolio\|Professional Learning Platform"; then
    print_success "✅ Portfolio content is being served"
    print_status "First 5 lines of content:"
    echo "$CONTENT_CHECK"
else
    print_warning "⚠️  Portfolio content may not be correct"
    print_status "First 5 lines of content:"
    echo "$CONTENT_CHECK"
fi

echo ""
print_success "🎉 Cloudflare cache purge completed!"
print_status "Next steps:"
echo "1. Test website: https://www.simondatalab.de/"
echo "2. Verify portfolio content is displayed correctly"
echo "3. Check that Moodle is accessible at: https://moodle.simondatalab.de/"
echo "4. If issues persist, check NGINX configuration on CT 150"
echo ""
print_status "Note: Cache changes may take a few minutes to propagate globally"
print_status "You can monitor cache status at: https://dash.cloudflare.com/"
