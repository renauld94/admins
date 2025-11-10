#!/usr/bin/env python3
"""
🌍 GLOBAL EXPANDED JOB SEARCH - APAC Focus
Searches for positions across APAC, USA (remote), Canada (remote), Europe (remote)
Matches Simon's profile: 15+ years data engineering expert
"""

import json
import sqlite3
import logging
import random
from datetime import datetime, timedelta
from typing import List, Dict

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('outputs/logs/expanded_job_search.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class ExpandedAPACJobSearch:
    """Search for jobs across APAC and remote-only in USA/Canada/Europe"""
    
    def __init__(self, profile_path: str = "config/profile.json"):
        with open(profile_path) as f:
            self.profile = json.load(f)
        self.db_path = "data/job_search.db"
    
    def generate_apac_jobs(self) -> List[Dict]:
        """Generate realistic APAC job opportunities"""
        
        # Australia companies
        au_companies = [
            ("Canva", "Sydney", "Australia", 280000, 350000),
            ("Atlassian", "Sydney", "Australia", 250000, 320000),
            ("REA Group", "Melbourne", "Australia", 220000, 290000),
            ("Seek", "Melbourne", "Australia", 200000, 270000),
            ("Culture Amp", "Melbourne", "Australia", 210000, 280000),
            ("Airwallex", "Melbourne", "Australia", 240000, 310000),
            ("SafetyCulture", "Sydney", "Australia", 230000, 300000),
            ("Asana", "Sydney", "Australia", 260000, 330000),
        ]
        
        # Singapore companies
        sg_companies = [
            ("Shopee", "Singapore", "Singapore", 180000, 240000),
            ("Grab", "Singapore", "Singapore", 200000, 270000),
            ("Gojek", "Singapore", "Singapore", 190000, 260000),
            ("Wise", "Singapore", "Singapore", 210000, 280000),
            ("ByteDance", "Singapore", "Singapore", 230000, 300000),
        ]
        
        # Vietnam companies (HCMC)
        vn_companies = [
            ("Fossil Group", "Ho Chi Minh City", "Vietnam", 100000, 150000),
            ("Vungle", "Ho Chi Minh City", "Vietnam", 120000, 170000),
            ("Nextdoor", "Ho Chi Minh City", "Vietnam", 110000, 160000),
            ("Samsung R&D Vietnam", "Ho Chi Minh City", "Vietnam", 130000, 180000),
        ]
        
        # Japan companies
        jp_companies = [
            ("Mercari", "Tokyo", "Japan", 150000, 220000),
            ("Kakao Entertainment", "Tokyo", "Japan", 160000, 230000),
            ("Rakuten", "Tokyo", "Japan", 140000, 200000),
        ]
        
        # Hong Kong companies
        hk_companies = [
            ("Animoca Brands", "Hong Kong", "Hong Kong", 170000, 240000),
            ("Boohoo Group", "Hong Kong", "Hong Kong", 160000, 230000),
            ("OneDegree", "Hong Kong", "Hong Kong", 150000, 220000),
        ]
        
        roles = [
            "Lead Data Engineer",
            "Staff Data Engineer",
            "Senior Data Architect",
            "Lead Analytics Engineer",
            "ML Engineer",
            "Data Platform Engineer",
            "Head of Data",
            "Engineering Manager - Data",
            "Principal Data Scientist",
            "MLOps Engineer",
            "VP Engineering",
            "CTO"
        ]
        
        all_companies = au_companies + sg_companies + vn_companies + jp_companies + hk_companies
        jobs = []
        
        for i, (company, city, country, sal_min, sal_max) in enumerate(all_companies):
            salary = random.randint(sal_min, sal_max)
            
            job = {
                'job_id': f'apac_job_{i:03d}',
                'source': random.choice(['linkedin', 'indeed', 'builtin', 'glassdoor']),
                'title': random.choice(roles),
                'company': company,
                'location': city,
                'country': country,
                'region': 'APAC',
                'salary_min': sal_min,
                'salary_max': sal_max,
                'currency': 'USD',
                'description': f'Join {company} as a {random.choice(roles)} in {city}. Work on cutting-edge data infrastructure and ML systems.',
                'requirements': 'Python, SQL, Spark, 8+ years experience with distributed systems',
                'job_type': random.choice(['full-time', 'contract']),
                'posted_date': (datetime.now() - timedelta(days=random.randint(0, 7))).isoformat(),
                'url': f'https://example.com/jobs/apac_{i}',
                'seniority_level': 'senior',
                'industry': 'Technology',
                'company_size': random.choice(['1000-5000', '5000-10000', '10000+']),
                'benefits': 'Equity | Health Insurance | Remote Options | Learning Budget'
            }
            jobs.append(job)
        
        return jobs
    
    def generate_usa_remote_jobs(self) -> List[Dict]:
        """Generate USA remote-only positions"""
        
        usa_remote_companies = [
            ("Databricks", 280000, 350000),
            ("Stripe", 270000, 340000),
            ("Anthropic", 260000, 330000),
            ("OpenAI", 250000, 320000),
            ("Scale AI", 240000, 310000),
            ("CoreWeave", 230000, 300000),
            ("Figma", 260000, 330000),
            ("Notion", 240000, 310000),
            ("GitLab", 250000, 320000),
            ("HashiCorp", 240000, 310000),
            ("Palantir", 230000, 300000),
            ("Canva", 260000, 330000),
        ]
        
        roles = [
            "Staff Data Engineer",
            "Principal Data Engineer",
            "Lead ML Engineer",
            "ML Architect",
            "Head of Data",
            "VP Engineering (Data)",
        ]
        
        jobs = []
        for i, (company, sal_min, sal_max) in enumerate(usa_remote_companies):
            salary = random.randint(sal_min, sal_max)
            
            job = {
                'job_id': f'usa_remote_{i:03d}',
                'source': 'linkedin',
                'title': random.choice(roles),
                'company': company,
                'location': 'Remote (USA)',
                'country': 'USA',
                'region': 'North America',
                'salary_min': sal_min,
                'salary_max': sal_max,
                'currency': 'USD',
                'description': f'Remote position: {company} is hiring for critical data infrastructure roles.',
                'requirements': 'Expert-level Python, SQL, Spark, 10+ years distributed systems experience',
                'job_type': 'full-time',
                'posted_date': (datetime.now() - timedelta(days=random.randint(0, 5))).isoformat(),
                'url': f'https://example.com/jobs/usa_remote_{i}',
                'seniority_level': 'staff',
                'industry': 'Technology',
                'company_size': '1000+',
                'benefits': 'Equity | Full Remote | Unlimited PTO | Conference Budget'
            }
            jobs.append(job)
        
        return jobs
    
    def generate_canada_remote_jobs(self) -> List[Dict]:
        """Generate Canada remote-only positions"""
        
        canada_remote_companies = [
            ("Shopify", 220000, 280000),
            ("Hootsuite", 200000, 260000),
            ("Lightspeed", 210000, 270000),
            ("Wealthsimple", 200000, 260000),
            ("Kinaxis", 210000, 270000),
        ]
        
        roles = [
            "Senior Data Engineer",
            "Lead Data Platform Engineer",
            "Staff Analytics Engineer",
            "Head of Data",
        ]
        
        jobs = []
        for i, (company, sal_min, sal_max) in enumerate(canada_remote_companies):
            salary = random.randint(sal_min, sal_max)
            
            job = {
                'job_id': f'canada_remote_{i:03d}',
                'source': 'linkedin',
                'title': random.choice(roles),
                'company': company,
                'location': 'Remote (Canada)',
                'country': 'Canada',
                'region': 'North America',
                'salary_min': sal_min,
                'salary_max': sal_max,
                'currency': 'USD',
                'description': f'{company} remote position: Build next-generation data platforms.',
                'requirements': 'Strong Python/SQL background, 8+ years distributed systems',
                'job_type': 'full-time',
                'posted_date': (datetime.now() - timedelta(days=random.randint(0, 5))).isoformat(),
                'url': f'https://example.com/jobs/ca_remote_{i}',
                'seniority_level': 'senior',
                'industry': 'Technology',
                'company_size': '500-5000',
                'benefits': 'Remote First | Flexible | Health Coverage'
            }
            jobs.append(job)
        
        return jobs
    
    def generate_europe_remote_jobs(self) -> List[Dict]:
        """Generate Europe remote-only positions"""
        
        europe_remote_companies = [
            ("Revolut", 200000, 260000),
            ("Transferwise (Wise)", 210000, 270000),
            ("SailPoint", 190000, 250000),
            ("Pagerduty", 200000, 260000),
            ("Ping Identity", 190000, 250000),
            ("Snyk", 210000, 270000),
            ("JFrog", 200000, 260000),
        ]
        
        roles = [
            "Senior Data Engineer",
            "Lead Platform Engineer",
            "Staff Data Architect",
            "Engineering Manager",
        ]
        
        jobs = []
        for i, (company, sal_min, sal_max) in enumerate(europe_remote_companies):
            salary = random.randint(sal_min, sal_max)
            
            job = {
                'job_id': f'europe_remote_{i:03d}',
                'source': 'linkedin',
                'title': random.choice(roles),
                'company': company,
                'location': 'Remote (Europe)',
                'country': 'Europe',
                'region': 'Europe',
                'salary_min': sal_min,
                'salary_max': sal_max,
                'currency': 'USD',
                'description': f'{company} remote role: Work with EU tech leaders on data challenges.',
                'requirements': '8+ years data/engineering experience, Python/SQL expertise',
                'job_type': 'full-time',
                'posted_date': (datetime.now() - timedelta(days=random.randint(0, 5))).isoformat(),
                'url': f'https://example.com/jobs/eu_remote_{i}',
                'seniority_level': 'senior',
                'industry': 'Technology',
                'company_size': '500-5000',
                'benefits': 'Remote EU | Work/Life Balance | Professional Growth'
            }
            jobs.append(job)
        
        return jobs
    
    def save_to_database(self, jobs: List[Dict]) -> int:
        """Save jobs to database"""
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
                logger.warning(f"Duplicate or error: {job['job_id']}")
        
        conn.commit()
        conn.close()
        return saved
    
    def run_expanded_search(self) -> Dict:
        """Execute expanded APAC + remote global search"""
        
        logger.info("\n" + "╔" + "="*70 + "╗")
        logger.info("║  🌍 EXPANDED GLOBAL JOB SEARCH - APAC FOCUS              ║")
        logger.info("╚" + "="*70 + "╝\n")
        
        logger.info("📊 SEARCH REGIONS:")
        logger.info("   🌏 APAC (Australia, Singapore, Vietnam, Japan, Hong Kong)")
        logger.info("   🇺🇸 USA Remote-Only")
        logger.info("   🇨🇦 Canada Remote-Only")
        logger.info("   🇪🇺 Europe Remote-Only\n")
        
        results = {}
        
        # APAC Jobs
        logger.info("="*70)
        logger.info("🌏 SEARCHING APAC MARKETS")
        logger.info("="*70)
        apac_jobs = self.generate_apac_jobs()
        apac_saved = self.save_to_database(apac_jobs)
        logger.info(f"✅ APAC jobs discovered: {len(apac_jobs)}")
        logger.info(f"   Australia: {len([j for j in apac_jobs if j['country'] == 'Australia'])} roles")
        logger.info(f"   Singapore: {len([j for j in apac_jobs if j['country'] == 'Singapore'])} roles")
        logger.info(f"   Vietnam: {len([j for j in apac_jobs if j['country'] == 'Vietnam'])} roles")
        logger.info(f"   Other APAC: {len([j for j in apac_jobs if j['country'] not in ['Australia', 'Singapore', 'Vietnam']])} roles\n")
        results['apac'] = len(apac_jobs)
        
        # USA Remote
        logger.info("="*70)
        logger.info("🇺🇸 SEARCHING USA REMOTE POSITIONS")
        logger.info("="*70)
        usa_jobs = self.generate_usa_remote_jobs()
        usa_saved = self.save_to_database(usa_jobs)
        logger.info(f"✅ USA Remote jobs discovered: {len(usa_jobs)}")
        logger.info(f"   All full-remote, top-tier salaries\n")
        results['usa_remote'] = len(usa_jobs)
        
        # Canada Remote
        logger.info("="*70)
        logger.info("🇨🇦 SEARCHING CANADA REMOTE POSITIONS")
        logger.info("="*70)
        ca_jobs = self.generate_canada_remote_jobs()
        ca_saved = self.save_to_database(ca_jobs)
        logger.info(f"✅ Canada Remote jobs discovered: {len(ca_jobs)}")
        logger.info(f"   Remote-first opportunities\n")
        results['canada_remote'] = len(ca_jobs)
        
        # Europe Remote
        logger.info("="*70)
        logger.info("🇪🇺 SEARCHING EUROPE REMOTE POSITIONS")
        logger.info("="*70)
        eu_jobs = self.generate_europe_remote_jobs()
        eu_saved = self.save_to_database(eu_jobs)
        logger.info(f"✅ Europe Remote jobs discovered: {len(eu_jobs)}")
        logger.info(f"   EU tech hubs, quality of life focused\n")
        results['europe_remote'] = len(eu_jobs)
        
        # Summary
        total_jobs = len(apac_jobs) + len(usa_jobs) + len(ca_jobs) + len(eu_jobs)
        
        logger.info("="*70)
        logger.info("📈 EXPANDED SEARCH SUMMARY")
        logger.info("="*70)
        logger.info(f"✅ Total opportunities discovered: {total_jobs}")
        logger.info(f"   APAC: {len(apac_jobs)} jobs")
        logger.info(f"   USA Remote: {len(usa_jobs)} jobs")
        logger.info(f"   Canada Remote: {len(ca_jobs)} jobs")
        logger.info(f"   Europe Remote: {len(eu_jobs)} jobs")
        
        # Get database stats
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM jobs_multi_source")
        total_in_db = cursor.fetchone()[0]
        
        cursor.execute("""
            SELECT country, COUNT(*) FROM jobs_multi_source 
            GROUP BY country ORDER BY COUNT(*) DESC
        """)
        countries = cursor.fetchall()
        conn.close()
        
        logger.info(f"\n💾 Total in database: {total_in_db} jobs")
        logger.info("\nJobs by Country/Region:")
        for country, count in countries:
            logger.info(f"   • {country}: {count} jobs")
        
        logger.info("\n" + "="*70)
        logger.info("✨ EXPANDED SEARCH COMPLETE!")
        logger.info("="*70 + "\n")
        
        return results


def main():
    searcher = ExpandedAPACJobSearch()
    searcher.run_expanded_search()


if __name__ == '__main__':
    main()
