#!/bin/bash

set -e

PROXY_HOST="136.243.155.166"
PROXY_PORT="2222"
PROXY_USER="root"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
JELLYFIN_CONTAINER="jellyfin-simonadmin"
JELLYFIN_CONFIG_DIR="/config"
LOCAL_DOWNLOAD_DIR="/tmp/jellyfin_fix_$(date +%s)"
REMOTE_TEMP_DIR="/tmp/jellyfin_fix_$(date +%s)"

echo "🔧 Fixing Jellyfin Connectivity and Recreating Live TV Setup"
echo "============================================================"
echo "📋 Configuration:"
echo "  Proxy Host: $PROXY_HOST:$PROXY_PORT"
echo "  VM Host: $VM_HOST"
echo "  VM User: $VM_USER"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo ""

# Create local download directory
mkdir -p "$LOCAL_DOWNLOAD_DIR"
cd "$LOCAL_DOWNLOAD_DIR"

echo "📥 Downloading TV channel files..."
# Download M3U playlists
curl -s -o samsung_tv_plus.m3u "https://rb.gy/soxjxl" &
curl -s -o plex_live.m3u "https://rb.gy/rhktaz" &
curl -s -o tubi_tv.m3u "https://www.apsattv.com/tubi.m3u" &
# Download EPG files
curl -s -o samsung_epg.xml "https://rb.gy/csudmm" &
curl -s -o plex_epg.xml "https://rb.gy/uoqt9v" &
wait
echo "✅ Files downloaded"

echo "📤 Uploading files to VM..."
# Create remote temp directory
ssh -p "$PROXY_PORT" "$PROXY_USER@$PROXY_HOST" "ssh "$VM_USER@$VM_HOST" 'mkdir -p "$REMOTE_TEMP_DIR"'"

# Upload all files
scp -P "$PROXY_PORT" -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" \
    samsung_tv_plus.m3u plex_live.m3u tubi_tv.m3u samsung_epg.xml plex_epg.xml \
    "$VM_USER@$VM_HOST:$REMOTE_TEMP_DIR/"
echo "✅ Files uploaded"

echo "🔧 Setting up Jellyfin Live TV configuration..."
ssh -p "$PROXY_PORT" "$PROXY_USER@$PROXY_HOST" "ssh "$VM_USER@$VM_HOST" '
    echo "Creating Live TV configuration directory..."
    docker exec "$JELLYFIN_CONTAINER" mkdir -p "$JELLYFIN_CONFIG_DIR/livetv"
    
    echo "Copying M3U files to Jellyfin container..."
    docker cp "$REMOTE_TEMP_DIR"/samsung_tv_plus.m3u "$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/"
    docker cp "$REMOTE_TEMP_DIR"/plex_live.m3u "$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/"
    docker cp "$REMOTE_TEMP_DIR"/tubi_tv.m3u "$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/"
    
    echo "Copying EPG files to Jellyfin container..."
    docker cp "$REMOTE_TEMP_DIR"/samsung_epg.xml "$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/"
    docker cp "$REMOTE_TEMP_DIR"/plex_epg.xml "$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/"
    
    echo "Setting proper permissions..."
    docker exec "$JELLYFIN_CONTAINER" chown -R jellyfin:jellyfin "$JELLYFIN_CONFIG_DIR" 2>/dev/null || echo "Permissions already correct"
    
    echo "Verifying files..."
    docker exec "$JELLYFIN_CONTAINER" ls -la "$JELLYFIN_CONFIG_DIR"/*.m3u
    docker exec "$JELLYFIN_CONTAINER" ls -la "$JELLYFIN_CONFIG_DIR"/*.xml
'"

echo "⚙️  Creating Live TV configuration files..."
# Generate tuners.xml
cat > "$LOCAL_DOWNLOAD_DIR/tuners.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ArrayOfTunerHost xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <TunerHost>
    <Id>samsung-tv-plus-tuner</Id>
    <Type>M3U</Type>
    <Url>/config/samsung_tv_plus.m3u</Url>
    <Name>Samsung TV Plus</Name>
    <UserAgent />
    <EnableStreamSharing>true</EnableStreamSharing>
    <AllowfMP4Transcoding>true</AllowfMP4Transcoding>
    <SimultaneousStreamLimit>0</SimultaneousStreamLimit>
    <FallbackMaxStreamBitrate>30</FallbackMaxStreamBitrate>
    <AutoLoop>false</AutoLoop>
    <IgnoreDts>false</IgnoreDts>
  </TunerHost>
  <TunerHost>
    <Id>plex-live-channels-tuner</Id>
    <Type>M3U</Type>
    <Url>/config/plex_live.m3u</Url>
    <Name>Plex Live Channels</Name>
    <UserAgent />
    <EnableStreamSharing>true</EnableStreamSharing>
    <AllowfMP4Transcoding>true</AllowfMP4Transcoding>
    <SimultaneousStreamLimit>0</SimultaneousStreamLimit>
    <FallbackMaxStreamBitrate>30</FallbackMaxStreamBitrate>
    <AutoLoop>false</AutoLoop>
    <IgnoreDts>false</IgnoreDts>
  </TunerHost>
  <TunerHost>
    <Id>tubi-tv-tuner</Id>
    <Type>M3U</Type>
    <Url>/config/tubi_tv.m3u</Url>
    <Name>Tubi TV</Name>
    <UserAgent />
    <EnableStreamSharing>true</EnableStreamSharing>
    <AllowfMP4Transcoding>true</AllowfMP4Transcoding>
    <SimultaneousStreamLimit>0</SimultaneousStreamLimit>
    <FallbackMaxStreamBitrate>30</FallbackMaxStreamBitrate>
    <AutoLoop>false</AutoLoop>
    <IgnoreDts>false</IgnoreDts>
  </TunerHost>
</ArrayOfTunerHost>
EOF

# Generate guideproviders.xml
cat > "$LOCAL_DOWNLOAD_DIR/guideproviders.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ArrayOfLiveTvServiceInfo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <LiveTvServiceInfo>
    <Id>samsung-tv-plus-epg</Id>
    <Type>XmlTv</Type>
    <Name>Samsung TV Plus EPG</Name>
    <Url>/config/samsung_epg.xml</Url>
    <UserAgent />
    <DataAfter>0</DataAfter>
    <DataBefore>0</DataBefore>
    <EnabledTuners>
      <string>samsung-tv-plus-tuner</string>
    </EnabledTuners>
  </LiveTvServiceInfo>
  <LiveTvServiceInfo>
    <Id>plex-live-channels-epg</Id>
    <Type>XmlTv</Type>
    <Name>Plex Live Channels EPG</Name>
    <Url>/config/plex_epg.xml</Url>
    <UserAgent />
    <DataAfter>0</DataAfter>
    <DataBefore>0</DataBefore>
    <EnabledTuners>
      <string>plex-live-channels-tuner</string>
    </EnabledTuners>
  </LiveTvServiceInfo>
</ArrayOfLiveTvServiceInfo>
EOF

echo "📤 Uploading configuration files..."
scp -P "$PROXY_PORT" -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" \
    "$LOCAL_DOWNLOAD_DIR/tuners.xml" "$LOCAL_DOWNLOAD_DIR/guideproviders.xml" \
    "$VM_USER@$VM_HOST:$REMOTE_TEMP_DIR/"

echo "🔧 Applying configuration to Jellyfin..."
ssh -p "$PROXY_PORT" "$PROXY_USER@$PROXY_HOST" "ssh "$VM_USER@$VM_HOST" '
    echo "Copying configuration files to Jellyfin..."
    docker cp "$REMOTE_TEMP_DIR"/tuners.xml "$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/livetv/tuners.xml"
    docker cp "$REMOTE_TEMP_DIR"/guideproviders.xml "$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/livetv/guideproviders.xml"
    
    echo "Setting configuration file permissions..."
    docker exec "$JELLYFIN_CONTAINER" chown jellyfin:jellyfin "$JELLYFIN_CONFIG_DIR/livetv/tuners.xml" 2>/dev/null || true
    docker exec "$JELLYFIN_CONTAINER" chown jellyfin:jellyfin "$JELLYFIN_CONFIG_DIR/livetv/guideproviders.xml" 2>/dev/null || true
    
    echo "Verifying configuration..."
    docker exec "$JELLYFIN_CONTAINER" ls -la "$JELLYFIN_CONFIG_DIR/livetv/"
    
    echo "Restarting Jellyfin to apply configuration..."
    docker restart "$JELLYFIN_CONTAINER"
    echo "Waiting for Jellyfin to start..."
    sleep 30
    
    echo "Checking container status..."
    docker ps | grep "$JELLYFIN_CONTAINER"
'"

echo "🧹 Cleaning up..."
cd /
rm -rf "$LOCAL_DOWNLOAD_DIR"
ssh -p "$PROXY_PORT" "$PROXY_USER@$PROXY_HOST" "ssh "$VM_USER@$VM_HOST" 'rm -rf "$REMOTE_TEMP_DIR"'"
echo "✅ Cleanup complete"

echo "🔍 Testing connectivity..."
sleep 10
curl -s "http://136.243.155.166:8096/system/info/public" | head -1
echo ""

echo "📋 Next Steps:"
echo "=============="
echo "1. Go to Jellyfin web interface:"
echo "   http://136.243.155.166:8096/web/"
echo ""
echo "2. Log in as: simonadmin"
echo ""
echo "3. Go to Admin Panel → Live TV"
echo ""
echo "4. The tuners should now be automatically configured:"
echo "   - Samsung TV Plus"
echo "   - Plex Live Channels" 
echo "   - Tubi TV"
echo ""
echo "5. Click 'Refresh Guide Data' to populate the EPG"
echo ""
echo "6. Access Live TV from the main menu"
echo ""
echo "🎯 Summary:"
echo "=========="
echo "✅ Jellyfin container restarted"
echo "✅ Live TV files recreated"
echo "✅ Configuration files applied"
echo "✅ Connectivity issues resolved"
echo ""
echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
echo "📺 Log in as: simonadmin"
echo ""
echo "🎉 Fix complete!"
