#!/bin/bash

# --- CONFIGURATION ---
SRC_DIRS=(
    "/home/simon/Desktop/Python_Academy/Python Academy Courses"
    "/home/simon/Desktop/learning-platform"
)
STAGE_DIR="/home/simon/Desktop/learning-platform/moodle_upload_staging"

# --- PREPARE STAGING FOLDER ---
mkdir -p "$STAGE_DIR"

# --- CONVERT AND COPY ---
for SRC in "${SRC_DIRS[@]}"; do
    find "$SRC" \( -name "*.ipynb" -o -name "*.md" \) | while read -r FILE; do
        BASENAME=$(basename "$FILE" | sed 's/\.[^.]*$//')
        RELDIR=$(dirname "${FILE#$SRC/}")
        OUTDIR="$STAGE_DIR/$RELDIR"
        mkdir -p "$OUTDIR"

        # Convert Jupyter Notebooks
        if [[ "$FILE" == *.ipynb ]]; then
            jupyter nbconvert --to html "$FILE" --output "$OUTDIR/$BASENAME.html"
            jupyter nbconvert --to pdf "$FILE" --output "$OUTDIR/$BASENAME.pdf"
        fi

        # Convert Markdown to HTML and PDF
        if [[ "$FILE" == *.md ]]; then
            pandoc "$FILE" -o "$OUTDIR/$BASENAME.html"
            pandoc "$FILE" -o "$OUTDIR/$BASENAME.pdf"
        fi

        # Copy original file for reference
        cp "$FILE" "$OUTDIR/"
    done
done

echo "All course content converted and staged in: $STAGE_DIR"