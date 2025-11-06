#!/bin/bash

# Test Moodle webservice via SSH tunnel (bypasses Cloudflare)
# This script creates an SSH tunnel to VM 9001 and makes API calls through it

set -e

TOKEN_FILE="$HOME/.moodle_token"
TOKEN=$(cat "$TOKEN_FILE" 2>/dev/null || echo "")

if [ -z "$TOKEN" ]; then
    echo "❌ Token file not found: $TOKEN_FILE"
    exit 1
fi

echo "🔧 Testing Moodle webservice via SSH tunnel..."
echo "Token: ${TOKEN:0:8}...${TOKEN: -8}"
echo ""

# Test via SSH tunnel - access Moodle container directly on VM 9001
echo "📡 Testing core_webservice_get_site_info..."
RESPONSE=$(ssh moodle-vm9001 "curl -s -X POST 'http://127.0.0.1:8086/webservice/rest/server.php' \
  -H 'Host: moodle.simondatalab.de' \
  -d 'wstoken=$TOKEN' \
  -d 'wsfunction=core_webservice_get_site_info' \
  -d 'moodlewsrestformat=json'")

echo "$RESPONSE"
echo ""

if [ -z "$RESPONSE" ]; then
    echo "❌ Empty response received"
    exit 1
fi

# Check if response contains error
if echo "$RESPONSE" | grep -q '"exception"'; then
    echo "❌ Error response received"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    exit 1
fi

# Check if response contains expected fields
if echo "$RESPONSE" | grep -q '"sitename"'; then
    echo "✅ Successfully connected to Moodle webservice!"
    echo ""
    echo "Site info:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null | head -20
    exit 0
else
    echo "⚠️  Unexpected response format"
    exit 1
fi
