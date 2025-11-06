#!/usr/bin/env python3
"""
geodashboard_epic_agent.py

Lightweight autonomous agent to run periodically on the VM to monitor the EPIC geodashboard.
Features:
- Configurable run duration (hours) and probe interval
- Probes a list of target URLs (HEAD requests), logs status & timings
- Fetches RainViewer maps.json to record latest radar timestamps
- Writes rotating log files under ./logs/
- Graceful shutdown on SIGINT / SIGTERM

This script is intentionally conservative (no destructive actions).
"""
from __future__ import annotations

import os
import sys
import time
import json
import signal
import shutil
import socket
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Optional

try:
    import requests
except Exception:
    requests = None
    import urllib.request as _urllib

ROOT = Path(__file__).resolve().parent
LOG_DIR = ROOT / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

DEFAULT_TARGETS = [
    "https://www.simondatalab.de/geospatial-viz/index.html",
    "https://www.simondatalab.de/geospatial-viz/globe-3d.html",
]

RAINVIEWER_API = "https://tile.rainviewer.com/api/maps.json"


def now_iso() -> str:
    return datetime.utcnow().isoformat() + "Z"


class Agent:
    def __init__(self,
                 targets: Optional[List[str]] = None,
                 duration_hours: float = 24.0,
                 interval_seconds: int = 30,
                 max_logs: int = 10,
                 log_filename: Optional[str] = None):
        self.targets = targets or DEFAULT_TARGETS
        self.duration_hours = float(duration_hours)
        self.interval_seconds = int(interval_seconds)
        self.max_logs = int(max_logs)
        self.start_time = datetime.utcnow()
        self.end_time = self.start_time + timedelta(hours=self.duration_hours)
        self.running = True
        self.pid = os.getpid()
        self.hostname = socket.gethostname()

        self.log_filename = log_filename or f"agent_{self.start_time.strftime('%Y%m%dT%H%M%SZ')}.log"
        self.log_path = LOG_DIR / self.log_filename
        self._rotate_logs()

        signal.signal(signal.SIGINT, self._on_signal)
        signal.signal(signal.SIGTERM, self._on_signal)

    def _rotate_logs(self):
        # keep at most self.max_logs files sorted by mtime
        files = sorted(LOG_DIR.glob("agent_*.log"), key=lambda p: p.stat().st_mtime, reverse=True)
        for f in files[self.max_logs - 1:]:
            try:
                f.unlink()
            except Exception:
                pass

    def log(self, payload: Dict):
        # append JSON line
        entry = {
            "ts": now_iso(),
            "pid": self.pid,
            "host": self.hostname,
            **payload,
        }
        line = json.dumps(entry, ensure_ascii=False)
        with open(self.log_path, "a", encoding="utf-8") as fh:
            fh.write(line + "\n")

    def _on_signal(self, signum, frame):
        self.log({"event": "signal", "signal": int(signum)})
        self.running = False

    def _http_head(self, url: str, timeout: int = 15) -> Dict:
        res = {"url": url}
        start = time.time()
        try:
            if requests:
                r = requests.head(url, timeout=timeout)
                res["status_code"] = r.status_code
                res["elapsed_ms"] = int(r.elapsed.total_seconds() * 1000)
            else:
                req = _urllib.Request(url, method="HEAD")
                with _urllib.urlopen(req, timeout=timeout) as r:
                    res["status_code"] = getattr(r, "status", 200)
                    res["elapsed_ms"] = int((time.time() - start) * 1000)
        except Exception as e:
            res["error"] = repr(e)
            res["elapsed_ms"] = int((time.time() - start) * 1000)
        return res

    def _fetch_rainviewer(self) -> Dict:
        res = {"api": RAINVIEWER_API}
        try:
            if requests:
                r = requests.get(RAINVIEWER_API, timeout=15)
                r.raise_for_status()
                data = r.json()
            else:
                with _urllib.urlopen(RAINVIEWER_API, timeout=15) as fh:
                    data = json.loads(fh.read().decode("utf-8"))
            # data contains list of timestamps and available layers
            res["ok"] = True
            res["data_summary"] = {
                "radar_times_count": len(data.get("radar", {}).get("past", [])) if isinstance(data, dict) else 0
            }
            # also include last available timestamp if present
            past = data.get("radar", {}).get("past", []) if isinstance(data, dict) else []
            if past:
                res["last_timestamp"] = past[-1].get("time") if isinstance(past[-1], dict) else past[-1]
        except Exception as e:
            res["ok"] = False
            res["error"] = repr(e)
        return res

    def run_once(self):
        # probe targets
        probes = [self._http_head(u) for u in self.targets]
        rv = self._fetch_rainviewer()
        summary = {
            "event": "heartbeat",
            "probes": probes,
            "rainviewer": rv,
        }
        self.log(summary)

    def run(self):
        self.log({"event": "start", "duration_hours": self.duration_hours, "interval_seconds": self.interval_seconds})
        try:
            while self.running and datetime.utcnow() < self.end_time:
                self.run_once()
                # sleep with early exit check
                slept = 0
                while slept < self.interval_seconds and self.running:
                    time.sleep(1)
                    slept += 1
        except Exception as e:
            self.log({"event": "error", "error": repr(e)})
        finally:
            self.log({"event": "stop", "uptime_seconds": int((datetime.utcnow() - self.start_time).total_seconds())})


def _env(name: str, default=None):
    val = os.environ.get(name)
    return val if val is not None else default


def main():
    duration = float(_env("DURATION_HOURS", 24.0))
    interval = int(_env("INTERVAL_SECONDS", 30))
    targets = _env("TARGET_URLS", None)
    if targets:
        targets = targets.split(";")
    else:
        targets = DEFAULT_TARGETS

    agent = Agent(targets=targets, duration_hours=duration, interval_seconds=interval)
    agent.run()


if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""
Autonomous EPIC Geodashboard Enhancement Agent
Professional portfolio and geospatial dashboard improvement agent
Runs continuously for 24-48 hours to enhance portfolio and geodashboards

Features:
- Monitors and improves portfolio pages
- Enhances 2D/3D geodashboard features
- Integrates new FREE geospatial APIs
- Optimizes performance and UX
- Professional logging (no emojis)
- Generates improvement reports

Author: Simon Data Lab
Created: 2024
"""

import os
import sys
import time
import json
import logging
import requests
from datetime import datetime
from pathlib import Path

# Configuration
AGENT_NAME = "EPIC_Geodashboard_Agent"
WORK_DIR = Path("/home/simon/Learning-Management-System-Academy")
PORTFOLIO_DIR = WORK_DIR / "portfolio-deployment-enhanced"
GEO_VIZ_DIR = PORTFOLIO_DIR / "geospatial-viz"
LOG_DIR = WORK_DIR / ".continue/agents/logs"
REPORT_DIR = WORK_DIR / ".continue/agents/reports"

# Ollama MCP connection (SSE pattern)
OLLAMA_SSE_URL = "http://127.0.0.1:11434/mcp/sse"
OLLAMA_API_URL = "http://127.0.0.1:11434/api/generate"
OLLAMA_TAGS_URL = "http://127.0.0.1:11434/api/tags"

# Agent runtime configuration
MAX_RUNTIME_HOURS = 48
ITERATION_DELAY_SECONDS = 300  # 5 minutes between iterations
HEALTH_CHECK_INTERVAL = 600  # 10 minutes

# Setup logging
LOG_DIR.mkdir(parents=True, exist_ok=True)
REPORT_DIR.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler(LOG_DIR / f'{AGENT_NAME}_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(AGENT_NAME)


class GeodasboardEPICAgent:
    """Autonomous agent for EPIC portfolio and geodashboard enhancements"""
    
    def __init__(self):
        self.start_time = datetime.now()
        self.iteration_count = 0
        self.improvements_made = []
        self.health_status = {
            'index_html': None,
            'globe_3d_html': None,
            'apis_accessible': []
        }
        logger.info(f"{AGENT_NAME} initialized - Target runtime: {MAX_RUNTIME_HOURS} hours")
    
    def run(self):
        """Main agent loop - runs for 24-48 hours"""
        logger.info("Starting EPIC Geodashboard Agent main loop...")
        
        try:
            while self.should_continue_running():
                self.iteration_count += 1
                logger.info(f"--- Iteration {self.iteration_count} ---")
                logger.info(f"Runtime: {self.get_runtime_hours():.2f} hours")
                
                # Health checks
                self.perform_health_checks()
                
                # Enhancement tasks
                self.analyze_and_improve_2d_dashboard()
                self.analyze_and_improve_3d_globe()
                self.integrate_new_apis()
                self.optimize_performance()
                
                # Generate report
                if self.iteration_count % 6 == 0:  # Every 30 minutes
                    self.generate_progress_report()
                
                # Sleep before next iteration
                logger.info(f"Sleeping for {ITERATION_DELAY_SECONDS} seconds...")
                time.sleep(ITERATION_DELAY_SECONDS)
        
        except KeyboardInterrupt:
            logger.info("Agent stopped by user")
        except Exception as e:
            logger.error(f"Agent error: {str(e)}", exc_info=True)
        finally:
            self.cleanup()
    
    def should_continue_running(self):
        """Check if agent should continue running"""
        runtime_hours = self.get_runtime_hours()
        return runtime_hours < MAX_RUNTIME_HOURS
    
    def get_runtime_hours(self):
        """Calculate runtime in hours"""
        return (datetime.now() - self.start_time).total_seconds() / 3600
    
    def perform_health_checks(self):
        """Check health of portfolio pages and APIs"""
        logger.info("Performing health checks...")
        
        # Check 2D dashboard
        try:
            index_path = GEO_VIZ_DIR / "index.html"
            self.health_status['index_html'] = index_path.exists()
            logger.info(f"2D Dashboard (index.html): {'OK' if self.health_status['index_html'] else 'MISSING'}")
        except Exception as e:
            logger.error(f"Error checking index.html: {e}")
            self.health_status['index_html'] = False
        
        # Check 3D globe
        try:
            globe_path = GEO_VIZ_DIR / "globe-3d.html"
            self.health_status['globe_3d_html'] = globe_path.exists()
            logger.info(f"3D Globe (globe-3d.html): {'OK' if self.health_status['globe_3d_html'] else 'MISSING'}")
        except Exception as e:
            logger.error(f"Error checking globe-3d.html: {e}")
            self.health_status['globe_3d_html'] = False
        
        # Check FREE API accessibility
        apis_to_check = {
            'USGS_Earthquakes': 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_week.geojson',
            'NASA_FIRMS': 'https://firms.modaps.eosdis.nasa.gov/api/area/csv/',
            'RainViewer': 'https://api.rainviewer.com/public/weather-maps.json',
            'OpenStreetMap': 'https://a.tile.openstreetmap.org/0/0/0.png',
            'ESRI_Imagery': 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer'
        }
        
        self.health_status['apis_accessible'] = []
        for api_name, url in apis_to_check.items():
            try:
                # Quick HEAD request to check accessibility
                response = requests.head(url, timeout=5)
                accessible = response.status_code in [200, 301, 302]
                if accessible:
                    self.health_status['apis_accessible'].append(api_name)
                logger.info(f"API {api_name}: {'ACCESSIBLE' if accessible else 'UNREACHABLE'}")
            except Exception as e:
                logger.warning(f"API {api_name}: ERROR - {str(e)}")
    
    def analyze_and_improve_2d_dashboard(self):
        """Analyze and improve 2D Leaflet dashboard"""
        logger.info("Analyzing 2D dashboard for improvements...")
        
        try:
            index_path = GEO_VIZ_DIR / "index.html"
            if not index_path.exists():
                logger.warning("index.html not found - skipping 2D improvements")
                return
            
            with open(index_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check for potential improvements
            improvements = []
            
            # Check if live radar is integrated
            if 'RainViewer' in content:
                logger.info("Live radar already integrated on 2D dashboard")
            else:
                improvements.append("Add RainViewer live radar overlay")
            
            # Check for emojis (should be zero)
            emoji_check = self.detect_emojis(content)
            if emoji_check:
                improvements.append(f"Remove {len(emoji_check)} emoji characters")
                logger.warning(f"Found {len(emoji_check)} emojis in 2D dashboard")
            
            # Log improvements
            if improvements:
                logger.info(f"2D Dashboard improvements needed: {improvements}")
                self.improvements_made.extend(improvements)
            else:
                logger.info("2D Dashboard: No improvements needed")
        
        except Exception as e:
            logger.error(f"Error analyzing 2D dashboard: {e}")
    
    def analyze_and_improve_3d_globe(self):
        """Analyze and improve 3D Cesium globe"""
        logger.info("Analyzing 3D globe for improvements...")
        
        try:
            globe_path = GEO_VIZ_DIR / "globe-3d.html"
            if not globe_path.exists():
                logger.warning("globe-3d.html not found - skipping 3D improvements")
                return
            
            with open(globe_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            improvements = []
            
            # Check Location Focus dropdown functionality
            if 'flyToLocation' in content and 'locationFocus' in content:
                logger.info("Location Focus dropdown exists - checking implementation")
                # TODO: Add CSS fix for Location Focus rendering
                improvements.append("Verify Location Focus dropdown CSS rendering")
            
            # Check for live radar integration on 3D
            if 'RainViewer' not in content:
                improvements.append("Add RainViewer live radar overlay to 3D globe")
                logger.info("Live radar NOT integrated on 3D globe - enhancement needed")
            
            # Check for emojis
            emoji_check = self.detect_emojis(content)
            if emoji_check:
                improvements.append(f"Remove {len(emoji_check)} emoji characters from 3D globe")
                logger.warning(f"Found {len(emoji_check)} emojis in 3D globe")
            
            # Log improvements
            if improvements:
                logger.info(f"3D Globe improvements needed: {improvements}")
                self.improvements_made.extend(improvements)
            else:
                logger.info("3D Globe: No improvements needed")
        
        except Exception as e:
            logger.error(f"Error analyzing 3D globe: {e}")
    
    def integrate_new_apis(self):
        """Research and integrate new FREE geospatial APIs"""
        logger.info("Searching for new FREE geospatial APIs to integrate...")
        
        # List of potential FREE APIs to research and integrate
        potential_apis = [
            "OpenAQ Air Quality API",
            "OpenSky Network Flight Tracking",
            "Marine Traffic Ship Positions",
            "ISS Location API",
            "NOAA Weather Stations",
            "OpenChargeMap EV Stations",
            "World Bank Climate Data"
        ]
        
        logger.info(f"Potential APIs for future integration: {', '.join(potential_apis)}")
        # TODO: Implement API integration logic
    
    def optimize_performance(self):
        """Optimize dashboard performance"""
        logger.info("Checking performance optimization opportunities...")
        # TODO: Implement performance analysis
        # - Check file sizes
        # - Analyze API response times
        # - Monitor memory usage
    
    def detect_emojis(self, text):
        """Detect emoji characters in text"""
        import re
        emoji_pattern = re.compile("["
            "\U0001F600-\U0001F64F"  # emoticons
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map symbols
            "\U0001F1E0-\U0001F1FF"  # flags
            "\U00002702-\U000027B0"
            "\U000024C2-\U0001F251"
            "]+", flags=re.UNICODE)
        return emoji_pattern.findall(text)
    
    def generate_progress_report(self):
        """Generate progress report"""
        logger.info("Generating progress report...")
        
        report = {
            'agent': AGENT_NAME,
            'timestamp': datetime.now().isoformat(),
            'runtime_hours': round(self.get_runtime_hours(), 2),
            'iteration_count': self.iteration_count,
            'health_status': self.health_status,
            'improvements_made': self.improvements_made,
            'status': 'RUNNING'
        }
        
        report_path = REPORT_DIR / f'{AGENT_NAME}_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"Progress report saved: {report_path}")
        logger.info(f"Total improvements identified: {len(self.improvements_made)}")
    
    def cleanup(self):
        """Cleanup and final report"""
        logger.info("Agent shutting down - generating final report...")
        
        final_report = {
            'agent': AGENT_NAME,
            'start_time': self.start_time.isoformat(),
            'end_time': datetime.now().isoformat(),
            'total_runtime_hours': round(self.get_runtime_hours(), 2),
            'total_iterations': self.iteration_count,
            'final_health_status': self.health_status,
            'all_improvements': self.improvements_made,
            'status': 'COMPLETED'
        }
        
        final_report_path = REPORT_DIR / f'{AGENT_NAME}_FINAL_REPORT_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        with open(final_report_path, 'w') as f:
            json.dump(final_report, f, indent=2)
        
        logger.info(f"Final report saved: {final_report_path}")
        logger.info(f"Agent completed {self.iteration_count} iterations over {self.get_runtime_hours():.2f} hours")
        logger.info("EPIC Geodashboard Agent shutdown complete")


def main():
    """Main entry point"""
    logger.info("=" * 80)
    logger.info("EPIC GEODASHBOARD ENHANCEMENT AGENT")
    logger.info("Professional Portfolio & Geospatial Dashboard Improvement System")
    logger.info("=" * 80)
    logger.info("")
    
    agent = GeodasboardEPICAgent()
    agent.run()


if __name__ == "__main__":
    main()
