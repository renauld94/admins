#!/bin/bash

# 🎨 Animation Studio - Usage Examples

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║     🔥 CREATIVE ANIMATION STUDIO - EXAMPLES 🔥          ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

cat << 'EOF'

📹 EXAMPLE VIDEOS FOUND:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

# Find some example videos
find /home/simon/Learning-Management-System-Academy -name "*.mp4" -type f 2>/dev/null | grep -v postgres-data | head -3 | while read video; do
    echo "  📁 $(basename "$video")"
    echo "     Path: $video"
    echo ""
done

cat << 'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎭 QUICK START EXAMPLES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  EASIEST - Interactive Mode:
   
   python3 tools/quick_animation.py
   
   Just answer the questions!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2️⃣  FASTEST - One Command (Cyberpunk):
   
   python3 tools/creative_animation_studio.py VIDEO.mp4 \
     -s cyberpunk --start 5 --end 8 \
     --text "CHAOS OF SAMHAIN"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

3️⃣  CREATIVE - All 10 Styles at Once:
   
   python3 tools/batch_animation_creator.py VIDEO.mp4 \
     --start 5 --end 8 --output-dir ./animations

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

4️⃣  SPECIAL - Samhain Collection:
   
   ./tools/create_samhain_animation.sh VIDEO.mp4 5 8

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎨 AVAILABLE STYLES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ cyberpunk    - Neon glitch aesthetic
🌊 vaporwave    - Pastel retro vibes
💚 matrix       - Green digital rain
🌅 retrowave    - 80s sunset gradient
🎞️  noir         - High contrast B&W
📺 glitch       - Digital corruption
✨ neon         - Glowing colors
🎮 pixel        - 8-bit retro
🔮 kaleidoscope - Psychedelic mirrors
🌈 chromatic    - RGB separation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 RECOMMENDED FOR YOUR SAMHAIN THEME:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🥇 Cyberpunk - Chaotic neon energy
   python3 tools/creative_animation_studio.py VIDEO.mp4 -s cyberpunk --start 5 --end 8

🥈 Glitch - Pure digital chaos
   python3 tools/creative_animation_studio.py VIDEO.mp4 -s glitch --start 5 --end 8

🥉 Noir - Dark and mysterious
   python3 tools/creative_animation_studio.py VIDEO.mp4 -s noir --start 5 --end 8

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 FULL DOCUMENTATION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📖 Complete Guide:   ANIMATION_STUDIO_GUIDE.md
📖 Tool Docs:        tools/README_ANIMATIONS.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 READY TO CREATE YOUR MASTERPIECE?

Replace VIDEO.mp4 with your actual video file and run any command above!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
