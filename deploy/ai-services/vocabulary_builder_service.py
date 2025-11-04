#!/usr/bin/env python3
"""
Vietnamese Vocabulary Builder Service
Port: 8102
Features:
- Spaced repetition flashcards
- Audio pronunciation
- Context-based learning
- Progress tracking
- Themed vocabulary sets
"""

import os
import json
import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from pathlib import Path
import base64
import io

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx

try:
    from gtts import gTTS
except ImportError:
    os.system("pip install gtts")
    from gtts import gTTS

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Vietnamese Vocabulary Builder")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Vocabulary sets organized by theme
VOCABULARY_SETS = {
    "greetings": {
        "title": "Greetings & Basic Phrases",
        "level": "beginner",
        "words": [
            {"vietnamese": "Xin chào", "english": "Hello", "pronunciation": "sin chow", "example": "Xin chào, bạn khỏe không?"},
            {"vietnamese": "Tạm biệt", "english": "Goodbye", "pronunciation": "tam bee-et", "example": "Tạm biệt, hẹn gặp lại!"},
            {"vietnamese": "Cảm ơn", "english": "Thank you", "pronunciation": "gam un", "example": "Cảm ơn bạn rất nhiều!"},
            {"vietnamese": "Xin lỗi", "english": "Sorry", "pronunciation": "sin loy", "example": "Xin lỗi, tôi không biết."},
            {"vietnamese": "Vâng", "english": "Yes", "pronunciation": "vung", "example": "Vâng, tôi hiểu."},
            {"vietnamese": "Không", "english": "No", "pronunciation": "khome", "example": "Không, cảm ơn."}
        ]
    },
    "food": {
        "title": "Food & Drink",
        "level": "beginner",
        "words": [
            {"vietnamese": "Cơm", "english": "Rice", "pronunciation": "germ", "example": "Tôi ăn cơm."},
            {"vietnamese": "Phở", "english": "Pho noodle soup", "pronunciation": "fuh", "example": "Phở bò rất ngon."},
            {"vietnamese": "Nước", "english": "Water", "pronunciation": "nerk", "example": "Tôi muốn uống nước."},
            {"vietnamese": "Cà phê", "english": "Coffee", "pronunciation": "ca feh", "example": "Một ly cà phê đen."},
            {"vietnamese": "Bánh mì", "english": "Bread/Sandwich", "pronunciation": "bang me", "example": "Bánh mì Việt Nam rất ngon."},
            {"vietnamese": "Trà", "english": "Tea", "pronunciation": "cha", "example": "Tôi thích uống trà xanh."}
        ]
    },
    "family": {
        "title": "Family Members",
        "level": "beginner",
        "words": [
            {"vietnamese": "Gia đình", "english": "Family", "pronunciation": "za ding", "example": "Gia đình tôi có năm người."},
            {"vietnamese": "Bố/Cha", "english": "Father", "pronunciation": "bo/cha", "example": "Bố tôi là bác sĩ."},
            {"vietnamese": "Mẹ", "english": "Mother", "pronunciation": "me", "example": "Mẹ tôi nấu ăn ngon."},
            {"vietnamese": "Anh/Em trai", "english": "Brother", "pronunciation": "ang/em chai", "example": "Em trai tôi học lớp 10."},
            {"vietnamese": "Chị/Em gái", "english": "Sister", "pronunciation": "chee/em gai", "example": "Chị gái tôi làm ở Hà Nội."},
            {"vietnamese": "Con", "english": "Child", "pronunciation": "gon", "example": "Tôi có hai con."}
        ]
    },
    "numbers": {
        "title": "Numbers",
        "level": "beginner",
        "words": [
            {"vietnamese": "Một", "english": "One", "pronunciation": "moat", "example": "Một cái bàn"},
            {"vietnamese": "Hai", "english": "Two", "pronunciation": "hai", "example": "Hai người bạn"},
            {"vietnamese": "Ba", "english": "Three", "pronunciation": "ba", "example": "Ba cuốn sách"},
            {"vietnamese": "Bốn", "english": "Four", "pronunciation": "bone", "example": "Bốn cái ghế"},
            {"vietnamese": "Năm", "english": "Five", "pronunciation": "nam", "example": "Năm ngày"},
            {"vietnamese": "Mười", "english": "Ten", "pronunciation": "moo-ee", "example": "Mười người"}
        ]
    },
    "colors": {
        "title": "Colors",
        "level": "beginner",
        "words": [
            {"vietnamese": "Màu đỏ", "english": "Red", "pronunciation": "mow doe", "example": "Quả táo màu đỏ"},
            {"vietnamese": "Màu xanh", "english": "Blue/Green", "pronunciation": "mow sang", "example": "Bầu trời màu xanh"},
            {"vietnamese": "Màu vàng", "english": "Yellow", "pronunciation": "mow vang", "example": "Hoa màu vàng"},
            {"vietnamese": "Màu trắng", "english": "White", "pronunciation": "mow chang", "example": "Áo màu trắng"},
            {"vietnamese": "Màu đen", "english": "Black", "pronunciation": "mow den", "example": "Mèo màu đen"},
            {"vietnamese": "Màu hồng", "english": "Pink", "pronunciation": "mow hong", "example": "Hoa hồng màu hồng"}
        ]
    },
    "time": {
        "title": "Time & Days",
        "level": "beginner",
        "words": [
            {"vietnamese": "Hôm nay", "english": "Today", "pronunciation": "home nai", "example": "Hôm nay là thứ hai."},
            {"vietnamese": "Ngày mai", "english": "Tomorrow", "pronunciation": "ngai mai", "example": "Ngày mai tôi đi làm."},
            {"vietnamese": "Hôm qua", "english": "Yesterday", "pronunciation": "home gwa", "example": "Hôm qua tôi ở nhà."},
            {"vietnamese": "Tuần", "english": "Week", "pronunciation": "two-an", "example": "Một tuần có bảy ngày."},
            {"vietnamese": "Tháng", "english": "Month", "pronunciation": "tang", "example": "Tháng này rất bận."},
            {"vietnamese": "Năm", "english": "Year", "pronunciation": "nam", "example": "Năm nay tôi 25 tuổi."}
        ]
    }
}

# Spaced repetition intervals (in days)
SRS_INTERVALS = {
    0: 0,      # New card
    1: 1,      # First review: 1 day
    2: 3,      # Second review: 3 days
    3: 7,      # Third review: 1 week
    4: 14,     # Fourth review: 2 weeks
    5: 30,     # Fifth review: 1 month
    6: 90      # Sixth+ review: 3 months
}

class FlashcardRequest(BaseModel):
    set_id: str
    user_id: Optional[str] = "default"

class ReviewRequest(BaseModel):
    word_id: str
    set_id: str
    user_id: str
    correct: bool

class UserProgress(BaseModel):
    user_id: str
    set_id: str

# In-memory storage (in production, use database)
user_progress = {}

def get_next_review_date(level: int) -> str:
    """Calculate next review date based on SRS level"""
    days = SRS_INTERVALS.get(level, 90)
    next_date = datetime.now() + timedelta(days=days)
    return next_date.isoformat()

async def generate_audio(text: str) -> str:
    """Generate Vietnamese audio for a word"""
    try:
        tts = gTTS(text=text, lang='vi', slow=False)
        audio_buffer = io.BytesIO()
        tts.write_to_fp(audio_buffer)
        audio_buffer.seek(0)
        audio_base64 = base64.b64encode(audio_buffer.read()).decode()
        return audio_base64
    except Exception as e:
        logger.error(f"Error generating audio: {e}")
        return ""

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "vocabulary-builder",
        "features": {
            "flashcards": True,
            "spaced_repetition": True,
            "audio": True,
            "vocabulary_sets": len(VOCABULARY_SETS),
            "total_words": sum(len(vs["words"]) for vs in VOCABULARY_SETS.values())
        },
        "version": "1.0.0"
    }

@app.get("/api/vocabulary-sets")
async def get_vocabulary_sets():
    """Get all vocabulary sets"""
    sets_summary = {}
    for set_id, data in VOCABULARY_SETS.items():
        sets_summary[set_id] = {
            "title": data["title"],
            "level": data["level"],
            "word_count": len(data["words"])
        }
    
    return {
        "sets": sets_summary,
        "total_sets": len(VOCABULARY_SETS)
    }

@app.get("/api/vocabulary-sets/{set_id}")
async def get_vocabulary_set(set_id: str):
    """Get specific vocabulary set"""
    if set_id not in VOCABULARY_SETS:
        raise HTTPException(status_code=404, detail="Vocabulary set not found")
    
    return VOCABULARY_SETS[set_id]

@app.get("/api/vocabulary-sets/{set_id}/word/{word_index}/audio")
async def get_word_audio(set_id: str, word_index: int):
    """Get audio for a specific word"""
    if set_id not in VOCABULARY_SETS:
        raise HTTPException(status_code=404, detail="Set not found")
    
    words = VOCABULARY_SETS[set_id]["words"]
    if word_index >= len(words):
        raise HTTPException(status_code=404, detail="Word not found")
    
    word = words[word_index]
    audio = await generate_audio(word["vietnamese"])
    
    return {
        "word": word["vietnamese"],
        "audio": audio,
        "format": "mp3"
    }

@app.post("/api/flashcards")
async def get_flashcards(request: FlashcardRequest):
    """Get flashcards for review (spaced repetition)"""
    if request.set_id not in VOCABULARY_SETS:
        raise HTTPException(status_code=404, detail="Set not found")
    
    user_key = f"{request.user_id}_{request.set_id}"
    
    # Initialize user progress if not exists
    if user_key not in user_progress:
        user_progress[user_key] = {
            word["vietnamese"]: {"level": 0, "last_review": None, "next_review": datetime.now().isoformat()}
            for word in VOCABULARY_SETS[request.set_id]["words"]
        }
    
    # Get due cards
    now = datetime.now()
    due_cards = []
    
    for word in VOCABULARY_SETS[request.set_id]["words"]:
        word_key = word["vietnamese"]
        progress = user_progress[user_key].get(word_key, {"level": 0, "next_review": now.isoformat()})
        
        next_review = datetime.fromisoformat(progress["next_review"])
        if next_review <= now:
            due_cards.append({
                **word,
                "progress": progress
            })
    
    return {
        "set_id": request.set_id,
        "due_cards": due_cards[:10],  # Limit to 10 cards per session
        "total_due": len(due_cards)
    }

@app.post("/api/review")
async def submit_review(request: ReviewRequest):
    """Submit flashcard review result"""
    user_key = f"{request.user_id}_{request.set_id}"
    
    if user_key not in user_progress:
        raise HTTPException(status_code=404, detail="No progress found")
    
    if request.word_id not in user_progress[user_key]:
        raise HTTPException(status_code=404, detail="Word not found in progress")
    
    # Update progress
    current_level = user_progress[user_key][request.word_id]["level"]
    
    if request.correct:
        new_level = min(current_level + 1, 6)  # Max level 6
    else:
        new_level = max(current_level - 1, 0)  # Reset if incorrect
    
    user_progress[user_key][request.word_id] = {
        "level": new_level,
        "last_review": datetime.now().isoformat(),
        "next_review": get_next_review_date(new_level)
    }
    
    return {
        "word": request.word_id,
        "old_level": current_level,
        "new_level": new_level,
        "next_review": user_progress[user_key][request.word_id]["next_review"]
    }

@app.get("/api/progress/{user_id}/{set_id}")
async def get_progress(user_id: str, set_id: str):
    """Get user progress for a vocabulary set"""
    user_key = f"{user_id}_{set_id}"
    
    if user_key not in user_progress:
        return {"message": "No progress yet", "words": {}}
    
    return {
        "user_id": user_id,
        "set_id": set_id,
        "progress": user_progress[user_key]
    }

@app.websocket("/ws/vocabulary")
async def websocket_vocabulary(websocket: WebSocket):
    """WebSocket for real-time vocabulary practice"""
    await websocket.accept()
    logger.info("Vocabulary WebSocket connected")
    
    try:
        while True:
            message = await websocket.receive_json()
            
            if message.get("type") == "get_word_audio":
                set_id = message.get("set_id")
                word_index = message.get("word_index", 0)
                
                if set_id in VOCABULARY_SETS:
                    words = VOCABULARY_SETS[set_id]["words"]
                    if word_index < len(words):
                        word = words[word_index]
                        audio = await generate_audio(word["vietnamese"])
                        
                        await websocket.send_json({
                            "type": "audio",
                            "word": word["vietnamese"],
                            "audio": audio
                        })
    
    except WebSocketDisconnect:
        logger.info("Vocabulary WebSocket disconnected")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        await websocket.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8102, log_level="info")
