#!/bin/bash

# Professional HTML to MP4 Converter for LinkedIn
# Optimized for ai-optimization-animation.html

set -e

HTML_FILE="ai-optimization-animation.html"
OUTPUT_FILE="ai-optimization-linkedin.mp4"
DURATION=15
WIDTH=1920
HEIGHT=1080
FPS=30

echo "🎬 Converting HTML Animation to MP4..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Input:  $HTML_FILE"
echo "Output: $OUTPUT_FILE"
echo "Resolution: ${WIDTH}x${HEIGHT} @ ${FPS}fps"
echo "Duration: ${DURATION} seconds"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Method 1: Using Chrome headless with screenshot capture
if command -v google-chrome &> /dev/null; then
    echo ""
    echo "📸 Method: Chrome headless screenshot capture"
    echo ""
    
    # Create temporary directory for frames
    TEMP_DIR=$(mktemp -d)
    echo "Temporary frames directory: $TEMP_DIR"
    
    # Calculate total frames
    TOTAL_FRAMES=$((DURATION * FPS))
    echo "Total frames to capture: $TOTAL_FRAMES"
    
    # Get absolute path to HTML file
    HTML_PATH="file://$(pwd)/$HTML_FILE"
    
    echo ""
    echo "🎥 Capturing frames..."
    
    # Capture frames using Chrome
    for i in $(seq 0 $((TOTAL_FRAMES - 1))); do
        PROGRESS=$((i * 100 / TOTAL_FRAMES))
        printf "\rProgress: [%-50s] %d%%" $(printf '#%.0s' $(seq 1 $((PROGRESS / 2)))) $PROGRESS
        
        google-chrome --headless --disable-gpu \
            --window-size=$WIDTH,$HEIGHT \
            --screenshot="$TEMP_DIR/frame_$(printf "%05d" $i).png" \
            --virtual-time-budget=$((i * 1000 / FPS)) \
            "$HTML_PATH" 2>/dev/null
        
        sleep 0.05
    done
    
    echo ""
    echo ""
    echo "🎞️  Encoding video with ffmpeg..."
    
    # Convert frames to MP4
    ffmpeg -framerate $FPS \
        -i "$TEMP_DIR/frame_%05d.png" \
        -c:v libx264 \
        -preset slow \
        -crf 18 \
        -pix_fmt yuv420p \
        -vf "scale=${WIDTH}:${HEIGHT}" \
        -y "$OUTPUT_FILE" 2>&1 | grep -E 'frame=|time=|size=' || true
    
    # Cleanup
    echo ""
    echo "🧹 Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ SUCCESS!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Video created: $OUTPUT_FILE"
    echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
    echo ""
    echo "📱 Ready to upload to LinkedIn!"
    echo ""
    echo "Next steps:"
    echo "1. Preview: vlc $OUTPUT_FILE"
    echo "2. Upload to LinkedIn with caption from LINKEDIN_POST_READY.md"
    echo ""
else
    echo "❌ Error: Chrome not found"
    echo "Install with: sudo apt install google-chrome-stable"
    exit 1
fi
