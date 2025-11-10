#!/usr/bin/env python3
"""
Resume Auto-Adjuster - Customize resume per job
================================================

Analyzes job descriptions and automatically adjusts resume for:
- Keyword matching and ATS optimization
- Skill prioritization based on job requirements
- Experience highlighting relevant to role
- Formatting for ATS systems (no graphics, proper formatting)
- PDF export of tailored resume
- Automated email delivery to recruiter

Author: Simon Renauld
Date: November 10, 2025
"""

import json
import os
import sqlite3
import subprocess
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import logging

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ResumeAutoAdjuster:
    """Automatically customize resume for job applications"""
    
    def __init__(self):
        self.base_dir = Path(__file__).parent
        self.data_dir = self.base_dir / "data"
        self.output_dir = self.base_dir / "outputs" / "resumes"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Master resume content (ATS-safe format)
        self.master_resume = self._load_master_resume()
        
        # Skill taxonomy
        self.skill_taxonomy = self._load_skill_taxonomy()
        
        logger.info("✅ Resume Auto-Adjuster initialized")
    
    def _load_master_resume(self) -> Dict:
        """Load master resume content"""
        return {
            "header": {
                "name": "Simon Renauld",
                "title": "Senior Data Engineer & Analytics Professional",
                "email": "contact@simondatalab.de",
                "phone": "+84 (preferred LinkedIn)",
                "linkedin": "linkedin.com/in/simonrenauld",
                "location": "Ho Chi Minh City, Vietnam (Willing to relocate to Australia)"
            },
            "summary": "15+ years data engineering, analytics, and platform architecture. Specialized in distributed systems (Spark, Kafka, Airflow), cloud platforms (AWS, GCP, Azure), and large-scale data pipelines. Proven track record: built 100M+ event/day systems, led 50-person teams, drove $10M+ revenue initiatives. Seeks challenging role in Tier-1 tech company working on high-impact problems.",
            "core_skills": {
                "languages": ["Python", "SQL", "Scala", "Java", "Go", "Rust"],
                "data_platforms": ["Apache Spark", "Apache Airflow", "Apache Kafka", "Flink", "Hive", "Presto"],
                "cloud": ["AWS (EC2, S3, RDS, Redshift, Lambda, EMR)", "GCP (Dataflow, BigQuery)", "Azure (Databricks, Data Factory)"],
                "databases": ["PostgreSQL", "MySQL", "MongoDB", "Cassandra", "Redis", "DynamoDB", "Snowflake"],
                "big_data": ["Hadoop", "Hbase", "Pig", "Mahout", "Druid", "Elasticsearch"],
                "ml_frameworks": ["TensorFlow", "PyTorch", "Scikit-learn", "XGBoost", "LightGBM"],
                "tools": ["Git", "Docker", "Kubernetes", "Jenkins", "Terraform", "Ansible", "Jupyter", "DBT"],
                "soft_skills": ["Leadership", "Team Building", "Mentoring", "Project Management", "Cross-functional Collaboration"]
            },
            "experience": [
                {
                    "title": "Senior Data Engineer",
                    "company": "Tech Company A",
                    "duration": "2020-2023",
                    "highlights": [
                        "Designed and implemented 100M+ event/day data pipeline using Spark + Kafka + Airflow",
                        "Reduced data processing latency by 70% through optimization and caching strategies",
                        "Led team of 8 engineers in building real-time analytics platform",
                        "Mentored 5 junior engineers; 2 promoted to senior roles",
                        "Managed $5M budget for data infrastructure and tooling"
                    ]
                },
                {
                    "title": "Data Engineer",
                    "company": "Tech Company B",
                    "duration": "2017-2020",
                    "highlights": [
                        "Built ETL pipelines processing 50TB+ daily data",
                        "Implemented Kubernetes cluster managing 200+ jobs daily",
                        "Designed data warehouse architecture supporting 1000+ concurrent users",
                        "Reduced infrastructure costs by 40% through optimization",
                        "Trained 20+ analysts on data tools and best practices"
                    ]
                },
                {
                    "title": "Data Analyst",
                    "company": "Tech Company C",
                    "duration": "2015-2017",
                    "highlights": [
                        "Developed 50+ dashboards used by 500+ internal users",
                        "Created data models improving forecast accuracy by 25%",
                        "Automated 80% of monthly reporting process",
                        "Advised C-suite on data-driven decisions ($10M+ revenue impact)"
                    ]
                }
            ],
            "education": [
                {
                    "degree": "B.S. Computer Science",
                    "institution": "University Name",
                    "year": "2009"
                }
            ],
            "certifications": [
                "AWS Certified Solutions Architect - Professional",
                "Google Cloud Professional Data Engineer",
                "Databricks Certified Associate Data Engineer",
                "Kubernetes Administrator (CKA)"
            ]
        }
    
    def _load_skill_taxonomy(self) -> Dict:
        """Load skill taxonomy for job matching"""
        return {
            "data_engineering": ["Spark", "Airflow", "Kafka", "Flink", "ETL", "Data Pipeline"],
            "big_data": ["Hadoop", "Hive", "Hbase", "Pig", "Cassandra", "Scala"],
            "cloud": ["AWS", "GCP", "Azure", "Databricks", "Redshift", "BigQuery", "Snowflake"],
            "ml": ["TensorFlow", "PyTorch", "Scikit-learn", "Machine Learning", "ML Ops", "Feature Engineering"],
            "backend": ["Python", "Java", "Go", "Rust", "Microservices", "APIs", "Distributed Systems"],
            "databases": ["SQL", "PostgreSQL", "MongoDB", "Redis", "NoSQL", "Data Warehouse"],
            "devops": ["Docker", "Kubernetes", "Jenkins", "Terraform", "Infrastructure", "CI/CD"],
            "analytics": ["SQL Analytics", "Dashboard", "Data Analysis", "Business Intelligence", "Tableau", "Looker"]
        }
    
    def extract_job_keywords(self, job_description: str) -> Dict[str, List[str]]:
        """Extract keywords from job description"""
        keywords = {
            "required": [],
            "preferred": [],
            "technologies": [],
            "seniority": "unknown"
        }
        
        text_lower = job_description.lower()
        
        # Extract seniority level
        if any(x in text_lower for x in ["senior", "lead", "staff", "principal"]):
            keywords["seniority"] = "senior"
        elif any(x in text_lower for x in ["junior", "entry", "graduate"]):
            keywords["seniority"] = "junior"
        else:
            keywords["seniority"] = "mid"
        
        # Extract technologies from job description
        for category, techs in self.skill_taxonomy.items():
            for tech in techs:
                if tech.lower() in text_lower:
                    keywords["technologies"].append(tech)
                    if "required" in text_lower[:text_lower.find(tech)]:
                        keywords["required"].append(tech)
                    elif "preferred" in text_lower[:text_lower.find(tech)]:
                        keywords["preferred"].append(tech)
        
        # Remove duplicates
        keywords["required"] = list(set(keywords["required"]))
        keywords["preferred"] = list(set(keywords["preferred"]))
        keywords["technologies"] = list(set(keywords["technologies"]))
        
        return keywords
    
    def score_match(self, job_keywords: Dict, master_skills: Dict) -> float:
        """Score how well resume matches job"""
        score = 0.0
        total_possible = 0
        
        # Required skills (weight: 2x)
        for skill in job_keywords.get("required", []):
            total_possible += 2
            for category, skills in master_skills.items():
                if any(s.lower() == skill.lower() for s in skills):
                    score += 2
                    break
        
        # Preferred skills (weight: 1x)
        for skill in job_keywords.get("preferred", []):
            total_possible += 1
            for category, skills in master_skills.items():
                if any(s.lower() == skill.lower() for s in skills):
                    score += 1
                    break
        
        # Technologies (weight: 0.5x)
        for tech in job_keywords.get("technologies", []):
            total_possible += 0.5
            for category, skills in master_skills.items():
                if any(s.lower() == tech.lower() for s in skills):
                    score += 0.5
                    break
        
        if total_possible == 0:
            return 0.0
        
        return min(100, (score / total_possible) * 100)
    
    def generate_custom_resume(self, job_title: str, job_description: str, 
                              company: str, job_id: str = None) -> Dict:
        """Generate resume customized for specific job"""
        
        logger.info(f"🔄 Generating custom resume for {job_title} @ {company}")
        
        # Extract job keywords
        keywords = self.extract_job_keywords(job_description)
        
        # Score match
        match_score = self.score_match(keywords, self.master_resume["core_skills"])
        
        logger.info(f"   Match Score: {match_score:.1f}%")
        logger.info(f"   Required Skills: {', '.join(keywords['required'][:3])}")
        logger.info(f"   Technologies: {', '.join(keywords['technologies'][:5])}")
        
        # Create customized resume
        custom_resume = {
            "metadata": {
                "job_title": job_title,
                "company": company,
                "job_id": job_id,
                "generated_at": datetime.now().isoformat(),
                "match_score": match_score,
                "keywords": keywords
            },
            "header": self.master_resume["header"],
            "summary": self._customize_summary(keywords, job_title),
            "core_skills": self._prioritize_skills(keywords),
            "experience": self._highlight_experience(keywords, job_description),
            "education": self.master_resume["education"],
            "certifications": self.master_resume["certifications"]
        }
        
        return custom_resume
    
    def _customize_summary(self, keywords: Dict, job_title: str) -> str:
        """Customize summary based on job keywords"""
        seniority_text = {
            "senior": "15+ years",
            "mid": "10+ years",
            "junior": "5+ years"
        }
        years = seniority_text.get(keywords["seniority"], "10+")
        
        summary = f"{years} data engineering, analytics, and platform architecture. Specialized in "
        
        # Add top 3 technologies
        top_techs = keywords["technologies"][:3]
        summary += ", ".join(top_techs) + ". "
        
        summary += "Proven track record building scalable systems, leading teams, and delivering business impact. Seeking challenging role in innovative organization."
        
        return summary
    
    def _prioritize_skills(self, keywords: Dict) -> Dict:
        """Prioritize skills based on job requirements"""
        prioritized = {}
        
        # Categorize and prioritize
        for category, skills in self.master_resume["core_skills"].items():
            matched_skills = []
            other_skills = []
            
            for skill in skills:
                if skill in keywords.get("required", []):
                    matched_skills.insert(0, skill)  # Required skills first
                elif skill in keywords.get("technologies", []):
                    matched_skills.append(skill)
                else:
                    other_skills.append(skill)
            
            # Combine: required/preferred first, then other relevant, then rest
            prioritized[category] = matched_skills + other_skills
        
        return prioritized
    
    def _highlight_experience(self, keywords: Dict, job_description: str) -> List[Dict]:
        """Highlight most relevant experience"""
        highlighted = []
        
        for exp in self.master_resume["experience"]:
            # Score experience based on keywords match
            highlights = []
            for original_highlight in exp["highlights"]:
                highlight_score = 0
                for keyword in keywords.get("technologies", []):
                    if keyword.lower() in original_highlight.lower():
                        highlight_score += 1
                
                # Re-score with job-specific terms
                if "pipeline" in job_description.lower() and "pipeline" in original_highlight.lower():
                    highlight_score += 2
                if "team" in job_description.lower() and ("team" in original_highlight.lower() or "engineer" in original_highlight.lower()):
                    highlight_score += 1
                if "leader" in job_description.lower() and "Led" in original_highlight:
                    highlight_score += 2
                
                highlights.append((original_highlight, highlight_score))
            
            # Sort by score and take top highlights
            highlights.sort(key=lambda x: x[1], reverse=True)
            exp["highlights"] = [h[0] for h in highlights[:3]]  # Top 3 highlights per role
            
            highlighted.append(exp)
        
        return highlighted
    
    def export_resume_text(self, custom_resume: Dict) -> str:
        """Export resume as ATS-friendly plain text"""
        text = []
        
        # Header
        meta = custom_resume["metadata"]
        text.append("=" * 80)
        text.append(f"CUSTOMIZED FOR: {meta['job_title']} @ {meta['company']}")
        text.append(f"MATCH SCORE: {meta['match_score']:.1f}%")
        text.append("=" * 80)
        text.append("")
        
        # Contact info
        header = custom_resume["header"]
        text.append(f"{header['name']} | {header['title']}")
        text.append(f"Email: {header['email']} | LinkedIn: {header['linkedin']}")
        text.append(f"Location: {header['location']}")
        text.append("")
        
        # Summary
        text.append("PROFESSIONAL SUMMARY")
        text.append("-" * 80)
        text.append(custom_resume["summary"])
        text.append("")
        
        # Skills (prioritized)
        text.append("CORE COMPETENCIES")
        text.append("-" * 80)
        for category, skills in custom_resume["core_skills"].items():
            text.append(f"{category.replace('_', ' ').title()}: {', '.join(skills[:8])}")
        text.append("")
        
        # Experience
        text.append("PROFESSIONAL EXPERIENCE")
        text.append("-" * 80)
        for exp in custom_resume["experience"]:
            text.append(f"{exp['title']} | {exp['company']} ({exp['duration']})")
            for highlight in exp["highlights"]:
                text.append(f"• {highlight}")
            text.append("")
        
        # Education
        text.append("EDUCATION")
        text.append("-" * 80)
        for edu in custom_resume["education"]:
            text.append(f"{edu['degree']} - {edu['institution']} ({edu['year']})")
        text.append("")
        
        # Certifications
        text.append("CERTIFICATIONS")
        text.append("-" * 80)
        for cert in custom_resume["certifications"]:
            text.append(f"✓ {cert}")
        text.append("")
        
        return "\n".join(text)
    
    def export_resume_json(self, custom_resume: Dict, job_id: str) -> str:
        """Export resume as JSON"""
        return json.dumps(custom_resume, indent=2)
    
    def save_resume(self, custom_resume: Dict, job_id: str, format_type: str = "both"):
        """Save customized resume"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        if format_type in ["text", "both"]:
            text_content = self.export_resume_text(custom_resume)
            text_path = self.output_dir / f"resume_{job_id}_{timestamp}.txt"
            text_path.write_text(text_content)
            logger.info(f"   ✅ Text resume saved: {text_path}")
        
        if format_type in ["json", "both"]:
            json_content = self.export_resume_json(custom_resume, job_id)
            json_path = self.output_dir / f"resume_{job_id}_{timestamp}.json"
            json_path.write_text(json_content)
            logger.info(f"   ✅ JSON resume saved: {json_path}")
        
        return text_path if format_type in ["text", "both"] else json_path
    
    def print_resume(self, custom_resume: Dict):
        """Print resume to console"""
        print(self.export_resume_text(custom_resume))
    
    def export_resume_pdf(self, custom_resume: Dict, job_id: str) -> Optional[Path]:
        """Export resume as PDF using pandoc (if available)"""
        try:
            text_content = self.export_resume_text(custom_resume)
            md_path = self.output_dir / f"resume_{job_id}_temp.md"
            md_path.write_text(text_content)
            
            pdf_path = self.output_dir / f"resume_{job_id}.pdf"
            result = subprocess.run(
                ['pandoc', str(md_path), '-o', str(pdf_path)],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                md_path.unlink()  # Clean up temp markdown
                logger.info(f"   ✅ PDF resume saved: {pdf_path}")
                return pdf_path
            else:
                logger.warning(f"   ⚠️  Pandoc error: {result.stderr}. Skipping PDF generation.")
                return None
        except FileNotFoundError:
            logger.warning("   ⚠️  Pandoc not installed. Skipping PDF generation. Install with: sudo apt install pandoc")
            return None
        except Exception as e:
            logger.warning(f"   ⚠️  PDF export failed: {e}")
            return None
    
    def send_resume_email(self, custom_resume: Dict, job_id: str, recruiter_email: str, 
                         recruiter_name: str = "Recruiter", pdf_path: Optional[Path] = None) -> bool:
        """Send tailored resume and cover letter to recruiter via email"""
        try:
            # Generate cover letter
            cover_letter = self._generate_cover_letter(custom_resume)
            
            # Setup email
            sender_email = "contact@simondatalab.de"
            sender_password = os.getenv("EMAIL_PASSWORD", "")  # Set via environment variable
            
            if not sender_password:
                logger.warning("   ⚠️  EMAIL_PASSWORD not set. Skipping email delivery.")
                logger.info("   Set via: export EMAIL_PASSWORD='your_app_password'")
                return False
            
            # Create message
            message = MIMEMultipart("alternative")
            message["Subject"] = f"Application: {custom_resume['metadata']['job_title']} @ {custom_resume['metadata']['company']}"
            message["From"] = sender_email
            message["To"] = recruiter_email
            
            # Email body
            body = f"""Dear {recruiter_name},

Please find attached my resume for the {custom_resume['metadata']['job_title']} position at {custom_resume['metadata']['company']}.

I am very interested in this opportunity and believe my experience in {', '.join(custom_resume['metadata']['keywords'].get('technologies', [])[:3])} aligns well with your needs.

I would welcome the chance to discuss how I can contribute to your team.

Best regards,
Simon Renauld
contact@simondatalab.de
linkedin.com/in/simonrenauld

---
Match Score: {custom_resume['metadata']['match_score']:.1f}%
"""
            
            part1 = MIMEText(body, "plain")
            message.attach(part1)
            
            # Attach resume (text)
            text_path = self.output_dir / f"resume_{job_id}.txt"
            if text_path.exists():
                with open(text_path, "rb") as attachment:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(attachment.read())
                encoders.encode_base64(part)
                part.add_header("Content-Disposition", f"attachment; filename= resume_{job_id}.txt")
                message.attach(part)
            
            # Attach PDF if available
            if pdf_path and pdf_path.exists():
                with open(pdf_path, "rb") as attachment:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(attachment.read())
                encoders.encode_base64(part)
                part.add_header("Content-Disposition", f"attachment; filename= resume_{job_id}.pdf")
                message.attach(part)
            
            # Send email (using Gmail SMTP; for other providers, adjust host/port)
            try:
                server = smtplib.SMTP_SSL("smtp.gmail.com", 465, timeout=10)
                server.login(sender_email, sender_password)
                server.sendmail(sender_email, recruiter_email, message.as_string())
                server.quit()
                logger.info(f"   ✅ Email sent to {recruiter_email}")
                return True
            except smtplib.SMTPAuthenticationError:
                logger.error(f"   ❌ Email auth failed. Check EMAIL_PASSWORD.")
                return False
            except Exception as e:
                logger.error(f"   ❌ Email send failed: {e}")
                return False
        
        except Exception as e:
            logger.error(f"   ❌ Email preparation failed: {e}")
            return False
    
    def _generate_cover_letter(self, custom_resume: Dict) -> str:
        """Generate cover letter from resume metadata"""
        meta = custom_resume["metadata"]
        keywords = meta.get("keywords", {})
        top_skills = keywords.get("technologies", [])[:3]
        
        cover_letter = f"""Dear Hiring Manager,

I am writing to express my strong interest in the {meta['job_title']} position at {meta['company']}.

With {custom_resume['summary'][:100]}... and deep expertise in {', '.join(top_skills)}, I am confident I can make significant contributions to your team.

Throughout my career, I have:
• Built and led high-performing engineering teams
• Designed scalable systems processing massive data volumes
• Delivered measurable business impact through technical innovation
• Mentored junior engineers and fostered collaborative environments

I am excited about the opportunity to bring my experience to {meta['company']} and contribute to your ambitious goals. I am available for interviews at your earliest convenience.

Thank you for considering my application. I look forward to discussing how I can add value to your organization.

Best regards,
Simon Renauld
contact@simondatalab.de
linkedin.com/in/simonrenauld
"""
        return cover_letter
    
    def process_job_and_send(self, job_title: str, job_description: str, company: str, 
                            recruiter_email: str, recruiter_name: str = "Recruiter", 
                            job_id: str = None, generate_pdf: bool = True, 
                            send_email: bool = True) -> Dict:
        """End-to-end: generate tailored resume, PDF, and send to recruiter"""
        
        if not job_id:
            job_id = f"{company}_{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        print(f"\n{'='*80}")
        print(f"📧 PROCESSING & SENDING FOR: {job_title} @ {company}")
        print(f"{'='*80}")
        
        # Generate customized resume
        print(f"\n1️⃣  Generating customized resume...")
        custom_resume = self.generate_custom_resume(job_title, job_description, company, job_id)
        print(f"   Match Score: {custom_resume['metadata']['match_score']:.1f}%")
        
        # Save text and JSON
        print(f"\n2️⃣  Saving resume (text + JSON)...")
        self.save_resume(custom_resume, job_id, format_type="both")
        
        # Generate PDF (if requested and pandoc available)
        pdf_path = None
        if generate_pdf:
            print(f"\n3️⃣  Generating PDF...")
            pdf_path = self.export_resume_pdf(custom_resume, job_id)
        
        # Send email (if requested)
        email_sent = False
        if send_email:
            print(f"\n4️⃣  Sending email to {recruiter_email}...")
            email_sent = self.send_resume_email(custom_resume, job_id, recruiter_email, recruiter_name, pdf_path)
        
        result = {
            "job_id": job_id,
            "company": company,
            "job_title": job_title,
            "match_score": custom_resume['metadata']['match_score'],
            "resume_saved": True,
            "pdf_generated": pdf_path is not None,
            "email_sent": email_sent,
            "recruiter_email": recruiter_email,
            "timestamp": datetime.now().isoformat()
        }
        
        # Log to tracking database
        self._log_delivery(result)
        
        print(f"\n{'='*80}")
        print(f"✅ COMPLETE: {job_title} @ {company}")
        print(f"{'='*80}\n")
        
        return result
    
    def _log_delivery(self, result: Dict):
        """Log resume delivery to tracking database"""
        try:
            db_path = self.base_dir / "data" / "resume_delivery.db"
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS deliveries (
                    id TEXT PRIMARY KEY,
                    job_id TEXT,
                    company TEXT,
                    job_title TEXT,
                    match_score REAL,
                    recruiter_email TEXT,
                    email_sent BOOLEAN,
                    pdf_generated BOOLEAN,
                    timestamp TEXT
                )
            ''')
            
            cursor.execute('''
                INSERT INTO deliveries VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                result.get("job_id"),
                result.get("job_id"),
                result.get("company"),
                result.get("job_title"),
                result.get("match_score"),
                result.get("recruiter_email"),
                result.get("email_sent"),
                result.get("pdf_generated"),
                result.get("timestamp")
            ))
            
            conn.commit()
            conn.close()
            logger.info(f"   📊 Delivery logged to database")
        except Exception as e:
            logger.warning(f"   ⚠️  Failed to log delivery: {e}")


def main():
    """Main execution"""
    
    print("\n" + "=" * 80)
    print("🎯 RESUME AUTO-ADJUSTER - ENHANCED DEMO")
    print("=" * 80 + "\n")
    
    adjuster = ResumeAutoAdjuster()
    
    # Example job description
    sample_job = {
        "title": "Senior Data Engineer",
        "company": "Databricks",
        "recruiter_email": "recruiter@databricks.com",
        "recruiter_name": "Alice Johnson",
        "description": """
        We are seeking a Senior Data Engineer to join our platform team.
        
        Required Skills:
        - 5+ years data engineering experience
        - Expert-level Python and SQL
        - Deep experience with Apache Spark and Kafka
        - AWS or GCP experience
        - Distributed systems knowledge
        
        Preferred:
        - Leadership experience
        - Open source contributions
        - Machine learning systems
        - Real-time data processing
        
        Responsibilities:
        - Design and build data pipelines processing 100M+ events daily
        - Lead team of engineers
        - Optimize system performance
        - Mentor junior engineers
        """
    }
    
    # Method 1: Generate customized resume (basic)
    print("METHOD 1: Basic Resume Customization")
    print("-" * 80)
    custom = adjuster.generate_custom_resume(
        sample_job["title"],
        sample_job["description"],
        sample_job["company"],
        "demo_databricks_001"
    )
    print(f"✅ Match Score: {custom['metadata']['match_score']:.1f}%")
    adjuster.save_resume(custom, "demo_databricks_001")
    
    # Method 2: End-to-end with PDF + email (requires pandoc and EMAIL_PASSWORD)
    print("\n\nMETHOD 2: End-to-End with PDF + Email Delivery")
    print("-" * 80)
    print("NOTE: This requires:")
    print("  • pandoc installed (sudo apt install pandoc)")
    print("  • EMAIL_PASSWORD set (export EMAIL_PASSWORD='your_app_password')")
    print("\nSkipping actual email send for demo (would fail without EMAIL_PASSWORD)")
    print("But showing what would happen:\n")
    
    result = adjuster.process_job_and_send(
        sample_job["title"],
        sample_job["description"],
        sample_job["company"],
        sample_job["recruiter_email"],
        sample_job["recruiter_name"],
        job_id="demo_databricks_002",
        generate_pdf=True,
        send_email=False  # Set to True if EMAIL_PASSWORD is set
    )
    
    print(f"Result: {json.dumps(result, indent=2)}")
    
    logger.info("✅ Resume auto-adjuster enhanced demo complete!")


if __name__ == "__main__":
    main()
