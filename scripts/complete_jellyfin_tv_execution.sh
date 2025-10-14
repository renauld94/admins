#!/bin/bash

# Complete Jellyfin TV Channels Execution via ProxyJump
# This script ensures files are uploaded and configuration is executed

set -e

echo "📺 Complete Jellyfin TV Channels Execution via ProxyJump"
echo "======================================================="

# Configuration
PROXY_HOST="136.243.155.166"
PROXY_PORT="2222"
PROXY_USER="root"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
JELLYFIN_CONTAINER="jellyfin-simonadmin"

# Local directories
LOCAL_DOWNLOAD_DIR="/tmp/jellyfin_tv_download"

echo "📋 Configuration:"
echo "  Proxy Host: $PROXY_HOST:$PROXY_PORT"
echo "  VM Host: $VM_HOST"
echo "  VM User: $VM_USER"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo ""

# Function to ensure files are uploaded
ensure_files_uploaded() {
    echo "📥 Ensuring TV channel files are uploaded..."
    
    # Create local download directory
    mkdir -p "$LOCAL_DOWNLOAD_DIR"
    cd "$LOCAL_DOWNLOAD_DIR"
    
    # Download files if they don't exist
    if [ ! -f "samsung_tv_plus.m3u" ]; then
        echo "Downloading Samsung TV Plus M3U..."
        curl -o samsung_tv_plus.m3u "https://rb.gy/soxjxl"
    fi
    
    if [ ! -f "plex_live.m3u" ]; then
        echo "Downloading Plex Live Channels M3U..."
        curl -o plex_live.m3u "https://rb.gy/rhktaz"
    fi
    
    if [ ! -f "tubi_tv.m3u" ]; then
        echo "Downloading Tubi TV M3U..."
        curl -o tubi_tv.m3u "https://www.apsattv.com/tubi.m3u"
    fi
    
    if [ ! -f "samsung_epg.xml" ]; then
        echo "Downloading Samsung TV Plus EPG..."
        curl -o samsung_epg.xml "https://rb.gy/csudmm"
    fi
    
    if [ ! -f "plex_epg.xml" ]; then
        echo "Downloading Plex Live Channels EPG..."
        curl -o plex_epg.xml "https://rb.gy/uoqt9v"
    fi
    
    # Upload files to VM
    echo "📤 Uploading files to VM..."
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST "mkdir -p /tmp/jellyfin_tv_setup"
    
    scp -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" *.m3u *.xml $VM_USER@$VM_HOST:/tmp/jellyfin_tv_setup/
    
    echo "✅ Files uploaded to VM"
    echo ""
}

# Function to copy files to Jellyfin container
copy_files_to_container() {
    echo "📁 Copying files to Jellyfin container..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Copying files to Jellyfin container..."
        
        TEMP_DIR="/tmp/jellyfin_tv_setup"
        CONTAINER_NAME="jellyfin-simonadmin"
        CONFIG_DIR="/config"
        
        # Copy M3U files
        docker cp "$TEMP_DIR/samsung_tv_plus.m3u" "$CONTAINER_NAME:$CONFIG_DIR/"
        docker cp "$TEMP_DIR/plex_live.m3u" "$CONTAINER_NAME:$CONFIG_DIR/"
        docker cp "$TEMP_DIR/tubi_tv.m3u" "$CONTAINER_NAME:$CONFIG_DIR/"
        
        # Copy EPG files
        docker cp "$TEMP_DIR/samsung_epg.xml" "$CONTAINER_NAME:$CONFIG_DIR/"
        docker cp "$TEMP_DIR/plex_epg.xml" "$CONTAINER_NAME:$CONFIG_DIR/"
        
        # Set permissions
        docker exec "$CONTAINER_NAME" chown -R 1000:1000 "$CONFIG_DIR"
        
        echo "✅ Files copied to Jellyfin container"
        
        # Verify files
        echo "Verifying files in container..."
        docker exec "$CONTAINER_NAME" ls -la "$CONFIG_DIR"/*.m3u
        docker exec "$CONTAINER_NAME" ls -la "$CONFIG_DIR"/*.xml
        
        # Cleanup temp directory
        rm -rf "$TEMP_DIR"
EOF
    
    echo ""
}

# Function to create and apply configuration
create_and_apply_config() {
    echo "⚙️  Creating and applying Jellyfin configuration..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Creating Jellyfin Live TV configuration..."
        
        CONTAINER_NAME="jellyfin-simonadmin"
        CONFIG_DIR="/config"
        
        # Create Live TV configuration directory
        docker exec "$CONTAINER_NAME" mkdir -p "$CONFIG_DIR/data/livetv"
        
        # Create tuners configuration
        docker exec "$CONTAINER_NAME" sh -c 'cat > /config/data/livetv/tuners.xml << "XML"
<?xml version="1.0" encoding="utf-8"?>
<Tuners>
  <Tuner>
    <Type>M3U</Type>
    <Name>Samsung TV Plus</Name>
    <File>/config/samsung_tv_plus.m3u</File>
    <Enable>true</Enable>
  </Tuner>
  <Tuner>
    <Type>M3U</Type>
    <Name>Plex Live Channels</Name>
    <File>/config/plex_live.m3u</File>
    <Enable>true</Enable>
  </Tuner>
  <Tuner>
    <Type>M3U</Type>
    <Name>Tubi TV</Name>
    <File>/config/tubi_tv.m3u</File>
    <Enable>true</Enable>
  </Tuner>
</Tuners>
XML'
        
        # Create guide providers configuration
        docker exec "$CONTAINER_NAME" sh -c 'cat > /config/data/livetv/guideproviders.xml << "XML"
<?xml version="1.0" encoding="utf-8"?>
<GuideProviders>
  <GuideProvider>
    <Type>XMLTV</Type>
    <Name>Samsung TV Plus EPG</Name>
    <File>/config/samsung_epg.xml</File>
    <Enable>true</Enable>
  </GuideProvider>
  <GuideProvider>
    <Type>XMLTV</Type>
    <Name>Plex Live EPG</Name>
    <File>/config/plex_epg.xml</File>
    <Enable>true</Enable>
  </GuideProvider>
</GuideProviders>
XML'
        
        # Set proper permissions
        docker exec "$CONTAINER_NAME" chown -R 1000:1000 "$CONFIG_DIR/data/livetv"
        
        echo "✅ Configuration files created"
EOF
    
    echo ""
}

# Function to restart and verify
restart_and_verify() {
    echo "🔄 Restarting Jellyfin and verifying setup..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Restarting Jellyfin container..."
        docker restart jellyfin-simonadmin
        
        echo "Waiting for Jellyfin to start..."
        sleep 30
        
        echo "Checking container status..."
        docker ps | grep jellyfin
        
        echo ""
        echo "Checking files in container..."
        docker exec jellyfin-simonadmin ls -la /config/*.m3u
        docker exec jellyfin-simonadmin ls -la /config/*.xml
        
        echo ""
        echo "Checking configuration files..."
        docker exec jellyfin-simonadmin ls -la /config/data/livetv/
        
        echo ""
        echo "Checking Jellyfin logs..."
        docker logs jellyfin-simonadmin --tail 10
EOF
    
    echo ""
}

# Function to test Live TV access
test_live_tv_access() {
    echo "📺 Testing Live TV access..."
    
    # Test if Jellyfin is accessible
    if curl -s -o /dev/null -w "%{http_code}" http://136.243.155.166:8096/web/ | grep -q "200\|302"; then
        echo "✅ Jellyfin web interface is accessible"
    else
        echo "❌ Jellyfin web interface is not accessible"
    fi
    
    echo ""
}

# Function to provide final instructions
final_instructions() {
    echo "📋 Final Instructions:"
    echo "====================="
    echo ""
    
    echo "1. Go to Jellyfin web interface:"
    echo "   http://136.243.155.166:8096/web/"
    echo ""
    
    echo "2. Log in as: simonadmin"
    echo ""
    
    echo "3. Go to Admin Panel → Live TV"
    echo ""
    
    echo "4. Check if tuners are automatically detected:"
    echo "   - Look for 'Samsung TV Plus', 'Plex Live Channels', 'Tubi TV'"
    echo "   - If not detected, add them manually using the files:"
    echo "     - /config/samsung_tv_plus.m3u"
    echo "     - /config/plex_live.m3u"
    echo "     - /config/tubi_tv.m3u"
    echo ""
    
    echo "5. Check if EPG providers are detected:"
    echo "   - Look for 'Samsung TV Plus EPG', 'Plex Live EPG'"
    echo "   - If not detected, add them manually using the files:"
    echo "     - /config/samsung_epg.xml"
    echo "     - /config/plex_epg.xml"
    echo ""
    
    echo "6. Refresh Guide Data:"
    echo "   - Click 'Refresh Guide Data'"
    echo "   - Wait for guide to populate"
    echo ""
    
    echo "7. Access Live TV:"
    echo "   - Return to Jellyfin home page"
    echo "   - Click 'Live TV' in main menu"
    echo "   - Browse and watch free channels!"
    echo ""
}

# Main execution
main() {
    echo "🚀 Starting complete Jellyfin TV channels execution..."
    echo ""
    
    ensure_files_uploaded
    copy_files_to_container
    create_and_apply_config
    restart_and_verify
    test_live_tv_access
    final_instructions
    
    echo "🎯 Summary:"
    echo "=========="
    echo ""
    echo "✅ Files downloaded and uploaded"
    echo "✅ Files copied to Jellyfin container"
    echo "✅ Configuration files created"
    echo "✅ Jellyfin restarted"
    echo "✅ Ready for Live TV"
    echo ""
    echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
    echo "📺 Log in as: simonadmin"
    echo "📋 Follow final instructions above"
    echo ""
    echo "🎉 Complete execution finished!"
}

# Run main function
main "$@"
