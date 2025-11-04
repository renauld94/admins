#!/bin/bash

# Stop the stealth scraper gracefully

PID_FILE="outputs/slow_stealth/scraper.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "⚠️  No scraper PID file found"
    echo "Scraper may not be running"
    exit 1
fi

PID=$(cat "$PID_FILE")

if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "⚠️  Scraper not running (stale PID: $PID)"
    rm "$PID_FILE"
    exit 1
fi

echo "Stopping stealth scraper (PID: $PID)..."
kill -SIGINT "$PID"  # Graceful shutdown (allows saving progress)

# Wait for process to exit
sleep 2

if ps -p "$PID" > /dev/null 2>&1; then
    echo "⚠️  Scraper still running, forcing stop..."
    kill -9 "$PID"
fi

rm "$PID_FILE"
echo "✓ Scraper stopped"
echo ""
echo "Check results:"
echo "  cat outputs/slow_stealth/leads_$(date +%Y%m%d).json"
