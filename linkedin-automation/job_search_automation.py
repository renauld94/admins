#!/usr/bin/env python3
"""
LinkedIn Job Search Automation
Find and track job opportunities matching your skills

Searches for:
- Data Engineering roles
- Analytics/ML roles  
- QA/Testing roles (like ADA position)
- Remote positions in target countries

Auto-imports to CRM and matches with existing leads
"""

import os
import json
import asyncio
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional
from dataclasses import dataclass, asdict

from playwright.async_api import async_playwright
from dotenv import load_dotenv

load_dotenv()

# Paths
BASE_DIR = Path(__file__).parent
JOBS_DIR = BASE_DIR / "outputs" / "jobs"
JOBS_DIR.mkdir(parents=True, exist_ok=True)


@dataclass
class JobOpportunity:
    """Job posting from LinkedIn"""
    id: str
    title: str
    company: str
    location: str
    employment_type: str  # 'Full-time', 'Contract', 'Remote'
    seniority_level: str  # 'Mid-Senior', 'Director', 'Executive'
    job_url: str
    posted_date: str
    description: str
    fit_score: int  # 1-10 based on skills match
    key_requirements: List[str]
    remote_eligible: bool
    salary_range: Optional[str]
    applicants: Optional[int]
    easy_apply: bool
    status: str  # 'identified', 'applied', 'screening', 'interview', 'offer', 'rejected'
    notes: str
    found_date: str


class LinkedInJobSearch:
    """Automated job search on LinkedIn"""
    
    # Your key skills for matching
    CORE_SKILLS = [
        "PostgreSQL", "Python", "SQL", "Airflow", "Data Engineering",
        "ETL", "Data Pipelines", "Analytics", "Machine Learning",
        "MLOps", "Docker", "Kubernetes", "CI/CD", "Testing",
        "QA", "Quality Assurance", "Test Automation", "PyTest",
        "AWS", "Azure", "GCP", "Data Warehouse", "Big Data"
    ]
    
    # Target job titles
    TARGET_ROLES = [
        # Data Engineering
        "Data Engineer",
        "Senior Data Engineer",
        "Lead Data Engineer",
        "Principal Data Engineer",
        "Staff Data Engineer",
        
        # Analytics & ML
        "Analytics Engineer",
        "ML Engineer",
        "Machine Learning Engineer",
        "MLOps Engineer",
        "Data Platform Engineer",
        
        # QA/Testing (like ADA position)
        "QA Engineer",
        "Quality Assurance Engineer",
        "QA Manager",
        "Test Engineer",
        "Software Quality Engineer",
        
        # Leadership
        "Head of Data",
        "Director of Data Engineering",
        "VP of Data",
        "Engineering Manager",
    ]
    
    # Target locations
    TARGET_LOCATIONS = [
        "Canada",
        "Toronto, Canada",
        "Vancouver, Canada",
        "Montreal, Canada",
        
        "Singapore",
        
        "Remote",
        "Remote - Canada",
        "Remote - Singapore",
        "Remote - North America",
        "Remote - Asia Pacific",
    ]
    
    def __init__(self):
        self.jobs: Dict[str, JobOpportunity] = {}
        
    async def search_jobs(self, 
                         job_title: str, 
                         location: str,
                         remote_only: bool = False,
                         page=None) -> List[JobOpportunity]:
        """
        Search for jobs on LinkedIn
        
        Args:
            job_title: Job title to search
            location: Location filter
            remote_only: Only return remote positions
            page: Existing browser page (to reuse session)
            
        Returns:
            List of job opportunities
        """
        print(f"🔍 Searching jobs: {job_title} in {location}")
        
        should_close = False
        
        if page is None:
            should_close = True
            async with async_playwright() as p:
                browser = await p.chromium.launch(headless=True)
                page = await browser.new_page()
                
                # Login
                try:
                    await page.goto('https://www.linkedin.com/login', timeout=60000)
                    await page.fill('input#username', os.getenv('LINKEDIN_EMAIL', ''))
                    await page.fill('input#password', os.getenv('LINKEDIN_PASSWORD', ''))
                    await page.click('button[type="submit"]')
                    await page.wait_for_url('https://www.linkedin.com/feed/', timeout=60000)
                except Exception as e:
                    print(f"   ⚠️ Login failed: {e}")
                    if should_close:
                        await browser.close()
                    return []
        
        try:
            # Build search URL
            search_params = {
                'keywords': job_title,
                'location': location,
            }
            
            if remote_only:
                search_params['f_WT'] = '2'  # Remote filter
            
            # Navigate to jobs search
            search_url = 'https://www.linkedin.com/jobs/search/?' + '&'.join(
                f'{k}={v}' for k, v in search_params.items()
            )
            
            await page.goto(search_url, timeout=60000)
            await asyncio.sleep(5)  # Let results load
            
            # Scroll to load more jobs
            for _ in range(3):
                await page.evaluate('window.scrollTo(0, document.body.scrollHeight)')
                await asyncio.sleep(2)
            
            jobs = []
            
            # Extract job cards
            job_cards = await page.query_selector_all('.job-card-container, .jobs-search-results__list-item')
            
            print(f"   Found {len(job_cards)} job cards")
            
            for i, card in enumerate(job_cards[:20]):  # Top 20 jobs
                try:
                    # Extract job details
                    title_elem = await card.query_selector('.job-card-list__title, .job-card-container__link')
                    company_elem = await card.query_selector('.job-card-container__company-name, .artdeco-entity-lockup__subtitle')
                    location_elem = await card.query_selector('.job-card-container__metadata-item, .artdeco-entity-lockup__caption')
                    link_elem = await card.query_selector('a[href*="/jobs/"]')
                    
                    if not title_elem or not company_elem:
                        continue
                    
                    title = (await title_elem.text_content() or "").strip()
                    company = (await company_elem.text_content() or "").strip()
                    loc = (await location_elem.text_content() or location).strip() if location_elem else location
                    job_url = await link_elem.get_attribute('href') if link_elem else ""
                    
                    # Check if remote
                    is_remote = any(term in loc.lower() for term in ['remote', 'anywhere', 'work from home'])
                    
                    if remote_only and not is_remote:
                        continue
                    
                    # Calculate fit score
                    fit_score = self._calculate_job_fit(title, company, loc)
                    
                    # Extract requirements (would need to click into job for full details)
                    requirements = self._extract_requirements(title)
                    
                    job = JobOpportunity(
                        id=f"job_{int(datetime.now().timestamp())}_{i}",
                        title=title,
                        company=company,
                        location=loc,
                        employment_type='Remote' if is_remote else 'On-site',
                        seniority_level=self._extract_seniority(title),
                        job_url=job_url if job_url.startswith('http') else f"https://www.linkedin.com{job_url}",
                        posted_date=datetime.now().isoformat(),
                        description="",  # Would need to visit job page
                        fit_score=fit_score,
                        key_requirements=requirements,
                        remote_eligible=is_remote,
                        salary_range=None,
                        applicants=None,
                        easy_apply=False,  # Would need to check
                        status='identified',
                        notes=f"Found via search: {job_title} in {location}",
                        found_date=datetime.now().isoformat()
                    )
                    
                    jobs.append(job)
                    
                except Exception as e:
                    print(f"   ⚠️ Error parsing job {i}: {e}")
                    continue
            
            print(f"   ✅ Found {len(jobs)} relevant jobs")
            
            # Save jobs
            self._save_jobs(jobs)
            
            return jobs
            
        except Exception as e:
            print(f"   ⚠️ Search failed: {e}")
            return []
        finally:
            if should_close and 'browser' in locals():
                await browser.close()
    
    def _calculate_job_fit(self, title: str, company: str, location: str) -> int:
        """Calculate how well job matches your skills (1-10)"""
        score = 5  # Base score
        
        title_lower = title.lower()
        company_lower = company.lower()
        location_lower = location.lower()
        
        # Senior/Lead roles
        if any(term in title_lower for term in ['senior', 'lead', 'principal', 'staff']):
            score += 2
        elif any(term in title_lower for term in ['director', 'head', 'vp', 'manager']):
            score += 3
        
        # Perfect match roles
        if 'data engineer' in title_lower:
            score += 2
        elif 'qa' in title_lower or 'quality' in title_lower:
            score += 2  # Like ADA position
        elif 'analytics' in title_lower or 'ml' in title_lower:
            score += 1
        
        # Remote bonus
        if 'remote' in location_lower:
            score += 1
        
        # Target location bonus
        if any(loc in location_lower for loc in ['canada', 'singapore']):
            score += 1
        
        # Healthcare/data companies
        if any(term in company_lower for term in ['health', 'medical', 'data', 'analytics']):
            score += 1
        
        return min(score, 10)
    
    def _extract_seniority(self, title: str) -> str:
        """Extract seniority level from title"""
        title_lower = title.lower()
        
        if any(term in title_lower for term in ['director', 'vp', 'head', 'chief']):
            return 'Executive'
        elif any(term in title_lower for term in ['lead', 'principal', 'staff', 'senior manager']):
            return 'Director'
        elif any(term in title_lower for term in ['senior', 'sr.']):
            return 'Mid-Senior'
        else:
            return 'Entry-Mid'
    
    def _extract_requirements(self, title: str) -> List[str]:
        """Extract likely requirements based on title"""
        requirements = []
        title_lower = title.lower()
        
        if 'data engineer' in title_lower:
            requirements = [
                "Python", "SQL", "PostgreSQL", "Airflow",
                "ETL/ELT", "Data Pipelines", "Cloud (AWS/GCP/Azure)"
            ]
        elif 'qa' in title_lower or 'quality' in title_lower:
            requirements = [
                "Test Automation", "Python", "PyTest", "CI/CD",
                "SQL", "API Testing", "Software Engineering"
            ]
        elif 'analytics' in title_lower:
            requirements = [
                "SQL", "Python", "Data Modeling", "BI Tools",
                "Statistics", "Data Visualization"
            ]
        elif 'ml' in title_lower:
            requirements = [
                "Python", "ML Frameworks", "MLOps", "Docker",
                "Model Deployment", "Data Pipelines"
            ]
        
        return requirements
    
    def _save_jobs(self, jobs: List[JobOpportunity]):
        """Save jobs to JSON file"""
        if not jobs:
            return
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = JOBS_DIR / f"jobs_{timestamp}.json"
        
        with open(filename, 'w') as f:
            json.dump([asdict(j) for j in jobs], f, indent=2)
        
        print(f"   💾 Saved to: {filename}")


class BatchJobSearch:
    """Search multiple job titles and locations"""
    
    def __init__(self, remote_only: bool = False):
        self.searcher = LinkedInJobSearch()
        self.remote_only = remote_only
        self.all_jobs: Dict[str, JobOpportunity] = {}
        
    async def run_batch_search(self,
                               roles: List[str] = None,
                               locations: List[str] = None) -> Dict:
        """
        Run batch job searches
        
        Args:
            roles: Job titles to search (defaults to TARGET_ROLES)
            locations: Locations to search (defaults to TARGET_LOCATIONS)
            
        Returns:
            Dictionary with job results
        """
        roles = roles or self.searcher.TARGET_ROLES
        locations = locations or self.searcher.TARGET_LOCATIONS
        
        print("=" * 70)
        print("💼 LINKEDIN JOB SEARCH")
        print("=" * 70)
        print(f"\nSearching {len(roles)} roles across {len(locations)} locations")
        print(f"Remote only: {self.remote_only}\n")
        
        total_searches = len(roles) * len(locations)
        current = 0
        
        for role in roles:
            for location in locations:
                current += 1
                print(f"\n[{current}/{total_searches}] {role} in {location}")
                
                try:
                    jobs = await self.searcher.search_jobs(
                        role, 
                        location, 
                        remote_only=self.remote_only
                    )
                    
                    # Deduplicate
                    new_jobs = 0
                    for job in jobs:
                        if job.job_url not in self.all_jobs:
                            self.all_jobs[job.job_url] = job
                            new_jobs += 1
                    
                    print(f"   New unique jobs: {new_jobs}")
                    print(f"   Total jobs: {len(self.all_jobs)}")
                    
                    # Rate limiting
                    if current < total_searches:
                        print(f"   Waiting 15s...")
                        await asyncio.sleep(15)
                        
                except Exception as e:
                    print(f"   ⚠️ Search failed: {e}")
                    continue
        
        # Generate report
        self._generate_report()
        
        return {
            "jobs": self.all_jobs,
            "total": len(self.all_jobs)
        }
    
    def _generate_report(self):
        """Generate job search report"""
        print("\n" + "=" * 70)
        print("📊 JOB SEARCH RESULTS")
        print("=" * 70)
        
        jobs_list = list(self.all_jobs.values())
        
        # Overall stats
        print(f"\n💼 TOTAL JOBS FOUND: {len(jobs_list)}")
        
        high_fit = [j for j in jobs_list if j.fit_score >= 8]
        remote_jobs = [j for j in jobs_list if j.remote_eligible]
        
        print(f"   High-fit jobs (≥8): {len(high_fit)}")
        print(f"   Remote eligible: {len(remote_jobs)}")
        
        # By location
        from collections import defaultdict
        location_counts = defaultdict(int)
        company_counts = defaultdict(int)
        
        for job in jobs_list:
            location_counts[job.location] += 1
            company_counts[job.company] += 1
        
        print(f"\n🌍 TOP LOCATIONS:")
        for loc, count in sorted(location_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"   {loc}: {count}")
        
        print(f"\n🏢 TOP COMPANIES:")
        for company, count in sorted(company_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"   {company}: {count}")
        
        # Save high-fit jobs
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        all_jobs_file = JOBS_DIR / f"batch_jobs_{timestamp}_all.json"
        with open(all_jobs_file, 'w') as f:
            json.dump([asdict(j) for j in jobs_list], f, indent=2)
        
        high_fit_file = JOBS_DIR / f"batch_jobs_{timestamp}_high_fit.json"
        with open(high_fit_file, 'w') as f:
            json.dump([asdict(j) for j in high_fit], f, indent=2)
        
        print(f"\n💾 FILES SAVED:")
        print(f"   All jobs: {all_jobs_file}")
        print(f"   High-fit jobs: {high_fit_file}")
        
        print(f"\n🎯 TOP OPPORTUNITIES:")
        for job in sorted(high_fit, key=lambda x: x.fit_score, reverse=True)[:10]:
            remote_tag = "🌐 REMOTE" if job.remote_eligible else ""
            print(f"   {job.fit_score}/10 - {job.title} @ {job.company} ({job.location}) {remote_tag}")
        
        # Auto-import to CRM
        print("\n" + "=" * 70)
        print("💾 IMPORTING TO CRM")
        print("=" * 70)
        
        try:
            import subprocess
            result = subprocess.run(
                ["python3", "crm_database.py", "import-jobs", str(all_jobs_file)],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                print(result.stdout)
            else:
                print("⚠️  Auto-import not available. Import manually:")
                print(f"  python3 crm_database.py import-jobs {all_jobs_file}")
                
        except Exception as e:
            print(f"⚠️  Auto-import skipped: {e}")
            print("Jobs saved to files above for manual review")


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Search for job opportunities on LinkedIn")
    parser.add_argument('--remote-only', action='store_true', help='Only search for remote positions')
    parser.add_argument('--roles', nargs='+', help='Specific roles to search')
    parser.add_argument('--locations', nargs='+', help='Specific locations to search')
    parser.add_argument('--quick', action='store_true', help='Quick search (top 5 roles, top 3 locations)')
    
    args = parser.parse_args()
    
    # Setup search
    searcher = BatchJobSearch(remote_only=args.remote_only)
    
    # Determine roles and locations
    if args.quick:
        roles = LinkedInJobSearch.TARGET_ROLES[:5]
        locations = ['Canada', 'Singapore', 'Remote']
    else:
        roles = args.roles or LinkedInJobSearch.TARGET_ROLES
        locations = args.locations or LinkedInJobSearch.TARGET_LOCATIONS
    
    # Run search
    results = asyncio.run(searcher.run_batch_search(roles, locations))
    
    print(f"\n✅ Job search complete! Found {results['total']} opportunities")


if __name__ == "__main__":
    main()
