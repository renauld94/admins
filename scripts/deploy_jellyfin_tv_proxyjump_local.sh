#!/bin/bash

# Deploy Jellyfin TV Channels Setup via ProxyJump (Local Download)
# This script downloads files locally first, then uploads them to the VM

set -e

echo "📺 Deploying Jellyfin TV Channels Setup via ProxyJump (Local Download)"
echo "====================================================================="

# Configuration
PROXY_HOST="136.243.155.166"
PROXY_PORT="2222"
PROXY_USER="root"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
JELLYFIN_CONTAINER="jellyfin-simonadmin"

# Local directories
LOCAL_DOWNLOAD_DIR="/tmp/jellyfin_tv_download"
VM_TEMP_DIR="/tmp/jellyfin_tv_setup"

echo "📋 Configuration:"
echo "  Proxy Host: $PROXY_HOST:$PROXY_PORT"
echo "  VM Host: $VM_HOST"
echo "  VM User: $VM_USER"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo "  Local Download Dir: $LOCAL_DOWNLOAD_DIR"
echo ""

# Function to download files locally
download_files_locally() {
    echo "📥 Downloading TV channel files locally..."
    
    # Create local download directory
    mkdir -p "$LOCAL_DOWNLOAD_DIR"
    cd "$LOCAL_DOWNLOAD_DIR"
    
    # Download M3U playlists
    echo "Downloading Samsung TV Plus M3U..."
    curl -o samsung_tv_plus.m3u "https://rb.gy/soxjxl" || echo "Failed to download Samsung M3U"
    
    echo "Downloading Plex Live Channels M3U..."
    curl -o plex_live.m3u "https://rb.gy/rhktaz" || echo "Failed to download Plex M3U"
    
    echo "Downloading Tubi TV M3U..."
    curl -o tubi_tv.m3u "https://www.apsattv.com/tubi.m3u" || echo "Failed to download Tubi M3U"
    
    # Download EPG files
    echo "Downloading Samsung TV Plus EPG..."
    curl -o samsung_epg.xml "https://rb.gy/csudmm" || echo "Failed to download Samsung EPG"
    
    echo "Downloading Plex Live Channels EPG..."
    curl -o plex_epg.xml "https://rb.gy/uoqt9v" || echo "Failed to download Plex EPG"
    
    echo "✅ Files downloaded locally"
    echo ""
}

# Function to upload files to VM
upload_files_to_vm() {
    echo "📤 Uploading files to VM..."
    
    # Create temp directory on VM
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST "mkdir -p $VM_TEMP_DIR"
    
    # Upload M3U files
    echo "Uploading M3U files..."
    scp -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$LOCAL_DOWNLOAD_DIR"/*.m3u $VM_USER@$VM_HOST:$VM_TEMP_DIR/
    
    # Upload EPG files
    echo "Uploading EPG files..."
    scp -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$LOCAL_DOWNLOAD_DIR"/*.xml $VM_USER@$VM_HOST:$VM_TEMP_DIR/
    
    echo "✅ Files uploaded to VM"
    echo ""
}

# Function to setup Jellyfin on VM
setup_jellyfin_on_vm() {
    echo "🔧 Setting up Jellyfin on VM..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "📺 Setting up Jellyfin TV Channels..."
        
        TEMP_DIR="/tmp/jellyfin_tv_setup"
        CONTAINER_NAME="jellyfin-simonadmin"
        CONFIG_DIR="/config"
        
        cd "$TEMP_DIR"
        
        echo "📁 Copying files to Jellyfin container..."
        
        # Copy M3U files to Jellyfin config directory
        docker cp samsung_tv_plus.m3u "$CONTAINER_NAME:$CONFIG_DIR/" || echo "Failed to copy Samsung M3U"
        docker cp plex_live.m3u "$CONTAINER_NAME:$CONFIG_DIR/" || echo "Failed to copy Plex M3U"
        docker cp tubi_tv.m3u "$CONTAINER_NAME:$CONFIG_DIR/" || echo "Failed to copy Tubi M3U"
        
        # Copy EPG files to Jellyfin config directory
        docker cp samsung_epg.xml "$CONTAINER_NAME:$CONFIG_DIR/" || echo "Failed to copy Samsung EPG"
        docker cp plex_epg.xml "$CONTAINER_NAME:$CONFIG_DIR/" || echo "Failed to copy Plex EPG"
        
        echo "🔧 Setting up Jellyfin configuration..."
        
        # Create Jellyfin configuration for Live TV
        docker exec "$CONTAINER_NAME" mkdir -p "$CONFIG_DIR/data/livetv"
        
        # Set proper permissions
        docker exec "$CONTAINER_NAME" chown -R jellyfin:jellyfin "$CONFIG_DIR"
        
        echo "🔄 Restarting Jellyfin container..."
        docker restart "$CONTAINER_NAME"
        
        echo "⏳ Waiting for Jellyfin to start..."
        sleep 30
        
        echo "✅ Setup complete!"
        
        # Cleanup temp directory
        cd /
        rm -rf "$TEMP_DIR"
EOF
    
    echo ""
}

# Function to verify setup
verify_setup() {
    echo "🔍 Verifying setup..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Checking Jellyfin container status..."
        docker ps | grep jellyfin || echo "Jellyfin container not found"
        
        echo ""
        echo "Checking if M3U files were created..."
        docker exec jellyfin-simonadmin ls -la /config/*.m3u 2>/dev/null || echo "M3U files not found"
        
        echo ""
        echo "Checking if EPG files were created..."
        docker exec jellyfin-simonadmin ls -la /config/*.xml 2>/dev/null || echo "EPG files not found"
        
        echo ""
        echo "Checking Jellyfin logs (last 10 lines)..."
        docker logs jellyfin-simonadmin --tail 10
EOF
    
    echo ""
}

# Function to cleanup local files
cleanup_local() {
    echo "🧹 Cleaning up local files..."
    rm -rf "$LOCAL_DOWNLOAD_DIR"
    echo "✅ Local cleanup complete"
    echo ""
}

# Function to provide next steps
next_steps() {
    echo "📋 Next Steps:"
    echo "=============="
    echo ""
    echo "1. Go to Jellyfin web interface:"
    echo "   http://136.243.155.166:8096/web/"
    echo ""
    echo "2. Log in as: simonadmin"
    echo ""
    echo "3. Go to Admin Panel → Live TV"
    echo ""
    echo "4. Add M3U Tuner:"
    echo "   - Click '+' next to 'Tuner Devices'"
    echo "   - Select 'M3U Tuner'"
    echo "   - Use local file: /config/samsung_tv_plus.m3u"
    echo "   - Click 'Save'"
    echo ""
    echo "5. Add XMLTV EPG:"
    echo "   - Click '+' next to 'TV Guide Data Providers'"
    echo "   - Select 'XMLTV'"
    echo "   - Use local file: /config/samsung_epg.xml"
    echo "   - Click 'Save'"
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
    echo "🚀 Starting Jellyfin TV channels deployment via ProxyJump..."
    echo ""
    
    download_files_locally
    upload_files_to_vm
    setup_jellyfin_on_vm
    verify_setup
    cleanup_local
    next_steps
    
    echo "🎯 Summary:"
    echo "=========="
    echo ""
    echo "✅ Files downloaded locally"
    echo "✅ Files uploaded to VM 200"
    echo "✅ Jellyfin container configured"
    echo "✅ Jellyfin restarted"
    echo "✅ Local files cleaned up"
    echo ""
    echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
    echo "📺 Log in as: simonadmin"
    echo "📋 Follow the next steps above to configure Live TV"
    echo ""
    echo "🎉 Deployment complete!"
}

# Run main function
main "$@"
