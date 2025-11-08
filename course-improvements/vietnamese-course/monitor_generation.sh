#!/bin/bash
# Content Generation Status Monitor
# Tracks progress of Vietnamese course content generation

COURSE_DIR="/home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course"
LOG_FILE="$COURSE_DIR/generation.log"
OUTPUT_DIR="$COURSE_DIR/generated/professional"

echo "========================================================================"
echo "  VIETNAMESE COURSE CONTENT GENERATION - STATUS MONITOR"
echo "========================================================================"
echo ""
echo "Monitoring directory: $OUTPUT_DIR"
echo "Log file: $LOG_FILE"
echo ""

# Count generated files
count_html=$(ls -1 "$OUTPUT_DIR"/*.html 2>/dev/null | wc -l)
count_quiz=$(ls -1 "$OUTPUT_DIR"/*.gift 2>/dev/null | wc -l)
count_flash=$(ls -1 "$OUTPUT_DIR"/*flashcards.csv 2>/dev/null | wc -l)
count_dialogue=$(ls -1 "$OUTPUT_DIR"/*dialogue.txt 2>/dev/null | wc -l)
count_audio=$(ls -1 "$OUTPUT_DIR"/*.mp3 2>/dev/null | wc -l)

echo "Generated Files Status:"
echo "  HTML Lessons:     $count_html / 8"
echo "  GIFT Quizzes:     $count_quiz / 8"
echo "  Flashcards:       $count_flash / 8"
echo "  Dialogues:        $count_dialogue / 8"
echo "  Audio Files:      $count_audio (supporting)"
echo ""

# Check if process is running
if pgrep -f "course_content_generator.py --generate-all" > /dev/null; then
    echo "Status: ⏳ RUNNING (in background)"
    echo "Process ID: $(pgrep -f "course_content_generator.py --generate-all")"
else
    echo "Status: ✅ COMPLETE or IDLE"
fi

echo ""
echo "Recent Log Output:"
echo "========================================================================"
tail -15 "$LOG_FILE" 2>/dev/null || echo "Log file not yet available"
echo "========================================================================"
echo ""
echo "To continue monitoring, run:"
echo "  tail -f $LOG_FILE"
echo ""
