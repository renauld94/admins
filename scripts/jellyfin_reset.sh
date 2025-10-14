#!/bin/bash

# Jellyfin Reset Script
# Run this script on the Proxmox VM 200 console

echo "🔄 Jellyfin Reset Script"
echo "========================"

CONTAINER_NAME="jellyfin-simonadmin"
BACKUP_DIR="/tmp/jellyfin_backup_$(date +%Y%m%d_%H%M%S)"

echo "📋 Configuration:"
echo "  Container: $CONTAINER_NAME"
echo "  Backup Directory: $BACKUP_DIR"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop Jellyfin container
echo "🛑 Stopping Jellyfin container..."
docker stop "$CONTAINER_NAME"

# Backup current configuration
echo "💾 Backing up current configuration..."
docker cp "$CONTAINER_NAME:/config" "$BACKUP_DIR/"

# Remove problematic database files (if needed)
echo "🗑️  Removing problematic database files..."
docker exec "$CONTAINER_NAME" rm -f /config/data/jellyfin.db
docker exec "$CONTAINER_NAME" rm -f /config/data/jellyfin.db-shm
docker exec "$CONTAINER_NAME" rm -f /config/data/jellyfin.db-wal

# Start Jellyfin container
echo "🚀 Starting Jellyfin container..."
docker start "$CONTAINER_NAME"

# Wait for container to start
echo "⏳ Waiting for Jellyfin to start..."
sleep 30

# Check container status
echo "🔍 Checking container status..."
docker ps | grep "$CONTAINER_NAME"

echo ""
echo "✅ Jellyfin reset complete!"
echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
echo "📝 You may need to complete the initial setup again"
echo ""
echo "💾 Backup saved to: $BACKUP_DIR"
