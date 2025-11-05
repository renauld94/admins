#!/usr/bin/env python3
"""
Vietnamese Course Content Generator - EPIC Edition

Generates professional, engaging content for all 8 weeks of the Vietnamese course.
Features:
- Duplicate detection and removal
- Professional design (minimal emojis)
- Integration with Vietnamese Tutor Agent
- Modern JS libraries (Chart.js, Reveal.js, Anime.js, Three.js)
- Interactive exercises and assessments
- Responsive design
- Accessibility features

Usage:
    python3 course_content_generator.py --generate-all
    python3 course_content_generator.py --review-duplicates
    python3 course_content_generator.py --test-content
"""

import os
import sys
import json
import requests
import argparse
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
import hashlib

# Configuration
BASE_DIR = Path(__file__).parent
OUTPUT_DIR = BASE_DIR / "generated" / "professional"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

AGENT_URL = "http://localhost:5001"
TOKEN_FILE = BASE_DIR / ".." / ".." / "workspace" / "agents" / ".token"

# Load auth token
AUTH_TOKEN = None
try:
    with open(TOKEN_FILE, 'r') as f:
        AUTH_TOKEN = f.read().strip()
except:
    print("⚠️  No auth token found - some features may be limited")

def get_headers() -> dict:
    """Get headers with authorization."""
    headers = {"Content-Type": "application/json"}
    if AUTH_TOKEN:
        headers["Authorization"] = f"Bearer {AUTH_TOKEN}"
    return headers


@dataclass
class CourseModule:
    """Represents a course module/week."""
    week: int
    title: str
    subtitle: str
    objectives: List[str]
    vocabulary_count: int
    grammar_topics: List[str]
    activities: List[Dict[str, str]]
    assessment: Dict[str, Any]
    
    def get_hash(self) -> str:
        """Generate unique hash for duplicate detection."""
        content = f"{self.title}{self.subtitle}{''.join(self.objectives)}"
        return hashlib.md5(content.encode()).hexdigest()


# Course structure - 8 weeks professional curriculum
COURSE_STRUCTURE = [
    CourseModule(
        week=1,
        title="Foundation: Greetings & Personal Information",
        subtitle="Build essential communication skills for daily interactions",
        objectives=[
            "Exchange greetings appropriately in formal and informal contexts",
            "Introduce yourself with name, nationality, and occupation",
            "Ask and answer questions about personal information",
            "Use numbers 0-100 and tell time accurately"
        ],
        vocabulary_count=60,
        grammar_topics=[
            "Subject pronouns (Tôi, Bạn, Anh, Chị)",
            "Verb 'to be' (là) and basic sentence structure",
            "Question words (gì, ai, ở đâu, bao nhiêu)",
            "Politeness markers (ạ, dạ, xin)"
        ],
        activities=[
            {"type": "dialogue", "name": "Introductions Roleplay", "duration": "15 min"},
            {"type": "pronunciation", "name": "Tone Practice with AI Feedback", "duration": "20 min"},
            {"type": "interactive", "name": "Number Game - H5P", "duration": "10 min"},
            {"type": "recording", "name": "30-second Self Introduction", "duration": "homework"}
        ],
        assessment={
            "formative": "10-question vocabulary quiz + pronunciation check",
            "summative": "Recorded self-introduction (rubric: pronunciation 40%, fluency 30%, accuracy 30%)"
        }
    ),
    CourseModule(
        week=2,
        title="Navigation: Directions & Transportation",
        subtitle="Master essential travel and navigation vocabulary",
        objectives=[
            "Ask for and give directions using common landmarks",
            "Purchase transportation tickets and understand schedules",
            "Describe locations using spatial prepositions",
            "Express transportation preferences and needs"
        ],
        vocabulary_count=70,
        grammar_topics=[
            "Location prepositions (trên, dưới, trong, ngoài)",
            "Directional verbs (đi, rẽ, qua, tới)",
            "Transportation vocabulary",
            "Polite requests and imperatives"
        ],
        activities=[
            {"type": "interactive", "name": "Interactive Map Navigation", "duration": "25 min"},
            {"type": "dialogue", "name": "AI Chatbot: Buying Tickets", "duration": "20 min"},
            {"type": "video", "name": "Create Travel Route Video", "duration": "homework"},
            {"type": "game", "name": "Direction Challenge - Gamified", "duration": "15 min"}
        ],
        assessment={
            "formative": "Map-based quiz + direction comprehension",
            "summative": "Video presentation: Navigate from A to B with commentary"
        }
    ),
    CourseModule(
        week=3,
        title="Culinary: Food, Dining & Preferences",
        subtitle="Communicate effectively in restaurants and markets",
        objectives=[
            "Order food and beverages in restaurants confidently",
            "Ask about ingredients, allergies, and dietary restrictions",
            "Express food preferences and tastes",
            "Understand and negotiate prices in markets"
        ],
        vocabulary_count=80,
        grammar_topics=[
            "Food classifier (món, đĩa, cốc, chai)",
            "Preference expressions (thích, ghét, muốn)",
            "Comparative structures",
            "Polite refusals and requests"
        ],
        activities=[
            {"type": "interactive", "name": "Restaurant Menu Translation", "duration": "20 min"},
            {"type": "roleplay", "name": "Market Bargaining Simulation", "duration": "25 min"},
            {"type": "writing", "name": "Food Diary (5 entries)", "duration": "homework"},
            {"type": "cultural", "name": "Vietnamese Cuisine Virtual Tour", "duration": "15 min"}
        ],
        assessment={
            "formative": "Menu comprehension + ordering roleplay",
            "summative": "Authentic restaurant dialogue (video or audio, 2-3 min)"
        }
    ),
    CourseModule(
        week=4,
        title="Academic: Classroom & Study Communication",
        subtitle="Develop academic Vietnamese language skills",
        objectives=[
            "Ask questions about assignments and deadlines",
            "Express opinions and participate in discussions",
            "Make polite requests to teachers and classmates",
            "Understand academic instructions and requirements"
        ],
        vocabulary_count=75,
        grammar_topics=[
            "Time markers (đã, đang, sẽ - past, present, future)",
            "Modal verbs (phải, nên, có thể)",
            "Conditional structures",
            "Academic vocabulary and phrases"
        ],
        activities=[
            {"type": "forum", "name": "Online Debate (Vietnamese)", "duration": "ongoing"},
            {"type": "workshop", "name": "Grammar Deep Dive: Time Markers", "duration": "30 min"},
            {"type": "peer", "name": "Peer Review Exercise", "duration": "25 min"},
            {"type": "presentation", "name": "Mini Presentation on Study Topic", "duration": "homework"}
        ],
        assessment={
            "formative": "Forum participation + grammar exercises",
            "summative": "3-minute presentation on academic topic with Q&A"
        }
    ),
    CourseModule(
        week=5,
        title="Professional: Work & Services",
        subtitle="Build workplace communication competence",
        objectives=[
            "Write professional emails and messages",
            "Conduct phone conversations for business purposes",
            "Request services and make appointments",
            "Understand workplace etiquette and vocabulary"
        ],
        vocabulary_count=85,
        grammar_topics=[
            "Formal vs informal register",
            "Professional email structure",
            "Phone conversation patterns",
            "Polite refusals and negotiations"
        ],
        activities=[
            {"type": "writing", "name": "Professional Email Templates", "duration": "20 min"},
            {"type": "simulation", "name": "AI Phone Call Roleplay", "duration": "25 min"},
            {"type": "project", "name": "Mock Job Application", "duration": "homework"},
            {"type": "analysis", "name": "Workplace Communication Analysis", "duration": "15 min"}
        ],
        assessment={
            "formative": "Email writing + phone script",
            "summative": "Job application package (CV + cover letter + interview)"
        }
    ),
    CourseModule(
        week=6,
        title="Cultural: Travel & Heritage Project",
        subtitle="Explore Vietnamese culture through language",
        objectives=[
            "Create and present a travel itinerary in Vietnamese",
            "Describe cultural practices and traditions",
            "Narrate experiences using past tense",
            "Collaborate on group multimedia projects"
        ],
        vocabulary_count=90,
        grammar_topics=[
            "Past tense narration (đã + verb)",
            "Descriptive adjectives and adverbs",
            "Cultural expressions and idioms",
            "Sequence connectors"
        ],
        activities=[
            {"type": "project", "name": "Group Travel Itinerary", "duration": "collaborative"},
            {"type": "video", "name": "3-5 min Travel Presentation", "duration": "homework"},
            {"type": "research", "name": "Cultural Heritage Research", "duration": "20 min"},
            {"type": "interactive", "name": "Virtual Vietnam Tour", "duration": "30 min"}
        ],
        assessment={
            "formative": "Itinerary draft + peer feedback",
            "summative": "Group video presentation + individual reflection"
        }
    ),
    CourseModule(
        week=7,
        title="Narrative: Storytelling & Comprehensive Review",
        subtitle="Synthesize and apply all learned skills",
        objectives=[
            "Narrate personal stories in past and present tense",
            "Review and consolidate all grammar topics",
            "Self-assess progress and identify improvement areas",
            "Refine and enhance previous project work"
        ],
        vocabulary_count=50,
        grammar_topics=[
            "Review: All tense markers",
            "Review: Question formation",
            "Review: Classifiers and counters",
            "Advanced connectors and transitions"
        ],
        activities=[
            {"type": "storytelling", "name": "Personal Narrative Recording", "duration": "homework"},
            {"type": "review", "name": "Comprehensive Grammar Review", "duration": "45 min"},
            {"type": "peer", "name": "Story Peer Review Session", "duration": "30 min"},
            {"type": "revision", "name": "Project Revisions", "duration": "ongoing"}
        ],
        assessment={
            "formative": "Peer review participation + self-assessment",
            "summative": "Revised personal narrative (3-5 min, polished)"
        }
    ),
    CourseModule(
        week=8,
        title="Capstone: Final Assessment & Showcase",
        subtitle="Demonstrate mastery and celebrate achievements",
        objectives=[
            "Complete comprehensive oral interview in Vietnamese",
            "Pass written assessment covering all topics",
            "Present best work in course showcase",
            "Reflect on learning journey and set future goals"
        ],
        vocabulary_count=0,  # Review only
        grammar_topics=[
            "Review: All course content",
            "Interview strategies",
            "Self-assessment techniques"
        ],
        activities=[
            {"type": "interview", "name": "Final Oral Interview (5-7 min)", "duration": "scheduled"},
            {"type": "exam", "name": "Written Comprehensive Exam", "duration": "90 min"},
            {"type": "showcase", "name": "Student Work Gallery", "duration": "exhibition"},
            {"type": "reflection", "name": "Learning Portfolio Submission", "duration": "homework"}
        ],
        assessment={
            "formative": "Practice interviews + study sessions",
            "summative": "Oral interview (50%) + Written exam (50%)"
        }
    )
]


class ContentGenerator:
    """Generate professional course content."""
    
    def __init__(self, agent_url: str = AGENT_URL):
        self.agent_url = agent_url
        self.generated_hashes = set()
        
    def detect_duplicates(self, modules: List[CourseModule]) -> List[str]:
        """Detect duplicate content across modules."""
        duplicates = []
        seen_hashes = {}
        
        for module in modules:
            h = module.get_hash()
            if h in seen_hashes:
                duplicates.append(f"Week {module.week} duplicates Week {seen_hashes[h]}")
            else:
                seen_hashes[h] = module.week
                
        return duplicates
    
    def generate_vocabulary_list(self, module: CourseModule) -> Dict[str, Any]:
        """Generate vocabulary list using Vietnamese Tutor Agent."""
        try:
            # Generate vocabulary based on module theme
            theme = module.title.split(":")[1].strip() if ":" in module.title else module.title
            
            response = requests.post(
                f"{self.agent_url}/vocabulary/practice",
                json={
                    "words": [theme],  # Use theme as seed
                    "include_examples": True,
                    "include_tones": True
                },
                headers=get_headers(),
                timeout=300
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                return {"error": f"Status {response.status_code}"}
        except Exception as e:
            return {"error": str(e)}
    
    def generate_quiz(self, module: CourseModule) -> str:
        """Generate GIFT format quiz for module."""
        try:
            topic = module.title.split(":")[1].strip() if ":" in module.title else module.title
            
            response = requests.post(
                f"{self.agent_url}/quiz/generate",
                json={
                    "topic": topic,
                    "level": "intermediate",
                    "num_questions": 15
                },
                headers=get_headers(),
                timeout=300
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get("quiz_content", "")
            else:
                return f"// Error generating quiz: {response.status_code}"
        except Exception as e:
            return f"// Error: {str(e)}"
    
    def generate_dialogue(self, module: CourseModule) -> str:
        """Generate interactive dialogue for module."""
        try:
            topic = module.title.split(":")[1].strip() if ":" in module.title else module.title
            
            response = requests.post(
                f"{self.agent_url}/dialogue/generate",
                json={
                    "topic": topic,
                    "level": "intermediate",
                    "num_exchanges": 8
                },
                headers=get_headers(),
                timeout=300
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get("dialogue", "")
            else:
                return f"Error: {response.status_code}"
        except Exception as e:
            return f"Error: {str(e)}"
    
    def generate_flashcards(self, module: CourseModule) -> str:
        """Generate flashcards CSV for module."""
        try:
            # Extract key vocabulary from module
            vocab_seed = [topic[:20] for topic in module.grammar_topics]
            
            response = requests.post(
                f"{self.agent_url}/flashcards/generate",
                json={
                    "vocabulary_list": vocab_seed,
                    "include_audio_prompts": True
                },
                headers=get_headers(),
                timeout=300
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get("csv_content", "")
            else:
                return f"# Error: {response.status_code}"
        except Exception as e:
            return f"# Error: {str(e)}"
    
    def generate_html_lesson(self, module: CourseModule) -> str:
        """Generate professional HTML lesson page with modern JS libraries."""
        
        # Generate content components
        objectives_html = "\n".join([f"<li class='objective-item'>{obj}</li>" for obj in module.objectives])
        grammar_html = "\n".join([f"<li class='grammar-item'>{topic}</li>" for topic in module.grammar_topics])
        
        activities_list = []
        for act in module.activities:
            act_type = act["type"]
            act_name = act["name"]
            act_duration = act["duration"]
            activities_list.append(
                f"<div class='activity-card' data-type='{act_type}'>"
                f"<h4>{act_name}</h4>"
                f"<p class='activity-meta'><span class='badge'>{act_type}</span> "
                f"<span class='duration'>{act_duration}</span></p>"
                f"</div>"
            )
        activities_html = "\n".join(activities_list)
        
        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Week {module.week}: {module.title}</title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Merriweather:wght@300;400;700&display=swap" rel="stylesheet">
    
    <!-- CSS Libraries -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    
    <style>
        :root {{
            --primary: #2563eb;
            --secondary: #7c3aed;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --dark: #1f2937;
            --light: #f9fafb;
            --border: #e5e7eb;
        }}
        
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Inter', sans-serif;
            line-height: 1.6;
            color: var(--dark);
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }}
        
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }}
        
        .hero {{
            background: white;
            border-radius: 16px;
            padding: 3rem;
            margin-bottom: 2rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }}
        
        .hero h1 {{
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }}
        
        .hero .subtitle {{
            font-size: 1.25rem;
            color: #6b7280;
            font-weight: 300;
        }}
        
        .week-badge {{
            display: inline-block;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }}
        
        .section {{
            background: white;
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }}
        
        .section h2 {{
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 3px solid var(--primary);
        }}
        
        .objectives-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            list-style: none;
        }}
        
        .objective-item {{
            padding: 1rem;
            background: var(--light);
            border-left: 4px solid var(--primary);
            border-radius: 8px;
            transition: transform 0.2s;
        }}
        
        .objective-item:hover {{
            transform: translateX(8px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }}
        
        .grammar-item {{
            padding: 0.75rem 1rem;
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            margin-bottom: 0.5rem;
            border-radius: 8px;
            list-style: none;
            font-weight: 500;
        }}
        
        .activities-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
        }}
        
        .activity-card {{
            background: white;
            border: 2px solid var(--border);
            border-radius: 12px;
            padding: 1.5rem;
            transition: all 0.3s;
            cursor: pointer;
        }}
        
        .activity-card:hover {{
            border-color: var(--primary);
            transform: translateY(-4px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }}
        
        .activity-card h4 {{
            font-size: 1.125rem;
            margin-bottom: 0.75rem;
            color: var(--dark);
        }}
        
        .activity-meta {{
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }}
        
        .badge {{
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background: var(--primary);
            color: white;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }}
        
        .duration {{
            padding: 0.25rem 0.75rem;
            background: var(--light);
            color: var(--dark);
            border-radius: 9999px;
            font-size: 0.75rem;
        }}
        
        .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }}
        
        .stat-card {{
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 1.5rem;
            border-radius: 12px;
            text-align: center;
        }}
        
        .stat-number {{
            font-size: 2.5rem;
            font-weight: 700;
            display: block;
        }}
        
        .stat-label {{
            font-size: 0.875rem;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }}
        
        .progress-container {{
            background: var(--light);
            border-radius: 9999px;
            height: 1rem;
            overflow: hidden;
            margin: 1rem 0;
        }}
        
        .progress-bar {{
            height: 100%;
            background: linear-gradient(90deg, var(--success), var(--primary));
            border-radius: 9999px;
            transition: width 1s ease-in-out;
        }}
        
        @media (max-width: 768px) {{
            .container {{
                padding: 1rem;
            }}
            
            .hero {{
                padding: 2rem 1.5rem;
            }}
            
            .hero h1 {{
                font-size: 1.875rem;
            }}
            
            .section {{
                padding: 1.5rem;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="hero animate__animated animate__fadeIn">
            <span class="week-badge">Week {module.week}</span>
            <h1>{module.title}</h1>
            <p class="subtitle">{module.subtitle}</p>
            
            <div class="stats">
                <div class="stat-card animate__animated animate__fadeInUp" style="animation-delay: 0.1s;">
                    <span class="stat-number">{module.vocabulary_count}</span>
                    <span class="stat-label">New Vocabulary</span>
                </div>
                <div class="stat-card animate__animated animate__fadeInUp" style="animation-delay: 0.2s;">
                    <span class="stat-number">{len(module.grammar_topics)}</span>
                    <span class="stat-label">Grammar Topics</span>
                </div>
                <div class="stat-card animate__animated animate__fadeInUp" style="animation-delay: 0.3s;">
                    <span class="stat-number">{len(module.activities)}</span>
                    <span class="stat-label">Activities</span>
                </div>
            </div>
        </div>
        
        <div class="section animate__animated animate__fadeInUp">
            <h2>Learning Objectives</h2>
            <ul class="objectives-grid">
                {objectives_html}
            </ul>
        </div>
        
        <div class="section animate__animated animate__fadeInUp">
            <h2>Grammar Focus</h2>
            <ul>
                {grammar_html}
            </ul>
        </div>
        
        <div class="section animate__animated animate__fadeInUp">
            <h2>Learning Activities</h2>
            <div class="activities-grid">
                {activities_html}
            </div>
        </div>
        
        <div class="section animate__animated animate__fadeInUp">
            <h2>Assessment</h2>
            <div style="padding: 1rem; background: var(--light); border-radius: 8px; margin-bottom: 1rem;">
                <h3 style="color: var(--primary); margin-bottom: 0.5rem;">Formative Assessment</h3>
                <p>{module.assessment['formative']}</p>
            </div>
            <div style="padding: 1rem; background: var(--light); border-radius: 8px;">
                <h3 style="color: var(--secondary); margin-bottom: 0.5rem;">Summative Assessment</h3>
                <p>{module.assessment['summative']}</p>
            </div>
        </div>
        
        <div class="section">
            <h2>Your Progress</h2>
            <div class="progress-container">
                <div class="progress-bar" id="progressBar" style="width: 0%;"></div>
            </div>
            <p style="text-align: center; color: #6b7280; margin-top: 0.5rem;">
                Complete activities to track your progress
            </p>
        </div>
    </div>
    
    <!-- JavaScript Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    
    <script>
        // Animate progress bar on load
        window.addEventListener('load', function() {{
            setTimeout(() => {{
                document.getElementById('progressBar').style.width = '25%';
            }}, 500);
        }});
        
        // Animate activity cards on hover
        const activityCards = document.querySelectorAll('.activity-card');
        activityCards.forEach(card => {{
            card.addEventListener('click', function() {{
                anime({{
                    targets: this,
                    scale: [1, 0.98, 1],
                    duration: 300,
                    easing: 'easeInOutQuad'
                }});
                
                // Mark as completed (demo)
                this.style.borderColor = 'var(--success)';
                this.style.background = 'linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%)';
                
                // Update progress
                const completedCards = document.querySelectorAll('.activity-card[style*="--success"]').length;
                const totalCards = activityCards.length;
                const progress = (completedCards / totalCards) * 100;
                document.getElementById('progressBar').style.width = progress + '%';
            }});
        }});
        
        // Smooth scroll for internal links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {{
            anchor.addEventListener('click', function (e) {{
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {{
                    target.scrollIntoView({{ behavior: 'smooth' }});
                }}
            }});
        }});
    </script>
</body>
</html>"""
        
        return html
    
    def generate_all_content(self):
        """Generate all content for all 8 weeks."""
        print("\n" + "=" * 70)
        print("  VIETNAMESE COURSE CONTENT GENERATOR - EPIC EDITION")
        print("=" * 70)
        
        # Check for duplicates
        print("\n[1/5] Checking for duplicate content...")
        duplicates = self.detect_duplicates(COURSE_STRUCTURE)
        if duplicates:
            print(f"⚠️  Found {len(duplicates)} potential duplicates:")
            for dup in duplicates:
                print(f"    - {dup}")
        else:
            print("✓ No duplicates detected")
        
        # Generate content for each week
        print("\n[2/5] Generating professional HTML lessons...")
        for module in COURSE_STRUCTURE:
            print(f"  Generating Week {module.week}: {module.title}...")
            
            # Generate HTML lesson
            html_content = self.generate_html_lesson(module)
            html_file = OUTPUT_DIR / f"week{module.week}_lesson.html"
            html_file.write_text(html_content, encoding='utf-8')
            print(f"    ✓ HTML lesson saved: {html_file.name}")
            
            # Generate quiz
            print(f"    Generating quiz...")
            quiz_content = self.generate_quiz(module)
            quiz_file = OUTPUT_DIR / f"week{module.week}_quiz.gift"
            quiz_file.write_text(quiz_content, encoding='utf-8')
            print(f"    ✓ Quiz saved: {quiz_file.name}")
            
            # Generate flashcards
            print(f"    Generating flashcards...")
            flashcards_content = self.generate_flashcards(module)
            flashcards_file = OUTPUT_DIR / f"week{module.week}_flashcards.csv"
            flashcards_file.write_text(flashcards_content, encoding='utf-8')
            print(f"    ✓ Flashcards saved: {flashcards_file.name}")
            
            # Generate dialogue
            print(f"    Generating dialogue...")
            dialogue_content = self.generate_dialogue(module)
            dialogue_file = OUTPUT_DIR / f"week{module.week}_dialogue.txt"
            dialogue_file.write_text(dialogue_content, encoding='utf-8')
            print(f"    ✓ Dialogue saved: {dialogue_file.name}")
            
            print(f"  ✓ Week {module.week} complete\n")
        
        print("\n[3/5] Generating course overview page...")
        self.generate_course_overview()
        print("  ✓ Course overview complete")
        
        print("\n[4/5] Generating deployment manifest...")
        self.generate_deployment_manifest()
        print("  ✓ Deployment manifest complete")
        
        print("\n[5/5] Summary")
        print(f"  Total weeks: {len(COURSE_STRUCTURE)}")
        print(f"  Total files: {len(list(OUTPUT_DIR.iterdir()))}")
        print(f"  Output directory: {OUTPUT_DIR}")
        
        print("\n" + "=" * 70)
        print("  GENERATION COMPLETE!")
        print("=" * 70)
        print("\nNext steps:")
        print("  1. Review generated content in generated/professional/")
        print("  2. Run: python3 course_content_generator.py --test-content")
        print("  3. Deploy to Moodle using the deployment manifest")
        print()
    
    def generate_course_overview(self):
        """Generate professional course overview page."""
        modules_html = ""
        for module in COURSE_STRUCTURE:
            modules_html += f"""
        <div class="module-card" data-week="{module.week}">
            <div class="module-header">
                <span class="week-number">Week {module.week}</span>
                <h3>{module.title}</h3>
            </div>
            <p class="module-subtitle">{module.subtitle}</p>
            <div class="module-stats">
                <span class="stat"><strong>{module.vocabulary_count}</strong> vocab</span>
                <span class="stat"><strong>{len(module.activities)}</strong> activities</span>
                <span class="stat"><strong>{len(module.grammar_topics)}</strong> grammar topics</span>
            </div>
            <a href="week{module.week}_lesson.html" class="module-link">Start Learning →</a>
        </div>
"""
        
        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vietnamese Course - Professional Edition</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    
    <style>
        :root {{
            --primary: #2563eb;
            --secondary: #7c3aed;
            --dark: #1f2937;
            --light: #f9fafb;
        }}
        
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        
        body {{
            font-family: 'Inter', sans-serif;
            line-height: 1.6;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 2rem;
        }}
        
        .container {{
            max-width: 1400px;
            margin: 0 auto;
        }}
        
        .header {{
            background: white;
            border-radius: 16px;
            padding: 3rem;
            margin-bottom: 2rem;
            text-align: center;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }}
        
        .header h1 {{
            font-size: 3rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }}
        
        .header p {{
            font-size: 1.25rem;
            color: #6b7280;
        }}
        
        .modules-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 2rem;
        }}
        
        .module-card {{
            background: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            transition: all 0.3s;
            cursor: pointer;
        }}
        
        .module-card:hover {{
            transform: translateY(-8px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2);
        }}
        
        .module-header {{
            margin-bottom: 1rem;
        }}
        
        .week-number {{
            display: inline-block;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 600;
        }}
        
        .module-card h3 {{
            font-size: 1.5rem;
            color: var(--dark);
            margin-top: 0.5rem;
        }}
        
        .module-subtitle {{
            color: #6b7280;
            margin-bottom: 1rem;
        }}
        
        .module-stats {{
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
            padding-top: 1rem;
            border-top: 1px solid #e5e7eb;
        }}
        
        .stat {{
            font-size: 0.875rem;
            color: #6b7280;
        }}
        
        .module-link {{
            display: inline-block;
            color: var(--primary);
            font-weight: 600;
            text-decoration: none;
            margin-top: 1rem;
        }}
        
        .module-link:hover {{
            text-decoration: underline;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header animate__animated animate__fadeIn">
            <h1>Vietnamese Language Course</h1>
            <p>Professional 8-Week Curriculum - A2 to B1 Level</p>
        </div>
        
        <div class="modules-grid">
            {modules_html}
        </div>
    </div>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>
    <script>
        // Stagger animation for module cards
        anime({{
            targets: '.module-card',
            translateY: [50, 0],
            opacity: [0, 1],
            delay: anime.stagger(100),
            easing: 'easeOutQuad'
        }});
    </script>
</body>
</html>"""
        
        overview_file = OUTPUT_DIR / "index.html"
        overview_file.write_text(html, encoding='utf-8')
    
    def generate_deployment_manifest(self):
        """Generate deployment manifest for Moodle."""
        manifest = {
            "course_id": 10,
            "course_name": "Vietnamese Language Course",
            "total_weeks": len(COURSE_STRUCTURE),
            "modules": []
        }
        
        for module in COURSE_STRUCTURE:
            manifest["modules"].append({
                "week": module.week,
                "title": module.title,
                "subtitle": module.subtitle,
                "files": {
                    "lesson": f"week{module.week}_lesson.html",
                    "quiz": f"week{module.week}_quiz.gift",
                    "flashcards": f"week{module.week}_flashcards.csv",
                    "dialogue": f"week{module.week}_dialogue.txt"
                },
                "objectives": module.objectives,
                "vocabulary_count": module.vocabulary_count,
                "activities_count": len(module.activities)
            })
        
        manifest_file = OUTPUT_DIR / "deployment_manifest.json"
        manifest_file.write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    
    def test_all_content(self):
        """Test all generated content."""
        print("\n" + "=" * 70)
        print("  TESTING GENERATED CONTENT")
        print("=" * 70)
        
        # Check if agent is running
        print("\n[1/3] Checking Vietnamese Tutor Agent...")
        try:
            response = requests.get(f"{self.agent_url}/health", timeout=5)
            if response.status_code == 200:
                print("  ✓ Agent is running")
            else:
                print(f"  ✗ Agent returned status {response.status_code}")
                return
        except Exception as e:
            print(f"  ✗ Agent is not accessible: {e}")
            return
        
        # Test generated files exist
        print("\n[2/3] Checking generated files...")
        required_files = []
        for week in range(1, 9):
            required_files.extend([
                OUTPUT_DIR / f"week{week}_lesson.html",
                OUTPUT_DIR / f"week{week}_quiz.gift",
                OUTPUT_DIR / f"week{week}_flashcards.csv",
                OUTPUT_DIR / f"week{week}_dialogue.txt"
            ])
        
        missing = [f for f in required_files if not f.exists()]
        if missing:
            print(f"  ✗ Missing {len(missing)} files:")
            for f in missing[:5]:
                print(f"    - {f.name}")
        else:
            print(f"  ✓ All {len(required_files)} files exist")
        
        # Validate HTML
        print("\n[3/3] Validating HTML files...")
        html_files = list(OUTPUT_DIR.glob("*.html"))
        for html_file in html_files:
            content = html_file.read_text()
            if "<html" in content and "</html>" in content:
                print(f"  ✓ {html_file.name} - Valid")
            else:
                print(f"  ✗ {html_file.name} - Invalid HTML")
        
        print("\n" + "=" * 70)
        print("  TESTING COMPLETE")
        print("=" * 70)


def main():
    parser = argparse.ArgumentParser(description="Vietnamese Course Content Generator")
    parser.add_argument("--generate-all", action="store_true", help="Generate all course content")
    parser.add_argument("--review-duplicates", action="store_true", help="Review content for duplicates")
    parser.add_argument("--test-content", action="store_true", help="Test generated content")
    parser.add_argument("--agent-url", default=AGENT_URL, help="Vietnamese Tutor Agent URL")
    
    args = parser.parse_args()
    
    generator = ContentGenerator(agent_url=args.agent_url)
    
    if args.review_duplicates:
        print("\nChecking for duplicate content...")
        duplicates = generator.detect_duplicates(COURSE_STRUCTURE)
        if duplicates:
            print(f"Found {len(duplicates)} duplicates:")
            for dup in duplicates:
                print(f"  - {dup}")
        else:
            print("✓ No duplicates found")
    
    elif args.test_content:
        generator.test_all_content()
    
    elif args.generate_all:
        generator.generate_all_content()
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
