#!/usr/bin/env python3
"""
Advanced Job Scorer - AI-Powered Job Relevance Analysis
========================================================

Intelligent job matching using:
- NLP keyword extraction
- Skill gap analysis
- Salary fit evaluation
- Company culture matching
- Growth potential assessment

Scoring: 0-100 with detailed breakdown

Author: Simon Renauld
Created: November 9, 2025
"""

import json
import logging
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime
import hashlib

# ===== CONFIGURATION =====
BASE_DIR = Path(__file__).parent
LOGS_DIR = BASE_DIR / "outputs" / "logs"
LOGS_DIR.mkdir(parents=True, exist_ok=True)

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOGS_DIR / f"job_scorer_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


# ===== DATA MODELS =====

@dataclass
class ScoringBreakdown:
    """Detailed scoring breakdown"""
    skill_match_score: int
    skill_match_details: Dict[str, int]
    
    experience_level_score: int
    experience_details: str
    
    salary_fit_score: int
    salary_details: str
    
    location_score: int
    location_details: str
    
    company_culture_score: int
    culture_details: str
    
    growth_potential_score: int
    growth_details: str
    
    red_flags: List[str]
    
    total_score: int


class AdvancedJobScorer:
    """
    Advanced job relevance scorer using NLP and multi-criteria analysis
    """
    
    def __init__(self, profile_path: Path = None):
        self.profile = self._load_profile(profile_path)
        self.skill_keywords = self._build_skill_keywords()
        logger.info("🎯 Advanced Job Scorer initialized")
    
    def _load_profile(self, profile_path: Path = None) -> Dict:
        """Load candidate profile"""
        if profile_path is None:
            profile_path = BASE_DIR / "config" / "profile.json"
        
        if not profile_path.exists():
            logger.warning(f"Profile not found: {profile_path}")
            return self._default_profile()
        
        with open(profile_path) as f:
            return json.load(f)
    
    def _default_profile(self) -> Dict:
        """Default profile for Simon"""
        return {
            "name": "Simon Renauld",
            "title": "Data Engineer & QA Automation",
            "years_experience": 8,
            "current_level": "senior",
            "core_skills": {
                "languages": ["Python", "SQL", "Scala", "Go"],
                "data_platforms": ["Apache Airflow", "Spark", "Kafka", "dbt"],
                "cloud": ["AWS", "GCP", "Azure"],
                "data_tools": ["Snowflake", "BigQuery", "PostgreSQL", "MongoDB"],
                "testing": ["pytest", "unittest", "CI/CD", "automation"],
                "architecture": ["ETL", "Data Governance", "Analytics Engineering"]
            },
            "target_roles": ["Lead Data Engineer", "Data Platform Engineer", "Analytics Lead", "QA Manager"],
            "target_locations": ["Remote", "Singapore", "Australia", "Vietnam"],
            "salary_expectations": {
                "min": 80000,
                "target": 120000,
                "max": 200000,
                "currency": "USD"
            },
            "values": ["Technical excellence", "Team collaboration", "Continuous learning", "Impact"],
            "red_flags": ["Unrealistic deadlines", "No testing culture", "High turnover", "Outdated stack"]
        }
    
    def _build_skill_keywords(self) -> Dict[str, List[str]]:
        """Build mapping of skills to job keywords"""
        return {
            "Python": ["python", "py", "pandas", "numpy"],
            "SQL": ["sql", "postgres", "mysql", "tsql", "snowflake"],
            "Airflow": ["airflow", "dag", "orchestration", "scheduling"],
            "Spark": ["spark", "pyspark", "distributed", "hadoop"],
            "Kafka": ["kafka", "stream", "event", "realtime"],
            "AWS": ["aws", "s3", "lambda", "ec2", "redshift"],
            "GCP": ["gcp", "bigquery", "dataflow", "cloud run"],
            "ETL": ["etl", "elt", "data pipeline", "integration"],
            "Testing": ["pytest", "unittest", "test", "qa", "automation"],
            "Leadership": ["lead", "manage", "director", "head", "principal"]
        }
    
    # ===== SCORING COMPONENTS =====
    
    def score_skill_match(self, job_description: str) -> Tuple[int, Dict]:
        """
        Score skill match (0-30 points)
        
        Analysis:
        - Core skills presence
        - Skill level match
        - Modern vs legacy tech
        """
        score = 0
        details = {}
        
        job_text = job_description.lower()
        matched_skills = []
        
        # Score each skill
        for skill, keywords in self.skill_keywords.items():
            for keyword in keywords:
                if keyword in job_text:
                    matched_skills.append(skill)
                    details[skill] = "✅ Found"
                    score += 3
                    break
        
        # Bonus for exact matches to core skills
        for core_skill in self.profile["core_skills"].get("languages", []):
            if core_skill.lower() in job_text:
                score += 2
                details[core_skill] = "💎 Core skill"
        
        # Penalize for outdated tech
        outdated = ["COBOL", "Fortran", "Flash"]
        for tech in outdated:
            if tech.lower() in job_text:
                score -= 5
                details[tech] = "⚠️ Outdated tech"
        
        return min(30, score), details
    
    def score_experience_level(self, job_description: str, job_title: str) -> Tuple[int, str]:
        """
        Score experience level match (0-20 points)
        
        Analysis:
        - Seniority match
        - Years of experience match
        - Role progression alignment
        """
        score = 0
        reason = ""
        
        my_years = self.profile["years_experience"]
        my_level = self.profile["current_level"]
        
        job_text = job_description.lower()
        job_title_lower = job_title.lower()
        
        # Parse years requirement
        required_years = self._extract_years_requirement(job_description)
        
        if required_years is None:
            reason = "No explicit years requirement"
            score = 15
        else:
            # Check if years match
            if abs(my_years - required_years) <= 2:
                score = 20
                reason = f"Perfect match: {my_years} years vs {required_years} required"
            elif my_years >= required_years:
                score = 15
                reason = f"Overqualified: {my_years} years vs {required_years} required"
            else:
                score = 8
                reason = f"Underqualified: {my_years} years vs {required_years} required"
        
        # Adjust for senior roles
        senior_keywords = ["lead", "senior", "principal", "staff", "director"]
        if any(kw in job_title_lower for kw in senior_keywords):
            if my_level == "senior":
                score += 5
        
        return min(20, score), reason
    
    def score_salary_fit(self, salary_range: Optional[str]) -> Tuple[int, str]:
        """
        Score salary fit (0-15 points)
        
        Analysis:
        - Within target range
        - Growth potential
        """
        score = 10  # Base score
        reason = "No salary specified"
        
        if not salary_range:
            return score, reason
        
        try:
            # Parse salary (very basic)
            salary_text = salary_range.lower()
            
            # Extract numbers
            import re
            numbers = re.findall(r'\d+', salary_text)
            
            if not numbers:
                return score, "Could not parse salary"
            
            min_sal = int(numbers[0])
            max_sal = int(numbers[-1]) if len(numbers) > 1 else min_sal
            
            # Compare to target
            target = self.profile["salary_expectations"]["target"]
            
            if min_sal <= target <= max_sal:
                score = 15
                reason = f"Within range: ${min_sal}k-${max_sal}k"
            elif max_sal >= target:
                score = 12
                reason = f"Upper range: ${min_sal}k-${max_sal}k (target: ${target}k)"
            else:
                score = 5
                reason = f"Below target: ${min_sal}k-${max_sal}k"
            
        except Exception as e:
            logger.warning(f"Salary parsing failed: {e}")
        
        return score, reason
    
    def score_location(self, location: str, job_description: str) -> Tuple[int, str]:
        """
        Score location fit (0-10 points)
        
        Analysis:
        - Remote vs onsite preference
        - Target locations
        """
        score = 0
        reason = ""
        
        location_lower = location.lower()
        job_text = job_description.lower()
        
        # Check for remote
        remote_keywords = ["remote", "anywhere", "distributed", "async"]
        is_remote = any(kw in location_lower or kw in job_text for kw in remote_keywords)
        
        # Check for target locations
        target_locs = [l.lower() for l in self.profile["target_locations"]]
        is_target_location = any(loc in location_lower for loc in target_locs)
        
        if self.profile.get("remote_preference"):
            if is_remote:
                score = 10
                reason = "Remote (preferred)"
            elif is_target_location:
                score = 8
                reason = f"Target location: {location}"
            else:
                score = 4
                reason = f"Onsite: {location}"
        else:
            if is_target_location:
                score = 10
                reason = f"Target location: {location}"
            elif is_remote:
                score = 6
                reason = "Remote (acceptable)"
            else:
                score = 2
                reason = f"Non-target: {location}"
        
        return score, reason
    
    def score_company_culture(self, company: str, job_description: str) -> Tuple[int, str]:
        """
        Score company culture fit (0-15 points)
        
        Analysis:
        - Values alignment
        - Company stage
        - Industry
        """
        score = 0
        reason = ""
        
        job_text = job_description.lower()
        
        # Check for values alignment
        values_keywords = {
            "Technical excellence": ["best practices", "high standards", "quality", "testing"],
            "Team collaboration": ["collaboration", "team", "cross-functional", "communication"],
            "Continuous learning": ["learning", "growth", "upskilling", "mentoring"],
            "Impact": ["impact", "scale", "meaningful", "mission"]
        }
        
        matched_values = []
        for value, keywords in values_keywords.items():
            if any(kw in job_text for kw in keywords):
                matched_values.append(value)
                score += 3
        
        reason = f"Values aligned: {', '.join(matched_values)}" if matched_values else "Limited values alignment"
        
        # Bonus for company size
        company_size_keywords = {
            "startup": ["startup", "early stage", "funded", "seed"],
            "scale-up": ["scale", "growth", "series", "expansion"],
            "enterprise": ["enterprise", "fortune", "large", "established"]
        }
        
        for size, keywords in company_size_keywords.items():
            if any(kw in job_text for kw in keywords):
                score += 2
                reason += f"; {size.capitalize()}"
                break
        
        return min(15, score), reason
    
    def score_growth_potential(self, job_title: str, company: str, job_description: str) -> Tuple[int, str]:
        """
        Score growth potential (0-10 points)
        
        Analysis:
        - Leadership opportunities
        - Learning opportunities
        - Progression path
        """
        score = 0
        reason = ""
        
        job_text = job_description.lower()
        job_title_lower = job_title.lower()
        
        # Check for leadership
        leadership_keywords = ["lead", "manage", "mentor", "growth", "director"]
        has_leadership = any(kw in job_title_lower or kw in job_text for kw in leadership_keywords)
        
        if has_leadership:
            score += 4
            reason = "Leadership opportunities"
        
        # Check for learning
        learning_keywords = ["learn", "training", "development", "upskilling", "mentorship"]
        has_learning = any(kw in job_text for kw in learning_keywords)
        
        if has_learning:
            score += 3
            reason += "; Learning opportunities" if reason else "Learning opportunities"
        
        # Check for modern tech
        modern_tech = ["kubernetes", "cloud", "ai", "ml", "gcp", "aws"]
        uses_modern = any(tech in job_text for tech in modern_tech)
        
        if uses_modern:
            score += 3
            reason += "; Modern tech stack" if reason else "Modern tech stack"
        
        return min(10, score), reason
    
    def detect_red_flags(self, job_description: str, company: str) -> List[str]:
        """
        Detect red flags in job posting
        """
        red_flags = []
        job_text = job_description.lower()
        
        # Unrealistic demands
        if "10+ years" in job_text and "entry level" in job_text:
            red_flags.append("🚩 Conflicting requirements (entry level + 10+ years)")
        
        # Poor practices
        bad_practices = [
            ("on-call 24/7", "Excessive on-call requirements"),
            ("must work weekends", "Weekend work required"),
            ("mvp in 2 weeks", "Unrealistic deadlines"),
        ]
        
        for phrase, flag in bad_practices:
            if phrase in job_text:
                red_flags.append(f"🚩 {flag}")
        
        # Cultural concerns
        if "move fast and break things" in job_text:
            red_flags.append("🚩 No testing culture")
        
        if "stack: cobol, vb6" in job_text:
            red_flags.append("🚩 Outdated technology stack")
        
        # From profile red flags
        for profile_flag in self.profile.get("red_flags", []):
            if profile_flag.lower() in job_text:
                red_flags.append(f"🚩 {profile_flag}")
        
        return red_flags
    
    def _extract_years_requirement(self, job_description: str) -> Optional[int]:
        """Extract required years of experience from job description"""
        import re
        
        # Look for patterns like "5 years", "5+ years"
        patterns = [
            r'(\d+)\+?\s+years',
            r'(\d+)\s+years\s+of',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, job_description)
            if match:
                return int(match.group(1))
        
        return None
    
    # ===== MAIN SCORING =====
    
    def score_job(
        self,
        job_title: str,
        company: str,
        location: str,
        job_description: str,
        salary_range: Optional[str] = None
    ) -> ScoringBreakdown:
        """
        Comprehensive job relevance scoring
        
        Returns detailed breakdown of all scoring components
        """
        
        logger.info(f"🎯 Scoring: {job_title} @ {company}")
        
        # Component scores
        skill_score, skill_details = self.score_skill_match(job_description)
        exp_score, exp_reason = self.score_experience_level(job_description, job_title)
        salary_score, salary_reason = self.score_salary_fit(salary_range)
        location_score, location_reason = self.score_location(location, job_description)
        culture_score, culture_reason = self.score_company_culture(company, job_description)
        growth_score, growth_reason = self.score_growth_potential(job_title, company, job_description)
        
        # Red flags
        red_flags = self.detect_red_flags(job_description, company)
        
        # Total score (weighted)
        total_score = (
            skill_score * 0.35 +      # Skills most important
            exp_score * 0.20 +        # Experience
            salary_score * 0.15 +     # Salary
            location_score * 0.15 +   # Location
            culture_score * 0.10 +    # Culture
            growth_score * 0.05       # Growth
        )
        
        # Penalize for red flags
        total_score -= len(red_flags) * 5
        total_score = max(0, min(100, total_score))
        
        breakdown = ScoringBreakdown(
            skill_match_score=skill_score,
            skill_match_details=skill_details,
            experience_level_score=exp_score,
            experience_details=exp_reason,
            salary_fit_score=salary_score,
            salary_details=salary_reason,
            location_score=location_score,
            location_details=location_reason,
            company_culture_score=culture_score,
            culture_details=culture_reason,
            growth_potential_score=growth_score,
            growth_details=growth_reason,
            red_flags=red_flags,
            total_score=int(total_score)
        )
        
        return breakdown
    
    def print_score_report(self, breakdown: ScoringBreakdown, job_title: str, company: str):
        """Pretty-print scoring breakdown"""
        print(f"\n{'='*70}")
        print(f"📊 JOB SCORE REPORT: {job_title} @ {company}")
        print(f"{'='*70}")
        print(f"\n🎯 OVERALL SCORE: {breakdown.total_score}/100")
        
        if breakdown.total_score >= 80:
            priority = "🔴 CRITICAL"
        elif breakdown.total_score >= 65:
            priority = "🟠 HIGH"
        elif breakdown.total_score >= 50:
            priority = "🟡 MEDIUM"
        else:
            priority = "🟢 LOW"
        
        print(f"   Priority: {priority}")
        
        print(f"\n📋 BREAKDOWN")
        print(f"   Skills Match:        {breakdown.skill_match_score:2d}/30 - {', '.join(breakdown.skill_match_details.keys()) if breakdown.skill_match_details else 'No matches'}")
        print(f"   Experience Level:    {breakdown.experience_level_score:2d}/20 - {breakdown.experience_details}")
        print(f"   Salary Fit:          {breakdown.salary_fit_score:2d}/15 - {breakdown.salary_details}")
        print(f"   Location:            {breakdown.location_score:2d}/10 - {breakdown.location_details}")
        print(f"   Company Culture:     {breakdown.company_culture_score:2d}/15 - {breakdown.culture_details}")
        print(f"   Growth Potential:    {breakdown.growth_potential_score:2d}/10 - {breakdown.growth_details}")
        
        if breakdown.red_flags:
            print(f"\n⚠️  RED FLAGS ({len(breakdown.red_flags)})")
            for flag in breakdown.red_flags:
                print(f"   {flag}")
        
        print(f"\n{'='*70}\n")


# ===== CLI =====

def main():
    """Main entry point"""
    import sys
    
    scorer = AdvancedJobScorer()
    
    if len(sys.argv) < 2:
        print("""
Advanced Job Scorer - AI-Powered Job Relevance Analysis
========================================================

Usage:
  python advanced_job_scorer.py score --title "Lead Data Engineer" --company "Shopee" --location "Singapore" --description "job_description.txt"

Example:
  python advanced_job_scorer.py score \\
    --title "Lead Data Engineer" \\
    --company "Shopee" \\
    --location "Singapore" \\
    --description "Sample job with Python, Airflow, AWS requirements"
""")
        sys.exit(0)
    
    command = sys.argv[1]
    
    if command == "score":
        title = company = location = description = None
        
        for i, arg in enumerate(sys.argv):
            if arg == "--title" and i + 1 < len(sys.argv):
                title = sys.argv[i + 1]
            elif arg == "--company" and i + 1 < len(sys.argv):
                company = sys.argv[i + 1]
            elif arg == "--location" and i + 1 < len(sys.argv):
                location = sys.argv[i + 1]
            elif arg == "--description" and i + 1 < len(sys.argv):
                description = sys.argv[i + 1]
        
        if all([title, company, location, description]):
            breakdown = scorer.score_job(title, company, location, description)
            scorer.print_score_report(breakdown, title, company)
        else:
            print("❌ Missing required arguments: --title, --company, --location, --description")


if __name__ == "__main__":
    main()
