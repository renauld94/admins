#!/bin/bash
# Test Moodle Webservice Connection
# This script tests various aspects of the Moodle webservice configuration

MOODLE_URL="https://moodle.simondatalab.de"
WEBSERVICE_ENDPOINT="${MOODLE_URL}/webservice/rest/server.php"

echo "========================================================================"
echo "  MOODLE WEBSERVICE CONNECTION TEST"
echo "========================================================================"
echo ""
echo "Testing connection to: $MOODLE_URL"
echo ""

# Test 1: Basic connectivity
echo "Test 1: Basic Moodle Site Connectivity"
echo "----------------------------------------"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$MOODLE_URL")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "✓ Site is reachable (HTTP $HTTP_CODE)"
else
    echo "✗ Site is not reachable (HTTP $HTTP_CODE)"
fi
echo ""

# Test 2: Webservice endpoint exists
echo "Test 2: Webservice Endpoint Accessibility"
echo "----------------------------------------"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$WEBSERVICE_ENDPOINT")
echo "Response code: HTTP $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Webservice endpoint is accessible"
elif [ "$HTTP_CODE" = "404" ]; then
    echo "✗ Webservice endpoint not found (404)"
    echo "  Web services may not be enabled in Moodle"
else
    echo "⚠ Unexpected response code"
fi
echo ""

# Test 3: Test with invalid token (should return error in JSON)
echo "Test 3: Webservice Response Format"
echo "----------------------------------------"
RESPONSE=$(curl -s --max-time 10 -X POST "$WEBSERVICE_ENDPOINT" \
    -d "wstoken=invalid_test_token" \
    -d "wsfunction=core_webservice_get_site_info" \
    -d "moodlewsrestformat=json")

if [ -z "$RESPONSE" ]; then
    echo "✗ Empty response received"
    echo "  This usually means:"
    echo "  1. Web services are not enabled in Moodle"
    echo "  2. REST protocol is not enabled"
    echo "  3. The endpoint URL is incorrect"
else
    echo "✓ Received response:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
fi
echo ""

# Test 4: Check if token file exists
echo "Test 4: Token Configuration"
echo "----------------------------------------"
TOKEN_FILE="$HOME/.moodle_token"
if [ -f "$TOKEN_FILE" ]; then
    echo "✓ Token file exists: $TOKEN_FILE"
    TOKEN=$(cat "$TOKEN_FILE")
    if [ -n "$TOKEN" ]; then
        echo "✓ Token is set (length: ${#TOKEN} characters)"
        
        # Test with real token
        echo ""
        echo "Testing with your configured token..."
        RESPONSE=$(curl -s --max-time 10 -X POST "$WEBSERVICE_ENDPOINT" \
            -d "wstoken=$TOKEN" \
            -d "wsfunction=core_webservice_get_site_info" \
            -d "moodlewsrestformat=json")
        
        if [ -z "$RESPONSE" ]; then
            echo "✗ Empty response with configured token"
        else
            echo "Response:"
            echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
        fi
    else
        echo "✗ Token file is empty"
    fi
else
    echo "⚠ No token file found at: $TOKEN_FILE"
    echo "  Run ./setup_moodle_webservices.sh to configure"
fi
echo ""

# Summary
echo "========================================================================"
echo "  NEXT STEPS"
echo "========================================================================"
echo ""
echo "If web services are not working:"
echo ""
echo "1. Enable web services in Moodle:"
echo "   $MOODLE_URL/admin/search.php?query=enablewebservices"
echo ""
echo "2. Enable REST protocol:"
echo "   $MOODLE_URL/admin/settings.php?section=webserviceprotocols"
echo ""
echo "3. Create and configure a web service:"
echo "   Run: ./setup_moodle_webservices.sh"
echo ""
echo "4. Or manually configure at:"
echo "   $MOODLE_URL/admin/settings.php?section=externalservices"
echo ""
