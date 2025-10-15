#!/bin/bash

#############################################################################
# IPTV Channel Organizer and Validator
#############################################################################
# This script will:
# 1. Test all channels from your playlists (1-100 at a time)
# 2. Remove non-working channels
# 3. Organize channels into categories
# 4. Create clean, working playlists for Jellyfin
#############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VM_IP="10.0.0.103"
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
CONTAINER="jellyfin-simonadmin"
TEMP_DIR="/tmp/iptv_organizer"
OUTPUT_DIR="/tmp/iptv_clean"

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}IPTV Channel Organizer and Validator${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

# Create temp directories
mkdir -p "$TEMP_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to test a channel URL
test_channel() {
    local url="$1"
    local timeout=5
    
    # Try to fetch headers from the stream URL
    if timeout $timeout curl -s -I -L "$url" 2>/dev/null | grep -q "200\|302\|301"; then
        return 0  # Working
    else
        return 1  # Not working
    fi
}

# Function to extract channels from M3U
extract_channels() {
    local m3u_file="$1"
    local category="$2"
    local output_file="$3"
    local max_channels="${4:-100}"
    
    echo -e "${YELLOW}Processing $category...${NC}"
    
    local count=0
    local working=0
    local failed=0
    
    # Write M3U header
    echo "#EXTM3U" > "$output_file"
    
    # Parse M3U file
    local extinf_line=""
    while IFS= read -r line; do
        if [[ $line == "#EXTINF:"* ]]; then
            extinf_line="$line"
        elif [[ $line =~ ^https?:// ]] && [[ -n $extinf_line ]]; then
            count=$((count + 1))
            
            # Only process up to max_channels
            if [ $count -le $max_channels ]; then
                echo -ne "${BLUE}Testing channel $count/$max_channels...${NC}\r"
                
                # Test the channel
                if test_channel "$line"; then
                    echo "$extinf_line" >> "$output_file"
                    echo "$line" >> "$output_file"
                    working=$((working + 1))
                    echo -ne "${GREEN}✓ Channel $count: Working ($working working, $failed failed)${NC}\r"
                else
                    failed=$((failed + 1))
                    echo -ne "${RED}✗ Channel $count: Failed ($working working, $failed failed)${NC}\r"
                fi
            fi
            
            extinf_line=""
        fi
    done < "$m3u_file"
    
    echo ""
    echo -e "${GREEN}✅ $category: $working working channels (tested $count, failed $failed)${NC}"
}

# Download current playlists from container
echo -e "${YELLOW}Step 1: Downloading current playlists from Jellyfin...${NC}"

ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'
    docker exec jellyfin-simonadmin sh -c 'cd /config/data/playlists && tar czf /tmp/playlists_backup.tar.gz iptv_org_*.m3u 2>/dev/null || true'
ENDSSH

scp -o "ProxyJump root@${PROXY_HOST}" ${VM_USER}@${VM_IP}:/tmp/playlists_backup.tar.gz "$TEMP_DIR/" 2>/dev/null || {
    echo -e "${RED}❌ Failed to download playlists. They may not exist yet.${NC}"
    exit 1
}

# Extract playlists
cd "$TEMP_DIR"
tar xzf playlists_backup.tar.gz 2>/dev/null || true

echo -e "${GREEN}✅ Downloaded playlists${NC}"
echo ""

# Organize by category
echo -e "${YELLOW}Step 2: Testing and organizing channels...${NC}"
echo ""

# Define categories with patterns to match
declare -A CATEGORIES=(
    ["News"]="news|cnn|bbc|fox news|msnbc|cnbc|sky news|france 24"
    ["Sports"]="sport|espn|fox sports|nba|nfl|mlb|soccer|football|tennis|golf|racing"
    ["Movies"]="movie|cinema|film|hollywood"
    ["Kids"]="kids|children|cartoon|disney|nickelodeon|cartoon network|baby"
    ["Music"]="music|mtv|vh1|vevo|radio"
    ["Entertainment"]="entertainment|e!|tlc|bravo|lifetime|comedy|drama"
    ["Documentary"]="discovery|national geographic|history|science|nature|documentary"
    ["Lifestyle"]="food|cooking|travel|home|garden|fashion|lifestyle"
)

# Process main playlists
for playlist_type in "categories" "international" "languages" "countries"; do
    if [ -f "iptv_org_${playlist_type}.m3u" ]; then
        echo -e "${BLUE}Processing iptv_org_${playlist_type}.m3u...${NC}"
        
        # For large playlists, extract by category
        for category in "${!CATEGORIES[@]}"; do
            pattern="${CATEGORIES[$category]}"
            
            # Extract channels matching this category
            grep -i -E "$pattern" "iptv_org_${playlist_type}.m3u" > "${OUTPUT_DIR}/temp_${category}.m3u" 2>/dev/null || continue
            
            # Test first 100 channels in this category
            if [ -s "${OUTPUT_DIR}/temp_${category}.m3u" ]; then
                extract_channels "${OUTPUT_DIR}/temp_${category}.m3u" "$category" "${OUTPUT_DIR}/${category}_working.m3u" 100
            fi
        done
    fi
done

# Process country-specific playlists (already manageable size)
for country in us uk de fr es it ca au; do
    if [ -f "iptv_org_country_${country}.m3u" ]; then
        country_upper=$(echo $country | tr '[:lower:]' '[:upper:]')
        echo -e "${BLUE}Processing country: $country_upper...${NC}"
        extract_channels "iptv_org_country_${country}.m3u" "$country_upper" "${OUTPUT_DIR}/${country_upper}_working.m3u" 200
    fi
done

echo ""
echo -e "${YELLOW}Step 3: Creating optimized playlists...${NC}"

# Combine all working channels into category-based playlists
for category in "${!CATEGORIES[@]}"; do
    if [ -f "${OUTPUT_DIR}/${category}_working.m3u" ]; then
        channel_count=$(grep -c "^http" "${OUTPUT_DIR}/${category}_working.m3u" 2>/dev/null || echo "0")
        if [ "$channel_count" -gt 0 ]; then
            echo -e "${GREEN}✅ $category: $channel_count working channels${NC}"
        fi
    fi
done

echo ""
echo -e "${YELLOW}Step 4: Uploading clean playlists to Jellyfin...${NC}"

# Upload working playlists
scp -o "ProxyJump root@${PROXY_HOST}" ${OUTPUT_DIR}/*_working.m3u ${VM_USER}@${VM_IP}:/tmp/

# Install to container
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'
    docker exec jellyfin-simonadmin mkdir -p /config/data/playlists/clean
    docker exec jellyfin-simonadmin sh -c 'cp /tmp/*_working.m3u /config/data/playlists/clean/ 2>/dev/null || true'
    docker exec jellyfin-simonadmin sh -c 'chown -R 1000:1000 /config/data/playlists/clean 2>/dev/null || true'
ENDSSH

echo -e "${GREEN}✅ Uploaded clean playlists${NC}"
echo ""

# Create summary
echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""
echo -e "${YELLOW}Clean playlists created in: /config/data/playlists/clean/${NC}"
echo ""
echo -e "${GREEN}Working channels by category:${NC}"

for category in "${!CATEGORIES[@]}"; do
    if [ -f "${OUTPUT_DIR}/${category}_working.m3u" ]; then
        channel_count=$(grep -c "^http" "${OUTPUT_DIR}/${category}_working.m3u" 2>/dev/null || echo "0")
        if [ "$channel_count" -gt 0 ]; then
            echo -e "  • ${category}: ${GREEN}${channel_count}${NC} channels"
        fi
    fi
done

echo ""
echo -e "${YELLOW}Country-specific playlists:${NC}"
for country in US UK DE FR ES IT CA AU; do
    if [ -f "${OUTPUT_DIR}/${country}_working.m3u" ]; then
        channel_count=$(grep -c "^http" "${OUTPUT_DIR}/${country}_working.m3u" 2>/dev/null || echo "0")
        if [ "$channel_count" -gt 0 ]; then
            echo -e "  • ${country}: ${GREEN}${channel_count}${NC} channels"
        fi
    fi
done

echo ""
echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}Next Steps${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""
echo "1. Access Jellyfin: http://136.243.155.166:8096/web/"
echo "2. Go to: Admin Dashboard → Live TV → Tuners"
echo "3. Delete old large tuners (11,000+ channels)"
echo "4. Add new tuners from: /config/data/playlists/clean/"
echo ""
echo "Example tuners to add:"
echo "  • /config/data/playlists/clean/News_working.m3u"
echo "  • /config/data/playlists/clean/Sports_working.m3u"
echo "  • /config/data/playlists/clean/Movies_working.m3u"
echo "  • /config/data/playlists/clean/US_working.m3u"
echo ""
echo -e "${GREEN}✅ Channel organization complete!${NC}"
echo ""
