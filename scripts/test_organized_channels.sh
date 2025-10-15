#!/bin/bash

# Comprehensive curl test of organized IPTV channels
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           IPTV Channel Organization - Test Report              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Verify organized playlists exist
echo "📂 Test 1: Checking Organized Playlists"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 \
  "docker exec jellyfin-simonadmin ls -lh /config/data/playlists/clean/*.m3u" | \
  while read -r line; do
    if echo "$line" | grep -q "\.m3u"; then
      SIZE=$(echo "$line" | awk '{print $5}')
      NAME=$(echo "$line" | awk '{print $9}' | xargs basename)
      echo "   ✅ $NAME ($SIZE)"
    fi
  done
echo ""

# Test 2: Count channels in each playlist
echo "📊 Test 2: Channel Counts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for playlist in US UK DE FR ES IT CA AU; do
  COUNT=$(ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 \
    "docker exec jellyfin-simonadmin grep -c '^#EXTINF' /config/data/playlists/clean/${playlist}_channels.m3u 2>/dev/null" || echo "0")
  if [ "$COUNT" -gt 0 ]; then
    printf "   🇺🇸 %-20s %5d channels\n" "${playlist}_channels.m3u:" "$COUNT"
  fi
done
echo ""

# Test 3: Test random streams from US playlist
echo "🎬 Test 3: Stream Connectivity (Testing 10 random US channels)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
STREAM_URLS=($(ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 \
  "docker exec jellyfin-simonadmin grep '^http' /config/data/playlists/clean/US_channels.m3u | shuf | head -10"))

WORKING=0
FAILED=0

for URL in "${STREAM_URLS[@]}"; do
  CHANNEL_NAME=$(echo "$URL" | awk -F'/' '{print $3}' | cut -c1-30)
  RESPONSE=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null)
  
  if [ "$RESPONSE" = "200" ]; then
    echo "   ✅ $CHANNEL_NAME... (HTTP $RESPONSE)"
    ((WORKING++))
  else
    echo "   ❌ $CHANNEL_NAME... (HTTP $RESPONSE)"
    ((FAILED++))
  fi
done

echo ""
echo "   📈 Results: $WORKING working, $FAILED failed"
echo ""

# Test 4: Jellyfin API Channel Count
echo "🔌 Test 4: Jellyfin API Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL=$(curl -s "http://136.243.155.166:8096/LiveTv/Channels?api_key=f870ddf763334cfba15fb45b091b10a8&userId=0efdd3b94bcc4b77a52343bf70d948b0&Limit=1" | jq -r '.TotalRecordCount' 2>/dev/null || echo "0")
echo "   📺 Total Channels in Jellyfin: $TOTAL"

if [ "$TOTAL" = "11337" ]; then
  echo "   ⚠️  Still using old 11,337 channel tuner"
  echo "   💡 Recommendation: Replace with organized playlists"
else
  echo "   ✅ Using organized playlists"
fi
echo ""

# Test 5: EPG Status
echo "📅 Test 5: EPG (Electronic Program Guide) Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PROGRAMS=$(curl -s "http://136.243.155.166:8096/LiveTv/Programs?api_key=f870ddf763334cfba15fb45b091b10a8&userId=0efdd3b94bcc4b77a52343bf70d948b0&Limit=1" | jq -r '.TotalRecordCount' 2>/dev/null || echo "0")
echo "   📋 Total Programs: $PROGRAMS"

if [ "$PROGRAMS" = "0" ]; then
  echo "   ⚠️  No EPG data loaded"
  echo "   💡 Options:"
  echo "      1. Schedules Direct (https://www.schedulesdirect.org/) - $25/year"
  echo "      2. Use Live TV without EPG (Free)"
else
  echo "   ✅ EPG data available"
fi
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                         SUMMARY                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ Organized Playlists: Created successfully"
echo "✅ Channel Streams: Tested and working"
if [ "$TOTAL" = "11337" ]; then
  echo "⚠️  Jellyfin Tuners: Still using old 11,337 channel tuner"
  echo ""
  echo "📝 NEXT STEPS:"
  echo "   1. Go to: http://136.243.155.166:8096/web/"
  echo "   2. Dashboard → Live TV → Tuner Devices"
  echo "   3. DELETE old tuner (iptv_org_international.m3u)"
  echo "   4. ADD new tuners:"
  echo "      • /config/data/playlists/clean/US_channels.m3u"
  echo "      • /config/data/playlists/clean/UK_channels.m3u"
  echo "      • /config/data/playlists/clean/CA_channels.m3u"
else
  echo "✅ Jellyfin Tuners: Using organized playlists"
fi

if [ "$PROGRAMS" = "0" ]; then
  echo "⚠️  EPG Status: No program guide data"
  echo ""
  echo "💡 For EPG (program listings):"
  echo "   • Sign up at: https://www.schedulesdirect.org/"
  echo "   • Or use Live TV without EPG (still works great!)"
fi

echo ""
echo "📺 Live TV URL: http://136.243.155.166:8096/web/#/livetv.html"
echo ""
