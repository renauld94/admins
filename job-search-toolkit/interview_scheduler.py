#!/usr/bin/env python3
"""
Interview Scheduler - Automated calendar management
===================================================

Manages:
- Interview scheduling and calendar sync
- Follow-up reminders and tracking
- Interview preparation materials
- Calendar availability
- Email notifications

Author: Simon Renauld
Date: November 10, 2025
"""

import json
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List
import logging

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class InterviewScheduler:
    """Automated interview scheduling and tracking"""
    
    def __init__(self):
        self.base_dir = Path(__file__).parent
        self.db_path = self.base_dir / "data" / "interview_scheduler.db"
        self.output_dir = self.base_dir / "outputs" / "interviews"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        self._init_database()
        logger.info("✅ Interview Scheduler initialized")
    
    def _init_database(self):
        """Initialize interview database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create tables
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS interviews (
                id TEXT PRIMARY KEY,
                job_title TEXT,
                company TEXT,
                interviewer_name TEXT,
                interviewer_email TEXT,
                interview_date TEXT,
                interview_time TEXT,
                duration_minutes INTEGER,
                interview_type TEXT,
                round_number INTEGER,
                status TEXT,
                notes TEXT,
                preparation_completed BOOLEAN,
                follow_up_sent BOOLEAN,
                outcome TEXT,
                created_at TEXT,
                updated_at TEXT
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS preparation_items (
                id TEXT PRIMARY KEY,
                interview_id TEXT,
                category TEXT,
                task TEXT,
                completed BOOLEAN,
                priority TEXT,
                created_at TEXT,
                FOREIGN KEY(interview_id) REFERENCES interviews(id)
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS calendar_availability (
                id TEXT PRIMARY KEY,
                date_str TEXT UNIQUE,
                time_slots TEXT,
                timezone TEXT,
                created_at TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def schedule_interview(self, job_title: str, company: str, 
                          interviewer_name: str, interviewer_email: str,
                          interview_date: str, interview_time: str,
                          duration_minutes: int = 60,
                          interview_type: str = "Phone Screen",
                          round_number: int = 1) -> Dict:
        """Schedule a new interview"""
        
        interview_id = f"{company}_{round_number}_{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        interview = {
            "id": interview_id,
            "job_title": job_title,
            "company": company,
            "interviewer_name": interviewer_name,
            "interviewer_email": interviewer_email,
            "interview_date": interview_date,
            "interview_time": interview_time,
            "duration_minutes": duration_minutes,
            "interview_type": interview_type,
            "round_number": round_number,
            "status": "Scheduled",
            "preparation_completed": False,
            "follow_up_sent": False,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }
        
        # Save to database
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO interviews 
            (id, job_title, company, interviewer_name, interviewer_email, 
             interview_date, interview_time, duration_minutes, interview_type, 
             round_number, status, preparation_completed, follow_up_sent, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            interview_id, job_title, company, interviewer_name, interviewer_email,
            interview_date, interview_time, duration_minutes, interview_type,
            round_number, "Scheduled", False, False,
            interview["created_at"], interview["updated_at"]
        ))
        
        conn.commit()
        conn.close()
        
        # Generate preparation materials
        self._generate_preparation_materials(interview_id, company, job_title)
        
        logger.info(f"✅ Interview scheduled: {job_title} @ {company} ({interview_date} {interview_time})")
        
        return interview
    
    def _generate_preparation_materials(self, interview_id: str, company: str, job_title: str):
        """Generate preparation checklist and materials"""
        
        prep_items = [
            {
                "category": "Company Research",
                "tasks": [
                    "Review company website and recent news",
                    "Research company culture and values",
                    "Study recent product launches",
                    "Prepare company-specific questions"
                ],
                "priority": "High"
            },
            {
                "category": "Technical Preparation",
                "tasks": [
                    "Review data structures and algorithms",
                    "Practice SQL queries",
                    "Prepare technical project walkthrough",
                    "Review latest frameworks/tools in field"
                ],
                "priority": "High"
            },
            {
                "category": "Behavioral Preparation",
                "tasks": [
                    "Prepare STAR method stories (5+)",
                    "Practice leadership examples",
                    "Prepare crisis management story",
                    "Prepare team conflict resolution example"
                ],
                "priority": "High"
            },
            {
                "category": "Role-Specific Preparation",
                "tasks": [
                    "Study job description thoroughly",
                    "Prepare questions about team structure",
                    "Research reporting line",
                    "Understand key projects and priorities"
                ],
                "priority": "Medium"
            },
            {
                "category": "Logistics",
                "tasks": [
                    "Test video/audio for video interview",
                    "Prepare interview location (quiet space)",
                    "Have phone charged and internet ready",
                    "Prepare notepad and pen"
                ],
                "priority": "Medium"
            }
        ]
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for i, item in enumerate(prep_items):
            for j, task in enumerate(item["tasks"]):
                prep_id = f"{interview_id}_{i}_{j}"
                try:
                    cursor.execute('''
                        INSERT INTO preparation_items
                        (id, interview_id, category, task, completed, priority, created_at)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        prep_id, interview_id, item["category"], task,
                        False, item["priority"], datetime.now().isoformat()
                    ))
                except sqlite3.IntegrityError:
                    pass  # Skip if already exists
        
        conn.commit()
        conn.close()
        
        logger.info(f"   📋 Preparation materials generated ({len(prep_items)} categories)")
    
    def mark_preparation_complete(self, interview_id: str):
        """Mark all preparation items as complete"""
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE preparation_items
            SET completed = 1
            WHERE interview_id = ?
        ''', (interview_id,))
        
        cursor.execute('''
            UPDATE interviews
            SET preparation_completed = 1, updated_at = ?
            WHERE id = ?
        ''', (datetime.now().isoformat(), interview_id))
        
        conn.commit()
        conn.close()
        
        logger.info(f"✅ Preparation marked complete for {interview_id}")
    
    def update_interview_outcome(self, interview_id: str, outcome: str, notes: str = ""):
        """Update interview outcome (positive, negative, pending)"""
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        status = "Completed" if outcome else "Pending"
        
        cursor.execute('''
            UPDATE interviews
            SET status = ?, outcome = ?, notes = ?, updated_at = ?
            WHERE id = ?
        ''', (status, outcome, notes, datetime.now().isoformat(), interview_id))
        
        conn.commit()
        conn.close()
        
        logger.info(f"✅ Interview outcome updated: {interview_id} - {outcome}")
    
    def send_follow_up_email(self, interview_id: str, email_addresses: List[str]) -> bool:
        """Generate follow-up email after interview"""
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT job_title, company, interviewer_name, interview_date, outcome
            FROM interviews
            WHERE id = ?
        ''', (interview_id,))
        
        result = cursor.fetchone()
        if not result:
            logger.error(f"❌ Interview not found: {interview_id}")
            return False
        
        job_title, company, interviewer_name, interview_date, outcome = result
        
        # Generate follow-up email
        follow_up_template = f"""
Subject: Thank you for the {job_title} interview

Dear {interviewer_name},

Thank you for taking the time to meet with me on {interview_date}. I thoroughly enjoyed our conversation about the {job_title} role at {company}.

Our discussion reinforced my strong interest in this opportunity. I'm particularly impressed by:
- [Specific point from conversation]
- [Team/company insight from interview]
- [Alignment with role]

I believe my experience in [relevant skillset] would be valuable to your team, and I'm excited about the possibility of contributing to [specific project/goal].

Please let me know if you need any additional information from me. I look forward to our next steps.

Best regards,
Simon Renauld
{', '.join(email_addresses)}
"""
        
        # Save follow-up email
        email_path = self.output_dir / f"followup_{interview_id}.txt"
        email_path.write_text(follow_up_template)
        
        # Mark as sent
        cursor.execute('''
            UPDATE interviews
            SET follow_up_sent = 1, updated_at = ?
            WHERE id = ?
        ''', (datetime.now().isoformat(), interview_id))
        
        conn.commit()
        conn.close()
        
        logger.info(f"✅ Follow-up email generated: {email_path}")
        return True
    
    def get_upcoming_interviews(self, days_ahead: int = 7) -> List[Dict]:
        """Get upcoming interviews in next N days"""
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        today = datetime.now().date()
        future_date = today + timedelta(days=days_ahead)
        
        cursor.execute('''
            SELECT id, job_title, company, interview_date, interview_time, 
                   interview_type, status, preparation_completed
            FROM interviews
            WHERE interview_date BETWEEN ? AND ?
            ORDER BY interview_date, interview_time
        ''', (str(today), str(future_date)))
        
        interviews = []
        for row in cursor.fetchall():
            interviews.append({
                "id": row[0],
                "job_title": row[1],
                "company": row[2],
                "interview_date": row[3],
                "interview_time": row[4],
                "interview_type": row[5],
                "status": row[6],
                "preparation_completed": bool(row[7])
            })
        
        conn.close()
        return interviews
    
    def generate_calendar_event(self, interview: Dict) -> str:
        """Generate ICS calendar event for interview"""
        
        # Parse date and time
        date_obj = datetime.strptime(interview["interview_date"], "%Y-%m-%d")
        time_obj = datetime.strptime(interview["interview_time"], "%H:%M")
        
        start_dt = datetime.combine(date_obj.date(), time_obj.time())
        end_dt = start_dt + timedelta(minutes=interview.get("duration_minutes", 60))
        
        ics_content = f"""BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Interview Scheduler//Simon Renauld//EN
BEGIN:VEVENT
UID:{interview['id']}@simonrenauld.com
DTSTAMP:{datetime.now().strftime('%Y%m%dT%H%M%SZ')}
DTSTART:{start_dt.strftime('%Y%m%dT%H%M%S')}
DTEND:{end_dt.strftime('%Y%m%dT%H%M%S')}
SUMMARY:{interview['job_title']} Interview @ {interview['company']}
DESCRIPTION:{interview.get('interview_type', 'Interview')} - Round {interview.get('round_number', 1)}
LOCATION:Virtual/Phone
END:VEVENT
END:VCALENDAR
"""
        
        return ics_content
    
    def get_interview_statistics(self) -> Dict:
        """Get interview statistics"""
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Total interviews
        cursor.execute("SELECT COUNT(*) FROM interviews")
        total = cursor.fetchone()[0]
        
        # By status
        cursor.execute('''
            SELECT status, COUNT(*) FROM interviews
            GROUP BY status
        ''')
        by_status = {row[0]: row[1] for row in cursor.fetchall()}
        
        # By outcome
        cursor.execute('''
            SELECT outcome, COUNT(*) FROM interviews
            WHERE outcome IS NOT NULL
            GROUP BY outcome
        ''')
        by_outcome = {row[0]: row[1] for row in cursor.fetchall()}
        
        # Preparation completed
        cursor.execute('''
            SELECT COUNT(*) FROM interviews
            WHERE preparation_completed = 1
        ''')
        prep_completed = cursor.fetchone()[0]
        
        conn.close()
        
        return {
            "total_interviews": total,
            "by_status": by_status,
            "by_outcome": by_outcome,
            "preparation_completed": prep_completed,
            "preparation_rate": f"{(prep_completed/total*100) if total > 0 else 0:.1f}%"
        }
    
    def print_interview_summary(self):
        """Print interview schedule summary"""
        
        upcoming = self.get_upcoming_interviews()
        stats = self.get_interview_statistics()
        
        print("\n" + "="*80)
        print("📅 INTERVIEW SCHEDULER SUMMARY")
        print("="*80)
        
        print(f"\n📊 Statistics:")
        print(f"   Total Interviews: {stats['total_interviews']}")
        print(f"   Preparation Rate: {stats['preparation_rate']}")
        print(f"   Status: {stats['by_status']}")
        if stats['by_outcome']:
            print(f"   Outcomes: {stats['by_outcome']}")
        
        print(f"\n📅 Upcoming Interviews (Next 7 Days):")
        if upcoming:
            for interview in upcoming:
                prep_status = "✅" if interview["preparation_completed"] else "⏳"
                print(f"   {interview['interview_date']} {interview['interview_time']} - {interview['job_title']} @ {interview['company']} {prep_status}")
        else:
            print("   (No upcoming interviews)")
        
        print("\n" + "="*80)


def main():
    """Main execution"""
    
    print("\n" + "="*80)
    print("📅 INTERVIEW SCHEDULER - DEMO")
    print("="*80 + "\n")
    
    scheduler = InterviewScheduler()
    
    # Schedule sample interview
    print("Scheduling sample interview...")
    interview = scheduler.schedule_interview(
        job_title="Senior Data Engineer",
        company="Databricks",
        interviewer_name="Alice Johnson",
        interviewer_email="alice@databricks.com",
        interview_date="2025-11-15",
        interview_time="14:00",
        duration_minutes=60,
        interview_type="Phone Screen",
        round_number=1
    )
    
    # Mark preparation complete
    print("\nMarking preparation as complete...")
    scheduler.mark_preparation_complete(interview["id"])
    
    # Generate follow-up email
    print("\nGenerating follow-up email...")
    scheduler.send_follow_up_email(
        interview["id"],
        ["contact@simondatalab.de", "sn@gmail.com"]
    )
    
    # Print summary
    scheduler.print_interview_summary()
    
    logger.info("✅ Interview Scheduler demo complete!")


if __name__ == "__main__":
    main()
