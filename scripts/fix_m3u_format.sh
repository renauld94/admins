#!/bin/bash

echo "🔧 Fixing M3U Format for Jellyfin Live TV Setup"
echo "=============================================="

echo "📋 The issue: M3U content needs proper line breaks"
echo "Current format (all on one line):"
echo "#EXTM3U #EXTINF:-1 tvg-id=\"AlJazeera\" tvg-logo=\"https://i.imgur.com/aljazeera.png\" group-title=\"News\",Al Jazeera English https://live-hls-web-aje.getaj.net/AJE/01.m3u8 #EXTINF:-1 tvg-id=\"Bloomberg\"..."

echo ""
echo "✅ Correct format (with line breaks):"
echo ""

# Create properly formatted M3U content
cat > /tmp/properly_formatted.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="AlJazeera" tvg-logo="https://i.imgur.com/aljazeera.png" group-title="News",Al Jazeera English
https://live-hls-web-aje.getaj.net/AJE/01.m3u8
#EXTINF:-1 tvg-id="Bloomberg" tvg-logo="https://i.imgur.com/bloomberg.png" group-title="News",Bloomberg
https://bloomberg-live.akamaized.net/hls/live/2003459/bloomberg/playlist.m3u8
#EXTINF:-1 tvg-id="DW" tvg-logo="https://i.imgur.com/dw.png" group-title="News",DW English
https://dwamdstream102.akamaized.net/hls/live/2015525/dwstream102/index.m3u8
#EXTINF:-1 tvg-id="RT" tvg-logo="https://i.imgur.com/rt.png" group-title="News",RT News
https://rt-glb.rttv.com/live/rtnews/playlist.m3u8
#EXTINF:-1 tvg-id="CGTN" tvg-logo="https://i.imgur.com/cgtn.png" group-title="News",CGTN English
https://live.cgtn.com/1000e/prog_index.m3u8
#EXTINF:-1 tvg-id="NHK" tvg-logo="https://i.imgur.com/nhk.png" group-title="News",NHK World
https://nhkworld.webcdn.stream.ne.jp/www11/nhkworld/tv/global/2003458/live.m3u8
#EXTINF:-1 tvg-id="Arirang" tvg-logo="https://i.imgur.com/arirang.png" group-title="News",Arirang TV
https://amdlive.ctnd.com.edgesuite.net/arirang_1ch/smil:arirang_1ch.smil/playlist.m3u8
#EXTINF:-1 tvg-id="TRT" tvg-logo="https://i.imgur.com/trt.png" group-title="News",TRT World
https://trtcanlive.akamaized.net/hls/live/2014070/TRTWORLD/index.m3u8
#EXTINF:-1 tvg-id="Euronews" tvg-logo="https://i.imgur.com/euronews.png" group-title="News",Euronews
https://rakuten-euronews-1-eu.rakuten.wurl.tv/playlist.m3u8
EOF

echo "📁 Properly formatted M3U content:"
cat /tmp/properly_formatted.m3u

echo ""
echo "🔧 How to fix this in Jellyfin:"
echo "=============================="
echo ""
echo "Method 1: Copy and paste the properly formatted content above"
echo "Method 2: Use a direct URL instead (recommended)"
echo ""
echo "🚀 RECOMMENDED SOLUTION: Use Direct URL"
echo "======================================"
echo ""
echo "Instead of pasting the M3U content, use this direct URL:"
echo "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
echo ""
echo "This will give you 1000+ channels and is much more reliable!"
echo ""
echo "📋 Step-by-step instructions:"
echo "1. Clear the 'File or URL' field"
echo "2. Paste this URL: https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
echo "3. Set User-Agent to: Jellyfin/10.10.7"
echo "4. Set other options as you have them"
echo "5. Click Save"
echo ""
echo "💡 Why this works better:"
echo "- No formatting issues"
echo "- Always gets latest channel list"
echo "- No need to manage M3U content manually"
echo "- More reliable than pasting content"


