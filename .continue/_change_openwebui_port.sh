#!/usr/bin/env bash
set -euo pipefail
COMPOSE=/opt/openwebui/docker-compose.yml
if [ ! -f "$COMPOSE" ]; then
  echo "No docker-compose file at $COMPOSE" >&2
  exit 1
fi

echo "Showing lines that mention 3000 or 8080 (for review)"
sudo sed -n '1,240p' "$COMPOSE" | nl -ba | sed -n '/3000\|8080/p' || true

BACKUP=${COMPOSE}.bak.$(date +%s)
sudo cp "$COMPOSE" "$BACKUP"
echo "Backup saved to $BACKUP"

# Replace host port 3000:8080 -> 3001:8080 (word-boundary safe)
sudo sed -i 's/\b3000:8080\b/3001:8080/g' "$COMPOSE"

echo "Lines after edit containing 3001 or 3000"
sudo sed -n '1,240p' "$COMPOSE" | nl -ba | sed -n '/3001\|3000/p' || true

# Bring up the stack
cd /opt/openwebui
sudo docker compose up -d || true
sleep 2

echo "Open-webui docker ps (filtered)"
sudo docker ps --filter name=open-webui --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' || true

echo "Listeners for :3001 and :3000"
ss -ltnp | grep ':3001' || true
ss -ltnp | grep ':3000' || true
