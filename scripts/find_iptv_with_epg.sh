#!/bin/bash

# Search for M3U playlists with EPG data
echo "🔍 Searching for M3U playlists with EPG data..."
echo ""

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# List of popular IPTV providers with EPG
declare -A PLAYLISTS=(
    ["Free-TV (M3U4U)"]="https://m3u4u.com/m3u/yn1yq7qr0r9wdv7z6z1h"
    ["IPTV.cat"]="https://iptv.cat/lists/global.m3u"
    ["Kodi Nerds"]="https://kodiapps.com/builds/iptv/kodi-best-live-tv.m3u"
    ["Free IPTV"]="https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
    ["Pluto TV US"]="https://i.mjh.nz/PlutoTV/all.m3u8"
    ["Samsung TV Plus US"]="https://i.mjh.nz/SamsungTVPlus/all.m3u8"
)

# Test each playlist
for name in "${!PLAYLISTS[@]}"; do
    url="${PLAYLISTS[$name]}"
    echo "📺 Testing: $name"
    echo "   URL: $url"
    
    # Download first 50 lines
    HEADER=$(timeout 10 curl -s "$url" 2>/dev/null | head -50)
    
    if [ -n "$HEADER" ]; then
        # Check for EPG URL in header
        EPG_URL=$(echo "$HEADER" | grep -i "x-tvg-url\|url-tvg" | head -1)
        
        if [ -n "$EPG_URL" ]; then
            echo "   ✅ EPG Found: $EPG_URL"
        else
            echo "   ⚠️  No EPG URL in header"
        fi
        
        # Count channels
        CHANNEL_COUNT=$(echo "$HEADER" | grep -c "^#EXTINF")
        echo "   Channels (in first 50 lines): $CHANNEL_COUNT"
    else
        echo "   ❌ Failed to download"
    fi
    echo ""
done

# Now let's try the Matt Huisman curated lists (these often have EPG)
echo "🎯 Testing Matt Huisman's curated IPTV lists (with EPG)..."
echo ""

MJH_LISTS=(
    "PlutoTV:https://i.mjh.nz/PlutoTV/us.m3u8:https://i.mjh.nz/PlutoTV/epg.xml.gz"
    "SamsungTVPlus:https://i.mjh.nz/SamsungTVPlus/us.m3u8:https://i.mjh.nz/SamsungTVPlus/epg.xml.gz"
    "PearTV:https://i.mjh.nz/Pear/us.m3u8:https://i.mjh.nz/Pear/epg.xml.gz"
    "Stirr:https://i.mjh.nz/Stirr/all.m3u8:https://i.mjh.nz/Stirr/epg.xml.gz"
)

for entry in "${MJH_LISTS[@]}"; do
    IFS=':' read -r name m3u_url epg_url <<< "$entry"
    
    echo "📺 $name"
    echo "   M3U: $m3u_url"
    echo "   EPG: $epg_url"
    
    # Test M3U
    M3U_STATUS=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "$m3u_url" 2>/dev/null)
    EPG_STATUS=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "$epg_url" 2>/dev/null)
    
    if [ "$M3U_STATUS" = "200" ]; then
        CHANNELS=$(timeout 5 curl -s "$m3u_url" 2>/dev/null | grep -c "^#EXTINF")
        echo "   ✅ M3U Working ($CHANNELS channels)"
    else
        echo "   ❌ M3U Failed (HTTP $M3U_STATUS)"
    fi
    
    if [ "$EPG_STATUS" = "200" ]; then
        echo "   ✅ EPG Working"
        echo ""
        echo "   🎬 RECOMMENDED: Use this one!"
        echo "   ---"
        echo "   Add to Jellyfin:"
        echo "   1. M3U Tuner URL: $m3u_url"
        echo "   2. XMLTV EPG URL: $epg_url"
        echo "   ---"
    else
        echo "   ❌ EPG Failed (HTTP $EPG_STATUS)"
    fi
    echo ""
done

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "✅ Search complete!"
echo ""
echo "💡 Recommendation: Use one of the Matt Huisman (i.mjh.nz) lists above"
echo "   They have both M3U playlists AND EPG guides that work together"
