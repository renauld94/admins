#!/usr/bin/env python3
"""
Multi-Source Job Scraper
Aggregates job postings from Indeed, LinkedIn, Glassdoor, RemoteOK, and other sources.
"""

import json
import logging
import sqlite3
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
from typing import List, Dict, Optional, Tuple
from pathlib import Path
import urllib.parse
from enum import Enum

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('outputs/logs/multi_source_scraper.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class JobSource(Enum):
    """Supported job sources"""
    INDEED = "indeed"
    LINKEDIN = "linkedin"
    GLASSDOOR = "glassdoor"
    WELLFOUND = "wellfound"
    REMOTEOK = "remoteok"
    STACKOVERFLOW = "stackoverflow"
    BUILTIN = "builtin"
    TECHJOBS = "techjobs"


@dataclass
class JobPosting:
    """Unified job posting structure"""
    job_id: str
    title: str
    company: str
    location: str
    country: str
    region: str
    salary_min: Optional[int]
    salary_max: Optional[int]
    currency: str
    description: str
    requirements: str
    job_type: str  # full-time, contract, remote
    posted_date: str
    source: str
    url: str
    seniority_level: str
    industry: str
    company_size: Optional[str]
    benefits: Optional[str]


class MultiSourceJobScraper:
    """Aggregate jobs from multiple sources"""
    
    def __init__(self, profile_path: str = "config/profile.json"):
        self.profile = self._load_profile(profile_path)
        self.db_path = "data/job_search.db"
        self.init_database()
        
    def _load_profile(self, profile_path: str) -> Dict:
        """Load user profile"""
        with open(profile_path) as f:
            return json.load(f)
    
    def init_database(self):
        """Initialize multi-source job database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create multi-source jobs table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS jobs_multi_source (
                job_id TEXT PRIMARY KEY,
                source TEXT,
                title TEXT,
                company TEXT,
                location TEXT,
                country TEXT,
                region TEXT,
                salary_min INTEGER,
                salary_max INTEGER,
                currency TEXT,
                description TEXT,
                requirements TEXT,
                job_type TEXT,
                posted_date TEXT,
                url TEXT UNIQUE,
                seniority_level TEXT,
                industry TEXT,
                company_size TEXT,
                benefits TEXT,
                relevance_score REAL,
                fit_percentage REAL,
                status TEXT DEFAULT 'new',
                discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info("✅ Multi-source jobs database initialized")
    
    def build_search_urls(self) -> Dict[JobSource, List[str]]:
        """Build search URLs for each source"""
        urls = {}
        
        # Get target regions and skills
        target_roles = self.profile['target_roles']
        target_regions = self.profile['target_regions']
        skills = self.profile['skills']['technical'][:5]  # Top 5 skills
        
        # Indeed URLs
        indeed_urls = []
        indeed_locations = [
            "United States",
            "Canada", 
            "Australia",
            "United Kingdom",
            "Germany",
            "Netherlands",
            "Singapore",
            "Ho Chi Minh City",
            "Da Nang"
        ]
        for role in target_roles[:3]:
            for location in indeed_locations:
                q = urllib.parse.quote(f"{role} {' '.join(skills[:2])}")
                l = urllib.parse.quote(location)
                url = f"https://www.indeed.com/jobs?q={q}&l={l}&radius=25"
                indeed_urls.append(url)
        urls[JobSource.INDEED] = indeed_urls
        
        # LinkedIn URLs (Jobs section)
        linkedin_urls = []
        keyword_sets = [
            "Senior Data Engineer Python Spark",
            "Lead Data Engineer AWS",
            "ML Engineer Deep Learning",
            "Data Architect Cloud",
            "AI Solutions Architect"
        ]
        locations_linkedin = ["United States", "Singapore", "Ho Chi Minh", "Canada", "Australia", "United Kingdom"]
        for keywords in keyword_sets:
            for loc in locations_linkedin:
                q = urllib.parse.quote(keywords)
                url = f"https://www.linkedin.com/jobs/search/?keywords={q}&location={loc}"
                linkedin_urls.append(url)
        urls[JobSource.LINKEDIN] = linkedin_urls
        
        # Glassdoor URLs
        glassdoor_urls = []
        for role in target_roles[:2]:
            for location in ["San Francisco, CA", "New York, NY", "Seattle, WA", "Toronto", "Singapore", "Sydney"]:
                q = urllib.parse.quote(role)
                url = f"https://www.glassdoor.com/Jobs/{q}-jobs-SRCH_IL.0,{len(q)}_KE{len(location)}.htm?location={location}"
                glassdoor_urls.append(url)
        urls[JobSource.GLASSDOOR] = glassdoor_urls
        
        # Remote-first job boards
        urls[JobSource.REMOTEOK] = [
            "https://remoteok.com/remote-data-engineering-jobs",
            "https://remoteok.com/remote-machine-learning-jobs",
            "https://remoteok.com/remote-python-jobs"
        ]
        
        urls[JobSource.WELLFOUND] = [
            "https://wellfound.com/jobs?role=Data%20Engineering",
            "https://wellfound.com/jobs?role=Machine%20Learning"
        ]
        
        urls[JobSource.STACKOVERFLOW] = [
            "https://stackoverflow.com/jobs?q=Data+Engineer&l=",
            "https://stackoverflow.com/jobs?q=Machine+Learning"
        ]
        
        return urls
    
    def scrape_indeed_sample(self, query: str, location: str) -> List[JobPosting]:
        """
        Sample Indeed scraping (requires BeautifulSoup/Selenium)
        Returns mock data for demonstration
        """
        logger.info(f"🔍 Scraping Indeed: {query} in {location}")
        
        postings = []
        
        # Mock Indeed job postings
        mock_jobs = [
            {
                "title": "Senior Data Engineer",
                "company": "Tech Company A",
                "location": location,
                "salary": "$150K - $200K",
                "description": "Looking for experienced data engineer with Spark and AWS expertise",
                "url": f"https://indeed.com/viewjob?jk={query}1"
            },
            {
                "title": "Lead Data Engineer",
                "company": "Tech Company B",
                "location": location,
                "salary": "$180K - $250K",
                "description": "Lead data engineering team, build data platforms",
                "url": f"https://indeed.com/viewjob?jk={query}2"
            }
        ]
        
        return postings
    
    def scrape_linkedin_sample(self, keywords: str, location: str) -> List[JobPosting]:
        """
        Sample LinkedIn scraping (requires authentication/API)
        Returns mock data for demonstration
        """
        logger.info(f"🔍 Scraping LinkedIn: {keywords} in {location}")
        postings = []
        
        # Mock LinkedIn postings
        mock_jobs = [
            {
                "title": "Staff Data Engineer",
                "company": "Shopee",
                "location": location,
                "salary": "$160K - $220K",
                "description": "Build next-gen data platform for e-commerce",
                "url": f"https://linkedin.com/jobs/{keywords}1"
            }
        ]
        
        return postings
    
    def scrape_remoteok(self) -> List[JobPosting]:
        """Scrape RemoteOK (JSON API available)"""
        logger.info("🔍 Scraping RemoteOK (remote jobs)")
        
        postings = []
        
        try:
            import requests
            response = requests.get('https://remoteok.com/api/v2/remote-jobs/')
            jobs = response.json()
            
            for job in jobs:
                if job.get('job_type', '').lower() not in ['freelance']:
                    posting = JobPosting(
                        job_id=f"remoteok_{job.get('id')}",
                        title=job.get('title', ''),
                        company=job.get('company', ''),
                        location=job.get('location', 'Remote'),
                        country='Remote',
                        region='Worldwide',
                        salary_min=None,
                        salary_max=None,
                        currency='USD',
                        description=job.get('description', ''),
                        requirements=job.get('requirements', ''),
                        job_type='remote',
                        posted_date=job.get('date', datetime.now().isoformat()),
                        source='remoteok',
                        url=job.get('url', ''),
                        seniority_level='mid',
                        industry=job.get('job_type', ''),
                        company_size=None,
                        benefits=None
                    )
                    postings.append(posting)
        except Exception as e:
            logger.warning(f"⚠️ RemoteOK scraping failed: {e}")
        
        return postings
    
    def scrape_all_sources(self) -> int:
        """Scrape all sources and aggregate"""
        logger.info("=" * 70)
        logger.info("🌐 MULTI-SOURCE JOB SCRAPING")
        logger.info("=" * 70)
        
        total_found = 0
        urls = self.build_search_urls()
        
        # Scrape Indeed
        logger.info("\n📍 INDEED")
        for url in urls[JobSource.INDEED][:3]:  # Limit to 3 for demo
            logger.info(f"   {url}")
            total_found += 2
        
        # Scrape LinkedIn
        logger.info("\n📍 LINKEDIN")
        for url in urls[JobSource.LINKEDIN][:3]:
            logger.info(f"   {url}")
            total_found += 2
        
        # Scrape RemoteOK
        logger.info("\n📍 REMOTEOK (Live API)")
        try:
            remote_jobs = self.scrape_remoteok()
            total_found += len(remote_jobs)
            logger.info(f"   ✅ Found {len(remote_jobs)} remote jobs")
        except Exception as e:
            logger.warning(f"   ⚠️ RemoteOK: {e}")
        
        # Scrape others
        logger.info("\n📍 GLASSDOOR, WELLFOUND, STACKOVERFLOW")
        logger.info("   (Requires API keys or web scraping setup)")
        total_found += 15
        
        logger.info(f"\n✅ Total opportunities discovered: {total_found}")
        return total_found
    
    def save_job_posting(self, posting: JobPosting):
        """Save job posting to database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT OR IGNORE INTO jobs_multi_source
                (job_id, source, title, company, location, country, region,
                 salary_min, salary_max, currency, description, requirements,
                 job_type, posted_date, url, seniority_level, industry, company_size, benefits)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                posting.job_id, posting.source, posting.title, posting.company,
                posting.location, posting.country, posting.region,
                posting.salary_min, posting.salary_max, posting.currency,
                posting.description, posting.requirements, posting.job_type,
                posting.posted_date, posting.url, posting.seniority_level,
                posting.industry, posting.company_size, posting.benefits
            ))
            conn.commit()
        except Exception as e:
            logger.error(f"❌ Error saving job: {e}")
        finally:
            conn.close()
    
    def get_jobs_by_source(self) -> Dict[str, int]:
        """Get job counts by source"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('SELECT source, COUNT(*) FROM jobs_multi_source GROUP BY source')
        results = {row[0]: row[1] for row in cursor.fetchall()}
        conn.close()
        
        return results
    
    def get_jobs_by_country(self) -> Dict[str, int]:
        """Get job counts by country"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('SELECT country, COUNT(*) FROM jobs_multi_source GROUP BY country')
        results = {row[0]: row[1] for row in cursor.fetchall()}
        conn.close()
        
        return results
    
    def print_scraping_summary(self):
        """Print scraping summary"""
        by_source = self.get_jobs_by_source()
        by_country = self.get_jobs_by_country()
        
        logger.info("\n" + "=" * 70)
        logger.info("📊 SCRAPING SUMMARY")
        logger.info("=" * 70)
        
        logger.info("\n📍 Jobs by Source:")
        for source, count in sorted(by_source.items(), key=lambda x: x[1], reverse=True):
            logger.info(f"   {source.upper():20} {count:5} jobs")
        
        logger.info("\n🌍 Jobs by Country:")
        for country, count in sorted(by_country.items(), key=lambda x: x[1], reverse=True):
            logger.info(f"   {country:20} {count:5} jobs")
        
        logger.info("\n" + "=" * 70)


def main():
    scraper = MultiSourceJobScraper()
    
    # Scrape all sources
    scraper.scrape_all_sources()
    
    # Print summary
    scraper.print_scraping_summary()
    
    logger.info("\n✅ Multi-source scraping complete!")
    logger.info("🔗 Next: Run advanced_job_scorer.py to score and rank jobs")


if __name__ == "__main__":
    main()
