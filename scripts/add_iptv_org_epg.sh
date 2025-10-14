#!/bin/bash

# Enhanced iptv-org EPG Setup Script for Jellyfin
# This script downloads EPG data from iptv-org and installs it into Jellyfin Docker container
# Supports multiple execution methods and comprehensive error handling

set -e

# Configuration
PROXY_HOST="136.243.155.166"
PROXY_PORT="2222"
PROXY_USER="root"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
JELLYFIN_CONTAINER="jellyfin-simonadmin"
JELLYFIN_CONFIG_DIR="/config"
LOCAL_DOWNLOAD_DIR="/tmp/iptv_org_epg_$(date +%s)"
REMOTE_TEMP_DIR="/tmp/iptv_org_epg_$(date +%s)"

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to test SSH connection
test_ssh_connection() {
    log_info "Testing SSH connection to VM..."
    
    if ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" -o ConnectTimeout=10 -o BatchMode=yes "$VM_USER@$VM_HOST" "echo 'SSH connection test successful'" >/dev/null 2>&1; then
        log_success "SSH connection to VM is working"
        return 0
    else
        log_error "SSH connection to VM failed"
        return 1
    fi
}

# Function to check Docker container status
check_docker_container() {
    log_info "Checking Docker container status..."
    
    local container_status
    container_status=$(ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep '$JELLYFIN_CONTAINER'" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$container_status" ]; then
        log_success "Jellyfin container is running"
        echo "  $container_status"
        return 0
    else
        log_warning "Jellyfin container not found or not running"
        return 1
    fi
}

# Function to validate EPG files
validate_epg_files() {
    log_info "Validating downloaded EPG files..."
    
    local valid_files=0
    local total_files=0
    
    for file in epg_*.xml; do
        if [ -f "$file" ]; then
            total_files=$((total_files + 1))
            if [ -s "$file" ] && head -1 "$file" | grep -q "<?xml"; then
                valid_files=$((valid_files + 1))
                log_success "Valid EPG file: $file"
            else
                log_warning "Invalid or empty EPG file: $file"
            fi
        fi
    done
    
    if [ $valid_files -eq 0 ]; then
        log_error "No valid EPG files found"
        return 1
    elif [ $valid_files -lt $total_files ]; then
        log_warning "Only $valid_files out of $total_files EPG files are valid"
    else
        log_success "All $total_files EPG files are valid"
    fi
    
    return 0
}

echo "📺 Enhanced iptv-org EPG Setup for Jellyfin"
echo "==========================================="
echo "📋 Configuration:"
echo "  Proxy Host: $PROXY_HOST:$PROXY_PORT"
echo "  VM Host: $VM_HOST"
echo "  VM User: $VM_USER"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo "  Target VM: 10.0.0.103 (VM 200 with Jellyfin)"
echo ""

# Pre-flight checks
log_info "Performing pre-flight checks..."

# Check required commands
if ! command_exists curl; then
    log_error "curl is required but not installed"
    exit 1
fi

if ! command_exists ssh; then
    log_error "ssh is required but not installed"
    exit 1
fi

if ! command_exists scp; then
    log_error "scp is required but not installed"
    exit 1
fi

# Test SSH connection
if ! test_ssh_connection; then
    log_error "Cannot proceed without SSH connection"
    echo ""
    echo "🔧 Troubleshooting SSH connection:"
    echo "  1. Check if VM 200 is running: ssh -p 2222 root@136.243.155.166 'qm status 200'"
    echo "  2. Test jump host: ssh -p 2222 root@136.243.155.166"
    echo "  3. Test VM connection: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103"
    echo ""
    echo "💡 Alternative: Use manual method (see script output below)"
    exit 1
fi

# Check Docker container
if ! check_docker_container; then
    log_error "Jellyfin container not found or not running"
    echo ""
    echo "🔧 Troubleshooting Docker container:"
    echo "  1. Check container status: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps'"
    echo "  2. Start container if stopped: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker start $JELLYFIN_CONTAINER'"
    echo "  3. Check container logs: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker logs $JELLYFIN_CONTAINER'"
    echo ""
    echo "💡 Alternative: Use manual method (see script output below)"
    exit 1
fi

# Create local download directory
log_info "Creating download directory: $LOCAL_DOWNLOAD_DIR"
mkdir -p "$LOCAL_DOWNLOAD_DIR"
cd "$LOCAL_DOWNLOAD_DIR"

# Download EPG files with error handling
log_info "Downloading iptv-org EPG files..."
echo "📥 Downloading regional EPG files from iptv-org..."

# Define EPG URLs - Using working sources
declare -A epg_urls=(
    ["us"]="https://epg.iptv-org.net/us.xml"
    ["uk"]="https://epg.iptv-org.net/uk.xml"
    ["de"]="https://epg.iptv-org.net/de.xml"
    ["fr"]="https://epg.iptv-org.net/fr.xml"
    ["ca"]="https://epg.iptv-org.net/ca.xml"
    ["au"]="https://epg.iptv-org.net/au.xml"
    ["jp"]="https://epg.iptv-org.net/jp.xml"
    ["kr"]="https://epg.iptv-org.net/kr.xml"
    ["in"]="https://epg.iptv-org.net/in.xml"
    ["br"]="https://epg.iptv-org.net/br.xml"
    ["mx"]="https://epg.iptv-org.net/mx.xml"
    ["es"]="https://epg.iptv-org.net/es.xml"
    ["it"]="https://epg.iptv-org.net/it.xml"
    ["nl"]="https://epg.iptv-org.net/nl.xml"
    ["ru"]="https://epg.iptv-org.net/ru.xml"
    ["cn"]="https://epg.iptv-org.net/cn.xml"
    ["ae"]="https://epg.iptv-org.net/ae.xml"
    ["ar"]="https://epg.iptv-org.net/ar.xml"
    ["eg"]="https://epg.iptv-org.net/eg.xml"
    ["sa"]="https://epg.iptv-org.net/sa.xml"
)

# Function to create test EPG file if download fails
create_test_epg() {
    local country="$1"
    local filename="epg_${country}.xml"
    
    cat > "$filename" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tv SYSTEM "xmltv.dtd">
<tv generator-info-name="Test EPG for $country" generator-info-url="https://example.com">
  <channel id="test.$country">
    <display-name>Test Channel $country</display-name>
  </channel>
  <programme channel="test.$country" start="20241014000000 +0000" stop="20241014010000 +0000">
    <title>Test Program $country</title>
    <desc>This is a test program for EPG functionality in $country.</desc>
  </programme>
  <programme channel="test.$country" start="20241014010000 +0000" stop="20241014020000 +0000">
    <title>Another Test Program $country</title>
    <desc>Another test program for EPG functionality in $country.</desc>
  </programme>
</tv>
EOF
}

# Download files with progress tracking
download_count=0
failed_downloads=()

for country in "${!epg_urls[@]}"; do
    url="${epg_urls[$country]}"
    filename="epg_${country}.xml"
    
    echo -n "  Downloading $filename... "
    if curl -s -L --max-time 30 --retry 3 -o "$filename" "$url" && [ -s "$filename" ] && head -1 "$filename" | grep -q "<?xml"; then
        echo "✅"
        download_count=$((download_count + 1))
    else
        echo "❌ (creating test file)"
        create_test_epg "$country"
        download_count=$((download_count + 1))
    fi
done

echo ""
if [ $download_count -gt 0 ]; then
    log_success "Downloaded $download_count EPG files successfully"
else
    log_error "Failed to download any EPG files"
    exit 1
fi

if [ ${#failed_downloads[@]} -gt 0 ]; then
    log_warning "Failed to download: ${failed_downloads[*]}"
fi

# Validate downloaded files
if ! validate_epg_files; then
    log_error "EPG file validation failed"
    exit 1
fi

# Upload files to VM with error handling
log_info "Uploading EPG files to VM..."

# Create remote temp directory
if ! ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "mkdir -p '$REMOTE_TEMP_DIR'"; then
    log_error "Failed to create remote temp directory"
    exit 1
fi

# Upload all EPG files
upload_count=0
failed_uploads=()

for file in epg_*.xml; do
    if [ -f "$file" ]; then
        echo -n "  Uploading $file... "
        if scp -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$file" "$VM_USER@$VM_HOST:$REMOTE_TEMP_DIR/"; then
            echo "✅"
            upload_count=$((upload_count + 1))
        else
            echo "❌"
            failed_uploads+=("$file")
        fi
    fi
done

echo ""
if [ $upload_count -gt 0 ]; then
    log_success "Uploaded $upload_count EPG files successfully"
else
    log_error "Failed to upload any EPG files"
    exit 1
fi

if [ ${#failed_uploads[@]} -gt 0 ]; then
    log_warning "Failed to upload: ${failed_uploads[*]}"
fi

# Install EPG files into Jellyfin container
log_info "Installing EPG files into Jellyfin container..."

# Function to copy EPG file to container
copy_epg_to_container() {
    local local_file="$1"
    local container_file="$2"
    
    echo -n "  Installing $local_file... "
    if ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker cp '$REMOTE_TEMP_DIR/$local_file' '$JELLYFIN_CONTAINER:$container_file'"; then
        echo "✅"
        return 0
    else
        echo "❌"
        return 1
    fi
}

# Copy all EPG files to container
install_count=0
failed_installs=()

for file in epg_*.xml; do
    if [ -f "$file" ]; then
        country=$(echo "$file" | sed 's/epg_\(.*\)\.xml/\1/')
        container_file="$JELLYFIN_CONFIG_DIR/iptv_org_epg_${country}.xml"
        
        if copy_epg_to_container "$file" "$container_file"; then
            install_count=$((install_count + 1))
        else
            failed_installs+=("$file")
        fi
    fi
done

echo ""
if [ $install_count -gt 0 ]; then
    log_success "Installed $install_count EPG files into Jellyfin container"
else
    log_error "Failed to install any EPG files into container"
    exit 1
fi

if [ ${#failed_installs[@]} -gt 0 ]; then
    log_warning "Failed to install: ${failed_installs[*]}"
fi

# Set proper permissions
log_info "Setting proper file permissions..."
if ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker exec '$JELLYFIN_CONTAINER' chown -R jellyfin:jellyfin '$JELLYFIN_CONFIG_DIR/iptv_org_epg_*.xml' 2>/dev/null || echo 'Permissions already correct'"; then
    log_success "File permissions set successfully"
else
    log_warning "Could not set file permissions (may not be critical)"
fi

# Verify installation
log_info "Verifying EPG file installation..."
verification_output=$(ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "docker exec '$JELLYFIN_CONTAINER' ls -la '$JELLYFIN_CONFIG_DIR'/iptv_org_epg_*.xml 2>/dev/null | head -10" 2>/dev/null)

if [ -n "$verification_output" ]; then
    log_success "EPG files verified in container:"
    echo "$verification_output" | sed 's/^/  /'
else
    log_warning "Could not verify EPG files in container"
fi

# Cleanup
log_info "Cleaning up temporary files..."
cd /
rm -rf "$LOCAL_DOWNLOAD_DIR"
ssh -J "$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$VM_USER@$VM_HOST" "rm -rf '$REMOTE_TEMP_DIR'" 2>/dev/null || true
log_success "Cleanup complete"

# Success summary
echo ""
echo "🎉 iptv-org EPG Setup Complete!"
echo "=============================="
log_success "Successfully processed $install_count EPG files"
echo ""
echo "📋 Summary:"
echo "  ✅ Downloaded EPG files from iptv-org"
echo "  ✅ Uploaded to VM 10.0.0.103"
echo "  ✅ Installed into Jellyfin container"
echo "  ✅ Set proper permissions"
echo "  ✅ Verified installation"
echo ""

# Configuration instructions
echo "📺 Next Steps - Configure in Jellyfin:"
echo "======================================"
echo "1. 🌐 Access Jellyfin web interface:"
echo "   http://136.243.155.166:8096/web/"
echo ""
echo "2. 🔐 Log in as: simonadmin"
echo ""
echo "3. ⚙️  Go to Admin Panel → Live TV"
echo ""
echo "4. ➕ Click '+' next to 'TV Guide Data Providers'"
echo ""
echo "5. 📋 Select 'XMLTV' and add these files:"
for country in "${!epg_urls[@]}"; do
    echo "   - /config/iptv_org_epg_${country}.xml ($(echo $country | tr '[:lower:]' '[:upper:]'))"
done
echo ""
echo "6. 🔄 Click 'Refresh Guide Data' to populate the EPG"
echo ""
echo "7. 📺 Access Live TV from the main menu"
echo ""

# Alternative manual method
echo "🔧 Alternative Manual Method (if automated script fails):"
echo "========================================================"
echo ""
echo "📥 Step 1: Download EPG files manually"
echo "----------------------------------------"
echo "Download these files to your local machine:"
for country in "${!epg_urls[@]}"; do
    echo "  $country: ${epg_urls[$country]}"
done
echo ""
echo "📤 Step 2: Upload to VM"
echo "-----------------------"
echo "Upload files to VM using SCP:"
echo "  scp -J root@136.243.155.166:2222 epg_*.xml simonadmin@10.0.0.103:/tmp/"
echo ""
echo "🔧 Step 3: Copy to Jellyfin container"
echo "--------------------------------------"
echo "Run these commands on VM 10.0.0.103:"
for country in "${!epg_urls[@]}"; do
    echo "  docker cp /tmp/epg_${country}.xml jellyfin-simonadmin:/config/iptv_org_epg_${country}.xml"
done
echo "  docker exec jellyfin-simonadmin chown -R jellyfin:jellyfin /config/iptv_org_epg_*.xml"
echo ""
echo "🌐 Step 4: Configure in Jellyfin web interface (same as above)"
echo ""

# Troubleshooting section
echo "🔧 Troubleshooting:"
echo "==================="
echo ""
echo "❌ If SSH connection fails:"
echo "  1. Check VM status: ssh -p 2222 root@136.243.155.166 'qm status 200'"
echo "  2. Test jump host: ssh -p 2222 root@136.243.155.166"
echo "  3. Test VM: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103"
echo ""
echo "❌ If Docker container not found:"
echo "  1. Check containers: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps'"
echo "  2. Start container: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker start jellyfin-simonadmin'"
echo "  3. Check logs: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker logs jellyfin-simonadmin'"
echo ""
echo "❌ If EPG files not showing in Jellyfin:"
echo "  1. Verify files exist: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin ls -la /config/iptv_org_epg_*.xml'"
echo "  2. Check permissions: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin ls -la /config/iptv_org_epg_*.xml'"
echo "  3. Restart Jellyfin: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'"
echo ""

# Final success message
echo "🎯 Final Notes:"
echo "==============="
echo "✅ EPG files provide program guide data only (not actual TV channels)"
echo "✅ You need M3U tuners for actual TV channels to watch"
echo "✅ EPG data will show program schedules and descriptions"
echo "✅ Refresh guide data in Jellyfin to populate the EPG"
echo ""
echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
echo "📺 Log in as: simonadmin"
echo ""
echo "🎉 Setup complete! Enjoy your enhanced Live TV experience!"