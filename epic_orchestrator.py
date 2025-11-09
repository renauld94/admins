#!/usr/bin/env python3
"""
🎯 EPIC AGENT ORCHESTRATOR & COORDINATOR
==========================================
Coordinates all 4 AI agents with multimedia to deliver personalized Vietnamese lessons
This runs on port 5100 and serves as the master controller for the course
"""

import requests
import json
import time
from datetime import datetime
from typing import Dict, List, Any, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import logging

# ============================================================================
# CONFIGURATION
# ============================================================================

AGENT_ENDPOINTS = {
    "code_agent": "http://localhost:5101",
    "data_agent": "http://localhost:5102",
    "course_agent": "http://localhost:5103",
    "tutor_agent": "http://localhost:5104",
}

MULTIMEDIA_SERVICE = "http://localhost:5105"

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("orchestrator")

# ============================================================================
# FASTAPI APP
# ============================================================================

app = FastAPI(
    title="🎓 EPIC Vietnamese Course Orchestrator",
    description="Master controller for personalized AI-powered Vietnamese lessons with multimedia",
    version="2.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# ORCHESTRATOR ENDPOINTS
# ============================================================================

@app.get("/")
async def root():
    """Welcome to the EPIC Vietnamese Course Platform"""
    return {
        "title": "🎓 EPIC Vietnamese Mastery System",
        "tagline": "AI-Powered Personalized Learning with Multimedia",
        "version": "2.0",
        "features": [
            "✅ 4 specialized AI agents (Code, Data, Course, Tutor)",
            "✅ Vietnamese speech synthesis (TTS)",
            "✅ Speech-to-text transcription",
            "✅ Personalized learning paths",
            "✅ Real-time performance analytics",
            "✅ Adaptive difficulty adjustment"
        ],
        "documentation": "http://localhost:5100/docs",
        "agents": {
            "code_support": "http://localhost:5101",
            "data_analytics": "http://localhost:5102",
            "course_content": "http://localhost:5103",
            "tutor_guidance": "http://localhost:5104"
        },
        "multimedia": "http://localhost:5105"
    }

@app.get("/health")
async def health():
    """System health check - verify all agents and multimedia service"""
    health_status = {
        "orchestrator": "running",
        "timestamp": datetime.now().isoformat(),
        "agents": {},
        "multimedia": None,
        "overall": "ok"
    }
    
    # Check each agent
    for agent_name, endpoint in AGENT_ENDPOINTS.items():
        try:
            response = requests.get(f"{endpoint}/health", timeout=5)
            if response.status_code == 200:
                data = response.json()
                health_status["agents"][agent_name] = {
                    "status": "🟢 RUNNING",
                    "model": data.get("model", "unknown"),
                    "port": data.get("port", "unknown")
                }
            else:
                health_status["agents"][agent_name] = {"status": "🔴 FAILED"}
                health_status["overall"] = "degraded"
        except Exception as e:
            health_status["agents"][agent_name] = {
                "status": f"🔴 ERROR: {str(e)[:30]}"
            }
            health_status["overall"] = "degraded"
    
    # Check multimedia service
    try:
        response = requests.get(f"{MULTIMEDIA_SERVICE}/health", timeout=5)
        if response.status_code == 200:
            health_status["multimedia"] = {
                "status": "🟢 RUNNING",
                "service": response.json().get("service", "multimedia")
            }
        else:
            health_status["multimedia"] = {"status": "🔴 FAILED"}
            health_status["overall"] = "degraded"
    except Exception as e:
        health_status["multimedia"] = {"status": f"🔴 ERROR: {str(e)[:30]}"}
        health_status["overall"] = "degraded"
    
    return health_status

@app.get("/dashboard")
async def dashboard():
    """Get system dashboard with all stats"""
    dashboard = {
        "title": "🎓 EPIC Vietnamese Course Dashboard",
        "deployment_date": "2025-11-09",
        "system_status": "🟢 ONLINE",
        "students_capacity": "Unlimited",
        "concurrent_sessions": "~100 per VM 159 resources",
        "uptime": "24/7",
        "features_deployed": {
            "personalized_lessons": "✅",
            "speech_synthesis": "✅ gTTS Vietnamese",
            "speech_recognition": "✅ HF Whisper API",
            "ai_tutoring": "✅ 4 specialized agents",
            "progress_analytics": "✅",
            "adaptive_difficulty": "✅",
            "multimedia_content": "✅ 100+ pages"
        },
        "agents_operational": {
            "code_agent": "🟢 Codestral 22B - Technical support",
            "data_agent": "🟢 Qwen 7B - Analytics",
            "course_agent": "🟢 Llama 3.2 3B - Lesson generation",
            "tutor_agent": "🟢 Qwen 7B - Personalized guidance"
        },
        "infrastructure": {
            "orchestrator_port": 5100,
            "agents_ports": "5101-5104",
            "multimedia_port": 5105,
            "ollama_vm": "VM 159",
            "models_available": 3
        },
        "access_endpoints": {
            "api_docs": "http://localhost:5100/docs",
            "code_agent": "http://localhost:5101/docs",
            "data_agent": "http://localhost:5102/docs",
            "course_agent": "http://localhost:5103/docs",
            "tutor_agent": "http://localhost:5104/docs",
            "multimedia": "http://localhost:5105/docs"
        }
    }
    return dashboard

@app.post("/personalized-lesson")
async def personalized_lesson(
    student_name: str,
    topic: str,
    level: str = "beginner",
    learning_style: str = "visual"
):
    """
    🎯 MAIN ENDPOINT: Generate personalized Vietnamese lesson
    Orchestrates all agents to create a complete, multimedia-rich lesson
    """
    logger.info(f"🎓 Creating personalized lesson for {student_name} on {topic}")
    
    try:
        lesson_result = {
            "student": student_name,
            "topic": topic,
            "level": level,
            "learning_style": learning_style,
            "timestamp": datetime.now().isoformat(),
            "components": {}
        }
        
        # 1. Get lesson content from Course Agent
        logger.info("📚 Requesting lesson content from Course Agent...")
        course_response = requests.post(
            f"{AGENT_ENDPOINTS['course_agent']}/generate-lesson",
            params={
                "topic": topic,
                "level": level,
                "duration_minutes": 30
            },
            timeout=120
        )
        
        if course_response.status_code == 200:
            course_data = course_response.json()
            lesson_result["components"]["lesson_content"] = {
                "content": course_data.get("lesson_content", ""),
                "audio": course_data.get("audio_introduction")
            }
            logger.info("✅ Lesson content generated")
        else:
            logger.warning(f"⚠️ Course Agent failed: {course_response.status_code}")
            lesson_result["components"]["lesson_content"] = {"error": "Failed to generate"}
        
        # 2. Get personalized guidance from Tutor Agent
        logger.info("👨‍🏫 Requesting personalized guidance from Tutor Agent...")
        tutor_response = requests.post(
            f"{AGENT_ENDPOINTS['tutor_agent']}/personalized-guidance",
            params={
                "student_id": f"student_{int(time.time())}",
                "student_name": student_name,
                "current_topic": topic,
                "learning_style": learning_style,
                "struggle_area": "pronunciation"
            },
            timeout=120
        )
        
        if tutor_response.status_code == 200:
            tutor_data = tutor_response.json()
            lesson_result["components"]["personalized_guidance"] = {
                "guidance": tutor_data.get("guidance", ""),
                "audio": tutor_data.get("audio_guidance")
            }
            logger.info("✅ Personalized guidance provided")
        else:
            logger.warning(f"⚠️ Tutor Agent failed: {tutor_response.status_code}")
        
        # 3. Generate quiz from Course Agent
        logger.info("❓ Creating quiz from Course Agent...")
        quiz_response = requests.post(
            f"{AGENT_ENDPOINTS['course_agent']}/create-quiz",
            params={
                "topic": topic,
                "num_questions": 5
            },
            timeout=120
        )
        
        if quiz_response.status_code == 200:
            quiz_data = quiz_response.json()
            lesson_result["components"]["quiz"] = {
                "questions": quiz_data.get("quiz", ""),
                "audio": quiz_data.get("audio_intro")
            }
            logger.info("✅ Quiz generated")
        else:
            logger.warning(f"⚠️ Quiz generation failed: {quiz_response.status_code}")
        
        # 4. Generate data insights from Data Agent
        logger.info("📊 Requesting data insights from Data Agent...")
        insights_response = requests.post(
            f"{AGENT_ENDPOINTS['data_agent']}/insights",
            params={"metric": f"learning_{topic}_progress"},
            timeout=120
        )
        
        if insights_response.status_code == 200:
            insights_data = insights_response.json()
            lesson_result["components"]["insights"] = {
                "insights": insights_data.get("insights", ""),
                "audio": insights_data.get("audio_insights")
            }
            logger.info("✅ Insights generated")
        else:
            logger.warning(f"⚠️ Insights failed: {insights_response.status_code}")
        
        # 5. Get code help if relevant (for advanced lessons)
        if "code" in topic.lower() or "python" in topic.lower():
            logger.info("💻 Requesting code help from Code Agent...")
            code_response = requests.post(
                f"{AGENT_ENDPOINTS['code_agent']}/help",
                params={
                    "topic": topic,
                    "student_name": student_name
                },
                timeout=120
            )
            
            if code_response.status_code == 200:
                code_data = code_response.json()
                lesson_result["components"]["code_help"] = {
                    "response": code_data.get("response", ""),
                    "audio": code_data.get("audio_url")
                }
                logger.info("✅ Code help provided")
        
        lesson_result["status"] = "complete"
        logger.info(f"✅ Complete personalized lesson generated for {student_name}")
        
        return lesson_result
        
    except Exception as e:
        logger.error(f"❌ Error creating lesson: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analyze-student-progress")
async def analyze_progress(student_id: str, week: int):
    """Analyze student progress using Data Agent"""
    logger.info(f"📊 Analyzing progress for student {student_id}, week {week}")
    
    try:
        response = requests.post(
            f"{AGENT_ENDPOINTS['data_agent']}/analyze-progress",
            params={
                "student_id": student_id,
                "week": week
            },
            timeout=120
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            raise HTTPException(status_code=response.status_code, detail="Data Agent error")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/adaptive-lesson")
async def adaptive_lesson(
    student_id: str,
    topic: str,
    current_performance: float,
    current_level: str
):
    """
    Generate adaptive lesson: if performance is good, increase difficulty
    If struggling, provide more foundational content
    """
    logger.info(f"📈 Generating adaptive lesson for {student_id}")
    
    try:
        # Get difficulty recommendation from Tutor
        rec_response = requests.post(
            f"{AGENT_ENDPOINTS['tutor_agent']}/adaptive-difficulty",
            params={
                "student_id": student_id,
                "performance": current_performance,
                "current_level": current_level
            },
            timeout=120
        )
        
        recommendation = rec_response.json() if rec_response.status_code == 200 else {}
        
        # Determine new level based on performance
        if current_performance >= 80:
            new_level = "intermediate" if current_level == "beginner" else "advanced"
        elif current_performance >= 60:
            new_level = current_level  # Stay at same level
        else:
            new_level = "beginner"  # Go back to basics
        
        # Generate lesson at new level
        lesson_response = requests.post(
            f"{AGENT_ENDPOINTS['course_agent']}/generate-lesson",
            params={
                "topic": topic,
                "level": new_level,
                "duration_minutes": 30
            },
            timeout=120
        )
        
        result = {
            "student_id": student_id,
            "topic": topic,
            "current_performance": current_performance,
            "previous_level": current_level,
            "recommended_level": new_level,
            "recommendation": recommendation.get("recommendation", ""),
            "new_lesson": lesson_response.json() if lesson_response.status_code == 200 else {},
            "timestamp": datetime.now().isoformat()
        }
        
        logger.info(f"✅ Adaptive lesson generated (level: {current_level} → {new_level})")
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# STATUS & MONITORING
# ============================================================================

@app.get("/agents/status")
async def agent_status():
    """Get detailed status of all agents"""
    status = {}
    
    for agent_name, endpoint in AGENT_ENDPOINTS.items():
        try:
            response = requests.get(f"{endpoint}/health", timeout=5)
            if response.status_code == 200:
                status[agent_name] = {
                    "status": "🟢 RUNNING",
                    "data": response.json()
                }
            else:
                status[agent_name] = {"status": "🔴 FAILED"}
        except Exception as e:
            status[agent_name] = {"status": f"🔴 ERROR: {str(e)[:50]}"}
    
    return status

@app.get("/docs-custom")
async def custom_docs():
    """Custom documentation page"""
    return {
        "title": "📚 EPIC Vietnamese Course - API Documentation",
        "system_overview": {
            "description": "AI-powered personalized Vietnamese learning platform",
            "components": 5,
            "agents": 4,
            "multimedia_enabled": True
        },
        "main_endpoints": {
            "/personalized-lesson": "POST - Generate complete personalized lesson with all components",
            "/adaptive-lesson": "POST - Auto-adjust difficulty based on performance",
            "/analyze-student-progress": "POST - Analyze student progress and provide insights",
            "/health": "GET - Check system health",
            "/dashboard": "GET - View system dashboard"
        },
        "agent_endpoints": AGENT_ENDPOINTS,
        "multimedia_service": MULTIMEDIA_SERVICE,
        "example_request": {
            "method": "POST",
            "endpoint": "/personalized-lesson",
            "params": {
                "student_name": "Nguyễn Văn A",
                "topic": "Vietnamese Greetings",
                "level": "beginner",
                "learning_style": "visual"
            }
        }
    }

# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    print("\n" + "="*80)
    print("🎓 EPIC VIETNAMESE COURSE ORCHESTRATOR - Starting...")
    print("="*80)
    print()
    print("🚀 System Components:")
    print("   ✅ Orchestrator (port 5100)")
    print("   ✅ Code Agent (port 5101) - Codestral 22B")
    print("   ✅ Data Agent (port 5102) - Qwen 7B")
    print("   ✅ Course Agent (port 5103) - Llama 3.2 3B")
    print("   ✅ Tutor Agent (port 5104) - Qwen 7B")
    print("   ✅ Multimedia Service (port 5105) - TTS/Transcription")
    print()
    print("📡 Access Points:")
    print("   API Docs: http://localhost:5100/docs")
    print("   Health: http://localhost:5100/health")
    print("   Dashboard: http://localhost:5100/dashboard")
    print()
    print("🎯 Main Endpoint:")
    print("   POST /personalized-lesson")
    print("        ?student_name=Nguyễn Văn A")
    print("        &topic=Vietnamese Greetings")
    print("        &level=beginner")
    print("        &learning_style=visual")
    print()
    print("="*80 + "\n")
    
    uvicorn.run(app, host="0.0.0.0", port=5100, log_level="info")
