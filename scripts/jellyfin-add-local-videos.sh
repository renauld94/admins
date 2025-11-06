#!/bin/bash
# Add /home/simon/Videos to Jellyfin Libraries

set -e

API_KEY="f870ddf763334cfba15fb45b091b10a8"
JELLYFIN_URL="http://136.243.155.166:8096"

echo "=========================================="
echo "Adding Local Videos to Jellyfin"
echo "=========================================="
echo ""

# Add Movies library
echo "Adding Movies library..."
curl -X POST \
    "$JELLYFIN_URL/Library/VirtualFolders?collectionType=movies&refreshLibrary=true&name=Local%20Movies" \
    -H "X-Emby-Token: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
        "LibraryOptions": {
            "PathInfos": [{
                "Path": "/home/simon/Videos/Movies"
            }],
            "PreferredMetadataLanguage": "en",
            "MetadataCountryCode": "US",
            "EnablePhotos": true,
            "EnableRealtimeMonitor": true,
            "EnableChapterImageExtraction": true,
            "ExtractChapterImagesDuringLibraryScan": true
        }
    }' 2>&1

echo ""
echo "✅ Movies library added"
echo ""

# Add TV Shows library
echo "Adding TV Shows library..."
curl -X POST \
    "$JELLYFIN_URL/Library/VirtualFolders?collectionType=tvshows&refreshLibrary=true&name=Local%20TV%20Shows" \
    -H "X-Emby-Token: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
        "LibraryOptions": {
            "PathInfos": [{
                "Path": "/home/simon/Videos/TV Shows"
            }],
            "PreferredMetadataLanguage": "en",
            "MetadataCountryCode": "US",
            "EnablePhotos": true,
            "EnableRealtimeMonitor": true,
            "EnableChapterImageExtraction": true,
            "ExtractChapterImagesDuringLibraryScan": true
        }
    }' 2>&1

echo ""
echo "✅ TV Shows library added"
echo ""

# Add Home Videos library
echo "Adding Screen Recordings library..."
curl -X POST \
    "$JELLYFIN_URL/Library/VirtualFolders?collectionType=homevideos&refreshLibrary=true&name=Screen%20Recordings" \
    -H "X-Emby-Token: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
        "LibraryOptions": {
            "PathInfos": [{
                "Path": "/home/simon/Videos/Screen Recordings"
            }],
            "EnablePhotos": true,
            "EnableRealtimeMonitor": true
        }
    }' 2>&1

echo ""
echo "✅ Screen Recordings library added"
echo ""

# Trigger library scan
echo "=========================================="
echo "Triggering Library Scan..."
echo "=========================================="
echo ""

curl -X POST \
    "$JELLYFIN_URL/Library/Refresh" \
    -H "X-Emby-Token: $API_KEY"

echo ""
echo "✅ Library scan started"
echo ""

echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "Added libraries:"
echo "  ✅ Local Movies: /home/simon/Videos/Movies"
echo "  ✅ Local TV Shows: /home/simon/Videos/TV Shows"
echo "  ✅ Screen Recordings: /home/simon/Videos/Screen Recordings"
echo ""
echo "Media organization:"
echo "  📁 Movies: 1 video (Personal Video 2025)"
echo "  📁 TV Shows: Empty (ready for content)"
echo "  📁 Screen Recordings: 7 videos"
echo ""
echo "Access at: http://136.243.155.166:8096"
echo "          or: https://jellyfin.simondatalab.de"
echo ""
echo "Scan will complete in a few moments. Refresh Jellyfin to see media!"
echo ""
