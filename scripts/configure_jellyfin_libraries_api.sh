#!/bin/bash

echo "📚 Configuring Jellyfin Media Libraries via API"
echo "=============================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "🔧 Creating media libraries..."

# Create Movies library
echo "Creating Movies library..."
MOVIES_RESPONSE=$(curl -s -X POST \
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
  "$JELLYFIN_URL/Library/VirtualFolders")

echo "Movies library response: $MOVIES_RESPONSE"

# Create TV Shows library
echo "Creating TV Shows library..."
TV_RESPONSE=$(curl -s -X POST \
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
  "$JELLYFIN_URL/Library/VirtualFolders")

echo "TV Shows library response: $TV_RESPONSE"

# Create Music library
echo "Creating Music library..."
MUSIC_RESPONSE=$(curl -s -X POST \
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
  "$JELLYFIN_URL/Library/VirtualFolders")

echo "Music library response: $MUSIC_RESPONSE"

# Create Books library
echo "Creating Books library..."
BOOKS_RESPONSE=$(curl -s -X POST \
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
  "$JELLYFIN_URL/Library/VirtualFolders")

echo "Books library response: $BOOKS_RESPONSE"

echo "🔄 Refreshing all libraries..."
REFRESH_RESPONSE=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  "$JELLYFIN_URL/Library/Refresh")

echo "Refresh response: $REFRESH_RESPONSE"

echo "📊 Checking current libraries..."
LIBRARIES=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/Library/VirtualFolders")
echo "Current libraries: $LIBRARIES"

echo ""
echo "✅ Media Libraries Configuration Complete!"
echo "========================================"
echo ""
echo "📚 Libraries created:"
echo "• Movies (/media/movies)"
echo "• TV Shows (/media/tvshows)"
echo "• Music (/media/music)"
echo "• Books (/media/books)"
echo ""
echo "🌐 Access Jellyfin: http://136.243.155.166:8096/web/"
echo "🔐 Login as: simonadmin"
echo "📺 You should now see the libraries in the main menu!"
echo ""
echo "📋 Next Steps:"
echo "1. Add media files to the library folders"
echo "2. Configure Live TV with the 2000+ free channels"
echo "3. Refresh libraries after adding content"
