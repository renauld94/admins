#!/usr/bin/env python3
"""
Live Progress Viewer
Polls the orchestrator and multimedia services and prints a concise status snapshot every 3s.
"""
import time
import requests
import os
from datetime import datetime

ORCH_URL = "http://localhost:5100/health"
MULTI_URL = "http://localhost:5105/stats"
DATA_DIR = "/home/simon/Learning-Management-System-Academy/data"
MOODLE_PAGES_DIR = os.path.join(DATA_DIR, "moodle_pages")
MIC_RECORD_DIR = os.path.join(DATA_DIR, "multimedia", "microphone_recordings")
LOG_FILE = "/home/simon/Learning-Management-System-Academy/logs/multimedia_service.log"

def safe_get(url, timeout=2):
    try:
        r = requests.get(url, timeout=timeout)
        return r.status_code, r.json() if r.headers.get('content-type','').startswith('application/json') else r.text
    except Exception as e:
        return None, str(e)


def count_files(path):
    try:
        return len([f for f in os.listdir(path) if os.path.isfile(os.path.join(path,f))])
    except Exception:
        return 0


def tail(path, lines=5):
    try:
        with open(path, 'rb') as f:
            f.seek(0, os.SEEK_END)
            size = f.tell()
            block = -1
            data = []
            while len(data) < lines and size > 0:
                step = min(1024, size)
                f.seek(block * 1024, os.SEEK_END)
                data = f.read().decode(errors='replace').splitlines()
                block -= 1
            return '\n'.join(data[-lines:])
    except Exception as e:
        return f"(no log available: {e})"


if __name__ == '__main__':
    print("Live Progress Viewer — polling every 3 seconds. Press Ctrl-C to stop.")
    try:
        while True:
            ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            print('\n' + '='*80)
            print(f"[{ts}] Snapshot")

            # Orchestrator health
            status_code, orch = safe_get(ORCH_URL)
            if status_code == 200:
                tunnel = orch.get('tunnel', 'unknown') if isinstance(orch, dict) else 'unknown'
                agents_running = orch.get('agents_running', 'unknown') if isinstance(orch, dict) else 'unknown'
                total_agents = orch.get('total_agents', 'unknown') if isinstance(orch, dict) else 'unknown'
                print(f"Orchestrator: UP | tunnel={tunnel} | agents_running={agents_running}/{total_agents}")
            else:
                print(f"Orchestrator: DOWN | {orch}")

            # Multimedia stats
            status_code, multi = safe_get(MULTI_URL)
            if status_code == 200 and isinstance(multi, dict):
                mic_count = multi.get('microphone_recordings', 0)
                visuals_count = multi.get('visual_assets_generated', 0)
                audio_count = multi.get('audio_files', 0)
                print(f"Multimedia: UP | mic_recordings={mic_count} | visuals={visuals_count} | audio_files={audio_count}")
            else:
                print(f"Multimedia: DOWN or unavailable | {multi}")

            # File counts
            pages = count_files(MOODLE_PAGES_DIR)
            recordings = count_files(MIC_RECORD_DIR)
            print(f"Generated pages: {pages} html files | Saved recordings: {recordings}")

            # Tail logs
            recent = tail(LOG_FILE, lines=5)
            print('\nRecent multimedia_service.log:')
            print(recent)

            print('='*80)
            time.sleep(3)
    except KeyboardInterrupt:
        print('\nStopping live progress viewer.')
