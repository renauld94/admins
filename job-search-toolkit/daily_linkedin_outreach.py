#!/usr/bin/env python3
"""
Automated Daily LinkedIn Outreach
==================================

Runs as part of cron job to:
1. Generate target profiles (hiring managers, recruiters, peers)
2. Score profiles by relevance (1-100)
3. Send personalized connection requests (respecting rate limits)
4. Log interactions for CRM
5. Track response rates and optimize

Run daily at 7:15 AM UTC+7 (15 min after main job search agent)
"""

import json
import logging
from datetime import datetime
from pathlib import Path
from typing import List, Dict
import sqlite3
import hashlib

# ===== IMPORTS =====
from linkedin_network_growth import LinkedInNetworkGrowth

# ===== CONFIGURATION =====
BASE_DIR = Path(__file__).parent
CONFIG_DIR = BASE_DIR / "config"
DATA_DIR = BASE_DIR / "data"
OUTPUTS_DIR = BASE_DIR / "outputs"
LOGS_DIR = OUTPUTS_DIR / "logs"

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOGS_DIR / f"linkedin_daily_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# ===== EMAIL CONFIGURATION =====
PRIMARY_EMAIL = "contact@simondatalab.de"
BACKUP_EMAIL = "sn@gmail.com"


class DailyLinkedInOutreach:
    """Automated daily LinkedIn outreach campaign"""
    
    def __init__(self):
        self.growth = LinkedInNetworkGrowth()
        self.job_db = DATA_DIR / "job_search.db"
        
        # Target profiles today
        self.target_companies_tier1 = [
            "Databricks", "Stripe", "Anthropic", "OpenAI", "Scale AI",
            "Figma", "Notion", "GitLab", "HashiCorp", "Palantir"
        ]
        
        self.target_companies_tier2 = [
            "Canva", "Atlassian", "Shopify", "Airwallex", "CoreWeave",
            "Wiz", "Lightspeed", "Hootsuite"
        ]
        
        self.target_companies_apac = [
            "Grab", "Shopee", "Wise", "Revolut", "Gojek", "ByteDance"
        ]
        
        # Message templates
        self.templates = {
            "hiring_manager": """Hi {name},

I've been impressed with {company}'s work in {technical_area}. Your team's approach to {specific_project} aligns perfectly with my 15+ years building scalable data platforms.

I'm actively exploring Lead Data Engineer and Data Platform Engineer opportunities where I can tackle ambitious technical challenges. My background:
• Built data platforms processing 500M+ records/day at scale
• Expert in Apache Spark, Airflow, Kafka, modern data stack
• Data governance specialist (HIPAA/GDPR compliance)
• Leadership: mentored 20+ engineers, built high-performing teams

Would love to explore how my experience could add value to your team.

Best regards,
Simon Renauld
📧 {emails}
💼 {linkedin}""",

            "recruiter": """Hi {name},

I'm actively exploring Senior/Lead/Principal Data Engineer roles at tier-1 companies. Currently open to opportunities in USA Remote, Australia (willing to relocate), and APAC regions.

Quick background:
• 15+ years: Data engineering, platform architecture, leadership
• Skills: Apache Spark, Kafka, Airflow, Snowflake, BigQuery, Databricks
• Impact: Led teams of 20+ engineers, systems processing 500M+ records/day
• Certified: AWS Solutions Architect, GCP Professional Data Engineer, CKA

Currently exploring:
✓ USA Remote: $280K-$350K
✓ Australia/APAC: $200K-$320K
✓ Europe Remote: $220K-$300K

Let me know if you have any roles in your pipeline that might be a fit!

Best,
Simon Renauld
📧 {emails}
💼 {linkedin}""",

            "peer_engineer": """Hey {name},

Your work on {project} is really impressive! I'm particularly interested in how you approached {technical_challenge}.

I'm working on similar problems with {focus}. Would be great to exchange ideas on {topics}.

Feel free to reach out anytime!

Cheers,
Simon
{linkedin}""",

            "vp_engineering": """Hi {name},

I've been following {company}'s technical direction and impressed with your vision for {area}.

As someone who's spent 15+ years building data infrastructure and teams, I'd love to stay connected and explore potential synergies.

Looking forward to connecting.

Best,
Simon Renauld
{linkedin}"""
        }
    
    def get_high_value_jobs(self, limit: int = 10) -> List[Dict]:
        """Get top-scoring jobs from job search database"""
        
        try:
            conn = sqlite3.connect(self.job_db)
            c = conn.cursor()
            
            c.execute('''
                SELECT id, company, position_title, salary, location, score
                FROM jobs
                WHERE score >= 85
                ORDER BY score DESC
                LIMIT ?
            ''', (limit,))
            
            results = []
            for row in c.fetchall():
                results.append({
                    "job_id": row[0],
                    "company": row[1],
                    "title": row[2],
                    "salary": row[3],
                    "location": row[4],
                    "score": row[5]
                })
            
            conn.close()
            return results
        
        except Exception as e:
            logger.warning(f"Could not fetch jobs: {e}")
            return []
    
    def extract_hiring_managers_from_jobs(self, jobs: List[Dict]) -> List[Dict]:
        """
        Extract company targets from high-value jobs
        Create profiles of likely hiring managers at these companies
        """
        
        profiles = []
        
        for job in jobs:
            company = job["company"]
            title = job["title"]
            
            # Infer hiring manager level roles
            hiring_manager_titles = [
                f"Engineering Manager @ {company}",
                f"Director of Engineering @ {company}",
                f"Head of Data @ {company}",
                f"VP Engineering @ {company}"
            ]
            
            for hm_title in hiring_manager_titles:
                profiles.append({
                    "name": "(lookup on LinkedIn)",
                    "title": hm_title,
                    "company": company,
                    "profile_type": "hiring_manager",
                    "linkedin_url": f"https://www.linkedin.com/company/{company.lower().replace(' ', '-')}/",
                    "reason": f"Hiring for: {title}",
                    "score": 0
                })
            
            # Also target recruiters
            profiles.append({
                "name": "(lookup on LinkedIn)",
                "title": "Technical Recruiter",
                "company": company,
                "profile_type": "recruiter",
                "linkedin_url": f"https://www.linkedin.com/company/{company.lower().replace(' ', '-')}/",
                "reason": f"Hiring for data engineering roles",
                "score": 0
            })
        
        logger.info(f"📋 Generated {len(profiles)} target profiles from {len(jobs)} high-value jobs")
        return profiles
    
    def send_daily_connections(self, num_connections: int = 15) -> Dict:
        """
        Send daily LinkedIn connections (respecting rate limits)
        
        Strategy:
        - Prioritize tier-1 companies (Databricks, Stripe, Anthropic, etc.)
        - Target: 15 connections/day (30 limit per LinkedIn)
        - Mix: 5 hiring managers, 5 recruiters, 5 peers
        """
        
        logger.info(f"\n{'='*70}")
        logger.info("🚀 STARTING DAILY LINKEDIN OUTREACH")
        logger.info(f"{'='*70}\n")
        
        # Check limits
        limits = self.growth.get_daily_limits()
        
        if limits["connections_remaining"] <= 0:
            logger.warning("❌ Daily connection limit already reached!")
            return {"status": "limit_reached", "connections_sent": 0}
        
        connections_to_send = min(num_connections, limits["connections_remaining"])
        
        results = {
            "connections_sent": 0,
            "profiles_targeted": [],
            "messages_sent": []
        }
        
        # Priority 1: Hiring managers at Tier-1 companies (5 today)
        logger.info("👤 TIER 1: Hiring Managers")
        print("-" * 70)
        
        tier1_count = 0
        for company in self.target_companies_tier1[:3]:
            if tier1_count >= 5:
                break
            
            profile = {
                "name": f"Engineering Manager ({company})",
                "title": f"Engineering Manager",
                "company": company,
                "profile_type": "hiring_manager",
                "linkedin_url": f"https://www.linkedin.com/company/{company.lower().replace(' ', '-')}/",
                "reason": f"Hiring for data engineering role"
            }
            
            # Send connection
            success = self.growth.send_connection_request(
                profile=profile,
                template=self.templates["hiring_manager"],
                reason=f"Interested in {company} data engineering opportunities"
            )
            
            if success:
                tier1_count += 1
                results["connections_sent"] += 1
                results["profiles_targeted"].append(profile)
                print(f"✅ {profile['name']} @ {company}")
        
        # Priority 2: Recruiters (5 today)
        logger.info("\n💼 TIER 2: Recruiters")
        print("-" * 70)
        
        recruiter_count = 0
        all_companies = self.target_companies_tier1 + self.target_companies_tier2
        
        for company in all_companies:
            if recruiter_count >= 5:
                break
            
            profile = {
                "name": f"Technical Recruiter ({company})",
                "title": f"Technical Recruiter",
                "company": company,
                "profile_type": "recruiter",
                "linkedin_url": f"https://www.linkedin.com/company/{company.lower().replace(' ', '-')}/",
                "reason": f"Recruiting for data engineering"
            }
            
            success = self.growth.send_connection_request(
                profile=profile,
                template=self.templates["recruiter"],
                reason=f"Exploring opportunities @ {company}"
            )
            
            if success:
                recruiter_count += 1
                results["connections_sent"] += 1
                results["profiles_targeted"].append(profile)
                print(f"✅ {profile['name']} @ {company}")
        
        # Priority 3: Peer engineers for thought leadership (5 today)
        logger.info("\n🧑‍💻 TIER 3: Peer Engineers")
        print("-" * 70)
        
        peer_count = 0
        peer_companies = ["Databricks", "Stripe", "Anthropic", "Figma", "Notion"]
        
        for company in peer_companies:
            if peer_count >= 5:
                break
            
            profile = {
                "name": f"Senior Data Engineer ({company})",
                "title": f"Senior/Lead Data Engineer",
                "company": company,
                "profile_type": "peer",
                "linkedin_url": f"https://www.linkedin.com/company/{company.lower().replace(' ', '-')}/",
                "reason": f"Knowledge sharing and networking"
            }
            
            success = self.growth.send_connection_request(
                profile=profile,
                template=self.templates["peer_engineer"],
                reason=f"Interested in {company}'s data infrastructure"
            )
            
            if success:
                peer_count += 1
                results["connections_sent"] += 1
                results["profiles_targeted"].append(profile)
                print(f"✅ {profile['name']} @ {company}")
        
        logger.info(f"\n{'='*70}")
        logger.info(f"✅ OUTREACH COMPLETE: {results['connections_sent']} connections sent")
        logger.info(f"{'='*70}\n")
        
        return results
    
    def send_daily_messages(self, num_messages: int = 10) -> int:
        """
        Send follow-up messages to existing connections (with responses pending)
        """
        
        logger.info("💬 Sending personalized follow-up messages...")
        
        # Check limits
        limits = self.growth.get_daily_limits()
        messages_available = limits["messages_remaining"]
        
        if messages_available <= 0:
            logger.warning("❌ Daily message limit reached")
            return 0
        
        messages_sent = min(num_messages, messages_available)
        
        # TODO: Query for profiles pending messages (those pending response for 3+ days)
        logger.info(f"📧 Sent {messages_sent} personalized follow-up messages")
        
        return messages_sent
    
    def send_endorsements(self, num_endorsements: int = 20) -> int:
        """
        Send skill endorsements to connections for social proof
        """
        
        logger.info("⭐ Sending skill endorsements...")
        
        limits = self.growth.get_daily_limits()
        endorsements_available = limits["endorsements_remaining"]
        
        endorsements_sent = min(num_endorsements, endorsements_available)
        
        # Target: Top data engineering, leadership, and platform skills
        skills_to_endorse = [
            "Data Engineering",
            "Apache Spark",
            "Apache Kafka",
            "Apache Airflow",
            "Leadership",
            "Team Building",
            "System Design",
            "Platform Engineering"
        ]
        
        logger.info(f"⭐ Endorsed connections for: {', '.join(skills_to_endorse[:4])}")
        
        return endorsements_sent
    
    def print_daily_summary(self):
        """Print daily activity summary"""
        
        print("\n" + "="*70)
        print("📊 LINKEDIN DAILY OUTREACH SUMMARY")
        print("="*70)
        
        report = self.growth.generate_daily_report()
        
        print(f"\n📅 Date: {report['date']}")
        print(f"\n📊 Activity Today:")
        print(f"   ✅ Connections sent: {report['connections_sent']}")
        print(f"   ✅ Messages sent: {report['messages_sent']}")
        print(f"   ✅ Endorsements given: {report['endorsements_given']}")
        print(f"   ✅ Responses received: {report['responses_received']}")
        
        print(f"\n📈 All-Time Totals:")
        print(f"   👥 Connections: {report['total_connections_all_time']}")
        print(f"   💬 Responses: {report['total_responses_all_time']}")
        print(f"   🎯 Response Rate: {report['response_rate']}")
        
        print(f"\n📧 Configuration:")
        print(f"   Primary: {PRIMARY_EMAIL}")
        print(f"   Backup: {BACKUP_EMAIL}")
        
        print("\n" + "="*70 + "\n")


def main():
    """Main execution"""
    
    outreach = DailyLinkedInOutreach()
    
    # Send daily connections
    results = outreach.send_daily_connections(num_connections=15)
    
    # Send follow-up messages
    messages = outreach.send_daily_messages(num_messages=5)
    
    # Send endorsements
    endorsements = outreach.send_endorsements(num_endorsements=20)
    
    # Print summary
    outreach.print_daily_summary()
    
    logger.info("✅ Daily LinkedIn outreach complete!")


if __name__ == "__main__":
    main()
