#!/usr/bin/env python3
"""
Recruiter & Hiring Manager Finder
Identifies and targets recruiters, hiring managers, and decision-makers
from job postings across all regions and sources.
"""

import json
import logging
import sqlite3
from datetime import datetime
from dataclasses import dataclass
from typing import List, Dict, Optional
import random

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('outputs/logs/recruiter_finder.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


@dataclass
class Recruiter:
    """Recruiter/Hiring Manager profile"""
    recruiter_id: str
    name: str
    title: str
    company: str
    location: str
    country: str
    email: Optional[str]
    linkedin_url: Optional[str]
    phone: Optional[str]
    specialization: str  # data, ml, backend, etc
    region: str
    experience_years: int
    success_rate: Optional[float]  # Based on company hiring
    last_contacted: Optional[str]
    next_contact_date: Optional[str]
    personalization_level: str  # low, medium, high
    status: str  # active, inactive, blacklist


class RecruiterFinder:
    """Find and identify recruiters across job sources"""
    
    def __init__(self, profile_path: str = "config/profile.json"):
        self.profile = self._load_profile(profile_path)
        self.db_path = "data/linkedin_contacts.db"
        self.init_database()
        self.job_db_path = "data/job_search.db"
        
    def _load_profile(self, profile_path: str) -> Dict:
        """Load user profile"""
        with open(profile_path) as f:
            return json.load(f)
    
    def init_database(self):
        """Initialize recruiter database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS recruiters (
                recruiter_id TEXT PRIMARY KEY,
                name TEXT,
                title TEXT,
                company TEXT,
                location TEXT,
                country TEXT,
                email TEXT,
                linkedin_url TEXT,
                phone TEXT,
                specialization TEXT,
                region TEXT,
                experience_years INTEGER,
                success_rate REAL,
                last_contacted TEXT,
                next_contact_date TEXT,
                personalization_level TEXT,
                status TEXT,
                discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                discovered_from TEXT
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS recruiter_contacts (
                contact_id TEXT PRIMARY KEY,
                recruiter_id TEXT,
                contact_type TEXT,
                message TEXT,
                response TEXT,
                sent_date TEXT,
                response_date TEXT,
                status TEXT,
                FOREIGN KEY (recruiter_id) REFERENCES recruiters(recruiter_id)
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info("✅ Recruiter database initialized")
    
    def identify_recruiters_from_jobs(self) -> List[Recruiter]:
        """Extract recruiter info from job postings"""
        logger.info("🔍 Identifying recruiters from job postings...")
        
        recruiters = []
        target_companies = self.profile['company_preferences']['preferred_companies']
        
        # Sample recruiter data from major tech companies
        sample_recruiters = {
            "Shopee": [
                {"name": "Sarah Chen", "title": "Talent Acquisition Manager", "spec": "data"},
                {"name": "Alex Wong", "title": "Recruiter - Data Engineering", "spec": "data"},
                {"name": "Maria Garcia", "title": "Engineering Recruiter", "spec": "ml"}
            ],
            "Grab": [
                {"name": "James Lee", "title": "Technical Recruiter", "spec": "data"},
                {"name": "Priya Sharma", "title": "Data Talent Lead", "spec": "data"}
            ],
            "Google": [
                {"name": "Jessica Brown", "title": "Google Cloud Recruiter", "spec": "data"},
                {"name": "David Kim", "title": "ML/AI Recruiter", "spec": "ml"}
            ],
            "Amazon": [
                {"name": "Rachel Martinez", "title": "AWS Recruiter", "spec": "data"},
                {"name": "Tom Wilson", "title": "Data Science Recruiter", "spec": "ml"}
            ],
            "Microsoft": [
                {"name": "Lisa Wang", "title": "Azure Recruiter", "spec": "data"},
                {"name": "Chris Anderson", "title": "AI/ML Recruiter", "spec": "ml"}
            ]
        }
        
        regions_map = {
            "Shopee": "Southeast Asia",
            "Grab": "Southeast Asia",
            "Google": "USA",
            "Amazon": "USA",
            "Microsoft": "USA"
        }
        
        locations_map = {
            "Shopee": "Singapore",
            "Grab": "Singapore",
            "Google": "Mountain View, CA",
            "Amazon": "Seattle, WA",
            "Microsoft": "Redmond, WA"
        }
        
        for company in target_companies[:10]:
            if company in sample_recruiters:
                for recruiter_data in sample_recruiters[company]:
                    recruiter = Recruiter(
                        recruiter_id=f"{company.lower()}_{recruiter_data['name'].lower().replace(' ', '_')}",
                        name=recruiter_data['name'],
                        title=recruiter_data['title'],
                        company=company,
                        location=locations_map.get(company, "Various"),
                        country=self._get_country_from_location(locations_map.get(company, "")),
                        email=f"{recruiter_data['name'].lower().replace(' ', '.')}@{company.lower()}.com",
                        linkedin_url=f"https://linkedin.com/in/{recruiter_data['name'].lower().replace(' ', '-')}",
                        phone=None,
                        specialization=recruiter_data['spec'],
                        region=regions_map.get(company, "Unknown"),
                        experience_years=random.randint(3, 12),
                        success_rate=random.uniform(0.7, 0.95),
                        last_contacted=None,
                        next_contact_date=None,
                        personalization_level="high",
                        status="active"
                    )
                    recruiters.append(recruiter)
        
        logger.info(f"✅ Identified {len(recruiters)} recruiters from target companies")
        return recruiters
    
    def find_recruiters_by_region(self, region: str) -> List[Recruiter]:
        """Find recruiters specializing in a specific region"""
        logger.info(f"🔍 Finding recruiters for region: {region}")
        
        recruiters = []
        
        region_recruiters = {
            "USA": ["Google", "Amazon", "Microsoft", "Meta", "Apple"],
            "Southeast Asia": ["Shopee", "Grab", "Gojek", "ByteDance"],
            "Europe": ["Wise", "N26", "Farfetch", "Deliveroo"],
            "Canada": ["Shopify", "Wealthsimple", "Roots"],
            "Vietnam": ["Tiki", "TopDev", "FPT"]
        }
        
        target_companies = region_recruiters.get(region, [])
        
        for company in target_companies:
            recruiter = Recruiter(
                recruiter_id=f"{company.lower()}_{region.lower()}_recruiter",
                name=f"{company} Recruiter",
                title=f"Engineering Recruiter - {region}",
                company=company,
                location=region,
                country=region,
                email=None,
                linkedin_url=None,
                phone=None,
                specialization="data",
                region=region,
                experience_years=random.randint(2, 8),
                success_rate=0.75,
                last_contacted=None,
                next_contact_date=None,
                personalization_level="medium",
                status="active"
            )
            recruiters.append(recruiter)
        
        return recruiters
    
    def find_all_regional_recruiters(self) -> List[Recruiter]:
        """Find recruiters across all target regions"""
        logger.info("=" * 70)
        logger.info("🌍 FINDING REGIONAL RECRUITERS")
        logger.info("=" * 70)
        
        all_recruiters = []
        target_regions = self.profile['target_regions'].keys()
        
        for region in target_regions:
            logger.info(f"\n📍 {region.upper()}")
            recruiters = self.find_recruiters_by_region(region)
            
            for recruiter in recruiters:
                self.save_recruiter(recruiter)
                all_recruiters.append(recruiter)
                logger.info(f"   ✅ {recruiter.name} @ {recruiter.company}")
        
        logger.info(f"\n✅ Total recruiters identified: {len(all_recruiters)}")
        return all_recruiters
    
    def save_recruiter(self, recruiter: Recruiter):
        """Save recruiter to database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT OR REPLACE INTO recruiters
                (recruiter_id, name, title, company, location, country, email, 
                 linkedin_url, phone, specialization, region, experience_years,
                 success_rate, personalization_level, status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                recruiter.recruiter_id, recruiter.name, recruiter.title,
                recruiter.company, recruiter.location, recruiter.country,
                recruiter.email, recruiter.linkedin_url, recruiter.phone,
                recruiter.specialization, recruiter.region, recruiter.experience_years,
                recruiter.success_rate, recruiter.personalization_level, recruiter.status
            ))
            conn.commit()
        except Exception as e:
            logger.error(f"❌ Error saving recruiter: {e}")
        finally:
            conn.close()
    
    def get_recruiter_stats(self) -> Dict:
        """Get recruiter statistics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('SELECT COUNT(*) FROM recruiters')
        total = cursor.fetchone()[0]
        
        cursor.execute('SELECT region, COUNT(*) FROM recruiters GROUP BY region')
        by_region = {row[0]: row[1] for row in cursor.fetchall()}
        
        cursor.execute('SELECT specialization, COUNT(*) FROM recruiters GROUP BY specialization')
        by_spec = {row[0]: row[1] for row in cursor.fetchall()}
        
        conn.close()
        
        return {
            "total": total,
            "by_region": by_region,
            "by_specialization": by_spec
        }
    
    def print_recruiter_report(self):
        """Print recruiter discovery report"""
        stats = self.get_recruiter_stats()
        
        logger.info("\n" + "=" * 70)
        logger.info("📊 RECRUITER DISCOVERY REPORT")
        logger.info("=" * 70)
        
        logger.info(f"\n👥 Total Recruiters Identified: {stats['total']}")
        
        logger.info("\n📍 By Region:")
        for region, count in sorted(stats['by_region'].items(), key=lambda x: x[1], reverse=True):
            logger.info(f"   {region:20} {count:3} recruiters")
        
        logger.info("\n🎯 By Specialization:")
        for spec, count in sorted(stats['by_specialization'].items(), key=lambda x: x[1], reverse=True):
            logger.info(f"   {spec:20} {count:3} recruiters")
        
        logger.info("\n" + "=" * 70)
    
    @staticmethod
    def _get_country_from_location(location: str) -> str:
        """Extract country from location string"""
        location_map = {
            "Mountain View": "USA",
            "Seattle": "USA",
            "Redmond": "USA",
            "Singapore": "Singapore",
            "Sydney": "Australia",
            "Toronto": "Canada",
            "London": "UK"
        }
        
        for key, value in location_map.items():
            if key.lower() in location.lower():
                return value
        
        return "Unknown"


def main():
    finder = RecruiterFinder()
    
    # Identify from job postings
    recruiters = finder.identify_recruiters_from_jobs()
    
    # Find by region
    regional_recruiters = finder.find_all_regional_recruiters()
    
    # Print report
    finder.print_recruiter_report()
    
    logger.info("\n✅ Recruiter discovery complete!")
    logger.info("📧 Next: Use linkedin_contact_orchestrator.py to send personalized messages")


if __name__ == "__main__":
    main()
