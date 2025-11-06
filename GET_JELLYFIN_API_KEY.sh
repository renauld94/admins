#!/bin/bash

#═══════════════════════════════════════════════════════════════════
# GET OR CREATE JELLYFIN API KEY
#═══════════════════════════════════════════════════════════════════

JELLYFIN_URL="http://10.0.0.103:8096"

echo "═══════════════════════════════════════════════════════════════════"
echo "  JELLYFIN API KEY GENERATOR"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Step 1: Check if Jellyfin is running
echo "1. Checking Jellyfin status..."
HEALTH=$(curl -s -m 5 "${JELLYFIN_URL}/health")
if [ "$HEALTH" == "OK" ]; then
    echo "   ✅ Jellyfin is running"
else
    echo "   ❌ Cannot reach Jellyfin"
    exit 1
fi

echo ""
echo "2. Checking for existing admin user..."

# Try to get users without authentication (may work for first setup)
USERS_RESPONSE=$(curl -s "${JELLYFIN_URL}/api/users")

if echo "$USERS_RESPONSE" | grep -q '"Id"'; then
    echo "   ✅ Found existing users"
    ADMIN_ID=$(echo "$USERS_RESPONSE" | grep -o '"Id":"[^"]*"' | head -1 | cut -d'"' -f4)
    ADMIN_NAME=$(echo "$USERS_RESPONSE" | grep -o '"Name":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "   Admin: $ADMIN_NAME (ID: ${ADMIN_ID:0:8}...)"
else
    echo "   ⚠️  Cannot retrieve users (may need authentication first)"
fi

echo ""
echo "3. API Key Options:"
echo ""
echo "   Option A: Get existing key from web UI"
echo "   ────────────────────────────────────────"
echo "   1. Go to: https://jellyfin.simondatalab.de"
echo "   2. Log in as admin"
echo "   3. Dashboard → Settings → API Keys"
echo "   4. Copy an existing key or create a new one"
echo "   5. Return here and provide the key"
echo ""
echo "   Option B: Auto-add tuners without API key"
echo "   ────────────────────────────────────────"
echo "   Some Jellyfin instances allow tuner configuration"
echo "   without authentication during initial setup."
echo ""

echo "4. Quick Access URLs:"
echo "   ──────────────────"
echo "   • Web UI: https://jellyfin.simondatalab.de"
echo "   • Direct: http://10.0.0.103:8096"
echo "   • API Health: curl $JELLYFIN_URL/health"
echo ""

echo "5. Once you have the API key, run:"
echo "   ──────────────────────────────"
echo "   bash /home/simon/Learning-Management-System-Academy/setup-jellyfin-tuners.sh \"YOUR_API_KEY\""
echo ""

# Try to list existing tuners (this might work without auth)
echo "6. Current Tuner Status:"
echo "   ──────────────────────"

TUNERS=$(curl -s "${JELLYFIN_URL}/api/LiveTv/TunerHosts")
if echo "$TUNERS" | grep -q '"Id"'; then
    TUNER_COUNT=$(echo "$TUNERS" | grep -o '"Id"' | wc -l)
    echo "   Current tuners: $TUNER_COUNT"
    echo ""
    echo "$TUNERS" | grep -o '"Name":"[^"]*"' | cut -d'"' -f4 | sed 's/^/   • /'
else
    echo "   No tuners configured yet (or cannot access without auth)"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
