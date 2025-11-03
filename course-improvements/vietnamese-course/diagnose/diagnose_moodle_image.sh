#!/usr/bin/env bash
set -eu

# Diagnose Moodle image issues for course-default.svg (safe helper script)
# Usage: ./diagnose_moodle_image.sh <image_url> [path-to-webserver-logs]

IMAGE_URL=${1:-}
LOG_PATH=${2:-}

if [ -z "$IMAGE_URL" ]; then
  echo "Usage: $0 <image_url> [log_path]"
  echo "Example: $0 'https://moodle.simondatalab.de/theme/image.php/boost/core/1761792253/f/image' /var/log/nginx/access.log"
  exit 2
fi

echo "Checking headers for: $IMAGE_URL"
curl -I --max-time 10 "$IMAGE_URL" || true

echo "---- Attempting a full GET (first 1KB) ----"
curl --max-time 10 --range 0-1023 "$IMAGE_URL" || true

if [ -n "$LOG_PATH" ]; then
  echo "---- Searching logs for occurrences of 'course-default' ----"
  if [ ! -f "$LOG_PATH" ]; then
    echo "Log file not found: $LOG_PATH"
    exit 0
  fi
  sudo grep -n "course-default" "$LOG_PATH" | tail -n 50 || echo "No matches or permission denied"
fi

echo "Done. Review HTTP headers and logs for 404/403 or upstream errors."
