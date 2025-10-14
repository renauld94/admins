#!/bin/bash

# Jellyfin Free TV Channels Setup Guide
# This script provides step-by-step instructions to add free TV channels to Jellyfin

set -e

echo "📺 Jellyfin Free TV Channels Setup Guide"
echo "========================================"

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096/web/index.html#/home.html"
USERNAME="simonadmin"

echo "📋 Configuration:"
echo "  Jellyfin URL: $JELLYFIN_URL"
echo "  Username: $USERNAME"
echo ""

# Function to provide step-by-step setup
step_by_step_setup() {
    echo "📋 Step-by-Step Setup Guide:"
    echo "============================"
    echo ""
    
    echo "Step 1: Access Jellyfin Admin Dashboard"
    echo "1. Go to: $JELLYFIN_URL"
    echo "2. Log in with username: $USERNAME"
    echo "3. Click the 'Admin Panel' icon (gear icon) in the top-right corner"
    echo "4. Navigate to 'Live TV' in the left sidebar"
    echo ""
    
    echo "Step 2: Add M3U Tuner"
    echo "1. In the Live TV section, click the '+' button next to 'Tuner Devices'"
    echo "2. Select 'M3U Tuner' as the Tuner Type"
    echo "3. In the 'File or URL' field, enter one of these free M3U playlists:"
    echo "   - Samsung TV Plus: https://rb.gy/soxjxl"
    echo "   - Plex Live Channels: https://rb.gy/rhktaz"
    echo "   - Tubi TV: https://www.apsattv.com/tubi.m3u"
    echo "4. Click 'Save'"
    echo ""
    
    echo "Step 3: Add Electronic Program Guide (EPG)"
    echo "1. Click the '+' button next to 'TV Guide Data Providers'"
    echo "2. Select 'XMLTV'"
    echo "3. In the 'File or URL' field, enter the corresponding EPG URL:"
    echo "   - Samsung TV Plus EPG: https://rb.gy/csudmm"
    echo "   - Plex Live Channels EPG: https://rb.gy/uoqt9v"
    echo "4. Click 'Save'"
    echo ""
    
    echo "Step 4: Refresh Guide Data"
    echo "1. After adding the EPG, click 'Refresh Guide Data'"
    echo "2. Wait for the guide data to populate"
    echo "3. This may take a few minutes"
    echo ""
    
    echo "Step 5: Access Live TV"
    echo "1. Return to the Jellyfin home page"
    echo "2. Click on 'Live TV' in the main menu"
    echo "3. Browse and watch the added channels"
    echo ""
}

# Function to provide free M3U playlists
free_m3u_playlists() {
    echo "📺 Free M3U Playlists:"
    echo "======================"
    echo ""
    
    echo "1. Samsung TV Plus:"
    echo "   URL: https://rb.gy/soxjxl"
    echo "   Description: Free Samsung TV Plus channels"
    echo "   EPG: https://rb.gy/csudmm"
    echo ""
    
    echo "2. Plex Live Channels:"
    echo "   URL: https://rb.gy/rhktaz"
    echo "   Description: Free Plex Live TV channels"
    echo "   EPG: https://rb.gy/uoqt9v"
    echo ""
    
    echo "3. Tubi TV:"
    echo "   URL: https://www.apsattv.com/tubi.m3u"
    echo "   Description: Free Tubi TV channels"
    echo "   EPG: Not available"
    echo ""
    
    echo "4. Additional Free Sources:"
    echo "   - Pluto TV: Various free channels"
    echo "   - XUMO: Free streaming channels"
    echo "   - Crackle: Free movies and TV shows"
    echo "   - Redbox Free Live TV: Free live channels"
    echo ""
}

# Function to provide troubleshooting tips
troubleshooting_tips() {
    echo "🛠️  Troubleshooting Tips:"
    echo "========================"
    echo ""
    
    echo "Common Issues and Solutions:"
    echo ""
    
    echo "Issue 1: Channels not loading"
    echo "Solution:"
    echo "1. Check if the M3U URL is accessible"
    echo "2. Verify internet connection"
    echo "3. Try a different M3U playlist"
    echo ""
    
    echo "Issue 2: No EPG data"
    echo "Solution:"
    echo "1. Ensure EPG URL is correct"
    echo "2. Click 'Refresh Guide Data'"
    echo "3. Wait for guide data to populate"
    echo ""
    
    echo "Issue 3: Channels not playing"
    echo "Solution:"
    echo "1. Check if streams are geo-blocked"
    echo "2. Try different channels"
    echo "3. Verify stream format compatibility"
    echo ""
    
    echo "Issue 4: Slow loading"
    echo "Solution:"
    echo "1. Check internet speed"
    echo "2. Try different M3U sources"
    echo "3. Reduce number of channels if needed"
    echo ""
}

# Function to provide advanced configuration
advanced_configuration() {
    echo "⚙️  Advanced Configuration:"
    echo "==========================="
    echo ""
    
    echo "1. Custom M3U Playlist:"
    echo "   - Create your own M3U file with preferred channels"
    echo "   - Upload to a web server or use local file"
    echo "   - Add to Jellyfin as M3U Tuner"
    echo ""
    
    echo "2. Multiple Tuners:"
    echo "   - Add multiple M3U tuners for different channel sources"
    echo "   - Combine different free TV services"
    echo "   - Organize channels by category"
    echo ""
    
    echo "3. EPG Customization:"
    echo "   - Use custom XMLTV files for better guide data"
    echo "   - Combine multiple EPG sources"
    echo "   - Set up automatic EPG updates"
    echo ""
    
    echo "4. Channel Organization:"
    echo "   - Create channel groups"
    echo "   - Hide unwanted channels"
    echo "   - Set up channel favorites"
    echo ""
}

# Function to provide legal considerations
legal_considerations() {
    echo "⚖️  Legal Considerations:"
    echo "=========================="
    echo ""
    
    echo "Important Notes:"
    echo "1. Only use legally available free TV channels"
    echo "2. Respect geo-blocking restrictions"
    echo "3. Check local laws regarding IPTV usage"
    echo "4. Some streams may have regional restrictions"
    echo "5. Always verify the legality of content in your region"
    echo ""
    
    echo "Recommended Sources:"
    echo "1. Official free TV services (Pluto TV, Tubi, etc.)"
    echo "2. Public domain content"
    echo "3. Legally licensed free channels"
    echo "4. Educational and public broadcasting"
    echo ""
}

# Main execution
main() {
    echo "🚀 Starting Jellyfin Free TV Channels Setup..."
    echo ""
    
    step_by_step_setup
    free_m3u_playlists
    troubleshooting_tips
    advanced_configuration
    legal_considerations
    
    echo "🎯 Quick Start Summary:"
    echo "======================"
    echo ""
    echo "1. Go to: $JELLYFIN_URL"
    echo "2. Log in as: $USERNAME"
    echo "3. Click Admin Panel → Live TV"
    echo "4. Add M3U Tuner with URL: https://rb.gy/soxjxl"
    echo "5. Add XMLTV EPG with URL: https://rb.gy/csudmm"
    echo "6. Click 'Refresh Guide Data'"
    echo "7. Enjoy free TV channels!"
    echo ""
    echo "📺 Happy streaming!"
    echo ""
}

# Run main function
main "$@"
