#!/usr/bin/env python3
"""
Vietnamese Grammar Helper Service
Port: 8101
Features:
- Grammar rule explanations
- Sentence structure analysis
- Common mistake detection
- Interactive grammar exercises
- AI-powered corrections with explanations
"""

import os
import json
import asyncio
import logging
from datetime import datetime
from typing import Dict, List, Optional
from pathlib import Path

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Vietnamese Grammar Helper")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Vietnamese Grammar Rules Database
GRAMMAR_RULES = {
    "word_order": {
        "title": "Vietnamese Word Order",
        "description": "Vietnamese follows Subject-Verb-Object (SVO) order",
        "examples": [
            {"vietnamese": "Tôi ăn cơm", "english": "I eat rice", "structure": "S-V-O"},
            {"vietnamese": "Cô ấy đọc sách", "english": "She reads book", "structure": "S-V-O"}
        ],
        "rules": [
            "Subject comes first",
            "Verb follows subject",
            "Object comes last",
            "Adjectives follow nouns (unlike English)"
        ]
    },
    "classifiers": {
        "title": "Classifiers (Từ chỉ loại)",
        "description": "Vietnamese uses classifiers before nouns",
        "examples": [
            {"classifier": "con", "usage": "animals", "example": "một con chó (one dog)"},
            {"classifier": "cái", "usage": "inanimate objects", "example": "một cái bàn (one table)"},
            {"classifier": "người", "usage": "people", "example": "hai người bạn (two friends)"},
            {"classifier": "cuốn", "usage": "books", "example": "ba cuốn sách (three books)"},
            {"classifier": "chiếc", "usage": "vehicles", "example": "một chiếc xe (one car)"}
        ],
        "rules": [
            "Number + Classifier + Noun",
            "Each noun type has specific classifiers",
            "Classifiers are mandatory with numbers"
        ]
    },
    "tenses": {
        "title": "Vietnamese Tenses",
        "description": "Vietnamese uses time markers instead of verb conjugation",
        "examples": [
            {"tense": "past", "marker": "đã", "example": "Tôi đã ăn (I ate/have eaten)"},
            {"tense": "future", "marker": "sẽ", "example": "Tôi sẽ ăn (I will eat)"},
            {"tense": "present", "marker": "đang", "example": "Tôi đang ăn (I am eating)"},
            {"tense": "completed", "marker": "rồi", "example": "Tôi ăn rồi (I already ate)"}
        ],
        "rules": [
            "Verbs don't conjugate",
            "Add time markers before or after verb",
            "Context often indicates tense"
        ]
    },
    "pronouns": {
        "title": "Vietnamese Pronouns",
        "description": "Pronouns vary by relationship and formality",
        "examples": [
            {"pronoun": "tôi", "meaning": "I/me", "usage": "formal or neutral"},
            {"pronoun": "bạn", "meaning": "you", "usage": "friend, peer"},
            {"pronoun": "anh/chị", "meaning": "you (older)", "usage": "respectful"},
            {"pronoun": "em", "meaning": "you (younger)", "usage": "to younger person"},
            {"pronoun": "ông/bà", "meaning": "you (elderly)", "usage": "very respectful"}
        ],
        "rules": [
            "Choose based on age and relationship",
            "Family terms used as pronouns",
            "Formality is very important"
        ]
    },
    "negation": {
        "title": "Negation",
        "description": "Vietnamese uses 'không' and 'chưa' for negation",
        "examples": [
            {"type": "general", "word": "không", "example": "Tôi không ăn (I don't eat)"},
            {"type": "not yet", "word": "chưa", "example": "Tôi chưa ăn (I haven't eaten yet)"}
        ],
        "rules": [
            "'không' = general negation (no/not)",
            "'chưa' = not yet (implies will happen)",
            "Place before the verb"
        ]
    },
    "questions": {
        "title": "Forming Questions",
        "description": "Vietnamese uses question particles",
        "examples": [
            {"type": "yes/no", "particle": "không", "example": "Bạn ăn cơm không? (Do you eat rice?)"},
            {"type": "yes/no polite", "particle": "chưa", "example": "Bạn ăn chưa? (Have you eaten yet?)"},
            {"type": "what", "particle": "gì", "example": "Bạn ăn gì? (What do you eat?)"},
            {"type": "where", "particle": "đâu", "example": "Bạn ở đâu? (Where are you?)"},
            {"type": "when", "particle": "khi nào", "example": "Khi nào bạn đi? (When do you go?)"}
        ],
        "rules": [
            "Yes/No: Statement + không?",
            "WH-questions: Replace answer with question word",
            "Question particles at end of sentence"
        ]
    }
}

# Common mistakes database
COMMON_MISTAKES = [
    {
        "mistake": "Missing classifier",
        "wrong": "Tôi có ba sách",
        "correct": "Tôi có ba cuốn sách",
        "explanation": "Use classifier 'cuốn' for books"
    },
    {
        "mistake": "Wrong word order with adjectives",
        "wrong": "Một đẹp nhà",
        "correct": "Một cái nhà đẹp",
        "explanation": "Adjectives come AFTER nouns in Vietnamese (unlike English)"
    },
    {
        "mistake": "Incorrect pronoun",
        "wrong": "Tôi yêu tôi",
        "correct": "Tôi yêu bạn/anh/chị/em",
        "explanation": "Use appropriate pronoun based on relationship, not 'tôi' for 'you'"
    },
    {
        "mistake": "Missing time marker",
        "wrong": "Tôi ăn ngày mai",
        "correct": "Tôi sẽ ăn ngày mai",
        "explanation": "Add 'sẽ' for future tense"
    },
    {
        "mistake": "Using 'không' instead of 'chưa'",
        "wrong": "Tôi không ăn (when meaning 'not yet')",
        "correct": "Tôi chưa ăn",
        "explanation": "Use 'chưa' for 'not yet', 'không' for general negation"
    }
]

# Pydantic models
class GrammarCheckRequest(BaseModel):
    text: str
    check_type: Optional[str] = "all"  # all, structure, classifiers, tones

class GrammarRule(BaseModel):
    rule_id: str
    category: str

class SentenceAnalysis(BaseModel):
    original: str
    structure: List[str]
    issues: List[Dict]
    suggestions: List[str]

# Ollama connection
OLLAMA_URL = "http://localhost:11434"

async def call_ollama(prompt: str, model: str = "gemma2:9b") -> str:
    """Call Ollama API for grammar analysis"""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{OLLAMA_URL}/api/generate",
                json={
                    "model": model,
                    "prompt": prompt,
                    "stream": False
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                return result.get("response", "")
            else:
                logger.error(f"Ollama error: {response.status_code}")
                return ""
    
    except Exception as e:
        logger.error(f"Error calling Ollama: {e}")
        return ""

def analyze_sentence_structure(sentence: str) -> Dict:
    """Analyze Vietnamese sentence structure"""
    words = sentence.strip().split()
    
    analysis = {
        "word_count": len(words),
        "has_subject": False,
        "has_verb": False,
        "has_object": False,
        "time_markers": [],
        "classifiers": [],
        "question_particles": []
    }
    
    # Common Vietnamese verbs (simplified)
    verbs = ["ăn", "uống", "đi", "đọc", "viết", "nói", "nghe", "nhìn", "làm", "học", "dạy"]
    
    # Time markers
    time_markers = ["đã", "sẽ", "đang", "rồi"]
    
    # Classifiers
    classifiers = ["con", "cái", "người", "cuốn", "chiếc", "quả", "bức", "tờ"]
    
    # Question particles
    question_particles = ["không", "chưa", "gì", "đâu", "nào", "sao"]
    
    for word in words:
        if word in verbs:
            analysis["has_verb"] = True
        if word in time_markers:
            analysis["time_markers"].append(word)
        if word in classifiers:
            analysis["classifiers"].append(word)
        if word in question_particles and word == words[-1]:
            analysis["question_particles"].append(word)
    
    # Simple subject detection (first word if pronoun)
    pronouns = ["tôi", "bạn", "anh", "chị", "em", "ông", "bà", "chúng tôi"]
    if words and words[0].lower() in pronouns:
        analysis["has_subject"] = True
    
    return analysis

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    # Check Ollama availability
    ollama_available = False
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{OLLAMA_URL}/api/tags")
            ollama_available = response.status_code == 200
    except:
        pass
    
    return {
        "status": "healthy",
        "service": "grammar-helper",
        "ollama_available": ollama_available,
        "features": {
            "grammar_rules": len(GRAMMAR_RULES),
            "common_mistakes": len(COMMON_MISTAKES),
            "ai_analysis": ollama_available
        },
        "version": "1.0.0"
    }

@app.get("/api/grammar-rules")
async def get_grammar_rules():
    """Get all Vietnamese grammar rules"""
    return {
        "rules": GRAMMAR_RULES,
        "total": len(GRAMMAR_RULES)
    }

@app.get("/api/grammar-rules/{rule_id}")
async def get_grammar_rule(rule_id: str):
    """Get specific grammar rule"""
    if rule_id not in GRAMMAR_RULES:
        raise HTTPException(status_code=404, detail="Rule not found")
    
    return GRAMMAR_RULES[rule_id]

@app.get("/api/common-mistakes")
async def get_common_mistakes():
    """Get common Vietnamese grammar mistakes"""
    return {
        "mistakes": COMMON_MISTAKES,
        "total": len(COMMON_MISTAKES)
    }

@app.post("/api/check-grammar")
async def check_grammar(request: GrammarCheckRequest):
    """Check Vietnamese grammar in text"""
    text = request.text.strip()
    
    if not text:
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    
    # Analyze structure
    structure = analyze_sentence_structure(text)
    
    # Detect issues
    issues = []
    suggestions = []
    
    # Check for missing classifiers
    numbers = ["một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín", "mười"]
    words = text.split()
    
    for i, word in enumerate(words):
        if word in numbers and i + 1 < len(words):
            next_word = words[i + 1]
            if next_word not in ["con", "cái", "người", "cuốn", "chiếc"]:
                issues.append({
                    "type": "missing_classifier",
                    "position": i,
                    "message": f"Number '{word}' might need a classifier before the noun"
                })
                suggestions.append(f"Consider adding a classifier after '{word}'")
    
    # Use AI for deeper analysis
    ai_feedback = ""
    prompt = f"""Analyze this Vietnamese sentence for grammar errors:
    
Sentence: {text}

Check for:
1. Word order (SVO structure)
2. Proper use of classifiers
3. Correct time markers
4. Appropriate pronouns
5. Negation usage

Provide specific corrections and explanations."""

    ai_feedback = await call_ollama(prompt)
    
    if ai_feedback:
        suggestions.append(f"AI Analysis: {ai_feedback[:500]}")
    
    return {
        "original": text,
        "structure_analysis": structure,
        "issues": issues,
        "suggestions": suggestions,
        "ai_feedback": ai_feedback if ai_feedback else "AI analysis unavailable"
    }

@app.post("/api/correct-sentence")
async def correct_sentence(request: GrammarCheckRequest):
    """Correct Vietnamese sentence with AI"""
    text = request.text.strip()
    
    prompt = f"""You are a Vietnamese language teacher. Correct this sentence and explain the corrections:

Student's sentence: {text}

Provide:
1. Corrected sentence
2. Explanation of each correction
3. Grammar rule applied

Format: 
Corrected: [corrected sentence]
Explanation: [detailed explanation]"""

    correction = await call_ollama(prompt)
    
    return {
        "original": text,
        "correction": correction,
        "timestamp": datetime.now().isoformat()
    }

@app.websocket("/ws/grammar")
async def websocket_grammar(websocket: WebSocket):
    """WebSocket for real-time grammar checking"""
    await websocket.accept()
    logger.info("Grammar helper WebSocket connected")
    
    try:
        while True:
            message = await websocket.receive_json()
            
            if message.get("type") == "check":
                text = message.get("text", "")
                structure = analyze_sentence_structure(text)
                
                await websocket.send_json({
                    "type": "analysis",
                    "structure": structure,
                    "word_count": len(text.split())
                })
            
            elif message.get("type") == "get_rule":
                rule_id = message.get("rule_id")
                if rule_id in GRAMMAR_RULES:
                    await websocket.send_json({
                        "type": "rule",
                        "data": GRAMMAR_RULES[rule_id]
                    })
    
    except WebSocketDisconnect:
        logger.info("Grammar helper WebSocket disconnected")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        await websocket.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8101, log_level="info")
