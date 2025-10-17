#!/bin/bash
#
# Record Grafana Dashboard for LinkedIn Post
# This script helps you create a professional screen recording
#

set -e

echo "🎬 Grafana Dashboard Recording Setup"
echo "======================================="
echo ""

# Check if required tools are installed
echo "📋 Checking dependencies..."

if ! command -v simplescreenrecorder &> /dev/null; then
    echo "   ⚠️  SimpleScreenRecorder not found. Install it?"
    read -p "   Install now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get update
        sudo apt-get install -y simplescreenrecorder
        echo "   ✅ SimpleScreenRecorder installed"
    fi
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "   ⚠️  FFmpeg not found. Install it?"
    read -p "   Install now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get install -y ffmpeg
        echo "   ✅ FFmpeg installed"
    fi
fi

echo ""
echo "🎯 Recording Options:"
echo "====================="
echo ""
echo "1. SimpleScreenRecorder (Recommended - GUI)"
echo "2. FFmpeg (Command Line)"
echo "3. OBS Studio (Professional)"
echo "4. Interactive D3.js Dashboard (Web)"
echo ""

read -p "Choose option (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🎥 Launching SimpleScreenRecorder..."
        echo ""
        echo "📝 Recommended Settings:"
        echo "   - Video: Full screen or select area"
        echo "   - Frame rate: 30 FPS"
        echo "   - Codec: H.264"
        echo "   - Container: MP4"
        echo "   - Scale: 1920x1080"
        echo "   - Audio: Enable microphone for narration"
        echo ""
        echo "🎬 Before recording:"
        echo "   1. Open Grafana dashboard in Firefox/Chrome"
        echo "   2. Set to fullscreen (F11)"
        echo "   3. Clear browser cache/cookies"
        echo "   4. Close unnecessary tabs"
        echo "   5. Prepare your script"
        echo ""
        read -p "Press Enter to launch SimpleScreenRecorder..."
        simplescreenrecorder &
        ;;
        
    2)
        echo ""
        echo "🎥 FFmpeg Command Line Recording"
        echo ""
        
        # Get screen resolution
        RESOLUTION=$(xdpyinfo | grep dimensions | awk '{print $2}')
        echo "   Detected resolution: $RESOLUTION"
        echo ""
        
        OUTPUT_FILE="grafana-dashboard-$(date +%Y%m%d-%H%M%S).mp4"
        
        echo "   Recording will start in 5 seconds..."
        echo "   Press Ctrl+C to stop recording"
        echo ""
        sleep 5
        
        ffmpeg -f x11grab -r 30 -s $RESOLUTION -i :0.0 \
               -f pulse -i default \
               -c:v libx264 -preset ultrafast -crf 23 \
               -c:a aac -b:a 128k \
               "$OUTPUT_FILE"
        
        echo "   ✅ Recording saved to: $OUTPUT_FILE"
        ;;
        
    3)
        echo ""
        echo "🎥 Installing OBS Studio..."
        
        if ! command -v obs &> /dev/null; then
            sudo add-apt-repository -y ppa:obsproject/obs-studio
            sudo apt-get update
            sudo apt-get install -y obs-studio
        fi
        
        echo ""
        echo "📝 OBS Studio Settings:"
        echo "   Settings → Output:"
        echo "     - Recording Format: MP4"
        echo "     - Encoder: x264"
        echo "     - Rate Control: CBR"
        echo "     - Bitrate: 2500 Kbps"
        echo ""
        echo "   Settings → Video:"
        echo "     - Base Resolution: 1920x1080"
        echo "     - Output Resolution: 1920x1080"
        echo "     - FPS: 30"
        echo ""
        echo "   Sources to add:"
        echo "     1. Browser Source (Grafana URL)"
        echo "     2. Audio Input Capture (microphone)"
        echo ""
        
        read -p "Press Enter to launch OBS Studio..."
        obs &
        ;;
        
    4)
        echo ""
        echo "🌐 Interactive D3.js Dashboard"
        echo ""
        echo "   Opening interactive dashboard in browser..."
        echo "   This can be:"
        echo "     - Recorded as a video"
        echo "     - Shared as a live link"
        echo "     - Embedded in portfolio"
        echo ""
        
        DASHBOARD_FILE="/home/simon/Learning-Management-System-Academy/deploy/prometheus/interactive-dashboard.html"
        
        if [ -f "$DASHBOARD_FILE" ]; then
            xdg-open "$DASHBOARD_FILE" 2>/dev/null || \
            firefox "$DASHBOARD_FILE" 2>/dev/null || \
            google-chrome "$DASHBOARD_FILE" 2>/dev/null
            
            echo "   ✅ Dashboard opened in browser"
            echo ""
            echo "   To record this:"
            echo "   1. Run this script again and choose option 1 or 2"
            echo "   2. Record the browser window"
            echo ""
        else
            echo "   ❌ Dashboard file not found: $DASHBOARD_FILE"
        fi
        ;;
        
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "📹 Recording Tips:"
echo "=================="
echo ""
echo "✅ Before Recording:"
echo "   • Close unnecessary applications"
echo "   • Disable notifications"
echo "   • Clear desktop clutter"
echo "   • Test audio levels"
echo "   • Prepare your script"
echo ""
echo "✅ During Recording:"
echo "   • Speak slowly and clearly"
echo "   • Pause on important metrics (3-5 seconds)"
echo "   • Navigate smoothly (no jerky movements)"
echo "   • Show refresh/live data updating"
echo "   • Keep under 60 seconds for LinkedIn"
echo ""
echo "✅ After Recording:"
echo "   • Trim silence at start/end"
echo "   • Add intro title (2-3 seconds)"
echo "   • Add captions/subtitles"
echo "   • Test on mobile device"
echo "   • Export as MP4 (1080p, 30fps)"
echo ""
echo "📚 Sample Script:"
echo "=================="
echo ""
cat << 'SCRIPT'
[0-5s] Opening
"This is my AI infrastructure monitoring dashboard 
running on Grafana and Prometheus..."

[5-15s] System Overview
"Here we can see real-time CPU usage across 8 cores. 
Right now we're running at about 15% utilization..."

[15-25s] Memory & Storage
"62 gigabytes of RAM with these spikes showing AI model 
inference. The ZFS storage on NVMe drives gives us 
sub-millisecond latency..."

[25-35s] Network
"Network traffic showing API calls to Ollama and OpenWebUI. 
These spikes are when users interact with AI models..."

[35-50s] Why This Matters
"All collected by Prometheus every 15 seconds and visualized 
in Grafana. This gives me proactive visibility into my AI 
infrastructure for performance optimization."

[50-55s] Call to Action
"All open-source, all self-hosted. Link in comments for 
the full setup guide."
SCRIPT

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo ""
echo "1. Record your video (30-60 seconds)"
echo "2. Edit with Kdenlive or OpenShot:"
echo "   sudo apt-get install kdenlive"
echo ""
echo "3. Upload to LinkedIn:"
echo "   - Use one of the post templates in LINKEDIN_POST_GUIDE.md"
echo "   - Add hashtags: #DevOps #AI #Monitoring #Prometheus #Grafana"
echo "   - Tag relevant connections"
echo ""
echo "4. Share the interactive dashboard:"
echo "   - Host on GitHub Pages"
echo "   - Link from LinkedIn post"
echo "   - Add to portfolio"
echo ""
echo "📄 Full guide available in:"
echo "   ~/Learning-Management-System-Academy/deploy/prometheus/LINKEDIN_POST_GUIDE.md"
echo ""
