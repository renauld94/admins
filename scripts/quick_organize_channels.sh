#!/bin/bash

#############################################################################
# QUICK IPTV Channel Organizer (No Testing - Category-Based)
#############################################################################
# This script organizes your 11,000+ channels into manageable categories
# WITHOUT testing each one (much faster!)
# You can manually remove non-working channels later as you find them
#############################################################################

set -e

# Configuration
VM_IP="10.0.0.103"
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
CONTAINER="jellyfin-simonadmin"

echo "============================================================================"
echo "QUICK IPTV Channel Organizer"
echo "============================================================================"
echo ""
echo "This will organize your channels by category WITHOUT testing them."
echo "This is MUCH faster (minutes vs hours) but some channels may not work."
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "📦 Creating organized playlists on VM..."

# Run organization directly on VM
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'

# Create clean directory
docker exec jellyfin-simonadmin mkdir -p /config/data/playlists/clean

# Define categories with grep patterns
declare -A CATEGORIES=(
    ["News"]="news|cnn|bbc|fox.news|msnbc|cnbc|sky.news|france.24|nbc.news|abc.news"
    ["Sports"]="sport|espn|fox.sports|nba|nfl|mlb|nhl|soccer|football|tennis|golf|racing|fifa|uefa"
    ["Movies"]="movie|cinema|film|hollywood|hbo|cinemax|showtime|starz"
    ["Kids"]="kids|child|cartoon|disney|nickelodeon|cartoon.network|baby|pbs.kids"
    ["Music"]="music|mtv|vh1|vevo|radio"
    ["Entertainment"]="entertainment|tlc|bravo|lifetime|comedy|amc|fx|usa.network"
    ["Documentary"]="discovery|national.geographic|history|science|nature|documentary|animal.planet"
    ["Lifestyle"]="food|cooking|travel|home|garden|fashion|hgtv|diy"
)

# Function to extract channels by pattern
extract_by_category() {
    local source_file="$1"
    local category="$2"
    local pattern="$3"
    local output_file="/config/data/playlists/clean/${category}_channels.m3u"
    
    echo "Processing $category from $(basename $source_file)..."
    
    # Initialize output file with header
    echo "#EXTM3U" > "$output_file"
    
    # Extract matching channels
    awk -v pattern="$pattern" '
        BEGIN {IGNORECASE=1}
        /^#EXTINF:/ {extinf=$0; next}
        /^https?:\/\// {
            if (extinf && extinf ~ pattern) {
                print extinf
                print $0
            }
            extinf=""
        }
    ' "$source_file" >> "$output_file"
    
    # Count channels
    local count=$(grep -c "^http" "$output_file" 2>/dev/null || echo "0")
    echo "  ✓ $category: $count channels"
}

echo "============================================================================"
echo "Organizing channels by category..."
echo "============================================================================"
echo ""

# Process each category from the main playlists
for category in News Sports Movies Kids Music Entertainment Documentary Lifestyle; do
    case $category in
        News) pattern="news|cnn|bbc|fox.news|msnbc|cnbc|sky.news|france.24|nbc.news|abc.news" ;;
        Sports) pattern="sport|espn|fox.sports|nba|nfl|mlb|nhl|soccer|football|tennis|golf|racing|fifa|uefa" ;;
        Movies) pattern="movie|cinema|film|hollywood|hbo|cinemax|showtime|starz" ;;
        Kids) pattern="kids|child|cartoon|disney|nickelodeon|cartoon.network|baby|pbs.kids" ;;
        Music) pattern="music|mtv|vh1|vevo|radio" ;;
        Entertainment) pattern="entertainment|tlc|bravo|lifetime|comedy|amc|fx|usa.network" ;;
        Documentary) pattern="discovery|national.geographic|history|science|nature|documentary|animal.planet" ;;
        Lifestyle) pattern="food|cooking|travel|home|garden|fashion|hgtv|diy" ;;
    esac
    
    # Start with empty file
    docker exec jellyfin-simonadmin sh -c "echo '#EXTM3U' > /config/data/playlists/clean/${category}_channels.m3u"
    
    # Extract from each source playlist
    for source in /config/data/playlists/iptv_org_*.m3u; do
        if [ -f "$source" ] && [ "$(basename $source)" != "iptv_org_country_"* ]; then
            docker exec jellyfin-simonadmin awk -v pattern="$pattern" '
                BEGIN {IGNORECASE=1}
                /^#EXTINF:/ {extinf=$0; next}
                /^https?:\/\// {
                    if (extinf && extinf ~ pattern) {
                        print extinf
                        print $0
                    }
                    extinf=""
                }
            ' "$source" >> "/config/data/playlists/clean/${category}_channels.m3u"
        fi
    done
    
    # Remove duplicates (same URL)
    docker exec jellyfin-simonadmin sh -c "
        awk '
            /^#EXTM3U/ {print; next}
            /^#EXTINF:/ {extinf=\$0; next}
            /^https?:\/\// {
                if (!seen[\$0]) {
                    if (extinf) print extinf
                    print
                    seen[\$0]=1
                }
                extinf=\"\"
            }
        ' /config/data/playlists/clean/${category}_channels.m3u > /tmp/${category}_dedup.m3u
        mv /tmp/${category}_dedup.m3u /config/data/playlists/clean/${category}_channels.m3u
    "
    
    # Count and report
    COUNT=$(docker exec jellyfin-simonadmin grep -c "^http" "/config/data/playlists/clean/${category}_channels.m3u" 2>/dev/null || echo "0")
    echo "✓ $category: $COUNT channels"
done

echo ""
echo "============================================================================"
echo "Creating country-specific playlists..."
echo "============================================================================"
echo ""

# Copy country-specific playlists (already reasonable size)
for country in us uk de fr es it ca au; do
    COUNTRY_UPPER=$(echo $country | tr '[:lower:]' '[:upper:]')
    if docker exec jellyfin-simonadmin test -f "/config/data/playlists/iptv_org_country_${country}.m3u"; then
        docker exec jellyfin-simonadmin cp "/config/data/playlists/iptv_org_country_${country}.m3u" "/config/data/playlists/clean/${COUNTRY_UPPER}_channels.m3u"
        COUNT=$(docker exec jellyfin-simonadmin grep -c "^http" "/config/data/playlists/clean/${COUNTRY_UPPER}_channels.m3u" 2>/dev/null || echo "0")
        echo "✓ $COUNTRY_UPPER: $COUNT channels"
    fi
done

echo ""
echo "============================================================================"
echo "Creating combined 'Best Of' playlist (top 500 popular channels)..."
echo "============================================================================"
echo ""

# Create a "Best Of" playlist with most popular channels
docker exec jellyfin-simonadmin sh -c "echo '#EXTM3U' > /config/data/playlists/clean/BEST_OF_500.m3u"

# Popular channel keywords
POPULAR_KEYWORDS="cnn|bbc|espn|nbc|abc|cbs|fox|hbo|mtv|discovery|disney|nickelodeon|national.geographic|sky|france.24|euronews|bloomberg|cnbc|al.jazeera"

# Extract popular channels from US playlist (most likely to work)
if docker exec jellyfin-simonadmin test -f "/config/data/playlists/iptv_org_country_us.m3u"; then
    docker exec jellyfin-simonadmin awk -v pattern="$POPULAR_KEYWORDS" '
        BEGIN {IGNORECASE=1; count=0}
        /^#EXTINF:/ {extinf=$0; next}
        /^https?:\/\// {
            if (count < 500 && extinf && extinf ~ pattern) {
                print extinf
                print $0
                count++
            }
            extinf=""
        }
    ' /config/data/playlists/iptv_org_country_us.m3u >> /config/data/playlists/clean/BEST_OF_500.m3u
fi

# Fill remaining with international popular channels
docker exec jellyfin-simonadmin awk -v pattern="$POPULAR_KEYWORDS" '
    BEGIN {IGNORECASE=1}
    /^#EXTINF:/ {extinf=$0; next}
    /^https?:\/\// {
        if (extinf && extinf ~ pattern) {
            print extinf
            print $0
        }
        extinf=""
    }
' /config/data/playlists/iptv_org_international.m3u | head -n 1000 >> /config/data/playlists/clean/BEST_OF_500.m3u

# Remove duplicates
docker exec jellyfin-simonadmin sh -c "
    awk '
        /^#EXTM3U/ {print; next}
        /^#EXTINF:/ {extinf=\$0; next}
        /^https?:\/\// {
            if (!seen[\$0]) {
                if (extinf) print extinf
                print
                seen[\$0]=1
            }
            extinf=\"\"
        }
    ' /config/data/playlists/clean/BEST_OF_500.m3u > /tmp/best_dedup.m3u
    head -n 1001 /tmp/best_dedup.m3u > /config/data/playlists/clean/BEST_OF_500.m3u
"

COUNT=$(docker exec jellyfin-simonadmin grep -c "^http" "/config/data/playlists/clean/BEST_OF_500.m3u" 2>/dev/null || echo "0")
echo "✓ BEST OF: $COUNT most popular channels"

echo ""
echo "Setting permissions..."
docker exec jellyfin-simonadmin chown -R 1000:1000 /config/data/playlists/clean 2>/dev/null || true

echo ""
echo "============================================================================"
echo "✅ Organization Complete!"
echo "============================================================================"

ENDSSH

echo ""
echo "============================================================================"
echo "📊 Summary"
echo "============================================================================"
echo ""
echo "✅ Created organized playlists in: /config/data/playlists/clean/"
echo ""
echo "Available playlists:"
echo "  • BEST_OF_500.m3u          - Top 500 most popular channels"
echo "  • News_channels.m3u        - News channels"
echo "  • Sports_channels.m3u      - Sports channels"
echo "  • Movies_channels.m3u      - Movie channels"
echo "  • Kids_channels.m3u        - Kids/family channels"
echo "  • Music_channels.m3u       - Music channels"
echo "  • Entertainment_channels.m3u - Entertainment channels"
echo "  • Documentary_channels.m3u - Documentary channels"
echo "  • Lifestyle_channels.m3u   - Lifestyle channels"
echo "  • US_channels.m3u          - US channels"
echo "  • UK_channels.m3u          - UK channels"
echo "  • DE_channels.m3u          - German channels"
echo "  • FR_channels.m3u          - French channels"
echo ""
echo "============================================================================"
echo "📺 Next Steps in Jellyfin"
echo "============================================================================"
echo ""
echo "1. Open: http://136.243.155.166:8096/web/"
echo "2. Login as: simonadmin"
echo "3. Go to: Admin Dashboard → Live TV"
echo ""
echo "4. Click 'Tuners' tab"
echo "5. DELETE all old large tuners (the ones with 11,000+ channels)"
echo ""
echo "6. Click '+' to add new tuners:"
echo "   a) Start with: /config/data/playlists/clean/BEST_OF_500.m3u"
echo "   b) Add categories you want (News, Sports, Movies, etc.)"
echo "   c) Add country-specific (US, UK, DE, FR)"
echo ""
echo "7. Refresh guide data"
echo ""
echo "Recommended setup (manageable ~2,000 channels):"
echo "  ✓ BEST_OF_500.m3u"
echo "  ✓ News_channels.m3u"
echo "  ✓ Sports_channels.m3u  
echo "  ✓ Movies_channels.m3u"
echo "  ✓ US_channels.m3u (if you want US content)"
echo ""
echo "============================================================================"
echo "✅ Done! Your channels are now organized and de-duplicated."
echo "============================================================================"
echo ""
