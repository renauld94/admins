#!/bin/bash

# 🚀 Fast Portfolio Deployment Script
# Deploys changes in seconds using incremental rsync

# Configuration
LOCAL_PORTFOLIO="/home/simon/Desktop/Learning Management System Academy/portofio_simon_rennauld/simonrenauld.github.io"
REMOTE_HOST="136.243.155.166"
REMOTE_PORT="8082"
REMOTE_PATH="/var/www/html/portfolio"
SSH_KEY="$HOME/.ssh/proxmox_key"

echo "⚡ FAST DEPLOYMENT MODE ⚡"
echo "📁 Local: $LOCAL_PORTFOLIO"
echo "🌐 Remote: http://$REMOTE_HOST:$REMOTE_PORT/"

# Quick connection test
if ! curl -s --max-time 3 http://$REMOTE_HOST:$REMOTE_PORT/ > /dev/null; then
    echo "❌ Server unreachable"
    exit 1
fi

# Fast SSH deployment with optimized rsync
echo "🔄 Syncing files..."
start_time=$(date +%s)

rsync -avz --delete --exclude='.git' --exclude='node_modules' \
  -e "ssh -i $SSH_KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o Compression=yes" \
  "$LOCAL_PORTFOLIO/" root@$REMOTE_HOST:"$REMOTE_PATH/"

end_time=$(date +%s)
duration=$((end_time - start_time))

if [ $? -eq 0 ]; then
    echo "✅ Deployed in ${duration}s!"
    echo "🌐 Live at: http://$REMOTE_HOST:$REMOTE_PORT/"
else
    echo "❌ Deployment failed"
    exit 1
fi
