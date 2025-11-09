#!/usr/bin/env python3
"""
Generate summary report for 2-day epic Moodle deployment
Usage: python3 generate_epic_moodle_report.py health_log orchestrator_log multimedia_log
"""
import sys
import json
from datetime import datetime

def parse_health_log(logfile):
    entries = []
    with open(logfile, 'r') as f:
        lines = f.readlines()
    for i in range(0, len(lines), 3):
        if i+2 < len(lines):
            ts = lines[i].strip().strip('- ')
            health = lines[i+1].strip()
            stats = lines[i+2].strip()
            try:
                health_json = json.loads(health)
                stats_json = json.loads(stats)
            except Exception:
                health_json = health
                stats_json = stats
            entries.append({'timestamp': ts, 'health': health_json, 'stats': stats_json})
    return entries

def main():
    if len(sys.argv) != 4:
        print("Usage: python3 generate_epic_moodle_report.py health_log orchestrator_log multimedia_log")
        sys.exit(1)
    health_log, orchestrator_log, multimedia_log = sys.argv[1:4]
    entries = parse_health_log(health_log)
    total_checks = len(entries)
    agents_up = sum(1 for e in entries if isinstance(e['health'], dict) and e['health'].get('agents_running', 0) > 0)
    multimedia_up = sum(1 for e in entries if isinstance(e['stats'], dict) and e['stats'].get('service') == 'multimedia')
    recordings = sum(e['stats'].get('microphone_recordings', 0) if isinstance(e['stats'], dict) else 0 for e in entries)
    print(f"\nEPIC MOODLE 2-DAY DEPLOYMENT SUMMARY\n{'='*40}")
    print(f"Total health checks: {total_checks}")
    print(f"Agents up: {agents_up}/{total_checks}")
    print(f"Multimedia service up: {multimedia_up}/{total_checks}")
    print(f"Total microphone recordings: {recordings}")
    print(f"\nSee orchestrator and multimedia logs for details.")

if __name__ == "__main__":
    main()
