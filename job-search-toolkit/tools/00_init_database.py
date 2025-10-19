"""
Database Initialization - SQLite Database Setup
Author: Simon Renauld
Created: October 17, 2025

Purpose: Initialize SQLite database for job search tracking:
- Jobs table (scraped jobs)
- Applications table (application status tracking)
- Contacts table (networking CRM)
- Interviews table (interview scheduling)
- Offers table (offer comparison)

Usage:
    python tools/00_init_database.py
"""

import sqlite3
import os
from datetime import datetime
from pathlib import Path


def init_database(db_path: str = "data/applications.db"):
    """Initialize SQLite database with all required tables"""
    
    # Create data directory if not exists
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    
    # Connect to database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    print(f"📊 Initializing database: {db_path}")
    
    # 1. Jobs table (scraped jobs)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS jobs (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            company TEXT NOT NULL,
            location TEXT,
            salary_min INTEGER,
            salary_max INTEGER,
            description TEXT,
            url TEXT,
            source TEXT,
            posted_date TEXT,
            scraped_at TEXT,
            score REAL,
            skills_match REAL,
            salary_match REAL,
            location_match REAL,
            status TEXT DEFAULT 'new',
            notes TEXT
        )
    """)
    print("✅ Created table: jobs")
    
    # 2. Applications table (application tracking)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS applications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            job_id TEXT,
            company TEXT NOT NULL,
            role TEXT NOT NULL,
            applied_date TEXT,
            status TEXT DEFAULT 'applied',
            status_updated TEXT,
            resume_version TEXT,
            cover_letter_path TEXT,
            application_url TEXT,
            referral_contact TEXT,
            response_date TEXT,
            rejection_reason TEXT,
            notes TEXT,
            FOREIGN KEY (job_id) REFERENCES jobs(id)
        )
    """)
    print("✅ Created table: applications")
    
    # 3. Contacts table (networking CRM)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            company TEXT,
            role TEXT,
            email TEXT,
            phone TEXT,
            linkedin_url TEXT,
            relationship TEXT,
            met_date TEXT,
            last_contact TEXT,
            next_followup TEXT,
            notes TEXT,
            tags TEXT
        )
    """)
    print("✅ Created table: contacts")
    
    # 4. Interviews table (interview tracking)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS interviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER,
            company TEXT NOT NULL,
            role TEXT NOT NULL,
            interview_date TEXT,
            interview_time TEXT,
            interview_type TEXT,
            interviewer_name TEXT,
            interviewer_role TEXT,
            duration_minutes INTEGER,
            location TEXT,
            video_link TEXT,
            prep_completed BOOLEAN DEFAULT 0,
            notes TEXT,
            outcome TEXT,
            feedback TEXT,
            FOREIGN KEY (application_id) REFERENCES applications(id)
        )
    """)
    print("✅ Created table: interviews")
    
    # 5. Offers table (offer comparison)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS offers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER,
            company TEXT NOT NULL,
            role TEXT NOT NULL,
            offer_date TEXT,
            response_deadline TEXT,
            base_salary INTEGER,
            bonus INTEGER,
            equity_value INTEGER,
            equity_details TEXT,
            benefits TEXT,
            vacation_days INTEGER,
            remote_policy TEXT,
            start_date TEXT,
            total_compensation INTEGER,
            status TEXT DEFAULT 'pending',
            decision_date TEXT,
            notes TEXT,
            FOREIGN KEY (application_id) REFERENCES applications(id)
        )
    """)
    print("✅ Created table: offers")
    
    # 6. Follow-ups table (automated reminders)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS followups (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER,
            followup_date TEXT,
            followup_type TEXT,
            message_sent BOOLEAN DEFAULT 0,
            response_received BOOLEAN DEFAULT 0,
            notes TEXT,
            FOREIGN KEY (application_id) REFERENCES applications(id)
        )
    """)
    print("✅ Created table: followups")
    
    # 7. Metrics table (analytics tracking)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            applications_sent INTEGER DEFAULT 0,
            responses_received INTEGER DEFAULT 0,
            interviews_scheduled INTEGER DEFAULT 0,
            offers_received INTEGER DEFAULT 0,
            week_number INTEGER,
            month TEXT
        )
    """)
    print("✅ Created table: metrics")
    
    # Commit changes
    conn.commit()
    
    # Insert initial metrics row
    today = datetime.now().strftime('%Y-%m-%d')
    cursor.execute("""
        INSERT OR IGNORE INTO metrics (date, week_number, month)
        VALUES (?, strftime('%W', 'now'), strftime('%Y-%m', 'now'))
    """, (today,))
    conn.commit()
    
    # Close connection
    conn.close()
    
    print(f"\n✅ Database initialized successfully!")
    print(f"📍 Location: {os.path.abspath(db_path)}")
    print(f"\n📋 Tables created:")
    print("   - jobs (scraped job listings)")
    print("   - applications (application tracking)")
    print("   - contacts (networking CRM)")
    print("   - interviews (interview scheduling)")
    print("   - offers (offer comparison)")
    print("   - followups (automated reminders)")
    print("   - metrics (analytics)")
    print(f"\n💡 Use other tools to populate data\n")


def verify_database(db_path: str = "data/applications.db"):
    """Verify database structure"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get all tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = cursor.fetchall()
    
    print(f"\n📊 Database verification: {db_path}")
    print(f"Tables found: {len(tables)}")
    
    for table in tables:
        table_name = table[0]
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        print(f"  - {table_name}: {count} rows")
    
    conn.close()


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Initialize Job Search Database")
    parser.add_argument("--db-path", default="data/applications.db", help="Database file path")
    parser.add_argument("--verify", action="store_true", help="Verify database structure")
    parser.add_argument("--reset", action="store_true", help="Reset database (delete and recreate)")
    
    args = parser.parse_args()
    
    if args.reset:
        confirm = input("⚠️  This will DELETE all data. Are you sure? (yes/no): ")
        if confirm.lower() == 'yes':
            if os.path.exists(args.db_path):
                os.remove(args.db_path)
                print(f"🗑️  Deleted: {args.db_path}")
            init_database(args.db_path)
        else:
            print("❌ Reset cancelled")
    elif args.verify:
        verify_database(args.db_path)
    else:
        init_database(args.db_path)
        verify_database(args.db_path)
