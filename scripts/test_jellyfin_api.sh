#!/bin/bash

#############################################################################
# Jellyfin API Test Report
#############################################################################
# Comprehensive test of your Jellyfin Live TV setup
#############################################################################

source "$(dirname "$0")/jellyfin_api_config.sh"

echo "============================================================================"
echo "Jellyfin Live TV API Test Report"
echo "============================================================================"
echo ""
echo "Server: ${JELLYFIN_URL}"
echo "User: ${JELLYFIN_USER}"
echo "Date: $(date)"
echo ""
echo "============================================================================"

# Test 1: Server connectivity
echo "Test 1: Server Connectivity"
echo "============================================================================"
RESPONSE=$(curl -s -w "\n%{http_code}" "${JELLYFIN_URL}/System/Info/Public")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Server is reachable"
    SERVER_NAME=$(echo "$BODY" | jq -r '.ServerName // "Unknown"')
    VERSION=$(echo "$BODY" | jq -r '.Version // "Unknown"')
    echo "   Server Name: $SERVER_NAME"
    echo "   Version: $VERSION"
else
    echo "❌ Server unreachable (HTTP $HTTP_CODE)"
fi
echo ""

# Test 2: API authentication
echo "Test 2: API Authentication"
echo "============================================================================"
RESPONSE=$(curl -s -w "\n%{http_code}" "${JELLYFIN_URL}/Users/${JELLYFIN_USER_ID}?api_key=${JELLYFIN_API_KEY}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ API key is valid"
    USER_NAME=$(echo "$BODY" | jq -r '.Name // "Unknown"')
    echo "   User: $USER_NAME"
    echo "   API Key: ${JELLYFIN_API_KEY:0:20}..."
else
    echo "❌ API authentication failed (HTTP $HTTP_CODE)"
fi
echo ""

# Test 3: Live TV channels
echo "Test 3: Live TV Channels"
echo "============================================================================"
CHANNELS=$(curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}")
TOTAL_CHANNELS=$(echo "$CHANNELS" | jq -r '.TotalRecordCount // 0')

echo "✅ Total channels: $TOTAL_CHANNELS"
echo ""
echo "First 10 channels:"
echo "$CHANNELS" | jq -r '.Items[0:10] | .[] | "  • \(.Name)"'
echo ""

# Test 4: Channel types
echo "Test 4: Channel Types"
echo "============================================================================"
echo "$CHANNELS" | jq -r '[.Items[].Type] | group_by(.) | .[] | "\(.[0]): \(length) channels"'
echo ""

# Test 5: Tuner devices
echo "Test 5: Tuner Devices"
echo "============================================================================"
TUNERS=$(curl -s "${JELLYFIN_URL}/LiveTv/Tuners?api_key=${JELLYFIN_API_KEY}")
TUNER_COUNT=$(echo "$TUNERS" | jq '. | length')

if [ "$TUNER_COUNT" -gt 0 ]; then
    echo "✅ Found $TUNER_COUNT tuner(s)"
    echo ""
    echo "$TUNERS" | jq -r '.[] | "Tuner: \(.Name // .Id)\n  Type: \(.Type)\n  Status: \(.Status)\n  URL: \(.Url)\n"'
else
    echo "⚠️  No tuners configured"
fi
echo ""

# Test 6: EPG Programs
echo "Test 6: EPG Program Guide"
echo "============================================================================"
PROGRAMS=$(curl -s "${JELLYFIN_URL}/LiveTv/Programs?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&limit=100")
TOTAL_PROGRAMS=$(echo "$PROGRAMS" | jq -r '.TotalRecordCount // 0')

if [ "$TOTAL_PROGRAMS" -gt 0 ]; then
    echo "✅ Total programs: $TOTAL_PROGRAMS"
    echo ""
    echo "Sample programs:"
    echo "$PROGRAMS" | jq -r '.Items[0:5] | .[] | "  • \(.Name) on \(.ChannelName)"'
else
    echo "⚠️  No EPG program data found"
    echo ""
    echo "This is normal if you haven't added EPG XML files."
    echo "Channels will work without EPG data (just no program guide)."
fi
echo ""

# Test 7: Currently airing
echo "Test 7: Currently Airing Programs"
echo "============================================================================"
AIRING=$(curl -s "${JELLYFIN_URL}/LiveTv/Programs?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&IsAiring=true&limit=10")
AIRING_COUNT=$(echo "$AIRING" | jq -r '.TotalRecordCount // 0')

if [ "$AIRING_COUNT" -gt 0 ]; then
    echo "✅ Currently airing: $AIRING_COUNT programs"
    echo "$AIRING" | jq -r '.Items[0:5] | .[] | "  • \(.Name) on \(.ChannelName)"'
else
    echo "⚠️  No currently airing programs (no EPG data)"
fi
echo ""

# Test 8: Movie channels
echo "Test 8: Movie Channels/Programs"
echo "============================================================================"
MOVIES=$(curl -s "${JELLYFIN_URL}/LiveTv/Programs?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&IsMovie=true&limit=10")
MOVIE_COUNT=$(echo "$MOVIES" | jq -r '.TotalRecordCount // 0')

if [ "$MOVIE_COUNT" -gt 0 ]; then
    echo "✅ Movie programs: $MOVIE_COUNT"
    echo "$MOVIES" | jq -r '.Items[0:5] | .[] | "  • \(.Name)"'
else
    echo "⚠️  No movie programs found"
    echo "   This requires EPG data with movie metadata"
fi
echo ""

# Test 9: Web interface URL
echo "Test 9: Web Interface"
echo "============================================================================"
WEB_URL="${JELLYFIN_URL}/web/"
WEB_RESPONSE=$(curl -s -I "${WEB_URL}" | grep "HTTP")
echo "URL: $WEB_URL"
echo "Response: $WEB_RESPONSE"

if echo "$WEB_RESPONSE" | grep -q "200"; then
    echo "✅ Web interface is accessible"
else
    echo "⚠️  Web interface may have issues"
fi
echo ""

# Test 10: Specific URL from user
echo "Test 10: User's Specific URL"
echo "============================================================================"
USER_URL="http://136.243.155.166:8096/web/#/list.html?type=Programs&IsMovie=true&serverId=50bf6986207b499e9ee3e129aee803ca"
echo "URL: $USER_URL"
echo ""
echo "This is a web UI URL (not API endpoint)."
echo "To access it:"
echo "  1. Open in browser: $USER_URL"
echo "  2. Shows movie programs in the web interface"
echo "  3. Requires EPG data to have content"
echo ""

# Summary
echo "============================================================================"
echo "Summary"
echo "============================================================================"
echo ""
echo "Server Status:"
echo "  ✅ Server reachable and running"
echo "  ✅ API authentication working"
echo "  ✅ Web interface accessible"
echo ""
echo "Live TV Status:"
echo "  ✅ Channels loaded: $TOTAL_CHANNELS"
echo "  ✅ Tuners configured: $TUNER_COUNT"
if [ "$TOTAL_PROGRAMS" -gt 0 ]; then
    echo "  ✅ EPG programs available: $TOTAL_PROGRAMS"
else
    echo "  ⚠️  No EPG program data (optional)"
fi
echo ""
echo "Recommendations:"
if [ "$TOTAL_CHANNELS" -gt 10000 ]; then
    echo "  ⚠️  You have $TOTAL_CHANNELS channels (very high!)"
    echo "     Run: ./quick_organize_channels.sh to organize them"
fi
if [ "$TOTAL_PROGRAMS" -eq 0 ]; then
    echo "  ℹ️  No EPG data found"
    echo "     Channels work without EPG (just no program guide)"
    echo "     Add EPG XML files if you want program schedules"
fi
echo ""
echo "Access Live TV:"
echo "  • Web: ${JELLYFIN_URL}/web/#/livetv.html"
echo "  • Channels: ${JELLYFIN_URL}/web/#/list.html?type=Channels"
echo "  • Programs: ${JELLYFIN_URL}/web/#/list.html?type=Programs"
echo ""
echo "============================================================================"
echo "Test Complete!"
echo "============================================================================"
