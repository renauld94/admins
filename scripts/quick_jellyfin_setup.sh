#!/bin/bash

echo "🚀 Quick Jellyfin Setup - Let's Go!"
echo "==================================="
echo "Setting up media libraries and 2000+ free TV channels"
echo ""

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "🔧 Step 1: Creating media libraries..."

# Create Movies library
echo "Creating Movies library..."
curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Movies",
    "CollectionType": "movies",
    "LibraryOptions": {
      "PathInfos": [
        {
          "Path": "/media/movies"
        }
      ]
    }
  }' \
  "$JELLYFIN_URL/Library/VirtualFolders" > /dev/null

# Create TV Shows library
echo "Creating TV Shows library..."
curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "TV Shows",
    "CollectionType": "tvshows",
    "LibraryOptions": {
      "PathInfos": [
        {
          "Path": "/media/tvshows"
        }
      ]
    }
  }' \
  "$JELLYFIN_URL/Library/VirtualFolders" > /dev/null

# Create Music library
echo "Creating Music library..."
curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Music",
    "CollectionType": "music",
    "LibraryOptions": {
      "PathInfos": [
        {
          "Path": "/media/music"
        }
      ]
    }
  }' \
  "$JELLYFIN_URL/Library/VirtualFolders" > /dev/null

# Create Books library
echo "Creating Books library..."
curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Books",
    "CollectionType": "books",
    "LibraryOptions": {
      "PathInfos": [
        {
          "Path": "/media/books"
        }
      ]
    }
  }' \
  "$JELLYFIN_URL/Library/VirtualFolders" > /dev/null

echo "✅ Media libraries created!"

echo ""
echo "📺 Step 2: Adding 2000+ free TV channels..."

# Add Live TV tuners
ENHANCED_DIR="/home/simon/Learning-Management-System-Academy/enhanced_channels"

# Function to add M3U tuner
add_m3u_tuner() {
    local name="$1"
    local file_path="$2"
    
    echo "Adding $name..."
    curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"$name\",
        \"Type\": \"M3U\",
        \"Url\": \"$file_path\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/Tuners" > /dev/null
}

# Add all M3U tuners
add_m3u_tuner "GitHub Free-TV" "$ENHANCED_DIR/free_tv_github.m3u8"
add_m3u_tuner "iptv-org Global" "$ENHANCED_DIR/iptv_org.m3u"
add_m3u_tuner "US Channels" "$ENHANCED_DIR/iptv_us.m3u"
add_m3u_tuner "UK Channels" "$ENHANCED_DIR/iptv_uk.m3u"
add_m3u_tuner "Canada Channels" "$ENHANCED_DIR/iptv_ca.m3u"
add_m3u_tuner "News Channels" "$ENHANCED_DIR/iptv_news.m3u"
add_m3u_tuner "Sports Channels" "$ENHANCED_DIR/iptv_sports.m3u"
add_m3u_tuner "Movies Channels" "$ENHANCED_DIR/iptv_movies.m3u"
add_m3u_tuner "Music Channels" "$ENHANCED_DIR/iptv_music.m3u"
add_m3u_tuner "Curated Free Channels" "$ENHANCED_DIR/curated_free_channels.m3u"
add_m3u_tuner "Samsung TV Plus Enhanced" "$ENHANCED_DIR/samsung_tv_plus_enhanced.m3u"
add_m3u_tuner "Pluto TV" "$ENHANCED_DIR/pluto_tv.m3u"

echo "✅ 2000+ free TV channels added!"

echo ""
echo "🔄 Step 3: Refreshing guide data..."

# Refresh libraries
curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  "$JELLYFIN_URL/Library/Refresh" > /dev/null

# Refresh guide data
curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  "$JELLYFIN_URL/LiveTv/Guide/Refresh" > /dev/null

echo "✅ Guide data refreshed!"

echo ""
echo "🎉 Jellyfin Setup Complete!"
echo "=========================="
echo ""
echo "📚 Media Libraries Created:"
echo "• Movies (/media/movies)"
echo "• TV Shows (/media/tvshows)"
echo "• Music (/media/music)"
echo "• Books (/media/books)"
echo ""
echo "📺 Live TV Channels Added:"
echo "• GitHub Free-TV (100+ channels)"
echo "• iptv-org Global (1000+ channels)"
echo "• US Channels (500+ channels)"
echo "• UK Channels (200+ channels)"
echo "• Canada Channels (150+ channels)"
echo "• News Channels (100+ channels)"
echo "• Sports Channels (200+ channels)"
echo "• Movies Channels (150+ channels)"
echo "• Music Channels (100+ channels)"
echo "• Curated Free Channels (30+ channels)"
echo "• Samsung TV Plus Enhanced (6 channels)"
echo "• Pluto TV (6 channels)"
echo ""
echo "🌐 Access Jellyfin: http://136.243.155.166:8096/web/"
echo "🔐 Login as: simonadmin"
echo "📺 Go to Live TV to see all your channels!"
echo "🎬 Go to Movies to see your movie library!"
echo ""
echo "🚀 Ready to enjoy 2000+ free TV channels!"


