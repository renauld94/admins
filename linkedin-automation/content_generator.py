#!/usr/bin/env python3
"""
LinkedIn Content Generator
Automatically generates LinkedIn posts from:
- Moodle course updates
- Portfolio achievements (simondatalab.de)
- Homelab/infrastructure updates
- Technical tutorials

Author: Simon Renauld
Created: November 4, 2025
"""

import os
import json
import requests
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict

from dotenv import load_dotenv

load_dotenv()

# Paths
BASE_DIR = Path(__file__).parent
CONFIG_DIR = BASE_DIR / "config"
CONTENT_DIR = BASE_DIR / "content"
OUTPUTS_DIR = BASE_DIR / "outputs" / "generated_content"

OUTPUTS_DIR.mkdir(parents=True, exist_ok=True)

# Brand voice from portfolio alignment
BRAND_VOICE = {
    "tone": "Professional, metrics-first, action-oriented",
    "no_emojis": True,
    "max_length": 1300,  # LinkedIn character limit
    "hashtags": 3,  # Max hashtags per post
}

# Content templates
TEMPLATES = {
    "course_launch": """New Course Available: {course_name}

{description}

What you'll learn:
{learning_outcomes}

Duration: {duration}
Level: {level}
Enrollment: {enrollment_url}

{hashtags}""",

    "portfolio_achievement": """{achievement_title}

{context}

Key Outcomes:
{metrics}

Technical Stack: {tech_stack}

Read the full case study: {link}

{hashtags}""",

    "homelab_update": """Infrastructure Update: {title}

{description}

What changed:
{changes}

Impact: {impact}

Technical details: {link}

{hashtags}""",

    "thought_leadership": """{headline}

{body}

Key Takeaways:
{takeaways}

{hashtags}""",

    "weekly_digest": """This Week in Data Engineering

{highlights}

Looking Ahead:
{next_week}

{hashtags}""",
}


@dataclass
class ContentPost:
    """Generated content post"""
    id: str
    title: str
    content: str
    content_type: str  # 'course', 'portfolio', 'homelab', 'thought_leadership'
    media_paths: List[str]
    media_type: str  # 'text', 'image', 'document'
    hashtags: List[str]
    link: Optional[str]
    created_at: str
    scheduled_for: Optional[str] = None


class ContentGenerator:
    """Main content generation class"""
    
    def __init__(self):
        self.moodle_url = os.getenv('MOODLE_URL', 'https://moodle.simondatalab.de')
        self.moodle_token = os.getenv('MOODLE_TOKEN', '')
        self.portfolio_url = os.getenv('PORTFOLIO_URL', 'https://www.simondatalab.de')
        
        # Load portfolio alignment
        with open(CONFIG_DIR / 'portfolio_alignment.json') as f:
            self.alignment = json.load(f)
    
    # ===== Moodle Integration =====
    
    def get_moodle_courses(self) -> List[Dict]:
        """Fetch courses from Moodle API"""
        if not self.moodle_token:
            print("⚠️ Moodle token not configured")
            return []
        
        try:
            endpoint = f"{self.moodle_url}/webservice/rest/server.php"
            params = {
                'wstoken': self.moodle_token,
                'wsfunction': 'core_course_get_courses',
                'moodlewsrestformat': 'json'
            }
            
            response = requests.get(endpoint, params=params, timeout=10)
            response.raise_for_status()
            courses = response.json()
            
            print(f"✅ Fetched {len(courses)} courses from Moodle")
            return courses
            
        except Exception as e:
            print(f"❌ Moodle API error: {e}")
            return []
    
    def get_course_enrollments(self, course_id: int) -> int:
        """Get enrollment count for a course"""
        if not self.moodle_token:
            return 0
        
        try:
            endpoint = f"{self.moodle_url}/webservice/rest/server.php"
            params = {
                'wstoken': self.moodle_token,
                'wsfunction': 'core_enrol_get_enrolled_users',
                'courseid': course_id,
                'moodlewsrestformat': 'json'
            }
            
            response = requests.get(endpoint, params=params, timeout=10)
            response.raise_for_status()
            users = response.json()
            
            return len(users)
            
        except Exception as e:
            print(f"❌ Enrollment count error: {e}")
            return 0
    
    def generate_course_launch_post(self, course: Dict) -> ContentPost:
        """Generate post for new course launch"""
        course_name = course.get('fullname', 'New Course')
        course_id = course.get('id', 0)
        description = course.get('summary', '')[:300]  # Truncate
        
        # Extract learning outcomes (if in description)
        outcomes = [
            "Master production-grade data pipelines",
            "Build scalable ETL/ELT systems",
            "Implement data quality frameworks"
        ]
        outcomes_text = "\n".join(f"• {o}" for o in outcomes)
        
        hashtags = ["#DataEngineering", "#Python", "#ETL"]
        
        content = TEMPLATES["course_launch"].format(
            course_name=course_name,
            description=description,
            learning_outcomes=outcomes_text,
            duration="8 weeks",
            level="Intermediate to Advanced",
            enrollment_url=f"{self.moodle_url}/course/view.php?id={course_id}",
            hashtags=" ".join(hashtags)
        )
        
        return ContentPost(
            id=f"course_{course_id}_{int(time.time())}",
            title=f"Course Launch: {course_name}",
            content=content,
            content_type="course",
            media_paths=[],
            media_type="text",
            hashtags=hashtags,
            link=f"{self.moodle_url}/course/view.php?id={course_id}",
            created_at=datetime.now().isoformat()
        )
    
    # ===== Portfolio Integration =====
    
    def generate_portfolio_achievement_post(self, achievement: Dict) -> ContentPost:
        """Generate post from portfolio case study"""
        title = achievement.get('title', 'Project Achievement')
        context = achievement.get('challenge', '')
        metrics = achievement.get('outcomes', [])
        tech_stack = achievement.get('tech_stack', [])
        
        metrics_text = "\n".join(f"• {m}" for m in metrics)
        tech_text = ", ".join(tech_stack)
        
        hashtags = ["#DataEngineering", "#Analytics", "#MLOps"]
        
        content = TEMPLATES["portfolio_achievement"].format(
            achievement_title=title,
            context=context,
            metrics=metrics_text,
            tech_stack=tech_text,
            link=f"{self.portfolio_url}/#case-studies",
            hashtags=" ".join(hashtags)
        )
        
        return ContentPost(
            id=f"portfolio_{int(time.time())}",
            title=title,
            content=content,
            content_type="portfolio",
            media_paths=[],
            media_type="text",
            hashtags=hashtags,
            link=f"{self.portfolio_url}/#case-studies",
            created_at=datetime.now().isoformat()
        )
    
    # ===== Homelab Content =====
    
    def generate_homelab_update_post(self, update: Dict) -> ContentPost:
        """Generate homelab infrastructure update post"""
        title = update.get('title', 'Infrastructure Update')
        description = update.get('description', '')
        changes = update.get('changes', [])
        impact = update.get('impact', '')
        
        changes_text = "\n".join(f"• {c}" for c in changes)
        
        hashtags = ["#Homelab", "#Infrastructure", "#DevOps"]
        
        content = TEMPLATES["homelab_update"].format(
            title=title,
            description=description,
            changes=changes_text,
            impact=impact,
            link=self.portfolio_url,
            hashtags=" ".join(hashtags)
        )
        
        # Check for carousel/diagrams
        media_paths = []
        carousel_dir = BASE_DIR / "outputs" / "social" / "carousel"
        if carousel_dir.exists():
            # Use latest carousel slides
            slides = sorted(carousel_dir.glob("slide-*.png"))
            if slides:
                media_paths = [str(s) for s in slides[:5]]
        
        return ContentPost(
            id=f"homelab_{int(time.time())}",
            title=title,
            content=content,
            content_type="homelab",
            media_paths=media_paths,
            media_type="image" if media_paths else "text",
            hashtags=hashtags,
            link=self.portfolio_url,
            created_at=datetime.now().isoformat()
        )
    
    # ===== Thought Leadership =====
    
    def generate_thought_leadership_post(self, topic: str, body: str, takeaways: List[str]) -> ContentPost:
        """Generate thought leadership content"""
        headline = topic
        takeaways_text = "\n".join(f"• {t}" for t in takeaways)
        
        hashtags = ["#DataStrategy", "#Leadership", "#DataEngineering"]
        
        content = TEMPLATES["thought_leadership"].format(
            headline=headline,
            body=body,
            takeaways=takeaways_text,
            hashtags=" ".join(hashtags)
        )
        
        return ContentPost(
            id=f"thought_{int(time.time())}",
            title=headline,
            content=content,
            content_type="thought_leadership",
            media_paths=[],
            media_type="text",
            hashtags=hashtags,
            link=None,
            created_at=datetime.now().isoformat()
        )
    
    # ===== Pre-built Content =====
    
    def get_healthcare_analytics_post(self) -> ContentPost:
        """Pre-built: Healthcare analytics thought leadership"""
        return self.generate_thought_leadership_post(
            topic="Why Healthcare Analytics Needs Engineering Excellence",
            body="""Healthcare data is uniquely challenging: high stakes, strict compliance (HIPAA, GDPR), and fragmented systems.

After processing 500M+ healthcare records, I've learned that clinical insights require more than just SQL and dashboards. You need:

1. Robust data governance frameworks
2. Automated quality validation pipelines
3. Complete audit trails and lineage tracking
4. Zero-downtime production systems (99.9%+ uptime)

The difference between a data scientist and a data engineer? Engineers build systems that work in production, at scale, under regulatory scrutiny.""",
            takeaways=[
                "Engineering rigor is non-negotiable in healthcare",
                "Automation reduces compliance risk",
                "Production-grade systems save lives (and costs)"
            ]
        )
    
    def get_homelab_mlops_post(self) -> ContentPost:
        """Pre-built: AI homelab content"""
        update = {
            "title": "Building an AI-Native Homelab for Private MLOps",
            "description": "Deployed ProxmoxMCP + Model Context Protocol for on-premise ML experimentation without cloud vendor lock-in.",
            "changes": [
                "Automated VM provisioning for ML workloads (< 2 min)",
                "GPU pass-through for training and inference",
                "Integrated monitoring (Grafana + MLflow)",
                "HIPAA-compliant data residency"
            ],
            "impact": "50% fewer manual interventions, 20% lower operational overhead, unlimited experiments on fixed budget"
        }
        return self.generate_homelab_update_post(update)
    
    def get_data_governance_post(self) -> ContentPost:
        """Pre-built: Data governance post"""
        return self.generate_thought_leadership_post(
            topic="Data Governance Is Not Optional (Especially in Healthcare)",
            body="""You can't build trust in analytics without governance.

In 2024, I implemented end-to-end data lineage tracking for a clinical research platform. The result? Zero compliance violations, 99.9% uptime, and executives who actually trust the dashboards.

Governance isn't bureaucracy. It's engineering discipline applied to data:
• Automated validation with Great Expectations
• Complete audit trails with OpenMetadata
• Access controls and data anonymization
• Real-time monitoring and alerting

When regulators ask "where did this number come from?" you better have an answer.""",
            takeaways=[
                "Governance enables trust, not slows it down",
                "Automation is key to compliance at scale",
                "Lineage tracking is table stakes for regulated industries"
            ]
        )
    
    def save_post(self, post: ContentPost):
        """Save generated post to file"""
        filename = OUTPUTS_DIR / f"{post.id}.json"
        with open(filename, 'w') as f:
            json.dump(asdict(post), f, indent=2)
        print(f"✅ Saved: {filename}")


# ===== CLI Functions =====

def generate_weekly_content():
    """Generate a week's worth of content"""
    generator = ContentGenerator()
    
    posts = [
        # Monday: Course/Training
        generator.get_healthcare_analytics_post(),
        
        # Wednesday: Homelab/Tech
        generator.get_homelab_mlops_post(),
        
        # Friday: Thought Leadership
        generator.get_data_governance_post(),
    ]
    
    # Schedule posts
    now = datetime.now()
    schedule_times = [
        now + timedelta(days=0, hours=9),   # Monday 9am
        now + timedelta(days=2, hours=10),  # Wednesday 10am
        now + timedelta(days=4, hours=14),  # Friday 2pm
    ]
    
    for post, schedule_time in zip(posts, schedule_times):
        post.scheduled_for = schedule_time.isoformat()
        generator.save_post(post)
    
    print(f"\n✅ Generated {len(posts)} posts for the week")
    print("\nSchedule:")
    for post, schedule_time in zip(posts, schedule_times):
        print(f"  {schedule_time.strftime('%A, %b %d at %I:%M %p')}: {post.title}")


if __name__ == "__main__":
    import sys
    import time
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python content_generator.py weekly        # Generate weekly content")
        print("  python content_generator.py healthcare    # Healthcare analytics post")
        print("  python content_generator.py homelab       # Homelab update post")
        print("  python content_generator.py governance    # Data governance post")
        sys.exit(1)
    
    command = sys.argv[1]
    generator = ContentGenerator()
    
    if command == "weekly":
        generate_weekly_content()
    
    elif command == "healthcare":
        post = generator.get_healthcare_analytics_post()
        generator.save_post(post)
        print(f"\n{post.content}\n")
    
    elif command == "homelab":
        post = generator.get_homelab_mlops_post()
        generator.save_post(post)
        print(f"\n{post.content}\n")
    
    elif command == "governance":
        post = generator.get_data_governance_post()
        generator.save_post(post)
        print(f"\n{post.content}\n")
    
    else:
        print(f"❌ Unknown command: {command}")
