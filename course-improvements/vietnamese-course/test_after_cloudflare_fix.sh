#!/bin/bash

# Test Moodle webservice after Cloudflare WAF rule is configured
# This should work once you add the Cloudflare custom rule

set -e

TOKEN_FILE="$HOME/.moodle_token"
MOODLE_URL="https://moodle.simondatalab.de"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "❌ Token file not found: $TOKEN_FILE"
    exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║         MOODLE WEBSERVICE TEST (via HTTPS + Cloudflare)          ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📡 Testing: $MOODLE_URL/webservice/rest/server.php"
echo "🔑 Token: ${TOKEN:0:8}...${TOKEN: -8}"
echo ""
echo "⏳ Calling core_webservice_get_site_info..."
echo ""

# Make the call
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$MOODLE_URL/webservice/rest/server.php" \
  -d "wstoken=$TOKEN" \
  -d "wsfunction=core_webservice_get_site_info" \
  -d "moodlewsrestformat=json" \
  --max-time 10)

# Split response and HTTP code
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "HTTP Status: $HTTP_CODE"
echo ""

# Check result
if [ "$HTTP_CODE" = "200" ]; then
    # Check if it's JSON with site info
    if echo "$BODY" | jq -e '.sitename' > /dev/null 2>&1; then
        echo "✅ SUCCESS! Webservice is working!"
        echo ""
        echo "Site Information:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$BODY" | jq '{
            sitename,
            siteurl,
            version,
            release,
            functions: .functions | length
        }'
        echo ""
        echo "✅ Cloudflare WAF rule is working correctly!"
        echo "✅ You can now use the Moodle API for automated deployments"
        exit 0
    elif echo "$BODY" | jq -e '.exception' > /dev/null 2>&1; then
        echo "⚠️  API Error:"
        echo "$BODY" | jq
        exit 1
    else
        echo "⚠️  Unexpected response format:"
        echo "$BODY" | head -20
        exit 1
    fi
elif [ "$HTTP_CODE" = "403" ]; then
    echo "❌ HTTP 403 Forbidden"
    echo ""
    echo "Cloudflare WAF is still blocking the request."
    echo ""
    echo "Please verify:"
    echo "  1. You created the Cloudflare WAF custom rule"
    echo "  2. Rule matches: URI Path starts with /webservice/"
    echo "  3. Action is: Skip (All remaining custom rules + WAF Managed Rulesets)"
    echo "  4. Rule is Deployed (not Draft)"
    echo "  5. Wait 30 seconds for propagation"
    echo ""
    echo "See: ./CLOUDFLARE_SETUP.sh for detailed instructions"
    exit 1
elif [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "303" ]; then
    echo "⚠️  HTTP $HTTP_CODE Redirect"
    echo ""
    echo "Moodle is redirecting. This might mean:"
    echo "  • Site registration/setup required"
    echo "  • HTTPS enforcement"
    echo ""
    echo "Response:"
    echo "$BODY" | head -20
    exit 1
else
    echo "❌ HTTP $HTTP_CODE"
    echo ""
    echo "Response:"
    echo "$BODY" | head -20
    exit 1
fi
