"""
Interview Prep Assistant - Company Research & Question Bank
Author: Simon Renauld
Created: October 17, 2025

Purpose: Comprehensive interview preparation:
- Company research (Crunchbase, LinkedIn, news, Glassdoor)
- Common interview questions for data engineering roles
- STAR method answer generator
- Technical question bank
- Salary research and benchmarking

Features:
- Automated company research scraping
- Role-specific question generation
- Answer template with STAR method
- Technical question database (SQL, Python, System Design)
- Mock interview simulator

Usage:
    python tools/05_interview_prep.py \\
        --company "Databricks" \\
        --role "Lead Data Engineer" \\
        --generate-report \\
        --output outputs/interview_notes/
"""

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List

sys.path.append(str(Path(__file__).parent.parent))

try:
    import requests
    from bs4 import BeautifulSoup
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("Install: pip install requests beautifulsoup4")
    sys.exit(1)


class InterviewPrepAssistant:
    """Interview preparation and company research tool"""
    
    def __init__(self, profile_path: str = "config/profile.json"):
        """Initialize with user profile"""
        self.profile = self._load_profile(profile_path)
        
        # Question banks by category
        self.questions = self._load_question_bank()
    
    def _load_profile(self, profile_path: str) -> Dict:
        """Load user profile"""
        try:
            with open(profile_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {}
    
    def _load_question_bank(self) -> Dict:
        """Load interview question bank"""
        return {
            "behavioral": [
                "Tell me about yourself and your experience in data engineering.",
                "Describe a time when you led a complex data engineering project. What was your approach?",
                "How do you handle conflicting priorities when managing multiple data pipelines?",
                "Tell me about a time you had to make a difficult technical decision. What was the outcome?",
                "Describe a situation where you improved data quality or pipeline performance significantly.",
                "How do you approach mentoring junior data engineers?",
                "Tell me about a time you had to communicate complex technical concepts to non-technical stakeholders.",
                "Describe a project where you failed or made a significant mistake. What did you learn?",
                "How do you stay current with evolving data engineering technologies?",
                "Tell me about a time you had to work with difficult team members or stakeholders."
            ],
            "technical_concepts": [
                "Explain the difference between ETL and ELT. When would you use each?",
                "How would you design a data pipeline to process 1 billion records daily?",
                "What is data partitioning? How does it improve query performance?",
                "Explain slowly changing dimensions (SCD) types 1, 2, and 3.",
                "How would you handle late-arriving data in a streaming pipeline?",
                "What is idempotency in data pipelines? Why is it important?",
                "Explain the CAP theorem and its implications for distributed data systems.",
                "How would you optimize a slow-running SQL query?",
                "What is data lineage? How do you implement it?",
                "Explain the difference between OLTP and OLAP systems."
            ],
            "technical_sql": [
                "Write a query to find the second highest salary from an Employee table.",
                "How would you find duplicate records in a table?",
                "Write a query to calculate a 7-day moving average.",
                "Explain window functions. Provide an example using ROW_NUMBER().",
                "How would you join three tables efficiently?",
                "What is the difference between WHERE and HAVING clauses?",
                "Write a query to pivot data from rows to columns.",
                "How do you handle NULL values in SQL queries?",
                "Explain CTEs (Common Table Expressions) and when to use them.",
                "Write a recursive query to traverse a hierarchical structure."
            ],
            "technical_python": [
                "How would you read and process a 10 GB CSV file in Python?",
                "Explain the difference between list comprehension and generator expressions.",
                "How do you handle exceptions in Python? Provide best practices.",
                "What is the GIL (Global Interpreter Lock)? How does it affect performance?",
                "Explain decorators in Python. Write a simple example.",
                "How would you optimize a slow Python script?",
                "What is the difference between @staticmethod and @classmethod?",
                "How do you manage dependencies in a Python project?",
                "Explain async/await in Python. When would you use it?",
                "How do you unit test data pipelines in Python?"
            ],
            "system_design": [
                "Design a real-time analytics dashboard for e-commerce.",
                "How would you architect a data warehouse for a healthcare organization?",
                "Design a data pipeline for processing streaming IoT sensor data.",
                "How would you build a recommendation engine at scale?",
                "Design a data lake architecture for multi-tenant SaaS.",
                "How would you implement data governance and access control?",
                "Design a CDC (Change Data Capture) pipeline for a legacy database.",
                "How would you architect a multi-region disaster recovery solution?",
                "Design a data platform for machine learning model training.",
                "How would you migrate from on-premise to cloud data infrastructure?"
            ],
            "leadership": [
                "How do you prioritize projects when resources are limited?",
                "Describe your approach to building and scaling a data engineering team.",
                "How do you handle underperforming team members?",
                "What metrics do you use to measure team success?",
                "How do you foster a culture of data quality and engineering excellence?",
                "Describe your experience with Agile/Scrum methodologies in data engineering.",
                "How do you balance technical debt with new feature development?",
                "What's your approach to on-call rotation and incident management?",
                "How do you align data engineering roadmap with business objectives?",
                "Describe your experience managing vendor relationships and technology selection."
            ]
        }
    
    def research_company(self, company_name: str) -> Dict:
        """
        Research company information
        Note: In production, integrate with:
        - Crunchbase API
        - LinkedIn Company API
        - Glassdoor API
        - Google News API
        """
        print(f"🔍 Researching {company_name}...")
        
        research = {
            "company_name": company_name,
            "researched_at": datetime.now().isoformat(),
            "overview": {
                "industry": "Technology / Data & Analytics",
                "size": "Unknown - research manually",
                "founded": "Unknown - research manually",
                "headquarters": "Unknown - research manually",
                "funding": "Unknown - check Crunchbase"
            },
            "products": [
                "Research company products on their website",
                "Check recent product launches",
                "Review customer case studies"
            ],
            "recent_news": [
                f"Search Google News for: {company_name} news",
                f"Check company blog/press releases",
                f"Review LinkedIn company page updates"
            ],
            "culture_values": [
                "Check Glassdoor reviews",
                "Read 'About Us' / 'Careers' pages",
                "Review employee testimonials"
            ],
            "interview_process": {
                "typical_rounds": [
                    "Phone screen (30 min)",
                    "Technical interview (60-90 min)",
                    "System design interview (60 min)",
                    "Behavioral interview (30-45 min)",
                    "Final round with hiring manager"
                ],
                "resources": [
                    f"Search Glassdoor: {company_name} interview questions",
                    f"Search Blind: {company_name} interviews",
                    "Ask your recruiter for interview format details"
                ]
            },
            "salary_benchmark": {
                "sources": [
                    f"Levels.fyi: {company_name}",
                    f"Glassdoor: {company_name} salary",
                    f"LinkedIn: {company_name} compensation"
                ],
                "estimated_range": "Research based on role and location"
            }
        }
        
        print("✅ Company research template generated")
        return research
    
    def get_role_questions(self, role: str) -> Dict[str, List[str]]:
        """Get interview questions relevant to role"""
        print(f"📝 Generating questions for: {role}")
        
        # Determine which categories are most relevant
        if "lead" in role.lower() or "head" in role.lower() or "principal" in role.lower():
            categories = ["behavioral", "technical_concepts", "system_design", "leadership"]
        else:
            categories = ["behavioral", "technical_concepts", "technical_sql", "technical_python", "system_design"]
        
        role_questions = {}
        for category in categories:
            role_questions[category] = self.questions.get(category, [])
        
        print(f"✅ Generated {sum(len(q) for q in role_questions.values())} questions")
        return role_questions
    
    def generate_star_template(self, question: str) -> str:
        """Generate STAR method answer template"""
        template = f"""
**Question**: {question}

**STAR Method Answer**:

**Situation** (Context):
- [Describe the context and background]
- [When did this happen? What was the challenge?]

**Task** (Your responsibility):
- [What was your specific role?]
- [What was the goal/objective?]

**Action** (What you did):
- [Step 1: What specific actions did you take?]
- [Step 2: How did you approach the problem?]
- [Step 3: What tools/technologies did you use?]

**Result** (Outcome + metrics):
- [Quantified outcome: X% improvement, $Y savings, Z users impacted]
- [What did you learn?]
- [How did this benefit the company/team?]

**Key Talking Points**:
- Emphasize: [leadership/technical depth/problem-solving]
- Metrics: [specific numbers]
- Technologies: [tools used]
"""
        return template
    
    def generate_prep_document(
        self,
        company_name: str,
        role: str,
        output_path: str
    ):
        """Generate comprehensive interview prep document"""
        print(f"\n{'='*60}")
        print(f"📚 INTERVIEW PREP: {company_name} - {role}")
        print(f"{'='*60}\n")
        
        # Research company
        company_research = self.research_company(company_name)
        
        # Get role-specific questions
        questions = self.get_role_questions(role)
        
        # Build prep document
        doc = f"""# Interview Preparation: {company_name} - {role}

**Prepared**: {datetime.now().strftime('%Y-%m-%d %H:%M')}
**Candidate**: {self.profile.get('name', 'Simon Renauld')}

---

## 📋 Company Research

### Overview
- **Industry**: {company_research['overview']['industry']}
- **Size**: {company_research['overview']['size']}
- **Founded**: {company_research['overview']['founded']}
- **HQ**: {company_research['overview']['headquarters']}

### Products/Services
{chr(10).join(f'- {p}' for p in company_research['products'])}

### Recent News
{chr(10).join(f'- {n}' for n in company_research['recent_news'])}

### Culture & Values
{chr(10).join(f'- {v}' for v in company_research['culture_values'])}

### Interview Process
**Typical Rounds**:
{chr(10).join(f'{i+1}. {r}' for i, r in enumerate(company_research['interview_process']['typical_rounds']))}

**Resources**:
{chr(10).join(f'- {r}' for r in company_research['interview_process']['resources'])}

### Salary Research
{chr(10).join(f'- {s}' for s in company_research['salary_benchmark']['sources'])}

---

## 🎯 Your Value Proposition

**Top 3 Achievements to Highlight**:

1. **Team Leadership & Delivery**
   - Coordinated multidisciplinary team of 50+ professionals
   - Improved delivery timelines by 30%
   - Reduced manual workload by 80% through automation

2. **Technical Excellence**
   - Architected enterprise ETL/DWH supporting 3x user growth
   - Processed 500M+ healthcare records with 99.9% reliability
   - 100% HIPAA compliance across all data systems

3. **Business Impact**
   - Saved ~$100K annually through process automation
   - 50% improvement in data quality
   - Reduced infrastructure costs by 40% via cloud migration

**Key Skills to Emphasize**:
{chr(10).join(f'- {skill}' for skill in self.profile.get('skills', {}).get('core', [])[:10])}

---

## 📝 Interview Questions & Preparation

"""
        # Add questions by category
        for category, question_list in questions.items():
            doc += f"\n### {category.replace('_', ' ').title()}\n\n"
            for i, question in enumerate(question_list[:5], 1):  # Top 5 per category
                doc += f"{i}. {question}\n"
                if i <= 2 and category == "behavioral":
                    # Add STAR template for first 2 behavioral questions
                    doc += self.generate_star_template(question)
                    doc += "\n"
            doc += "\n"
        
        # Add closing sections
        doc += """
---

## 🔧 Technical Deep Dive Prep

### System Design Topics
- Data pipeline architectures (batch vs. streaming)
- Database selection (OLTP vs. OLAP, SQL vs. NoSQL)
- Scalability patterns (sharding, replication, caching)
- Data quality frameworks
- Monitoring and observability

### Coding Topics
- SQL: Joins, window functions, CTEs, query optimization
- Python: Pandas, data processing, async programming
- Algorithms: Sorting, searching, graph traversal

### Technologies to Review
{chr(10).join(f'- {skill}' for skill in self.profile.get('skills', {}).get('core', []))}

---

## 💡 Questions to Ask Interviewer

### About the Role
1. What are the biggest challenges facing the data engineering team right now?
2. What does success look like in this role in the first 90 days?
3. How does this role interact with data science, analytics, and product teams?
4. What's the current data stack? Any planned migrations or upgrades?

### About the Team
1. What's the team structure? How many data engineers?
2. What's your approach to mentoring and professional development?
3. How do you handle on-call rotation and incident response?
4. What's the team's approach to code review and engineering best practices?

### About the Company
1. How does {company_name} differentiate from competitors?
2. What are the company's top priorities for the next 12 months?
3. How is the data engineering team measured? What are key metrics?
4. What opportunities are there for career growth and leadership?

---

## 📊 Preparation Checklist

### Before the Interview
- [ ] Review company website, blog, and recent news
- [ ] Check Glassdoor reviews and interview experiences
- [ ] Research interviewers on LinkedIn
- [ ] Prepare 3-5 STAR stories covering key competencies
- [ ] Review technical concepts (SQL, Python, system design)
- [ ] Prepare 5-10 thoughtful questions to ask
- [ ] Test video/audio setup (if virtual interview)

### Day of Interview
- [ ] Arrive 10 minutes early (or log in 5 min early for virtual)
- [ ] Have resume, notebook, and pen ready
- [ ] Keep water nearby
- [ ] Have portfolio/GitHub ready to share if asked
- [ ] Bring list of questions to ask

### After the Interview
- [ ] Send thank you email within 24 hours
- [ ] Note key points discussed for follow-up
- [ ] Update application tracker with interview notes
- [ ] Follow up with recruiter if no response in 1 week

---

## 🎤 Mock Interview Practice

**Practice with**:
- Pramp.com (peer mock interviews)
- Interviewing.io (anonymous technical interviews)
- LeetCode (SQL and coding challenges)
- YouTube (watch data engineering interview videos)

**Record yourself**:
- Practice answering questions on video
- Review body language and tone
- Time your answers (aim for 2-3 min per behavioral question)

---

**Good luck! 🚀**

*Portfolio*: https://www.simondatalab.de/
*LinkedIn*: https://www.linkedin.com/in/simonrenauld
*Resume*: [Attach to interview prep folder]
"""
        
        # Save document
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'w') as f:
            f.write(doc)
        
        print(f"✅ Interview prep document saved: {output_path}")
        print(f"\n📖 Review the document and customize STAR answers with your specific examples.")
        print(f"💪 Practice answering questions out loud before the interview!\n")


def main():
    parser = argparse.ArgumentParser(description="Interview Prep Assistant")
    parser.add_argument("--company", required=True, help="Company name")
    parser.add_argument("--role", required=True, help="Job title/role")
    parser.add_argument("--output", default="outputs/interview_notes", help="Output directory")
    parser.add_argument("--generate-report", action="store_true", help="Generate full prep document")
    
    args = parser.parse_args()
    
    # Initialize assistant
    assistant = InterviewPrepAssistant()
    
    # Generate prep document
    if args.generate_report:
        timestamp = datetime.now().strftime("%Y%m%d")
        filename = f"interview_prep_{args.company.lower().replace(' ', '_')}_{timestamp}.md"
        output_path = os.path.join(args.output, filename)
        
        assistant.generate_prep_document(args.company, args.role, output_path)
    else:
        # Just show questions
        questions = assistant.get_role_questions(args.role)
        print(f"\n📝 Interview Questions for {args.role}:\n")
        for category, question_list in questions.items():
            print(f"\n{category.replace('_', ' ').title()}:")
            for i, q in enumerate(question_list[:3], 1):
                print(f"  {i}. {q}")


if __name__ == "__main__":
    main()
