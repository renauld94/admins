#!/bin/bash

# Jellyfin Free TV Channels Setup via Command Line
# This script adds free TV channels to Jellyfin using command line tools

set -e

echo "📺 Jellyfin Free TV Channels - Command Line Setup"
echo "================================================="

# Configuration
PROXMOX_HOST="136.243.155.166"
VM_ID="200"
VM_NAME="nextcloud-vm"
JELLYFIN_CONTAINER="jellyfin-simonadmin"
JELLYFIN_PORT="8096"
JELLYFIN_CONFIG="/config"
USERNAME="simonadmin"

# Free M3U Playlists
SAMSUNG_M3U="https://rb.gy/soxjxl"
SAMSUNG_EPG="https://rb.gy/csudmm"
PLEX_M3U="https://rb.gy/rhktaz"
PLEX_EPG="https://rb.gy/uoqt9v"
TUBI_M3U="https://www.apsattv.com/tubi.m3u"

echo "📋 Configuration:"
echo "  Proxmox Host: $PROXMOX_HOST"
echo "  VM ID: $VM_ID ($VM_NAME)"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo "  Jellyfin Port: $JELLYFIN_PORT"
echo "  Username: $USERNAME"
echo ""

# Function to access Proxmox console
access_proxmox_console() {
    echo "🔧 Accessing Proxmox Console:"
    echo "============================"
    echo ""
    echo "To run this script, you need to:"
    echo "1. Go to Proxmox web interface: https://$PROXMOX_HOST:8006"
    echo "2. Log in with your Proxmox credentials"
    echo "3. Navigate to VM 200 (nextcloud-vm)"
    echo "4. Click 'Console' to open VM console"
    echo "5. Copy and paste the commands below"
    echo ""
}

# Function to create M3U playlist files
create_m3u_files() {
    echo "📺 Creating M3U Playlist Files:"
    echo "==============================="
    echo ""
    
    cat > add_jellyfin_tv_channels.sh << 'EOF'
#!/bin/bash

# Jellyfin TV Channels Setup Script
# Run this script inside the Proxmox VM 200 console

set -e

echo "📺 Setting up Jellyfin TV Channels..."
echo "===================================="

CONTAINER_NAME="jellyfin-simonadmin"
CONFIG_DIR="/config"
TEMP_DIR="/tmp/jellyfin_tv_setup"

# Create temporary directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "📥 Downloading M3U playlists..."

# Download Samsung TV Plus M3U
echo "Downloading Samsung TV Plus playlist..."
curl -o samsung_tv_plus.m3u "https://rb.gy/soxjxl" || echo "Failed to download Samsung M3U"

# Download Plex Live Channels M3U
echo "Downloading Plex Live Channels playlist..."
curl -o plex_live.m3u "https://rb.gy/rhktaz" || echo "Failed to download Plex M3U"

# Download Tubi TV M3U
echo "Downloading Tubi TV playlist..."
curl -o tubi_tv.m3u "https://www.apsattv.com/tubi.m3u" || echo "Failed to download Tubi M3U"

echo "📥 Downloading EPG files..."

# Download Samsung TV Plus EPG
echo "Downloading Samsung TV Plus EPG..."
curl -o samsung_epg.xml "https://rb.gy/csudmm" || echo "Failed to download Samsung EPG"

# Download Plex Live Channels EPG
echo "Downloading Plex Live Channels EPG..."
curl -o plex_epg.xml "https://rb.gy/uoqt9v" || echo "Failed to download Plex EPG"

echo "📁 Copying files to Jellyfin container..."

# Copy M3U files to Jellyfin config directory
docker cp samsung_tv_plus.m3u "$CONTAINER_NAME:$CONFIG_DIR/"
docker cp plex_live.m3u "$CONTAINER_NAME:$CONFIG_DIR/"
docker cp tubi_tv.m3u "$CONTAINER_NAME:$CONFIG_DIR/"

# Copy EPG files to Jellyfin config directory
docker cp samsung_epg.xml "$CONTAINER_NAME:$CONFIG_DIR/"
docker cp plex_epg.xml "$CONTAINER_NAME:$CONFIG_DIR/"

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
echo ""
echo "📋 Next Steps:"
echo "1. Go to Jellyfin web interface: http://136.243.155.166:8096/web/"
echo "2. Log in as simonadmin"
echo "3. Go to Admin Panel → Live TV"
echo "4. Add M3U Tuner with local file: /config/samsung_tv_plus.m3u"
echo "5. Add XMLTV EPG with local file: /config/samsung_epg.xml"
echo "6. Click 'Refresh Guide Data'"
echo ""
echo "📺 Available M3U files:"
echo "  - /config/samsung_tv_plus.m3u"
echo "  - /config/plex_live.m3u"
echo "  - /config/tubi_tv.m3u"
echo ""
echo "📺 Available EPG files:"
echo "  - /config/samsung_epg.xml"
echo "  - /config/plex_epg.xml"
echo ""

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "🎉 Jellyfin TV channels setup complete!"
EOF

    chmod +x add_jellyfin_tv_channels.sh
    echo "✅ Created add_jellyfin_tv_channels.sh"
    echo ""
}

# Function to create API-based setup script
create_api_setup() {
    echo "🔌 Creating API-based Setup Script:"
    echo "===================================="
    echo ""
    
    cat > jellyfin_api_setup.sh << 'EOF'
#!/bin/bash

# Jellyfin API-based TV Channels Setup
# This script uses Jellyfin API to add TV channels

set -e

echo "🔌 Jellyfin API TV Channels Setup"
echo "=================================="

JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY=""
USERNAME="simonadmin"

# Function to get API key
get_api_key() {
    echo "🔑 Getting Jellyfin API key..."
    
    # Login to get API key
    LOGIN_RESPONSE=$(curl -s -X POST "$JELLYFIN_URL/Users/authenticatebyname" \
        -H "Content-Type: application/json" \
        -d "{\"Username\":\"$USERNAME\",\"Pw\":\"\"}")
    
    if [ $? -eq 0 ]; then
        API_KEY=$(echo "$LOGIN_RESPONSE" | grep -o '"AccessToken":"[^"]*"' | cut -d'"' -f4)
        echo "✅ API key obtained: ${API_KEY:0:10}..."
    else
        echo "❌ Failed to get API key"
        exit 1
    fi
}

# Function to add M3U tuner
add_m3u_tuner() {
    echo "📺 Adding M3U tuner..."
    
    curl -X POST "$JELLYFIN_URL/LiveTv/Tuners" \
        -H "Content-Type: application/json" \
        -H "X-Emby-Token: $API_KEY" \
        -d '{
            "Type": "M3U",
            "Name": "Samsung TV Plus",
            "Url": "https://rb.gy/soxjxl"
        }'
    
    echo "✅ M3U tuner added"
}

# Function to add EPG
add_epg() {
    echo "📋 Adding EPG..."
    
    curl -X POST "$JELLYFIN_URL/LiveTv/GuideProviders" \
        -H "Content-Type: application/json" \
        -H "X-Emby-Token: $API_KEY" \
        -d '{
            "Type": "XMLTV",
            "Name": "Samsung TV Plus EPG",
            "Url": "https://rb.gy/csudmm"
        }'
    
    echo "✅ EPG added"
}

# Function to refresh guide data
refresh_guide() {
    echo "🔄 Refreshing guide data..."
    
    curl -X POST "$JELLYFIN_URL/LiveTv/Guide/Refresh" \
        -H "X-Emby-Token: $API_KEY"
    
    echo "✅ Guide data refresh initiated"
}

# Main execution
main() {
    get_api_key
    add_m3u_tuner
    add_epg
    refresh_guide
    
    echo ""
    echo "🎉 TV channels setup complete via API!"
    echo "🌐 Access Jellyfin at: $JELLYFIN_URL/web/"
}

main "$@"
EOF

    chmod +x jellyfin_api_setup.sh
    echo "✅ Created jellyfin_api_setup.sh"
    echo ""
}

# Function to create Docker-based setup
create_docker_setup() {
    echo "🐳 Creating Docker-based Setup:"
    echo "==============================="
    echo ""
    
    cat > docker_tv_setup.sh << 'EOF'
#!/bin/bash

# Docker-based Jellyfin TV Channels Setup
# Run this script inside the Proxmox VM 200 console

set -e

echo "🐳 Docker-based Jellyfin TV Setup"
echo "================================="

CONTAINER_NAME="jellyfin-simonadmin"
CONFIG_DIR="/config"

echo "📥 Downloading TV channel files..."

# Download M3U playlists
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/samsung_tv.m3u" "https://rb.gy/soxjxl" || echo "Failed to download Samsung M3U"
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/plex_tv.m3u" "https://rb.gy/rhktaz" || echo "Failed to download Plex M3U"
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/tubi_tv.m3u" "https://www.apsattv.com/tubi.m3u" || echo "Failed to download Tubi M3U"

# Download EPG files
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/samsung_epg.xml" "https://rb.gy/csudmm" || echo "Failed to download Samsung EPG"
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/plex_epg.xml" "https://rb.gy/uoqt9v" || echo "Failed to download Plex EPG"

echo "🔧 Setting up Jellyfin configuration..."

# Create Live TV directory
docker exec "$CONTAINER_NAME" mkdir -p "$CONFIG_DIR/data/livetv"

# Set permissions
docker exec "$CONTAINER_NAME" chown -R jellyfin:jellyfin "$CONFIG_DIR"

echo "🔄 Restarting Jellyfin..."
docker restart "$CONTAINER_NAME"

echo "⏳ Waiting for restart..."
sleep 30

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Go to: http://136.243.155.166:8096/web/"
echo "2. Log in as simonadmin"
echo "3. Admin Panel → Live TV"
echo "4. Add M3U Tuner with file: /config/samsung_tv.m3u"
echo "5. Add XMLTV EPG with file: /config/samsung_epg.xml"
echo ""
EOF

    chmod +x docker_tv_setup.sh
    echo "✅ Created docker_tv_setup.sh"
    echo ""
}

# Function to provide manual commands
manual_commands() {
    echo "⌨️  Manual Commands:"
    echo "==================="
    echo ""
    
    echo "Step 1: Access Proxmox Console"
    echo "1. Go to: https://$PROXMOX_HOST:8006"
    echo "2. Log in and open VM 200 console"
    echo ""
    
    echo "Step 2: Download M3U Files"
    echo "wget -O samsung_tv.m3u 'https://rb.gy/soxjxl'"
    echo "wget -O plex_tv.m3u 'https://rb.gy/rhktaz'"
    echo "wget -O tubi_tv.m3u 'https://www.apsattv.com/tubi.m3u'"
    echo ""
    
    echo "Step 3: Download EPG Files"
    echo "wget -O samsung_epg.xml 'https://rb.gy/csudmm'"
    echo "wget -O plex_epg.xml 'https://rb.gy/uoqt9v'"
    echo ""
    
    echo "Step 4: Copy to Jellyfin Container"
    echo "docker cp samsung_tv.m3u $JELLYFIN_CONTAINER:/config/"
    echo "docker cp plex_tv.m3u $JELLYFIN_CONTAINER:/config/"
    echo "docker cp tubi_tv.m3u $JELLYFIN_CONTAINER:/config/"
    echo "docker cp samsung_epg.xml $JELLYFIN_CONTAINER:/config/"
    echo "docker cp plex_epg.xml $JELLYFIN_CONTAINER:/config/"
    echo ""
    
    echo "Step 5: Set Permissions and Restart"
    echo "docker exec $JELLYFIN_CONTAINER chown -R jellyfin:jellyfin /config"
    echo "docker restart $JELLYFIN_CONTAINER"
    echo ""
}

# Main execution
main() {
    echo "🚀 Creating command-line setup scripts..."
    echo ""
    
    access_proxmox_console
    create_m3u_files
    create_api_setup
    create_docker_setup
    manual_commands
    
    echo "🎯 Quick Start Options:"
    echo "======================"
    echo ""
    echo "Option 1: Run the automated script"
    echo "1. Copy add_jellyfin_tv_channels.sh to VM 200"
    echo "2. Run: ./add_jellyfin_tv_channels.sh"
    echo ""
    echo "Option 2: Use Docker commands"
    echo "1. Copy docker_tv_setup.sh to VM 200"
    echo "2. Run: ./docker_tv_setup.sh"
    echo ""
    echo "Option 3: Manual commands"
    echo "1. Follow the manual commands above"
    echo "2. Execute each command step by step"
    echo ""
    echo "🌐 After setup, access Jellyfin at: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo "📺 Log in as: $USERNAME"
    echo ""
}

# Run main function
main "$@"
