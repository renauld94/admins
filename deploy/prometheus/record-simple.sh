#!/bin/bash

# Simple HTML to MP4 using OBS Studio or SimpleScreenRecorder
# Manual recording guide with automated setup

set -e

HTML_FILE="ai-optimization-animation.html"
OUTPUT_FILE="ai-optimization-linkedin.mp4"

echo "🎬 HTML to MP4 Conversion - Simple Method"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if screen recording tools are available
if command -v obs &> /dev/null; then
    RECORDER="OBS Studio"
    RECORDER_CMD="obs"
elif command -v simplescreenrecorder &> /dev/null; then
    RECORDER="SimpleScreenRecorder"
    RECORDER_CMD="simplescreenrecorder"
else
    echo "📦 Installing SimpleScreenRecorder..."
    sudo apt-get update
    sudo apt-get install -y simplescreenrecorder
    RECORDER="SimpleScreenRecorder"
    RECORDER_CMD="simplescreenrecorder"
fi

echo "✅ Screen recorder found: $RECORDER"
echo ""
echo "📋 RECORDING INSTRUCTIONS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Opening animation in browser..."
firefox "file://$(pwd)/$HTML_FILE" &
BROWSER_PID=$!
sleep 3

echo ""
echo "2️⃣  Press F11 in Firefox to enter fullscreen mode"
echo ""
echo "3️⃣  Configure $RECORDER:"
echo "    • Resolution: 1920x1080"
echo "    • Frame rate: 30 fps"
echo "    • Output format: MP4"
echo "    • Codec: H.264"
echo "    • Select the Firefox window"
echo ""
echo "4️⃣  Record for exactly 15 seconds"
echo ""
echo "5️⃣  Save as: $OUTPUT_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Press ENTER when ready to launch $RECORDER..."

# Launch screen recorder
$RECORDER_CMD &
RECORDER_PID=$!

echo ""
echo "🎥 Recording in progress..."
echo ""
echo "⏱️  Timer: Record for 15 seconds exactly"
echo ""

# 15 second countdown
for i in {15..1}; do
    printf "\r⏱️  Time remaining: %02d seconds" $i
    sleep 1
done

echo ""
echo ""
echo "✅ Recording complete!"
echo ""
echo "📝 Save the recording as: $OUTPUT_FILE"
echo ""
echo "Press ENTER when done..."
read

# Cleanup
kill $BROWSER_PID 2>/dev/null || true

echo ""
echo "✅ Process complete!"
echo ""
echo "Next steps:"
echo "1. Check video: vlc $OUTPUT_FILE"
echo "2. Upload to LinkedIn"
echo "3. Use caption from LINKEDIN_POST_READY.md"
echo ""
