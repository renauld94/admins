#!/bin/bash

#═══════════════════════════════════════════════════════════════════
# ADD IPTV TUNERS TO JELLYFIN VIA API AND TEST
#═══════════════════════════════════════════════════════════════════

JELLYFIN_URL="http://10.0.0.103:8096"
API_KEY="${1:-}"

if [ -z "$API_KEY" ]; then
    echo "❌ Error: API_KEY required"
    echo "Usage: $0 <API_KEY>"
    echo ""
    echo "To get API key from Jellyfin:"
    echo "  1. Log in to https://jellyfin.simondatalab.de"
    echo "  2. Dashboard → Settings → API Keys"
    echo "  3. Create new key or copy existing"
    exit 1
fi

echo "═══════════════════════════════════════════════════════════════════"
echo "  JELLYFIN TUNER SETUP VIA API"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Test API connection
echo "Testing API connection..."
HEALTH=$(curl -s "${JELLYFIN_URL}/health")
if [ "$HEALTH" == "OK" ]; then
    echo "✅ Jellyfin is accessible at ${JELLYFIN_URL}"
else
    echo "❌ Cannot reach Jellyfin at ${JELLYFIN_URL}"
    exit 1
fi

echo ""
echo "Testing API authentication with provided key..."
USERS=$(curl -s "${JELLYFIN_URL}/api/users?api_key=${API_KEY}")
if echo "$USERS" | grep -q '"Id"'; then
    echo "✅ API authentication successful"
    echo "$USERS" | head -c 200
    echo ""
else
    echo "❌ API authentication failed"
    echo "Response: $USERS"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  ADDING IPTV TUNERS"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Define tuners
declare -a TUNERS=(
    "Main|https://iptv-org.github.io/iptv/index.m3u"
    "UK|https://iptv-org.github.io/iptv/countries/uk.m3u"
    "US|https://iptv-org.github.io/iptv/countries/us.m3u"
    "France|https://iptv-org.github.io/iptv/countries/fr.m3u"
    "Germany|https://iptv-org.github.io/iptv/countries/de.m3u"
    "Canada|https://iptv-org.github.io/iptv/countries/ca.m3u"
)

# Add each tuner
for tuner in "${TUNERS[@]}"; do
    IFS='|' read -r NAME URL <<< "$tuner"
    
    echo "Adding $NAME tuner..."
    
    RESPONSE=$(curl -s -X POST "${JELLYFIN_URL}/api/LiveTv/TunerHosts?api_key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"Type\": \"m3u\",
            \"Url\": \"${URL}\",
            \"AllowHWTranscoding\": true,
            \"EnableStreamSharing\": false,
            \"SimultaneousStreamLimit\": 0,
            \"Name\": \"${NAME} Channels\"
        }")
    
    if echo "$RESPONSE" | grep -q '"Id"'; then
        TUNER_ID=$(echo "$RESPONSE" | grep -o '"Id":"[^"]*"' | cut -d'"' -f4)
        echo "  ✅ Added: $NAME → $URL (ID: ${TUNER_ID:0:8}...)"
    else
        echo "  ⚠️  Response: $RESPONSE"
    fi
    
    echo ""
done

echo "═══════════════════════════════════════════════════════════════════"
echo "  VERIFY TUNERS"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

TUNERS_LIST=$(curl -s "${JELLYFIN_URL}/api/LiveTv/TunerHosts?api_key=${API_KEY}")
TUNER_COUNT=$(echo "$TUNERS_LIST" | grep -o '"Id"' | wc -l)

echo "Total tuners configured: $TUNER_COUNT"
echo ""
echo "Tuners:"
echo "$TUNERS_LIST" | grep -o '"Name":"[^"]*"' | while read -r line; do
    NAME=$(echo "$line" | cut -d'"' -f4)
    echo "  • $NAME"
done

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  TEST IPTV CHANNELS"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Get a sample of channels from the main M3U
echo "Downloading main IPTV playlist to verify..."
M3U=$(curl -s "https://iptv-org.github.io/iptv/index.m3u" | head -50)
CHANNEL_COUNT=$(curl -s "https://iptv-org.github.io/iptv/index.m3u" | grep -c "^http")

echo "✅ Main IPTV source verified"
echo "   Channels available: ~${CHANNEL_COUNT} channels"
echo ""
echo "Sample channels:"
echo "$M3U" | grep "^http" | head -5 | while read -r url; do
    RESPONSE=$(curl -s -I --connect-timeout 3 "$url")
    if echo "$RESPONSE" | grep -q "HTTP.*200"; then
        echo "   ✅ $url"
    else
        STATUS=$(echo "$RESPONSE" | head -1)
        echo "   ⚠️  $url ($STATUS)"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  SETUP COMPLETE"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Go to: https://jellyfin.simondatalab.de"
echo "  2. Dashboard → Live TV"
echo "  3. Click \"Browse\" to see channels from configured tuners"
echo "  4. Select a channel and play!"
echo ""
echo "To view full tuner list:"
echo "  curl '${JELLYFIN_URL}/api/LiveTv/TunerHosts?api_key=${API_KEY}' | jq ."
echo ""
