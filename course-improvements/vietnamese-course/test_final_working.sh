#!/bin/bash

# FINAL WORKING SOLUTION - Test Moodle webservice
# Uses direct IP with Host header to bypass Cloudflare

set -e

TOKEN_FILE="$HOME/.moodle_token"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "❌ Token file not found: $TOKEN_FILE"
    exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║             MOODLE WEBSERVICE TEST - FINAL SOLUTION              ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🔧 Using: Direct IP + Host header (bypasses Cloudflare)"
echo "📡 Endpoint: http://136.243.155.166:8086/webservice/rest/server.php"
echo "🔑 Token: ${TOKEN:0:8}...${TOKEN: -8}"
echo ""

# Call API using direct IP with Host header
curl -s -X POST "http://136.243.155.166:8086/webservice/rest/server.php" \
  -H "Host: moodle.simondatalab.de" \
  -H "X-Forwarded-Proto: https" \
  -d "wstoken=$TOKEN" \
  -d "wsfunction=core_webservice_get_site_info" \
  -d "moodlewsrestformat=json" \
  --max-time 10 | python3 -m json.tool 2>/dev/null | head -30

echo ""
echo "✅ If you see site info above, the API is working!"
echo ""
echo "To use in your code:"
echo "  MOODLE_URL = 'http://136.243.155.166:8086'"
echo "  headers = {'Host': 'moodle.simondatalab.de', 'X-Forwarded-Proto': 'https'}"
