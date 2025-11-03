#!/usr/bin/env bash
set -euo pipefail

# Find PIDs listening on :3000
PIDS=$(ss -ltnp | awk '/:3000[[:space:]]/ { if(match($0,/pid=([0-9]+)/,a)) print a[1] }' || true)
echo "pids:$PIDS"

if [ -n "${PIDS// /}" ]; then
  for pid in $PIDS; do
    echo "PID $pid -> "$(ps -p $pid -o pid,user,cmd --no-headers)
    echo "Sending TERM to $pid"
    sudo kill -TERM "$pid" || true
  done
  sleep 5
  PIDS2=$(ss -ltnp | awk '/:3000[[:space:]]/ { if(match($0,/pid=([0-9]+)/,a)) print a[1] }' || true)
  if [ -n "${PIDS2// /}" ]; then
    for pid in $PIDS2; do
      echo "PID $pid still present; sending KILL"
      sudo kill -KILL "$pid" || true
    done
  fi
else
  echo "No process listening on :3000"
fi

# Start or restart open-webui container
if sudo docker ps -a --format '{{.Names}} {{.Status}}' | grep -q '^open-webui\b'; then
  echo "Found open-webui container; attempting start/restart"
  # If it's Created, 'start' will work
  sudo docker start open-webui || sudo docker restart open-webui || true
else
  echo "open-webui container not found in docker ps -a; attempting docker compose in /opt/openwebui"
  if [ -f /opt/openwebui/docker-compose.yml ]; then
    echo "Found /opt/openwebui/docker-compose.yml; bringing up"
    sudo docker compose -f /opt/openwebui/docker-compose.yml up -d || true
  else
    echo "No open-webui container and no /opt/openwebui/docker-compose.yml; nothing to start"
  fi
fi

sleep 4

echo "Docker open-webui status:"
sudo docker ps --format '{{.Names}} {{.Status}} {{.Ports}}' | grep open-webui || true

echo "Socket listeners for :3000"
ss -ltnp | grep ':3000' || true
