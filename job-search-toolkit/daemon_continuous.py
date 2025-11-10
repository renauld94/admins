#!/usr/bin/env python3
"""
Continuous Background Daemon for VM 159
Runs job search and LinkedIn outreach continuously with slow rate limiting
"""

import json
import logging
import time
import subprocess
import signal
import sys
from datetime import datetime, timedelta
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - [DAEMON] - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('outputs/logs/daemon_continuous.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class ContinuousJobSearchDaemon:
    """Daemon for continuous background job search"""
    
    def __init__(self, config_path: str = "config/profile.json"):
        self.config = self._load_config(config_path)
        self.running = True
        self.cycle_count = 0
        self.start_time = datetime.now()
        
        # Rate limiting from profile
        self.max_apps_per_day = self.config['job_search_settings']['max_applications_per_day']
        self.max_linkedin_conn = self.config['job_search_settings']['max_linkedin_connections_per_day']
        self.max_linkedin_msgs = self.config['job_search_settings']['max_linkedin_messages_per_day']
        self.slowdown_factor = self.config['job_search_settings']['slowdown_factor']
        self.rate_limit_seconds = self.config['job_search_settings']['rate_limit_seconds']
        
        # Calculate delays
        self.job_discovery_interval = (60 * 60 / max(1, self.max_apps_per_day)) * self.slowdown_factor
        self.linkedin_interval = (60 * 60 / max(1, self.max_linkedin_conn)) * self.slowdown_factor
        self.message_interval = (60 * 60 / max(1, self.max_linkedin_msgs)) * self.slowdown_factor
        
    def _load_config(self, config_path: str) -> dict:
        """Load profile configuration"""
        with open(config_path) as f:
            return json.load(f)
    
    def setup_signal_handlers(self):
        """Setup graceful shutdown handlers"""
        def signal_handler(sig, frame):
            logger.info("\n🛑 Graceful shutdown initiated...")
            self.running = False
            sys.exit(0)
        
        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        logger.info("✅ Signal handlers registered")
    
    def print_startup_banner(self):
        """Print daemon startup banner"""
        logger.info("=" * 80)
        logger.info("🚀 EPIC JOB SEARCH CONTINUOUS DAEMON - VM 159")
        logger.info("=" * 80)
        logger.info(f"⏰ Started: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        logger.info(f"📍 Target Regions: {', '.join(self.config['target_regions'].keys())}")
        logger.info(f"🎯 Target Roles: {', '.join(self.config['target_roles'][:3])}...")
        logger.info(f"💰 Salary Range: ${self.config['compensation']['minimum_salary']}K - ${self.config['compensation']['maximum_salary']}K")
        logger.info("")
        logger.info("📊 RATE LIMITING SETTINGS:")
        logger.info(f"   Max Applications/Day: {self.max_apps_per_day}")
        logger.info(f"   Max LinkedIn Connections/Day: {self.max_linkedin_conn}")
        logger.info(f"   Max LinkedIn Messages/Day: {self.max_linkedin_msgs}")
        logger.info(f"   Slowdown Factor: {self.slowdown_factor}x")
        logger.info(f"   Base Rate Limit: {self.rate_limit_seconds}s between actions")
        logger.info("")
        logger.info("⏳ CALCULATED INTERVALS:")
        logger.info(f"   Job Discovery: {self.job_discovery_interval:.0f}s")
        logger.info(f"   LinkedIn Connection: {self.linkedin_interval:.0f}s")
        logger.info(f"   LinkedIn Messaging: {self.message_interval:.0f}s")
        logger.info("=" * 80)
    
    def run_job_discovery(self):
        """Run multi-source job discovery"""
        logger.info("🔍 Starting job discovery cycle...")
        try:
            result = subprocess.run(
                ['python3', 'multi_source_scraper.py'],
                capture_output=True,
                text=True,
                timeout=300
            )
            if result.returncode == 0:
                logger.info("✅ Job discovery completed")
            else:
                logger.warning(f"⚠️ Job discovery returned: {result.returncode}")
        except Exception as e:
            logger.error(f"❌ Job discovery failed: {e}")
    
    def run_job_scoring(self):
        """Run job scoring and ranking"""
        logger.info("🎯 Starting job scoring...")
        try:
            result = subprocess.run(
                ['python3', 'advanced_job_scorer.py', 'batch'],
                capture_output=True,
                text=True,
                timeout=300
            )
            if result.returncode == 0:
                logger.info("✅ Job scoring completed")
            else:
                logger.warning(f"⚠️ Job scoring returned: {result.returncode}")
        except Exception as e:
            logger.error(f"❌ Job scoring failed: {e}")
    
    def run_recruiter_outreach(self):
        """Run recruiter identification and outreach"""
        logger.info("👥 Starting recruiter outreach...")
        try:
            result = subprocess.run(
                ['python3', 'recruiter_finder.py'],
                capture_output=True,
                text=True,
                timeout=300
            )
            if result.returncode == 0:
                logger.info("✅ Recruiter identification completed")
            else:
                logger.warning(f"⚠️ Recruiter finder returned: {result.returncode}")
        except Exception as e:
            logger.error(f"❌ Recruiter outreach failed: {e}")
    
    def run_linkedin_campaign(self):
        """Run LinkedIn connection campaign"""
        logger.info("🔗 Starting LinkedIn campaign...")
        try:
            result = subprocess.run(
                ['python3', 'linkedin_contact_orchestrator.py', 'campaign', '--slow'],
                capture_output=True,
                text=True,
                timeout=600
            )
            if result.returncode == 0:
                logger.info("✅ LinkedIn campaign completed")
            else:
                logger.warning(f"⚠️ LinkedIn campaign returned: {result.returncode}")
        except Exception as e:
            logger.error(f"❌ LinkedIn campaign failed: {e}")
    
    def run_metrics_update(self):
        """Update dashboard metrics"""
        logger.info("📊 Updating metrics...")
        try:
            result = subprocess.run(
                ['python3', 'job_search_dashboard.py', 'daily'],
                capture_output=True,
                text=True,
                timeout=120
            )
            if result.returncode == 0:
                logger.info("✅ Metrics updated")
            else:
                logger.warning(f"⚠️ Metrics update returned: {result.returncode}")
        except Exception as e:
            logger.error(f"❌ Metrics update failed: {e}")
    
    def print_cycle_summary(self):
        """Print cycle summary"""
        uptime = datetime.now() - self.start_time
        hours = uptime.total_seconds() / 3600
        
        logger.info("")
        logger.info("=" * 80)
        logger.info(f"📈 DAEMON CYCLE #{self.cycle_count}")
        logger.info("=" * 80)
        logger.info(f"⏰ Uptime: {hours:.1f} hours")
        logger.info(f"📍 VM: 159 (vm159.local)")
        logger.info(f"🔄 Next cycle in {self.job_discovery_interval:.0f}s")
        logger.info("=" * 80)
        logger.info("")
    
    def run_continuous_loop(self):
        """Main continuous execution loop"""
        self.print_startup_banner()
        self.setup_signal_handlers()
        
        logger.info("🟢 Daemon entering continuous mode")
        logger.info("💡 Tip: Press Ctrl+C to gracefully shutdown")
        logger.info("")
        
        try:
            while self.running:
                self.cycle_count += 1
                
                logger.info(f"\n{'='*80}")
                logger.info(f"🔄 CYCLE #{self.cycle_count} - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                logger.info(f"{'='*80}\n")
                
                # Job discovery
                self.run_job_discovery()
                self._wait_with_interval("Job Discovery", self.job_discovery_interval)
                
                # Job scoring
                self.run_job_scoring()
                self._wait_with_interval("Job Scoring", self.job_discovery_interval)
                
                # Recruiter outreach
                self.run_recruiter_outreach()
                self._wait_with_interval("Recruiter Outreach", self.linkedin_interval)
                
                # LinkedIn campaign (slow)
                self.run_linkedin_campaign()
                self._wait_with_interval("LinkedIn Campaign", self.linkedin_interval)
                
                # Metrics update
                self.run_metrics_update()
                self._wait_with_interval("Metrics Update", 60)
                
                # Print cycle summary
                self.print_cycle_summary()
                
                # Wait before next cycle (30 minutes default)
                cycle_interval = 30 * 60
                logger.info(f"⏳ Waiting {cycle_interval}s before next cycle...")
                self._wait_with_interval("Next Cycle", cycle_interval)
        
        except KeyboardInterrupt:
            logger.info("\n🛑 Daemon shutting down...")
        finally:
            self.print_shutdown_summary()
    
    def _wait_with_interval(self, phase: str, seconds: int):
        """Wait with logging every 10 seconds"""
        remaining = seconds
        while remaining > 0 and self.running:
            sleep_time = min(10, remaining)
            time.sleep(sleep_time)
            remaining -= sleep_time
            
            if remaining > 0:
                logger.debug(f"   ⏳ {phase}: {remaining:.0f}s remaining")
    
    def print_shutdown_summary(self):
        """Print final shutdown summary"""
        uptime = datetime.now() - self.start_time
        hours = uptime.total_seconds() / 3600
        
        logger.info("\n" + "=" * 80)
        logger.info("🛑 DAEMON SHUTDOWN SUMMARY")
        logger.info("=" * 80)
        logger.info(f"⏰ Total Uptime: {hours:.1f} hours")
        logger.info(f"🔄 Cycles Completed: {self.cycle_count}")
        logger.info(f"📝 Log File: outputs/logs/daemon_continuous.log")
        logger.info("=" * 80)


def main():
    daemon = ContinuousJobSearchDaemon()
    daemon.run_continuous_loop()


if __name__ == "__main__":
    main()
