#!/bin/bash

# Create a working M3U + EPG combo for Jellyfin
# This uses freely available streaming services that have EPG data

echo "🎬 Creating M3U Playlist with EPG for Jellyfin"
echo "=============================================="
echo ""

# Create output directory
OUTPUT_DIR="/tmp/jellyfin_iptv_epg"
mkdir -p "$OUTPUT_DIR"

echo "📺 Option 1: Use Plex IPTV (Free channels with EPG)"
echo "-----------------------------------------------"
echo "Plex offers free ad-supported channels with EPG data"
echo ""
echo "M3U URL: https://i.mjh.nz/Plex/all.m3u"
echo "EPG URL: https://i.mjh.nz/Plex/all.xml"
echo ""

# Test Plex
PLEX_M3U_STATUS=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "https://i.mjh.nz/Plex/all.m3u" 2>/dev/null)
PLEX_EPG_STATUS=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "https://i.mjh.nz/Plex/all.xml" 2>/dev/null)

if [ "$PLEX_M3U_STATUS" = "200" ] && [ "$PLEX_EPG_STATUS" = "200" ]; then
    echo "✅ Plex IPTV is WORKING!"
    echo ""
    curl -s "https://i.mjh.nz/Plex/all.m3u" -o "$OUTPUT_DIR/plex_channels.m3u"
    curl -s "https://i.mjh.nz/Plex/all.xml" -o "$OUTPUT_DIR/plex_epg.xml"
    
    CHANNELS=$(grep -c "^#EXTINF" "$OUTPUT_DIR/plex_channels.m3u")
    PROGRAMS=$(grep -c '<programme' "$OUTPUT_DIR/plex_epg.xml")
    
    echo "   📊 Channels: $CHANNELS"
    echo "   📋 Programs: $PROGRAMS"
    echo ""
    echo "   ✅ RECOMMENDED: Use Plex IPTV"
    echo ""
else
    echo "❌ Plex IPTV not available (HTTP M3U:$PLEX_M3U_STATUS, EPG:$PLEX_EPG_STATUS)"
    echo ""
fi

echo "📺 Option 2: Use Stirr (Free US streaming TV)"
echo "--------------------------------------------"
STIRR_M3U="https://i.mjh.nz/Stirr/all.m3u"
STIRR_EPG="https://i.mjh.nz/Stirr/all.xml"

STIRR_M3U_STATUS=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "$STIRR_M3U" 2>/dev/null)
STIRR_EPG_STATUS=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "$STIRR_EPG" 2>/dev/null)

if [ "$STIRR_M3U_STATUS" = "200" ] && [ "$STIRR_EPG_STATUS" = "200" ]; then
    echo "✅ Stirr is WORKING!"
    curl -s "$STIRR_M3U" -o "$OUTPUT_DIR/stirr_channels.m3u"
    curl -s "$STIRR_EPG" -o "$OUTPUT_DIR/stirr_epg.xml"
    
    CHANNELS=$(grep -c "^#EXTINF" "$OUTPUT_DIR/stirr_channels.m3u")
    PROGRAMS=$(grep -c '<programme' "$OUTPUT_DIR/stirr_epg.xml")
    
    echo "   📊 Channels: $CHANNELS"
    echo "   📋 Programs: $PROGRAMS"
    echo ""
else
    echo "❌ Stirr not available"
    echo ""
fi

echo "📺 Option 3: GitHub IPTV Community (iptv-org)"
echo "--------------------------------------------"
echo "Using iptv-org's free worldwide channels"
echo ""

# Download iptv-org playlist
IPTV_ORG_M3U="https://iptv-org.github.io/iptv/index.m3u"
curl -s "$IPTV_ORG_M3U" -o "$OUTPUT_DIR/iptv_org.m3u"

CHANNELS=$(grep -c "^#EXTINF" "$OUTPUT_DIR/iptv_org.m3u")
echo "   📊 Channels: $CHANNELS"
echo "   ⚠️  EPG: Limited (channels have tvg-id but no unified EPG)"
echo ""

echo "=============================================="
echo "📋 Summary:"
echo "=============================================="
echo ""

if [ -f "$OUTPUT_DIR/plex_channels.m3u" ]; then
    echo "✅ BEST OPTION: Plex IPTV"
    echo "   Channels: $(grep -c "^#EXTINF" "$OUTPUT_DIR/plex_channels.m3u")"
    echo "   Programs: $(grep -c '<programme' "$OUTPUT_DIR/plex_epg.xml")"
    echo ""
    echo "   📝 To use in Jellyfin:"
    echo "   1. Upload files to Jellyfin:"
    
    # Upload to VM
    echo "      Uploading to server..."
    scp -o ProxyJump=simonadmin@136.243.155.166:2222 "$OUTPUT_DIR/plex_channels.m3u" simonadmin@10.0.0.103:/tmp/
    scp -o ProxyJump=simonadmin@136.243.155.166:2222 "$OUTPUT_DIR/plex_epg.xml" simonadmin@10.0.0.103:/tmp/
    
    ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 "docker cp /tmp/plex_channels.m3u jellyfin-simonadmin:/config/data/plex_channels.m3u"
    ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 "docker cp /tmp/plex_epg.xml jellyfin-simonadmin:/config/plex_epg.xml"
    
    echo "      ✅ Files uploaded!"
    echo ""
    echo "   2. Add M3U Tuner in Jellyfin:"
    echo "      - Go to: Dashboard → Live TV → Tuner Devices"
    echo "      - Click '+' → Select 'M3U Tuner'"
    echo "      - File or URL: /config/data/plex_channels.m3u"
    echo "      - Save"
    echo ""
    echo "   3. Add XMLTV EPG in Jellyfin:"
    echo "      - Go to: Dashboard → Live TV → TV Guide Data Providers"
    echo "      - Click '+' → Select 'XMLTV'"
    echo "      - Path: /config/plex_epg.xml"
    echo "      - UNCHECK 'Download images'"
    echo "      - Check 'Enable for all tuner devices'"
    echo "      - Save"
    echo "      - Click 'Refresh Guide'"
    echo ""
    echo "   4. Wait 2-3 minutes, then check:"
    echo "      http://136.243.155.166:8096/web/#/list.html?type=Programs&IsMovie=true"
    echo ""
elif [ -f "$OUTPUT_DIR/stirr_channels.m3u" ]; then
    echo "✅ Use Stirr IPTV"
    echo "   (Same instructions as Plex, but use stirr_channels.m3u and stirr_epg.xml)"
    echo ""
else
    echo "⚠️  Only iptv-org available (no comprehensive EPG)"
    echo "   Consider using Schedules Direct: https://www.schedulesdirect.org/"
    echo ""
fi

echo "Files saved to: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
