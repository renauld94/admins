#!/bin/bash
#
# IPTV Channel Organizer - Create Category-Based Playlists
# This script filters the large IPTV playlist into manageable categories
#

set -e

# Configuration
VM_USER="simonadmin"
VM_IP="10.0.0.103"
PROXY_HOST="root@136.243.155.166"
PROXY_PORT="2222"
CONTAINER_NAME="jellyfin-simonadmin"
TEMP_DIR="/tmp/iptv_organize_$$"
VM_TEMP_DIR="/tmp/iptv_organize"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     IPTV Channel Organizer - Create Popular Categories   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Create temp directory
mkdir -p "$TEMP_DIR"

echo -e "${YELLOW}Step 1: Downloading current playlists from Jellyfin...${NC}"

# Download international playlist (most comprehensive)
scp -o ProxyJump=${PROXY_HOST}:${PROXY_PORT} \
    ${VM_USER}@${VM_IP}:/tmp/jellyfin_playlist_backup.m3u "$TEMP_DIR/" 2>/dev/null || \
ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} \
    "docker cp ${CONTAINER_NAME}:/config/data/playlists/iptv_org_international.m3u /tmp/jellyfin_playlist_backup.m3u" && \
scp -o ProxyJump=${PROXY_HOST}:${PROXY_PORT} \
    ${VM_USER}@${VM_IP}:/tmp/jellyfin_playlist_backup.m3u "$TEMP_DIR/"

SOURCE_PLAYLIST="$TEMP_DIR/jellyfin_playlist_backup.m3u"

if [[ ! -f "$SOURCE_PLAYLIST" ]]; then
    echo -e "${YELLOW}✗ Could not download playlist. Using local filtering...${NC}"
    exit 1
fi

TOTAL_CHANNELS=$(grep -c "^#EXTINF" "$SOURCE_PLAYLIST")
echo -e "${GREEN}✓ Downloaded playlist with $TOTAL_CHANNELS channels${NC}"
echo

echo -e "${YELLOW}Step 2: Creating category-based playlists...${NC}"

# Function to create filtered playlist
create_category_playlist() {
    local category=$1
    local pattern=$2
    local output_file="$TEMP_DIR/popular_${category}.m3u"
    
    echo "#EXTM3U" > "$output_file"
    
    # Extract channels matching the pattern
    awk -v pattern="$pattern" '
        /^#EXTINF/ {
            line = $0
            getline url
            if (tolower(line) ~ pattern) {
                print line
                print url
            }
        }
    ' "$SOURCE_PLAYLIST" >> "$output_file"
    
    local count=$(grep -c "^#EXTINF" "$output_file" 2>/dev/null || echo "0")
    echo -e "  ${GREEN}✓${NC} ${category}: $count channels"
    
    # Only keep if we found channels
    if [[ $count -eq 0 ]]; then
        rm "$output_file"
    fi
}

# Create popular category playlists
echo "Creating filtered playlists:"

create_category_playlist "news" "news|cnn|bbc|fox news|msnbc|cnbc|sky news|al jazeera"
create_category_playlist "sports" "sport|espn|tsn|bein|fox sports|nba|nfl|mlb|nhl|soccer|football"
create_category_playlist "movies" "movie|cinema|film|hbo|showtime|starz"
create_category_playlist "entertainment" "entertainment|e!|bravo|tlc|lifetime|hallmark"
create_category_playlist "kids" "kids|cartoon|disney|nickelodeon|nick jr|pbs kids|baby"
create_category_playlist "music" "music|mtv|vh1|vevo|bet|fuse"
create_category_playlist "documentary" "discover|history|nat geo|smithsonian|science|animal planet"
create_category_playlist "lifestyle" "food|hgtv|diy|travel|cooking|home"

echo
echo -e "${YELLOW}Step 3: Uploading organized playlists to Jellyfin...${NC}"

# Upload to VM
ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} "mkdir -p ${VM_TEMP_DIR}"

for playlist in "$TEMP_DIR"/popular_*.m3u; do
    if [[ -f "$playlist" ]]; then
        filename=$(basename "$playlist")
        scp -o ProxyJump=${PROXY_HOST}:${PROXY_PORT} "$playlist" ${VM_USER}@${VM_IP}:${VM_TEMP_DIR}/
        ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} \
            "docker cp ${VM_TEMP_DIR}/${filename} ${CONTAINER_NAME}:/config/data/playlists/"
        echo -e "  ${GREEN}✓${NC} Uploaded: $filename"
    fi
done

echo
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                ✓ Organization Complete!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo
echo "Created category playlists in: /config/data/playlists/"
echo
echo "Add these tuners in Jellyfin:"
for playlist in "$TEMP_DIR"/popular_*.m3u; do
    if [[ -f "$playlist" ]]; then
        filename=$(basename "$playlist")
        echo "  • /config/data/playlists/$filename"
    fi
done
echo
echo "Go to: http://136.243.155.166:8096/web/"
echo "Admin Dashboard → Live TV → Add Tuner → M3U Tuner"
echo

# Cleanup
rm -rf "$TEMP_DIR"
ssh -J ${PROXY_HOST}:${PROXY_PORT} ${VM_USER}@${VM_IP} "rm -rf ${VM_TEMP_DIR}"

exit 0
