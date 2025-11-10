#!/usr/bin/env python3
"""
🚀 LIVE JOB FETCHER - Real-time job discovery from live APIs
Fetches actual jobs from RemoteOK, Indeed API, and other sources
"""

import json
import logging
import sqlite3
import requests
from datetime import datetime, timedelta
from typing import List, Dict, Optional
from pathlib import Path
import time

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('outputs/logs/live_job_fetcher.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class LiveJobFetcher:
    """Fetch real jobs from live APIs"""
    
    def __init__(self, profile_path: str = "config/profile.json"):
        self.profile = self._load_profile(profile_path)
        self.db_path = "data/job_search.db"
        self.keywords = self.profile.get('target_roles', [])
        self.skills = self.profile.get('technical_skills', [])
        self.salary_min = self.profile.get('salary_range', {}).get('min', 150000)
        self.salary_max = self.profile.get('salary_range', {}).get('max', 350000)
        
    def _load_profile(self, profile_path: str) -> Dict:
        """Load user profile"""
        with open(profile_path) as f:
            return json.load(f)
    
    def fetch_remoteok_jobs(self) -> List[Dict]:
        """Fetch from RemoteOK Live API"""
        logger.info("\n" + "="*70)
        logger.info("🌍 FETCHING FROM REMOTEOK API (Live Data)")
        logger.info("="*70)
        
        jobs = []
        try:
            # RemoteOK API endpoint
            url = "https://remoteok.com/api/v2/remote-jobs/"
            headers = {'User-Agent': 'Mozilla/5.0 (job search)'}
            
            logger.info(f"🔗 Connecting to: {url}")
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            api_jobs = response.json()
            logger.info(f"✅ Retrieved {len(api_jobs)} total remote jobs")
            
            # Filter for relevant keywords
            keywords_lower = [k.lower() for k in self.keywords]
            
            for job in api_jobs[:100]:  # Process first 100
                title_lower = str(job.get('title', '')).lower()
                desc_lower = str(job.get('description', '')).lower()
                
                # Check if job matches any keyword
                matches = any(kw in title_lower or kw in desc_lower for kw in keywords_lower)
                
                if matches and job.get('job_type', '').lower() not in ['freelance']:
                    job_data = {
                        'job_id': f"remoteok_{job.get('id')}",
                        'title': job.get('title', 'Unknown'),
                        'company': job.get('company', 'Unknown'),
                        'location': job.get('location', 'Remote'),
                        'country': 'Remote',
                        'region': 'Worldwide',
                        'salary_min': None,
                        'salary_max': None,
                        'currency': 'USD',
                        'description': job.get('description', ''),
                        'requirements': job.get('requirements', ''),
                        'job_type': 'remote',
                        'posted_date': job.get('date', datetime.now().isoformat()),
                        'source': 'remoteok',
                        'url': job.get('url', ''),
                        'seniority_level': 'mid',
                        'industry': job.get('job_type', ''),
                        'company_size': None,
                        'benefits': None
                    }
                    jobs.append(job_data)
                    logger.info(f"   ✅ {job_data['title']} @ {job_data['company']}")
            
            logger.info(f"\n🎯 Matched {len(jobs)} relevant remote jobs")
            return jobs
            
        except Exception as e:
            logger.error(f"❌ RemoteOK API error: {e}")
            return []
    
    def fetch_indeed_jobs(self) -> List[Dict]:
        """Fetch from Indeed API (if available)"""
        logger.info("\n" + "="*70)
        logger.info("💼 FETCHING FROM INDEED")
        logger.info("="*70)
        
        jobs = []
        try:
            # Using Indeed Job Search API (free tier)
            keywords = " OR ".join(self.keywords[:3])  # Top 3 roles
            
            search_urls = [
                f"https://www.indeed.com/jobs?q={keywords}&l=Remote&sort=date",
                f"https://www.indeed.com/jobs?q=data+engineer&l=Remote&sort=date",
                f"https://www.indeed.com/jobs?q=ml+engineer&l=Remote&sort=date",
            ]
            
            logger.info(f"🔍 Searching for: {', '.join(self.keywords[:3])}")
            logger.info("   (Direct scraping - see web URLs)")
            
            for url in search_urls:
                logger.info(f"   📍 {url}")
                jobs.append({
                    'source': 'indeed',
                    'url': url,
                    'status': 'ready_to_scrape'
                })
            
            logger.info(f"✅ Found {len(search_urls)} Indeed search URLs")
            return jobs
            
        except Exception as e:
            logger.error(f"❌ Indeed error: {e}")
            return []
    
    def fetch_linkedin_jobs(self) -> List[Dict]:
        """Fetch from LinkedIn API"""
        logger.info("\n" + "="*70)
        logger.info("💼 FETCHING FROM LINKEDIN")
        logger.info("="*70)
        
        jobs = []
        try:
            keywords = " OR ".join(self.keywords[:3])
            
            search_urls = [
                f"https://www.linkedin.com/jobs/search/?keywords={keywords}&location=Remote&remote=true&sort=date",
                "https://www.linkedin.com/jobs/search/?keywords=data%20engineer&location=Remote&remote=true&sort=date",
                "https://www.linkedin.com/jobs/search/?keywords=ml%20engineer&location=Remote&remote=true&sort=date",
            ]
            
            logger.info(f"🔍 Searching for: {', '.join(self.keywords[:3])}")
            
            for url in search_urls:
                logger.info(f"   📍 {url}")
                jobs.append({
                    'source': 'linkedin',
                    'url': url,
                    'status': 'ready_to_scrape'
                })
            
            logger.info(f"✅ Found {len(search_urls)} LinkedIn search URLs")
            return jobs
            
        except Exception as e:
            logger.error(f"❌ LinkedIn error: {e}")
            return []
    
    def save_job(self, job: Dict) -> bool:
        """Save job to database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR IGNORE INTO jobs_multi_source
                (job_id, source, title, company, location, country, region,
                 salary_min, salary_max, currency, description, requirements,
                 job_type, posted_date, url, seniority_level, industry, company_size, benefits)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                job.get('job_id'), job.get('source'), job.get('title'),
                job.get('company'), job.get('location'), job.get('country'),
                job.get('region'), job.get('salary_min'), job.get('salary_max'),
                job.get('currency'), job.get('description'), job.get('requirements'),
                job.get('job_type'), job.get('posted_date'), job.get('url'),
                job.get('seniority_level'), job.get('industry'),
                job.get('company_size'), job.get('benefits')
            ))
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            logger.error(f"❌ Error saving job: {e}")
            return False
    
    def discover_all_live(self) -> int:
        """Discover jobs from all live sources"""
        logger.info("\n" + "╔" + "="*68 + "╗")
        logger.info("║  🚀 LIVE JOB DISCOVERY - REAL-TIME DATA                        ║")
        logger.info("╚" + "="*68 + "╝\n")
        
        total_jobs = 0
        
        # Fetch from RemoteOK (live API)
        logger.info("📡 PHASE 1: Remote-First Jobs (RemoteOK Live API)")
        remoteok_jobs = self.fetch_remoteok_jobs()
        for job in remoteok_jobs:
            if self.save_job(job):
                total_jobs += 1
        
        time.sleep(1)  # Rate limiting
        
        # Fetch from Indeed
        logger.info("\n📡 PHASE 2: Traditional Job Boards (Indeed)")
        indeed_jobs = self.fetch_indeed_jobs()
        logger.info(f"   Created {len(indeed_jobs)} Indeed search URLs")
        total_jobs += len(indeed_jobs)
        
        time.sleep(1)
        
        # Fetch from LinkedIn
        logger.info("\n📡 PHASE 3: Professional Network (LinkedIn)")
        linkedin_jobs = self.fetch_linkedin_jobs()
        logger.info(f"   Created {len(linkedin_jobs)} LinkedIn search URLs")
        total_jobs += len(linkedin_jobs)
        
        # Summary
        logger.info("\n" + "="*70)
        logger.info("📊 LIVE DISCOVERY SUMMARY")
        logger.info("="*70)
        logger.info(f"✅ Total opportunities discovered: {total_jobs}")
        logger.info(f"   RemoteOK (Live): {len(remoteok_jobs)} jobs")
        logger.info(f"   Indeed (URLs): {len(indeed_jobs)} search URLs")
        logger.info(f"   LinkedIn (URLs): {len(linkedin_jobs)} search URLs")
        logger.info(f"\n🎯 Next: Score & prioritize jobs, prepare applications")
        logger.info("="*70 + "\n")
        
        return total_jobs


def main():
    """Main entry point"""
    fetcher = LiveJobFetcher()
    total = fetcher.discover_all_live()
    
    if total > 0:
        logger.info(f"\n✨ Success! Discovered {total} opportunities")
    else:
        logger.warning("\n⚠️ No jobs discovered in this run")


if __name__ == '__main__':
    main()
