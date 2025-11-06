#!/bin/bash
# Install Jellyfin ScrollBehavior Fix to Chrome/Chromium
# This script copies the userscript and opens Chrome to install Tampermonkey

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
USERSCRIPT="$PROJECT_ROOT/config/jellyfin/jellyfin-scrollfix.user.js"

echo "================================================"
echo "  Jellyfin ScrollBehavior Fix - Installation"
echo "================================================"
echo ""

# Check if userscript exists
if [ ! -f "$USERSCRIPT" ]; then
    echo "❌ Error: Userscript not found at $USERSCRIPT"
    exit 1
fi

echo "✅ Found userscript: $USERSCRIPT"
echo ""

# Check for Chrome/Chromium
BROWSER=""
if command -v google-chrome &> /dev/null; then
    BROWSER="google-chrome"
    echo "✅ Found Google Chrome"
elif command -v chromium-browser &> /dev/null; then
    BROWSER="chromium-browser"
    echo "✅ Found Chromium"
elif command -v chromium &> /dev/null; then
    BROWSER="chromium"
    echo "✅ Found Chromium"
else
    echo "❌ No Chrome/Chromium browser found"
    echo "   Please install Google Chrome or Chromium first"
    exit 1
fi

echo ""
echo "📋 Installation Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "STEP 1: Install Tampermonkey Extension"
echo "   Opening Chrome Web Store..."
echo ""

# Open Tampermonkey installation page
$BROWSER "https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo" > /dev/null 2>&1 &
sleep 3

echo "   ➜ Click 'Add to Chrome' button"
echo "   ➜ Click 'Add extension' in popup"
echo "   ➜ Wait for confirmation message"
echo ""
read -p "Press ENTER when Tampermonkey is installed..."

echo ""
echo "STEP 2: Create New Userscript"
echo "   Opening Tampermonkey dashboard..."
echo ""

# Open Tampermonkey dashboard
$BROWSER "chrome-extension://dhdgffkkebhmkfjojejmpbldmpobfkfo/options.html#nav=dashboard" > /dev/null 2>&1 &
sleep 2

echo "   ➜ Click the '+' button or 'Create a new script'"
echo "   ➜ Delete all default code in the editor"
echo ""
read -p "Press ENTER when editor is ready..."

echo ""
echo "STEP 3: Copy Userscript Content"
echo ""
echo "   Copying script to clipboard..."

# Copy to clipboard if xclip is available
if command -v xclip &> /dev/null; then
    cat "$USERSCRIPT" | xclip -selection clipboard
    echo "   ✅ Script copied to clipboard!"
    echo "   ➜ Paste (Ctrl+V) into Tampermonkey editor"
elif command -v xsel &> /dev/null; then
    cat "$USERSCRIPT" | xsel --clipboard
    echo "   ✅ Script copied to clipboard!"
    echo "   ➜ Paste (Ctrl+V) into Tampermonkey editor"
else
    echo "   📋 Clipboard tool not found. Opening script in text editor..."
    
    if command -v gedit &> /dev/null; then
        gedit "$USERSCRIPT" > /dev/null 2>&1 &
    elif command -v kate &> /dev/null; then
        kate "$USERSCRIPT" > /dev/null 2>&1 &
    elif command -v mousepad &> /dev/null; then
        mousepad "$USERSCRIPT" > /dev/null 2>&1 &
    else
        echo ""
        echo "   Manual copy required. Script location:"
        echo "   $USERSCRIPT"
        echo ""
        echo "   Run: cat $USERSCRIPT"
    fi
    
    echo "   ➜ Copy all content and paste into Tampermonkey"
fi

echo ""
read -p "Press ENTER when script is pasted..."

echo ""
echo "STEP 4: Save Script"
echo "   ➜ Press Ctrl+S or click File → Save"
echo "   ➜ Close the Tampermonkey tab"
echo ""
read -p "Press ENTER when script is saved..."

echo ""
echo "STEP 5: Test the Fix"
echo "   Opening Jellyfin..."
echo ""

# Open Jellyfin with Live TV
$BROWSER "https://jellyfin.simondatalab.de/web/#/livetv.html?collectionType=livetv" > /dev/null 2>&1 &
sleep 3

echo "   ➜ Press F12 to open Developer Console"
echo "   ➜ Look for message: '✅ Jellyfin ScrollBehavior Fix - Applied successfully!'"
echo "   ➜ Navigate to Live TV → Guide"
echo "   ➜ Scroll through channels - no errors should appear"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Installation Complete!"
echo ""
echo "If you still see scrollBehavior errors:"
echo "  1. Check Tampermonkey icon (top right) shows '1' badge"
echo "  2. Click icon → Dashboard → Ensure script is enabled (green light)"
echo "  3. Refresh Jellyfin page (Ctrl+R)"
echo ""
echo "Script location: $USERSCRIPT"
echo ""
