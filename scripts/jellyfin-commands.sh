#!/bin/bash
# Quick commands for Jellyfin management

SCRIPT_DIR="/home/simon/Learning-Management-System-Academy/scripts"

case "$1" in
    test)
        echo "🔍 Testing all channels (dry run)..."
        python3 "$SCRIPT_DIR/jellyfin-channel-monitor.py" --dry-run
        ;;
    clean)
        echo "🧹 Cleaning dead channels..."
        python3 "$SCRIPT_DIR/jellyfin-channel-monitor.py"
        ;;
    update)
        echo "🔄 Fetching new channels..."
        bash "$SCRIPT_DIR/update-jellyfin-channels.sh"
        ;;
    status)
        echo "📊 Jellyfin Status:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Count channels
        M3U="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u"
        if [ -f "$M3U" ]; then
            CHANNELS=$(grep -c "^#EXTINF:" "$M3U")
            echo "  Live TV Channels: $CHANNELS"
        fi
        
        # Check service status
        if systemctl is-active --quiet jellyfin-channel-monitor.timer 2>/dev/null; then
            echo "  Monitor Service: ✓ Active"
            systemctl status jellyfin-channel-monitor.timer --no-pager -l | grep "Trigger:"
        else
            echo "  Monitor Service: ⚠ Not running (check cron)"
        fi
        
        # Last report
        REPORT_DIR="/home/simon/Learning-Management-System-Academy/reports/jellyfin"
        if [ -d "$REPORT_DIR" ]; then
            LAST_REPORT=$(ls -t "$REPORT_DIR"/channel-health-*.html 2>/dev/null | head -1)
            if [ ! -z "$LAST_REPORT" ]; then
                echo "  Last Report: $(basename "$LAST_REPORT")"
            fi
        fi
        ;;
    report)
        # Open latest report
        REPORT_DIR="/home/simon/Learning-Management-System-Academy/reports/jellyfin"
        LAST_REPORT=$(ls -t "$REPORT_DIR"/channel-health-*.html 2>/dev/null | head -1)
        if [ ! -z "$LAST_REPORT" ]; then
            echo "📄 Opening report: $(basename "$LAST_REPORT")"
            xdg-open "$LAST_REPORT" 2>/dev/null || echo "Report: $LAST_REPORT"
        else
            echo "No reports found"
        fi
        ;;
    *)
        echo "Jellyfin Quick Commands"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Usage: jellyfin-commands.sh [command]"
        echo ""
        echo "Commands:"
        echo "  test    - Test all channels (dry run, no changes)"
        echo "  clean   - Remove dead channels from M3U"
        echo "  update  - Fetch new channels from IPTV-Org"
        echo "  status  - Show Jellyfin status and stats"
        echo "  report  - Open latest health report"
        echo ""
        echo "Examples:"
        echo "  ./jellyfin-commands.sh test    # Test channels"
        echo "  ./jellyfin-commands.sh clean   # Clean dead ones"
        echo "  ./jellyfin-commands.sh status  # Check stats"
        ;;
esac
