#!/usr/bin/env python3
"""
Multimedia Service - Vietnamese Course Edition
Handles visual assets, audio playback, microphone recording, and practice validation
FastAPI service running on port 5105
"""

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse, FileResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
import uvicorn
import os
import json
import uuid
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any
import asyncio

app = FastAPI(
    title="Vietnamese Course Multimedia Service",
    description="Handles visuals, audio, microphone, and practice for Vietnamese Moodle course"
)

# Configuration
MULTIMEDIA_DIR = "/home/simon/Learning-Management-System-Academy/data/multimedia"
MICROPHONE_RECORDINGS_DIR = f"{MULTIMEDIA_DIR}/microphone_recordings"
VISUAL_ASSETS_DIR = f"{MULTIMEDIA_DIR}/visuals"
AUDIO_FILES_DIR = f"{MULTIMEDIA_DIR}/audio"
PRACTICE_RESPONSES_DIR = f"{MULTIMEDIA_DIR}/practice_responses"

# Create directories
for directory in [MULTIMEDIA_DIR, MICROPHONE_RECORDINGS_DIR, VISUAL_ASSETS_DIR, AUDIO_FILES_DIR, PRACTICE_RESPONSES_DIR]:
    os.makedirs(directory, exist_ok=True)


class VisualAssetGenerator:
    """Generate and manage visual assets"""
    
    @staticmethod
    def create_svg_concept_diagram(title: str, concepts: List[str]) -> str:
        """Create SVG concept diagram"""
        svg_id = str(uuid.uuid4())[:8]
        
        # Simple SVG with concepts
        svg = f"""<svg width="800" height="400" xmlns="http://www.w3.org/2000/svg">
            <defs>
                <style>
                    .title {{ font-size: 24px; font-weight: bold; fill: #1a73e8; }}
                    .concept {{ font-size: 16px; fill: #ffffff; }}
                    .box {{ fill: #34a853; stroke: #1a73e8; stroke-width: 2; }}
                </style>
            </defs>
            <rect width="800" height="400" fill="#f0f4f8"/>
            <text x="400" y="40" text-anchor="middle" class="title">{title}</text>
            
            <!-- Concept boxes -->"""
        
        box_width = 150
        start_x = 50
        y = 100
        
        for i, concept in enumerate(concepts[:5]):  # Max 5 concepts
            x = start_x + (i * (box_width + 30))
            svg += f"""
            <rect class="box" x="{x}" y="{y}" width="{box_width}" height="80" rx="5"/>
            <text class="concept" x="{x + box_width//2}" y="{y + 45}" text-anchor="middle">{concept[:15]}</text>
            """
            
            if i < len(concepts) - 1:
                svg += f'<line x1="{x + box_width}" y1="{y + 40}" x2="{x + box_width + 20}" y2="{y + 40}" stroke="#1a73e8" stroke-width="2"/>'
        
        svg += """
        </svg>"""
        
        return svg


class AudioService:
    """Manage audio files and streaming"""
    
    @staticmethod
    def get_available_audio_files(language: str = "vietnamese") -> List[Dict[str, Any]]:
        """Get list of available audio files"""
        # This would integrate with the indexed Vietnamese audio resources
        return [
            {
                "id": "audio_001",
                "filename": "greeting_basic.mp3",
                "title": "Basic Greetings",
                "duration_seconds": 45,
                "language": language,
                "level": "beginner"
            }
        ]
    
    @staticmethod
    def generate_tts_audio(text: str, language: str = "vietnamese", voice: str = "female") -> Dict[str, Any]:
        """Generate Text-to-Speech audio (placeholder for integration)"""
        audio_id = str(uuid.uuid4())[:8]
        
        # In production, this would call a TTS service
        # For now, return specification for how this would be created
        return {
            "audio_id": audio_id,
            "text": text,
            "language": language,
            "voice": voice,
            "status": "queued",
            "service": "text_to_speech",
            "estimated_duration_seconds": len(text.split()) * 0.5  # Rough estimate
        }


class MicrophoneService:
    """Handle microphone recording and analysis"""
    
    @staticmethod
    async def save_recording(file: UploadFile, page_id: int, student_id: str, activity_id: str) -> Dict[str, Any]:
        """Save microphone recording"""
        recording_id = str(uuid.uuid4())[:8]
        
        # Save file
        filename = f"{page_id}_{student_id}_{activity_id}_{recording_id}.wav"
        filepath = os.path.join(MICROPHONE_RECORDINGS_DIR, filename)
        
        contents = await file.read()
        with open(filepath, 'wb') as f:
            f.write(contents)
        
        return {
            "recording_id": recording_id,
            "filename": filename,
            "filepath": filepath,
            "page_id": page_id,
            "student_id": student_id,
            "activity_id": activity_id,
            "timestamp": datetime.now().isoformat(),
            "file_size_bytes": len(contents),
            "status": "saved"
        }
    
    @staticmethod
    def analyze_recording(recording_id: str) -> Dict[str, Any]:
        """Analyze recorded audio (transcription, pronunciation, etc.)"""
        # This would integrate with speech recognition
        return {
            "recording_id": recording_id,
            "analysis": {
                "transcription": "Xin chào",
                "confidence": 0.92,
                "pronunciation_score": 0.85,
                "suggestions": ["Good pronunciation!", "Try emphasizing the tone more"]
            },
            "status": "analyzed"
        }


class PracticeExerciseValidator:
    """Validate and score practice exercises"""
    
    @staticmethod
    def validate_multiple_choice(user_answer: str, correct_answer: str) -> Dict[str, Any]:
        """Validate multiple choice answer"""
        is_correct = user_answer.lower().strip() == correct_answer.lower().strip()
        return {
            "is_correct": is_correct,
            "score": 100 if is_correct else 0,
            "feedback": "Correct!" if is_correct else "Not quite right. Try again!"
        }
    
    @staticmethod
    def validate_fill_blank(user_answer: str, expected_answers: List[str]) -> Dict[str, Any]:
        """Validate fill-in-blank with variations"""
        normalized_user = user_answer.lower().strip()
        normalized_expected = [e.lower().strip() for e in expected_answers]
        
        is_correct = any(exp in normalized_user or normalized_user in exp for exp in normalized_expected)
        
        return {
            "is_correct": is_correct,
            "score": 100 if is_correct else 0,
            "feedback": "Correct answer!" if is_correct else f"Expected: {expected_answers[0]}"
        }
    
    @staticmethod
    def validate_free_response(response: str, min_length: int = 5) -> Dict[str, Any]:
        """Validate free response (basic validation)"""
        word_count = len(response.split())
        
        return {
            "word_count": word_count,
            "meets_minimum": word_count >= min_length,
            "score": min(100, (word_count / 20) * 100),  # Score based on length
            "status": "submitted_for_ai_review",
            "feedback": "Response submitted for teacher review"
        }


# ============ FastAPI Routes ============

@app.get("/health")
async def health():
    """Health check"""
    return {
        "status": "ok",
        "service": "multimedia",
        "timestamp": datetime.now().isoformat()
    }


@app.get("/visuals/concept/{title}")
async def get_concept_diagram(title: str):
    """Get concept diagram SVG"""
    concepts = title.split("_")
    svg_content = VisualAssetGenerator.create_svg_concept_diagram(title, concepts)
    
    return {
        "visual_id": str(uuid.uuid4())[:8],
        "type": "concept_diagram",
        "title": title,
        "format": "svg",
        "svg_content": svg_content,
        "generated_at": datetime.now().isoformat()
    }


@app.get("/audio/available")
async def get_available_audio():
    """Get available audio files"""
    return {
        "available_audio": AudioService.get_available_audio_files(),
        "total": len(AudioService.get_available_audio_files())
    }


@app.post("/audio/tts")
async def generate_tts(text: str, language: str = "vietnamese", voice: str = "female"):
    """Generate text-to-speech"""
    tts_spec = AudioService.generate_tts_audio(text, language, voice)
    
    return {
        "status": "queued",
        "tts_specification": tts_spec,
        "message": "Audio generation queued. Will be available shortly."
    }


@app.post("/microphone/record")
async def save_microphone_recording(
    file: UploadFile = File(...),
    page_id: int = None,
    student_id: str = None,
    activity_id: str = None
):
    """Save microphone recording"""
    if not all([page_id, student_id, activity_id]):
        raise HTTPException(status_code=400, detail="Missing required parameters")
    
    recording_data = await MicrophoneService.save_recording(file, page_id, student_id, activity_id)
    
    return {
        "status": "saved",
        "recording": recording_data
    }


@app.post("/microphone/analyze/{recording_id}")
async def analyze_microphone_recording(recording_id: str):
    """Analyze microphone recording"""
    analysis = MicrophoneService.analyze_recording(recording_id)
    
    return analysis


@app.post("/practice/validate")
async def validate_practice_response(
    exercise_type: str,
    user_response: str,
    expected_answer: str = None,
    accepted_variations: List[str] = None
):
    """Validate practice exercise response"""
    
    if exercise_type == "multiple_choice":
        result = PracticeExerciseValidator.validate_multiple_choice(user_response, expected_answer)
    elif exercise_type == "fill_blank":
        variations = accepted_variations or [expected_answer]
        result = PracticeExerciseValidator.validate_fill_blank(user_response, variations)
    elif exercise_type == "free_response":
        result = PracticeExerciseValidator.validate_free_response(user_response)
    else:
        raise HTTPException(status_code=400, detail=f"Unknown exercise type: {exercise_type}")
    
    return {
        "status": "validated",
        "result": result,
        "timestamp": datetime.now().isoformat()
    }


@app.get("/stats")
async def get_stats():
    """Get multimedia service statistics"""
    recording_count = len(os.listdir(MICROPHONE_RECORDINGS_DIR))
    
    return {
        "service": "multimedia",
        "microphone_recordings": recording_count,
        "visual_assets_generated": len(os.listdir(VISUAL_ASSETS_DIR)),
        "directories": {
            "microphone_recordings": MICROPHONE_RECORDINGS_DIR,
            "visual_assets": VISUAL_ASSETS_DIR,
            "audio_files": AUDIO_FILES_DIR,
            "practice_responses": PRACTICE_RESPONSES_DIR
        }
    }


def main():
    """Run multimedia service"""
    print("="*70)
    print("VIETNAMESE COURSE MULTIMEDIA SERVICE")
    print("="*70)
    print(f"Starting on port 5105...")
    print(f"Directories:")
    print(f"  • Microphone: {MICROPHONE_RECORDINGS_DIR}")
    print(f"  • Visuals: {VISUAL_ASSETS_DIR}")
    print(f"  • Audio: {AUDIO_FILES_DIR}")
    print("="*70)
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=5105,
        log_level="info"
    )


if __name__ == "__main__":
    main()
