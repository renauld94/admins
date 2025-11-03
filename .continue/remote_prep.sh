#!/usr/bin/env bash
set -euxo pipefail

echo '--- remove placeholder GGUF if present ---'
FILE=/mnt/newdisk/models/mistral-7b-v0.1/mistral-7b-v0.1.gguf
if [ -f "$FILE" ]; then
  sudo rm -f "$FILE"
  echo "Removed $FILE"
else
  echo "No placeholder file at $FILE"
fi

echo '--- ensure model dir exists and ownership ---'
sudo mkdir -p /mnt/newdisk/models/mistral-7b-v0.1
sudo chown $(id -un):$(id -gn) /mnt/newdisk/models/mistral-7b-v0.1 || true

echo '--- disk usage ---'
df -h /mnt/newdisk /

echo '--- setup swap if needed ---'
SWAP=/mnt/newdisk/swapfile
if swapon --show=NAME | grep -q "${SWAP}"; then
  echo "Swap $SWAP already active"
else
  if [ ! -f "$SWAP" ]; then
    echo "Creating swapfile $SWAP (16G)"
    sudo fallocate -l 16G "$SWAP"
    sudo chmod 600 "$SWAP"
    sudo mkswap "$SWAP"
  fi
  echo "Enabling swapfile"
  sudo swapon "$SWAP"
  if ! grep -qF "$SWAP none swap sw 0 0" /etc/fstab; then
    echo "$SWAP none swap sw 0 0" | sudo tee -a /etc/fstab
  fi
fi

echo '--- swap summary ---'
swapon --show || true
free -h || true

echo '--- set inotify watches ---'
echo 'fs.inotify.max_user_watches=524288' | sudo tee /etc/sysctl.d/99-user-watches.conf
sudo sysctl --system || true

echo '--- docker containers (names & images) ---'
sudo docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}' || true

for name in open-webui ollama; do
  if sudo docker ps -a --format '{{.Names}}' | grep -qw "$name"; then
    echo "--- mounts for container: $name ---"
    sudo docker inspect --format '{{json .Mounts}}' "$name" | python3 -m json.tool || true
  else
    echo "container $name not found"
  fi
done

echo '--- remote_prep done ---'
