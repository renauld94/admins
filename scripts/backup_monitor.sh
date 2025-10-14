#!/bin/bash

# Backup Monitoring and Alert Script
# This script monitors backup status and sends alerts

BACKUP_DIR="/home/simon/Desktop/Learning Management System Academy/backups"
PROXMOX_IP="136.243.155.166"
ALERT_EMAIL="your-email@example.com"  # Replace with your email

echo "🔍 Checking backup status..."

# Check if backups exist from last 24 hours
RECENT_BACKUPS=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime -1 | wc -l)

if [ "$RECENT_BACKUPS" -eq 0 ]; then
    echo "❌ ALERT: No backups found in the last 24 hours!"
    # Send alert email (requires mailutils)
    # echo "Backup failed - no recent backups found" | mail -s "Backup Alert" "$ALERT_EMAIL"
else
    echo "✅ Found $RECENT_BACKUPS recent backup(s)"
fi

# Check Proxmox VM status
echo "🖥️ Checking Proxmox VM status..."
VM_STATUS=$(ssh root@$PROXMOX_IP "qm status 106" 2>/dev/null | awk '{print $2}')

if [ "$VM_STATUS" = "running" ]; then
    echo "✅ VM 106 is running"
else
    echo "❌ ALERT: VM 106 is not running (Status: $VM_STATUS)"
fi

# Check disk space
echo "💾 Checking disk space..."
DISK_USAGE=$(df -h "$BACKUP_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "⚠️ WARNING: Disk usage is ${DISK_USAGE}%"
else
    echo "✅ Disk usage is ${DISK_USAGE}%"
fi

# Check backup integrity
echo "🔍 Checking backup integrity..."
for backup in "$BACKUP_DIR"/*.tar.gz; do
    if [ -f "$backup" ]; then
        if tar -tzf "$backup" >/dev/null 2>&1; then
            echo "✅ $(basename "$backup"): Valid"
        else
            echo "❌ $(basename "$backup"): Corrupted"
        fi
    fi
done

echo "📊 Backup monitoring completed"
