#!/bin/bash

# Run Stealth Scraper All Day
# This script runs the slow scraper in the background and monitors it

DATE=$(date +%Y%m%d)
LOG_DIR="outputs/slow_stealth"
PID_FILE="$LOG_DIR/scraper.pid"

mkdir -p "$LOG_DIR"

echo "================================================"
echo "🕵️  STEALTH LINKEDIN SCRAPER - ALL DAY MODE"
echo "================================================"
echo ""
echo "Date: $(date '+%A, %B %d, %Y')"
echo "Start time: $(date '+%H:%M:%S')"
echo ""

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "⚠️  Scraper already running (PID: $OLD_PID)"
        echo ""
        echo "To view logs:"
        echo "  tail -f $LOG_DIR/scraper_${DATE}.log"
        echo ""
        echo "To stop:"
        echo "  kill $OLD_PID"
        exit 1
    else
        rm "$PID_FILE"
    fi
fi

# Start scraper in background
echo "Starting stealth scraper..."
echo "This will run for 8 hours with random delays (2-10 min between searches)"
echo ""

# Run Python scraper
python3 slow_stealth_scraper.py &
SCRAPER_PID=$!

# Save PID
echo "$SCRAPER_PID" > "$PID_FILE"

echo "✓ Scraper started (PID: $SCRAPER_PID)"
echo ""
echo "📊 Monitor progress:"
echo "  tail -f $LOG_DIR/scraper_${DATE}.log"
echo ""
echo "📁 Leads will be saved to:"
echo "  $LOG_DIR/leads_${DATE}.json"
echo ""
echo "⏸️  To stop scraper:"
echo "  kill $SCRAPER_PID"
echo "  OR"
echo "  ./stop_stealth_scraper.sh"
echo ""
echo "Scraper is now running in the background..."
echo "You can close this terminal - scraper will continue."
echo ""

# Optional: Show live logs
read -p "Show live logs now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    tail -f "$LOG_DIR/scraper_${DATE}.log"
fi
