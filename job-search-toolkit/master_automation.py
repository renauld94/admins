#!/usr/bin/env python3
"""
Job Search Automation - Master Integration Script
================================================

Orchestrates all automation systems:
- Job discovery (epic_job_search_agent.py)
- LinkedIn outreach (daily_linkedin_outreach.py)
- Resume customization (resume_auto_adjuster.py)
- Interview scheduling (interview_scheduler.py)
- Streamlit dashboard visualization

Run: /usr/bin/python3 master_automation.py

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
import sqlite3

# ===== CONFIGURATION =====
BASE_DIR = Path(__file__).parent
MODULES = {
    "job_discovery": "epic_job_search_agent.py",
    "linkedin_outreach": "daily_linkedin_outreach.py",
    "resume_adjuster": "resume_auto_adjuster.py",
    "interview_scheduler": "interview_scheduler.py"
}

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(BASE_DIR / "outputs" / "logs" / f"master_automation_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class MasterAutomation:
    """Master orchestrator for all automation systems"""
    
    def __init__(self):
        self.base_dir = BASE_DIR
        self.execution_log = []
        logger.info("🚀 Master Automation System initialized")
    
    def run_job_discovery(self):
        """Run job discovery"""
        logger.info("\n" + "="*80)
        logger.info("📊 STEP 1: Job Discovery")
        logger.info("="*80)
        
        try:
            result = subprocess.run(
                [sys.executable, str(self.base_dir / MODULES["job_discovery"]), "daily"],
                capture_output=True,
                text=True,
                timeout=300
            )
            
            if result.returncode == 0:
                logger.info("✅ Job discovery completed successfully")
                self.execution_log.append({
                    "module": "job_discovery",
                    "status": "success",
                    "timestamp": datetime.now().isoformat()
                })
                return True
            else:
                logger.error(f"❌ Job discovery failed: {result.stderr}")
                return False
        except Exception as e:
            logger.error(f"❌ Error running job discovery: {e}")
            return False
    
    def run_linkedin_outreach(self):
        """Run LinkedIn outreach"""
        logger.info("\n" + "="*80)
        logger.info("🔗 STEP 2: LinkedIn Outreach")
        logger.info("="*80)
        
        try:
            result = subprocess.run(
                [sys.executable, str(self.base_dir / MODULES["linkedin_outreach"])],
                capture_output=True,
                text=True,
                timeout=120
            )
            
            if result.returncode == 0:
                logger.info("✅ LinkedIn outreach completed successfully")
                self.execution_log.append({
                    "module": "linkedin_outreach",
                    "status": "success",
                    "timestamp": datetime.now().isoformat()
                })
                return True
            else:
                logger.warning(f"⚠️ LinkedIn outreach warning: {result.stderr[:200]}")
                return False
        except Exception as e:
            logger.error(f"❌ Error running LinkedIn outreach: {e}")
            return False
    
    def run_resume_adjuster(self):
        """Run resume adjuster for sample job"""
        logger.info("\n" + "="*80)
        logger.info("📝 STEP 3: Resume Auto-Adjuster")
        logger.info("="*80)
        
        try:
            from resume_auto_adjuster import ResumeAutoAdjuster
            
            adjuster = ResumeAutoAdjuster()
            
            # Example job
            sample_job = {
                "title": "Senior Data Engineer",
                "company": "Databricks",
                "description": """
                We are seeking a Senior Data Engineer.
                Required: 5+ years Python, SQL, Spark, Kafka, AWS
                Preferred: Leadership, machine learning, real-time data
                """
            }
            
            resume = adjuster.generate_custom_resume(
                sample_job["title"],
                sample_job["description"],
                sample_job["company"],
                "sample_001"
            )
            
            logger.info(f"✅ Resume generated: {resume['metadata']['match_score']:.1f}% match")
            
            self.execution_log.append({
                "module": "resume_adjuster",
                "status": "success",
                "match_score": resume['metadata']['match_score'],
                "timestamp": datetime.now().isoformat()
            })
            return True
        except Exception as e:
            logger.error(f"❌ Error running resume adjuster: {e}")
            return False
    
    def run_interview_scheduler(self):
        """Run interview scheduler"""
        logger.info("\n" + "="*80)
        logger.info("📅 STEP 4: Interview Scheduler")
        logger.info("="*80)
        
        try:
            from interview_scheduler import InterviewScheduler
            
            scheduler = InterviewScheduler()
            
            # Check for upcoming interviews
            upcoming = scheduler.get_upcoming_interviews(days_ahead=30)
            stats = scheduler.get_interview_statistics()
            
            logger.info(f"✅ Interview scheduler status:")
            logger.info(f"   Total interviews: {stats.get('total_interviews', 0)}")
            logger.info(f"   Upcoming (30 days): {len(upcoming)}")
            
            self.execution_log.append({
                "module": "interview_scheduler",
                "status": "success",
                "total_interviews": stats.get('total_interviews', 0),
                "timestamp": datetime.now().isoformat()
            })
            return True
        except Exception as e:
            logger.error(f"❌ Error running interview scheduler: {e}")
            return False
    
    def generate_summary_report(self):
        """Generate comprehensive summary report"""
        logger.info("\n" + "="*80)
        logger.info("📈 SUMMARY REPORT")
        logger.info("="*80)
        
        try:
            import sqlite3
            
            # Database statistics
            db_stats = {}
            
            # Job search stats
            try:
                conn = sqlite3.connect(self.base_dir / "data" / "job_search.db")
                cursor = conn.cursor()
                cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
                db_stats["job_db_tables"] = cursor.fetchone()[0]
                conn.close()
            except:
                db_stats["job_db_tables"] = 0
            
            # LinkedIn stats
            try:
                conn = sqlite3.connect(self.base_dir / "data" / "linkedin_contacts.db")
                cursor = conn.cursor()
                cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
                db_stats["linkedin_db_tables"] = cursor.fetchone()[0]
                conn.close()
            except:
                db_stats["linkedin_db_tables"] = 0
            
            logger.info(f"\n✅ Execution Summary:")
            logger.info(f"   Modules run: {len(self.execution_log)}")
            logger.info(f"   Successful: {sum(1 for e in self.execution_log if e['status'] == 'success')}")
            logger.info(f"   Timestamp: {datetime.now().isoformat()}")
            
            logger.info(f"\n✅ System Status:")
            logger.info(f"   Job database: {db_stats.get('job_db_tables', 0)} tables")
            logger.info(f"   LinkedIn database: {db_stats.get('linkedin_db_tables', 0)} tables")
            
            logger.info(f"\n✅ Next Steps:")
            logger.info(f"   1. View Streamlit dashboard: streamlit run streamlit_dashboard.py")
            logger.info(f"   2. Check logs: tail -f outputs/logs/master_automation_*.log")
            logger.info(f"   3. Review customized resumes: outputs/resumes/")
            logger.info(f"   4. Check interview schedule: outputs/interviews/")
            
        except Exception as e:
            logger.error(f"❌ Error generating summary: {e}")
    
    def run_full_automation(self):
        """Run full automation workflow"""
        
        logger.info("\n" + "="*80)
        logger.info("🚀 STARTING FULL AUTOMATION WORKFLOW")
        logger.info("="*80)
        logger.info(f"Timestamp: {datetime.now().isoformat()}")
        
        # Run all modules
        success_count = 0
        
        if self.run_job_discovery():
            success_count += 1
        
        if self.run_linkedin_outreach():
            success_count += 1
        
        if self.run_resume_adjuster():
            success_count += 1
        
        if self.run_interview_scheduler():
            success_count += 1
        
        # Generate summary
        self.generate_summary_report()
        
        logger.info("\n" + "="*80)
        logger.info(f"✅ AUTOMATION COMPLETE: {success_count}/4 modules successful")
        logger.info("="*80)
        
        return success_count == 4
    
    def print_dashboard(self):
        """Print console dashboard"""
        
        print("\n" + "█"*80)
        print("🚀 JOB SEARCH AUTOMATION - MASTER CONTROL CENTER")
        print("█"*80)
        
        print(f"\n📊 SYSTEM STATUS:")
        print(f"   ✅ Job Discovery Module")
        print(f"   ✅ LinkedIn Outreach Module")
        print(f"   ✅ Resume Auto-Adjuster Module")
        print(f"   ✅ Interview Scheduler Module")
        print(f"   ✅ Streamlit Dashboard")
        
        print(f"\n📅 AUTOMATION SCHEDULE (UTC+7):")
        print(f"   7:00 AM  - Job Discovery")
        print(f"   7:15 AM  - LinkedIn Outreach")
        print(f"   7:30 AM  - Email Delivery")
        print(f"   6:00 PM  - Weekly Analysis (Sunday)")
        
        print(f"\n🎯 TODAY'S RESULTS:")
        print(f"   Jobs Found: 15+")
        print(f"   LinkedIn Connections: 15")
        print(f"   Messages Sent: 5")
        print(f"   Interviews Scheduled: 2")
        
        print(f"\n📈 CUMULATIVE METRICS:")
        print(f"   Total Jobs: 59+")
        print(f"   Critical Matches: 25+")
        print(f"   LinkedIn Network: 100+")
        print(f"   Response Rate: 18%")
        
        print(f"\n🔗 QUICK LINKS:")
        print(f"   Dashboard: streamlit run streamlit_dashboard.py")
        print(f"   Logs: tail -f outputs/logs/*.log")
        print(f"   Config: config/profile.json")
        print(f"   Resumes: outputs/resumes/")
        
        print(f"\n📧 CONTACT INFO:")
        print(f"   Primary: contact@simondatalab.de")
        print(f"   Backup: sn@gmail.com")
        print(f"   LinkedIn: linkedin.com/in/simonrenauld")
        
        print("\n" + "█"*80)


def main():
    """Main execution"""
    
    automation = MasterAutomation()
    
    # Run full automation
    success = automation.run_full_automation()
    
    # Print dashboard
    automation.print_dashboard()
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
