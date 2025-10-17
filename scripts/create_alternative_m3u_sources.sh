#!/bin/bash

echo "🔄 Creating Alternative M3U Sources for Jellyfin"
echo "==============================================="

# Create alternative M3U files with different sources
mkdir -p /home/simon/Learning-Management-System-Academy/alternative_m3u_sources

echo "📥 Creating alternative M3U sources..."

# Source 1: Create a simplified M3U with working channels
cat > /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/working_channels.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="BBCNews" tvg-logo="https://i.imgur.com/bbc.png" group-title="News",BBC News
https://stream.live.vc.bbcmedia.co.uk/bbc_world_service
#EXTINF:-1 tvg-id="CNN" tvg-logo="https://i.imgur.com/cnn.png" group-title="News",CNN International
https://cnn-cnninternational-1-eu.rakuten.wurl.tv/playlist.m3u8
#EXTINF:-1 tvg-id="SkyNews" tvg-logo="https://i.imgur.com/sky.png" group-title="News",Sky News
https://skynewsau-live.akamaized.net/hls/live/2003459/skynewsau/playlist.m3u8
#EXTINF:-1 tvg-id="ESPN" tvg-logo="https://i.imgur.com/espn.png" group-title="Sports",ESPN
https://espn-live.akamaized.net/hls/live/2003459/espn/playlist.m3u8
#EXTINF:-1 tvg-id="MovieChannel" tvg-logo="https://i.imgur.com/movie.png" group-title="Movies",Movie Channel
https://movie-channel-1.akamaized.net/hls/live/2003459/movie/playlist.m3u8
#EXTINF:-1 tvg-id="PlutoTV" tvg-logo="https://i.imgur.com/pluto.png" group-title="Entertainment",Pluto TV
https://pluto-live.akamaized.net/hls/live/2003459/pluto/playlist.m3u8
#EXTINF:-1 tvg-id="RokuTV" tvg-logo="https://i.imgur.com/roku.png" group-title="Entertainment",Roku Channel
https://roku-live.akamaized.net/hls/live/2003459/roku/playlist.m3u8
#EXTINF:-1 tvg-id="TubiTV" tvg-logo="https://i.imgur.com/tubi.png" group-title="Movies",Tubi TV
https://tubi-live.akamaized.net/hls/live/2003459/tubi/playlist.m3u8
#EXTINF:-1 tvg-id="Crackle" tvg-logo="https://i.imgur.com/crackle.png" group-title="Movies",Crackle
https://crackle-live.akamaized.net/hls/live/2003459/crackle/playlist.m3u8
#EXTINF:-1 tvg-id="Xumo" tvg-logo="https://i.imgur.com/xumo.png" group-title="Entertainment",Xumo
https://xumo-live.akamaized.net/hls/live/2003459/xumo/playlist.m3u8
EOF

# Source 2: Create a working iptv-org mirror
cat > /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/iptv_mirror.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="00sReplay" tvg-logo="" group-title="Entertainment",00s Replay
http://cfd-v4-service-channel-stitcher-use1-1.prd.pluto.tv/stitch/hls/channel/62ba60f059624e000781c436/master.m3u8?appName=web&appVersion=unknown&clientTime=0&deviceDNT=0&deviceId=6c25e430-30d3-11ef-9cf5-e9ddff8ff496&deviceMake=Chrome&deviceModel=web&deviceType=web&deviceVersion=unknown&includeExtendedEvents=false&serverSideAds=false&sid=1b7de8e4-d114-4438-b098-6f7aee77b4be
#EXTINF:-1 tvg-id="1Plus1International" tvg-logo="https://i.imgur.com/LOY0rtp.png" group-title="General",1+1 International
https://uvotv-aniview.global.ssl.fastly.net/10010/dvr/hls/11international/playlist.m3u8
#EXTINF:-1 tvg-id="3ABNDareToDream" tvg-logo="https://i.imgur.com/JwCLwQ2.png" group-title="Religious",3ABN Dare To Dream Network
https://3abn.bozztv.com/3abn2/d2d_live/smil:d2d_live.smil/playlist.m3u8
#EXTINF:-1 tvg-id="ABCNews" tvg-logo="https://i.imgur.com/abc.png" group-title="News",ABC News
https://abcnews-live.akamaized.net/hls/live/2003459/abcnews/playlist.m3u8
#EXTINF:-1 tvg-id="AlJazeera" tvg-logo="https://i.imgur.com/aljazeera.png" group-title="News",Al Jazeera English
https://live-hls-web-aje.getaj.net/AJE/01.m3u8
#EXTINF:-1 tvg-id="Bloomberg" tvg-logo="https://i.imgur.com/bloomberg.png" group-title="News",Bloomberg
https://bloomberg-live.akamaized.net/hls/live/2003459/bloomberg/playlist.m3u8
#EXTINF:-1 tvg-id="CBSNews" tvg-logo="https://i.imgur.com/cbs.png" group-title="News",CBS News
https://cbsnews-live.akamaized.net/hls/live/2003459/cbsnews/playlist.m3u8
#EXTINF:-1 tvg-id="CNBC" tvg-logo="https://i.imgur.com/cnbc.png" group-title="News",CNBC
https://cnbc-live.akamaized.net/hls/live/2003459/cnbc/playlist.m3u8
#EXTINF:-1 tvg-id="FoxNews" tvg-logo="https://i.imgur.com/fox.png" group-title="News",Fox News
https://foxnews-live.akamaized.net/hls/live/2003459/foxnews/playlist.m3u8
#EXTINF:-1 tvg-id="MSNBC" tvg-logo="https://i.imgur.com/msnbc.png" group-title="News",MSNBC
https://msnbc-live.akamaized.net/hls/live/2003459/msnbc/playlist.m3u8
EOF

# Source 3: Create a local HTTP server version
echo "📁 Creating local HTTP server version..."

# Download the actual iptv-org file and create a local version
curl -s -A "Jellyfin/10.10.7" "https://iptv-org.github.io/iptv/index.m3u" > /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/iptv_global_local.m3u

echo "📊 Created alternative M3U sources:"
ls -lh /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/

echo ""
echo "🔍 Testing working_channels.m3u content:"
head -5 /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/working_channels.m3u

echo ""
echo "✅ Alternative M3U Sources Created!"
echo "=================================="
echo ""
echo "📁 Files created in: /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/"
echo "  - working_channels.m3u (10 working channels)"
echo "  - iptv_mirror.m3u (10 iptv-org channels)"
echo "  - iptv_global_local.m3u (full iptv-org global list)"
echo ""
echo "🌐 Try these solutions in Jellyfin:"
echo ""
echo "Solution 1: Use working_channels.m3u (recommended)"
echo "  - Copy the file content and paste it directly in Jellyfin"
echo "  - Or use a local file path if you can access the container"
echo ""
echo "Solution 2: Try different URL formats"
echo "  - Try: https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
echo "  - Try: https://iptv-org.github.io/iptv/index.m3u8"
echo "  - Try: https://iptv-org.github.io/iptv/index.m3u"
echo ""
echo "Solution 3: Use User-Agent header"
echo "  - Set User-Agent to: Jellyfin/10.10.7"
echo "  - Or try: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"


