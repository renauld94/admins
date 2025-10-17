#!/bin/bash

echo "📚 Setting up Jellyfin Media Libraries"
echo "======================================"

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
CONTAINER_NAME="jellyfin-simonadmin"
API_KEY="f870ddf763334cfba15fb45b091b10a8"
JELLYFIN_URL="http://136.243.155.166:8096"

echo "🔧 Creating media directories on VM..."

# Create media directories via SSH
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'sudo mkdir -p /media/movies /media/tvshows /media/music /media/books'"

echo "📁 Creating sample media content..."

# Create sample movie files
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'cat > /media/movies/sample_movie.txt << EOF
# Sample Movie Collection
This directory contains your movie files.

To add movies:
1. Copy movie files to /media/movies/
2. Use proper naming: Movie Name (Year).ext
3. Refresh library in Jellyfin

Supported formats: MP4, MKV, AVI, MOV, etc.
EOF'"

# Create sample TV show structure
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'mkdir -p /media/tvshows/Sample\ Show/Season\ 01'"

ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'cat > /media/tvshows/Sample\ Show/Season\ 01/README.txt << EOF
# Sample TV Show Structure
This is how to organize your TV shows:

/media/tvshows/
├── Show Name/
│   ├── Season 01/
│   │   ├── Show Name - S01E01 - Episode Title.mp4
│   │   └── Show Name - S01E02 - Episode Title.mp4
│   └── Season 02/
│       └── Show Name - S02E01 - Episode Title.mp4

Use this structure for best results.
EOF'"

echo "🔧 Configuring Jellyfin libraries via API..."

# Create Movies library
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
  "$JELLYFIN_URL/Library/VirtualFolders"

# Create TV Shows library
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
  "$JELLYFIN_URL/Library/VirtualFolders"

# Create Music library
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
  "$JELLYFIN_URL/Library/VirtualFolders"

echo "🔄 Refreshing libraries..."

# Refresh all libraries
curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  "$JELLYFIN_URL/Library/Refresh"

echo "✅ Media library setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Go to: http://136.243.155.166:8096/web/"
echo "2. Login as: simonadmin"
echo "3. Go to Admin Panel → Libraries"
echo "4. Verify libraries are created"
echo "5. Add your media files to:"
echo "   - /media/movies (for movies)"
echo "   - /media/tvshows (for TV shows)"
echo "   - /media/music (for music)"
echo "6. Refresh libraries after adding content"


