#!/bin/bash

# Test Script for iptv-org EPG Setup
# This script provides a simple way to test the enhanced EPG script

echo "🧪 Testing iptv-org EPG Setup Script"
echo "===================================="
echo ""

# Check if the main script exists
SCRIPT_PATH="/home/simon/Desktop/Learning Management System Academy/scripts/add_iptv_org_epg.sh"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Main script not found at: $SCRIPT_PATH"
    exit 1
fi

echo "✅ Found main script: $SCRIPT_PATH"
echo ""

# Check script permissions
if [ ! -x "$SCRIPT_PATH" ]; then
    echo "🔧 Making script executable..."
    chmod +x "$SCRIPT_PATH"
    echo "✅ Script is now executable"
else
    echo "✅ Script is already executable"
fi

echo ""
echo "📋 Pre-flight checks:"
echo "==================="

# Check required commands
echo -n "Checking curl... "
if command -v curl >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌ (required for downloading EPG files)"
fi

echo -n "Checking ssh... "
if command -v ssh >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌ (required for VM connection)"
fi

echo -n "Checking scp... "
if command -v scp >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌ (required for file upload)"
fi

echo ""
echo "🚀 Ready to run the EPG setup script!"
echo ""
echo "To execute the script, run:"
echo "  $SCRIPT_PATH"
echo ""
echo "Or from the scripts directory:"
echo "  cd /home/simon/Desktop/Learning\ Management\ System\ Academy/scripts"
echo "  ./add_iptv_org_epg.sh"
echo ""
echo "📝 The script will:"
echo "  1. Test SSH connection to VM 10.0.0.103"
echo "  2. Check Docker container status"
echo "  3. Download EPG files from iptv-org"
echo "  4. Upload files to VM"
echo "  5. Install into Jellyfin container"
echo "  6. Provide configuration instructions"
echo ""
echo "💡 If the automated script fails, it will provide manual instructions"
echo ""
echo "🎯 Target: VM 10.0.0.103 (VM 200 with Jellyfin)"
echo "🌐 Jellyfin URL: http://136.243.155.166:8096/web/"
echo "👤 Login: simonadmin"
