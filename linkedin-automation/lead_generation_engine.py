#!/usr/bin/env python3
"""
Lead Generation Engine - Leverages Your Full Infrastructure
Automates lead generation, outreach, and opportunity tracking using:
- LinkedIn automation (personal + company)
- Portfolio showcase (simondatalab.de)
- Moodle courses (social proof)
- AI agents (VM 159)
- Analytics (demonstrate capabilities)

Author: Simon Renauld
Created: November 4, 2025
"""

import os
import json
import asyncio
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict

from playwright.async_api import async_playwright
from dotenv import load_dotenv

load_dotenv()

# Paths
BASE_DIR = Path(__file__).parent
LEADS_DIR = BASE_DIR / "outputs" / "leads"
OUTREACH_DIR = BASE_DIR / "outputs" / "outreach"

LEADS_DIR.mkdir(parents=True, exist_ok=True)
OUTREACH_DIR.mkdir(parents=True, exist_ok=True)


@dataclass
class Lead:
    """Potential client/employer"""
    id: str
    name: str
    company: str
    title: str
    linkedin_url: str
    industry: str
    pain_points: List[str]
    fit_score: int  # 1-10
    contact_method: str  # 'linkedin', 'email', 'website'
    status: str  # 'identified', 'contacted', 'responding', 'qualified', 'lost'
    notes: str
    created_at: str
    last_contact: Optional[str] = None


@dataclass
class OutreachMessage:
    """Personalized outreach template"""
    lead_id: str
    message_type: str  # 'connection', 'inmail', 'email', 'comment'
    subject: str
    body: str
    cta: str
    showcase_link: str  # Portfolio, case study, or demo
    created_at: str


class LeadGenerationEngine:
    """Main lead generation automation"""
    
    def __init__(self):
        self.portfolio_url = "https://www.simondatalab.de"
        self.moodle_url = "https://moodle.simondatalab.de"
        self.company_page = "https://www.linkedin.com/company/105307318"
        
        # Exclude existing contacts from search results
        self.excluded_names = [
            "Frank Plazanet",
            "David Nomber",
            "frank plazanet",
            "david nomber",
            "FRANK PLAZANET",
            "DAVID NOMBER"
        ]
        
        # Your infrastructure capabilities
        self.capabilities = {
            "healthcare_analytics": {
                "proof": "500M+ records processed, 100% HIPAA compliance",
                "case_study": f"{self.portfolio_url}/#case-studies",
                "demo": "Live Moodle courses + AI homelab"
            },
            "data_engineering": {
                "proof": "85% faster ETL, 99.9% uptime, automated ops",
                "case_study": f"{self.portfolio_url}/#expertise",
                "demo": "ProxmoxMCP automation + VM 159 AI agents"
            },
            "mlops_platform": {
                "proof": "Private MLOps, HIPAA-compliant, cost-efficient",
                "case_study": "AI homelab with ProxmoxMCP",
                "demo": "Live infrastructure at simondatalab.de"
            },
            "training_delivery": {
                "proof": "Live Moodle platform with data engineering courses",
                "case_study": self.moodle_url,
                "demo": "Hands-on labs + automated grading"
            }
        }
    
    # ===== Lead Identification =====
    
    async def scrape_linkedin_search(self, job_title: str, location: str = "Vietnam", page=None, browser_context=None) -> List[Lead]:
        """Scrape LinkedIn for potential leads (hiring managers, CTOs, etc.)"""
        print(f"🔍 Searching LinkedIn: {job_title} in {location}")
        
        should_close = False
        
        if page is None:
            # Create new browser session
            should_close = True
            async with async_playwright() as p:
                browser = await p.chromium.launch(headless=True)
                page = await browser.new_page()
                
                # Login with increased timeout
                try:
                    await page.goto('https://www.linkedin.com/login', timeout=60000)
                    await page.fill('input#username', os.getenv('LINKEDIN_EMAIL'))
                    await page.fill('input#password', os.getenv('LINKEDIN_PASSWORD'))
                    await page.click('button[type="submit"]')
                    await page.wait_for_url('https://www.linkedin.com/feed/', timeout=60000)
                except Exception as e:
                    print(f"   ⚠️ Login failed: {e}")
                    print(f"   Possible causes:")
                    print(f"     - Invalid credentials")
                    print(f"     - LinkedIn requires verification/CAPTCHA")
                    print(f"     - Rate limiting")
                    await browser.close()
                    return []
        
        try:
            # Search
            search_url = f'https://www.linkedin.com/search/results/people/?keywords={job_title}&location={location}'
            await page.goto(search_url, timeout=60000)
            await asyncio.sleep(5)  # Let page fully load
            
            leads = []
            profiles = await page.query_selector_all('.entity-result__item')
            
            for i, profile in enumerate(profiles[:20]):  # Top 20 results
                try:
                    name_elem = await profile.query_selector('.entity-result__title-text a')
                    title_elem = await profile.query_selector('.entity-result__primary-subtitle')
                    company_elem = await profile.query_selector('.entity-result__secondary-subtitle')
                    
                    name = await name_elem.text_content() if name_elem else f"Lead_{i}"
                    title = await title_elem.text_content() if title_elem else ""
                    company = await company_elem.text_content() if company_elem else ""
                    linkedin_url = await name_elem.get_attribute('href') if name_elem else ""
                    
                    # Skip if this is an excluded contact (existing hot leads)
                    if name and any(excluded.lower() in name.lower() for excluded in self.excluded_names):
                        print(f"⏭️  Skipping existing contact: {name}")
                        continue
                    
                    # Determine fit score based on title
                    fit_score = self._calculate_fit_score(title or "", company or "")
                    
                    lead = Lead(
                        id=f"lead_{int(datetime.now().timestamp())}_{i}",
                        name=(name or f"Lead_{i}").strip(),
                        company=(company or "").strip(),
                        title=(title or "").strip(),
                        linkedin_url=linkedin_url or "",
                        industry="Healthcare/Tech",  # TODO: Extract from profile
                        pain_points=self._identify_pain_points(title or ""),
                        fit_score=fit_score,
                        contact_method='linkedin',
                        status='identified',
                        notes=f"Found via search: {job_title}",
                        created_at=datetime.now().isoformat()
                    )
                    
                    leads.append(lead)
                    
                except Exception as e:
                    print(f"⚠️ Error parsing profile {i}: {e}")
            
            # Save leads
            self._save_leads(leads)
            
            print(f"✅ Found {len(leads)} potential leads")
            return leads
            
        except Exception as e:
            print(f"   ⚠️ Search failed: {e}")
            return []
        finally:
            if should_close and 'browser' in locals():
                await browser.close()
    
    def _calculate_fit_score(self, title: str, company: str) -> int:
        """Score lead based on title/company (1-10)"""
        score = 5  # Base score
        
        # High-value titles
        if any(x in title.lower() for x in ['cto', 'vp', 'head of', 'director', 'lead']):
            score += 3
        elif any(x in title.lower() for x in ['manager', 'senior', 'principal']):
            score += 2
        
        # Target industries
        if any(x in company.lower() for x in ['health', 'medical', 'clinical', 'pharma']):
            score += 2
        elif any(x in company.lower() for x in ['startup', 'tech', 'ai', 'ml']):
            score += 1
        
        return min(score, 10)
    
    def _identify_pain_points(self, title: str) -> List[str]:
        """Identify likely pain points based on role"""
        title_lower = title.lower()
        
        if 'data' in title_lower or 'analytics' in title_lower:
            return [
                "Slow ETL pipelines",
                "Data quality issues",
                "HIPAA compliance complexity",
                "Manual reporting overhead"
            ]
        elif 'cto' in title_lower or 'vp eng' in title_lower:
            return [
                "Technical team scaling",
                "ML infrastructure costs",
                "Data governance",
                "Operational efficiency"
            ]
        elif 'ml' in title_lower or 'ai' in title_lower:
            return [
                "MLOps platform setup",
                "Model deployment complexity",
                "Data privacy/residency",
                "Experiment tracking"
            ]
        else:
            return [
                "Data-driven decision making",
                "Analytics infrastructure",
                "Team training needs"
            ]
    
    # ===== Outreach Generation =====
    
    def generate_connection_request(self, lead: Lead) -> OutreachMessage:
        """Generate personalized LinkedIn connection request"""
        
        # Select best capability match
        capability = self._match_capability(lead.pain_points)
        proof = self.capabilities[capability]["proof"]
        case_study = self.capabilities[capability]["case_study"]
        
        # Personalized message (300 char limit)
        message = f"""Hi {lead.name.split()[0]},

I saw your work at {lead.company} in {lead.title}. I've built similar {capability.replace('_', ' ')} solutions ({proof}).

Would love to connect and share insights.

Simon"""
        
        return OutreachMessage(
            lead_id=lead.id,
            message_type='connection',
            subject="",
            body=message,
            cta="Connect to share insights",
            showcase_link=case_study,
            created_at=datetime.now().isoformat()
        )
    
    def generate_inmail_pitch(self, lead: Lead) -> OutreachMessage:
        """Generate personalized InMail pitch"""
        
        capability = self._match_capability(lead.pain_points)
        proof = self.capabilities[capability]["proof"]
        case_study = self.capabilities[capability]["case_study"]
        demo = self.capabilities[capability]["demo"]
        
        first_name = lead.name.split()[0]
        
        subject = f"Re: {capability.replace('_', ' ').title()} at {lead.company}"
        
        body = f"""Hi {first_name},

I noticed {lead.company}'s work in {lead.industry} and thought you might be interested in how we've tackled similar challenges.

**Your likely challenges:**
{chr(10).join(f'• {p}' for p in lead.pain_points[:3])}

**What I've built:**
{proof}

**Proof:** {case_study}
**Live demo:** {demo}

I'm based in Ho Chi Minh City and available for:
• Strategic consulting (data platform design)
• Technical implementation (end-to-end delivery)
• Team training (live courses on Moodle)

15-minute call to discuss your specific needs? I can share relevant case studies from healthcare/tech.

Best,
Simon Renauld
{self.portfolio_url}
"""
        
        return OutreachMessage(
            lead_id=lead.id,
            message_type='inmail',
            subject=subject,
            body=body,
            cta="Book 15-min call",
            showcase_link=self.portfolio_url,
            created_at=datetime.now().isoformat()
        )
    
    def generate_email_pitch(self, lead: Lead, email: str) -> OutreachMessage:
        """Generate cold email pitch"""
        
        capability = self._match_capability(lead.pain_points)
        proof = self.capabilities[capability]["proof"]
        case_study = self.capabilities[capability]["case_study"]
        
        first_name = lead.name.split()[0]
        
        subject = f"[{lead.company}] {capability.replace('_', ' ').title()} Case Study"
        
        body = f"""Hi {first_name},

I came across {lead.company}'s recent work and thought you might find this case study relevant.

**Quick context:**
I'm a data engineering leader who's built {capability.replace('_', ' ')} platforms for healthcare and tech companies. Recent outcomes:

{proof}

**Relevant to {lead.company}:**
Based on your role as {lead.title}, you're likely dealing with:
{chr(10).join(f'• {p}' for p in lead.pain_points[:3])}

**What I can help with:**
✓ Strategic consulting: Data platform architecture, ML roadmaps
✓ Technical delivery: End-to-end implementation (Python, SQL, PySpark, Databricks)
✓ Team enablement: Training programs on live Moodle platform

**Live examples:**
• Portfolio: {self.portfolio_url}
• Case studies: {case_study}
• Training platform: {self.moodle_url}

Worth a 15-minute exploratory call?

Best regards,
Simon Renauld
Senior Data Scientist & Innovation Strategist
{self.portfolio_url}
+84 923 180 061
"""
        
        return OutreachMessage(
            lead_id=lead.id,
            message_type='email',
            subject=subject,
            body=body,
            cta="Schedule 15-min call",
            showcase_link=self.portfolio_url,
            created_at=datetime.now().isoformat()
        )
    
    def _match_capability(self, pain_points: List[str]) -> str:
        """Match lead's pain points to best capability"""
        pain_text = " ".join(pain_points).lower()
        
        if any(x in pain_text for x in ['hipaa', 'healthcare', 'clinical', 'compliance']):
            return 'healthcare_analytics'
        elif any(x in pain_text for x in ['ml', 'mlops', 'model', 'ai', 'experiment']):
            return 'mlops_platform'
        elif any(x in pain_text for x in ['training', 'team', 'course', 'learning']):
            return 'training_delivery'
        else:
            return 'data_engineering'
    
    # ===== LinkedIn Engagement =====
    
    async def engage_with_post(self, post_url: str, comment: str):
        """Comment on a prospect's LinkedIn post"""
        print(f"💬 Commenting on: {post_url}")
        
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            page = await browser.new_page()
            
            # Login
            await page.goto('https://www.linkedin.com/login')
            await page.fill('input#username', os.getenv('LINKEDIN_EMAIL'))
            await page.fill('input#password', os.getenv('LINKEDIN_PASSWORD'))
            await page.click('button[type="submit"]')
            await page.wait_for_url('https://www.linkedin.com/feed/')
            
            # Navigate to post
            await page.goto(post_url)
            await asyncio.sleep(2)
            
            # Click comment
            await page.click('button[aria-label*="Comment"]')
            await asyncio.sleep(1)
            
            # Write comment
            comment_box = await page.wait_for_selector('div[role="textbox"]')
            await comment_box.fill(comment)
            await asyncio.sleep(1)
            
            # Post comment
            await page.click('button:has-text("Post")')
            await asyncio.sleep(2)
            
            await browser.close()
            print("✅ Comment posted")
    
    # ===== Data Management =====
    
    def _save_leads(self, leads: List[Lead]):
        """Save leads to JSON"""
        filename = LEADS_DIR / f"leads_{datetime.now().strftime('%Y%m%d')}.json"
        
        existing = []
        if filename.exists():
            with open(filename) as f:
                existing = json.load(f)
        
        all_leads = existing + [asdict(l) for l in leads]
        
        with open(filename, 'w') as f:
            json.dump(all_leads, f, indent=2)
        
        print(f"✅ Saved {len(leads)} leads to {filename}")
    
    def _save_outreach(self, message: OutreachMessage):
        """Save outreach message"""
        filename = OUTREACH_DIR / f"outreach_{message.lead_id}.json"
        
        with open(filename, 'w') as f:
            json.dump(asdict(message), f, indent=2)
        
        print(f"✅ Saved outreach: {filename}")
    
    def get_high_value_leads(self, min_score: int = 7) -> List[Lead]:
        """Get leads with fit score >= min_score"""
        all_leads = []
        
        for file in LEADS_DIR.glob("leads_*.json"):
            with open(file) as f:
                leads_data = json.load(f)
                all_leads.extend([Lead(**l) for l in leads_data])
        
        high_value = [l for l in all_leads if l.fit_score >= min_score]
        high_value.sort(key=lambda x: x.fit_score, reverse=True)
        
        return high_value


# ===== CLI Functions =====

async def find_leads(job_title: str, location: str = "Vietnam"):
    """Find and score leads"""
    engine = LeadGenerationEngine()
    leads = await engine.scrape_linkedin_search(job_title, location)
    
    print(f"\n📊 Lead Summary:")
    print(f"Total leads: {len(leads)}")
    print(f"High-value (7+): {len([l for l in leads if l.fit_score >= 7])}")
    print(f"Medium-value (5-6): {len([l for l in leads if 5 <= l.fit_score < 7])}")


def generate_outreach(lead_id: str, method: str = 'inmail'):
    """Generate personalized outreach"""
    engine = LeadGenerationEngine()
    
    # Load lead
    for file in LEADS_DIR.glob("leads_*.json"):
        with open(file) as f:
            leads_data = json.load(f)
            for l in leads_data:
                if l['id'] == lead_id:
                    lead = Lead(**l)
                    
                    if method == 'connection':
                        message = engine.generate_connection_request(lead)
                    elif method == 'inmail':
                        message = engine.generate_inmail_pitch(lead)
                    elif method == 'email':
                        message = engine.generate_email_pitch(lead, "email@example.com")
                    
                    engine._save_outreach(message)
                    
                    print(f"\n{'='*70}")
                    print(f"OUTREACH: {method.upper()}")
                    print(f"{'='*70}")
                    print(f"To: {lead.name} ({lead.title} at {lead.company})")
                    print(f"Fit Score: {lead.fit_score}/10")
                    print(f"\nSubject: {message.subject}")
                    print(f"\n{message.body}")
                    print(f"\n{'='*70}")
                    
                    return
    
    print(f"❌ Lead not found: {lead_id}")


def show_pipeline():
    """Show current lead pipeline"""
    engine = LeadGenerationEngine()
    all_leads = []
    
    for file in LEADS_DIR.glob("leads_*.json"):
        with open(file) as f:
            leads_data = json.load(f)
            all_leads.extend([Lead(**l) for l in leads_data])
    
    print(f"\n📊 LEAD PIPELINE")
    print(f"{'='*70}")
    print(f"Total Leads: {len(all_leads)}")
    print(f"\nBy Status:")
    for status in ['identified', 'contacted', 'responding', 'qualified', 'lost']:
        count = len([l for l in all_leads if l.status == status])
        print(f"  {status.title()}: {count}")
    
    print(f"\nBy Fit Score:")
    print(f"  High (8-10): {len([l for l in all_leads if l.fit_score >= 8])}")
    print(f"  Medium (5-7): {len([l for l in all_leads if 5 <= l.fit_score < 8])}")
    print(f"  Low (1-4): {len([l for l in all_leads if l.fit_score < 5])}")
    
    print(f"\nTop 10 Leads:")
    high_value = engine.get_high_value_leads()
    for i, lead in enumerate(high_value[:10], 1):
        print(f"  {i}. {lead.name} - {lead.title} at {lead.company} (Score: {lead.fit_score})")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("""
Lead Generation Engine - Usage:

  python lead_generation_engine.py find "Head of Data" "Vietnam"
  python lead_generation_engine.py find "CTO" "Singapore"
  
  python lead_generation_engine.py outreach <lead_id> inmail
  python lead_generation_engine.py outreach <lead_id> email
  
  python lead_generation_engine.py pipeline
""")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "find":
        job_title = sys.argv[2] if len(sys.argv) > 2 else "Head of Data"
        location = sys.argv[3] if len(sys.argv) > 3 else "Vietnam"
        asyncio.run(find_leads(job_title, location))
    
    elif command == "outreach":
        lead_id = sys.argv[2] if len(sys.argv) > 2 else ""
        method = sys.argv[3] if len(sys.argv) > 3 else "inmail"
        generate_outreach(lead_id, method)
    
    elif command == "pipeline":
        show_pipeline()
    
    else:
        print(f"❌ Unknown command: {command}")
