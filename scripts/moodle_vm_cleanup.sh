#!/bin/bash
# Moodle VM 9001 Cleanup Script
# Run on simonadmin@10.0.0.104
# Purpose: Free up disk space and reduce memory pressure

set -e

echo "=== Moodle VM 9001 Maintenance ==="
echo "Started: $(date)"
echo ""

# 1. Top-level disk usage
echo "1. Checking top-level disk usage..."
sudo du -h --max-depth=1 / 2>/dev/null | sort -hr | head -20
echo ""

# 2. Current disk usage
echo "2. Current disk usage:"
df -h
echo ""

# 3. Check for old Proxmox backups (if path exists)
if [ -d /var/lib/vz/dump ]; then
    echo "3. Checking Proxmox backup archives..."
    sudo ls -lh --sort=time /var/lib/vz/dump/ | head -20
    echo ""
    echo "Old backups (30+ days):"
    sudo find /var/lib/vz -type f -name '*.tar*' -mtime +30 -print
    echo ""
fi

# 4. Check Moodle data directory
if [ -d /var/www/moodledata ]; then
    echo "4. Moodle data directory usage:"
    sudo du -sh /var/www/moodledata/* 2>/dev/null | sort -hr | head -15
    echo ""
fi

# 5. Log directory usage
echo "5. Log directory usage:"
sudo du -sh /var/log/* 2>/dev/null | sort -hr | head -15
echo ""

# 6. Check for large temporary files
echo "6. Large temporary files (>100MB):"
sudo find /tmp -type f -size +100M -exec ls -lh {} \; 2>/dev/null
echo ""

# Cleanup actions (uncomment when ready to execute)
read -p "Do you want to proceed with cleanup? (yes/no): " CONFIRM

if [ "$CONFIRM" = "yes" ]; then
    echo ""
    echo "=== Starting Cleanup ==="
    
    # Purge Moodle caches
    if [ -f /var/www/moodle/admin/cli/purge_caches.php ]; then
        echo "7. Purging Moodle caches..."
        sudo -u www-data php /var/www/moodle/admin/cli/purge_caches.php
        echo "✓ Moodle caches purged"
    fi
    
    # Clean package cache
    echo "8. Cleaning APT cache..."
    sudo apt-get clean
    echo "✓ APT cache cleaned"
    
    # Vacuum systemd journal
    echo "9. Vacuuming systemd journal to 200MB..."
    sudo journalctl --vacuum-size=200M
    echo "✓ Journal vacuumed"
    
    # Remove old temp files
    echo "10. Removing temp files older than 7 days..."
    sudo find /tmp -type f -mtime +7 -delete 2>/dev/null || true
    echo "✓ Old temp files removed"
    
    # Optional: Remove old log archives
    read -p "Remove old compressed logs in /var/log? (yes/no): " LOGS
    if [ "$LOGS" = "yes" ]; then
        echo "11. Removing old compressed logs..."
        sudo find /var/log -type f -name "*.gz" -mtime +30 -delete 2>/dev/null || true
        sudo find /var/log -type f -name "*.1" -mtime +7 -delete 2>/dev/null || true
        echo "✓ Old logs removed"
    fi
    
    echo ""
    echo "=== Cleanup Complete ==="
    echo "Final disk usage:"
    df -h
    echo ""
    echo "Memory usage:"
    free -h
else
    echo "Cleanup cancelled. Review the information above and run again when ready."
fi

echo ""
echo "Completed: $(date)"
echo ""
echo "=== Manual cleanup suggestions ==="
echo "• Review old Proxmox backups and remove with: sudo rm /var/lib/vz/dump/<filename>"
echo "• Check Moodle backup files in: /var/www/moodledata/backup/"
echo "• Archive old course content if needed"
echo "• Consider increasing VM RAM allocation in Proxmox if memory stays >90%"
