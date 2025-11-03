#!/bin/bash
# Update all Moodle course files to fix mixed content audio links
# Usage: ./update_insecure_audio_links.sh <directory>

TARGET_DIR="${1:-.}"

find "$TARGET_DIR" -type f -exec sed -i \
  's|https://moodle.simondatalab.de/vietnamese-audio/|https://moodle.simondatalab.de/vietnamese-audio/|g' {} +

echo "All insecure audio links updated to HTTPS proxy!"