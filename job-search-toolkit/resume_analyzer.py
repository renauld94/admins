#!/usr/bin/env python3
"""
Resume Analyzer - Match Your Resume to Job Opportunities
Analyzes your resume and finds the best-fit jobs across all sources and regions
"""

import json
import logging
import sqlite3
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('outputs/logs/resume_analyzer.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


@dataclass
class ResumeProfile:
    """Parsed resume profile"""
    name: str
    email: str
    phone: str
    headline: str
    years_experience: int
    skills: List[str]
    companies: List[str]
    roles: List[str]
    achievements: List[str]
    certifications: List[str]
    education: List[str]


class ResumeAnalyzer:
    """Analyze resume and match to jobs"""
    
    def __init__(self, profile_path: str = "config/profile.json", resume_path: Optional[str] = None):
        self.profile = self._load_profile(profile_path)
        self.resume_path = resume_path or self._find_resume()
        self.resume_text = self._read_resume()
        self.db_path = "data/job_search.db"
        
    def _load_profile(self, profile_path: str) -> Dict:
        """Load user profile"""
        with open(profile_path) as f:
            return json.load(f)
    
    def _find_resume(self) -> Optional[str]:
        """Find resume file"""
        possible_paths = [
            Path("resumes") / "Simon_Renauld_Resume_Director_AI_Analytics.md",
            Path("resumes") / "resume.md",
            Path("resumes") / "resume.pdf",
            Path("resumes") / "resume.txt",
            Path("resume.pdf"),
            Path("resume.md"),
        ]
        
        for path in possible_paths:
            if path.exists():
                logger.info(f"📄 Found resume: {path}")
                return str(path)
        
        logger.warning("⚠️ No resume file found, using profile data only")
        return None
    
    def _read_resume(self) -> str:
        """Read resume content"""
        if not self.resume_path:
            return ""
        
        try:
            with open(self.resume_path, 'r', encoding='utf-8') as f:
                content = f.read()
                logger.info(f"✅ Resume loaded ({len(content)} characters)")
                return content
        except Exception as e:
            logger.error(f"❌ Error reading resume: {e}")
            return ""
    
    def extract_skills_from_text(self, text: str) -> List[str]:
        """Extract skill keywords from resume text"""
        tech_keywords = [
            "python", "sql", "spark", "kafka", "aws", "gcp", "azure",
            "docker", "kubernetes", "airflow", "dbt", "tensorflow",
            "pytorch", "machine learning", "deep learning", "data warehousing",
            "etl", "elt", "real-time", "distributed systems", "microservices",
            "java", "scala", "r", "go", "rust", "rust",
            "postgresql", "mysql", "mongodb", "cassandra", "elasticsearch",
            "git", "jenkins", "gitlab", "github", "ci/cd",
            "leadership", "mentoring", "agile", "scrum", "management"
        ]
        
        found_skills = []
        text_lower = text.lower()
        
        for skill in tech_keywords:
            if skill in text_lower:
                found_skills.append(skill)
        
        return list(set(found_skills))
    
    def parse_resume(self) -> ResumeProfile:
        """Parse resume into structured profile"""
        logger.info("📋 Parsing resume...")
        
        text = self.resume_text or self._create_profile_from_config()
        
        # Extract basic info
        name = self.profile['personal']['name']
        email = self.profile['personal']['email']
        phone = self.profile['personal']['phone']
        headline = self.profile['professional']['current_role']
        
        # Extract years of experience
        years = self.profile['professional']['years_experience']
        
        # Extract skills
        skills = self._extract_all_skills(text)
        
        # Extract companies
        companies = []
        for company in self.profile['company_preferences']['preferred_companies'][:10]:
            if company.lower() in text.lower():
                companies.append(company)
        
        # Extract roles
        roles = self.profile['target_roles']
        
        profile = ResumeProfile(
            name=name,
            email=email,
            phone=phone,
            headline=headline,
            years_experience=years,
            skills=skills,
            companies=companies,
            roles=roles,
            achievements=self._extract_achievements(text),
            certifications=self._extract_certifications(text),
            education=self._extract_education(text)
        )
        
        logger.info(f"✅ Resume parsed: {len(skills)} skills, {years} years experience")
        return profile
    
    def _create_profile_from_config(self) -> str:
        """Create resume text from profile config"""
        return f"""
{self.profile['personal']['name']}
{self.profile['professional']['current_role']}

Years of Experience: {self.profile['professional']['years_experience']}

Technical Skills:
{', '.join(self.profile['skills']['technical'])}

Soft Skills:
{', '.join(self.profile['skills']['soft_skills'])}

Target Roles:
{', '.join(self.profile['target_roles'])}

Experience: Data engineering, distributed systems, cloud architecture, leadership.
"""
    
    def _extract_all_skills(self, text: str) -> List[str]:
        """Extract all technical skills"""
        config_skills = self.profile['skills']['technical']
        extracted = self.extract_skills_from_text(text)
        return list(set(config_skills + extracted))
    
    def _extract_achievements(self, text: str) -> List[str]:
        """Extract achievements from resume"""
        # Look for bullet points
        lines = text.split('\n')
        achievements = [line.strip() for line in lines 
                       if line.strip().startswith('•') or line.strip().startswith('-')]
        return achievements[:10]
    
    def _extract_certifications(self, text: str) -> List[str]:
        """Extract certifications"""
        certs = []
        cert_keywords = ['aws', 'gcp', 'azure', 'certified', 'certification']
        
        for line in text.split('\n'):
            if any(keyword in line.lower() for keyword in cert_keywords):
                if len(line) < 100:  # Likely a cert line
                    certs.append(line.strip())
        
        return certs[:5]
    
    def _extract_education(self, text: str) -> List[str]:
        """Extract education"""
        education = []
        edu_keywords = ['bachelor', 'master', 'phd', 'diploma', 'degree', 'university', 'college']
        
        for line in text.split('\n'):
            if any(keyword in line.lower() for keyword in edu_keywords):
                if len(line) < 150:
                    education.append(line.strip())
        
        return education[:5]
    
    def calculate_resume_job_fit(self, job_title: str, job_description: str, 
                                job_requirements: str, resume: ResumeProfile) -> Tuple[float, Dict]:
        """Calculate how well job fits the resume"""
        score = 0
        breakdown = {}
        
        # 1. Skill match (40 points)
        skill_matches = self._match_skills(job_description, resume.skills)
        skill_score = min(40, len(skill_matches) * 5)
        breakdown['skills'] = {'score': skill_score, 'matches': skill_matches}
        score += skill_score
        
        # 2. Role match (30 points)
        role_matches = [r for r in resume.roles if r.lower() in job_title.lower()]
        role_score = 30 if role_matches else 15
        breakdown['role'] = {'score': role_score, 'match': bool(role_matches)}
        score += role_score
        
        # 3. Experience level (20 points)
        years_required = self._extract_years_required(job_requirements)
        if years_required and resume.years_experience >= years_required:
            exp_score = 20
        elif years_required:
            exp_score = max(0, 20 - (years_required - resume.years_experience) * 3)
        else:
            exp_score = 20
        breakdown['experience'] = {'score': exp_score, 'years': resume.years_experience}
        score += exp_score
        
        # 4. Soft skills (10 points)
        soft_skill_keywords = ['leadership', 'mentoring', 'communication', 'management']
        soft_matches = [s for s in soft_skill_keywords 
                       if s in job_description.lower() and s in ' '.join(resume.skills).lower()]
        soft_score = len(soft_matches) * 2.5
        breakdown['soft_skills'] = {'score': soft_score, 'matches': soft_matches}
        score += soft_score
        
        return score, breakdown
    
    def _match_skills(self, job_description: str, resume_skills: List[str]) -> List[str]:
        """Find skill matches between job and resume"""
        job_desc_lower = job_description.lower()
        matches = []
        
        for skill in resume_skills:
            if skill.lower() in job_desc_lower:
                matches.append(skill)
        
        return matches
    
    def _extract_years_required(self, requirements: str) -> Optional[int]:
        """Extract years of experience required"""
        # Look for patterns like "3+ years" or "5 years"
        matches = re.findall(r'(\d+)\+?\s*(?:years?|yrs)', requirements.lower())
        if matches:
            return int(matches[0])
        return None
    
    def find_matching_jobs(self) -> List[Dict]:
        """Find matching jobs from database"""
        logger.info("🔍 Finding matching jobs...")
        
        resume = self.parse_resume()
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Get all jobs
        cursor.execute('SELECT * FROM jobs_multi_source LIMIT 100')
        jobs = cursor.fetchall()
        conn.close()
        
        matches = []
        for job in jobs:
            title = job[2]
            description = job[9]
            requirements = job[10]
            
            fit_score, breakdown = self.calculate_resume_job_fit(
                title, description, requirements, resume
            )
            
            if fit_score > 40:  # Only include good matches
                matches.append({
                    'title': title,
                    'company': job[3],
                    'location': job[4],
                    'fit_score': fit_score,
                    'breakdown': breakdown,
                    'url': job[14]
                })
        
        return sorted(matches, key=lambda x: x['fit_score'], reverse=True)
    
    def print_resume_profile(self):
        """Print resume profile"""
        resume = self.parse_resume()
        
        logger.info("\n" + "=" * 80)
        logger.info("📄 RESUME PROFILE")
        logger.info("=" * 80)
        logger.info(f"\n👤 Name: {resume.name}")
        logger.info(f"   Email: {resume.email}")
        logger.info(f"   Phone: {resume.phone}")
        logger.info(f"   Headline: {resume.headline}")
        
        logger.info(f"\n📊 Experience: {resume.years_experience} years")
        
        logger.info(f"\n🛠️  Top Skills ({len(resume.skills)}):")
        for skill in resume.skills[:15]:
            logger.info(f"   • {skill}")
        
        logger.info(f"\n🎯 Target Roles ({len(resume.roles)}):")
        for role in resume.roles[:5]:
            logger.info(f"   • {role}")
        
        if resume.companies:
            logger.info(f"\n🏢 Companies ({len(resume.companies)}):")
            for company in resume.companies[:5]:
                logger.info(f"   • {company}")
        
        logger.info("\n" + "=" * 80)
    
    def print_matching_jobs_report(self):
        """Print matching jobs report"""
        matches = self.find_matching_jobs()
        
        logger.info("\n" + "=" * 80)
        logger.info("🎯 RESUME-MATCHED JOBS")
        logger.info("=" * 80)
        logger.info(f"\nFound {len(matches)} matching opportunities\n")
        
        for i, job in enumerate(matches[:10], 1):
            logger.info(f"{i}. {job['title']} @ {job['company']}")
            logger.info(f"   📍 {job['location']}")
            logger.info(f"   ⭐ Fit Score: {job['fit_score']:.0f}/100")
            logger.info(f"   Skills: {', '.join(job['breakdown']['skills']['matches'][:3])}")
            logger.info("")
        
        logger.info("=" * 80)


def main():
    analyzer = ResumeAnalyzer()
    analyzer.print_resume_profile()
    analyzer.print_matching_jobs_report()


if __name__ == "__main__":
    main()
