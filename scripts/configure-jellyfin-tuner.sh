#!/bin/bash

#
# Jellyfin M3U Tuner Configuration Script
# Configures the M3U tuner for organized IPTV channels via Jellyfin API
#

set -e

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="415b13e6a3044c938ce15f72a0bb1a47"
M3U_FILE="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-organized-channels.m3u"
TUNER_NAME="Jellyfin Organized Channels"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Jellyfin M3U Tuner Configuration Tool${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Verify Jellyfin is running
echo -e "${YELLOW}[1/5]${NC} Checking Jellyfin server connectivity..."
if curl -s -f "$JELLYFIN_URL/System/Info/Public" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Jellyfin is online at $JELLYFIN_URL"
else
    echo -e "${RED}✗${NC} Cannot connect to Jellyfin at $JELLYFIN_URL"
    echo "    Make sure Jellyfin is running and accessible"
    exit 1
fi

# Step 2: Verify M3U file exists
echo ""
echo -e "${YELLOW}[2/5]${NC} Verifying M3U file..."
if [ -f "$M3U_FILE" ]; then
    CHANNEL_COUNT=$(grep -c "^#EXTINF:" "$M3U_FILE" || echo "0")
    FILE_SIZE=$(ls -lh "$M3U_FILE" | awk '{print $5}')
    echo -e "${GREEN}✓${NC} M3U file found: $M3U_FILE"
    echo "    File size: $FILE_SIZE | Channels: $CHANNEL_COUNT"
else
    echo -e "${RED}✗${NC} M3U file not found: $M3U_FILE"
    exit 1
fi

# Step 3: Get existing tuners
echo ""
echo -e "${YELLOW}[3/5]${NC} Fetching existing tuners..."
TUNERS=$(curl -s -X GET "$JELLYFIN_URL/LiveTv/TunerHosts" \
    -H "X-Api-Key: $API_KEY" \
    -H "Content-Type: application/json")

TUNER_COUNT=$(echo "$TUNERS" | grep -o '"Type":"' | wc -l || echo "0")
echo -e "${GREEN}✓${NC} Found $TUNER_COUNT existing tuner(s)"

# Step 4: Check if tuner already exists
echo ""
echo -e "${YELLOW}[4/5]${NC} Checking for existing M3U tuner..."
EXISTING_TUNER=$(echo "$TUNERS" | grep -o "\"Type\":\"m3u\"" || echo "")

if [ -n "$EXISTING_TUNER" ]; then
    echo -e "${YELLOW}⚠${NC}  M3U tuner already configured"
    echo "    You can manage it in: Jellyfin → Settings → Live TV → Tuners"
else
    echo -e "${GREEN}✓${NC} No M3U tuner found - will create new one"
fi

# Step 5: Create/Update M3U Tuner
echo ""
echo -e "${YELLOW}[5/5]${NC} Adding M3U Tuner configuration..."

# API payload for M3U tuner
PAYLOAD=$(cat <<EOF
{
    "Type": "m3u",
    "Name": "$TUNER_NAME",
    "Url": "file://$M3U_FILE",
    "AllowHWTranscoding": true,
    "AllowStreamSharing": true,
    "FallbackFallbackMaxStreamBitrate": 30,
    "TunerCount": 0,
    "IgnoreDts": false,
    "EnableFFMpegTranscodingContainer": true,
    "AutomaticFFMpegStreamCopy": true
}
EOF
)

# Send API request
RESPONSE=$(curl -s -X POST "$JELLYFIN_URL/LiveTv/TunerHosts" \
    -H "X-Api-Key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>&1)

# Check if successful
if echo "$RESPONSE" | grep -q "Type" || [ -z "$(echo "$RESPONSE" | grep -i error)" ]; then
    echo -e "${GREEN}✓${NC} Tuner configuration added successfully!"
    echo "    Name: $TUNER_NAME"
    echo "    File: $M3U_FILE"
else
    echo -e "${YELLOW}⚠${NC}  Response: $RESPONSE"
fi

# Final instructions
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Configuration Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "📺 Next Steps:"
echo "   1. Open Jellyfin at: $JELLYFIN_URL"
echo "   2. Go to: Settings → Live TV → Tuners"
echo "   3. Verify your tuner is listed"
echo "   4. Go to: Live TV → Guide"
echo "   5. Wait 30-60 seconds for channels to populate"
echo ""
echo "📊 Channel Stats:"
echo "   Total Channels: $CHANNEL_COUNT"
echo "   Categories: 9 (News, Sports, Entertainment, Movies, Music, Kids, Religious, Documentary, General)"
echo ""
echo "🔍 View Channels:"
echo "   Command: grep -o 'group-title=\"[^\"]*\"' \"$M3U_FILE\" | sort | uniq"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
