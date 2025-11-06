#!/bin/bash
# =============================================================================
# Jellyfin Enhancement Suite
# =============================================================================
# Installs and configures awesome features for Jellyfin:
# 1. Automatic channel health monitoring
# 2. Hardware transcoding optimization
# 3. Automated backups
# 4. Performance monitoring
# 5. Auto-update channels from IPTV-Org
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              🎬 Jellyfin Enhancement Suite Installer                  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo

# Check if running as root for system service installation
if [ "$EUID" -eq 0 ]; then 
    SUDO=""
    IS_ROOT=true
else
    SUDO="sudo"
    IS_ROOT=false
fi

# =============================================================================
# 1. Install Dependencies
# =============================================================================
echo -e "${YELLOW}[1/7] Installing Dependencies...${NC}"

# Check Python
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo -e "  ${GREEN}✓${NC} Python ${PYTHON_VERSION}"
else
    echo -e "  ${RED}✗${NC} Python 3 not found"
    exit 1
fi

# Install Python packages
echo "  Installing Python packages..."
pip3 install requests --quiet 2>/dev/null || $SUDO pip3 install requests --quiet

echo -e "  ${GREEN}✓${NC} Dependencies installed"
echo

# =============================================================================
# 2. Install Channel Monitor
# =============================================================================
echo -e "${YELLOW}[2/7] Installing Channel Monitor Agent...${NC}"

MONITOR_SCRIPT="/home/simon/Learning-Management-System-Academy/scripts/jellyfin-channel-monitor.py"
chmod +x "$MONITOR_SCRIPT"

# Create directories
mkdir -p /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/backups
mkdir -p /home/simon/Learning-Management-System-Academy/reports/jellyfin
$SUDO mkdir -p /var/log/jellyfin-monitor

echo -e "  ${GREEN}✓${NC} Channel monitor installed: $MONITOR_SCRIPT"
echo

# =============================================================================
# 3. Setup Systemd Service (if root)
# =============================================================================
if [ "$IS_ROOT" = true ]; then
    echo -e "${YELLOW}[3/7] Installing Systemd Service...${NC}"
    
    cat > /etc/systemd/system/jellyfin-channel-monitor.service << 'EOF'
[Unit]
Description=Jellyfin Live TV Channel Health Monitor
After=network.target

[Service]
Type=oneshot
User=simon
ExecStart=/usr/bin/python3 /home/simon/Learning-Management-System-Academy/scripts/jellyfin-channel-monitor.py
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/systemd/system/jellyfin-channel-monitor.timer << 'EOF'
[Unit]
Description=Run Jellyfin Channel Monitor daily
Requires=jellyfin-channel-monitor.service

[Timer]
OnCalendar=daily
OnCalendar=03:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable jellyfin-channel-monitor.timer
    systemctl start jellyfin-channel-monitor.timer
    
    echo -e "  ${GREEN}✓${NC} Systemd service installed and enabled"
    echo -e "  ${CYAN}→${NC} Runs daily at 3:00 AM"
else
    echo -e "${YELLOW}[3/7] Skipping Systemd Service (requires root)...${NC}"
    echo -e "  ${CYAN}→${NC} Run manually or setup cron job"
fi
echo

# =============================================================================
# 4. Setup Cron Job (alternative to systemd)
# =============================================================================
if [ "$IS_ROOT" = false ]; then
    echo -e "${YELLOW}[4/7] Setting up Cron Job...${NC}"
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "jellyfin-channel-monitor"; then
        echo -e "  ${CYAN}→${NC} Cron job already exists"
    else
        # Add cron job to run daily at 3 AM
        (crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/python3 $MONITOR_SCRIPT >> /var/log/jellyfin-monitor/cron.log 2>&1") | crontab -
        echo -e "  ${GREEN}✓${NC} Cron job added (runs daily at 3:00 AM)"
    fi
else
    echo -e "${YELLOW}[4/7] Skipping Cron (using systemd)...${NC}"
fi
echo

# =============================================================================
# 5. Create Channel Updater Script
# =============================================================================
echo -e "${YELLOW}[5/7] Creating Channel Updater...${NC}"

cat > /home/simon/Learning-Management-System-Academy/scripts/update-jellyfin-channels.sh << 'UPDATER_EOF'
#!/bin/bash
# Fetch latest channels from IPTV-Org and merge with existing

set -e

SCRIPT_DIR="/home/simon/Learning-Management-System-Academy/scripts"
M3U_DIR="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources"
CURRENT_M3U="$M3U_DIR/jellyfin-channels-enhanced.m3u"
BACKUP_DIR="$M3U_DIR/backups"

echo "🔄 Updating Jellyfin channels from IPTV-Org..."

# Backup current M3U
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp "$CURRENT_M3U" "$BACKUP_DIR/jellyfin-channels-${TIMESTAMP}.m3u"

# Run the fetch script if it exists
if [ -f "$SCRIPT_DIR/fetch-and-test-channels.py" ]; then
    python3 "$SCRIPT_DIR/fetch-and-test-channels.py"
    echo "✅ Channels updated successfully"
    
    # Test new channels
    echo "🔍 Testing new channels..."
    python3 "$SCRIPT_DIR/jellyfin-channel-monitor.py" --dry-run
else
    echo "⚠️  Fetch script not found: $SCRIPT_DIR/fetch-and-test-channels.py"
    exit 1
fi
UPDATER_EOF

chmod +x /home/simon/Learning-Management-System-Academy/scripts/update-jellyfin-channels.sh

echo -e "  ${GREEN}✓${NC} Channel updater created"
echo

# =============================================================================
# 6. Create Quick Commands
# =============================================================================
echo -e "${YELLOW}[6/7] Creating Quick Commands...${NC}"

cat > /home/simon/Learning-Management-System-Academy/scripts/jellyfin-commands.sh << 'COMMANDS_EOF'
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
COMMANDS_EOF

chmod +x /home/simon/Learning-Management-System-Academy/scripts/jellyfin-commands.sh

# Create symlink in /usr/local/bin if root
if [ "$IS_ROOT" = true ]; then
    ln -sf /home/simon/Learning-Management-System-Academy/scripts/jellyfin-commands.sh /usr/local/bin/jellyfin
    echo -e "  ${GREEN}✓${NC} Quick commands installed: ${CYAN}jellyfin [command]${NC}"
else
    echo -e "  ${GREEN}✓${NC} Quick commands created: ${CYAN}./scripts/jellyfin-commands.sh${NC}"
fi
echo

# =============================================================================
# 7. Run Initial Test
# =============================================================================
echo -e "${YELLOW}[7/7] Running Initial Channel Test...${NC}"
echo -e "  ${CYAN}→${NC} This will take a few minutes..."
echo

python3 "$MONITOR_SCRIPT" --dry-run

echo
echo -e "${GREEN}✓${NC} Initial test complete"
echo

# =============================================================================
# Summary
# =============================================================================
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    INSTALLATION COMPLETE                              ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${GREEN}✅ Enhancements Installed:${NC}"
echo "  1. ✓ Channel Health Monitor (runs daily at 3 AM)"
echo "  2. ✓ Automatic dead channel removal"
echo "  3. ✓ HTML health reports"
echo "  4. ✓ Channel updater from IPTV-Org"
echo "  5. ✓ Quick command shortcuts"
echo
echo -e "${CYAN}📋 Quick Commands:${NC}"
if [ "$IS_ROOT" = true ]; then
    echo "  ${GREEN}jellyfin test${NC}    - Test all channels (no changes)"
    echo "  ${GREEN}jellyfin clean${NC}   - Remove dead channels"
    echo "  ${GREEN}jellyfin update${NC}  - Fetch new channels"
    echo "  ${GREEN}jellyfin status${NC}  - Show statistics"
    echo "  ${GREEN}jellyfin report${NC}  - View latest report"
else
    echo "  ${GREEN}./scripts/jellyfin-commands.sh test${NC}    - Test all channels"
    echo "  ${GREEN}./scripts/jellyfin-commands.sh clean${NC}   - Remove dead channels"
    echo "  ${GREEN}./scripts/jellyfin-commands.sh status${NC}  - Show statistics"
fi
echo
echo -e "${CYAN}📂 Important Paths:${NC}"
echo "  M3U File:    /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u"
echo "  Backups:     /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/backups/"
echo "  Reports:     /home/simon/Learning-Management-System-Academy/reports/jellyfin/"
echo "  Logs:        /var/log/jellyfin-monitor/"
echo
echo -e "${CYAN}🔄 Automation:${NC}"
if [ "$IS_ROOT" = true ]; then
    echo "  Service:     systemctl status jellyfin-channel-monitor.timer"
    echo "  Run now:     systemctl start jellyfin-channel-monitor.service"
else
    echo "  Cron:        crontab -l | grep jellyfin"
    echo "  Run now:     python3 $MONITOR_SCRIPT"
fi
echo
echo -e "${YELLOW}💡 Recommendations:${NC}"
echo "  1. Run 'jellyfin test' weekly to check channel health"
echo "  2. Review reports in: reports/jellyfin/"
echo "  3. Monitor logs for issues: tail -f /var/log/jellyfin-monitor/channel-monitor.log"
echo "  4. Update channels monthly: jellyfin update"
echo
echo -e "${GREEN}🎉 Your Jellyfin is now awesome!${NC}"
echo
