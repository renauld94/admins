#!/bin/bash
#
# Convert D3.js Animation to MP4 for LinkedIn
# This script captures the HTML animation and converts it to MP4 format
#

echo "AI Model Optimization Animation - MP4 Conversion"
echo "==============================================="
echo ""

# Check if required tools are installed
command -v google-chrome >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1 || {
    echo "ERROR: Chrome/Chromium not found. Installing chromium-browser..."
    sudo apt-get update && sudo apt-get install -y chromium-browser
}

command -v ffmpeg >/dev/null 2>&1 || {
    echo "ERROR: ffmpeg not found. Installing..."
    sudo apt-get install -y ffmpeg
}

# File paths
HTML_FILE="$(pwd)/ai-optimization-animation.html"
OUTPUT_DIR="$(pwd)/linkedin-videos"
OUTPUT_FILE="$OUTPUT_DIR/ai-optimization-$(date +%Y%m%d-%H%M%S).mp4"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Recording animation to MP4..."
echo "Input: $HTML_FILE"
echo "Output: $OUTPUT_FILE"
echo ""

# Method 1: Using Chrome headless with screenshot capture (if available)
if command -v google-chrome >/dev/null 2>&1; then
    CHROME_BIN="google-chrome"
elif command -v chromium-browser >/dev/null 2>&1; then
    CHROME_BIN="chromium-browser"
fi

echo "Step 1: Capturing animation frames..."

# Create temporary directory for frames
FRAME_DIR="$(mktemp -d)"
echo "Temporary frames directory: $FRAME_DIR"

# Capture using puppeteer-like approach with chrome
cat > /tmp/capture-animation.js <<'EOF'
const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    const page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });
    
    const htmlPath = process.argv[2];
    const outputDir = process.argv[3];
    
    await page.goto(`file://${htmlPath}`, { waitUntil: 'networkidle0' });
    
    // Record for 15 seconds at 30fps
    const fps = 30;
    const duration = 15; // seconds
    const totalFrames = fps * duration;
    
    for (let i = 0; i < totalFrames; i++) {
        await page.screenshot({
            path: `${outputDir}/frame-${String(i).padStart(5, '0')}.png`,
            type: 'png'
        });
        await page.waitForTimeout(1000 / fps);
    }
    
    await browser.close();
    console.log(`Captured ${totalFrames} frames`);
})();
EOF

# Check if puppeteer is available
if command -v node >/dev/null 2>&1 && npm list -g puppeteer >/dev/null 2>&1; then
    echo "Using Puppeteer for high-quality capture..."
    node /tmp/capture-animation.js "$HTML_FILE" "$FRAME_DIR"
else
    echo "Puppeteer not available. Using alternative method..."
    echo ""
    echo "ALTERNATIVE METHOD:"
    echo "=================="
    echo "1. Open the HTML file in your browser:"
    echo "   file://$HTML_FILE"
    echo ""
    echo "2. Use a screen recorder to capture 15 seconds:"
    echo "   - OBS Studio (https://obsproject.com/)"
    echo "   - SimpleScreenRecorder"
    echo "   - Kazam"
    echo ""
    echo "3. Export as MP4 with these settings:"
    echo "   - Resolution: 1920x1080"
    echo "   - Frame rate: 30fps"
    echo "   - Codec: H.264"
    echo "   - Bitrate: 5000kbps"
    echo ""
    echo "For automated recording, install Puppeteer:"
    echo "   npm install -g puppeteer"
    echo ""
    exit 1
fi

# Convert frames to MP4 using ffmpeg
echo ""
echo "Step 2: Converting frames to MP4..."

ffmpeg -y \
    -framerate 30 \
    -pattern_type glob \
    -i "$FRAME_DIR/frame-*.png" \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -crf 23 \
    -preset slow \
    -movflags +faststart \
    "$OUTPUT_FILE"

# Cleanup
rm -rf "$FRAME_DIR"
rm -f /tmp/capture-animation.js

echo ""
echo "SUCCESS! Video created:"
echo "$OUTPUT_FILE"
echo ""
echo "LinkedIn Upload Specifications:"
echo "- Resolution: 1920x1080"
echo "- Duration: 15 seconds"
echo "- Format: MP4"
echo "- Codec: H.264"
echo ""
echo "You can now upload this to LinkedIn!"
echo ""