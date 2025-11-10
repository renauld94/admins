#!/bin/bash

# Quick test script for animation studio

echo "🎨 Testing Creative Animation Studio..."
echo ""

# Use the intro video we found
VIDEO="learning-platform-backup/jnj/module-02-core-python/session-2.01-Core Python Introduction/intro_video.mp4"

if [ ! -f "$VIDEO" ]; then
    echo "❌ Test video not found: $VIDEO"
    echo ""
    echo "Please run with your own video:"
    echo "  python3 tools/creative_animation_studio.py YOUR_VIDEO.mp4 -s cyberpunk --start 5 --end 8"
    exit 1
fi

echo "📹 Using test video: intro_video.mp4"
echo "🎭 Style: Cyberpunk"
echo "⏱️  Segment: 0-3 seconds (short test)"
echo "📁 Output: test_animation_cyberpunk.gif"
echo ""
echo "🎬 Creating animation..."
echo ""

# Use virtual environment if available
if [ -f ".venv/bin/python" ]; then
    PYTHON=".venv/bin/python"
else
    PYTHON="python3"
fi

$PYTHON tools/creative_animation_studio.py "$VIDEO" \
    -s cyberpunk \
    --start 0 \
    --end 3 \
    --resize 0.5 \
    --fps 10 \
    -o test_animation_cyberpunk.gif

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Success! Animation created: test_animation_cyberpunk.gif"
    ls -lh test_animation_cyberpunk.gif 2>/dev/null
else
    echo ""
    echo "❌ Test failed. Check error messages above."
fi
