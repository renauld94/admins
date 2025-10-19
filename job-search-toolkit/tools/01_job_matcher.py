"""
AI-Powered Job Matcher - Intelligent Job Scoring & Recommendation
Author: Simon Renauld
Created: October 17, 2025

Purpose: Intelligently match and score job postings based on:
- Skills alignment (NLP keyword matching)
- Salary fit (target range comparison)
- Location preferences (remote, hybrid, on-site)
- Company culture fit (values, size, industry)
- Career growth potential

Features:
- Multi-source job aggregation (LinkedIn, Indeed, Glassdoor)
- AI-powered relevance scoring (0-100)
- Skill gap analysis
- Automatic priority ranking
- Export to JSON/CSV for application generation

Usage:
    python tools/01_job_matcher.py \\
        --keywords "Lead Data Engineer" \\
        --location "Remote,Ho Chi Minh City" \\
        --min-score 75 \\
        --max-results 50
"""

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Set, Tuple
from collections import Counter

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

try:
    import requests
    from bs4 import BeautifulSoup
    import pandas as pd
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity
    import spacy
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("Install: pip install requests beautifulsoup4 pandas scikit-learn spacy")
    print("Then run: python -m spacy download en_core_web_sm")
    sys.exit(1)


class JobMatcher:
    """AI-powered job matching and scoring engine"""
    
    def __init__(self, profile_path: str = "config/profile.json"):
        """Initialize with user profile"""
        self.profile = self._load_profile(profile_path)
        try:
            self.nlp = spacy.load("en_core_web_sm")
        except OSError:
            print("⚠️  Spacy model not found. Run: python -m spacy download en_core_web_sm")
            self.nlp = None
        
        self.vectorizer = TfidfVectorizer(
            ngram_range=(1, 3),
            stop_words='english',
            max_features=500
        )
    
    def _load_profile(self, profile_path: str) -> Dict:
        """Load user profile configuration"""
        try:
            with open(profile_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"⚠️  Profile not found: {profile_path}")
            print("Creating default profile...")
            return self._create_default_profile(profile_path)
    
    def _create_default_profile(self, profile_path: str) -> Dict:
        """Create default profile template"""
        profile = {
            "name": "Simon Renauld",
            "target_roles": [
                "Lead Data Engineer",
                "Analytics Lead",
                "Head of Data Engineering",
                "Senior Data Architect"
            ],
            "skills": {
                "core": [
                    "Python", "SQL", "PySpark", "Airflow", "Databricks",
                    "ETL/ELT", "Data Warehousing", "Data Pipeline",
                    "PostgreSQL", "Redshift", "Spark"
                ],
                "leadership": [
                    "Team Leadership", "Agile", "Scrum", "Mentoring",
                    "Cross-functional Collaboration", "Stakeholder Management"
                ],
                "cloud": ["AWS", "Azure", "Kubernetes", "Docker"],
                "analytics": ["Power BI", "Tableau", "Data Visualization"],
                "domain": ["Healthcare", "SaaS", "E-commerce"]
            },
            "experience_years": 10,
            "salary_range": {
                "min": 80000,
                "target": 120000,
                "max": 180000,
                "currency": "USD"
            },
            "locations": {
                "preferred": ["Remote", "Ho Chi Minh City"],
                "acceptable": ["Singapore", "Australia", "Remote - Asia Pacific"]
            },
            "company_preferences": {
                "size": ["51-200", "201-500", "500+"],
                "stage": ["Series B+", "Public", "Established"],
                "values": ["Data-driven", "Innovation", "Healthcare Impact"]
            },
            "requirements": {
                "must_have": ["Remote option", "Senior/Lead level", "English"],
                "nice_to_have": ["Healthcare domain", "Startup culture", "Equity"]
            }
        }
        
        # Create config directory if not exists
        os.makedirs(os.path.dirname(profile_path), exist_ok=True)
        with open(profile_path, 'w') as f:
            json.dump(profile, f, indent=2)
        
        print(f"✅ Created profile: {profile_path}")
        return profile
    
    def scrape_jobs(
        self,
        keywords: List[str],
        locations: List[str],
        max_results: int = 50
    ) -> List[Dict]:
        """
        Scrape jobs from multiple sources
        Note: This is a simplified version. For production, use:
        - LinkedIn Job Search API (requires OAuth)
        - Indeed API
        - Glassdoor API
        """
        jobs = []
        
        print(f"🔍 Searching for: {', '.join(keywords)}")
        print(f"📍 Locations: {', '.join(locations)}")
        
        # For demo purposes, create sample jobs
        # In production, integrate with real job boards or APIs
        jobs = self._get_sample_jobs(keywords, locations)
        
        print(f"✅ Found {len(jobs)} job postings")
        return jobs[:max_results]
    
    def _get_sample_jobs(self, keywords: List[str], locations: List[str]) -> List[Dict]:
        """Generate sample jobs for testing (replace with real scraping)"""
        sample_jobs = [
            {
                "id": "JOB001",
                "title": "Lead Data Engineer",
                "company": "Databricks",
                "location": "Remote",
                "salary_min": 140000,
                "salary_max": 180000,
                "description": """
                    We're seeking a Lead Data Engineer to architect and build scalable data pipelines.
                    
                    Requirements:
                    - 8+ years in data engineering
                    - Expert in Python, SQL, PySpark, Airflow
                    - Experience with Databricks, AWS, Kubernetes
                    - Leadership experience managing data engineering teams
                    - Strong communication skills
                    
                    Responsibilities:
                    - Design enterprise ETL/ELT architectures
                    - Lead team of 5-10 data engineers
                    - Implement data governance and quality frameworks
                    - Optimize data pipelines for performance and cost
                """,
                "posted_date": "2025-10-15",
                "url": "https://databricks.com/careers/job001",
                "source": "LinkedIn"
            },
            {
                "id": "JOB002",
                "title": "Head of Analytics Engineering",
                "company": "Grab",
                "location": "Ho Chi Minh City",
                "salary_min": 100000,
                "salary_max": 140000,
                "description": """
                    Lead our analytics engineering function across Southeast Asia.
                    
                    Requirements:
                    - 10+ years in analytics/data engineering
                    - Experience with dbt, Airflow, Snowflake
                    - Team leadership (15+ people)
                    - Stakeholder management at C-level
                    
                    Responsibilities:
                    - Build and lead analytics engineering team
                    - Define metrics strategy and data models
                    - Partner with business stakeholders
                    - Implement self-service analytics platform
                """,
                "posted_date": "2025-10-14",
                "url": "https://grab.com/careers/job002",
                "source": "Company Website"
            },
            {
                "id": "JOB003",
                "title": "Senior Data Platform Engineer",
                "company": "Thoughtworks",
                "location": "Remote - Asia Pacific",
                "salary_min": 90000,
                "salary_max": 130000,
                "description": """
                    Join our data platform team building cutting-edge data infrastructure.
                    
                    Requirements:
                    - 6+ years in data platform/infrastructure
                    - Kubernetes, Docker, Terraform
                    - Apache Spark, Kafka, Flink
                    - Python, Scala, SQL
                    
                    Responsibilities:
                    - Design cloud-native data platforms
                    - Implement CI/CD for data pipelines
                    - Mentor junior engineers
                    - Drive technical excellence
                """,
                "posted_date": "2025-10-13",
                "url": "https://thoughtworks.com/careers/job003",
                "source": "Indeed"
            }
        ]
        
        return sample_jobs
    
    def score_job(self, job: Dict) -> Tuple[float, Dict]:
        """
        Score job based on profile fit
        Returns: (score, breakdown)
        """
        breakdown = {}
        
        # 1. Skills match (40%)
        skills_score = self._score_skills(job)
        breakdown['skills'] = skills_score
        
        # 2. Salary fit (20%)
        salary_score = self._score_salary(job)
        breakdown['salary'] = salary_score
        
        # 3. Location fit (15%)
        location_score = self._score_location(job)
        breakdown['location'] = location_score
        
        # 4. Title relevance (15%)
        title_score = self._score_title(job)
        breakdown['title'] = title_score
        
        # 5. Company fit (10%)
        company_score = self._score_company(job)
        breakdown['company'] = company_score
        
        # Weighted average
        total_score = (
            skills_score * 0.40 +
            salary_score * 0.20 +
            location_score * 0.15 +
            title_score * 0.15 +
            company_score * 0.10
        )
        
        breakdown['total'] = round(total_score, 1)
        
        return total_score, breakdown
    
    def _score_skills(self, job: Dict) -> float:
        """Score based on skills match"""
        job_text = f"{job.get('title', '')} {job.get('description', '')}".lower()
        
        all_skills = []
        for skill_category in self.profile['skills'].values():
            all_skills.extend([s.lower() for s in skill_category])
        
        matched_skills = [skill for skill in all_skills if skill in job_text]
        
        if not all_skills:
            return 50.0
        
        match_ratio = len(matched_skills) / len(all_skills)
        return min(match_ratio * 100, 100)
    
    def _score_salary(self, job: Dict) -> float:
        """Score based on salary fit"""
        salary_min = job.get('salary_min', 0)
        salary_max = job.get('salary_max', 0)
        
        if not salary_min and not salary_max:
            return 50.0  # Unknown salary
        
        target = self.profile['salary_range']['target']
        min_acceptable = self.profile['salary_range']['min']
        
        # Check if job salary range overlaps with target
        if salary_max >= target:
            return 100.0
        elif salary_max >= min_acceptable:
            return 70.0
        else:
            return 30.0
    
    def _score_location(self, job: Dict) -> float:
        """Score based on location preference"""
        job_location = job.get('location', '').lower()
        
        preferred = [loc.lower() for loc in self.profile['locations']['preferred']]
        acceptable = [loc.lower() for loc in self.profile['locations']['acceptable']]
        
        for pref_loc in preferred:
            if pref_loc in job_location:
                return 100.0
        
        for acc_loc in acceptable:
            if acc_loc in job_location:
                return 70.0
        
        return 30.0
    
    def _score_title(self, job: Dict) -> float:
        """Score based on title relevance"""
        job_title = job.get('title', '').lower()
        
        target_roles = [role.lower() for role in self.profile['target_roles']]
        
        for target in target_roles:
            if target in job_title:
                return 100.0
        
        # Check for partial matches (e.g., "Data Engineer" in "Senior Data Engineer")
        title_words = set(job_title.split())
        for target in target_roles:
            target_words = set(target.split())
            if len(title_words & target_words) >= 2:
                return 70.0
        
        return 30.0
    
    def _score_company(self, job: Dict) -> float:
        """Score based on company preferences"""
        # Placeholder - in production, integrate with:
        # - Crunchbase API for company data
        # - Glassdoor API for reviews
        # - LinkedIn Company API
        return 70.0
    
    def analyze_skill_gap(self, job: Dict) -> Dict:
        """Analyze skill gaps for a job"""
        job_text = f"{job.get('title', '')} {job.get('description', '')}".lower()
        
        all_your_skills = []
        for skill_category in self.profile['skills'].values():
            all_your_skills.extend([s.lower() for s in skill_category])
        
        # Extract skills mentioned in job
        job_skills = set()
        for word in job_text.split():
            if len(word) > 2:  # Skip short words
                job_skills.add(word)
        
        # Find matches and gaps
        matched = [skill for skill in all_your_skills if skill in job_text]
        
        # Missing skills (simple heuristic - in production use NLP)
        common_skills = [
            'python', 'sql', 'spark', 'airflow', 'kubernetes', 'docker',
            'aws', 'azure', 'databricks', 'snowflake', 'dbt', 'kafka'
        ]
        
        missing = []
        for skill in common_skills:
            if skill in job_text and skill not in [s.lower() for s in matched]:
                missing.append(skill)
        
        return {
            "matched": matched,
            "missing": missing,
            "match_percentage": round(len(matched) / len(all_your_skills) * 100, 1) if all_your_skills else 0
        }
    
    def export_results(
        self,
        scored_jobs: List[Dict],
        output_dir: str = "outputs"
    ):
        """Export scored jobs to JSON and CSV"""
        os.makedirs(output_dir, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # JSON
        json_path = os.path.join(output_dir, f"matched_jobs_{timestamp}.json")
        with open(json_path, 'w') as f:
            json.dump(scored_jobs, f, indent=2)
        
        # CSV
        csv_path = os.path.join(output_dir, f"matched_jobs_{timestamp}.csv")
        df = pd.DataFrame([
            {
                'job_id': job['id'],
                'title': job['title'],
                'company': job['company'],
                'location': job['location'],
                'score': job['score']['total'],
                'skills_score': job['score']['skills'],
                'salary_score': job['score']['salary'],
                'url': job['url']
            }
            for job in scored_jobs
        ])
        df.to_csv(csv_path, index=False)
        
        print(f"\n✅ Results exported:")
        print(f"JSON: {json_path}")
        print(f"CSV: {csv_path}")
        
        return json_path, csv_path


def main():
    parser = argparse.ArgumentParser(description="AI-Powered Job Matcher")
    parser.add_argument("--keywords", default="Lead Data Engineer,Analytics Lead", help="Comma-separated job keywords")
    parser.add_argument("--location", default="Remote", help="Comma-separated locations")
    parser.add_argument("--min-score", type=float, default=70.0, help="Minimum match score (0-100)")
    parser.add_argument("--max-results", type=int, default=50, help="Maximum jobs to return")
    parser.add_argument("--output", default="outputs", help="Output directory")
    
    args = parser.parse_args()
    
    # Initialize matcher
    matcher = JobMatcher()
    
    # Parse inputs
    keywords = [k.strip() for k in args.keywords.split(',')]
    locations = [l.strip() for l in args.location.split(',')]
    
    # Scrape jobs
    print(f"\n{'='*60}")
    print(f"🎯 JOB MATCHER - AI-Powered Job Search")
    print(f"{'='*60}\n")
    
    jobs = matcher.scrape_jobs(keywords, locations, args.max_results)
    
    # Score jobs
    print(f"\n⚙️  Scoring {len(jobs)} jobs...")
    scored_jobs = []
    
    for job in jobs:
        score, breakdown = matcher.score_job(job)
        skill_gap = matcher.analyze_skill_gap(job)
        
        scored_jobs.append({
            **job,
            'score': breakdown,
            'skill_gap': skill_gap
        })
    
    # Filter by min score
    scored_jobs = [job for job in scored_jobs if job['score']['total'] >= args.min_score]
    
    # Sort by score
    scored_jobs.sort(key=lambda x: x['score']['total'], reverse=True)
    
    # Display results
    print(f"\n{'='*60}")
    print(f"📊 RESULTS: {len(scored_jobs)} jobs matched (score >= {args.min_score})")
    print(f"{'='*60}\n")
    
    for i, job in enumerate(scored_jobs[:10], 1):
        print(f"{i}. {job['title']} @ {job['company']}")
        print(f"   Score: {job['score']['total']}/100")
        print(f"   Location: {job['location']}")
        print(f"   Skills Match: {job['skill_gap']['match_percentage']}%")
        print(f"   URL: {job['url']}")
        print()
    
    # Export
    matcher.export_results(scored_jobs, args.output)
    
    print(f"\n✨ Job matching complete!")
    print(f"Top recommendation: {scored_jobs[0]['title']} @ {scored_jobs[0]['company']}")
    print(f"Score: {scored_jobs[0]['score']['total']}/100\n")


if __name__ == "__main__":
    main()
