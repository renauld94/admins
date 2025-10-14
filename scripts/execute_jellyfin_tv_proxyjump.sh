#!/bin/bash

# Execute Jellyfin TV Channels Configuration via ProxyJump
# This script configures the TV channels directly via API/CLI without web interface

set -e

echo "📺 Executing Jellyfin TV Channels Configuration via ProxyJump"
echo "============================================================"

# Configuration
PROXY_HOST="136.243.155.166"
PROXY_PORT="2222"
PROXY_USER="root"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
JELLYFIN_CONTAINER="jellyfin-simonadmin"
JELLYFIN_URL="http://136.243.155.166:8096"

echo "📋 Configuration:"
echo "  Proxy Host: $PROXY_HOST:$PROXY_PORT"
echo "  VM Host: $VM_HOST"
echo "  VM User: $VM_USER"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo "  Jellyfin URL: $JELLYFIN_URL"
echo ""

# Function to check if files exist in container
check_files_in_container() {
    echo "🔍 Checking if TV channel files exist in Jellyfin container..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Checking M3U files..."
        docker exec jellyfin-simonadmin ls -la /config/*.m3u 2>/dev/null || echo "No M3U files found"
        
        echo ""
        echo "Checking EPG files..."
        docker exec jellyfin-simonadmin ls -la /config/*.xml 2>/dev/null || echo "No EPG files found"
        
        echo ""
        echo "Checking Jellyfin container status..."
        docker ps | grep jellyfin || echo "Jellyfin container not running"
EOF
    
    echo ""
}

# Function to create M3U configuration files
create_m3u_config() {
    echo "📝 Creating M3U configuration files..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Creating M3U configuration files..."
        
        # Create Samsung TV Plus M3U config
        cat > /tmp/samsung_tv_config.json << 'JSON'
{
    "Type": "M3U",
    "Name": "Samsung TV Plus",
    "Url": "",
    "File": "/config/samsung_tv_plus.m3u",
    "Enable": true
}
JSON
        
        # Create Plex Live M3U config
        cat > /tmp/plex_live_config.json << 'JSON'
{
    "Type": "M3U",
    "Name": "Plex Live Channels",
    "Url": "",
    "File": "/config/plex_live.m3u",
    "Enable": true
}
JSON
        
        # Create Tubi TV M3U config
        cat > /tmp/tubi_tv_config.json << 'JSON'
{
    "Type": "M3U",
    "Name": "Tubi TV",
    "Url": "",
    "File": "/config/tubi_tv.m3u",
    "Enable": true
}
JSON
        
        echo "✅ M3U configuration files created"
EOF
    
    echo ""
}

# Function to create EPG configuration files
create_epg_config() {
    echo "📝 Creating EPG configuration files..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Creating EPG configuration files..."
        
        # Create Samsung TV Plus EPG config
        cat > /tmp/samsung_epg_config.json << 'JSON'
{
    "Type": "XMLTV",
    "Name": "Samsung TV Plus EPG",
    "Url": "",
    "File": "/config/samsung_epg.xml",
    "Enable": true
}
JSON
        
        # Create Plex Live EPG config
        cat > /tmp/plex_epg_config.json << 'JSON'
{
    "Type": "XMLTV",
    "Name": "Plex Live EPG",
    "Url": "",
    "File": "/config/plex_epg.xml",
    "Enable": true
}
JSON
        
        echo "✅ EPG configuration files created"
EOF
    
    echo ""
}

# Function to configure Jellyfin via API
configure_jellyfin_api() {
    echo "🔌 Configuring Jellyfin via API..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Configuring Jellyfin Live TV via API..."
        
        # Get API key (this might need to be done manually first)
        echo "Note: API configuration requires authentication"
        echo "You may need to:"
        echo "1. Log into Jellyfin web interface"
        echo "2. Go to Admin Panel → API Keys"
        echo "3. Create a new API key"
        echo "4. Use that key for API calls"
        
        # Example API calls (uncomment when you have API key)
        # API_KEY="your_api_key_here"
        # 
        # # Add M3U tuner
        # curl -X POST "http://localhost:8096/LiveTv/Tuners" \
        #     -H "Content-Type: application/json" \
        #     -H "X-Emby-Token: $API_KEY" \
        #     -d @/tmp/samsung_tv_config.json
        # 
        # # Add EPG
        # curl -X POST "http://localhost:8096/LiveTv/GuideProviders" \
        #     -H "Content-Type: application/json" \
        #     -H "X-Emby-Token: $API_KEY" \
        #     -d @/tmp/samsung_epg_config.json
EOF
    
    echo ""
}

# Function to configure via Jellyfin CLI
configure_jellyfin_cli() {
    echo "⌨️  Configuring Jellyfin via CLI..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Configuring Jellyfin via CLI..."
        
        # Check if Jellyfin CLI is available
        if docker exec jellyfin-simonadmin which jellyfin >/dev/null 2>&1; then
            echo "Jellyfin CLI found, configuring..."
            
            # Add M3U tuner via CLI
            docker exec jellyfin-simonadmin jellyfin livetv tuners add \
                --type M3U \
                --name "Samsung TV Plus" \
                --file "/config/samsung_tv_plus.m3u" \
                --enable || echo "Failed to add Samsung tuner"
            
            # Add EPG via CLI
            docker exec jellyfin-simonadmin jellyfin livetv guide add \
                --type XMLTV \
                --name "Samsung TV Plus EPG" \
                --file "/config/samsung_epg.xml" \
                --enable || echo "Failed to add Samsung EPG"
        else
            echo "Jellyfin CLI not available, using alternative method..."
        fi
EOF
    
    echo ""
}

# Function to configure via configuration files
configure_via_files() {
    echo "📁 Configuring via Jellyfin configuration files..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Configuring Jellyfin via configuration files..."
        
        # Create Live TV configuration directory
        docker exec jellyfin-simonadmin mkdir -p /config/data/livetv
        
        # Create tuners configuration
        cat > /tmp/tuners.xml << 'XML'
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
XML
        
        # Create guide providers configuration
        cat > /tmp/guideproviders.xml << 'XML'
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
XML
        
        # Copy configuration files to container
        docker cp /tmp/tuners.xml jellyfin-simonadmin:/config/data/livetv/
        docker cp /tmp/guideproviders.xml jellyfin-simonadmin:/config/data/livetv/
        
        # Set proper permissions
        docker exec jellyfin-simonadmin chown -R 1000:1000 /config/data/livetv
        
        echo "✅ Configuration files created and copied"
EOF
    
    echo ""
}

# Function to restart and verify
restart_and_verify() {
    echo "🔄 Restarting Jellyfin and verifying configuration..."
    
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "Restarting Jellyfin container..."
        docker restart jellyfin-simonadmin
        
        echo "Waiting for Jellyfin to start..."
        sleep 30
        
        echo "Checking container status..."
        docker ps | grep jellyfin
        
        echo ""
        echo "Checking configuration files..."
        docker exec jellyfin-simonadmin ls -la /config/data/livetv/ 2>/dev/null || echo "Live TV config directory not found"
        
        echo ""
        echo "Checking Jellyfin logs for Live TV..."
        docker logs jellyfin-simonadmin --tail 20 | grep -i "livetv\|tuner\|epg" || echo "No Live TV related logs found"
EOF
    
    echo ""
}

# Function to provide manual configuration steps
manual_configuration_steps() {
    echo "📋 Manual Configuration Steps (if automated methods fail):"
    echo "========================================================="
    echo ""
    
    echo "1. Go to Jellyfin web interface:"
    echo "   http://136.243.155.166:8096/web/"
    echo ""
    
    echo "2. Log in as: simonadmin"
    echo ""
    
    echo "3. Go to Admin Panel → Live TV"
    echo ""
    
    echo "4. Add M3U Tuners:"
    echo "   - Click '+' next to 'Tuner Devices'"
    echo "   - Select 'M3U Tuner'"
    echo "   - Name: 'Samsung TV Plus'"
    echo "   - File: '/config/samsung_tv_plus.m3u'"
    echo "   - Click 'Save'"
    echo ""
    
    echo "5. Add XMLTV EPG:"
    echo "   - Click '+' next to 'TV Guide Data Providers'"
    echo "   - Select 'XMLTV'"
    echo "   - Name: 'Samsung TV Plus EPG'"
    echo "   - File: '/config/samsung_epg.xml'"
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
    echo "🚀 Starting Jellyfin TV channels configuration execution..."
    echo ""
    
    check_files_in_container
    create_m3u_config
    create_epg_config
    configure_via_files
    restart_and_verify
    manual_configuration_steps
    
    echo "🎯 Summary:"
    echo "=========="
    echo ""
    echo "✅ Configuration files created"
    echo "✅ Jellyfin restarted"
    echo "✅ Ready for Live TV configuration"
    echo ""
    echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
    echo "📺 Log in as: simonadmin"
    echo "📋 Follow manual steps above if needed"
    echo ""
    echo "🎉 Configuration execution complete!"
}

# Run main function
main "$@"
