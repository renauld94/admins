#!/bin/bash

# 🎨 Creative Animation Demo
# Chaos of Samhain Style

echo "═══════════════════════════════════════════════════════"
echo "🔥 CHAOS OF SAMHAIN - Animation Creator 🔥"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check if video file is provided
if [ -z "$1" ]; then
    echo "📹 Available MP4 files in workspace:"
    echo ""
    find /home/simon/Learning-Management-System-Academy -name "*.mp4" -type f 2>/dev/null | grep -v "postgres-data" | head -10 | nl
    echo ""
    echo "Usage: $0 <path-to-video.mp4> [start] [end]"
    echo ""
    echo "Example:"
    echo "  $0 my_video.mp4 5 8"
    echo ""
    exit 1
fi

VIDEO="$1"
START="${2:-5}"
END="${3:-8}"

if [ ! -f "$VIDEO" ]; then
    echo "❌ Error: Video file not found: $VIDEO"
    exit 1
fi

# Create output directory
OUTPUT_DIR="./animations_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "📹 Video: $(basename "$VIDEO")"
echo "⏱️  Segment: ${START}s - ${END}s"
echo "📁 Output: $OUTPUT_DIR"
echo ""
echo "═══════════════════════════════════════════════════════"
echo "🎭 Creating Artistic Variations..."
echo "═══════════════════════════════════════════════════════"
echo ""

# Array of styles perfect for Samhain theme
declare -a STYLES=("cyberpunk" "glitch" "matrix" "noir" "vaporwave")

# Create each style
for STYLE in "${STYLES[@]}"; do
    echo ""
    echo "🎨 Creating ${STYLE} animation..."
    python3 tools/creative_animation_studio.py "$VIDEO" \
        -s "$STYLE" \
        --start "$START" \
        --end "$END" \
        --resize 0.6 \
        --fps 15 \
        -o "${OUTPUT_DIR}/samhain_${STYLE}.gif"
    
    if [ $? -eq 0 ]; then
        echo "✅ ${STYLE} complete!"
    else
        echo "❌ ${STYLE} failed"
    fi
done

# Create one with text overlay
echo ""
echo "🎨 Creating special edition with text..."
python3 tools/creative_animation_studio.py "$VIDEO" \
    -s cyberpunk \
    --start "$START" \
    --end "$END" \
    --text "CHAOS OF SAMHAIN" \
    --resize 0.7 \
    --fps 15 \
    -o "${OUTPUT_DIR}/samhain_special.gif"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✨ CREATION COMPLETE! ✨"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📂 Your animations are ready in: $OUTPUT_DIR"
echo ""
ls -lh "$OUTPUT_DIR"/*.gif 2>/dev/null | awk '{print "   🎬", $9, "-", $5}'
echo ""
echo "═══════════════════════════════════════════════════════"
