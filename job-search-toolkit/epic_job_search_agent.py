#!/usr/bin/env python3
"""
EPIC Job Search Agent - AI-Powered Job Search Orchestrator
===========================================================

Master agent coordinating:
- Intelligent job discovery & scoring
- LinkedIn contact automation  
- Company research & outreach
- Relationship tracking
- Follow-up management
- Offer negotiation

Author: Simon Renauld
Created: November 9, 2025
Version: 1.0 EPIC
"""

import asyncio
import json
import logging
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
import sqlite3

# Add parent to path
sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    import requests
    from dotenv import load_dotenv
    from enum import Enum
    import hashlib
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    sys.exit(1)

# Load environment
load_dotenv()

# ===== CONFIGURATION =====
BASE_DIR = Path(__file__).parent
CONFIG_DIR = BASE_DIR / "config"
DATA_DIR = BASE_DIR / "data"
OUTPUTS_DIR = BASE_DIR / "outputs"
LOGS_DIR = OUTPUTS_DIR / "logs"

# Create directories
for d in [CONFIG_DIR, DATA_DIR, OUTPUTS_DIR, LOGS_DIR]:
    d.mkdir(parents=True, exist_ok=True)

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOGS_DIR / f"agent_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


# ===== DATA MODELS =====

class Priority(Enum):
    CRITICAL = 1
    HIGH = 2
    MEDIUM = 3
    LOW = 4


class SourcePlatform(Enum):
    LINKEDIN = "linkedin"
    INDEED = "indeed"
    GLASSDOOR = "glassdoor"
    COMPANY_WEBSITE = "company_website"


@dataclass
class JobOpportunity:
    """Represents a job opportunity"""
    id: str
    title: str
    company: str
    location: str
    salary_range: Optional[str]
    job_url: str
    source: SourcePlatform
    description: str
    posted_date: str
    relevance_score: int  # 0-100
    matched_skills: List[str]
    skill_gaps: List[str]
    priority: Priority
    notes: str
    discovered_at: str = None
    status: str = "discovered"  # discovered, applied, interview, offer, rejected
    
    def __post_init__(self):
        if self.discovered_at is None:
            self.discovered_at = datetime.now().isoformat()


@dataclass
class LinkedInContact:
    """LinkedIn contact for outreach"""
    id: str
    name: str
    title: str
    company: str
    linkedin_url: str
    relationship: str  # hiring_manager, recruiter, peer, referral
    relevance_score: int  # 0-100
    status: str = "identified"  # identified, connected, messaged, interested, dead
    last_interaction: str = None
    notes: str = ""


@dataclass
class ApplicationPackage:
    """Generated application materials"""
    job_id: str
    company: str
    role: str
    resume_path: str
    cover_letter_path: str
    linkedin_easy_apply: bool
    status: str = "generated"
    submitted_at: str = None
    application_url: str = None


# ===== DATABASE =====

class JobSearchDB:
    """SQLite database for job search tracking"""
    
    def __init__(self, db_path: Path = None):
        if db_path is None:
            db_path = DATA_DIR / "job_search.db"
        
        self.db_path = db_path
        self.init_db()
    
    def init_db(self):
        """Initialize database schema"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        # Jobs table
        c.execute('''
            CREATE TABLE IF NOT EXISTS jobs (
                id TEXT PRIMARY KEY,
                title TEXT,
                company TEXT,
                location TEXT,
                salary_range TEXT,
                job_url TEXT,
                source TEXT,
                description TEXT,
                posted_date TEXT,
                relevance_score INTEGER,
                matched_skills TEXT,
                skill_gaps TEXT,
                priority TEXT,
                notes TEXT,
                discovered_at TEXT,
                status TEXT,
                UNIQUE(job_url, company)
            )
        ''')
        
        # Contacts table
        c.execute('''
            CREATE TABLE IF NOT EXISTS contacts (
                id TEXT PRIMARY KEY,
                name TEXT,
                title TEXT,
                company TEXT,
                linkedin_url TEXT UNIQUE,
                relationship TEXT,
                relevance_score INTEGER,
                status TEXT,
                last_interaction TEXT,
                notes TEXT
            )
        ''')
        
        # Applications table
        c.execute('''
            CREATE TABLE IF NOT EXISTS applications (
                id TEXT PRIMARY KEY,
                job_id TEXT,
                company TEXT,
                role TEXT,
                resume_path TEXT,
                cover_letter_path TEXT,
                linkedin_easy_apply INTEGER,
                status TEXT,
                submitted_at TEXT,
                application_url TEXT,
                FOREIGN KEY(job_id) REFERENCES jobs(id)
            )
        ''')
        
        # Interactions table
        c.execute('''
            CREATE TABLE IF NOT EXISTS interactions (
                id TEXT PRIMARY KEY,
                contact_id TEXT,
                type TEXT,
                message TEXT,
                response TEXT,
                created_at TEXT,
                FOREIGN KEY(contact_id) REFERENCES contacts(id)
            )
        ''')
        
        # Metrics table
        c.execute('''
            CREATE TABLE IF NOT EXISTS metrics (
                id TEXT PRIMARY KEY,
                date TEXT,
                applications_sent INTEGER,
                connections_made INTEGER,
                interviews_scheduled INTEGER,
                offers_received INTEGER,
                total_reach INTEGER
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info(f"✅ Database initialized: {self.db_path}")
    
    def add_job(self, job: JobOpportunity) -> bool:
        """Add job to database"""
        try:
            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            
            c.execute('''
                INSERT OR REPLACE INTO jobs VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                job.id,
                job.title,
                job.company,
                job.location,
                job.salary_range,
                job.job_url,
                job.source.value,
                job.description,
                job.posted_date,
                job.relevance_score,
                json.dumps(job.matched_skills),
                json.dumps(job.skill_gaps),
                job.priority.name,
                job.notes,
                job.discovered_at,
                job.status
            ))
            
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            logger.error(f"❌ Failed to add job: {e}")
            return False
    
    def get_jobs_by_priority(self, priority: Priority = None) -> List[JobOpportunity]:
        """Retrieve jobs, optionally filtered by priority"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        if priority:
            c.execute('''SELECT * FROM jobs WHERE priority = ? ORDER BY relevance_score DESC''', 
                     (priority.name,))
        else:
            c.execute('''SELECT * FROM jobs ORDER BY relevance_score DESC''')
        
        rows = c.fetchall()
        conn.close()
        
        jobs = []
        for row in rows:
            jobs.append(JobOpportunity(
                id=row[0],
                title=row[1],
                company=row[2],
                location=row[3],
                salary_range=row[4],
                job_url=row[5],
                source=SourcePlatform(row[6]),
                description=row[7],
                posted_date=row[8],
                relevance_score=row[9],
                matched_skills=json.loads(row[10]),
                skill_gaps=json.loads(row[11]),
                priority=Priority[row[12]],
                notes=row[13],
                discovered_at=row[14],
                status=row[15]
            ))
        
        return jobs


# ===== MAIN AGENT =====

class EPICJobSearchAgent:
    """
    Main job search agent orchestrating:
    - Job discovery and scoring
    - LinkedIn outreach
    - Application generation
    - Tracking and metrics
    """
    
    def __init__(self):
        self.db = JobSearchDB()
        self.config = self._load_config()
        self.session = requests.Session()
        logger.info("🚀 EPIC Job Search Agent initialized")
    
    def _load_config(self) -> Dict:
        """Load configuration"""
        config_file = CONFIG_DIR / "profile.json"
        
        if not config_file.exists():
            logger.warning(f"⚠️ Config not found: {config_file}")
            return self._default_config()
        
        with open(config_file) as f:
            return json.load(f)
    
    def _default_config(self) -> Dict:
        """Default configuration"""
        return {
            "name": "Simon Renauld",
            "title": "Data Engineer & QA Automation",
            "experience_years": 8,
            "target_roles": [
                "Lead Data Engineer",
                "Data Platform Engineer",
                "Analytics Lead",
                "QA Manager"
            ],
            "target_locations": ["Remote", "Singapore", "Australia", "Ho Chi Minh City"],
            "skills": [
                "Python", "SQL", "Apache Airflow", "AWS", "GCP",
                "Data Engineering", "QA Automation", "pytest",
                "ETL", "Data Governance", "CI/CD"
            ],
            "salary_range": {"min": 80000, "max": 200000},
            "remote_preference": True
        }
    
    # ===== JOB DISCOVERY & SCORING =====
    
    async def discover_jobs(self, limit: int = 50) -> List[JobOpportunity]:
        """
        Discover job opportunities from multiple sources
        
        Future: Integrate with LinkedIn, Indeed, Glassdoor APIs
        For now: Return mock data for testing
        """
        logger.info(f"🔍 Discovering {limit} job opportunities...")
        
        jobs = []
        
        # TODO: Integrate real job APIs
        # For now, create sample opportunities
        sample_jobs = [
            {
                "title": "Lead Data Engineer",
                "company": "Shopee",
                "location": "Singapore",
                "salary": "S$120k-150k",
                "description": "Lead data platform team, Airflow, Python"
            },
            {
                "title": "Data Platform Engineer",
                "company": "Grab",
                "location": "Singapore",
                "salary": "S$130k-160k",
                "description": "Data infrastructure, AWS, Scala, Python"
            },
            {
                "title": "Analytics Lead",
                "company": "Atlassian",
                "location": "Sydney",
                "salary": "A$180k-220k",
                "description": "Analytics team leadership, Tableau, SQL"
            }
        ]
        
        logger.info(f"✅ Discovered {len(sample_jobs)} opportunities (sample)")
        return jobs
    
    async def score_job(self, job: JobOpportunity) -> int:
        """
        Score job relevance 0-100 based on:
        - Skill match
        - Salary fit
        - Location preference
        - Company culture
        """
        score = 0
        matched_skills = []
        skill_gaps = []
        
        # Skill matching (40 points)
        my_skills = set(s.lower() for s in self.config["skills"])
        job_keywords = set(job.description.lower().split())
        
        skill_matches = my_skills & job_keywords
        matched_skills = list(skill_matches)
        score += min(40, len(skill_matches) * 4)
        
        # Location preference (20 points)
        if any(loc.lower() in job.location.lower() 
               for loc in self.config["target_locations"]):
            score += 20
        
        # Role match (25 points)
        if any(role.lower() in job.title.lower() 
               for role in self.config["target_roles"]):
            score += 25
        
        # Salary fit (15 points)
        if job.salary_range:
            # TODO: Parse salary and compare
            score += 10
        
        job.relevance_score = min(100, score)
        job.matched_skills = matched_skills
        
        # Determine priority
        if score >= 80:
            job.priority = Priority.CRITICAL
        elif score >= 65:
            job.priority = Priority.HIGH
        elif score >= 50:
            job.priority = Priority.MEDIUM
        else:
            job.priority = Priority.LOW
        
        return job.relevance_score
    
    # ===== LINKEDIN OUTREACH =====
    
    async def identify_linkedin_contacts(self, company: str, limit: int = 10) -> List[LinkedInContact]:
        """
        Identify key contacts at target company:
        - Hiring managers
        - Recruiters
        - Relevant engineers
        
        Future: Integrate LinkedIn API
        """
        logger.info(f"👥 Identifying {limit} contacts at {company}...")
        
        # TODO: Implement LinkedIn search + data extraction
        contacts = []
        
        logger.info(f"✅ Identified {len(contacts)} contacts")
        return contacts
    
    async def generate_outreach_message(self, contact: LinkedInContact, job: JobOpportunity) -> str:
        """
        Generate personalized LinkedIn outreach message
        
        Future: Use LLM for more personalized messages
        """
        message = f"""Hi {contact.name},

I noticed you're at {contact.company} as {contact.title}. I'm very interested in your {job.title} role and believe my background in {', '.join(self.config['skills'][:3])} aligns well with your needs.

Would love to chat about opportunities to contribute to your team's success.

Best regards,
{self.config['name']}"""
        
        return message
    
    # ===== APPLICATION MANAGEMENT =====
    
    async def generate_application_package(self, job: JobOpportunity) -> ApplicationPackage:
        """
        Generate tailored application materials:
        - Resume
        - Cover letter
        - LinkedIn easy-apply
        
        Future: Implement with actual document generation
        """
        logger.info(f"📋 Generating application for {job.title} at {job.company}...")
        
        # Create unique IDs
        app_id = hashlib.md5(f"{job.id}_{datetime.now().isoformat()}".encode()).hexdigest()[:8]
        
        package = ApplicationPackage(
            job_id=job.id,
            company=job.company,
            role=job.title,
            resume_path=f"{OUTPUTS_DIR}/resumes/{job.company}_tailored_resume.pdf",
            cover_letter_path=f"{OUTPUTS_DIR}/cover_letters/{job.company}_cover_letter.md",
            linkedin_easy_apply=True,
            status="generated"
        )
        
        logger.info(f"✅ Generated application package: {app_id}")
        return package
    
    # ===== MAIN WORKFLOWS =====
    
    async def run_daily_workflow(self):
        """
        Daily job search workflow:
        1. Search for new opportunities
        2. Score and prioritize
        3. Generate top 5 applications
        4. Schedule LinkedIn outreach
        5. Review follow-ups
        """
        logger.info("="*70)
        logger.info("🤖 STARTING EPIC DAILY JOB SEARCH WORKFLOW")
        logger.info("="*70)
        
        try:
            # 1. Discover jobs
            logger.info("\n📊 STEP 1: Job Discovery")
            jobs = await self.discover_jobs(limit=50)
            logger.info(f"   Found {len(jobs)} opportunities")
            
            # 2. Score jobs
            logger.info("\n🎯 STEP 2: Scoring & Prioritization")
            scored_jobs = []
            for job in jobs:
                score = await self.score_job(job)
                self.db.add_job(job)
                if job.priority in [Priority.CRITICAL, Priority.HIGH]:
                    scored_jobs.append(job)
            
            scored_jobs.sort(key=lambda x: x.relevance_score, reverse=True)
            top_5 = scored_jobs[:5]
            
            for i, job in enumerate(top_5, 1):
                logger.info(f"   {i}. {job.title} @ {job.company} ({job.relevance_score}%)")
            
            # 3. Generate applications
            logger.info("\n📝 STEP 3: Application Generation")
            applications = []
            for job in top_5:
                app = await self.generate_application_package(job)
                applications.append(app)
                logger.info(f"   ✅ {job.title} @ {job.company}")
            
            # 4. LinkedIn outreach
            logger.info("\n👥 STEP 4: LinkedIn Outreach Prep")
            for job in top_5:
                contacts = await self.identify_linkedin_contacts(job.company, limit=3)
                logger.info(f"   📍 {job.company}: {len(contacts)} contacts identified")
            
            # 5. Summary
            logger.info("\n📈 WORKFLOW SUMMARY")
            logger.info(f"   Opportunities found: {len(jobs)}")
            logger.info(f"   Critical/High priority: {len(scored_jobs)}")
            logger.info(f"   Applications generated: {len(applications)}")
            logger.info(f"   Ready to submit: {len(top_5)}")
            
            logger.info("\n✅ DAILY WORKFLOW COMPLETE")
            logger.info("="*70)
            
        except Exception as e:
            logger.error(f"❌ Workflow failed: {e}", exc_info=True)
    
    async def run_weekly_workflow(self):
        """
        Weekly job search workflow:
        1. Comprehensive analytics
        2. Follow-up management
        3. Interview prep
        4. Strategic adjustments
        """
        logger.info("="*70)
        logger.info("🤖 STARTING EPIC WEEKLY JOB SEARCH WORKFLOW")
        logger.info("="*70)
        
        try:
            # Get all jobs
            all_jobs = self.db.get_jobs_by_priority()
            
            logger.info("\n📊 WEEKLY ANALYTICS")
            logger.info(f"   Total opportunities: {len(all_jobs)}")
            
            # Count by priority
            for priority in Priority:
                count = len([j for j in all_jobs if j.priority == priority])
                logger.info(f"   {priority.name}: {count}")
            
            logger.info("\n✅ WEEKLY WORKFLOW COMPLETE")
            logger.info("="*70)
            
        except Exception as e:
            logger.error(f"❌ Weekly workflow failed: {e}", exc_info=True)


# ===== CLI =====

async def main():
    """Main entry point"""
    import sys
    
    agent = EPICJobSearchAgent()
    
    if len(sys.argv) < 2:
        print("""
EPIC Job Search Agent - AI-Powered Job Search Orchestrator
===========================================================

Usage:
  python epic_job_search_agent.py daily       # Run daily workflow
  python epic_job_search_agent.py weekly      # Run weekly workflow
  python epic_job_search_agent.py status      # Show current status
  python epic_job_search_agent.py init        # Initialize setup

Examples:
  python epic_job_search_agent.py daily       # Discover + score + apply
  python epic_job_search_agent.py weekly      # Analytics + follow-ups
""")
        sys.exit(0)
    
    command = sys.argv[1]
    
    if command == "daily":
        await agent.run_daily_workflow()
    
    elif command == "weekly":
        await agent.run_weekly_workflow()
    
    elif command == "status":
        jobs = agent.db.get_jobs_by_priority()
        print(f"\n📊 AGENT STATUS")
        print(f"   Total jobs tracked: {len(jobs)}")
        print(f"   Database: {agent.db.db_path}")
        print(f"   Config: {agent.config['name']}")
    
    elif command == "init":
        logger.info("✅ Agent initialized and ready")
    
    else:
        print(f"❌ Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
