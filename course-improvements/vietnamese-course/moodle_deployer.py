#!/usr/bin/env python3
"""
Automated Moodle Deployment System for Vietnamese Course

This script automates 100% of the Moodle deployment process:
1. Import quizzes (GIFT format) to Question Bank
2. Upload HTML lessons as Page resources
3. Distribute flashcards as File resources
4. Link dialogues in assignments
5. Configure Vietnamese Tutor Agent widgets in Moodle pages

Usage:
    python3 moodle_deployer.py --deploy-all
    python3 moodle_deployer.py --deploy-quizzes
    python3 moodle_deployer.py --deploy-lessons
    python3 moodle_deployer.py --deploy-resources
    python3 moodle_deployer.py --configure-agent-widgets
"""

import os
import sys
import json
import requests
import argparse
from pathlib import Path
from typing import Dict, List, Any, Optional
from datetime import datetime
import hashlib
import time

# Import working Moodle client
from moodle_client import call_webservice, create_page_direct

# Configuration
MOODLE_URL = "https://moodle.simondatalab.de"
COURSE_ID = 10
MOODLE_TOKEN_FILE = Path.home() / ".moodle_token"

# Paths
BASE_DIR = Path(__file__).parent
CONTENT_DIR = BASE_DIR / "generated" / "professional"
AGENT_TOKEN_FILE = BASE_DIR / ".." / ".." / "workspace" / "agents" / ".token"

# Vietnamese Tutor Agent
AGENT_URL = "http://localhost:5001"

# Load tokens
MOODLE_TOKEN = None
AGENT_TOKEN = None

try:
    with open(MOODLE_TOKEN_FILE, 'r') as f:
        MOODLE_TOKEN = f.read().strip()
except:
    print("⚠️  No Moodle token found. Create one at:")
    print(f"   {MOODLE_URL}/admin/settings.php?section=webservicetokens")
    print(f"   Save it to: {MOODLE_TOKEN_FILE}")

try:
    with open(AGENT_TOKEN_FILE, 'r') as f:
        AGENT_TOKEN = f.read().strip()
except:
    pass


class MoodleAPI:
    """Moodle Web Services API wrapper using SSH tunnel."""
    
    def __init__(self, url: str, token: str):
        self.url = url
        self.token = token
        # Note: token is already loaded by moodle_client.py from ~/.moodle_token
        
    def call(self, function: str, **params) -> Dict[str, Any]:
        """Call Moodle web service function via SSH tunnel."""
        try:
            print(f"  📡 Calling: {function}")
            result = call_webservice(function, params if params else None)
            
            if isinstance(result, dict) and 'error' in result:
                raise Exception(f"Moodle API error: {result.get('error', result)}")
            
            return result
        except Exception as e:
            print(f"❌ API call failed: {function}")
            print(f"   Error: {e}")
            raise
    
    def upload_file(self, filepath: Path, contextid: int) -> Dict[str, Any]:
        """Upload file to Moodle."""
        upload_url = f"{self.url}/webservice/upload.php"
        
        with open(filepath, 'rb') as f:
            files = {'file': (filepath.name, f)}
            data = {
                'token': self.token,
                'itemid': 0,
                'contextid': contextid
            }
            
            response = requests.post(upload_url, files=files, data=data, timeout=60)
            response.raise_for_status()
            result = response.json()
            
            if isinstance(result, list) and len(result) > 0:
                return result[0]
            else:
                raise Exception(f"File upload failed: {result}")
    
    def get_course_modules(self, courseid: int) -> List[Dict[str, Any]]:
        """Get all modules in a course."""
        return self.call('core_course_get_contents', courseid=courseid)
    
    def create_page(self, courseid: int, section: int, name: str, content: str) -> Dict[str, Any]:
        """Create a Page resource in course using direct database access."""
        # Use the direct creation method which can handle large HTML content
        return create_page_direct(courseid, section, name, content)
    
    def create_assignment(self, courseid: int, section: int, name: str, 
                         intro: str, duedate: int = 0) -> Dict[str, Any]:
        """Create an Assignment in course."""
        result = self.call(
            'mod_assign_create_assignments',
            assignments=[{
                'courseid': courseid,
                'section': section,
                'name': name,
                'intro': intro,
                'introformat': 1,
                'duedate': duedate,
                'allowsubmissionsfromdate': int(time.time()),
                'gradingduedate': 0,
                'visible': 1
            }]
        )
        return result
    
    def create_resource(self, courseid: int, section: int, name: str, 
                       files: List[str]) -> Dict[str, Any]:
        """Create a File resource in course."""
        # Get course context
        contexts = self.call('core_course_get_courses', options={'ids[]': courseid})
        context_id = contexts[0]['id'] if contexts else 0
        
        # Upload files first
        uploaded_files = []
        for filepath in files:
            uploaded = self.upload_file(Path(filepath), context_id)
            uploaded_files.append(uploaded)
        
        # Create resource
        result = self.call(
            'mod_resource_add_resource',
            courseid=courseid,
            section=section,
            name=name,
            intro='',
            files=uploaded_files,
            visible=1
        )
        return result
    
    def import_questions(self, courseid: int, categoryid: int, 
                        gift_content: str, categoryname: str = None) -> Dict[str, Any]:
        """Import GIFT format questions to question bank."""
        # Create category if name provided
        if categoryname:
            self.call(
                'core_question_create_categories',
                categories=[{
                    'name': categoryname,
                    'parent': categoryid,
                    'contextlevel': 'course',
                    'contextid': courseid
                }]
            )
        
        # Import questions
        result = self.call(
            'core_question_import_questions',
            courseid=courseid,
            categoryid=categoryid,
            format='gift',
            content=gift_content
        )
        return result


class MoodleDeployer:
    """Automated Moodle deployment for Vietnamese course."""
    
    def __init__(self, moodle_url: str, token: str, course_id: int, preview: bool = False):
        self.api = MoodleAPI(moodle_url, token)
        self.course_id = course_id
        self.manifest = self.load_manifest()
        self.preview = preview
        
    def load_manifest(self) -> Dict[str, Any]:
        """Load deployment manifest."""
        manifest_file = CONTENT_DIR / "deployment_manifest.json"
        if manifest_file.exists():
            with open(manifest_file, 'r') as f:
                return json.load(f)
        return {"modules": []}
    
    def deploy_quizzes(self):
        """Deploy all GIFT quizzes to Moodle question bank."""
        print("\n" + "=" * 70)
        print("  DEPLOYING QUIZZES TO QUESTION BANK")
        print("=" * 70)
        
        # Get default question category (skip live API when previewing)
        if self.preview:
            print("(Preview) Skipping category lookup; using simulated category ID: 1")
            default_category = 1
        else:
            try:
                categories = self.api.call('core_question_get_categories', 
                                          courseid=self.course_id)
                if not categories:
                    print("❌ No question categories found")
                    return
                
                default_category = categories[0]['id']
                print(f"Using question category: {categories[0]['name']} (ID: {default_category})")
            except Exception as e:
                print(f"❌ Failed to get question categories: {e}")
                return
        
        # Import each week's quiz
        for module in self.manifest.get('modules', []):
            week = module['week']
            quiz_file = CONTENT_DIR / module['files']['quiz']
            
            if not quiz_file.exists():
                print(f"⚠️  Week {week}: Quiz file not found: {quiz_file.name}")
                continue
            
            print(f"\nWeek {week}: {module['title']}")
            print(f"  Reading quiz: {quiz_file.name}")
            
            try:
                with open(quiz_file, 'r', encoding='utf-8') as f:
                    gift_content = f.read()

                # Create category for this week
                category_name = f"Week {week} - {module['title']}"

                print(f"  Importing questions to category: {category_name}")

                if self.preview:
                    print(f"  (Preview) Would import GIFT from: {quiz_file}")
                else:
                    # Import questions
                    result = self.api.import_questions(
                        self.course_id, 
                        default_category, 
                        gift_content,
                        category_name
                    )
                    print(f"  ✓ Imported successfully")

            except Exception as e:
                print(f"  ❌ Failed: {e}")
        
        print("\n" + "=" * 70)
        print("  QUIZ DEPLOYMENT COMPLETE")
        print("=" * 70)
    
    def deploy_lessons(self):
        """Deploy HTML lessons as Page resources."""
        print("\n" + "=" * 70)
        print("  DEPLOYING HTML LESSONS AS PAGES")
        print("=" * 70)
        
        for module in self.manifest.get('modules', []):
            week = module['week']
            lesson_file = CONTENT_DIR / module['files']['lesson']
            
            if not lesson_file.exists():
                print(f"⚠️  Week {week}: Lesson file not found: {lesson_file.name}")
                continue
            
            print(f"\nWeek {week}: {module['title']}")
            print(f"  Reading lesson: {lesson_file.name}")
            
            try:
                with open(lesson_file, 'r', encoding='utf-8') as f:
                    html_content = f.read()

                # Inject Vietnamese Tutor Agent widget
                html_content = self.inject_agent_widget(html_content, week)

                page_name = f"Week {week}: {module['title']}"

                print(f"  Creating page: {page_name}")
                if self.preview:
                    print(f"  (Preview) Would create Page resource for: {lesson_file}")
                else:
                    result = self.api.create_page(
                        self.course_id,
                        week,  # Section number
                        page_name,
                        html_content
                    )
                    print(f"  ✓ Created successfully")

            except Exception as e:
                print(f"  ❌ Failed: {e}")
        
        print("\n" + "=" * 70)
        print("  LESSON DEPLOYMENT COMPLETE")
        print("=" * 70)
    
    def deploy_resources(self):
        """Deploy flashcards and dialogues as File resources."""
        print("\n" + "=" * 70)
        print("  DEPLOYING FLASHCARDS AND DIALOGUES")
        print("=" * 70)
        
        for module in self.manifest.get('modules', []):
            week = module['week']
            flashcard_file = CONTENT_DIR / module['files']['flashcards']
            dialogue_file = CONTENT_DIR / module['files']['dialogue']
            
            print(f"\nWeek {week}: {module['title']}")
            
            # Deploy flashcards
            if flashcard_file.exists():
                try:
                    print(f"  Uploading flashcards: {flashcard_file.name}")
                    if self.preview:
                        print(f"  (Preview) Would upload file: {flashcard_file}")
                    else:
                        result = self.api.create_resource(
                            self.course_id,
                            week,
                            f"Week {week} Flashcards - Anki Deck",
                            [str(flashcard_file)]
                        )
                        print(f"  ✓ Flashcards uploaded")
                except Exception as e:
                    print(f"  ❌ Flashcard upload failed: {e}")
            else:
                print(f"  ⚠️  Flashcard file not found")
            
            # Deploy dialogue
            if dialogue_file.exists():
                try:
                    print(f"  Uploading dialogue: {dialogue_file.name}")
                    if self.preview:
                        print(f"  (Preview) Would upload file: {dialogue_file}")
                    else:
                        result = self.api.create_resource(
                            self.course_id,
                            week,
                            f"Week {week} Practice Dialogues",
                            [str(dialogue_file)]
                        )
                        print(f"  ✓ Dialogue uploaded")
                except Exception as e:
                    print(f"  ❌ Dialogue upload failed: {e}")
            else:
                print(f"  ⚠️  Dialogue file not found")
        
        print("\n" + "=" * 70)
        print("  RESOURCE DEPLOYMENT COMPLETE")
        print("=" * 70)
    
    def deploy_assignments(self):
        """Create speaking/recording assignments."""
        print("\n" + "=" * 70)
        print("  CREATING ASSIGNMENTS")
        print("=" * 70)
        
        assignments = [
            {
                "week": 1,
                "name": "30-Second Self Introduction",
                "intro": """<h3>Recording Assignment - Week 1</h3>
<p>Record a 30-second self-introduction in Vietnamese.</p>
<h4>Requirements:</h4>
<ul>
<li>State your name (Tôi tên là...)</li>
<li>Mention your nationality (Tôi đến từ...)</li>
<li>Say what you do (Tôi làm việc...)</li>
<li>Use proper pronunciation and tones</li>
</ul>
<h4>Grading Rubric:</h4>
<ul>
<li>Pronunciation: 40%</li>
<li>Fluency: 30%</li>
<li>Accuracy: 30%</li>
</ul>"""
            },
            {
                "week": 2,
                "name": "Direction Giving Video",
                "intro": """<h3>Video Assignment - Week 2</h3>
<p>Create a video showing how to navigate from Point A to Point B with Vietnamese commentary.</p>
<h4>Requirements:</h4>
<ul>
<li>Use directional vocabulary (đi, rẽ, qua, tới)</li>
<li>Mention landmarks</li>
<li>2-3 minutes duration</li>
<li>Clear audio and video</li>
</ul>"""
            },
            {
                "week": 3,
                "name": "Restaurant Dialogue Recording",
                "intro": """<h3>Dialogue Assignment - Week 3</h3>
<p>Record an authentic restaurant ordering dialogue (2-3 minutes).</p>
<h4>Requirements:</h4>
<ul>
<li>Order food and drinks</li>
<li>Ask about ingredients</li>
<li>Request the bill</li>
<li>Use polite language</li>
</ul>"""
            },
            {
                "week": 4,
                "name": "Academic Presentation",
                "intro": """<h3>Presentation Assignment - Week 4</h3>
<p>Create a 3-minute presentation on an academic topic in Vietnamese.</p>
<h4>Requirements:</h4>
<ul>
<li>Clear topic introduction</li>
<li>Use time markers (đã, đang, sẽ)</li>
<li>Express opinions</li>
<li>Include Q&A preparation</li>
</ul>"""
            },
            {
                "week": 5,
                "name": "Job Application Package",
                "intro": """<h3>Professional Assignment - Week 5</h3>
<p>Submit a complete job application package in Vietnamese.</p>
<h4>Requirements:</h4>
<ul>
<li>CV/Resume in Vietnamese</li>
<li>Cover letter (formal register)</li>
<li>Mock interview recording (5 minutes)</li>
<li>Professional email template</li>
</ul>"""
            },
            {
                "week": 6,
                "name": "Travel Itinerary Group Project",
                "intro": """<h3>Group Project - Week 6</h3>
<p>Collaborate to create a Vietnam travel itinerary with video presentation.</p>
<h4>Requirements:</h4>
<ul>
<li>3-5 minute group video</li>
<li>Detailed itinerary document</li>
<li>Cultural insights included</li>
<li>Each member speaks</li>
</ul>"""
            },
            {
                "week": 7,
                "name": "Personal Narrative Story",
                "intro": """<h3>Storytelling Assignment - Week 7</h3>
<p>Record a personal story in Vietnamese (3-5 minutes, polished).</p>
<h4>Requirements:</h4>
<ul>
<li>Use past and present tense</li>
<li>Clear narrative structure</li>
<li>Descriptive language</li>
<li>Revised based on peer feedback</li>
</ul>"""
            }
        ]
        
        # Calculate due dates (1 week per module)
        base_timestamp = int(time.time())
        week_seconds = 7 * 24 * 60 * 60
        
        for assignment in assignments:
            week = assignment['week']
            duedate = base_timestamp + (week * week_seconds)
            
            print(f"\nWeek {week}: {assignment['name']}")
            
            try:
                if self.preview:
                    print(f"  (Preview) Would create assignment: {assignment['name']} (due: {duedate})")
                else:
                    result = self.api.create_assignment(
                        self.course_id,
                        week,
                        assignment['name'],
                        assignment['intro'],
                        duedate
                    )
                    print(f"  ✓ Assignment created")
            except Exception as e:
                print(f"  ❌ Failed: {e}")
        
        print("\n" + "=" * 70)
        print("  ASSIGNMENT CREATION COMPLETE")
        print("=" * 70)
    
    def inject_agent_widget(self, html_content: str, week: int) -> str:
        """Inject Vietnamese Tutor Agent widget into HTML."""
        
        widget_html = f"""
<!-- Vietnamese Tutor Agent Widget -->
<div id="vietnamese-agent-widget" style="position: fixed; bottom: 20px; right: 20px; z-index: 9999;">
    <button id="agent-toggle" style="
        background: linear-gradient(135deg, #2563eb, #7c3aed);
        color: white;
        border: none;
        border-radius: 50%;
        width: 60px;
        height: 60px;
        font-size: 24px;
        cursor: pointer;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        transition: transform 0.2s;
    " onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
        🎓
    </button>
    
    <div id="agent-panel" style="
        display: none;
        position: absolute;
        bottom: 70px;
        right: 0;
        width: 400px;
        max-height: 600px;
        background: white;
        border-radius: 12px;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3);
        overflow: hidden;
    ">
        <div style="background: linear-gradient(135deg, #2563eb, #7c3aed); color: white; padding: 1rem;">
            <h3 style="margin: 0; font-size: 1.125rem;">Vietnamese Tutor AI</h3>
            <p style="margin: 0.5rem 0 0; font-size: 0.875rem; opacity: 0.9;">Week {week} Assistant</p>
        </div>
        
        <div style="padding: 1rem; max-height: 400px; overflow-y: auto;" id="agent-chat-area">
            <p style="color: #6b7280; font-size: 0.875rem;">
                I can help you with:
            </p>
            <ul style="color: #374151; font-size: 0.875rem;">
                <li>Grammar checking</li>
                <li>Pronunciation feedback</li>
                <li>Vocabulary practice</li>
                <li>Dialogue generation</li>
                <li>Translation help</li>
            </ul>
        </div>
        
        <div style="padding: 1rem; border-top: 1px solid #e5e7eb;">
            <div style="display: flex; gap: 0.5rem;">
                <input type="text" id="agent-input" placeholder="Ask me anything..." style="
                    flex: 1;
                    padding: 0.5rem;
                    border: 1px solid #d1d5db;
                    border-radius: 6px;
                    font-size: 0.875rem;
                " />
                <button onclick="sendToAgent()" style="
                    background: #2563eb;
                    color: white;
                    border: none;
                    border-radius: 6px;
                    padding: 0.5rem 1rem;
                    cursor: pointer;
                    font-size: 0.875rem;
                    font-weight: 600;
                ">Send</button>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin-top: 0.75rem;">
                <button onclick="quickAction('grammar')" class="quick-btn">Check Grammar</button>
                <button onclick="quickAction('pronunciation')" class="quick-btn">Pronunciation</button>
                <button onclick="quickAction('vocabulary')" class="quick-btn">Vocabulary</button>
                <button onclick="quickAction('translate')" class="quick-btn">Translate</button>
            </div>
        </div>
    </div>
</div>

<style>
.quick-btn {{
    background: #f3f4f6;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    padding: 0.5rem;
    font-size: 0.75rem;
    cursor: pointer;
    transition: all 0.2s;
}}
.quick-btn:hover {{
    background: #e5e7eb;
    border-color: #2563eb;
}}
</style>

<script>
// Vietnamese Tutor Agent Integration
const AGENT_URL = '{AGENT_URL}';
const AGENT_TOKEN = '{AGENT_TOKEN if AGENT_TOKEN else ""}';

document.getElementById('agent-toggle').addEventListener('click', function() {{
    const panel = document.getElementById('agent-panel');
    panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
}});

document.getElementById('agent-input').addEventListener('keypress', function(e) {{
    if (e.key === 'Enter') {{
        sendToAgent();
    }}
}});

function sendToAgent() {{
    const input = document.getElementById('agent-input');
    const message = input.value.trim();
    if (!message) return;
    
    const chatArea = document.getElementById('agent-chat-area');
    
    // Add user message
    chatArea.innerHTML += `
        <div style="margin: 0.5rem 0; text-align: right;">
            <span style="background: #2563eb; color: white; padding: 0.5rem 0.75rem; border-radius: 12px; display: inline-block; max-width: 80%; font-size: 0.875rem;">
                ${{message}}
            </span>
        </div>
    `;
    
    input.value = '';
    chatArea.scrollTop = chatArea.scrollHeight;
    
    // Send to agent (grammar check as default)
    fetch(AGENT_URL + '/grammar/check', {{
        method: 'POST',
        headers: {{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + AGENT_TOKEN
        }},
        body: JSON.stringify({{
            text: message,
            level: 'intermediate'
        }})
    }})
    .then(res => res.json())
    .then(data => {{
        const response = data.response || 'I analyzed your text!';
        chatArea.innerHTML += `
            <div style="margin: 0.5rem 0;">
                <span style="background: #f3f4f6; color: #1f2937; padding: 0.5rem 0.75rem; border-radius: 12px; display: inline-block; max-width: 80%; font-size: 0.875rem;">
                    ${{response.substring(0, 200)}}...
                </span>
            </div>
        `;
        chatArea.scrollTop = chatArea.scrollHeight;
    }})
    .catch(err => {{
        console.error('Agent error:', err);
        chatArea.innerHTML += `
            <div style="margin: 0.5rem 0;">
                <span style="background: #fef3c7; color: #92400e; padding: 0.5rem 0.75rem; border-radius: 12px; display: inline-block; max-width: 80%; font-size: 0.875rem;">
                    Connection error. Please try again.
                </span>
            </div>
        `;
        chatArea.scrollTop = chatArea.scrollHeight;
    }});
}}

function quickAction(action) {{
    const chatArea = document.getElementById('agent-chat-area');
    const actions = {{
        'grammar': 'Check my grammar',
        'pronunciation': 'Help with pronunciation',
        'vocabulary': 'Practice vocabulary',
        'translate': 'Translate text'
    }};
    
    chatArea.innerHTML += `
        <div style="margin: 0.5rem 0; text-align: right;">
            <span style="background: #2563eb; color: white; padding: 0.5rem 0.75rem; border-radius: 12px; display: inline-block; font-size: 0.875rem;">
                ${{actions[action]}}
            </span>
        </div>
        <div style="margin: 0.5rem 0;">
            <span style="background: #f3f4f6; color: #1f2937; padding: 0.5rem 0.75rem; border-radius: 12px; display: inline-block; font-size: 0.875rem;">
                Opening ${{action}} tool... Type your text above!
            </span>
        </div>
    `;
    chatArea.scrollTop = chatArea.scrollHeight;
}}
</script>
"""
        
        # Inject before closing body tag
        if '</body>' in html_content:
            html_content = html_content.replace('</body>', widget_html + '</body>')
        else:
            html_content += widget_html
        
        return html_content
    
    def deploy_all(self):
        """Deploy everything to Moodle."""
        print("\n" + "=" * 70)
        print("  MOODLE AUTOMATED DEPLOYMENT - VIETNAMESE COURSE")
        print("=" * 70)
        print(f"\nCourse ID: {self.course_id}")
        print(f"Moodle URL: {MOODLE_URL}")
        print(f"Content Directory: {CONTENT_DIR}")
        print(f"Total Weeks: {len(self.manifest.get('modules', []))}")
        
        if not CONTENT_DIR.exists():
            print(f"\n❌ Content directory not found: {CONTENT_DIR}")
            print("   Run: python3 course_content_generator.py --generate-all")
            return
        
        # Confirm deployment
        print("\nThis will deploy:")
        print("  1. All quizzes to Question Bank (GIFT format)")
        print("  2. All HTML lessons as Page resources")
        print("  3. All flashcards as File resources")
        print("  4. All dialogues as File resources")
        print("  5. All assignments with descriptions")
        print("  6. Vietnamese Tutor Agent widgets on all pages")
        
        # If preview mode, skip interactive confirmation and just show plan
        if self.preview:
            print("(Preview mode) Showing planned actions without contacting Moodle.")
        else:
            response = input("\nProceed with deployment? (yes/no): ")
            if response.lower() != 'yes':
                print("Deployment cancelled.")
                return
        
        # Execute deployment steps
        try:
            # Run steps (they act as previews if self.preview is True)
            self.deploy_quizzes()
            time.sleep(1)

            self.deploy_lessons()
            time.sleep(1)

            self.deploy_resources()
            time.sleep(1)

            self.deploy_assignments()

            print("\n" + "=" * 70)
            if self.preview:
                print("  ✅ PREVIEW COMPLETE - no changes made to Moodle")
            else:
                print("  🎉 DEPLOYMENT COMPLETE!")
            print("=" * 70)
            print("\nSummary:")
            print(f"  Weeks processed (manifest): {len(self.manifest.get('modules', []))}")
            print(f"  Lessons (page resources): {len(self.manifest.get('modules', []))}")
            print(f"  Quizzes (GIFT): {len(self.manifest.get('modules', []))}")
            print(f"  Flashcard files: {len(self.manifest.get('modules', []))}")
            print(f"  Dialogue files: {len(self.manifest.get('modules', []))}")

            if not self.preview:
                print(f"\nView course: {MOODLE_URL}/course/view.php?id={self.course_id}")

        except Exception as e:
            print(f"\n❌ Deployment failed: {e}")
            print("Please check your Moodle token and permissions.")


def main():
    parser = argparse.ArgumentParser(description="Automated Moodle Deployment")
    parser.add_argument("--deploy-all", action="store_true", help="Deploy everything")
    parser.add_argument("--deploy-quizzes", action="store_true", help="Deploy quizzes only")
    parser.add_argument("--deploy-lessons", action="store_true", help="Deploy lessons only")
    parser.add_argument("--deploy-resources", action="store_true", help="Deploy resources only")
    parser.add_argument("--deploy-assignments", action="store_true", help="Deploy assignments only")
    parser.add_argument("--configure-agent-widgets", action="store_true", help="Configure Agent widgets only")
    parser.add_argument("--moodle-url", default=MOODLE_URL, help="Moodle base URL")
    parser.add_argument("--course-id", type=int, default=COURSE_ID, help="Course ID")
    parser.add_argument("--preview", action="store_true", help="Preview actions without contacting Moodle")
    
    args = parser.parse_args()
    
    if not MOODLE_TOKEN and not args.preview:
        print("❌ Moodle token not found!")
        print(f"Create one at: {MOODLE_URL}/admin/settings.php?section=webservicetokens")
        print(f"Save it to: {MOODLE_TOKEN_FILE}")
        sys.exit(1)

    token_to_use = MOODLE_TOKEN if MOODLE_TOKEN else ""
    deployer = MoodleDeployer(args.moodle_url, token_to_use, args.course_id, preview=args.preview)
    
    if args.deploy_quizzes:
        deployer.deploy_quizzes()
    elif args.deploy_lessons:
        deployer.deploy_lessons()
    elif args.deploy_resources:
        deployer.deploy_resources()
    elif args.deploy_assignments:
        deployer.deploy_assignments()
    elif args.configure_agent_widgets:
        print("Agent widgets are automatically injected during lesson deployment")
    elif args.deploy_all:
        deployer.deploy_all()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
