#!/usr/bin/env python3
"""
🤖 AI Conversation Partner - BEGINNER FRIENDLY Vietnamese Practice
Port: 8100 - SIMPLIFIED FOR COMPLETE BEGINNERS
"""

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, JSONResponse, Response
import ollama
import json
import uuid
import asyncio
from datetime import datetime
from typing import Dict, List, Optional
import logging
from gtts import gTTS
import io
import base64
import tempfile
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI Conversation Partner - Beginner", version="2.0")

# CORS for Moodle integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://moodle.simondatalab.de", "http://localhost:*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# SUPER SIMPLE SCENARIOS FOR BEGINNERS
SCENARIOS = {
    'greetings': {
        'name': '👋 Hello & Goodbye (SUPER EASY)',
        'level': 'absolute beginner',
        'context': "A very friendly Vietnamese person wants to say hello!",
        'vocabulary': ['xin chào', 'tạm biệt', 'cảm ơn'],
        'intro': "Xin chào! 😊 (Hello!)",
        'tips': [
            "Xin chào = Hello",
            "Tạm biệt = Goodbye",
            "Cảm ơn = Thank you"
        ]
    },
    'numbers': {
        'name': '🔢 Count 1-5 (SUPER EASY)',
        'level': 'absolute beginner',
        'context': "Let's practice Vietnamese numbers together!",
        'vocabulary': ['một', 'hai', 'ba', 'bốn', 'năm'],
        'intro': "Một, hai, ba! (One, two, three!)",
        'tips': [
            "Một = 1",
            "Hai = 2",
            "Ba = 3",
            "Bốn = 4",
            "Năm = 5"
        ]
    },
    'coffee': {
        'name': '☕ Order Coffee (EASY)',
        'level': 'beginner',
        'context': "You're at a cafe. Just order a simple drink!",
        'vocabulary': ['cà phê', 'trà', 'nước', 'một'],
        'intro': "Xin chào! Bạn muốn uống gì? (Hello! What to drink?)",
        'tips': [
            "Một cà phê = One coffee",
            "Một trà = One tea",
            "Bao nhiêu? = How much?",
            "Cảm ơn = Thank you"
        ]
    },
    'food': {
        'name': '🍜 Order Food (EASY)',
        'level': 'beginner',
        'context': "Order simple Vietnamese food",
        'vocabulary': ['phở', 'cơm', 'bánh mì', 'một'],
        'intro': "Bạn muốn ăn gì? (What to eat?)",
        'tips': [
            "Một phở = One pho",
            "Một cơm = One rice",
            "Một bánh mì = One sandwich"
        ]
    },
    'intro': {
        'name': '😊 Say Your Name (EASY)',
        'level': 'beginner',
        'context': "Introduce yourself in Vietnamese!",
        'vocabulary': ['tôi', 'tên', 'là'],
        'intro': "Bạn tên là gì? (What's your name?)",
        'tips': [
            "Tôi tên là... = My name is...",
            "Tôi là John = I am John",
            "Rất vui = Nice (to meet you)"
        ]
    }
}

# Store active sessions
active_sessions: Dict[str, Dict] = {}

SYSTEM_PROMPT_TEMPLATE = """You are a SUPER PATIENT and FRIENDLY Vietnamese teacher for COMPLETE BEGINNERS.

Scenario: {name}
Student level: {level}

VERY IMPORTANT RULES:
1. Keep responses EXTREMELY SHORT (3-5 words max)
2. Use ONLY the simplest Vietnamese words
3. Be SUPER encouraging - always praise their effort!
4. NEVER use complex grammar
5. If they make a mistake, just respond naturally - don't correct
6. Sound like a very kind friend, not a strict teacher

Helpful words for this scenario:
{tips}

Simple vocabulary: {vocabulary}

Remember: They are BEGINNERS! Keep it simple and fun! 😊"""

async def generate_ai_response(student_message: str, scenario_id: str, session_id: str) -> str:
    """Generate simple, beginner-friendly AI response"""
    
    scenario = SCENARIOS.get(scenario_id, SCENARIOS['greetings'])
    
    # Build super simple prompt
    system_prompt = SYSTEM_PROMPT_TEMPLATE.format(
        name=scenario['name'],
        level=scenario['level'],
        vocabulary=', '.join(scenario['vocabulary']),
        tips='\n'.join(scenario.get('tips', []))
    )
    
    conversation_prompt = f"""Student said: "{student_message}"

Now respond in Vietnamese:
- Keep it VERY short (3-5 words)
- Be encouraging
- Use simple words only
- Sound friendly and patient

Response:"""

    try:
        # Call Ollama
        response = ollama.chat(
            model='gemma2:9b',
            messages=[
                {'role': 'system', 'content': system_prompt},
                {'role': 'user', 'content': conversation_prompt}
            ]
        )
        
        ai_text = response['message']['content'].strip()
        
        # Keep it short if AI gets verbose
        if len(ai_text.split()) > 10:
            ai_text = ' '.join(ai_text.split()[:10]) + "..."
        
        return ai_text
        
    except Exception as e:
        logger.error(f"Ollama error: {e}")
        # Fallback responses
        fallbacks = {
            'greetings': "Xin chào bạn! 😊",
            'coffee': "Vâng, một cà phê!",
            'food': "Một phở rất ngon!",
            'intro': "Rất vui được gặp bạn!",
            'numbers': "Một, hai, ba!"
        }
        return fallbacks.get(scenario_id, "Tốt lắm! (Very good!)")

def generate_audio(text: str) -> str:
    """Generate Vietnamese audio"""
    try:
        tts = gTTS(text=text, lang='vi', slow=True)  # SLOW for beginners!
        audio_buffer = io.BytesIO()
        tts.write_to_fp(audio_buffer)
        audio_buffer.seek(0)
        audio_base64 = base64.b64encode(audio_buffer.read()).decode()
        return audio_base64
    except Exception as e:
        logger.error(f"TTS error: {e}")
        return ""

@app.get("/health")
async def health_check():
    """Health check"""
    try:
        ollama.list()
        ollama_status = True
    except:
        ollama_status = False
    
    return {
        "status": "healthy",
        "service": "ai-conversation-beginner",
        "ollama_available": ollama_status,
        "features": {
            "text_to_speech": True,
            "speech_to_text": "browser_only",
            "difficulty": "beginner-friendly",
            "slow_audio": True
        },
        "scenarios": len(SCENARIOS)
    }

@app.get("/api/scenarios")
async def get_scenarios():
    """Get all beginner scenarios"""
    return {
        "scenarios": {
            key: {
                "name": val["name"],
                "level": val["level"],
                "vocabulary": val["vocabulary"],
                "tips": val.get("tips", [])
            }
            for key, val in SCENARIOS.items()
        }
    }

@app.websocket("/ws/conversation")
async def websocket_conversation(websocket: WebSocket):
    """WebSocket for real-time conversation"""
    await websocket.accept()
    session_id = str(uuid.uuid4())
    logger.info(f"New conversation session: {session_id}")
    
    try:
        while True:
            data = await websocket.receive_json()
            action = data.get("action")
            
            if action == "start":
                scenario_id = data.get("scenario", "greetings")
                scenario = SCENARIOS.get(scenario_id, SCENARIOS["greetings"])
                
                # Store session
                active_sessions[session_id] = {
                    "scenario": scenario_id,
                    "started": datetime.now().isoformat(),
                    "messages": []
                }
                
                # Send intro message with audio
                intro_text = scenario["intro"]
                intro_audio = generate_audio(intro_text)
                
                await websocket.send_json({
                    "type": "ai_message",
                    "text": intro_text,
                    "audio": intro_audio,
                    "tips": scenario.get("tips", [])
                })
            
            elif action == "message":
                student_message = data.get("message", "").strip()
                scenario_id = active_sessions.get(session_id, {}).get("scenario", "greetings")
                
                if student_message:
                    # Generate AI response
                    ai_response = await generate_ai_response(
                        student_message, 
                        scenario_id, 
                        session_id
                    )
                    
                    # Generate audio (SLOW for beginners)
                    audio_base64 = generate_audio(ai_response)
                    
                    # Send response
                    await websocket.send_json({
                        "type": "ai_message",
                        "text": ai_response,
                        "audio": audio_base64,
                        "encouragement": "Tốt lắm! (Good job!) 👍"
                    })
            
            elif action == "end":
                if session_id in active_sessions:
                    del active_sessions[session_id]
                await websocket.send_json({
                    "type": "session_ended",
                    "message": "Tạm biệt! (Goodbye!) 👋"
                })
    
    except WebSocketDisconnect:
        if session_id in active_sessions:
            del active_sessions[session_id]
        logger.info(f"Session ended: {session_id}")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        await websocket.close()

@app.post("/api/text-to-speech")
async def text_to_speech(data: dict):
    """Generate Vietnamese audio"""
    text = data.get("text", "")
    if not text:
        raise HTTPException(400, "No text provided")
    
    audio = generate_audio(text)
    return {"audio": audio, "text": text}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8100, log_level="info")
