#!/usr/bin/env python3
"""
LinkedIn Network Growth Automation
===================================

Automates LinkedIn connection outreach targeting:
- Hiring managers at target companies
- Recruiters in your field
- Peer engineers for relationship building
- Company CTOs/Directors for thought leadership

Features:
- Intelligent profile scoring (role, company, seniority, fit)
- Personalized connection messages based on profile analysis
- Rate limit compliance (30 connections/day, 50 messages/day)
- Dual email tracking (contact@simondatalab.de + sn@gmail.com)
- Relationship CRM integration
- Success rate tracking & optimization

Author: Simon Renauld
Date: November 10, 2025
"""

import sqlite3
import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import hashlib
import time

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
        logging.FileHandler(LOGS_DIR / f"linkedin_growth_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# ===== EMAIL CONFIGURATION =====
PRIMARY_EMAIL = "contact@simondatalab.de"
BACKUP_EMAIL = "sn@gmail.com"
LINKEDIN_PROFILE = "https://www.linkedin.com/in/simonrenauld"

# ===== RATE LIMITING =====
DAILY_CONNECTION_LIMIT = 30  # LinkedIn default
DAILY_MESSAGE_LIMIT = 50
DAILY_ENDORSEMENT_LIMIT = 100
RATE_LIMIT_DELAY = 2  # seconds between actions


class LinkedInNetworkGrowth:
    """Orchestrates LinkedIn network growth automation"""
    
    def __init__(self):
        self.db_path = DATA_DIR / "linkedin_contacts.db"
        self.crm_db_path = DATA_DIR / "networking_crm.db"
        self.job_db_path = DATA_DIR / "job_search.db"
        
        self.init_databases()
        self.load_profile_config()
        
        logger.info("🚀 LinkedIn Network Growth automation initialized")
    
    def init_databases(self):
        """Initialize/verify LinkedIn databases"""
        # LinkedIn contacts database
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            CREATE TABLE IF NOT EXISTS target_profiles (
                id TEXT PRIMARY KEY,
                name TEXT,
                title TEXT,
                company TEXT,
                linkedin_url TEXT UNIQUE,
                profile_type TEXT,
                relevance_score INTEGER,
                target_reason TEXT,
                connection_status TEXT,
                connection_message TEXT,
                connection_sent_at TEXT,
                response_received_at TEXT,
                response_text TEXT,
                follow_up_scheduled TEXT,
                follow_up_sent_at TEXT,
                email_sent_to TEXT,
                email_tracking_id TEXT,
                created_at TEXT,
                updated_at TEXT
            )
        ''')
        
        # Outreach templates
        c.execute('''
            CREATE TABLE IF NOT EXISTS outreach_templates (
                id TEXT PRIMARY KEY,
                target_type TEXT,
                context TEXT,
                template TEXT,
                created_at TEXT
            )
        ''')
        
        # Campaign tracking
        c.execute('''
            CREATE TABLE IF NOT EXISTS campaigns (
                id TEXT PRIMARY KEY,
                name TEXT,
                target_companies TEXT,
                target_roles TEXT,
                start_date TEXT,
                status TEXT,
                connections_sent INTEGER,
                messages_sent INTEGER,
                responses_received INTEGER,
                conversion_rate REAL,
                created_at TEXT
            )
        ''')
        
        # Daily activity logs
        c.execute('''
            CREATE TABLE IF NOT EXISTS daily_activity (
                id TEXT PRIMARY KEY,
                date TEXT,
                connections_sent INTEGER,
                messages_sent INTEGER,
                endorsements_given INTEGER,
                responses_received INTEGER,
                follows INTEGER,
                created_at TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info("✅ LinkedIn databases initialized")
    
    def load_profile_config(self):
        """Load Simon's profile configuration"""
        profile_path = CONFIG_DIR / "profile.json"
        if profile_path.exists():
            with open(profile_path) as f:
                self.profile = json.load(f)
            logger.info(f"✅ Profile loaded: {self.profile['personal']['name']}")
        else:
            logger.warning("⚠️ Profile config not found")
            self.profile = {}
    
    # ===== TARGET PROFILE GENERATION =====
    
    def generate_target_profiles(self, target_companies: Optional[List[str]] = None, target_roles: Optional[List[str]] = None) -> List[Dict]:
        """
        Generate list of ideal LinkedIn profiles to connect with
        
        Profiles include:
        1. Hiring managers at target companies
        2. Recruiters at target companies
        3. Peer engineers for networking
        4. CTOs/VPs for thought leadership
        """
        
        if not target_companies:
            # Default target companies (Tier-1)
            target_companies = [
                "Databricks", "Stripe", "Anthropic", "OpenAI", "Scale AI",
                "Figma", "Notion", "GitLab", "HashiCorp", "Canva",
                "Atlassian", "Shopify", "Airwallex", "Grab", "Shopee",
                "Wise", "Revolut", "Lightspeed", "CoreWeave", "Wiz"
            ]
        
        if not target_roles:
            # Relevant roles to connect with
            target_roles = [
                "Hiring Manager",
                "Engineering Manager", 
                "Director of Engineering",
                "VP Engineering",
                "Head of Data",
                "CTO",
                "Senior Data Engineer",
                "Lead Data Engineer",
                "Data Platform Engineer",
                "Recruiter"
            ]
        
        profiles = []
        
        for company in target_companies:
            # Profile Type 1: Hiring Managers
            profiles.append({
                "company": company,
                "profile_type": "hiring_manager",
                "target_roles": ["Engineering Manager", "Director of Engineering", "Head of Data"],
                "priority": "high",
                "relevance_factors": ["team_building_experience", "data_engineering_background", "leadership"]
            })
            
            # Profile Type 2: Recruiters
            profiles.append({
                "company": company,
                "profile_type": "recruiter",
                "target_roles": ["Recruiter", "HR"],
                "priority": "high",
                "relevance_factors": ["data_engineering_hiring", "pipeline_building", "response_rate"]
            })
            
            # Profile Type 3: Peer Engineers
            profiles.append({
                "company": company,
                "profile_type": "peer",
                "target_roles": ["Senior Data Engineer", "Lead Data Engineer", "Data Platform Engineer"],
                "priority": "medium",
                "relevance_factors": ["similar_skills", "interesting_projects", "thought_leadership"]
            })
        
        logger.info(f"📋 Generated {len(profiles)} target profile templates across {len(target_companies)} companies")
        return profiles
    
    # ===== CONNECTION MESSAGE TEMPLATES =====
    
    def create_outreach_templates(self):
        """Create personalized connection message templates"""
        
        templates = {
            "hiring_manager_cold": {
                "context": "Cold outreach to engineering manager at target company",
                "template": """Hi {name},

I've been impressed with {company}'s approach to {technical_area}. Your team's work on {specific_project} aligns perfectly with my 15+ years building scalable data platforms.

I'm actively exploring Lead Data Engineer and Data Platform Engineer opportunities where I can contribute to ambitious technical challenges. My background includes:

• Built data platforms processing 500M+ records/day at scale
• Expert in Apache Spark, Airflow, Kafka, and modern data stack
• Data governance and compliance specialist (HIPAA/GDPR)
• Leadership: mentored 20+ engineers, built high-performing teams

I'd love to explore how my experience could add value to your team.

Best regards,
Simon Renauld
{emails}
{linkedin}"""
            },
            
            "recruiter_active": {
                "context": "Active outreach to recruiting professional",
                "template": """Hi {name},

I'm actively exploring Senior/Lead/Principal Data Engineer roles at tier-1 companies, particularly in {locations}.

Quick summary:
• 15+ years: data engineering, platform architecture, leadership
• Expertise: Apache Spark, Kafka, Airflow, Snowflake, BigQuery, Databricks
• Leadership: Built and mentored data teams of 20+
• Impact: Systems processing 500M+ records/day, 99.9% uptime

Currently exploring opportunities in:
- USA Remote: $280K-$350K
- Australia/APAC: $200K-$320K (open to relocation)
- Europe Remote: Remote-first preferred

Do you have any roles in your pipeline that might be a fit? Happy to discuss.

Best,
Simon Renauld
📧 {emails}
💼 {linkedin}"""
            },
            
            "peer_engineer": {
                "context": "Connection with peer engineer for knowledge sharing",
                "template": """Hey {name},

Your work on {technical_detail} is really impressive! I'm particularly interested in how you approached {technical_challenge}.

I'm working on similar problems with {your_focus}. Would be great to exchange ideas on:
• {topic_1}
• {topic_2}
• {topic_3}

Feel free to reach out anytime.

Cheers,
Simon
{linkedin}"""
            },
            
            "cto_thought_leadership": {
                "context": "Thought leadership connection with executive",
                "template": """Hi {name},

I've been following {company}'s technical direction and impressed with your vision for {area}.

As someone who's spent 15+ years building data infrastructure at scale, I'd love to stay connected and potentially collaborate on {topic}.

Looking forward to connecting.

Best,
Simon Renauld
{linkedin}"""
            },
            
            "referral_request": {
                "context": "Follow-up asking for referral/introduction",
                "template": """Hi {name},

Hope you're doing well! Following up on our conversation about {topic}.

I'm particularly interested in connecting with {target_person_role} at {company} who owns {area}. Would you be open to an introduction?

Appreciate any help!

Best,
Simon"""
            }
        }
        
        # Store templates in database
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        for template_id, template_data in templates.items():
            c.execute('''
                INSERT OR REPLACE INTO outreach_templates
                VALUES (?, ?, ?, ?, ?)
            ''', (
                hashlib.md5(template_id.encode()).hexdigest()[:8],
                template_data.get("context", ""),
                template_id,
                json.dumps(template_data),
                datetime.now().isoformat()
            ))
        
        conn.commit()
        conn.close()
        logger.info(f"✅ Created {len(templates)} outreach templates")
    
    # ===== PROFILE SCORING =====
    
    def score_target_profile(self, profile: Dict) -> int:
        """
        Score a LinkedIn profile for connection priority
        
        Factors (0-100):
        - Company tier (30 pts): Target company list
        - Role relevance (25 pts): Hiring power or technical credibility
        - Network position (20 pts): 1st/2nd degree, mutual connections
        - Activity level (15 pts): Recent posts, engagement
        - Seasonality (10 pts): Time zone, typical responsiveness
        """
        
        score = 0
        
        # Company tier (30 points)
        tier1_companies = ["Databricks", "Stripe", "Anthropic", "OpenAI", "Scale AI", "Figma", "Notion"]
        tier2_companies = ["GitLab", "HashiCorp", "Canva", "Atlassian", "Shopify", "Airwallex"]
        tier3_companies = ["Grab", "Shopee", "Wise", "Revolut"]
        
        if profile.get("company") in tier1_companies:
            score += 30
        elif profile.get("company") in tier2_companies:
            score += 20
        elif profile.get("company") in tier3_companies:
            score += 15
        else:
            score += 5
        
        # Role relevance (25 points)
        high_value_roles = ["CTO", "VP Engineering", "Head of Data", "Engineering Manager", "Director"]
        medium_value_roles = ["Senior Manager", "Lead Engineer", "Principal Engineer", "Recruiter", "Hiring Manager"]
        
        if any(role in profile.get("title", "") for role in high_value_roles):
            score += 25
        elif any(role in profile.get("title", "") for role in medium_value_roles):
            score += 15
        else:
            score += 5
        
        # Network position (20 points)
        degree = profile.get("degree_of_separation", 3)
        mutual = profile.get("mutual_connections", 0)
        
        if degree == 1:
            score += 15
        elif degree == 2:
            score += 10
        else:
            score += 5
        
        if mutual > 10:
            score += 5
        
        # Activity level (15 points)
        if profile.get("recent_activity", False):
            score += 10
        
        if profile.get("thought_leader", False):
            score += 5
        
        # Seasonality/Timezone bonus (10 points)
        location = profile.get("location", "")
        if any(city in location for city in ["Singapore", "Sydney", "Hong Kong", "Ho Chi Minh"]):
            score += 10  # Better timezone for Simon
        elif any(city in location for city in ["San Francisco", "NYC", "Seattle"]):
            score += 5   # USA timezone, OK
        
        return min(100, score)
    
    # ===== CAMPAIGN MANAGEMENT =====
    
    def create_campaign(self, name: str, target_companies: List[str], target_roles: List[str]) -> str:
        """Create a new outreach campaign"""
        
        campaign_id = hashlib.md5(f"{name}{datetime.now().isoformat()}".encode()).hexdigest()[:8]
        
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            INSERT INTO campaigns (id, name, target_companies, target_roles, start_date, status)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            campaign_id,
            name,
            json.dumps(target_companies),
            json.dumps(target_roles),
            datetime.now().isoformat(),
            "active"
        ))
        
        conn.commit()
        conn.close()
        
        logger.info(f"📊 Campaign created: {name} ({campaign_id})")
        return campaign_id
    
    # ===== DAILY ACTIVITY TRACKING =====
    
    def get_daily_limits(self) -> Dict:
        """Check today's activity against limits"""
        
        today = datetime.now().strftime("%Y-%m-%d")
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            SELECT connections_sent, messages_sent, endorsements_given 
            FROM daily_activity 
            WHERE date = ?
        ''', (today,))
        
        result = c.fetchone()
        conn.close()
        
        if result:
            connections_sent, messages_sent, endorsements = result
        else:
            connections_sent = messages_sent = endorsements = 0
        
        return {
            "connections_sent": connections_sent,
            "connections_remaining": DAILY_CONNECTION_LIMIT - connections_sent,
            "messages_sent": messages_sent,
            "messages_remaining": DAILY_MESSAGE_LIMIT - messages_sent,
            "endorsements_given": endorsements,
            "endorsements_remaining": DAILY_ENDORSEMENT_LIMIT - endorsements
        }
    
    def log_activity(self, activity_type: str, count: int = 1):
        """Log daily activity"""
        
        today = datetime.now().strftime("%Y-%m-%d")
        activity_id = hashlib.md5(f"{today}{activity_type}{time.time()}".encode()).hexdigest()[:8]
        
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        # Check if today's record exists
        c.execute('SELECT id FROM daily_activity WHERE date = ?', (today,))
        exists = c.fetchone()
        
        if exists:
            # Update
            if activity_type == "connection":
                c.execute('UPDATE daily_activity SET connections_sent = connections_sent + ? WHERE date = ?', (count, today))
            elif activity_type == "message":
                c.execute('UPDATE daily_activity SET messages_sent = messages_sent + ? WHERE date = ?', (count, today))
            elif activity_type == "endorsement":
                c.execute('UPDATE daily_activity SET endorsements_given = endorsements_given + ? WHERE date = ?', (count, today))
        else:
            # Insert new
            data = {
                "connections_sent": 1 if activity_type == "connection" else 0,
                "messages_sent": 1 if activity_type == "message" else 0,
                "endorsements_given": 1 if activity_type == "endorsement" else 0,
                "follows": 0
            }
            c.execute('''
                INSERT INTO daily_activity (id, date, connections_sent, messages_sent, endorsements_given, follows)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (activity_id, today, data["connections_sent"], data["messages_sent"], data["endorsements_given"], data["follows"]))
        
        conn.commit()
        conn.close()
    
    # ===== CONNECTION INITIATION =====
    
    def send_connection_request(self, profile: Dict, template: str, reason: str) -> bool:
        """
        Send connection request with personalized message
        
        Respects rate limits and tracks via dual emails
        """
        
        # Check rate limits
        limits = self.get_daily_limits()
        if limits["connections_remaining"] <= 0:
            logger.warning("❌ Daily connection limit reached")
            return False
        
        # Generate personalized message
        message = self._personalize_template(template, profile, reason)
        
        # Record in database
        profile_id = hashlib.md5(f"{profile.get('linkedin_url', '')}".encode()).hexdigest()[:8]
        
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            INSERT OR REPLACE INTO target_profiles 
            (id, name, title, company, linkedin_url, profile_type, connection_message, connection_sent_at, email_sent_to)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            profile_id,
            profile.get("name"),
            profile.get("title"),
            profile.get("company"),
            profile.get("linkedin_url"),
            profile.get("profile_type"),
            message,
            datetime.now().isoformat(),
            PRIMARY_EMAIL  # Track which email sent this
        ))
        
        conn.commit()
        conn.close()
        
        # Log activity
        self.log_activity("connection")
        
        logger.info(f"✅ Connection request recorded for {profile.get('name')} @ {profile.get('company')}")
        logger.info(f"   📧 Email: {PRIMARY_EMAIL}")
        logger.info(f"   💬 Message preview: {message[:100]}...")
        
        return True
    
    def _personalize_template(self, template: str, profile: Dict, reason: str) -> str:
        """Personalize message template with profile details"""
        
        replacements = {
            "{name}": profile.get("name", "there"),
            "{company}": profile.get("company", "your company"),
            "{title}": profile.get("title", "role"),
            "{technical_area}": "data infrastructure",
            "{specific_project}": profile.get("recent_project", "current work"),
            "{emails}": f"{PRIMARY_EMAIL} | {BACKUP_EMAIL}",
            "{linkedin}": f"linkedin.com/in/simonrenauld",
            "{locations}": "USA Remote, Australia, Singapore, Vietnam",
            "{topic_1}": "data platform architecture",
            "{topic_2}": "real-time data processing",
            "{topic_3}": "ML infrastructure",
            "{your_focus}": "building scalable data systems",
            "{technical_detail}": profile.get("recent_project", "your work"),
            "{technical_challenge}": "scaling and reliability",
            "{area}": "data engineering and ML infrastructure",
            "{target_person_role}": "Head of Data",
            "{reason}": reason
        }
        
        personalized = template
        for placeholder, value in replacements.items():
            personalized = personalized.replace(placeholder, value)
        
        return personalized
    
    # ===== REPORTING =====
    
    def generate_daily_report(self) -> Dict:
        """Generate daily LinkedIn activity report"""
        
        today = datetime.now().strftime("%Y-%m-%d")
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        # Get today's activity
        c.execute('SELECT * FROM daily_activity WHERE date = ?', (today,))
        activity = c.fetchone()
        
        # Get connection status
        c.execute('''
            SELECT connection_status, COUNT(*) as count 
            FROM target_profiles 
            WHERE date(connection_sent_at) = ?
            GROUP BY connection_status
        ''', (today,))
        
        status_counts = dict(c.fetchall())
        
        # Get response rate
        c.execute('''
            SELECT COUNT(*) FROM target_profiles 
            WHERE response_received_at IS NOT NULL AND date(connection_sent_at) <= ?
        ''', (today,))
        
        responses = c.fetchone()[0]
        
        c.execute('SELECT COUNT(*) FROM target_profiles WHERE date(connection_sent_at) <= ?', (today,))
        total_sent = c.fetchone()[0]
        
        conn.close()
        
        response_rate = (responses / total_sent * 100) if total_sent > 0 else 0
        
        report = {
            "date": today,
            "connections_sent": activity[1] if activity else 0,
            "messages_sent": activity[2] if activity else 0,
            "endorsements_given": activity[3] if activity else 0,
            "responses_received": activity[4] if activity else 0,
            "total_connections_all_time": total_sent,
            "total_responses_all_time": responses,
            "response_rate": f"{response_rate:.1f}%",
            "status_breakdown": status_counts,
            "emails_used": [PRIMARY_EMAIL, BACKUP_EMAIL],
            "limits": self.get_daily_limits()
        }
        
        return report
    
    def print_status(self):
        """Print current status"""
        
        print("\n" + "="*70)
        print("🚀 LINKEDIN NETWORK GROWTH - STATUS")
        print("="*70)
        
        report = self.generate_daily_report()
        
        print(f"\n📊 TODAY'S ACTIVITY ({report['date']}):")
        print(f"   ✅ Connections sent: {report['connections_sent']}")
        print(f"   ✅ Messages sent: {report['messages_sent']}")
        print(f"   ✅ Endorsements given: {report['endorsements_given']}")
        print(f"   ✅ Responses received: {report['responses_received']}")
        
        print(f"\n📈 ALL-TIME STATS:")
        print(f"   👥 Total connections: {report['total_connections_all_time']}")
        print(f"   💬 Total responses: {report['total_responses_all_time']}")
        print(f"   🎯 Response rate: {report['response_rate']}")
        
        print(f"\n⏱️ TODAY'S LIMITS:")
        limits = report['limits']
        print(f"   Connections: {limits['connections_sent']}/{DAILY_CONNECTION_LIMIT} used ({limits['connections_remaining']} left)")
        print(f"   Messages: {limits['messages_sent']}/{DAILY_MESSAGE_LIMIT} used ({limits['messages_remaining']} left)")
        print(f"   Endorsements: {limits['endorsements_given']}/{DAILY_ENDORSEMENT_LIMIT} used ({limits['endorsements_remaining']} left)")
        
        print(f"\n📧 EMAILS CONFIGURED:")
        print(f"   Primary: {PRIMARY_EMAIL}")
        print(f"   Backup: {BACKUP_EMAIL}")
        print(f"   LinkedIn: {LINKEDIN_PROFILE}")
        
        print("\n" + "="*70 + "\n")


# ===== MAIN EXECUTION =====

def main():
    """Main execution"""
    
    linkedin_growth = LinkedInNetworkGrowth()
    
    # Create outreach templates
    linkedin_growth.create_outreach_templates()
    
    # Print status
    linkedin_growth.print_status()
    
    # Example: Create campaign
    campaign_id = linkedin_growth.create_campaign(
        name="Tier-1 Company Outreach",
        target_companies=["Databricks", "Stripe", "Anthropic", "OpenAI", "Figma"],
        target_roles=["Hiring Manager", "Engineering Manager", "Head of Data", "Recruiter"]
    )
    
    logger.info(f"🎯 Campaign ready: {campaign_id}")
    logger.info("📋 Next: Use send_connection_request() to begin outreach")


if __name__ == "__main__":
    main()
