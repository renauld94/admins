#!/usr/bin/env python3
"""
Job Search Analytics Dashboard - Metrics & Insights
===================================================

Tracks and visualizes:
- Applications sent (by role, company, week)
- Response rate & interview conversion
- Salary pipeline & offer analysis
- Network reach & interaction metrics
- Time-to-offer predictions

Author: Simon Renauld
Created: November 9, 2025
"""

import sqlite3
import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass

# ===== CONFIGURATION =====
BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / "data"
OUTPUTS_DIR = BASE_DIR / "outputs"
LOGS_DIR = OUTPUTS_DIR / "logs"

# Create directories
for d in [DATA_DIR, OUTPUTS_DIR, LOGS_DIR]:
    d.mkdir(parents=True, exist_ok=True)

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOGS_DIR / f"dashboard_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


# ===== DATA MODELS =====

@dataclass
class DailyMetrics:
    """Daily metrics snapshot"""
    date: str
    applications_sent: int
    connections_made: int
    messages_sent: int
    interviews_scheduled: int
    offers_received: int
    total_reach: int


@dataclass
class WeeklyMetrics:
    """Weekly aggregated metrics"""
    week_start: str
    applications_sent: int
    response_count: int
    interview_count: int
    offer_count: int
    average_response_time_days: float
    response_rate: float
    interview_conversion_rate: float
    offer_conversion_rate: float


class JobSearchDashboard:
    """
    Analytics dashboard for job search metrics
    """
    
    def __init__(self):
        self.db_path = DATA_DIR / "job_search_metrics.db"
        self.init_db()
        logger.info("📊 Analytics Dashboard initialized")
    
    def init_db(self):
        """Initialize metrics database"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        # Daily metrics table
        c.execute('''
            CREATE TABLE IF NOT EXISTS daily_metrics (
                id TEXT PRIMARY KEY,
                date TEXT,
                applications_sent INTEGER,
                connections_made INTEGER,
                messages_sent INTEGER,
                interviews_scheduled INTEGER,
                offers_received INTEGER,
                total_reach INTEGER,
                created_at TEXT
            )
        ''')
        
        # Application pipeline
        c.execute('''
            CREATE TABLE IF NOT EXISTS application_pipeline (
                id TEXT PRIMARY KEY,
                job_id TEXT,
                company TEXT,
                role TEXT,
                status TEXT,
                applied_date TEXT,
                response_date TEXT,
                response_type TEXT,
                interview_date TEXT,
                offer_date TEXT,
                salary_range TEXT,
                notes TEXT
            )
        ''')
        
        # Network metrics
        c.execute('''
            CREATE TABLE IF NOT EXISTS network_metrics (
                id TEXT PRIMARY KEY,
                date TEXT,
                total_connections INTEGER,
                recruiters INTEGER,
                hiring_managers INTEGER,
                peers INTEGER,
                referrals INTEGER,
                active_conversations INTEGER
            )
        ''')
        
        # Salary data
        c.execute('''
            CREATE TABLE IF NOT EXISTS salary_data (
                id TEXT PRIMARY KEY,
                company TEXT,
                role TEXT,
                min_salary INTEGER,
                max_salary INTEGER,
                avg_salary INTEGER,
                currency TEXT,
                source TEXT,
                recorded_date TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info(f"✅ Metrics database initialized: {self.db_path}")
    
    # ===== METRICS RECORDING =====
    
    def record_daily_metrics(
        self,
        applications_sent: int = 0,
        connections_made: int = 0,
        messages_sent: int = 0,
        interviews_scheduled: int = 0,
        offers_received: int = 0,
        total_reach: int = 0
    ) -> bool:
        """Record daily metrics"""
        try:
            import hashlib
            
            metric_id = hashlib.md5(
                f"{datetime.now().strftime('%Y-%m-%d')}_metrics".encode()
            ).hexdigest()[:8]
            
            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            
            c.execute('''
                INSERT INTO daily_metrics VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                metric_id,
                datetime.now().strftime('%Y-%m-%d'),
                applications_sent,
                connections_made,
                messages_sent,
                interviews_scheduled,
                offers_received,
                total_reach,
                datetime.now().isoformat()
            ))
            
            conn.commit()
            conn.close()
            
            logger.info(f"✅ Daily metrics recorded")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to record metrics: {e}")
            return False
    
    def record_application(
        self,
        job_id: str,
        company: str,
        role: str,
        applied_date: str = None
    ) -> bool:
        """Record application"""
        try:
            import hashlib
            
            app_id = hashlib.md5(
                f"{job_id}_{company}_{role}".encode()
            ).hexdigest()[:8]
            
            if applied_date is None:
                applied_date = datetime.now().isoformat()
            
            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            
            c.execute('''
                INSERT INTO application_pipeline VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                app_id,
                job_id,
                company,
                role,
                "applied",
                applied_date,
                None, None, None, None, None, None
            ))
            
            conn.commit()
            conn.close()
            
            logger.info(f"✅ Application recorded: {role} @ {company}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to record application: {e}")
            return False
    
    def update_application_status(
        self,
        job_id: str,
        status: str,
        response_type: str = None,
        interview_date: str = None,
        offer_salary: str = None
    ) -> bool:
        """Update application status"""
        try:
            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            
            if status == "responded":
                c.execute('''
                    UPDATE application_pipeline 
                    SET status = ?, response_date = ?, response_type = ?
                    WHERE job_id = ?
                ''', (status, datetime.now().isoformat(), response_type, job_id))
            
            elif status == "interview":
                c.execute('''
                    UPDATE application_pipeline 
                    SET status = ?, interview_date = ?
                    WHERE job_id = ?
                ''', (status, interview_date or datetime.now().isoformat(), job_id))
            
            elif status == "offer":
                c.execute('''
                    UPDATE application_pipeline 
                    SET status = ?, offer_date = ?, salary_range = ?
                    WHERE job_id = ?
                ''', (status, datetime.now().isoformat(), offer_salary, job_id))
            
            else:
                c.execute('''
                    UPDATE application_pipeline 
                    SET status = ?
                    WHERE job_id = ?
                ''', (status, job_id))
            
            conn.commit()
            conn.close()
            
            logger.info(f"✅ Application status updated: {job_id} -> {status}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to update application: {e}")
            return False
    
    # ===== ANALYTICS & CALCULATIONS =====
    
    def get_daily_metrics(self, date: str = None) -> Optional[DailyMetrics]:
        """Get daily metrics for specific date"""
        if date is None:
            date = datetime.now().strftime('%Y-%m-%d')
        
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            SELECT date, applications_sent, connections_made, messages_sent, 
                   interviews_scheduled, offers_received, total_reach
            FROM daily_metrics 
            WHERE date = ?
        ''', (date,))
        
        row = c.fetchone()
        conn.close()
        
        if not row:
            return None
        
        return DailyMetrics(
            date=row[0],
            applications_sent=row[1],
            connections_made=row[2],
            messages_sent=row[3],
            interviews_scheduled=row[4],
            offers_received=row[5],
            total_reach=row[6]
        )
    
    def get_weekly_metrics(self, weeks_back: int = 0) -> WeeklyMetrics:
        """Calculate weekly aggregated metrics"""
        
        # Calculate week start and end
        now = datetime.now()
        week_start = now - timedelta(days=now.weekday() + 7 * weeks_back)
        week_start = week_start.replace(hour=0, minute=0, second=0)
        week_end = week_start + timedelta(days=7)
        
        week_start_str = week_start.strftime('%Y-%m-%d')
        week_end_str = week_end.strftime('%Y-%m-%d')
        
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        # Daily aggregates
        c.execute('''
            SELECT SUM(applications_sent), SUM(connections_made),
                   SUM(interviews_scheduled), SUM(offers_received)
            FROM daily_metrics
            WHERE date >= ? AND date < ?
        ''', (week_start_str, week_end_str))
        
        daily_result = c.fetchone()
        apps_sent = daily_result[0] or 0
        connections = daily_result[1] or 0
        interviews = daily_result[2] or 0
        offers = daily_result[3] or 0
        
        # Application pipeline metrics
        c.execute('''
            SELECT COUNT(*),
                   COUNT(CASE WHEN status IN ('responded', 'interview', 'offer') THEN 1 END),
                   COUNT(CASE WHEN status IN ('interview', 'offer') THEN 1 END),
                   COUNT(CASE WHEN status = 'offer' THEN 1 END),
                   AVG(CASE WHEN response_date IS NOT NULL 
                       THEN (julianday(response_date) - julianday(applied_date)) 
                       END)
            FROM application_pipeline
            WHERE applied_date >= ? AND applied_date < ?
        ''', (week_start_str, week_end_str))
        
        pipeline_result = c.fetchone()
        total_apps = pipeline_result[0] or 0
        responses = pipeline_result[1] or 0
        interviews_tracked = pipeline_result[2] or 0
        offers_tracked = pipeline_result[3] or 0
        avg_response_time = pipeline_result[4] or 0
        
        conn.close()
        
        # Calculate rates
        response_rate = (responses / total_apps * 100) if total_apps > 0 else 0
        interview_conversion = (interviews_tracked / responses * 100) if responses > 0 else 0
        offer_conversion = (offers_tracked / interviews_tracked * 100) if interviews_tracked > 0 else 0
        
        return WeeklyMetrics(
            week_start=week_start_str,
            applications_sent=total_apps,
            response_count=responses,
            interview_count=interviews_tracked,
            offer_count=offers_tracked,
            average_response_time_days=round(avg_response_time, 1),
            response_rate=round(response_rate, 1),
            interview_conversion_rate=round(interview_conversion, 1),
            offer_conversion_rate=round(offer_conversion, 1)
        )
    
    def get_company_stats(self, company: str) -> Dict:
        """Get statistics for specific company"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            SELECT 
                COUNT(*) as total_applications,
                SUM(CASE WHEN status IN ('responded', 'interview', 'offer') THEN 1 ELSE 0 END) as responses,
                SUM(CASE WHEN status IN ('interview', 'offer') THEN 1 ELSE 0 END) as interviews,
                SUM(CASE WHEN status = 'offer' THEN 1 ELSE 0 END) as offers,
                GROUP_CONCAT(DISTINCT role) as roles
            FROM application_pipeline
            WHERE company = ?
        ''', (company,))
        
        result = c.fetchone()
        conn.close()
        
        total = result[0] or 0
        responses = result[1] or 0
        interviews = result[2] or 0
        offers = result[3] or 0
        roles = (result[4] or "").split(",")
        
        return {
            "company": company,
            "total_applications": total,
            "responses": responses,
            "interviews": interviews,
            "offers": offers,
            "response_rate": round(responses / total * 100, 1) if total > 0 else 0,
            "roles": roles
        }
    
    # ===== REPORTING =====
    
    def print_daily_report(self):
        """Print daily metrics report"""
        metrics = self.get_daily_metrics()
        
        print(f"\n{'='*70}")
        print(f"📊 DAILY METRICS REPORT - {datetime.now().strftime('%Y-%m-%d')}")
        print(f"{'='*70}\n")
        
        if metrics:
            print(f"📈 TODAY'S ACTIVITY")
            print(f"   Applications sent:    {metrics.applications_sent}")
            print(f"   LinkedIn connections: {metrics.connections_made}")
            print(f"   Messages sent:        {metrics.messages_sent}")
            print(f"   Interviews scheduled: {metrics.interviews_scheduled}")
            print(f"   Offers received:      {metrics.offers_received}")
            print(f"   Total reach:          {metrics.total_reach}")
        else:
            print("   No metrics recorded for today")
        
        print(f"\n{'='*70}\n")
    
    def print_weekly_report(self, weeks_back: int = 0):
        """Print weekly metrics report"""
        metrics = self.get_weekly_metrics(weeks_back)
        
        print(f"\n{'='*70}")
        print(f"📊 WEEKLY METRICS REPORT - Week of {metrics.week_start}")
        print(f"{'='*70}\n")
        
        print(f"📋 APPLICATIONS")
        print(f"   Applications sent: {metrics.applications_sent}")
        print(f"   Responses:         {metrics.response_count} ({metrics.response_rate}%)")
        print(f"   Interviews:        {metrics.interview_count}")
        print(f"   Offers:            {metrics.offer_count}")
        
        print(f"\n⏱️  TIMING")
        print(f"   Avg response time: {metrics.average_response_time_days} days")
        print(f"   Interview conversion: {metrics.interview_conversion_rate}%")
        print(f"   Offer conversion: {metrics.offer_conversion_rate}%")
        
        # Projected offers
        if metrics.applications_sent > 0:
            projected_offer_rate = (metrics.offer_count / metrics.applications_sent) * 100
            print(f"\n🎯 PROJECTIONS")
            print(f"   Offer rate: {projected_offer_rate:.1f}%")
            print(f"   Projected offers (100 apps): {round(100 * projected_offer_rate / 100)}")
        
        print(f"\n{'='*70}\n")
    
    def print_pipeline_report(self):
        """Print application pipeline report"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            SELECT status, COUNT(*), GROUP_CONCAT(company)
            FROM application_pipeline
            GROUP BY status
            ORDER BY COUNT(*) DESC
        ''')
        
        rows = c.fetchall()
        conn.close()
        
        print(f"\n{'='*70}")
        print(f"📋 APPLICATION PIPELINE")
        print(f"{'='*70}\n")
        
        for status, count, companies in rows:
            print(f"   {status.upper():12} : {count} applications")
        
        print(f"\n{'='*70}\n")
    
    def print_full_dashboard(self):
        """Print complete dashboard"""
        print(f"\n{'='*70}")
        print(f"🎯 JOB SEARCH ANALYTICS DASHBOARD")
        print(f"{'='*70}")
        
        self.print_daily_report()
        self.print_weekly_report()
        self.print_pipeline_report()


# ===== CLI =====

def main():
    """Main entry point"""
    import sys
    
    dashboard = JobSearchDashboard()
    
    if len(sys.argv) < 2:
        print("""
Job Search Analytics Dashboard
=============================

Usage:
  python job_search_dashboard.py daily          # Print daily metrics
  python job_search_dashboard.py weekly         # Print weekly metrics
  python job_search_dashboard.py pipeline       # Print pipeline status
  python job_search_dashboard.py full           # Print full dashboard
  python job_search_dashboard.py record --apps 5 --connections 3  # Record metrics

Examples:
  python job_search_dashboard.py daily
  python job_search_dashboard.py weekly
  python job_search_dashboard.py record --apps 10 --connections 5 --messages 3
""")
        sys.exit(0)
    
    command = sys.argv[1]
    
    if command == "daily":
        dashboard.print_daily_report()
    
    elif command == "weekly":
        dashboard.print_weekly_report()
    
    elif command == "pipeline":
        dashboard.print_pipeline_report()
    
    elif command == "full":
        dashboard.print_full_dashboard()
    
    elif command == "record":
        apps = connections = messages = interviews = offers = 0
        
        for i, arg in enumerate(sys.argv):
            if arg == "--apps" and i + 1 < len(sys.argv):
                apps = int(sys.argv[i + 1])
            elif arg == "--connections" and i + 1 < len(sys.argv):
                connections = int(sys.argv[i + 1])
            elif arg == "--messages" and i + 1 < len(sys.argv):
                messages = int(sys.argv[i + 1])
            elif arg == "--interviews" and i + 1 < len(sys.argv):
                interviews = int(sys.argv[i + 1])
            elif arg == "--offers" and i + 1 < len(sys.argv):
                offers = int(sys.argv[i + 1])
        
        dashboard.record_daily_metrics(
            applications_sent=apps,
            connections_made=connections,
            messages_sent=messages,
            interviews_scheduled=interviews,
            offers_received=offers
        )
    
    else:
        print(f"❌ Unknown command: {command}")


if __name__ == "__main__":
    main()
