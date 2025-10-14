#!/bin/bash

# Deploy homepage files to live Moodle server
# Uses ProxyJump SSH to connect through jump host to VM

set -e

# Configuration
JUMP_HOST="root@136.243.155.166:2222"
VM_USER="simonadmin"
VM_IP="10.0.0.104"
REMOTE_MOODLE_DIR="/opt/learning-platform/moodle"
REMOTE_THEME_DIR="/opt/learning-platform/moodle/theme/jnjboost.20250911_clean"
LOCAL_HOMEPAGE_DIR="/home/simon/Desktop/Learning Management System Academy/moodle-homepage"

echo "🚀 Deploying homepage files to live server..."

# Upload homepage files to temp location first
echo "Creating temp directory..."
ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "mkdir -p ~/homepage_temp"
echo "Uploading homepage files to temp location..."
scp -o ProxyJump=$JUMP_HOST "$LOCAL_HOMEPAGE_DIR/index.html" $VM_USER@$VM_IP:~/homepage_temp/
scp -o ProxyJump=$JUMP_HOST "$LOCAL_HOMEPAGE_DIR/styles.css" $VM_USER@$VM_IP:~/homepage_temp/
scp -o ProxyJump=$JUMP_HOST "$LOCAL_HOMEPAGE_DIR/app.js" $VM_USER@$VM_IP:~/homepage_temp/

# Move files to final location with sudo
echo "Moving files to Moodle directory..."
ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "sudo mkdir -p $REMOTE_MOODLE_DIR/homepage && sudo mv ~/homepage_temp/* $REMOTE_MOODLE_DIR/homepage/ && sudo chown -R daemon:daemon $REMOTE_MOODLE_DIR/homepage && sudo chmod -R 755 $REMOTE_MOODLE_DIR/homepage && rm -rf ~/homepage_temp"

# Copy theme files if they exist
if [ -d "/home/simon/Desktop/Learning Management System Academy/moodle/theme/jnjboost.20250908_124759" ]; then
    echo "Uploading theme files..."
    scp -o ProxyJump=$JUMP_HOST -r "/home/simon/Desktop/Learning Management System Academy/moodle/theme/jnjboost.20250908_124759" $VM_USER@$VM_IP:$REMOTE_MOODLE_DIR/theme/
    ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "sudo chown -R daemon:daemon $REMOTE_THEME_DIR"
fi

# Purge Moodle caches
echo "Purging Moodle caches..."
ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "cd $REMOTE_MOODLE_DIR && sudo -u daemon php admin/cli/purge_caches.php"

# Restart Moodle service
echo "Restarting Moodle service..."
ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "sudo /opt/bitnami/ctlscript.sh restart moodle"

echo "✅ Deployment complete!"
echo "🌐 Check your updated homepage at: http://136.243.155.166:8086/"
echo ""
echo "📝 If you don't see changes, try:"
echo "   - Hard refresh your browser (Ctrl+F5)"
echo "   - Clear browser cache"
echo "   - Check browser developer tools for any errors"
