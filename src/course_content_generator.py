#!/usr/bin/env python3
"""
Enhanced Course Content Generator - Vietnamese Edition
Generates personalized, multimedia-rich course content for each Moodle page
Uses AI agents to create: visuals, audio, microphone activities, practice exercises
"""

import json
import asyncio
import requests
from typing import Dict, List, Any
from datetime import datetime
import uuid
from pathlib import Path

class CourseContentGenerator:
    """Generate personalized, engaging course content"""
    
    def __init__(self, orchestrator_url: str = "http://localhost:5100"):
        self.orchestrator_url = orchestrator_url
        self.vietnamese_index = self._load_vietnamese_index()
        self.content_cache = {}
        self.agent_responses = []
    
    def _load_vietnamese_index(self) -> Dict[str, Any]:
        """Load the Vietnamese resource index"""
        index_path = "/home/simon/Learning-Management-System-Academy/data/vietnamese_content_index.json"
        try:
            with open(index_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"[WARNING] Could not load Vietnamese index: {e}")
            return {"resources": [], "audio_index": [], "glossary_index": []}
    
    def generate_page_content(self, page_id: int, lesson_title: str, 
                            learning_level: str = "beginner",
                            student_name: str = None) -> Dict[str, Any]:
        """Generate complete personalized content for a Moodle page"""
        
        content_id = str(uuid.uuid4())[:8]
        print(f"\n[GENERATOR] 🎯 Generating content for Page {page_id}: {lesson_title}")
        
        # Generate core components
        lesson_content = self._generate_lesson_content(lesson_title, learning_level, student_name)
        visual_spec = self._generate_visual_specification(lesson_title, learning_level)
        audio_spec = self._generate_audio_specification(lesson_title, learning_level)
        microphone_activity = self._generate_microphone_activity(lesson_title, learning_level)
        practice_exercises = self._generate_practice_exercises(lesson_title, learning_level)
        
        # Compile complete page content
        page_content = {
            "content_id": content_id,
            "page_id": page_id,
            "lesson_title": lesson_title,
            "generated_at": datetime.now().isoformat(),
            "personalization": {
                "student_name": student_name,
                "learning_level": learning_level
            },
            "components": {
                "lesson": lesson_content,
                "visuals": visual_spec,
                "audio": audio_spec,
                "microphone_activity": microphone_activity,
                "practice": practice_exercises
            },
            "engagement_tracking": {
                "visual_views": 0,
                "audio_plays": 0,
                "microphone_attempts": 0,
                "practice_completions": 0
            }
        }
        
        # Cache the content
        self.content_cache[page_id] = page_content
        
        print(f"[GENERATOR] ✅ Generated content for page {page_id}")
        return page_content
    
    def _generate_lesson_content(self, title: str, level: str, student_name: str = None) -> Dict[str, Any]:
        """Generate personalized lesson content using AI agent"""
        
        # Personalization
        greeting = f"Xin chào {student_name}! " if student_name else ""
        
        # Query the Course Agent
        prompt = f"""
        Create a {level} Vietnamese language lesson about: {title}
        
        {f'For student: {student_name}' if student_name else ''}
        
        Provide:
        1. MAIN_CONCEPT: Key learning point (1-2 sentences in Vietnamese + English translation)
        2. VOCABULARY: 5-10 key vocabulary words with pronunciations and translations
        3. GRAMMAR_POINT: Important grammar rule with 3 examples
        4. CULTURAL_CONTEXT: Relevant Vietnamese cultural insight
        5. REAL_WORLD_APPLICATION: How to use this in real Vietnamese conversations
        6. LEARNING_PATH: Suggested next lessons
        
        Format as JSON.
        """
        
        try:
            response = requests.post(
                f"{self.orchestrator_url}/agent/Course/query",
                json={"query": prompt},
                timeout=30
            )
            if response.status_code == 200:
                agent_response = response.json()
                # Parse the response content
                content = agent_response.get("response", "")
                # Try to extract JSON
                try:
                    lesson_data = json.loads(content)
                    return lesson_data
                except:
                    return {
                        "main_concept": content[:200],
                        "status": "generated",
                        "raw_response": content
                    }
        except Exception as e:
            print(f"[WARNING] Course Agent query failed: {e}")
        
        # Fallback content
        return {
            "main_concept": f"Lesson on {title}",
            "vocabulary": ["từ", "ngôn ngữ", "Việt Nam"],
            "status": "fallback"
        }
    
    def _generate_visual_specification(self, title: str, level: str) -> Dict[str, Any]:
        """Generate visual design specification"""
        return {
            "type": "visual_specification",
            "elements": [
                {
                    "id": "concept_diagram",
                    "type": "infographic",
                    "title": f"{title} - Visual Overview",
                    "description": f"Animated concept diagram showing {title.lower()}",
                    "colors": ["#1a73e8", "#34a853", "#fbbc04", "#ea4335"],
                    "style": "modern_gradient"
                },
                {
                    "id": "vocabulary_cards",
                    "type": "flashcard_set",
                    "count": 8,
                    "layout": "grid_2x4",
                    "animation": "flip_on_click"
                },
                {
                    "id": "cultural_context_banner",
                    "type": "illustrated_banner",
                    "height_vh": 30,
                    "content": "Vietnamese cultural context"
                },
                {
                    "id": "progress_indicator",
                    "type": "progress_bar",
                    "segments": 5,
                    "label": "Your Progress"
                }
            ],
            "interactive_elements": [
                {"type": "hover_tooltips", "enabled": True},
                {"type": "click_to_reveal", "enabled": True},
                {"type": "drag_drop_exercises", "enabled": True}
            ]
        }
    
    def _generate_audio_specification(self, title: str, level: str) -> Dict[str, Any]:
        """Generate audio specification for this lesson"""
        
        audio_resources = self.vietnamese_index.get("audio_index", [])
        relevant_audio = [a for a in audio_resources if a["size_mb"] < 50][:3]  # Small files
        
        return {
            "type": "audio_specification",
            "components": [
                {
                    "id": "lesson_narration",
                    "type": "text_to_speech",
                    "text": f"Vietnamese lesson: {title}",
                    "voice": "vietnamese_female",
                    "speed": "normal",
                    "auto_play": False
                },
                {
                    "id": "vocabulary_pronunciation",
                    "type": "pronunciation_guide",
                    "items": 8,
                    "language": "vietnamese",
                    "style": "native_speaker"
                },
                {
                    "id": "cultural_audio",
                    "type": "audio_segment",
                    "source": "vietnamese_resources",
                    "duration_seconds": "varies",
                    "description": f"Authentic Vietnamese audio for {title}"
                }
            ],
            "background_music": {
                "type": "ambient",
                "culture": "vietnamese",
                "volume_percentage": 20
            },
            "available_resources": len(relevant_audio),
            "resource_sample": relevant_audio[:2] if relevant_audio else []
        }
    
    def _generate_microphone_activity(self, title: str, level: str) -> Dict[str, Any]:
        """Generate microphone recording activity"""
        return {
            "type": "microphone_activity",
            "id": "pronunciation_practice",
            "title": f"Practice Pronunciation: {title}",
            "instructions": "Click the microphone and repeat the Vietnamese phrase you hear",
            "activities": [
                {
                    "id": "mic_activity_1",
                    "type": "listen_and_repeat",
                    "prompt": "Repeat: Xin chào",
                    "target_phrase": "Xin chào",
                    "english_translation": "Hello",
                    "difficulty": level
                },
                {
                    "id": "mic_activity_2",
                    "type": "listen_and_repeat",
                    "prompt": f"Repeat: {title}",
                    "target_phrase": title,
                    "difficulty": level
                },
                {
                    "id": "mic_activity_3",
                    "type": "conversation_simulation",
                    "prompt": "Respond naturally to: Bạn khỏe không?",
                    "expected_response_concepts": ["well", "greeting", "response"],
                    "allow_variations": True
                }
            ],
            "recording_settings": {
                "max_duration_seconds": 30,
                "quality": "high",
                "format": "wav",
                "auto_save": True
            },
            "feedback_system": {
                "provide_transcription": True,
                "provide_comparison": True,
                "provide_encouragement": True,
                "store_for_review": True
            }
        }
    
    def _generate_practice_exercises(self, title: str, level: str) -> Dict[str, Any]:
        """Generate engaging practice exercises"""
        return {
            "type": "practice_exercises",
            "lesson_topic": title,
            "difficulty_level": level,
            "exercises": [
                {
                    "id": "ex_1",
                    "type": "multiple_choice",
                    "question": f"What is the Vietnamese word for the main concept of {title}?",
                    "options": [
                        {"text": "Option A", "correct": False},
                        {"text": "Option B", "correct": True},
                        {"text": "Option C", "correct": False}
                    ],
                    "explanation": "This is the correct Vietnamese terminology"
                },
                {
                    "id": "ex_2",
                    "type": "fill_in_blank",
                    "sentence": "Tôi yêu tiếng Việt vì nó là _______",
                    "answer": "ngôn ngữ đẹp",
                    "accepted_variations": ["ngôn ngữ", "tiếng Việt"],
                    "hint": "Think about what Vietnamese language is..."
                },
                {
                    "id": "ex_3",
                    "type": "matching",
                    "pairs": [
                        {"vietnamese": "Xin chào", "english": "Hello"},
                        {"vietnamese": "Cảm ơn", "english": "Thank you"},
                        {"vietnamese": "Tạm biệt", "english": "Goodbye"}
                    ]
                },
                {
                    "id": "ex_4",
                    "type": "free_response",
                    "prompt": f"Write a short sentence in Vietnamese about {title}",
                    "min_length": 5,
                    "max_length": 100,
                    "evaluation_criteria": ["grammar", "vocabulary", "meaning"],
                    "ai_evaluation": True
                },
                {
                    "id": "ex_5",
                    "type": "scenario_based",
                    "scenario": "You meet a Vietnamese friend. What do you say about this lesson's topic?",
                    "context": f"Discussing {title} in Vietnamese",
                    "allow_voice_input": True,
                    "allow_text_input": True
                }
            ],
            "scoring": {
                "total_points": 100,
                "point_distribution": "equal",
                "passing_score": 70
            },
            "engagement_rewards": {
                "completion_badge": f"Mastered {title}",
                "streak_bonus": True,
                "leaderboard_points": 10
            }
        }
    
    def generate_batch_for_course(self, course_pages: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Generate content for entire course"""
        
        print(f"\n[GENERATOR] 📚 Generating content for {len(course_pages)} course pages")
        
        batch_result = {
            "batch_id": str(uuid.uuid4())[:8],
            "generated_at": datetime.now().isoformat(),
            "total_pages": len(course_pages),
            "pages_content": [],
            "statistics": {
                "total_components": 0,
                "total_exercises": 0,
                "total_microphone_activities": 0
            }
        }
        
        for page in course_pages:
            page_content = self.generate_page_content(
                page_id=page.get("id"),
                lesson_title=page.get("title", "Lesson"),
                learning_level=page.get("level", "beginner"),
                student_name=page.get("student_name")
            )
            
            batch_result["pages_content"].append(page_content)
            
            # Update statistics
            if "practice" in page_content["components"]:
                batch_result["statistics"]["total_exercises"] += len(
                    page_content["components"]["practice"].get("exercises", [])
                )
            if "microphone_activity" in page_content["components"]:
                batch_result["statistics"]["total_microphone_activities"] += len(
                    page_content["components"]["microphone_activity"].get("activities", [])
                )
        
        print(f"[GENERATOR] ✅ Batch generation complete: {batch_result['batch_id']}")
        return batch_result


def main():
    """Demo the content generator"""
    generator = CourseContentGenerator()
    
    # Generate sample pages
    sample_pages = [
        {"id": 6, "title": "Greetings & Introductions", "level": "beginner", "student_name": "Student"},
        {"id": 7, "title": "Numbers & Counting", "level": "beginner"},
        {"id": 8, "title": "Family & Relationships", "level": "intermediate"},
    ]
    
    batch = generator.generate_batch_for_course(sample_pages)
    
    # Save batch
    output_path = "/home/simon/Learning-Management-System-Academy/data/generated_course_content_sample.json"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(batch, f, indent=2, ensure_ascii=False)
    
    print(f"\n[DONE] Content saved to: {output_path}")
    print(f"Generated {len(batch['pages_content'])} pages")
    print(f"Total exercises: {batch['statistics']['total_exercises']}")
    print(f"Total microphone activities: {batch['statistics']['total_microphone_activities']}")


if __name__ == "__main__":
    import os
    main()
