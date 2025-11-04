#!/usr/bin/env python3
"""
Vietnamese Pronunciation Coach Service
Port: 8103
Features:
- Vietnamese tone accuracy analysis (6 tones)
- Pronunciation similarity scoring
- Visual pitch/tone graphs
- Real-time feedback with waveform visualization
- Comparison with native speaker audio
"""

import os
import json
import asyncio
import logging
from datetime import datetime
from typing import Dict, List, Optional
from pathlib import Path
import base64
import io
import tempfile

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, UploadFile, File
from fastapi.responses import JSONResponse, Response
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
from pydantic import BaseModel

# Audio processing
try:
    import librosa
    import soundfile as sf
except ImportError:
    print("Installing librosa and soundfile...")
    os.system("pip install librosa soundfile")
    import librosa
    import soundfile as sf

# Text-to-speech
try:
    from gtts import gTTS
except ImportError:
    print("Installing gTTS...")
    os.system("pip install gtts")
    from gtts import gTTS

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Vietnamese Pronunciation Coach")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Vietnamese tone data
VIETNAMESE_TONES = {
    "ngang": {"name": "Level", "number": 1, "description": "Mid-level pitch", "example": "ma (ghost)"},
    "huyền": {"name": "Falling", "number": 2, "description": "Low falling pitch", "example": "mà (but)"},
    "sắc": {"name": "Rising", "number": 3, "description": "High rising pitch", "example": "má (mother)"},
    "hỏi": {"name": "Dipping", "number": 4, "description": "Dip and rise", "example": "mả (tomb)"},
    "ngã": {"name": "Rising broken", "number": 5, "description": "High rising with glottal", "example": "mã (horse)"},
    "nặng": {"name": "Heavy", "number": 6, "description": "Low falling with glottal", "example": "mạ (rice seedling)"}
}

# Practice words by tone
TONE_PRACTICE_WORDS = {
    "ngang": ["ba", "ma", "la", "ca", "nga"],
    "huyền": ["bà", "mà", "là", "cà", "ngà"],
    "sắc": ["bá", "má", "lá", "cá", "ngá"],
    "hỏi": ["bả", "mả", "lả", "cả", "ngả"],
    "ngã": ["bã", "mã", "lã", "cã", "ngã"],
    "nặng": ["bạ", "mạ", "lạ", "cạ", "ngạ"]
}

# Pydantic models
class PronunciationRequest(BaseModel):
    word: str
    tone: Optional[str] = None

class ToneAnalysis(BaseModel):
    detected_tone: str
    confidence: float
    pitch_contour: List[float]
    accuracy_score: float
    feedback: str

class WordAnalysis(BaseModel):
    word: str
    target_tone: str
    detected_tone: str
    accuracy: float
    pitch_graph: str  # base64 SVG
    feedback: List[str]

def extract_pitch_contour(audio_data: bytes, sr: int = 22050) -> List[float]:
    """Extract F0 (fundamental frequency) pitch contour from audio"""
    try:
        # Convert bytes to audio array
        audio_array, sample_rate = librosa.load(io.BytesIO(audio_data), sr=sr)
        
        # Extract pitch using pYIN algorithm
        f0, voiced_flag, voiced_probs = librosa.pyin(
            audio_array,
            fmin=librosa.note_to_hz('C2'),  # ~65 Hz
            fmax=librosa.note_to_hz('C7')   # ~2093 Hz
        )
        
        # Remove NaN values and normalize
        pitch_contour = f0[~np.isnan(f0)]
        if len(pitch_contour) > 0:
            # Normalize to 0-100 range
            min_pitch = np.min(pitch_contour)
            max_pitch = np.max(pitch_contour)
            normalized = ((pitch_contour - min_pitch) / (max_pitch - min_pitch) * 100).tolist()
            return normalized
        return []
    except Exception as e:
        logger.error(f"Error extracting pitch: {e}")
        return []

def detect_vietnamese_tone(pitch_contour: List[float]) -> tuple[str, float]:
    """
    Detect Vietnamese tone from pitch contour
    Returns: (tone_name, confidence)
    """
    if len(pitch_contour) < 3:
        return "unknown", 0.0
    
    # Calculate pitch statistics
    pitch_array = np.array(pitch_contour)
    mean_pitch = np.mean(pitch_array)
    pitch_trend = np.polyfit(range(len(pitch_array)), pitch_array, 1)[0]  # Linear slope
    pitch_variance = np.var(pitch_array)
    
    # Simple tone classification based on pitch patterns
    # This is a simplified model - real implementation would use ML
    
    if pitch_variance < 50:  # Relatively flat
        if mean_pitch > 60:
            return "ngang", 0.75  # High level
        else:
            return "huyền", 0.70  # Low falling
    
    elif pitch_trend > 2:  # Rising
        if pitch_variance > 100:
            return "ngã", 0.65  # Rising broken
        else:
            return "sắc", 0.80  # Rising
    
    elif pitch_trend < -2:  # Falling
        if pitch_variance > 150:
            return "nặng", 0.70  # Heavy
        else:
            return "huyền", 0.75  # Falling
    
    else:  # Complex contour
        return "hỏi", 0.60  # Dipping
    
    return "unknown", 0.0

def generate_pitch_graph_svg(
    user_pitch: List[float],
    reference_pitch: List[float],
    detected_tone: str,
    target_tone: str
) -> str:
    """Generate SVG graph comparing user pitch with reference"""
    
    width, height = 600, 300
    padding = 40
    graph_width = width - 2 * padding
    graph_height = height - 2 * padding
    
    # Normalize data to graph space
    def normalize_points(data):
        if not data:
            return []
        max_len = max(len(user_pitch), len(reference_pitch))
        x_scale = graph_width / max(1, max_len - 1)
        y_scale = graph_height / 100  # Pitch is 0-100
        
        points = []
        for i, y in enumerate(data):
            x = padding + (i * x_scale)
            y_coord = height - padding - (y * y_scale)
            points.append(f"{x:.1f},{y_coord:.1f}")
        return " ".join(points)
    
    user_points = normalize_points(user_pitch)
    ref_points = normalize_points(reference_pitch)
    
    # Build SVG
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
    <!-- Background -->
    <rect width="{width}" height="{height}" fill="#1a1a2e"/>
    
    <!-- Grid lines -->
    <line x1="{padding}" y1="{padding}" x2="{padding}" y2="{height-padding}" stroke="#333" stroke-width="2"/>
    <line x1="{padding}" y1="{height-padding}" x2="{width-padding}" y2="{height-padding}" stroke="#333" stroke-width="2"/>
    
    <!-- Grid horizontals -->
    <line x1="{padding}" y1="{padding + graph_height/4}" x2="{width-padding}" y2="{padding + graph_height/4}" stroke="#2a2a3e" stroke-width="1" stroke-dasharray="5,5"/>
    <line x1="{padding}" y1="{padding + graph_height/2}" x2="{width-padding}" y2="{padding + graph_height/2}" stroke="#2a2a3e" stroke-width="1" stroke-dasharray="5,5"/>
    <line x1="{padding}" y1="{padding + 3*graph_height/4}" x2="{width-padding}" y2="{padding + 3*graph_height/4}" stroke="#2a2a3e" stroke-width="1" stroke-dasharray="5,5"/>
    
    <!-- Reference pitch (green) -->
    <polyline points="{ref_points}" fill="none" stroke="#00bfa5" stroke-width="3" opacity="0.7"/>
    
    <!-- User pitch (blue) -->
    <polyline points="{user_points}" fill="none" stroke="#0066cc" stroke-width="3"/>
    
    <!-- Labels -->
    <text x="{width/2}" y="25" fill="#fff" font-size="16" text-anchor="middle" font-weight="bold">
        Pitch Contour: {detected_tone.upper()} (target: {target_tone.upper()})
    </text>
    
    <text x="15" y="{height/2}" fill="#999" font-size="12" text-anchor="middle" transform="rotate(-90, 15, {height/2})">
        Pitch (Hz)
    </text>
    
    <text x="{width/2}" y="{height-10}" fill="#999" font-size="12" text-anchor="middle">
        Time
    </text>
    
    <!-- Legend -->
    <line x1="{width-150}" y1="50" x2="{width-130}" y2="50" stroke="#0066cc" stroke-width="3"/>
    <text x="{width-125}" y="55" fill="#fff" font-size="12">Your pitch</text>
    
    <line x1="{width-150}" y1="70" x2="{width-130}" y2="70" stroke="#00bfa5" stroke-width="3"/>
    <text x="{width-125}" y="75" fill="#fff" font-size="12">Reference</text>
</svg>'''
    
    return base64.b64encode(svg.encode()).decode()

def calculate_accuracy(user_pitch: List[float], reference_pitch: List[float]) -> float:
    """Calculate pronunciation accuracy score (0-100)"""
    if not user_pitch or not reference_pitch:
        return 0.0
    
    # Resample to same length
    target_len = min(len(user_pitch), len(reference_pitch))
    user_resized = np.interp(
        np.linspace(0, len(user_pitch)-1, target_len),
        range(len(user_pitch)),
        user_pitch
    )
    ref_resized = np.interp(
        np.linspace(0, len(reference_pitch)-1, target_len),
        range(len(reference_pitch)),
        reference_pitch
    )
    
    # Calculate mean squared error
    mse = np.mean((user_resized - ref_resized) ** 2)
    
    # Convert to accuracy score (0-100)
    # Lower MSE = higher accuracy
    accuracy = max(0, 100 - (mse / 10))
    
    return round(accuracy, 1)

def generate_feedback(accuracy: float, detected_tone: str, target_tone: str) -> List[str]:
    """Generate personalized feedback based on analysis"""
    feedback = []
    
    if detected_tone == target_tone:
        if accuracy >= 90:
            feedback.append("✓ Excellent! Your tone is very accurate.")
        elif accuracy >= 75:
            feedback.append("✓ Good job! Your tone is correct.")
        elif accuracy >= 60:
            feedback.append("~ Correct tone, but try to match the pitch contour more closely.")
        else:
            feedback.append("~ Right tone detected, but needs more practice.")
    else:
        feedback.append(f"✗ Detected {detected_tone}, but target is {target_tone}.")
        
        tone_info = VIETNAMESE_TONES.get(target_tone, {})
        feedback.append(f"Tip: {tone_info.get('description', 'Practice the tone pattern')}")
        feedback.append(f"Example: {tone_info.get('example', '')}")
    
    # Pitch-specific feedback
    if accuracy < 50:
        feedback.append("Focus on matching the pitch movement, not just the sound.")
    elif accuracy < 75:
        feedback.append("You're close! Try exaggerating the tone slightly.")
    
    return feedback

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "pronunciation-coach",
        "features": {
            "tone_analysis": True,
            "pitch_graphs": True,
            "accuracy_scoring": True,
            "supported_tones": list(VIETNAMESE_TONES.keys())
        },
        "version": "1.0.0"
    }

@app.get("/api/tones")
async def get_tones():
    """Get information about Vietnamese tones"""
    return {
        "tones": VIETNAMESE_TONES,
        "practice_words": TONE_PRACTICE_WORDS
    }

@app.post("/api/generate-reference")
async def generate_reference_audio(request: PronunciationRequest):
    """Generate reference audio for a word"""
    try:
        word = request.word
        
        # Generate TTS audio
        tts = gTTS(text=word, lang='vi', slow=False)
        
        # Save to bytes
        audio_buffer = io.BytesIO()
        tts.write_to_fp(audio_buffer)
        audio_buffer.seek(0)
        
        # Extract pitch contour
        pitch_contour = extract_pitch_contour(audio_buffer.read())
        
        # Generate new audio for response
        audio_buffer = io.BytesIO()
        tts.write_to_fp(audio_buffer)
        audio_buffer.seek(0)
        audio_base64 = base64.b64encode(audio_buffer.read()).decode()
        
        return {
            "word": word,
            "audio": audio_base64,
            "pitch_contour": pitch_contour,
            "format": "mp3"
        }
    
    except Exception as e:
        logger.error(f"Error generating reference: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/analyze-pronunciation")
async def analyze_pronunciation(
    audio: UploadFile = File(...),
    word: str = None,
    target_tone: str = None
):
    """
    Analyze uploaded audio for pronunciation accuracy
    Returns tone detection, accuracy score, and visual pitch graph
    """
    try:
        # Read uploaded audio
        audio_data = await audio.read()
        
        # Extract user's pitch contour
        user_pitch = extract_pitch_contour(audio_data)
        
        if not user_pitch:
            raise HTTPException(status_code=400, detail="Could not extract pitch from audio")
        
        # Detect tone
        detected_tone, confidence = detect_vietnamese_tone(user_pitch)
        
        # Generate reference audio if word provided
        reference_pitch = []
        if word:
            tts = gTTS(text=word, lang='vi', slow=False)
            ref_buffer = io.BytesIO()
            tts.write_to_fp(ref_buffer)
            ref_buffer.seek(0)
            reference_pitch = extract_pitch_contour(ref_buffer.read())
        
        # Calculate accuracy
        accuracy = calculate_accuracy(user_pitch, reference_pitch) if reference_pitch else 0
        
        # Use target tone or detected tone
        final_target = target_tone or detected_tone
        
        # Generate pitch graph
        pitch_graph = generate_pitch_graph_svg(
            user_pitch,
            reference_pitch,
            detected_tone,
            final_target
        )
        
        # Generate feedback
        feedback = generate_feedback(accuracy, detected_tone, final_target)
        
        return {
            "word": word or "unknown",
            "target_tone": final_target,
            "detected_tone": detected_tone,
            "confidence": confidence,
            "accuracy": accuracy,
            "pitch_graph_svg": pitch_graph,
            "user_pitch": user_pitch[:50],  # First 50 points for preview
            "reference_pitch": reference_pitch[:50] if reference_pitch else [],
            "feedback": feedback
        }
    
    except Exception as e:
        logger.error(f"Error analyzing pronunciation: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/ws/pronunciation")
async def websocket_pronunciation(websocket: WebSocket):
    """WebSocket for real-time pronunciation coaching"""
    await websocket.accept()
    logger.info("Pronunciation coaching WebSocket connected")
    
    try:
        while True:
            # Receive audio chunk or message
            message = await websocket.receive_json()
            
            if message.get("type") == "audio":
                # Process base64 audio
                audio_b64 = message.get("data")
                audio_bytes = base64.b64decode(audio_b64)
                
                # Extract pitch
                pitch = extract_pitch_contour(audio_bytes)
                
                # Detect tone
                tone, confidence = detect_vietnamese_tone(pitch)
                
                # Send real-time feedback
                await websocket.send_json({
                    "type": "analysis",
                    "detected_tone": tone,
                    "confidence": confidence,
                    "pitch_preview": pitch[:20]  # First 20 points
                })
            
            elif message.get("type") == "get_practice_word":
                tone = message.get("tone", "ngang")
                words = TONE_PRACTICE_WORDS.get(tone, [])
                
                await websocket.send_json({
                    "type": "practice_word",
                    "tone": tone,
                    "words": words
                })
    
    except WebSocketDisconnect:
        logger.info("Pronunciation coaching WebSocket disconnected")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        await websocket.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8103, log_level="info")
