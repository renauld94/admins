#!/bin/bash

# Download real EPG data from iptv-org
API_KEY="f870ddf763334cfba15fb45b091b10a8"
SERVER="http://136.243.155.166:8096"

echo "📺 Downloading Real EPG Data from iptv-org..."
echo ""

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "📥 Downloading EPG files..."

# Download real EPG data from iptv-org GitHub
EPG_URLS=(
    "https://raw.githubusercontent.com/iptv-org/epg/master/sites/guidatv.sky.it/guidatv.sky.it.channels.xml"
    "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvguide.com/tvguide.com.channels.xml"
    "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tv.yandex.ru/tv.yandex.ru.channels.xml"
)

# Try the main EPG repository
echo "Downloading from iptv-org EPG repository..."
wget -q --timeout=30 "https://github.com/iptv-org/epg/releases/download/latest/guide.xml.gz" -O guide.xml.gz 2>/dev/null

if [ -f "guide.xml.gz" ] && [ -s "guide.xml.gz" ]; then
    echo "✅ Downloaded main EPG guide (compressed)"
    gunzip guide.xml.gz
    
    if [ -f "guide.xml" ] && [ -s "guide.xml" ]; then
        PROGRAM_COUNT=$(grep -c '<programme' guide.xml 2>/dev/null || echo "0")
        FILE_SIZE=$(du -h guide.xml | cut -f1)
        echo "   Size: $FILE_SIZE"
        echo "   Programs: $PROGRAM_COUNT"
        
        if [ "$PROGRAM_COUNT" -gt 100 ]; then
            echo ""
            echo "🚀 Uploading to Jellyfin container..."
            
            # Upload to VM
            scp -o ProxyJump=simonadmin@136.243.155.166:2222 guide.xml simonadmin@10.0.0.103:/tmp/epg_full.xml
            
            # Copy to container
            ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 "docker cp /tmp/epg_full.xml jellyfin-simonadmin:/config/epg_full.xml"
            
            # Set permissions
            ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin chmod 664 /config/epg_full.xml"
            
            echo "✅ EPG uploaded to: /config/epg_full.xml"
            echo ""
            echo "📋 Next Steps:"
            echo "1. Go to: http://136.243.155.166:8096/web/#/livetvguidedata.html"
            echo "2. Edit your XMLTV provider"
            echo "3. Change path to: /config/epg_full.xml"
            echo "4. Save and click 'Refresh Guide'"
            echo ""
            echo "🎬 This EPG contains $PROGRAM_COUNT programs!"
        else
            echo "❌ EPG file too small, not enough program data"
        fi
    fi
else
    echo "❌ Failed to download main EPG"
    echo ""
    echo "🔄 Trying alternative: XMLTV EPG sources..."
    
    # Try xmltv.se
    echo "Downloading from xmltv.se..."
    wget -q --timeout=30 "http://xmltv.xmltv.se/guide.xml.gz" -O xmltv_se.xml.gz 2>/dev/null
    
    if [ -f "xmltv_se.xml.gz" ] && [ -s "xmltv_se.xml.gz" ]; then
        gunzip xmltv_se.xml.gz
        PROGRAM_COUNT=$(grep -c '<programme' xmltv_se.xml 2>/dev/null || echo "0")
        echo "✅ Downloaded from xmltv.se ($PROGRAM_COUNT programs)"
        
        # Upload
        scp -o ProxyJump=simonadmin@136.243.155.166:2222 xmltv_se.xml simonadmin@10.0.0.103:/tmp/epg_full.xml
        ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 "docker cp /tmp/epg_full.xml jellyfin-simonadmin:/config/epg_full.xml"
        ssh -J simonadmin@136.243.155.166:2222 simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin chmod 664 /config/epg_full.xml"
        
        echo "✅ EPG uploaded!"
    else
        echo "❌ All EPG sources failed"
        echo ""
        echo "💡 Alternative Solution:"
        echo "   You can use Jellyfin's built-in 'Schedules Direct' EPG provider"
        echo "   (requires free account at schedulesdirect.org)"
    fi
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "Done!"
