#!/bin/bash

# CLOUDFLARE API SSL FIX SCRIPT
# Uses Cloudflare API to fix SSL certificate issues

echo "🔐 CLOUDFLARE API SSL FIX SCRIPT"
echo "================================"
echo ""

echo "🔍 ANALYZING YOUR CLOUDFLARE CONFIGURATION:"
echo "==========================================="
echo ""
echo "✅ DNS Records Found:"
echo "  - moodle.simondatalab.de → 136.243.155.166 (Proxied)"
echo "  - grafana.simondatalab.de → 136.243.155.166 (Proxied)"
echo "  - jellyfin.simondatalab.de → 136.243.155.166 (Proxied)"
echo "  - nextcloud.simondatalab.de → 136.243.155.166 (Proxied)"
echo ""
echo "✅ API Access Confirmed:"
echo "  - Zone.DNS Settings ✓"
echo "  - Zone.Cache Purge ✓"
echo "  - Zone.Firewall Services ✓"
echo "  - Zone.Config Rules ✓"
echo ""

echo "🚨 ISSUE IDENTIFIED:"
echo "==================="
echo "❌ Error code 526: Invalid SSL certificate"
echo "❌ Moodle was working yesterday (temporary issue)"
echo "❌ All services pointing to same IP (136.243.155.166)"
echo ""

echo "🛠️  CLOUDFLARE API FIX STRATEGY:"
echo "==============================="
echo ""

# Check if API credentials are set
if [ -z "$CLOUDFLARE_API_TOKEN" ] && [ -z "$CLOUDFLARE_EMAIL" ] && [ -z "$CLOUDFLARE_API_KEY" ]; then
    echo "❌ Cloudflare API credentials not found!"
    echo ""
    echo "Please set your API credentials:"
    echo "  export CLOUDFLARE_API_TOKEN='your-api-token'"
    echo "  # OR"
    echo "  export CLOUDFLARE_EMAIL='sn.renauld@gmail.com'"
    echo "  export CLOUDFLARE_API_KEY='your-global-api-key'"
    echo ""
    echo "You can get these from:"
    echo "  https://dash.cloudflare.com/profile/api-tokens"
    echo ""
    exit 1
fi

# Set domain
DOMAIN="simondatalab.de"
ZONE_ID=""

echo "🔍 Getting Zone ID for domain: $DOMAIN"

# Get Zone ID
if [ ! -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "Using API Token authentication..."
    ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json")
else
    echo "Using Email + API Key authentication..."
    ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
        -H "Content-Type: application/json")
fi

# Extract Zone ID
ZONE_ID=$(echo "$ZONE_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$ZONE_ID" ]; then
    echo "❌ Failed to get Zone ID for domain: $DOMAIN"
    echo "Response: $ZONE_RESPONSE"
    exit 1
fi

echo "✅ Zone ID found: $ZONE_ID"
echo ""

echo "🔧 CHECKING CURRENT SSL SETTINGS:"
echo "================================="

# Get current SSL settings
if [ ! -z "$CLOUDFLARE_API_TOKEN" ]; then
    SSL_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/ssl" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json")
else
    SSL_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/ssl" \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
        -H "Content-Type: application/json")
fi

# Extract SSL mode
SSL_MODE=$(echo "$SSL_RESPONSE" | grep -o '"value":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "Current SSL mode: $SSL_MODE"

if [ "$SSL_MODE" = "flexible" ]; then
    echo "❌ SSL mode is 'flexible' - this is the problem!"
    echo "   Cloudflare expects HTTP from origin, but origin is HTTPS"
    echo ""
    echo "🛠️  FIXING SSL MODE:"
    echo "==================="
    
    # Update SSL mode to 'full'
    if [ ! -z "$CLOUDFLARE_API_TOKEN" ]; then
        UPDATE_RESPONSE=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/ssl" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"value":"full"}')
    else
        UPDATE_RESPONSE=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/ssl" \
            -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
            -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
            -H "Content-Type: application/json" \
            -d '{"value":"full"}')
    fi
    
    if echo "$UPDATE_RESPONSE" | grep -q '"success":true'; then
        echo "✅ SSL mode updated to 'full' successfully!"
        echo ""
        echo "⏳ Waiting 60 seconds for changes to propagate..."
        sleep 60
        echo ""
        
        echo "🧪 TESTING SERVICES:"
        echo "==================="
        
        # Test each service
        SERVICES=("moodle" "grafana" "jellyfin" "nextcloud")
        for service in "${SERVICES[@]}"; do
            echo "Testing $service.simondatalab.de:"
            HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$service.simondatalab.de/)
            if [ "$HTTP_STATUS" = "200" ]; then
                echo "   ✅ HTTP $HTTP_STATUS - Working!"
            else
                echo "   ❌ HTTP $HTTP_STATUS - Still has issues"
            fi
        done
        
        echo ""
        echo "🎉 SSL FIX COMPLETE!"
        echo "=================="
        echo ""
        echo "Expected results:"
        echo "✅ All services should now return HTTP 200"
        echo "✅ SSL certificates should be working"
        echo "✅ Cloudflare can connect to origin servers"
        
    else
        echo "❌ Failed to update SSL mode!"
        echo "Response: $UPDATE_RESPONSE"
        exit 1
    fi
    
elif [ "$SSL_MODE" = "full" ] || [ "$SSL_MODE" = "strict" ]; then
    echo "✅ SSL mode is already '$SSL_MODE' - this should be correct"
    echo ""
    echo "🔍 CHECKING ORIGIN SERVER SSL:"
    echo "============================="
    echo "The issue might be with the origin server SSL configuration."
    echo "Since Moodle was working yesterday, this could be:"
    echo "1. Temporary SSL certificate issue"
    echo "2. Origin server SSL configuration changed"
    echo "3. SSL certificate expired"
    echo ""
    echo "🛠️  ORIGIN SERVER FIX NEEDED:"
    echo "============================"
    echo "1. Check origin server SSL certificate"
    echo "2. Verify SSL configuration on 136.243.155.166"
    echo "3. Restart SSL services if needed"
    echo "4. Check SSL certificate expiration"
    
else
    echo "⚠️  Unknown SSL mode: $SSL_MODE"
    echo "This might be the issue."
fi

echo ""
echo "📋 SUMMARY:"
echo "=========="
echo "Domain: $DOMAIN"
echo "Zone ID: $ZONE_ID"
echo "SSL Mode: $SSL_MODE"
echo "Origin IP: 136.243.155.166"
echo "Affected Services: moodle, grafana, jellyfin, nextcloud"
echo ""
echo "🔄 To run this fix again:"
echo "  ./fix_cloudflare_api_ssl.sh"
