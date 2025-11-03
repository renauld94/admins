#!/usr/bin/env bash
set -euo pipefail

# Simple deploy helper for the ASR service using Docker Compose (prod overlay)
# Usage: ./deploy.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f ./.env ]; then
  cp ./.env.example ./.env
  echo "Created .env from .env.example — edit .env to set ASR_API_KEY and optional HTUSER/HTPASS."
fi

# Optionally create htpasswd if HTUSER and HTPASS are set in .env
HTUSER=$(grep -E '^HTUSER=' .env 2>/dev/null | cut -d'=' -f2- || true)
HTPASS=$(grep -E '^HTPASS=' .env 2>/dev/null | cut -d'=' -f2- || true)
if [ -n "$HTUSER" ] && [ -n "$HTPASS" ]; then
  mkdir -p ./nginx
  echo "Creating htpasswd for user $HTUSER"
  docker run --rm --entrypoint htpasswd httpd:2 -Bbn "$HTUSER" "$HTPASS" > ./nginx/htpasswd
  chmod 600 ./nginx/htpasswd
fi

echo "Bringing up services with Docker Compose (this may take a few minutes on first run)..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d

echo "Done. Visit http://<server-ip>/ (or your domain) and POST to /transcribe (protected by htpasswd if configured)."
