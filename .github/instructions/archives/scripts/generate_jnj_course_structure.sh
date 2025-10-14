#!/bin/bash
# Script to replicate Johnson & Johnson Python Academy course structure with content
# Usage: bash generate_jnj_course_structure.sh /target/path

SRC="/home/simon/Learning Management System Academy/learning-platform/courses/johnson-johnson/python-academy"
DEST="$1"

if [ -z "$DEST" ]; then
  echo "Usage: $0 /target/path"
  exit 1
fi

mkdir -p "$DEST"
rsync -av --progress "$SRC/" "$DEST/"
echo "Johnson & Johnson Python Academy course structure and content copied to $DEST"
