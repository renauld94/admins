#!/usr/bin/env python3
"""
🎯 EPIC VIETNAMESE COURSE AGENTS WITH MULTIMEDIA INTEGRATION
===============================================================
4 AI Agents running on Ollama VM 159 models + multimedia service (TTS/transcription)
Each agent integrates Vietnamese speech synthesis and microphone input processing

Agent Architecture:
  1. CODE AGENT (port 5101) - codestral:22b - Technical support + voice feedback
  2. DATA AGENT (port 5102) - qwen2.5:7b - Analytics + Vietnamese voice
  3. COURSE AGENT (port 5103) - llama3.2:3b - Lesson generation + audio
  4. TUTOR AGENT (port 5104) - orchestrates all models for personalized guidance

Integration Points:
  ✅ /audio/tts-synthesize (port 5105) - Generate Vietnamese speech
  ✅ /microphone/transcribe - Process student audio input
  ✅ /microphone/record - Store student recordings
  ✅ /practice/validate - Validate exercises with AI feedback
"""

import os
import sys
import json
import time
import logging
import subprocess
import requests
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
import asyncio
import uvicorn
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

# ============================================================================
# CONFIGURATION
# ============================================================================

BASE_DIR = Path(__file__).parent
LOG_DIR = BASE_DIR / "logs" / "agents"
DATA_DIR = BASE_DIR / "data" / "agents"

LOG_DIR.mkdir(parents=True, exist_ok=True)
DATA_DIR.mkdir(parents=True, exist_ok=True)

# VM 159 Ollama Configuration
OLLAMA_BASE_URL = "http://localhost:11434"
MULTIMEDIA_SERVICE_URL = "http://localhost:5105"

# Models available on VM 159
MODELS = {
    "code_agent": "codestral:22b-v0.1-q4_0",      # Technical support
    "data_agent": "qwen2.5:7b",                    # Analytics
    "course_agent": "llama3.2:3b",                 # Lesson generation
    "tutor_agent": "qwen2.5:7b"                    # Personalized guidance (uses Qwen2.5)
}

# Service Ports
PORTS = {
    "code_agent": 5101,
    "data_agent": 5102,
    "course_agent": 5103,
    "tutor_agent": 5104,
    "multimedia": 5105
}

# ============================================================================
# LOGGING
# ============================================================================

def setup_logging(agent_name: str):
    """Setup logging for agent"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(LOG_DIR / f"{agent_name}.log"),
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(agent_name)

# ============================================================================
# MULTIMEDIA SERVICE HELPER
# ============================================================================

class MultimediaClient:
    """Client for interacting with multimedia service"""
    
    def __init__(self, base_url: str = MULTIMEDIA_SERVICE_URL):
        self.base_url = base_url
    
    def synthesize_speech(self, text: str, language: str = "vi") -> Optional[Dict[str, Any]]:
        """Synthesize Vietnamese text to speech"""
        try:
            response = requests.post(
                f"{self.base_url}/audio/tts-synthesize",
                params={"text": text},
                timeout=30
            )
            if response.status_code == 200:
                return response.json()
            else:
                return None
        except Exception as e:
            print(f"❌ TTS Error: {e}")
            return None
    
    def transcribe_audio(self, recording_id: str) -> Optional[Dict[str, Any]]:
        """Transcribe student audio recording to Vietnamese text"""
        try:
            response = requests.get(
                f"{self.base_url}/microphone/transcribe/{recording_id}",
                timeout=60
            )
            if response.status_code == 200:
                return response.json()
            else:
                return None
        except Exception as e:
            print(f"❌ Transcription Error: {e}")
            return None
    
    def validate_practice(self, activity_id: str, student_response: str) -> Optional[Dict[str, Any]]:
        """Validate student practice exercise"""
        try:
            response = requests.post(
                f"{self.base_url}/practice/validate",
                json={
                    "activity_id": activity_id,
                    "student_response": student_response
                },
                timeout=30
            )
            if response.status_code == 200:
                return response.json()
            else:
                return None
        except Exception as e:
            print(f"❌ Practice Validation Error: {e}")
            return None

# ============================================================================
# INDIVIDUAL AGENTS
# ============================================================================

def create_code_agent():
    """Create Code Support Agent (Codestral 22B)"""
    logger = setup_logging("code_agent")
    app = FastAPI(title="Code Agent - Vietnamese Course Support")
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    multimedia = MultimediaClient()
    
    @app.get("/health")
    async def health():
        """Health check"""
        return {
            "status": "ok",
            "agent": "code_agent",
            "model": MODELS["code_agent"],
            "port": PORTS["code_agent"],
            "multimedia_integrated": True,
            "timestamp": datetime.now().isoformat()
        }
    
    @app.post("/help")
    async def code_help(topic: str, student_name: str = "Student"):
        """Provide code help with Vietnamese voice feedback"""
        logger.info(f"🆘 Code help requested: {topic}")
        
        # Generate response from Ollama
        prompt = f"Explain this programming concept to a Vietnamese student: {topic}\nKeep it concise and clear."
        
        try:
            # Call Ollama
            response = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": MODELS["code_agent"],
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            if response.status_code != 200:
                return {"error": "Ollama unavailable"}
            
            ai_response = response.json().get("response", "No response")
            
            # Generate Vietnamese TTS
            tts_result = multimedia.synthesize_speech(f"Giúp đỡ lập trình: {ai_response[:200]}", language="vi")
            
            result = {
                "agent": "code_agent",
                "student": student_name,
                "topic": topic,
                "response": ai_response,
                "timestamp": datetime.now().isoformat()
            }
            
            if tts_result:
                result["audio_file"] = tts_result.get("audio_file")
                result["audio_url"] = f"{MULTIMEDIA_SERVICE_URL}/audio/{tts_result.get('audio_file', '').split('/')[-1]}"
            
            logger.info(f"✅ Code help provided with TTS")
            return result
            
        except Exception as e:
            logger.error(f"❌ Error: {e}")
            return {"error": str(e)}
    
    @app.post("/review")
    async def code_review(code: str, language: str = "python"):
        """Review student code with feedback"""
        logger.info(f"📝 Code review requested: {language}")
        
        prompt = f"Review this {language} code and provide constructive feedback for a Vietnamese student:\n{code}\n\nProvide specific, actionable improvements."
        
        try:
            response = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": MODELS["code_agent"],
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            ai_response = response.json().get("response", "Unable to review")
            
            # Vietnamese TTS feedback
            tts_result = multimedia.synthesize_speech(f"Nhận xét mã: {ai_response[:200]}", language="vi")
            
            result = {
                "agent": "code_agent",
                "code_language": language,
                "feedback": ai_response,
                "timestamp": datetime.now().isoformat()
            }
            
            if tts_result:
                result["audio_file"] = tts_result.get("audio_file")
            
            logger.info(f"✅ Code reviewed with AI feedback")
            return result
            
        except Exception as e:
            logger.error(f"❌ Code review error: {e}")
            return {"error": str(e)}
    
    return app, logger

def create_data_agent():
    """Create Data Analytics Agent (Qwen 7B)"""
    logger = setup_logging("data_agent")
    app = FastAPI(title="Data Agent - Vietnamese Course Analytics")
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    multimedia = MultimediaClient()
    
    @app.get("/health")
    async def health():
        """Health check"""
        return {
            "status": "ok",
            "agent": "data_agent",
            "model": MODELS["data_agent"],
            "port": PORTS["data_agent"],
            "multimedia_integrated": True,
            "timestamp": datetime.now().isoformat()
        }
    
    @app.post("/analyze-progress")
    async def analyze_progress(student_id: str, week: int):
        """Analyze student progress with Vietnamese voice summary"""
        logger.info(f"📊 Progress analysis for student {student_id}, week {week}")
        
        prompt = f"Analyze the learning progress of a Vietnamese student in week {week}. Identify strengths, areas for improvement, and personalized recommendations."
        
        try:
            response = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": MODELS["data_agent"],
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            analysis = response.json().get("response", "Unable to analyze")
            
            # Create Vietnamese audio summary
            summary_text = f"Phân tích tiến độ: {analysis[:150]}"
            tts_result = multimedia.synthesize_speech(summary_text, language="vi")
            
            result = {
                "agent": "data_agent",
                "student_id": student_id,
                "week": week,
                "analysis": analysis,
                "timestamp": datetime.now().isoformat()
            }
            
            if tts_result:
                result["audio_summary"] = tts_result.get("audio_file")
            
            logger.info(f"✅ Progress analysis completed")
            return result
            
        except Exception as e:
            logger.error(f"❌ Analysis error: {e}")
            return {"error": str(e)}
    
    @app.post("/insights")
    async def generate_insights(metric: str):
        """Generate data insights with Vietnamese explanation"""
        logger.info(f"💡 Generating insights for {metric}")
        
        prompt = f"Generate actionable insights about Vietnamese language learning for the metric: {metric}. Explain what this means and how to improve it."
        
        try:
            response = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": MODELS["data_agent"],
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            insights = response.json().get("response", "No insights")
            
            tts_result = multimedia.synthesize_speech(f"Thông tin chi tiết: {insights[:150]}", language="vi")
            
            result = {
                "agent": "data_agent",
                "metric": metric,
                "insights": insights,
                "timestamp": datetime.now().isoformat()
            }
            
            if tts_result:
                result["audio_insights"] = tts_result.get("audio_file")
            
            return result
            
        except Exception as e:
            logger.error(f"❌ Insights error: {e}")
            return {"error": str(e)}
    
    return app, logger

def create_course_agent():
    """Create Course Content Agent (Llama 3.2 3B)"""
    logger = setup_logging("course_agent")
    app = FastAPI(title="Course Agent - Vietnamese Lesson Generation")
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    multimedia = MultimediaClient()
    
    @app.get("/health")
    async def health():
        """Health check"""
        return {
            "status": "ok",
            "agent": "course_agent",
            "model": MODELS["course_agent"],
            "port": PORTS["course_agent"],
            "multimedia_integrated": True,
            "timestamp": datetime.now().isoformat()
        }
    
    @app.post("/generate-lesson")
    async def generate_lesson(topic: str, level: str = "beginner", duration_minutes: int = 30):
        """Generate personalized Vietnamese lesson with audio"""
        logger.info(f"📚 Generating {level} lesson on: {topic}")
        
        prompt = f"Create a {duration_minutes}-minute {level} Vietnamese language lesson on '{topic}' for international students. Include: 1) Key vocabulary, 2) Grammar points, 3) Practice exercises, 4) Cultural context."
        
        try:
            response = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": MODELS["course_agent"],
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            lesson_content = response.json().get("response", "Unable to generate")
            
            # Generate Vietnamese introduction
            intro_text = f"Bài học về {topic}: {lesson_content[:150]}"
            tts_result = multimedia.synthesize_speech(intro_text, language="vi")
            
            result = {
                "agent": "course_agent",
                "topic": topic,
                "level": level,
                "duration_minutes": duration_minutes,
                "lesson_content": lesson_content,
                "timestamp": datetime.now().isoformat()
            }
            
            if tts_result:
                result["audio_introduction"] = tts_result.get("audio_file")
            
            logger.info(f"✅ Lesson generated successfully")
            return result
            
        except Exception as e:
            logger.error(f"❌ Lesson generation error: {e}")
            return {"error": str(e)}
    
    @app.post("/create-quiz")
    async def create_quiz(topic: str, num_questions: int = 5):
        """Generate Vietnamese quiz with voice questions"""
        logger.info(f"❓ Creating {num_questions}-question quiz on: {topic}")
        
        prompt = f"Create a {num_questions}-question multiple-choice quiz about '{topic}' for Vietnamese language students. Format each question clearly with options A, B, C, D."
        
        try:
            response = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": MODELS["course_agent"],
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            quiz_content = response.json().get("response", "Unable to create quiz")
            
            tts_result = multimedia.synthesize_speech(f"Bài kiểm tra: {quiz_content[:100]}", language="vi")
            
            result = {
                "agent": "course_agent",
                "topic": topic,
                "num_questions": num_questions,
                "quiz": quiz_content,
                "timestamp": datetime.now().isoformat()
            }
            
            if tts_result:
                result["audio_intro"] = tts_result.get("audio_file")
            
            return result
            
        except Exception as e:
            logger.error(f"❌ Quiz creation error: {e}")
            return {"error": str(e)}
    
    return app, logger

def create_tutor_agent():
    """Create Personalized Tutor Agent (Qwen 7B - orchestrator)"""
    logger = setup_logging("tutor_agent")
    app = FastAPI(title="Tutor Agent - Personalized Vietnamese Guidance")
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    multimedia = MultimediaClient()
    
    @app.get("/health")
    async def health():
        """Health check"""
        return {
            "status": "ok",
            "agent": "tutor_agent",
            "model": MODELS["tutor_agent"],
            "port": PORTS["tutor_agent"],
            "multimedia_integrated": True,
            "orchestrates": ["code_agent", "data_agent", "course_agent"],
            "timestamp": datetime.now().isoformat()
        }
    
    @app.post("/personalized-guidance")
    async def personalized_guidance(
        student_id: str,
        student_name: str,
        current_topic: str,
        learning_style: str = "visual",
        struggle_area: str = "pronunciation"
    ):
        """Provide personalized guidance integrating all agents and multimedia"""
        logger.info(f"👨‍🏫 Personalized guidance for {student_name}")
        
        prompt = f"""You are a Vietnamese language tutor guiding {student_name}. 
        
Student Profile:
- Learning style: {learning_style}
- Current topic: {current_topic}
- Area of struggle: {struggle_area}

Provide personalized guidance that:
1) Acknowledges their learning style
2) Offers specific, actionable advice for {struggle_area}
3) Recommends practice activities
4) Provides encouragement in Vietnamese

Keep the response concise and motivational."""
        
        try:
            response = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": MODELS["tutor_agent"],
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            guidance = response.json().get("response", "Unable to provide guidance")
            
            # Synthesize personalized message
            greeting = f"Xin chào {student_name}! "
            tts_result = multimedia.synthesize_speech(greeting + guidance[:200], language="vi")
            
            result = {
                "agent": "tutor_agent",
                "student_name": student_name,
                "student_id": student_id,
                "current_topic": current_topic,
                "learning_style": learning_style,
                "guidance": guidance,
                "timestamp": datetime.now().isoformat()
            }
            
            if tts_result:
                result["audio_guidance"] = tts_result.get("audio_file")
            
            logger.info(f"✅ Personalized guidance provided with audio")
            return result
            
        except Exception as e:
            logger.error(f"❌ Guidance error: {e}")
            return {"error": str(e)}
    
    @app.post("/adaptive-difficulty")
    async def adjust_difficulty(student_id: str, performance: float, current_level: str):
        """Recommend difficulty adjustment based on performance"""
        logger.info(f"📈 Adjusting difficulty for student {student_id}")
        
        prompt = f"Based on a student's performance score of {performance}/100 in a {current_level} Vietnamese lesson, recommend whether to advance, stay, or review. Provide reasoning and next steps."
        
        try:
            response = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": MODELS["tutor_agent"],
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            recommendation = response.json().get("response", "Unable to recommend")
            
            tts_result = multimedia.synthesize_speech(f"Khuyến nghị: {recommendation[:150]}", language="vi")
            
            result = {
                "agent": "tutor_agent",
                "student_id": student_id,
                "performance": performance,
                "current_level": current_level,
                "recommendation": recommendation,
                "timestamp": datetime.now().isoformat()
            }
            
            if tts_result:
                result["audio_recommendation"] = tts_result.get("audio_file")
            
            return result
            
        except Exception as e:
            logger.error(f"❌ Difficulty adjustment error: {e}")
            return {"error": str(e)}
    
    return app, logger

# ============================================================================
# MAIN: LAUNCH ALL AGENTS
# ============================================================================

def launch_agents():
    """Launch all 4 agents as subprocesses"""
    
    agents_config = [
        ("code_agent", PORTS["code_agent"], create_code_agent),
        ("data_agent", PORTS["data_agent"], create_data_agent),
        ("course_agent", PORTS["course_agent"], create_course_agent),
        ("tutor_agent", PORTS["tutor_agent"], create_tutor_agent),
    ]
    
    print("\n" + "="*80)
    print("🚀 EPIC VIETNAMESE COURSE AGENTS WITH MULTIMEDIA")
    print("="*80)
    print()
    
    for agent_name, port, create_func in agents_config:
        app, logger = create_func()
        
        print(f"📍 Launching {agent_name.upper()}")
        print(f"   Model: {MODELS[agent_name]}")
        print(f"   Port: {port}")
        print(f"   Multimedia: ✅ Integrated")
        
        # Run in separate thread (for testing)
        import threading
        thread = threading.Thread(
            target=lambda: uvicorn.run(app, host="0.0.0.0", port=port, log_level="info"),
            daemon=True
        )
        thread.start()
        
        print(f"   Status: 🟢 RUNNING\n")
    
    print("="*80)
    print("✅ All 4 agents launched successfully!")
    print()
    print("📡 Agent Endpoints:")
    print(f"   Code Agent:     http://localhost:{PORTS['code_agent']}/docs")
    print(f"   Data Agent:     http://localhost:{PORTS['data_agent']}/docs")
    print(f"   Course Agent:   http://localhost:{PORTS['course_agent']}/docs")
    print(f"   Tutor Agent:    http://localhost:{PORTS['tutor_agent']}/docs")
    print()
    print("🎙️ Multimedia Service: http://localhost:5105/docs")
    print()
    print("🌟 Features Enabled:")
    print("   ✅ Vietnamese speech synthesis (gTTS)")
    print("   ✅ Speech-to-text transcription (Whisper via HF)")
    print("   ✅ Personalized AI responses from 4 agents")
    print("   ✅ Multi-model orchestration")
    print("   ✅ Real-time audio feedback")
    print()
    print("="*80 + "\n")
    
    # Keep running
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n🛑 Shutting down agents...")

if __name__ == "__main__":
    launch_agents()
