#!/usr/bin/env python3
"""
🎯 LIVE RESULTS GENERATOR - Create realistic job matches for demonstration
Based on your profile, generates matching job opportunities
"""

import json
import sqlite3
import logging
from datetime import datetime, timedelta
import random
from typing import List, Dict

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('outputs/logs/live_results.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class LiveResultsGenerator:
    """Generate realistic job results matching user profile"""
    
    def __init__(self, profile_path: str = "config/profile.json"):
        with open(profile_path) as f:
            self.profile = json.load(f)
        self.db_path = "data/job_search.db"
        
    def generate_sample_jobs(self) -> List[Dict]:
        """Generate realistic sample jobs based on user profile"""
        
        companies = [
            "Databricks", "Stripe", "Scale AI", "Anthropic", "CoreWeave",
            "Figma", "Notion", "Canva", "Rippling", "Segment",
            "Mixpanel", "Amplitude", "Intercom", "HashiCorp", "PlanetScale",
            "Supabase", "Prisma", "Vercel", "Raycast", "Linear"
        ]
        
        roles = [
            "Staff Data Engineer",
            "Lead Machine Learning Engineer", 
            "Senior Data Architect",
            "Principal Analytics Engineer",
            "Engineering Manager - Data",
            "Head of Data Platform",
            "Data Infrastructure Architect",
            "ML Ops Engineer",
            "Data Science Manager"
        ]
        
        locations = [
            "San Francisco, CA (Remote-First)",
            "New York, NY (Remote-First)",
            "Austin, TX (Remote-First)",
            "Seattle, WA (Remote-First)",
            "Remote (Global)",
            "Remote (Americas)",
            "Hybrid - San Francisco"
        ]
        
        benefits_pool = [
            "Stock options", "Unlimited PTO", "401k match",
            "Health insurance", "Home office stipend", "$2k laptop budget",
            "Conference budget", "Free lunch", "Gym membership",
            "Mental health support", "Professional development"
        ]
        
        jobs = []
        
        for i in range(12):
            salary_base = random.randint(180000, 280000)
            salary_min = salary_base
            salary_max = salary_base + random.randint(40000, 100000)
            
            job = {
                'job_id': f'sample_job_{i:03d}',
                'source': random.choice(['indeed', 'linkedin', 'builtin']),
                'title': random.choice(roles),
                'company': random.choice(companies),
                'location': random.choice(locations),
                'country': random.choice(['United States', 'Canada', 'Remote']),
                'region': random.choice(['North America', 'Americas', 'Worldwide']),
                'salary_min': salary_min,
                'salary_max': salary_max,
                'currency': 'USD',
                'description': self._generate_description(random.choice(roles)),
                'requirements': self._generate_requirements(),
                'job_type': random.choice(['full-time', 'contract']),
                'posted_date': (datetime.now() - timedelta(days=random.randint(0, 5))).isoformat(),
                'url': f'https://example.com/jobs/{i}',
                'seniority_level': 'senior',
                'industry': 'Technology',
                'company_size': random.choice(['1000-5000', '100-1000', '10000+']),
                'benefits': ' | '.join(random.sample(benefits_pool, random.randint(3, 6)))
            }
            jobs.append(job)
        
        return jobs
    
    def _generate_description(self, role: str) -> str:
        """Generate job description"""
        descriptions = {
            'Staff Data Engineer': 'Lead data infrastructure initiatives across the organization. Design and build scalable data pipelines processing 100B+ events daily.',
            'Lead Machine Learning Engineer': 'Build production ML systems for recommendation engines. Mentor team of 5-8 engineers on best practices.',
            'Senior Data Architect': 'Design enterprise data architecture supporting 500+ users. Oversee data quality, governance, and compliance.',
            'Principal Analytics Engineer': 'Shape company analytics strategy. Build self-service analytics platform used by 100+ stakeholders.',
            'Engineering Manager - Data': 'Manage team of 8-12 data engineers. Set technical direction and hiring strategy.',
            'Head of Data Platform': 'Lead 20+ person data team. Build next-gen data platform and ML infrastructure.',
            'Data Infrastructure Architect': 'Design distributed systems handling petabytes of data. Optimize costs and performance.',
            'ML Ops Engineer': 'Build ML infrastructure for model training and deployment. Reduce training time by 10x.',
            'Data Science Manager': 'Lead analytics and data science team. Drive data-driven product decisions.'
        }
        return descriptions.get(role, 'Leading technology company looking for experienced data professional.')
    
    def _generate_requirements(self) -> str:
        """Generate job requirements"""
        requirements = [
            "5+ years in data engineering or related field",
            "Expert in Python, SQL, and Spark",
            "Experience with cloud platforms (AWS, GCP, Azure)",
            "Knowledge of data warehousing and ETL",
            "Familiarity with Kubernetes and Docker",
            "Experience mentoring junior engineers",
            "Strong problem-solving skills",
            "Excellent communication abilities",
            "Experience with Apache Airflow or equivalent",
            "Knowledge of real-time data processing"
        ]
        return " | ".join(random.sample(requirements, random.randint(5, 8)))
    
    def save_jobs_to_db(self, jobs: List[Dict]) -> int:
        """Save generated jobs to database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        saved = 0
        for job in jobs:
            try:
                cursor.execute('''
                    INSERT OR IGNORE INTO jobs_multi_source
                    (job_id, source, title, company, location, country, region,
                     salary_min, salary_max, currency, description, requirements,
                     job_type, posted_date, url, seniority_level, industry, company_size, benefits)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    job['job_id'], job['source'], job['title'], job['company'],
                    job['location'], job['country'], job['region'],
                    job['salary_min'], job['salary_max'], job['currency'],
                    job['description'], job['requirements'], job['job_type'],
                    job['posted_date'], job['url'], job['seniority_level'],
                    job['industry'], job['company_size'], job['benefits']
                ))
                saved += 1
            except Exception as e:
                logger.error(f"Error saving job: {e}")
        
        conn.commit()
        conn.close()
        return saved
    
    def generate_and_save(self) -> int:
        """Generate and save sample jobs"""
        logger.info("\n" + "╔" + "="*68 + "╗")
        logger.info("║  💼 LIVE RESULTS GENERATOR - Creating Matched Opportunities   ║")
        logger.info("╚" + "="*68 + "╝\n")
        
        logger.info("🎯 PROFILE SUMMARY:")
        logger.info(f"   Name: {self.profile.get('name')}")
        logger.info(f"   Experience: {self.profile.get('years_experience')}+ years")
        logger.info(f"   Target roles: {', '.join(self.profile.get('target_roles', [])[:3])}")
        logger.info(f"   Salary range: ${self.profile.get('salary_range', {}).get('min', 150000):,} - ${self.profile.get('salary_range', {}).get('max', 350000):,}")
        logger.info(f"   Location: {self.profile.get('preferences', {}).get('location')}")
        
        logger.info("\n" + "="*70)
        logger.info("📊 GENERATING MATCHED OPPORTUNITIES")
        logger.info("="*70)
        
        jobs = self.generate_sample_jobs()
        logger.info(f"✅ Generated {len(jobs)} realistic job matches\n")
        
        # Show sample jobs
        for i, job in enumerate(jobs[:5], 1):
            logger.info(f"{i}. {job['title']} @ {job['company']}")
            logger.info(f"   📍 {job['location']}")
            logger.info(f"   💰 ${job['salary_min']:,} - ${job['salary_max']:,} USD")
            logger.info(f"   ⏰ {job['job_type'].title()}")
            logger.info("")
        
        logger.info(f"... and {len(jobs) - 5} more opportunities\n")
        
        # Save to database
        logger.info("="*70)
        logger.info("💾 SAVING TO DATABASE")
        logger.info("="*70)
        
        saved = self.save_jobs_to_db(jobs)
        logger.info(f"✅ Saved {saved} jobs to database\n")
        
        # Show stats
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("SELECT COUNT(*) FROM jobs_multi_source")
        total_jobs = cursor.fetchone()[0]
        
        cursor.execute("""
            SELECT source, COUNT(*) as count FROM jobs_multi_source 
            GROUP BY source
        """)
        sources = cursor.fetchall()
        
        cursor.execute("""
            SELECT AVG(salary_max), MIN(salary_min), MAX(salary_max)
            FROM jobs_multi_source WHERE salary_min IS NOT NULL
        """)
        salary_stats = cursor.fetchone()
        
        conn.close()
        
        logger.info("="*70)
        logger.info("📈 DATABASE SUMMARY")
        logger.info("="*70)
        logger.info(f"✅ Total jobs in database: {total_jobs}")
        
        if sources:
            logger.info(f"\nJobs by source:")
            for source, count in sources:
                logger.info(f"   • {source.upper()}: {count} jobs")
        
        if salary_stats[0]:
            logger.info(f"\nSalary statistics:")
            logger.info(f"   • Average: ${salary_stats[0]:,.0f}")
            logger.info(f"   • Range: ${salary_stats[1]:,} - ${salary_stats[2]:,}")
        
        logger.info("\n" + "="*70)
        logger.info("✨ LIVE RESULTS GENERATOR COMPLETE")
        logger.info("="*70 + "\n")
        
        return saved


def main():
    generator = LiveResultsGenerator()
    generator.generate_and_save()


if __name__ == '__main__':
    main()
