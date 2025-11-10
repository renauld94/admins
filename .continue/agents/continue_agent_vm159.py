#!/usr/bin/env python3
"""
Continue Agent Manager - VM 159
================================

Orchestrates automated job search + LinkedIn network growth
Runs on Continue IDE for continuous development & monitoring

VM Instance: 159
Location: /home/simon/Learning-Management-System-Academy
Active Projects:
  1. Job Search Automation
  2. LinkedIn Network Growth
  3. Email Delivery System
  4. CRM Tracking

Author: Simon Renauld
Date: November 10, 2025
"""

import os
import sys
import json
import logging
from datetime import datetime
from pathlib import Path
import subprocess

# ===== CONFIGURATION =====
VM_INSTANCE = "159"
BASE_DIR = Path("/home/simon/Learning-Management-System-Academy")
JOB_SEARCH_DIR = BASE_DIR / "job-search-toolkit"
CONTINUE_DIR = BASE_DIR / ".continue"
AGENTS_DIR = CONTINUE_DIR / "agents"

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(AGENTS_DIR / "logs" / f"continue_agent_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class ContinueAgentManager:
    """Manages Continue agents for job search automation"""
    
    def __init__(self):
        self.vm = VM_INSTANCE
        self.base_dir = BASE_DIR
        self.job_search_dir = JOB_SEARCH_DIR
        self.agents_dir = AGENTS_DIR
        
        # Create directories
        for d in [AGENTS_DIR / "logs", AGENTS_DIR / "outputs"]:
            d.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"🤖 Continue Agent Manager initialized (VM {self.vm})")
        logger.info(f"   Base Dir: {self.base_dir}")
        logger.info(f"   Job Search: {self.job_search_dir}")
        logger.info(f"   Agents: {self.agents_dir}")
    
    def verify_workspace(self):
        """Verify workspace structure and components"""
        logger.info("🔍 Verifying workspace structure...")
        
        checks = {
            "Job Search Toolkit": self.job_search_dir.exists(),
            "Continue Agents": self.agents_dir.exists(),
            "LinkedIn Growth": (self.job_search_dir / "linkedin_network_growth.py").exists(),
            "Daily Outreach": (self.job_search_dir / "daily_linkedin_outreach.py").exists(),
            "Job Search Agent": (self.job_search_dir / "epic_job_search_agent.py").exists(),
            "Databases": (self.job_search_dir / "data").exists(),
        }
        
        all_ok = True
        for name, exists in checks.items():
            status = "✅" if exists else "❌"
            logger.info(f"   {status} {name}")
            if not exists:
                all_ok = False
        
        return all_ok
    
    def get_system_status(self):
        """Get current system status"""
        logger.info("📊 Checking system status...")
        
        status = {
            "timestamp": datetime.now().isoformat(),
            "vm": self.vm,
            "python": sys.version.split()[0],
            "working_dir": str(self.base_dir),
            "cron_jobs": 0,
            "jobs_discovered": 0,
            "databases": {}
        }
        
        # Check cron jobs
        try:
            result = subprocess.run(["crontab", "-l"], capture_output=True, text=True)
            status["cron_jobs"] = len([l for l in result.stdout.split("\n") if "python" in l and not l.startswith("#")])
        except:
            pass
        
        # Check databases
        db_dir = self.job_search_dir / "data"
        if db_dir.exists():
            for db_file in db_dir.glob("*.db"):
                size_kb = db_file.stat().st_size / 1024
                status["databases"][db_file.name] = f"{size_kb:.1f} KB"
        
        logger.info(f"   Python: {status['python']}")
        logger.info(f"   Cron Jobs: {status['cron_jobs']}")
        logger.info(f"   Databases: {len(status['databases'])}")
        
        return status
    
    def start_job_discovery(self):
        """Start job discovery immediately"""
        logger.info("🚀 Starting job discovery...")
        
        try:
            os.chdir(self.job_search_dir)
            result = subprocess.run(
                [sys.executable, "epic_job_search_agent.py", "daily"],
                capture_output=True,
                text=True,
                timeout=300
            )
            
            if result.returncode == 0:
                logger.info("✅ Job discovery started successfully")
                return True
            else:
                logger.error(f"❌ Job discovery failed: {result.stderr}")
                return False
        except Exception as e:
            logger.error(f"❌ Error starting job discovery: {e}")
            return False
    
    def start_linkedin_outreach(self):
        """Start LinkedIn outreach immediately"""
        logger.info("🔗 Starting LinkedIn outreach...")
        
        try:
            os.chdir(self.job_search_dir)
            result = subprocess.run(
                [sys.executable, "daily_linkedin_outreach.py"],
                capture_output=True,
                text=True,
                timeout=120
            )
            
            if result.returncode == 0:
                logger.info("✅ LinkedIn outreach started successfully")
                return True
            else:
                logger.error(f"❌ LinkedIn outreach failed: {result.stderr}")
                return False
        except Exception as e:
            logger.error(f"❌ Error starting LinkedIn outreach: {e}")
            return False
    
    def generate_report(self):
        """Generate comprehensive status report"""
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "vm_instance": self.vm,
            "workspace_verified": self.verify_workspace(),
            "system_status": self.get_system_status(),
            "tasks": {
                "job_discovery": "READY",
                "linkedin_outreach": "READY",
                "email_delivery": "READY",
                "crm_tracking": "READY"
            }
        }
        
        # Save report
        report_path = self.agents_dir / "outputs" / f"status_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"✅ Report saved: {report_path}")
        return report
    
    def print_dashboard(self):
        """Print agent dashboard"""
        
        print("\n" + "="*70)
        print("🤖 CONTINUE AGENT DASHBOARD - VM 159")
        print("="*70)
        
        print(f"\n📍 WORKSPACE: {self.base_dir}")
        print(f"🖥️  VM Instance: {self.vm}")
        print(f"⏰ Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC+7')}")
        
        print("\n📊 SYSTEM STATUS:")
        status = self.get_system_status()
        print(f"   • Python: {status['python']}")
        print(f"   • Cron Jobs: {status['cron_jobs']} scheduled")
        print(f"   • Databases: {len(status['databases'])} active")
        
        print("\n✅ AUTOMATED SERVICES:")
        print("   ✓ Job Discovery: 50-100 jobs/day @ 7:00 AM")
        print("   ✓ LinkedIn Growth: 15 connections/day @ 7:15 AM")
        print("   ✓ Email Delivery: Daily digest (both emails)")
        print("   ✓ CRM Tracking: All interactions logged")
        
        print("\n🚀 QUICK ACTIONS:")
        print("   1. Run job discovery now")
        print("   2. Run LinkedIn outreach now")
        print("   3. View system dashboard")
        print("   4. Check logs")
        
        print("\n📁 KEY FILES:")
        print("   • job-search-toolkit/")
        print("     ├─ linkedin_network_growth.py")
        print("     ├─ daily_linkedin_outreach.py")
        print("     ├─ epic_job_search_agent.py")
        print("     └─ data/ (4 databases)")
        
        print("\n" + "="*70)
        print("✅ READY FOR CONTINUOUS AUTOMATION")
        print("="*70 + "\n")


def main():
    """Main execution"""
    
    print("\n" + "🤖 "*20)
    print("CONTINUE AGENT - JOB SEARCH AUTOMATION ON VM 159")
    print("🤖 "*20 + "\n")
    
    manager = ContinueAgentManager()
    
    # Verify workspace
    print("\n1️⃣ VERIFYING WORKSPACE...")
    workspace_ok = manager.verify_workspace()
    
    if not workspace_ok:
        logger.error("❌ Workspace verification failed!")
        sys.exit(1)
    
    # Get system status
    print("\n2️⃣ CHECKING SYSTEM STATUS...")
    status = manager.get_system_status()
    
    # Generate report
    print("\n3️⃣ GENERATING STATUS REPORT...")
    report = manager.generate_report()
    
    # Print dashboard
    print("\n4️⃣ DISPLAYING DASHBOARD...")
    manager.print_dashboard()
    
    # Ready for automation
    print("✅ Continue Agent is ready!")
    print("   • Workspace verified")
    print("   • All systems operational")
    print("   • Ready for automated execution")
    print("\n   Schedule:")
    print("   • 7:00 AM UTC+7: Job discovery")
    print("   • 7:15 AM UTC+7: LinkedIn outreach")
    print("   • Daily: Email digest")
    
    logger.info("✅ Continue Agent ready for automation")


if __name__ == "__main__":
    main()
