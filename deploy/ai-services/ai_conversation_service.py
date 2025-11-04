#!/usr/bin/env python3
"""
🤖 AI Conversation Partner - Vietnamese Language Practice
Port: 8100
Purpose: Real-time conversation practice with AI tutor
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

app = FastAPI(title="AI Conversation Partner", version="1.0")

# CORS for Moodle integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://moodle.simondatalab.de", "http://localhost:*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Conversation scenarios
SCENARIOS = {
    'coffee_shop': {
        'name': 'Coffee Shop Conversation',
        'context': "You are Lan, a friendly barista at a traditional Vietnamese coffee shop in Hanoi.",
        'vocabulary': ['cà phê', 'sữa đá', 'nóng', 'lạnh', 'bao nhiêu tiền', 'ngon', 'cảm ơn'],
        'cultural_notes': "Vietnamese coffee culture emphasizes slow enjoyment and condensed milk.",
        'intro': "Xin chào! Chào mừng bạn đến quán cà phê. Bạn muốn uống gì?"
    },
    'greetings': {
        'name': 'Basic Greetings & Introductions',
        'context': "You are Mai, a Vietnamese language partner helping someone practice basic greetings.",
        'vocabulary': ['xin chào', 'tên', 'tôi', 'bạn', 'đến từ', 'rất vui', 'gặp bạn'],
        'cultural_notes': "Vietnamese has different pronouns based on age and social hierarchy.",
        'intro': "Xin chào! Tôi tên là Mai. Bạn tên là gì?"
    },
    'business_meeting': {
        'name': 'Business Meeting',
        'context': "You are Mr. Tuấn, a Vietnamese business partner at a formal meeting.",
        'vocabulary': ['hợp đồng', 'thương lượng', 'đối tác', 'doanh thu', 'phát triển', 'công ty'],
        'cultural_notes': "Business in Vietnam requires respect for hierarchy and relationship building.",
        'intro': "Chào anh/chị. Rất vui được gặp đối tác từ công ty của quý vị."
    },
    'shopping': {
        'name': 'Shopping at Market',
        'context': "You are Hoa, a vendor at Ben Thanh Market in Saigon.",
        'vocabulary': ['bao nhiêu', 'tiền', 'mua', 'bán', 'rẻ', 'đắt', 'giảm giá'],
        'cultural_notes': "Bargaining is common in Vietnamese markets. Be friendly but firm.",
        'intro': "Chào chị! Hàng tươi ngon đây, mời chị xem!"
    },
    'restaurant': {
        'name': 'Ordering at Restaurant',
        'context': "You are a waiter at a traditional Vietnamese restaurant.",
        'vocabulary': ['phở', 'bún chả', 'món ăn', 'ngon', 'đặc sản', 'nước uống'],
        'cultural_notes': "Vietnamese cuisine varies by region. Hanoi vs Saigon styles differ.",
        'intro': "Xin chào! Bạn muốn gọi món gì ạ?"
    }
}

SYSTEM_PROMPT_TEMPLATE = """You are {character}, a native Vietnamese speaker. You're having a conversation with a {level} student learning Vietnamese.

CONTEXT: {context}

RULES:
1. Respond ONLY in Vietnamese (no English in your responses)
2. Keep language complexity appropriate for {level} level
3. Use vocabulary from this list when possible: {vocabulary}
4. Be natural and conversational
5. Gently correct errors without being pedantic
6. Stay in character for the scenario
7. Keep responses to 2-3 sentences maximum
8. Be encouraging and patient

CULTURAL NOTES: {cultural_notes}

After each exchange, you will analyze the student's Vietnamese and provide feedback in a separate message.
"""

FEEDBACK_PROMPT = """Analyze this Vietnamese sentence from a {level} student:
Student said: "{student_text}"

Provide detailed feedback as JSON:
{{
    "grammar_score": 0-100,
    "tone_accuracy": 0-100,
    "vocabulary_level": "too_simple" | "appropriate" | "too_complex",
    "errors": [
        {{
            "type": "grammar|tone|vocabulary|usage",
            "issue": "what's wrong",
            "correction": "how to fix it",
            "explanation": "why"
        }}
    ],
    "encouragement": "specific positive feedback",
    "improvement_tip": "one specific thing to improve",
    "cultural_note": "relevant cultural context if applicable"
}}

Be constructive and encouraging!
"""

class ConversationSession:
    def __init__(self, session_id: str, scenario: str, level: str):
        self.session_id = session_id
        self.scenario = scenario
        self.level = level
        self.history = []
        self.created_at = datetime.now()
        self.ollama_client = ollama.Client()
        
    def get_system_prompt(self) -> str:
        scenario_data = SCENARIOS[self.scenario]
        return SYSTEM_PROMPT_TEMPLATE.format(
            character=scenario_data['name'],
            level=self.level,
            context=scenario_data['context'],
            vocabulary=', '.join(scenario_data['vocabulary']),
            cultural_notes=scenario_data['cultural_notes']
        )
    
    async def generate_response(self, user_message: str) -> Dict:
        """Generate AI response to user's Vietnamese"""
        
        # Add user message to history
        self.history.append({
            "role": "user",
            "content": user_message
        })
        
        # Build messages for Ollama
        messages = [
            {"role": "system", "content": self.get_system_prompt()}
        ] + self.history
        
        try:
            # Generate response
            response = self.ollama_client.chat(
                model='qwen2.5:7b-instruct',
                messages=messages,
                options={
                    'temperature': 0.7,
                    'top_p': 0.9
                }
            )
            
            ai_response = response['message']['content']
            
            # Add to history
            self.history.append({
                "role": "assistant",
                "content": ai_response
            })
            
            # Generate audio for AI response
            audio_base64 = None
            try:
                tts = gTTS(text=ai_response, lang='vi', slow=False)
                audio_buffer = io.BytesIO()
                tts.write_to_fp(audio_buffer)
                audio_buffer.seek(0)
                audio_base64 = base64.b64encode(audio_buffer.read()).decode('utf-8')
            except Exception as e:
                logger.warning(f"TTS generation failed: {e}")
            
            # Generate feedback
            feedback = await self.analyze_student_vietnamese(user_message)
            
            return {
                'type': 'ai_response',
                'vietnamese_text': ai_response,
                'audio_base64': audio_base64,
                'feedback': feedback,
                'timestamp': datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error generating response: {e}")
            raise HTTPException(status_code=500, detail=str(e))
    
    async def analyze_student_vietnamese(self, text: str) -> Dict:
        """AI analyzes student's Vietnamese"""
        
        prompt = FEEDBACK_PROMPT.format(level=self.level, student_text=text)
        
        try:
            response = self.ollama_client.chat(
                model='qwen2.5:7b',
                messages=[{"role": "user", "content": prompt}],
                format='json'
            )
            
            feedback = json.loads(response['message']['content'])
            return feedback
            
        except Exception as e:
            logger.error(f"Error analyzing Vietnamese: {e}")
            return {
                'grammar_score': 50,
                'tone_accuracy': 50,
                'vocabulary_level': 'appropriate',
                'errors': [],
                'encouragement': 'Keep practicing!',
                'improvement_tip': 'Focus on pronunciation',
                'cultural_note': ''
            }

# Session management
sessions: Dict[str, ConversationSession] = {}

@app.get("/")
async def root():
    return {
        "service": "AI Conversation Partner",
        "version": "1.0",
        "status": "running",
        "scenarios": list(SCENARIOS.keys())
    }

@app.get("/scenarios")
async def get_scenarios():
    """List available conversation scenarios"""
    return {
        'scenarios': [
            {
                'id': key,
                'name': data['name'],
                'vocabulary_count': len(data['vocabulary']),
                'description': data['context']
            }
            for key, data in SCENARIOS.items()
        ]
    }

@app.websocket("/ws/conversation")
async def conversation_websocket(websocket: WebSocket):
    """WebSocket endpoint for real-time conversation"""
    
    await websocket.accept()
    session_id = str(uuid.uuid4())
    session = None
    
    logger.info(f"New WebSocket connection: {session_id}")
    
    try:
        while True:
            data = await websocket.receive_json()
            
            if data['type'] == 'start_scenario':
                # Initialize new conversation
                scenario = data.get('scenario', 'greetings')
                level = data.get('level', 'beginner')
                
                session = ConversationSession(session_id, scenario, level)
                sessions[session_id] = session
                
                # Send introduction
                intro = SCENARIOS[scenario]['intro']
                await websocket.send_json({
                    'type': 'ai_message',
                    'text': intro,
                    'scenario': scenario,
                    'level': level,
                    'session_id': session_id
                })
                
            elif data['type'] == 'student_message':
                # Student sent Vietnamese text
                if session is None:
                    await websocket.send_json({
                        'type': 'error',
                        'message': 'No active session. Please start a scenario first.'
                    })
                    continue
                
                student_text = data.get('text', '')
                
                # Generate AI response
                response = await session.generate_response(student_text)
                await websocket.send_json(response)
                
            elif data['type'] == 'end_conversation':
                # Clean up session
                if session_id in sessions:
                    del sessions[session_id]
                await websocket.send_json({
                    'type': 'goodbye',
                    'message': 'Tạm biệt! See you next time!'
                })
                break
                
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected: {session_id}")
        if session_id in sessions:
            del sessions[session_id]
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        await websocket.send_json({
            'type': 'error',
            'message': str(e)
        })

@app.post("/api/test-model")
async def test_model(prompt: str = "Xin chào! Bạn khỏe không?"):
    """Test Ollama model"""
    try:
        client = ollama.Client()
        response = client.chat(
            model='qwen2.5:7b-instruct',
            messages=[{'role': 'user', 'content': prompt}]
        )
        return {
            'success': True,
            'prompt': prompt,
            'response': response['message']['content'],
            'model': 'qwen2.5:7b'
        }
    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }

@app.post("/api/text-to-speech")
async def text_to_speech(text: str, lang: str = "vi"):
    """Convert Vietnamese text to speech"""
    try:
        # Generate speech using gTTS
        tts = gTTS(text=text, lang=lang, slow=False)
        
        # Save to bytes buffer
        audio_buffer = io.BytesIO()
        tts.write_to_fp(audio_buffer)
        audio_buffer.seek(0)
        
        # Return audio file
        return Response(
            content=audio_buffer.read(),
            media_type="audio/mpeg",
            headers={
                "Content-Disposition": "attachment; filename=speech.mp3"
            }
        )
    except Exception as e:
        logger.error(f"TTS error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/speech-to-text")
async def speech_to_text(audio: UploadFile = File(...)):
    """Convert speech to text using Web Speech API proxy"""
    try:
        # Save uploaded audio to temp file
        audio_data = await audio.read()
        
        # For now, return a placeholder
        # In production, integrate with speech recognition service
        # like Whisper, Google Speech-to-Text, or Azure Speech
        return {
            'success': False,
            'message': 'Speech-to-text will use browser Web Speech API',
            'text': ''
        }
    except Exception as e:
        logger.error(f"STT error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        # Test Ollama connection
        client = ollama.Client()
        models_response = client.list()
        
        # Extract model names from response
        model_names = []
        if hasattr(models_response, 'models'):
            model_names = [m.model for m in models_response.models]
        
        return {
            'status': 'healthy',
            'service': 'ai-conversation',
            'ollama_available': True,
            'models_loaded': model_names,
            'active_sessions': len(sessions),
            'features': {
                'text_to_speech': True,
                'speech_to_text': 'browser_only'
            }
        }
    except Exception as e:
        return {
            'status': 'unhealthy',
            'service': 'ai-conversation',
            'ollama_available': False,
            'error': str(e)
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8100)
