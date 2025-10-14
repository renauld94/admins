#!/bin/bash

# Deploy Jellyfin TV Channels Setup via ProxyJump
# This script deploys the TV channels setup to Proxmox VM 200 using proxy jump

set -e

echo "📺 Deploying Jellyfin TV Channels Setup via ProxyJump"
echo "====================================================="

# Configuration
PROXY_HOST="136.243.155.166"
VM_HOST="10.0.0.103"  # VM 200 internal IP
VM_USER="simonadmin"
VM_ID="200"
JELLYFIN_CONTAINER="jellyfin-simonadmin"

# Local files
LOCAL_SCRIPT="/home/simon/Desktop/Learning Management System Academy/add_jellyfin_tv_channels.sh"
LOCAL_CLI_SCRIPT="/home/simon/Desktop/Learning Management System Academy/jellyfin_cli_tv_setup.sh"

echo "📋 Configuration:"
echo "  Proxy Host: $PROXY_HOST"
echo "  VM Host: $VM_HOST (VM $VM_ID)"
echo "  VM User: $VM_USER"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo ""

# Function to test connectivity
test_connectivity() {
    echo "🔍 Testing connectivity..."
    
    # Test proxy host
    echo "Testing proxy host connectivity..."
    if ! ping -c 2 $PROXY_HOST > /dev/null 2>&1; then
        echo "❌ Error: Cannot reach proxy host $PROXY_HOST"
        exit 1
    fi
    echo "✅ Proxy host is reachable"
    
    # Test VM connectivity through proxy
    echo "Testing VM connectivity through proxy..."
    if ! ssh -o ConnectTimeout=10 -o ProxyJump=$PROXY_HOST $VM_USER@$VM_HOST "echo 'Connection successful'" > /dev/null 2>&1; then
        echo "❌ Error: Cannot reach VM $VM_HOST through proxy $PROXY_HOST"
        echo "💡 Please check:"
        echo "   - SSH key authentication is set up"
        echo "   - ProxyJump configuration is correct"
        echo "   - VM is accessible from proxy"
        exit 1
    fi
    echo "✅ VM is reachable through proxy"
    echo ""
}

# Function to upload scripts
upload_scripts() {
    echo "📤 Uploading scripts to VM..."
    
    # Upload the main TV channels setup script
    if [ -f "$LOCAL_SCRIPT" ]; then
        echo "Uploading add_jellyfin_tv_channels.sh..."
        scp -o ProxyJump=$PROXY_HOST "$LOCAL_SCRIPT" $VM_USER@$VM_HOST:/tmp/
        echo "✅ Script uploaded successfully"
    else
        echo "❌ Error: Local script not found: $LOCAL_SCRIPT"
        exit 1
    fi
    
    # Upload the CLI setup script
    if [ -f "$LOCAL_CLI_SCRIPT" ]; then
        echo "Uploading jellyfin_cli_tv_setup.sh..."
        scp -o ProxyJump=$PROXY_HOST "$LOCAL_CLI_SCRIPT" $VM_USER@$VM_HOST:/tmp/
        echo "✅ CLI script uploaded successfully"
    fi
    echo ""
}

# Function to run the setup script
run_setup_script() {
    echo "🚀 Running Jellyfin TV channels setup..."
    
    # Make script executable and run it
    ssh -o ProxyJump=$PROXY_HOST $VM_USER@$VM_HOST << 'EOF'
        echo "📺 Setting up Jellyfin TV Channels..."
        echo "===================================="
        
        # Make script executable
        chmod +x /tmp/add_jellyfin_tv_channels.sh
        
        # Run the setup script
        echo "Running automated TV channels setup..."
        /tmp/add_jellyfin_tv_channels.sh
        
        echo ""
        echo "✅ Setup script completed!"
EOF
    
    echo ""
}

# Function to verify setup
verify_setup() {
    echo "🔍 Verifying setup..."
    
    ssh -o ProxyJump=$PROXY_HOST $VM_USER@$VM_HOST << 'EOF'
        echo "Checking Jellyfin container status..."
        docker ps | grep jellyfin || echo "Jellyfin container not found"
        
        echo ""
        echo "Checking if M3U files were created..."
        docker exec jellyfin-simonadmin ls -la /config/*.m3u 2>/dev/null || echo "M3U files not found"
        
        echo ""
        echo "Checking if EPG files were created..."
        docker exec jellyfin-simonadmin ls -la /config/*.xml 2>/dev/null || echo "EPG files not found"
        
        echo ""
        echo "Checking Jellyfin logs..."
        docker logs jellyfin-simonadmin --tail 10
EOF
    
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

# Function to create alternative deployment methods
create_alternative_methods() {
    echo "🔄 Alternative Deployment Methods:"
    echo "=================================="
    echo ""
    
    cat > deploy_jellyfin_tv_proxyjump.sh << 'EOF'
#!/bin/bash

# Alternative: Direct command execution via ProxyJump
# This runs the TV channels setup directly without uploading files

set -e

PROXY_HOST="136.243.155.166"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
CONTAINER_NAME="jellyfin-simonadmin"

echo "📺 Running Jellyfin TV setup directly via ProxyJump..."

ssh -o ProxyJump=$PROXY_HOST $VM_USER@$VM_HOST << 'EOF'
    echo "📺 Setting up Jellyfin TV Channels..."
    
    # Create temporary directory
    TEMP_DIR="/tmp/jellyfin_tv_setup"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Download M3U playlists
    echo "📥 Downloading M3U playlists..."
    curl -o samsung_tv_plus.m3u "https://rb.gy/soxjxl" || echo "Failed to download Samsung M3U"
    curl -o plex_live.m3u "https://rb.gy/rhktaz" || echo "Failed to download Plex M3U"
    curl -o tubi_tv.m3u "https://www.apsattv.com/tubi.m3u" || echo "Failed to download Tubi M3U"
    
    # Download EPG files
    echo "📥 Downloading EPG files..."
    curl -o samsung_epg.xml "https://rb.gy/csudmm" || echo "Failed to download Samsung EPG"
    curl -o plex_epg.xml "https://rb.gy/uoqt9v" || echo "Failed to download Plex EPG"
    
    # Copy to Jellyfin container
    echo "📁 Copying files to Jellyfin container..."
    docker cp samsung_tv_plus.m3u jellyfin-simonadmin:/config/
    docker cp plex_live.m3u jellyfin-simonadmin:/config/
    docker cp tubi_tv.m3u jellyfin-simonadmin:/config/
    docker cp samsung_epg.xml jellyfin-simonadmin:/config/
    docker cp plex_epg.xml jellyfin-simonadmin:/config/
    
    # Set permissions and restart
    echo "🔧 Setting permissions and restarting Jellyfin..."
    docker exec jellyfin-simonadmin chown -R jellyfin:jellyfin /config
    docker restart jellyfin-simonadmin
    
    echo "⏳ Waiting for Jellyfin to start..."
    sleep 30
    
    # Cleanup
    cd /
    rm -rf "$TEMP_DIR"
    
    echo "✅ Setup complete!"
EOF

echo "🎉 Jellyfin TV channels setup complete via ProxyJump!"
EOF

    chmod +x deploy_jellyfin_tv_proxyjump.sh
    echo "✅ Created alternative deployment script: deploy_jellyfin_tv_proxyjump.sh"
    echo ""
}

# Main execution
main() {
    echo "🚀 Starting Jellyfin TV channels deployment via ProxyJump..."
    echo ""
    
    test_connectivity
    upload_scripts
    run_setup_script
    verify_setup
    next_steps
    create_alternative_methods
    
    echo "🎯 Summary:"
    echo "=========="
    echo ""
    echo "✅ Scripts uploaded to VM 200"
    echo "✅ TV channels setup completed"
    echo "✅ Jellyfin restarted with new configuration"
    echo ""
    echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
    echo "📺 Log in as: simonadmin"
    echo "📋 Follow the next steps above to configure Live TV"
    echo ""
    echo "🎉 Deployment complete!"
}

# Run main function
main "$@"
