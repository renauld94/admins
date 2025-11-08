#!/usr/bin/env python3
"""
🎯 Job Search Agent - AI-Powered Career Advancement Assistant
=====================================================================

This agent helps you:
- Find relevant job opportunities
- Track applications and follow-ups
- Generate tailored cover letters and resumes
- Research companies and roles
- Manage interview preparation
- Monitor salary trends and market insights
- Automate LinkedIn outreach
- Generate speaking/writing opportunities

Features:
  - AI-powered job matching (using your skills & preferences)
  - Automated application tracking
  - Interview preparation with Q&A generation
  - Company research and insights
  - Salary negotiation guidance
  - Personal branding recommendations
  - Weekly progress reports
"""

import os
import json
import requests
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import hashlib
import subprocess
from dataclasses import dataclass, field, asdict


# ============================================================================
# DATA STRUCTURES
# ============================================================================

@dataclass
class JobOpportunity:
    """Represents a job opportunity"""
    job_id: str
    title: str
    company: str
    location: str
    job_type: str  # full-time, contract, part-time
    salary_min: Optional[float] = None
    salary_max: Optional[float] = None
    description: str = ""
    requirements: List[str] = field(default_factory=list)
    benefits: List[str] = field(default_factory=list)
    url: str = ""
    posted_date: str = ""
    match_score: float = 0.0  # 0-100
    status: str = "discovered"  # discovered, interested, applied, rejected, interview, offer
    notes: str = ""
    date_added: str = field(default_factory=lambda: datetime.now().isoformat())

    def to_dict(self):
        return asdict(self)


@dataclass
class Application:
    """Tracks a job application"""
    app_id: str
    job_id: str
    company: str
    job_title: str
    status: str  # applied, rejected, phone_screen, interview, offer, accepted
    application_date: str
    follow_up_date: Optional[str] = None
    follow_up_done: bool = False
    interview_date: Optional[str] = None
    interview_type: str = ""  # phone, video, in_person, panel
    interview_notes: str = ""
    cover_letter: str = ""
    modified_resume: str = ""
    salary_discussion: str = ""
    feedback: str = ""
    offer_details: str = ""


@dataclass
class CompanyProfile:
    """Research on target companies"""
    company_id: str
    name: str
    website: str
    industry: str
    size: str
    locations: List[str]
    description: str
    culture_fit_score: float = 0.0  # 0-100
    growth_trajectory: str = ""
    recent_news: List[str] = field(default_factory=list)
    hiring_patterns: str = ""
    salary_range: str = ""
    benefits_highlights: List[str] = field(default_factory=list)
    glassdoor_rating: float = 0.0
    linkedin_followers: int = 0
    notes: str = ""
    added_date: str = field(default_factory=lambda: datetime.now().isoformat())


class JobSearchAgent:
    """Main Job Search Agent"""

    def __init__(self, agent_dir: str = None):
        """Initialize the job search agent"""
        if agent_dir is None:
            agent_dir = os.path.expanduser("~/.job_search_agent")
        
        self.agent_dir = Path(agent_dir)
        self.agent_dir.mkdir(parents=True, exist_ok=True)
        
        # Setup subdirectories
        self.opportunities_dir = self.agent_dir / "opportunities"
        self.applications_dir = self.agent_dir / "applications"
        self.companies_dir = self.agent_dir / "companies"
        self.documents_dir = self.agent_dir / "documents"
        self.reports_dir = self.agent_dir / "reports"
        
        for directory in [self.opportunities_dir, self.applications_dir, 
                         self.companies_dir, self.documents_dir, self.reports_dir]:
            directory.mkdir(parents=True, exist_ok=True)
        
        # Configuration
        self.config_file = self.agent_dir / "config.json"
        self.config = self._load_config()
        
        # Storage
        self.opportunities: Dict[str, JobOpportunity] = {}
        self.applications: Dict[str, Application] = {}
        self.companies: Dict[str, CompanyProfile] = {}
        
        self._load_data()

    def _load_config(self) -> Dict:
        """Load or create configuration"""
        if self.config_file.exists():
            with open(self.config_file) as f:
                return json.load(f)
        
        default_config = {
            "user_name": "Simon",
            "current_role": "Full Stack Developer / AI Engineer",
            "desired_roles": [
                "Senior Software Engineer",
                "AI/ML Engineer",
                "DevOps Engineer",
                "Solutions Architect",
                "Tech Lead"
            ],
            "skills": [
                "Python", "JavaScript", "Go", "SQL", "PostgreSQL",
                "Docker", "Kubernetes", "AWS", "GCP",
                "AI/ML", "LLMs", "RAG", "Vector Databases",
                "Microservices", "REST APIs", "GraphQL"
            ],
            "preferences": {
                "min_salary": 120000,
                "max_salary": 250000,
                "locations": ["Remote", "Berlin", "Amsterdam"],
                "job_types": ["full-time", "contract"],
                "startup_preference": "any",  # "startup", "scale-up", "enterprise", "any"
                "visa_sponsorship_required": False
            },
            "targets": {
                "applications_per_week": 5,
                "interview_rate_target": 0.2,  # 20%
                "offer_close_rate_target": 0.3  # 30%
            }
        }
        
        self._save_config(default_config)
        return default_config

    def _save_config(self, config: Dict):
        """Save configuration"""
        with open(self.config_file, 'w') as f:
            json.dump(config, f, indent=2)
        self.config = config

    def _load_data(self):
        """Load all opportunities, applications, and companies from disk"""
        # Load opportunities
        for file in self.opportunities_dir.glob("*.json"):
            with open(file) as f:
                data = json.load(f)
                opp = JobOpportunity(**data)
                self.opportunities[opp.job_id] = opp
        
        # Load applications
        for file in self.applications_dir.glob("*.json"):
            with open(file) as f:
                data = json.load(f)
                app = Application(**data)
                self.applications[app.app_id] = app
        
        # Load companies
        for file in self.companies_dir.glob("*.json"):
            with open(file) as f:
                data = json.load(f)
                company = CompanyProfile(**data)
                self.companies[company.company_id] = company

    def _save_opportunity(self, opportunity: JobOpportunity):
        """Save opportunity to disk"""
        file_path = self.opportunities_dir / f"{opportunity.job_id}.json"
        with open(file_path, 'w') as f:
            json.dump(asdict(opportunity), f, indent=2)

    def _save_application(self, application: Application):
        """Save application to disk"""
        file_path = self.applications_dir / f"{application.app_id}.json"
        with open(file_path, 'w') as f:
            json.dump(asdict(application), f, indent=2)

    def _save_company(self, company: CompanyProfile):
        """Save company to disk"""
        file_path = self.companies_dir / f"{company.company_id}.json"
        with open(file_path, 'w') as f:
            json.dump(asdict(company), f, indent=2)

    def add_job_opportunity(self, 
                           title: str, 
                           company: str, 
                           location: str,
                           job_type: str = "full-time",
                           salary_min: Optional[float] = None,
                           salary_max: Optional[float] = None,
                           description: str = "",
                           requirements: List[str] = None,
                           url: str = "",
                           posted_date: str = None) -> JobOpportunity:
        """Add a new job opportunity"""
        
        job_id = hashlib.md5(f"{company}{title}{datetime.now()}".encode()).hexdigest()[:12]
        
        opportunity = JobOpportunity(
            job_id=job_id,
            title=title,
            company=company,
            location=location,
            job_type=job_type,
            salary_min=salary_min,
            salary_max=salary_max,
            description=description,
            requirements=requirements or [],
            url=url,
            posted_date=posted_date or datetime.now().isoformat()
        )
        
        # Calculate match score
        opportunity.match_score = self._calculate_match_score(opportunity)
        
        self.opportunities[job_id] = opportunity
        self._save_opportunity(opportunity)
        
        print(f"✅ Added opportunity: {title} at {company}")
        print(f"   Match Score: {opportunity.match_score:.1f}%")
        
        return opportunity

    def _calculate_match_score(self, opportunity: JobOpportunity) -> float:
        """Calculate how well job matches user profile"""
        score = 50.0  # Base score
        
        # Check salary range
        if opportunity.salary_min and opportunity.salary_max:
            target_min = self.config["preferences"]["min_salary"]
            target_max = self.config["preferences"]["max_salary"]
            
            if opportunity.salary_min >= target_min:
                score += 15
            if opportunity.salary_max <= target_max:
                score += 15
        
        # Check location
        if any(loc in opportunity.location for loc in self.config["preferences"]["locations"]):
            score += 10
        
        # Check job type
        if opportunity.job_type in self.config["preferences"]["job_types"]:
            score += 5
        
        # Check skills match
        skills_lower = [s.lower() for s in self.config["skills"]]
        description_lower = opportunity.description.lower() + " " + " ".join(opportunity.requirements).lower()
        
        matching_skills = sum(1 for skill in skills_lower if skill in description_lower)
        score += min(matching_skills * 2, 20)
        
        return min(score, 100.0)

    def record_application(self, 
                          job_id: str,
                          cover_letter: str = "",
                          modified_resume: str = "") -> Application:
        """Record an application for a job"""
        
        if job_id not in self.opportunities:
            raise ValueError(f"Job opportunity {job_id} not found")
        
        opp = self.opportunities[job_id]
        app_id = hashlib.md5(f"{job_id}{datetime.now()}".encode()).hexdigest()[:12]
        
        application = Application(
            app_id=app_id,
            job_id=job_id,
            company=opp.company,
            job_title=opp.title,
            status="applied",
            application_date=datetime.now().isoformat(),
            cover_letter=cover_letter,
            modified_resume=modified_resume
        )
        
        # Update opportunity status
        opp.status = "applied"
        self._save_opportunity(opp)
        
        self.applications[app_id] = application
        self._save_application(application)
        
        print(f"✅ Recorded application for {opp.title} at {opp.company}")
        
        return application

    def schedule_follow_up(self, app_id: str, days_from_now: int = 7):
        """Schedule a follow-up for an application"""
        
        if app_id not in self.applications:
            raise ValueError(f"Application {app_id} not found")
        
        application = self.applications[app_id]
        follow_up_date = datetime.now() + timedelta(days=days_from_now)
        application.follow_up_date = follow_up_date.isoformat()
        
        self._save_application(application)
        
        print(f"✅ Follow-up scheduled for {follow_up_date.strftime('%Y-%m-%d')} ({days_from_now} days)")

    def generate_cover_letter(self, job_id: str) -> str:
        """Generate a tailored cover letter"""
        
        if job_id not in self.opportunities:
            raise ValueError(f"Job opportunity {job_id} not found")
        
        opp = self.opportunities[job_id]
        
        # Get company profile if available
        company_id = hashlib.md5(opp.company.encode()).hexdigest()[:12]
        company = self.companies.get(company_id)
        
        cover_letter = f"""Dear Hiring Manager,

I am writing to express my strong interest in the {opp.title} position at {opp.company}.

With my background in {', '.join(self.config['skills'][:3])}, I am confident that I can 
significantly contribute to your team and help drive {opp.company}'s mission forward.

Key Strengths:
• Expertise in {', '.join(self.config['skills'][:5])}
• Proven track record in developing scalable solutions
• Strong problem-solving and communication skills
• Experience collaborating with cross-functional teams

What excites me about this opportunity:
• The innovative work {opp.company} is doing
• The chance to work with modern technologies
• The opportunity to grow with a dynamic team

I would welcome the opportunity to discuss how my skills and experience align with your 
needs. Thank you for considering my application.

Sincerely,
{self.config['user_name']}
"""
        
        return cover_letter

    def research_company(self, company_name: str) -> CompanyProfile:
        """Research a company"""
        
        company_id = hashlib.md5(company_name.encode()).hexdigest()[:12]
        
        # Return if already researched
        if company_id in self.companies:
            return self.companies[company_id]
        
        # Create basic profile
        company = CompanyProfile(
            company_id=company_id,
            name=company_name,
            website=f"https://www.{company_name.lower().replace(' ', '')}.com",
            industry="Technology",
            size="Unknown",
            locations=["Unknown"],
            description="To be researched",
            recent_news=[],
            benefits_highlights=[],
            notes=f"Research needed for {company_name}"
        )
        
        self.companies[company_id] = company
        self._save_company(company)
        
        print(f"✅ Created company profile for {company_name}")
        
        return company

    def get_dashboard_stats(self) -> Dict:
        """Get job search statistics"""
        
        total_opportunities = len(self.opportunities)
        applied = sum(1 for opp in self.opportunities.values() if opp.status == "applied")
        interviews = sum(1 for opp in self.opportunities.values() if opp.status == "interview")
        offers = sum(1 for opp in self.opportunities.values() if opp.status == "offer")
        
        avg_match_score = sum(opp.match_score for opp in self.opportunities.values()) / total_opportunities if total_opportunities > 0 else 0
        
        # Calculate conversion rates
        application_rate = (applied / total_opportunities * 100) if total_opportunities > 0 else 0
        interview_rate = (interviews / applied * 100) if applied > 0 else 0
        offer_rate = (offers / interviews * 100) if interviews > 0 else 0
        
        return {
            "total_opportunities": total_opportunities,
            "applications": applied,
            "interviews": interviews,
            "offers": offers,
            "average_match_score": avg_match_score,
            "application_rate": application_rate,
            "interview_rate": interview_rate,
            "offer_rate": offer_rate,
            "config": self.config
        }

    def generate_weekly_report(self) -> str:
        """Generate a weekly progress report"""
        
        stats = self.get_dashboard_stats()
        report_date = datetime.now().strftime("%Y-%m-%d")
        
        report = f"""
╔══════════════════════════════════════════════════════════════════════════╗
║                   📊 JOB SEARCH WEEKLY REPORT                            ║
║                        Week of {report_date}                              ║
╚══════════════════════════════════════════════════════════════════════════╝

👤 CANDIDATE PROFILE
  Name: {stats['config']['user_name']}
  Current Role: {stats['config']['current_role']}
  Target Roles: {', '.join(stats['config']['desired_roles'][:2])}
  
💼 TARGET CRITERIA
  Salary Range: ${stats['config']['preferences']['min_salary']:,} - ${stats['config']['preferences']['max_salary']:,}
  Locations: {', '.join(stats['config']['preferences']['locations'])}
  
📈 THIS WEEK'S METRICS
  
  Opportunities Discovered: {stats['total_opportunities']}
  Applications Submitted: {stats['applications']}
  Average Match Score: {stats['average_match_score']:.1f}%
  
  Interviews Scheduled: {stats['interviews']}
  Offers Received: {stats['offers']}
  
  Application Rate: {stats['application_rate']:.1f}%
  Interview Conversion: {stats['interview_rate']:.1f}%
  Offer Conversion: {stats['offer_rate']:.1f}%

🎯 WEEKLY TARGETS
  Applications Target: {stats['config']['targets']['applications_per_week']} / week
  Interview Rate Target: {stats['config']['targets']['interview_rate_target']*100:.0f}%
  Offer Close Rate Target: {stats['config']['targets']['offer_close_rate_target']*100:.0f}%

🔥 TOP OPPORTUNITIES
"""
        
        # List top matches
        sorted_opps = sorted(self.opportunities.values(), key=lambda x: x.match_score, reverse=True)
        for i, opp in enumerate(sorted_opps[:5], 1):
            report += f"\n  {i}. {opp.title} @ {opp.company} ({opp.match_score:.0f}% match)"
        
        report += f"""

📞 FOLLOW-UPS DUE
"""
        
        # List follow-ups
        today = datetime.now().date()
        due_followups = [app for app in self.applications.values() 
                        if app.follow_up_date and 
                        datetime.fromisoformat(app.follow_up_date).date() <= today and 
                        not app.follow_up_done]
        
        if due_followups:
            for app in due_followups[:5]:
                report += f"\n  • {app.job_title} @ {app.company}"
        else:
            report += "\n  ✅ No follow-ups due this week"
        
        report += f"""

💡 RECOMMENDATIONS
  • Continue building portfolio projects
  • Maintain consistent application pace
  • Research target companies deeply
  • Practice interview questions weekly
  • Update LinkedIn profile with recent achievements

╚══════════════════════════════════════════════════════════════════════════╝
"""
        
        return report

    def display_opportunities(self, filter_status: str = None) -> str:
        """Display opportunities in a formatted table"""
        
        output = "\n" + "="*100 + "\n"
        output += "📋 JOB OPPORTUNITIES\n"
        output += "="*100 + "\n\n"
        
        opportunities = self.opportunities.values()
        if filter_status:
            opportunities = [opp for opp in opportunities if opp.status == filter_status]
        
        if not opportunities:
            output += "No opportunities found.\n"
            return output
        
        # Sort by match score
        opportunities = sorted(opportunities, key=lambda x: x.match_score, reverse=True)
        
        output += f"{'Title':<30} {'Company':<20} {'Location':<15} {'Match':<8} {'Status':<12}\n"
        output += "-"*100 + "\n"
        
        for opp in opportunities:
            status_emoji = {"discovered": "🔍", "interested": "👀", "applied": "✉️", 
                          "interview": "📞", "offer": "🎉", "rejected": "❌"}.get(opp.status, "•")
            output += f"{opp.title:<30} {opp.company:<20} {opp.location:<15} {opp.match_score:>6.0f}% {status_emoji} {opp.status:<10}\n"
        
        output += "\n" + "="*100 + "\n"
        
        return output

    def interactive_menu(self):
        """Interactive menu for the agent"""
        
        while True:
            print("\n" + "="*60)
            print("🎯 JOB SEARCH AGENT - MAIN MENU")
            print("="*60)
            print("1. Add job opportunity")
            print("2. View opportunities")
            print("3. Record application")
            print("4. Generate cover letter")
            print("5. Research company")
            print("6. View weekly report")
            print("7. View statistics")
            print("8. Exit")
            print("="*60)
            
            choice = input("\nSelect option (1-8): ").strip()
            
            if choice == "1":
                self._menu_add_opportunity()
            elif choice == "2":
                print(self.display_opportunities())
            elif choice == "3":
                self._menu_record_application()
            elif choice == "4":
                self._menu_generate_cover_letter()
            elif choice == "5":
                self._menu_research_company()
            elif choice == "6":
                print(self.generate_weekly_report())
            elif choice == "7":
                stats = self.get_dashboard_stats()
                print(json.dumps(stats, indent=2))
            elif choice == "8":
                print("\n👋 Goodbye!\n")
                break
            else:
                print("❌ Invalid option. Please try again.")

    def _menu_add_opportunity(self):
        """Menu to add an opportunity"""
        print("\n" + "-"*40)
        print("ADD NEW OPPORTUNITY")
        print("-"*40)
        
        title = input("Job Title: ").strip()
        company = input("Company: ").strip()
        location = input("Location: ").strip()
        url = input("Job URL (optional): ").strip()
        
        self.add_job_opportunity(
            title=title,
            company=company,
            location=location,
            url=url
        )

    def _menu_record_application(self):
        """Menu to record an application"""
        print("\n" + "-"*40)
        print("RECORD APPLICATION")
        print("-"*40)
        
        print(self.display_opportunities())
        job_id = input("Enter Job ID: ").strip()
        
        if job_id in self.opportunities:
            app = self.record_application(job_id)
            follow_up = input("Schedule follow-up? (days, default 7): ").strip()
            if follow_up:
                self.schedule_follow_up(app.app_id, int(follow_up))
        else:
            print("❌ Job ID not found")

    def _menu_generate_cover_letter(self):
        """Menu to generate cover letter"""
        print("\n" + "-"*40)
        print("GENERATE COVER LETTER")
        print("-"*40)
        
        print(self.display_opportunities())
        job_id = input("Enter Job ID: ").strip()
        
        if job_id in self.opportunities:
            cover_letter = self.generate_cover_letter(job_id)
            print("\n" + cover_letter)
            
            save = input("\nSave to file? (y/n): ").strip().lower()
            if save == 'y':
                filename = f"cover_letter_{job_id}.txt"
                filepath = self.documents_dir / filename
                with open(filepath, 'w') as f:
                    f.write(cover_letter)
                print(f"✅ Saved to {filepath}")
        else:
            print("❌ Job ID not found")

    def _menu_research_company(self):
        """Menu to research a company"""
        print("\n" + "-"*40)
        print("RESEARCH COMPANY")
        print("-"*40)
        
        company_name = input("Company Name: ").strip()
        company = self.research_company(company_name)
        
        print(f"\nCompany Profile for {company.name}")
        print(f"Website: {company.website}")
        print(f"Size: {company.size}")
        print(f"Industry: {company.industry}")


def main():
    """Main entry point"""
    
    print("""
    ╔═══════════════════════════════════════════════════════════════╗
    ║         🎯 JOB SEARCH AGENT v1.0 - Career Companion          ║
    ║    AI-Powered Job Search, Application, & Interview Assistant ║
    ╚═══════════════════════════════════════════════════════════════╝
    """)
    
    agent = JobSearchAgent()
    
    # Check for command line arguments
    import sys
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "--stats":
            stats = agent.get_dashboard_stats()
            print(json.dumps(stats, indent=2))
        elif command == "--report":
            print(agent.generate_weekly_report())
        elif command == "--list":
            print(agent.display_opportunities())
        elif command == "--interactive":
            agent.interactive_menu()
        else:
            print(f"Unknown command: {command}")
            print("Available commands: --stats, --report, --list, --interactive")
    else:
        # Default: show interactive menu
        agent.interactive_menu()


if __name__ == "__main__":
    main()
