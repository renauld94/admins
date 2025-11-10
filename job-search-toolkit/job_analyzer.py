#!/usr/bin/env python3
"""
🎯 JOB ANALYZER & REPORTER - Analyze and report on discovered jobs
Scores, ranks, and generates actionable insights
"""

import sqlite3
import json
import logging
from datetime import datetime
from typing import List, Dict, Tuple

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('outputs/logs/job_analyzer.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class JobAnalyzer:
    """Analyze and score discovered jobs"""
    
    def __init__(self, profile_path: str = "config/profile.json"):
        with open(profile_path) as f:
            self.profile = json.load(f)
        self.db_path = "data/job_search.db"
        
    def get_all_jobs(self) -> List[Dict]:
        """Get all jobs from database"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM jobs_multi_source")
        jobs = [dict(row) for row in cursor.fetchall()]
        conn.close()
        
        return jobs
    
    def score_job(self, job: Dict) -> Dict:
        """Score a job based on user profile"""
        score = 0
        reasons = []
        
        # Title match (40 points) - INCREASED from 30
        title_lower = job.get('title', '').lower()
        for role in self.profile.get('target_roles', []):
            if role.lower() in title_lower:
                score += 40
                reasons.append(f"✅ Target role: {role}")
                break
        
        # Company reputation & tier (25 points) - INCREASED from 15
        known_companies = [
            "databricks", "stripe", "anthropic", "figma", "notion",
            "rippling", "segment", "mixpanel", "amplitude", "prisma",
            "canva", "atlassian", "shopify", "gitlab", "hashicorp",
            "scale ai", "corweave", "openai", "wise", "revolut"
        ]
        company = job.get('company', '').lower()
        if any(known in company for known in known_companies):
            score += 25
            reasons.append(f"⭐ Strong company: {job.get('company')}")
        
        # Remote/Location flexibility (20 points)
        location = job.get('location', '').lower()
        if 'remote' in location or job.get('job_type') == 'remote':
            score += 20
            reasons.append("🌍 Remote eligible")
        
        # Job type diversity (10 points)
        job_type = job.get('job_type')
        if job_type and job_type in ['full-time', 'contract']:
            score += 10
            reasons.append(f"📋 {job_type.title()}")
        
        # Salary bonus (only 5 points) - REDUCED from 25, now OPTIONAL
        salary_min = self.profile.get('salary_range', {}).get('min', 150000)
        job_salary_max = job.get('salary_max')
        if job_salary_max and job_salary_max >= salary_min:
            score += 5  # Minimal points - salary is bonus, not primary
            if job_salary_max >= 300000:
                reasons.append(f"💰 Excellent salary: ${job_salary_max:,}")
            elif job_salary_max >= 250000:
                reasons.append(f"💰 Good salary: ${job_salary_max:,}")
        
        return {
            'job_id': job.get('job_id'),
            'title': job.get('title'),
            'company': job.get('company'),
            'location': job.get('location'),
            'salary_max': job.get('salary_max'),
            'source': job.get('source'),
            'url': job.get('url'),
            'score': min(100, score),  # Cap at 100
            'reasons': reasons
        }
        
        return {
            'job_id': job.get('job_id'),
            'title': job.get('title'),
            'company': job.get('company'),
            'location': job.get('location'),
            'salary_max': job.get('salary_max'),
            'source': job.get('source'),
            'url': job.get('url'),
            'score': min(100, score),  # Cap at 100
            'reasons': reasons
        }
    
    def analyze_all_jobs(self) -> List[Dict]:
        """Analyze and score all jobs"""
        logger.info("\n" + "╔" + "="*68 + "╗")
        logger.info("║  📊 JOB ANALYZER - Scoring All Opportunities              ║")
        logger.info("╚" + "="*68 + "╝\n")
        
        jobs = self.get_all_jobs()
        logger.info(f"📥 Found {len(jobs)} jobs in database\n")
        
        scored_jobs = []
        for job in jobs:
            scored = self.score_job(job)
            scored_jobs.append(scored)
        
        # Sort by score
        scored_jobs.sort(key=lambda x: x['score'], reverse=True)
        
        # Display results
        logger.info("="*70)
        logger.info("🎯 TOP JOB MATCHES (Ranked by Score)")
        logger.info("="*70 + "\n")
        
        for i, job in enumerate(scored_jobs[:10], 1):
            logger.info(f"{i}. {job['title']} @ {job['company']}")
            logger.info(f"   Location: {job['location']}")
            if job['salary_max']:
                logger.info(f"   Salary: ${job['salary_max']:,}/year")
            logger.info(f"   🏆 Score: {job['score']}/100")
            for reason in job['reasons']:
                logger.info(f"      {reason}")
            logger.info("")
        
        # Summary stats
        logger.info("="*70)
        logger.info("📈 ANALYSIS SUMMARY")
        logger.info("="*70)
        
        critical = len([j for j in scored_jobs if j['score'] >= 80])
        high = len([j for j in scored_jobs if 60 <= j['score'] < 80])
        medium = len([j for j in scored_jobs if 40 <= j['score'] < 60])
        
        logger.info(f"✅ Total jobs analyzed: {len(jobs)}")
        logger.info(f"🔴 CRITICAL (80+): {critical} jobs")
        logger.info(f"🟠 HIGH (60-79): {high} jobs")
        logger.info(f"🟡 MEDIUM (40-59): {medium} jobs")
        logger.info(f"   Average score: {sum(j['score'] for j in scored_jobs) / len(scored_jobs):.1f}/100")
        
        logger.info("\n" + "="*70)
        logger.info("✨ ANALYSIS COMPLETE - Ready to apply!")
        logger.info("="*70 + "\n")
        
        return scored_jobs
    
    def export_results(self, scored_jobs: List[Dict]) -> str:
        """Export results to file"""
        filename = f"outputs/job_analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        with open(filename, 'w') as f:
            json.dump(scored_jobs, f, indent=2)
        
        logger.info(f"💾 Results exported to: {filename}\n")
        return filename


def main():
    analyzer = JobAnalyzer()
    scored_jobs = analyzer.analyze_all_jobs()
    analyzer.export_results(scored_jobs)


if __name__ == '__main__':
    main()
