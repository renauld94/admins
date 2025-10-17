#!/bin/bash
#
# Automated Dashboard Recording with Annotations
# Records 30 seconds of the professional dashboard with text overlays
#

set -e

echo "=========================================="
echo "Automated Dashboard Recording (30 seconds)"
echo "=========================================="
echo ""

# Configuration
DURATION=30
OUTPUT_DIR="$HOME/Videos/grafana-recordings"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/infrastructure-monitoring-$TIMESTAMP.mp4"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if Firefox with dashboard is running
if ! pgrep -f "firefox.*professional-dashboard.html" > /dev/null; then
    echo "Opening professional dashboard in Firefox..."
    firefox "$HOME/Learning-Management-System-Academy/deploy/prometheus/professional-dashboard.html" &
    sleep 5
fi

# Get screen resolution
RESOLUTION=$(xdpyinfo | grep dimensions | awk '{print $2}')
echo "Screen resolution: $RESOLUTION"
echo ""

# Find Firefox window and focus it
echo "Focusing Firefox window..."
WINDOW_ID=$(xdotool search --name "Infrastructure Monitoring" | head -1)
if [ -n "$WINDOW_ID" ]; then
    xdotool windowactivate "$WINDOW_ID"
    xdotool key F11  # Fullscreen
    sleep 2
else
    echo "Warning: Could not find Firefox window. Recording full screen..."
fi

echo ""
echo "Recording will start in 3 seconds..."
echo "Duration: 30 seconds"
echo "Output: $OUTPUT_FILE"
echo ""

sleep 3

# Create temporary filter script for text overlays
cat > /tmp/ffmpeg_text_overlay.txt << 'EOF'
[0:v]drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='Infrastructure Monitoring':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=50:enable='between(t,1,5)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='Production AI Workloads | Simon Renauld':fontcolor=white@0.8:fontsize=24:x=(w-text_w)/2:y=120:enable='between(t,1,5)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='Real-time Prometheus Metrics':fontcolor=white@0.9:fontsize=28:x=50:y=h-100:enable='between(t,6,12)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='64+ metric series | 15s intervals':fontcolor=white@0.8:fontsize=22:x=50:y=h-60:enable='between(t,6,12)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='CPU | Memory | Disk | Network':fontcolor=white@0.9:fontsize=28:x=50:y=h-100:enable='between(t,13,20)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='ZFS on NVMe | 62GB RAM':fontcolor=white@0.8:fontsize=22:x=50:y=h-60:enable='between(t,13,20)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='Zero crashes in 30 days':fontcolor=#10B981:fontsize=28:x=50:y=h-100:enable='between(t,21,27)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='40% resource optimization':fontcolor=#10B981:fontsize=22:x=50:y=h-60:enable='between(t,21,27)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='simondatalab.de':fontcolor=white:fontsize=32:x=(w-text_w)/2:y=h-80:enable='between(t,27,30)',
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='Data Engineering & MLOps':fontcolor=white@0.8:fontsize=20:x=(w-text_w)/2:y=h-40:enable='between(t,27,30)'[outv]
EOF

echo "Recording started..."
echo ""

# Record with FFmpeg with text overlays
ffmpeg -f x11grab -r 30 -s "$RESOLUTION" -i :0.0 \
    -t $DURATION \
    -filter_complex_script /tmp/ffmpeg_text_overlay.txt \
    -map '[outv]' \
    -c:v libx264 -preset medium -crf 23 \
    -pix_fmt yuv420p \
    "$OUTPUT_FILE" 2>&1 | grep -E "(time=|frame=)" || true

echo ""
echo "=========================================="
echo "Recording Complete!"
echo "=========================================="
echo ""
echo "Output file: $OUTPUT_FILE"
echo "Duration: 30 seconds"
echo "Resolution: $RESOLUTION"
echo ""

# Get file size
FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
echo "File size: $FILE_SIZE"

echo ""
echo "Next steps:"
echo "1. Review the video: vlc \"$OUTPUT_FILE\""
echo "2. Upload to LinkedIn (native video upload)"
echo "3. Use professional post template from LINKEDIN_POST_GUIDE_PROFESSIONAL.md"
echo ""

# Exit fullscreen
if [ -n "$WINDOW_ID" ]; then
    xdotool windowactivate "$WINDOW_ID"
    xdotool key F11
fi

# Cleanup
rm -f /tmp/ffmpeg_text_overlay.txt

echo "Recording saved successfully!"
