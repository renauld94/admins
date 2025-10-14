#!/bin/bash

# CHEG CONFIGURATION VERIFICATION AND QUICK FIX
# Checks current Jellyfin Live TV configuration and provides specific fixes

echo "📺 CHEG CONFIGURATION VERIFICATION"
echo "=================================="
echo ""

echo "🔍 CHECKING CURRENT CONFIGURATION:"
echo "================================="
echo ""

# Check if we can access Jellyfin
echo "1. Testing Jellyfin access..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8096/ >/dev/null 2>&1; then
    echo "   ✅ Jellyfin is accessible locally"
    JELLYFIN_ACCESSIBLE=true
else
    echo "   ❌ Jellyfin is not accessible locally"
    JELLYFIN_ACCESSIBLE=false
fi

echo ""
echo "2. Checking configuration files..."
echo "   M3U Files (Channel Sources):"
if [ -f "/config/samsung_tv_plus.m3u" ]; then
    echo "   ✅ /config/samsung_tv_plus.m3u exists"
else
    echo "   ❌ /config/samsung_tv_plus.m3u missing"
fi

if [ -f "/config/plex_live.m3u" ]; then
    echo "   ✅ /config/plex_live.m3u exists"
else
    echo "   ❌ /config/plex_live.m3u missing"
fi

if [ -f "/config/tubi_tv.m3u" ]; then
    echo "   ✅ /config/tubi_tv.m3u exists"
else
    echo "   ❌ /config/tubi_tv.m3u missing"
fi

echo ""
echo "   EPG Files (Program Guide):"
if [ -f "/config/epg_us.xml" ]; then
    echo "   ✅ /config/epg_us.xml exists"
else
    echo "   ❌ /config/epg_us.xml missing"
fi

if [ -f "/config/epg_uk.xml" ]; then
    echo "   ✅ /config/epg_uk.xml exists"
else
    echo "   ❌ /config/epg_uk.xml missing"
fi

echo ""
echo "🚨 IDENTIFIED ISSUES:"
echo "===================="
echo "❌ Tuner Devices incorrectly shows: M3U /config/epg_us.xml"
echo "❌ EPG file is being used as a channel source"
echo "❌ This will cause Live TV to not work properly"
echo ""

echo "🛠️  IMMEDIATE FIX REQUIRED:"
echo "========================="
echo ""
echo "STEP 1: Access Jellyfin Admin Panel"
echo "-----------------------------------"
echo "1. Open browser and go to: http://localhost:8096"
echo "2. Login with admin credentials"
echo "3. Go to: Dashboard → Live TV"
echo ""

echo "STEP 2: Remove Incorrect Tuner"
echo "-----------------------------"
echo "1. Find the tuner showing: 'M3U /config/epg_us.xml'"
echo "2. Click the 'X' or 'Delete' button"
echo "3. Confirm deletion"
echo ""

echo "STEP 3: Add Correct Tuner Devices"
echo "---------------------------------"
echo "1. Click '+' next to 'Tuner Devices'"
echo "2. Select 'M3U Tuner'"
echo "3. Add each tuner:"
echo ""
echo "   Tuner 1:"
echo "   - Name: Samsung TV Plus"
echo "   - M3U URL: /config/samsung_tv_plus.m3u"
echo "   - Click 'Save'"
echo ""
echo "   Tuner 2:"
echo "   - Name: Plex Live"
echo "   - M3U URL: /config/plex_live.m3u"
echo "   - Click 'Save'"
echo ""
echo "   Tuner 3:"
echo "   - Name: Tubi TV"
echo "   - M3U URL: /config/tubi_tv.m3u"
echo "   - Click 'Save'"
echo ""

echo "STEP 4: Add EPG Provider"
echo "----------------------"
echo "1. Click '+' next to 'TV Guide Data Providers'"
echo "2. Select 'XMLTV'"
echo "3. Configure:"
echo "   - Name: US EPG"
echo "   - XMLTV URL: /config/epg_us.xml"
echo "   - Click 'Save'"
echo ""

echo "🧪 VERIFICATION CHECKLIST:"
echo "=========================="
echo ""
echo "After making changes, verify:"
echo "□ Tuner Devices show M3U files (not EPG files)"
echo "□ TV Guide Data Providers show XMLTV files"
echo "□ Channels are visible and playable"
echo "□ Program guide shows schedule"
echo "□ Live TV works correctly"
echo ""

echo "🔍 TROUBLESHOOTING:"
echo "=================="
echo ""
echo "If channels don't appear:"
echo "1. Check M3U file format"
echo "2. Verify file paths are correct"
echo "3. Check file permissions"
echo "4. Restart Jellyfin service"
echo ""
echo "If EPG doesn't work:"
echo "1. Check XMLTV file format"
echo "2. Verify channel mapping"
echo "3. Check EPG refresh schedule"
echo "4. Clear EPG cache"
echo ""

echo "💡 KEY CONCEPTS:"
echo "==============="
echo ""
echo "M3U Files = Channel Sources (what to watch)"
echo "EPG Files = Program Guide (when to watch)"
echo ""
echo "Tuner Devices = Where channels come from"
echo "TV Guide Data Providers = Where schedule comes from"
echo ""

echo "🎯 EXPECTED RESULT:"
echo "=================="
echo ""
echo "After fixing configuration:"
echo "✅ Tuner Devices show M3U files (not EPG files)"
echo "✅ TV Guide Data Providers show XMLTV files"
echo "✅ Channels are playable"
echo "✅ Program guide shows schedule"
echo "✅ Live TV works correctly"
echo ""

echo "📞 SUPPORT:"
echo "==========="
echo ""
echo "If issues persist:"
echo "1. Check Jellyfin logs"
echo "2. Verify file formats"
echo "3. Test M3U files manually"
echo "4. Check network connectivity"
echo ""
echo "🔄 To run this verification again:"
echo "  ./verify_cheg_config.sh"
