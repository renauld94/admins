#!/bin/bash

# Config
REMOTE_USER="simonadmin"
REMOTE_VM_IP="10.0.0.104"
REMOTE_DIR="~"
JUMP_HOST="root@136.243.155.166"

SRC1="/home/simon/Desktop/learning-platform"
SRC2="/home/simon/Desktop/Python_Academy"

sync_folder() {
    local src="$1"
    echo -e "\n➡️  Syncing $src to $REMOTE_USER@$REMOTE_VM_IP (via $JUMP_HOST)\n"
    rsync -avz --no-group --no-times --progress -e "ssh -J $JUMP_HOST" "$src" "$REMOTE_USER@$REMOTE_VM_IP:$REMOTE_DIR"
    if [ $? -eq 0 ]; then
        echo -e "\n✅ Synced $src successfully.\n"
    else
        echo -e "\n❌ Failed to sync $src.\n"
    fi
}

sync_folder "$SRC1"
sync_folder "$SRC2"

echo "🎉 All done."
