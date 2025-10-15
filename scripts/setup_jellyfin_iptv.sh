#!/bin/bash
#
# Jellyfin IPTV Setup Script
# Downloads and configures IPTV channels from iptv-org/awesome-iptv
# Target: VM 200 (10.0.0.103) - Jellyfin Container
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VM_USER="simonadmin"
VM_IP="10.0.0.103"
PROXY_HOST="root@136.243.155.166"
PROXY_PORT="2222"
CONTAINER_NAME="jellyfin-simonadmin"
TEMP_DIR="/tmp/jellyfin-iptv-$$"
VM_TEMP_DIR="/tmp/jellyfin-iptv"

# IPTV Sources from iptv-org
declare -A IPTV_SOURCES=(
    ["international"]="https://iptv-org.github.io/iptv/index.m3u"
    ["categories"]="https://iptv-org.github.io/iptv/index.category.m3u"
    ["languages"]="https://iptv-org.github.io/iptv/index.language.m3u"
    ["countries"]="https://iptv-org.github.io/iptv/index.country.m3u"
)

# Specific country playlists
declare -A COUNTRY_PLAYLISTS=(
    ["us"]="https://iptv-org.github.io/iptv/countries/us.m3u"
    ["uk"]="https://iptv-org.github.io/iptv/countries/uk.m3u"
    ["de"]="https://iptv-org.github.io/iptv/countries/de.m3u"
    ["fr"]="https://iptv-org.github.io/iptv/countries/fr.m3u"
    ["es"]="https://iptv-org.github.io/iptv/countries/es.m3u"
    ["it"]="https://iptv-org.github.io/iptv/countries/it.m3u"
    ["ca"]="https://iptv-org.github.io/iptv/countries/ca.m3u"
    ["au"]="https://iptv-org.github.io/iptv/countries/au.m3u"
)

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Jellyfin IPTV Setup - iptv-org Integration           ║${NC}"
echo -e "${BLUE}║     Target: VM 200 (10.0.0.103)                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "info")
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        "success")
            echo -e "${GREEN}[✓]${NC} $message"
            ;;
        "error")
            echo -e "${RED}[✗]${NC} $message"
            ;;
        "warning")
            echo -e "${YELLOW}[!]${NC} $message"
            ;;
    esac
}

# Pre-flight checks
print_status "info" "Running pre-flight checks..."

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    print_status "error" "curl is not installed. Please install it first."
    exit 1
fi
print_status "success" "curl is available"

# Check SSH connectivity
print_status "info" "Testing SSH connection to VM 200..."
if ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} -o ConnectTimeout=10 "exit" &> /dev/null; then
    print_status "success" "SSH connection successful"
else
    print_status "error" "Cannot connect to VM 200 via SSH"
    echo
    echo "Try manually:"
    echo "  ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP}"
    exit 1
fi

# Check Docker container status
print_status "info" "Checking Jellyfin container status..."
CONTAINER_STATUS=$(ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} "docker ps --filter name=${CONTAINER_NAME} --format '{{.Status}}'" 2>/dev/null)
if [[ -z "$CONTAINER_STATUS" ]]; then
    print_status "error" "Jellyfin container '${CONTAINER_NAME}' is not running"
    exit 1
fi
print_status "success" "Container is running: $CONTAINER_STATUS"

# Create temporary directories
print_status "info" "Creating temporary directories..."
mkdir -p "$TEMP_DIR"
ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} "mkdir -p ${VM_TEMP_DIR}"
print_status "success" "Temporary directories created"

echo
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Step 1: Downloading IPTV Playlists${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo

# Download main IPTV sources
for name in "${!IPTV_SOURCES[@]}"; do
    url="${IPTV_SOURCES[$name]}"
    output_file="$TEMP_DIR/iptv_org_${name}.m3u"
    
    print_status "info" "Downloading ${name} playlist..."
    if curl -L -f -s --max-time 60 "$url" -o "$output_file"; then
        if [[ -s "$output_file" ]]; then
            SIZE=$(du -h "$output_file" | cut -f1)
            CHANNELS=$(grep -c "^#EXTINF" "$output_file" || echo "0")
            print_status "success" "${name}: $SIZE, $CHANNELS channels"
        else
            print_status "warning" "${name}: Downloaded but empty"
            rm -f "$output_file"
        fi
    else
        print_status "error" "Failed to download ${name}"
    fi
done

# Download country-specific playlists
echo
print_status "info" "Downloading country-specific playlists..."
for country in "${!COUNTRY_PLAYLISTS[@]}"; do
    url="${COUNTRY_PLAYLISTS[$country]}"
    output_file="$TEMP_DIR/iptv_org_country_${country}.m3u"
    
    if curl -L -f -s --max-time 30 "$url" -o "$output_file" 2>/dev/null; then
        if [[ -s "$output_file" ]]; then
            CHANNELS=$(grep -c "^#EXTINF" "$output_file" || echo "0")
            print_status "success" "${country^^}: $CHANNELS channels"
        else
            rm -f "$output_file"
        fi
    fi
done

# Count total files downloaded
TOTAL_FILES=$(ls -1 "$TEMP_DIR"/*.m3u 2>/dev/null | wc -l)
if [[ $TOTAL_FILES -eq 0 ]]; then
    print_status "error" "No playlist files were successfully downloaded"
    rm -rf "$TEMP_DIR"
    exit 1
fi
print_status "success" "Total playlists downloaded: $TOTAL_FILES"

echo
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Step 2: Uploading to VM 200${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo

# Upload files to VM
print_status "info" "Uploading playlists to VM..."
if scp -o ProxyJump=${PROXY_HOST}:${PROXY_PORT} "$TEMP_DIR"/*.m3u ${VM_USER}@${VM_IP}:${VM_TEMP_DIR}/ &>/dev/null; then
    print_status "success" "Upload completed"
else
    print_status "error" "Upload failed"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Step 3: Installing to Jellyfin Container${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo

# Copy files to container
print_status "info" "Copying playlists to Jellyfin container..."
ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} << 'EOF'
for file in /tmp/jellyfin-iptv/*.m3u; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        docker cp "$file" jellyfin-simonadmin:/config/data/playlists/
        echo "  ✓ Installed: $filename"
    fi
done

# Set proper permissions
docker exec jellyfin-simonadmin chown -R jellyfin:jellyfin /config/data/playlists/
docker exec jellyfin-simonadmin chmod -R 644 /config/data/playlists/*.m3u
EOF

print_status "success" "Playlists installed to container"

# Verify installation
print_status "info" "Verifying installation..."
INSTALLED_COUNT=$(ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} \
    "docker exec ${CONTAINER_NAME} ls -1 /config/data/playlists/iptv_org_*.m3u 2>/dev/null | wc -l")
print_status "success" "Verified: $INSTALLED_COUNT playlists in container"

echo
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Step 4: Cleanup${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo

# Cleanup
print_status "info" "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"
ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} "rm -rf ${VM_TEMP_DIR}"
print_status "success" "Cleanup completed"

echo
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 ✓ SETUP COMPLETED                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Access Jellyfin: http://136.243.155.166:8096/web/"
echo "2. Or via tunnel: https://jellyfin.simondatalab.de (after adding route)"
echo "3. Login as: simonadmin"
echo "4. Navigate to: Admin Dashboard → Live TV"
echo "5. Click: Add Tuner → M3U Tuner"
echo "6. Select playlists from: /config/data/playlists/"
echo
echo -e "${YELLOW}Installed Playlists:${NC}"
ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} \
    "docker exec ${CONTAINER_NAME} ls -lh /config/data/playlists/iptv_org_*.m3u 2>/dev/null" | \
    awk '{print "  • " $9 " (" $5 ")"}'
echo
echo -e "${BLUE}To refresh in Jellyfin:${NC}"
echo "  Admin Dashboard → Scheduled Tasks → Refresh Guide"
echo

exit 0
