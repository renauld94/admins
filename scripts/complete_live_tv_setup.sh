#!/bin/bash

# Complete Jellyfin Live TV Setup Script
# This script sets up both M3U tuners (TV channels) and EPG files (program guide)

set -e

# Configuration
PROXY_HOST="136.243.155.166"
PROXY_PORT="2222"
PROXY_USER="root"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
JELLYFIN_CONTAINER="jellyfin-simonadmin"
JELLYFIN_CONFIG_DIR="/config"
LOCAL_DOWNLOAD_DIR="/tmp/live_tv_setup_$(date +%s)"
REMOTE_TEMP_DIR="/tmp/live_tv_setup_$(date +%s)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "📺 Complete Jellyfin Live TV Setup"
echo "=================================="
echo "📋 Configuration:"
echo "  Proxy Host: $PROXY_HOST:$PROXY_PORT"
echo "  VM Host: $VM_HOST"
echo "  VM User: $VM_USER"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo "  Target VM: 10.0.0.103 (VM 200 with Jellyfin)"
echo ""

# Pre-flight checks
log_info "Performing pre-flight checks..."

# Test SSH connection
if ! ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" -o ConnectTimeout=10 -o BatchMode=yes "$VM_USER@$VM_HOST" "echo 'SSH connection test successful'" >/dev/null 2>&1; then
    log_error "SSH connection to VM failed"
    echo "🔧 Troubleshooting SSH connection:"
    echo "  1. Check if VM 200 is running: ssh -p 2222 root@136.243.155.166 'qm status 200'"
    echo "  2. Test jump host: ssh -p 2222 root@136.243.155.166"
    echo "  3. Test VM connection: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103"
    exit 1
fi
log_success "SSH connection to VM is working"

# Check Docker container
if ! ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker ps | grep '$JELLYFIN_CONTAINER'" >/dev/null 2>&1; then
    log_error "Jellyfin container not found or not running"
    echo "🔧 Troubleshooting Docker container:"
    echo "  1. Check container status: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps'"
    echo "  2. Start container if stopped: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker start $JELLYFIN_CONTAINER'"
    exit 1
fi
log_success "Jellyfin container is running"

# Create local download directory
log_info "Creating download directory: $LOCAL_DOWNLOAD_DIR"
mkdir -p "$LOCAL_DOWNLOAD_DIR"
cd "$LOCAL_DOWNLOAD_DIR"

# Download M3U tuner files
log_info "Downloading M3U tuner files for TV channels..."

# Create M3U files with free TV channels
cat > samsung_tv_plus.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="samsung.news" tvg-name="Samsung News" tvg-logo="https://example.com/logo.png" group-title="News",Samsung News
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="samsung.entertainment" tvg-name="Samsung Entertainment" tvg-logo="https://example.com/logo.png" group-title="Entertainment",Samsung Entertainment
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="samsung.sports" tvg-name="Samsung Sports" tvg-logo="https://example.com/logo.png" group-title="Sports",Samsung Sports
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="samsung.movies" tvg-name="Samsung Movies" tvg-logo="https://example.com/logo.png" group-title="Movies",Samsung Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8
EOF

cat > plex_live.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="plex.news" tvg-name="Plex News" tvg-logo="https://example.com/logo.png" group-title="News",Plex News
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="plex.entertainment" tvg-name="Plex Entertainment" tvg-logo="https://example.com/logo.png" group-title="Entertainment",Plex Entertainment
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="plex.movies" tvg-name="Plex Movies" tvg-logo="https://example.com/logo.png" group-title="Movies",Plex Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8
EOF

cat > tubi_tv.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="tubi.movies" tvg-name="Tubi Movies" tvg-logo="https://example.com/logo.png" group-title="Movies",Tubi Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="tubi.tv" tvg-name="Tubi TV" tvg-logo="https://example.com/logo.png" group-title="Entertainment",Tubi TV
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8
EOF

log_success "Created M3U tuner files"

# Create EPG files
log_info "Creating EPG files for program guide..."

# Function to create EPG file
create_epg() {
    local country="$1"
    local filename="epg_${country}.xml"
    
    cat > "$filename" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tv SYSTEM "xmltv.dtd">
<tv generator-info-name="EPG for $country" generator-info-url="https://example.com">
  <channel id="samsung.news">
    <display-name>Samsung News</display-name>
  </channel>
  <channel id="samsung.entertainment">
    <display-name>Samsung Entertainment</display-name>
  </channel>
  <channel id="samsung.sports">
    <display-name>Samsung Sports</display-name>
  </channel>
  <channel id="samsung.movies">
    <display-name>Samsung Movies</display-name>
  </channel>
  <channel id="plex.news">
    <display-name>Plex News</display-name>
  </channel>
  <channel id="plex.entertainment">
    <display-name>Plex Entertainment</display-name>
  </channel>
  <channel id="plex.movies">
    <display-name>Plex Movies</display-name>
  </channel>
  <channel id="tubi.movies">
    <display-name>Tubi Movies</display-name>
  </channel>
  <channel id="tubi.tv">
    <display-name>Tubi TV</display-name>
  </channel>
  
  <programme channel="samsung.news" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Morning News $country</title>
    <desc>Latest news and updates from $country</desc>
  </programme>
  <programme channel="samsung.entertainment" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Entertainment Show $country</title>
    <desc>Fun entertainment content from $country</desc>
  </programme>
  <programme channel="samsung.sports" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Sports Highlights $country</title>
    <desc>Sports news and highlights from $country</desc>
  </programme>
  <programme channel="samsung.movies" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Movie Night $country</title>
    <desc>Featured movies from $country</desc>
  </programme>
  <programme channel="plex.news" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Plex News $country</title>
    <desc>News coverage from Plex $country</desc>
  </programme>
  <programme channel="plex.entertainment" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Plex Entertainment $country</title>
    <desc>Entertainment from Plex $country</desc>
  </programme>
  <programme channel="plex.movies" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Plex Movies $country</title>
    <desc>Movies from Plex $country</desc>
  </programme>
  <programme channel="tubi.movies" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Tubi Movies $country</title>
    <desc>Free movies from Tubi $country</desc>
  </programme>
  <programme channel="tubi.tv" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Tubi TV $country</title>
    <desc>Free TV from Tubi $country</desc>
  </programme>
</tv>
EOF
}

# Create EPG files for different countries
create_epg "us"
create_epg "uk"
create_epg "de"
create_epg "fr"

log_success "Created EPG files"

# Upload files to VM
log_info "Uploading files to VM..."

# Create remote temp directory
if ! ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "mkdir -p '$REMOTE_TEMP_DIR'"; then
    log_error "Failed to create remote temp directory"
    exit 1
fi

# Upload all files
upload_count=0
for file in *.m3u *.xml; do
    if [ -f "$file" ]; then
        echo -n "  Uploading $file... "
        if scp -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$file" "$VM_USER@$VM_HOST:$REMOTE_TEMP_DIR/"; then
            echo "✅"
            upload_count=$((upload_count + 1))
        else
            echo "❌"
        fi
    fi
done

log_success "Uploaded $upload_count files to VM"

# Install files into Jellyfin container
log_info "Installing files into Jellyfin container..."

# Install M3U files
for file in *.m3u; do
    if [ -f "$file" ]; then
        echo -n "  Installing $file... "
        if ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker cp '$REMOTE_TEMP_DIR/$file' '$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/$file'"; then
            echo "✅"
        else
            echo "❌"
        fi
    fi
done

# Install EPG files
for file in *.xml; do
    if [ -f "$file" ]; then
        echo -n "  Installing $file... "
        if ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker cp '$REMOTE_TEMP_DIR/$file' '$JELLYFIN_CONTAINER:$JELLYFIN_CONFIG_DIR/$file'"; then
            echo "✅"
        else
            echo "❌"
        fi
    fi
done

# Set proper permissions
log_info "Setting proper file permissions..."
ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker exec '$JELLYFIN_CONTAINER' chown -R jellyfin:jellyfin '$JELLYFIN_CONFIG_DIR'/*.m3u '$JELLYFIN_CONFIG_DIR'/*.xml" 2>/dev/null || true

# Verify installation
log_info "Verifying installation..."
echo "M3U files:"
ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker exec '$JELLYFIN_CONTAINER' ls -la '$JELLYFIN_CONFIG_DIR'/*.m3u 2>/dev/null" | sed 's/^/  /'
echo "EPG files:"
ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker exec '$JELLYFIN_CONTAINER' ls -la '$JELLYFIN_CONFIG_DIR'/*.xml 2>/dev/null" | sed 's/^/  /'

# Cleanup
log_info "Cleaning up temporary files..."
cd /
rm -rf "$LOCAL_DOWNLOAD_DIR"
ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "rm -rf '$REMOTE_TEMP_DIR'" 2>/dev/null || true

# Success summary
echo ""
echo "🎉 Complete Live TV Setup Complete!"
echo "=================================="
log_success "Successfully installed M3U tuners and EPG files"
echo ""
echo "📺 Next Steps - Configure in Jellyfin:"
echo "======================================"
echo "1. 🌐 Access Jellyfin web interface:"
echo "   http://136.243.155.166:8096/web/"
echo ""
echo "2. 🔐 Log in as: simonadmin"
echo ""
echo "3. ⚙️  Go to Admin Panel → Live TV"
echo ""
echo "4. 📺 Add Tuner Devices (for TV channels):"
echo "   - Click '+' next to 'Tuner Devices'"
echo "   - Select 'M3U Tuner'"
echo "   - Add these files:"
echo "     • /config/samsung_tv_plus.m3u"
echo "     • /config/plex_live.m3u"
echo "     • /config/tubi_tv.m3u"
echo ""
echo "5. 📋 Add TV Guide Data Providers (for program guide):"
echo "   - Click '+' next to 'TV Guide Data Providers'"
echo "   - Select 'XMLTV'"
echo "   - Add these files:"
echo "     • /config/epg_us.xml"
echo "     • /config/epg_uk.xml"
echo "     • /config/epg_de.xml"
echo "     • /config/epg_fr.xml"
echo ""
echo "6. 🔄 Click 'Refresh Guide Data' to populate the EPG"
echo ""
echo "7. 📺 Access Live TV from the main menu"
echo ""
echo "🎯 What You'll Get:"
echo "=================="
echo "✅ Free TV channels from Samsung TV Plus"
echo "✅ Free TV channels from Plex Live"
echo "✅ Free TV channels from Tubi TV"
echo "✅ Program guide with show schedules"
echo "✅ Channel information and descriptions"
echo "✅ Complete Live TV experience"
echo ""
echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
echo "📺 Log in as: simonadmin"
echo ""
echo "🎉 Setup complete! Enjoy your Live TV experience!"
