"""
Application Tracker - Job Application Management System
Author: Simon Renauld
Created: October 15, 2025

Purpose: Track job applications in SQLite database
- Add new applications
- Update application status
- Generate weekly reports
- Track response rates
- Manage follow-ups

Usage:
    # Add application
    python tools/application_tracker.py --add \\
        --company "Acme Corp" \\
        --role "Lead Data Engineer" \\
        --status "Applied"
    
    # Update status
    python tools/application_tracker.py --update APP001 --status "Interview"
    
    # Generate report
    python tools/application_tracker.py --report weekly
"""

import argparse
import json
import os
import sqlite3
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import pandas as pd


class ApplicationTracker:
    """Job application tracking system"""
    
    def __init__(self, db_path: str = "data/applications.db"):
        """Initialize tracker with SQLite database"""
        self.db_path = db_path
        self._init_database()
    
    def _init_database(self):
        """Create database tables if not exists"""
        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS applications (
                id TEXT PRIMARY KEY,
                company TEXT NOT NULL,
                role TEXT NOT NULL,
                location TEXT,
                salary_range TEXT,
                source TEXT,
                url TEXT,
                status TEXT DEFAULT 'Applied',
                priority TEXT DEFAULT 'Medium',
                applied_date TEXT,
                last_updated TEXT,
                follow_up_date TEXT,
                notes TEXT,
                resume_version TEXT,
                cover_letter_path TEXT
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS status_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                application_id TEXT,
                old_status TEXT,
                new_status TEXT,
                changed_at TEXT,
                FOREIGN KEY (application_id) REFERENCES applications(id)
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                application_id TEXT,
                name TEXT,
                role TEXT,
                email TEXT,
                linkedin TEXT,
                notes TEXT,
                FOREIGN KEY (application_id) REFERENCES applications(id)
            )
        """)
        
        conn.commit()
        conn.close()
    
    def _generate_app_id(self, company: str, role: str) -> str:
        """Generate unique application ID"""
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        company_slug = company[:3].upper()
        return f"APP{company_slug}{timestamp}"
    
    def add_application(
        self,
        company: str,
        role: str,
        location: str = "",
        salary_range: str = "",
        source: str = "",
        url: str = "",
        priority: str = "Medium",
        notes: str = ""
    ) -> str:
        """Add new job application"""
        app_id = self._generate_app_id(company, role)
        applied_date = datetime.now().isoformat()
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO applications 
            (id, company, role, location, salary_range, source, url, status, priority, applied_date, last_updated, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (app_id, company, role, location, salary_range, source, url, "Applied", priority, applied_date, applied_date, notes))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Application added: {app_id} - {company} - {role}")
        return app_id
    
    def update_status(self, app_id: str, new_status: str, notes: str = ""):
        """Update application status"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Get current status
        cursor.execute("SELECT status FROM applications WHERE id = ?", (app_id,))
        result = cursor.fetchone()
        
        if not result:
            print(f"❌ Application {app_id} not found")
            conn.close()
            return
        
        old_status = result[0]
        updated_at = datetime.now().isoformat()
        
        # Update application
        cursor.execute("""
            UPDATE applications 
            SET status = ?, last_updated = ?, notes = COALESCE(notes || ?, ?)
            WHERE id = ?
        """, (new_status, updated_at, f"\n{notes}", notes, app_id))
        
        # Log status change
        cursor.execute("""
            INSERT INTO status_history (application_id, old_status, new_status, changed_at)
            VALUES (?, ?, ?, ?)
        """, (app_id, old_status, new_status, updated_at))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Status updated: {app_id} - {old_status} → {new_status}")
    
    def get_applications(
        self,
        status: Optional[str] = None,
        priority: Optional[str] = None,
        limit: int = 100
    ) -> List[Dict]:
        """Retrieve applications with filters"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        query = "SELECT * FROM applications WHERE 1=1"
        params = []
        
        if status:
            query += " AND status = ?"
            params.append(status)
        
        if priority:
            query += " AND priority = ?"
            params.append(priority)
        
        query += " ORDER BY applied_date DESC LIMIT ?"
        params.append(limit)
        
        cursor.execute(query, params)
        columns = [desc[0] for desc in cursor.description]
        rows = cursor.fetchall()
        
        conn.close()
        
        return [dict(zip(columns, row)) for row in rows]
    
    def generate_weekly_report(self, output_dir: str = "outputs/reports/"):
        """Generate weekly application report"""
        # Get applications from last 7 days
        week_ago = (datetime.now() - timedelta(days=7)).isoformat()
        
        conn = sqlite3.connect(self.db_path)
        
        # Applications by status
        df_status = pd.read_sql_query("""
            SELECT status, COUNT(*) as count
            FROM applications
            WHERE applied_date >= ?
            GROUP BY status
        """, conn, params=(week_ago,))
        
        # Applications by priority
        df_priority = pd.read_sql_query("""
            SELECT priority, COUNT(*) as count
            FROM applications
            WHERE applied_date >= ?
            GROUP BY priority
        """, conn, params=(week_ago,))
        
        # Response rate
        df_response = pd.read_sql_query("""
            SELECT 
                COUNT(*) as total_applications,
                SUM(CASE WHEN status NOT IN ('Applied', 'Rejected') THEN 1 ELSE 0 END) as responses,
                ROUND(100.0 * SUM(CASE WHEN status NOT IN ('Applied', 'Rejected') THEN 1 ELSE 0 END) / COUNT(*), 1) as response_rate
            FROM applications
            WHERE applied_date >= ?
        """, conn, params=(week_ago,))
        
        conn.close()
        
        # Generate report
        os.makedirs(output_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_path = os.path.join(output_dir, f"weekly_report_{timestamp}.txt")
        
        with open(report_path, 'w') as f:
            f.write("=" * 60 + "\n")
            f.write("JOB APPLICATION WEEKLY REPORT\n")
            f.write(f"Period: Last 7 days ({week_ago[:10]} to {datetime.now().isoformat()[:10]})\n")
            f.write("=" * 60 + "\n\n")
            
            f.write("Applications by Status:\n")
            f.write(df_status.to_string(index=False) + "\n\n")
            
            f.write("Applications by Priority:\n")
            f.write(df_priority.to_string(index=False) + "\n\n")
            
            f.write("Response Metrics:\n")
            f.write(df_response.to_string(index=False) + "\n\n")
        
        print(f"📊 Weekly report generated: {report_path}")
        print(df_status.to_string(index=False))
        print(f"\nResponse Rate: {df_response['response_rate'].iloc[0]}%")


def main():
    parser = argparse.ArgumentParser(description="Job Application Tracker")
    parser.add_argument("--add", action="store_true", help="Add new application")
    parser.add_argument("--update", help="Update application by ID")
    parser.add_argument("--report", choices=["weekly", "monthly"], help="Generate report")
    parser.add_argument("--company", help="Company name")
    parser.add_argument("--role", help="Job role")
    parser.add_argument("--location", default="", help="Job location")
    parser.add_argument("--status", help="Application status")
    parser.add_argument("--priority", default="Medium", help="Priority (High/Medium/Low)")
    parser.add_argument("--notes", default="", help="Notes")
    
    args = parser.parse_args()
    
    tracker = ApplicationTracker()
    
    if args.add:
        if not args.company or not args.role:
            print("❌ --company and --role required")
            return
        
        tracker.add_application(
            company=args.company,
            role=args.role,
            location=args.location,
            priority=args.priority,
            notes=args.notes
        )
    
    elif args.update:
        if not args.status:
            print("❌ --status required for update")
            return
        
        tracker.update_status(args.update, args.status, args.notes)
    
    elif args.report == "weekly":
        tracker.generate_weekly_report()
    
    else:
        # List all applications
        apps = tracker.get_applications(limit=20)
        df = pd.DataFrame(apps)
        print(df[['id', 'company', 'role', 'status', 'applied_date']].to_string(index=False))


if __name__ == "__main__":
    main()
