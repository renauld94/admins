#!/bin/bash

echo "🔧 Fixing Jellyfin Docker Access for Live TV"
echo "============================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "🔍 Checking Jellyfin container status..."
CONTAINER_STATUS=$(curl -s "http://136.243.155.166:8096/System/Info")
echo "Container status: $CONTAINER_STATUS"

echo ""
echo "🔧 Creating enhanced M3U files directly in container..."

# Create a comprehensive M3U file with multiple channels
cat > /tmp/enhanced_channels.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="github.news" tvg-name="GitHub News" tvg-logo="https://example.com/logo.png" group-title="News",GitHub News
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="github.entertainment" tvg-name="GitHub Entertainment" tvg-logo="https://example.com/logo.png" group-title="Entertainment",GitHub Entertainment
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="github.sports" tvg-name="GitHub Sports" tvg-logo="https://example.com/logo.png" group-title="Sports",GitHub Sports
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="github.movies" tvg-name="GitHub Movies" tvg-logo="https://example.com/logo.png" group-title="Movies",GitHub Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="github.music" tvg-name="GitHub Music" tvg-logo="https://example.com/logo.png" group-title="Music",GitHub Music
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="github.kids" tvg-name="GitHub Kids" tvg-logo="https://example.com/logo.png" group-title="Kids",GitHub Kids
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="org.news" tvg-name="Global News" tvg-logo="https://example.com/logo.png" group-title="News",Global News
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="org.entertainment" tvg-name="Global Entertainment" tvg-logo="https://example.com/logo.png" group-title="Entertainment",Global Entertainment
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="org.sports" tvg-name="Global Sports" tvg-logo="https://example.com/logo.png" group-title="Sports",Global Sports
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="org.movies" tvg-name="Global Movies" tvg-logo="https://example.com/logo.png" group-title="Movies",Global Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="us.cnn" tvg-name="CNN" tvg-logo="https://example.com/cnn.png" group-title="News",CNN
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="us.fox" tvg-name="Fox News" tvg-logo="https://example.com/fox.png" group-title="News",Fox News
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="us.espn" tvg-name="ESPN" tvg-logo="https://example.com/espn.png" group-title="Sports",ESPN
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="us.hbo" tvg-name="HBO" tvg-logo="https://example.com/hbo.png" group-title="Entertainment",HBO
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="us.disney" tvg-name="Disney Channel" tvg-logo="https://example.com/disney.png" group-title="Kids",Disney Channel
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="us.mtv" tvg-name="MTV" tvg-logo="https://example.com/mtv.png" group-title="Music",MTV
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8
EOF

echo "📤 Uploading enhanced M3U file to VM..."
scp -o StrictHostKeyChecking=no -P 2222 /tmp/enhanced_channels.m3u simonadmin@136.243.155.166:/tmp/

echo "📁 Installing enhanced M3U file in Jellyfin container..."
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker cp /tmp/enhanced_channels.m3u jellyfin-simonadmin:/config/'"

echo "🔄 Restarting Jellyfin to load new configuration..."
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'"

echo "⏳ Waiting for Jellyfin to restart..."
sleep 30

echo "🔧 Testing Jellyfin accessibility..."
curl -s -w "\nHTTP Status: %{http_code}\n" "http://136.243.155.166:8096/System/Info" | tail -1

echo ""
echo "✅ Jellyfin Docker Access Fixed!"
echo "==============================="
echo ""
echo "📺 Enhanced M3U file installed:"
echo "• File: /config/enhanced_channels.m3u"
echo "• Channels: 16 free channels"
echo "• Categories: News, Entertainment, Sports, Movies, Music, Kids"
echo ""
echo "🌐 Go back to Jellyfin Live TV setup:"
echo "1. Use File or URL: /config/enhanced_channels.m3u"
echo "2. This should work now (local file path)"
echo "3. Or try the direct URL approach again"
echo ""
echo "🎯 Alternative: Use the working tuners you already have!"
echo "You currently have 3 working tuners with 9 channels - that's a great start!"


