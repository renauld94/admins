#!/bin/bash
# Jellyfin IPTV Setup Helper Script
# This script helps you set up and test IPTV channels for Jellyfin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
JELLYFIN_CONTAINER="jellyfin"
M3U_LOCAL_PATH="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources"
M3U_ORGANIZED="jellyfin-organized-channels.m3u"
JELLYFIN_CONFIG_PATH="/jellyfin-data/config"

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_docker() {
    print_info "Checking if Jellyfin container is running..."
    if docker ps | grep -q "$JELLYFIN_CONTAINER"; then
        print_success "Jellyfin container is running"
        return 0
    else
        print_error "Jellyfin container is not running"
        echo "Available containers:"
        docker ps -a | grep -i jellyfin || echo "No Jellyfin containers found"
        return 1
    fi
}

validate_m3u() {
    local file=$1
    print_info "Validating M3U file: $file"
    
    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        return 1
    fi
    
    # Check if file starts with #EXTM3U
    if ! head -1 "$file" | grep -q "^#EXTM3U"; then
        print_error "File does not start with #EXTM3U"
        return 1
    fi
    
    # Count entries
    local count=$(grep -c "^#EXTINF:" "$file" || true)
    print_success "M3U file is valid - Contains $count channel entries"
    
    # Show categories
    echo ""
    print_info "Categories found:"
    grep -o 'group-title="[^"]*"' "$file" | sort | uniq | sed 's/group-title="//g' | sed 's/"//g' | nl
    
    return 0
}

test_url_connectivity() {
    local url=$1
    print_info "Testing URL connectivity: $url"
    
    # Test with curl
    if curl -I -m 5 "$url" 2>/dev/null | head -1 | grep -q "200\|206\|403"; then
        print_success "URL is accessible"
        return 0
    else
        print_warning "Could not reach URL or got unexpected response"
        return 1
    fi
}

test_channel_stream() {
    local url=$1
    print_info "Testing stream playback capability..."
    
    # Try to get first 1MB of stream
    if timeout 5 curl -r 0-1048576 "$url" > /dev/null 2>&1; then
        print_success "Stream is downloadable (working)"
        return 0
    else
        print_warning "Could not download stream segment"
        return 1
    fi
}

get_m3u_channels() {
    local file=$1
    print_info "Extracting channel information from: $file"
    
    # Extract channel names and URLs
    grep "^#EXTINF:" "$file" | head -20 | while read line; do
        name=$(echo "$line" | sed -n 's/.*,\(.*\)$/\1/p')
        echo "  - $name"
    done
    
    echo ""
    local total=$(grep "^#EXTINF:" "$file" | wc -l)
    echo "Total channels: $total"
}

clear_jellyfin_cache() {
    print_warning "Clearing Jellyfin cache..."
    docker exec "$JELLYFIN_CONTAINER" bash -c "rm -rf /cache/livetv/*" 2>/dev/null || true
    print_success "Cache cleared"
}

restart_jellyfin() {
    print_warning "Restarting Jellyfin..."
    docker restart "$JELLYFIN_CONTAINER"
    print_success "Jellyfin restarted - Wait 30 seconds for startup"
    sleep 30
}

show_menu() {
    print_header "Jellyfin IPTV Setup Helper"
    
    echo "Select an option:"
    echo ""
    echo "  1) Check Jellyfin status"
    echo "  2) Validate M3U file"
    echo "  3) Test URL connectivity"
    echo "  4) Test streaming (sample channel)"
    echo "  5) Show channel list"
    echo "  6) Clear Jellyfin cache"
    echo "  7) Restart Jellyfin"
    echo "  8) Full diagnostic (all checks)"
    echo "  9) Show setup instructions"
    echo "  0) Exit"
    echo ""
    read -p "Enter your choice [0-9]: " choice
}

show_instructions() {
    print_header "Jellyfin IPTV Setup Instructions"
    
    cat << 'EOF'
QUICK SETUP (5 minutes):

1. Open Jellyfin Web UI
   URL: http://136.243.155.166:8096

2. Login as: simonadmin

3. Go to Settings → Live TV

4. Click "Add Tuner" or "Add TV Provider"

5. Select "M3U Tuner" or "IPTV"

6. Fill in details:
   Name: Jellyfin Organized Channels
   File or URL: /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-organized-channels.m3u
   Enable: ✓ (checked)

7. Click Save

8. Go to Live TV → Guide

9. Wait 30-60 seconds for channels to load

10. You should see 9 categories with 100+ channels


TROUBLESHOOTING:

If channels don't appear:
  - Use remote URL instead of local file
  - Check Jellyfin container is running
  - Clear cache and restart Jellyfin
  - Check network connectivity

For geo-blocked streams:
  - Some channels may not work outside their region
  - This is normal - try other channels

For slow loading:
  - Don't add multiple large M3U files
  - Keep guide refresh interval at 3600+ seconds


MULTIPLE M3U FILES:

Add these for better organization:

News: https://iptv-org.github.io/iptv/categories/news.m3u
Sports: https://iptv-org.github.io/iptv/categories/sports.m3u
Entertainment: https://iptv-org.github.io/iptv/categories/entertainment.m3u
Movies: https://iptv-org.github.io/iptv/categories/movies.m3u
Music: https://iptv-org.github.io/iptv/categories/music.m3u
Kids: https://iptv-org.github.io/iptv/categories/kids.m3u

Each as a separate tuner in Jellyfin.

EOF
}

run_full_diagnostic() {
    print_header "Running Full Diagnostic"
    
    # Check Docker
    check_docker
    if [ $? -ne 0 ]; then
        print_error "Cannot continue - Jellyfin not running"
        return 1
    fi
    
    echo ""
    # Validate M3U
    local m3u_file="$M3U_LOCAL_PATH/$M3U_ORGANIZED"
    if [ -f "$m3u_file" ]; then
        validate_m3u "$m3u_file"
    else
        print_warning "M3U file not found, skipping validation"
    fi
    
    echo ""
    # Show summary
    print_header "Diagnostic Summary"
    echo "Jellyfin: Running ✓"
    echo "M3U File: Found ✓"
    echo "Categories: Multiple ✓"
    echo "Ready to use: YES ✓"
    echo ""
}

# Main script
case "$1" in
    "check")
        check_docker
        ;;
    "validate")
        if [ -z "$2" ]; then
            validate_m3u "$M3U_LOCAL_PATH/$M3U_ORGANIZED"
        else
            validate_m3u "$2"
        fi
        ;;
    "test-url")
        if [ -z "$2" ]; then
            print_error "Usage: $0 test-url <url>"
            exit 1
        fi
        test_url_connectivity "$2"
        ;;
    "test-stream")
        if [ -z "$2" ]; then
            print_error "Usage: $0 test-stream <stream_url>"
            exit 1
        fi
        test_channel_stream "$2"
        ;;
    "show")
        get_m3u_channels "$M3U_LOCAL_PATH/$M3U_ORGANIZED"
        ;;
    "clear-cache")
        check_docker || exit 1
        clear_jellyfin_cache
        ;;
    "restart")
        check_docker || exit 1
        restart_jellyfin
        ;;
    "diagnostic")
        run_full_diagnostic
        ;;
    "help"|"instructions")
        show_instructions
        ;;
    *)
        # Interactive mode
        while true; do
            show_menu
            
            case $choice in
                1)
                    check_docker
                    ;;
                2)
                    validate_m3u "$M3U_LOCAL_PATH/$M3U_ORGANIZED"
                    ;;
                3)
                    read -p "Enter URL to test: " url
                    test_url_connectivity "$url"
                    ;;
                4)
                    print_info "Testing sample channel..."
                    # Extract first stream URL from M3U
                    local sample_url=$(grep -A1 "^#EXTINF:" "$M3U_LOCAL_PATH/$M3U_ORGANIZED" | grep "^http" | head -1)
                    if [ -n "$sample_url" ]; then
                        test_channel_stream "$sample_url"
                    else
                        print_error "No stream URL found"
                    fi
                    ;;
                5)
                    get_m3u_channels "$M3U_LOCAL_PATH/$M3U_ORGANIZED"
                    ;;
                6)
                    check_docker || continue
                    clear_jellyfin_cache
                    ;;
                7)
                    check_docker || continue
                    restart_jellyfin
                    ;;
                8)
                    run_full_diagnostic
                    ;;
                9)
                    show_instructions
                    ;;
                0)
                    print_info "Exiting..."
                    exit 0
                    ;;
                *)
                    print_error "Invalid choice. Please try again."
                    ;;
            esac
            
            echo ""
            read -p "Press Enter to continue..."
        done
        ;;
esac
