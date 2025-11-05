#!/usr/bin/env python3
"""
Vietnamese Tutor Agent - EPIC AI-powered Vietnamese language learning assistant

Features:
- Pronunciation feedback using ASR transcription comparison
- Grammar checking with detailed explanations
- Vocabulary practice with contextual examples
- Interactive dialogue generation for conversation practice
- Flashcard generation with tones and pronunciation guides
- Cultural context and usage tips
- Translation with natural language explanations
- Quiz generation for different proficiency levels

Integrates with:
- Local Ollama models (qwen2.5-coder:7b, deepseek-coder:6.7b, phi3.5:3.8b)
- ASR service at /course-improvements/vietnamese-course/asr_service/
- Moodle course (id=10)
"""
from fastapi import FastAPI, Depends, Header, HTTPException, Request, File, UploadFile
from fastapi.responses import StreamingResponse, JSONResponse
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import uvicorn
import os
import requests
import json
import asyncio
from datetime import datetime
import difflib
import tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
CONTEXT_DIR = os.path.join(ROOT, 'workspace', 'agents', 'context', 'vietnamese-tutor')
os.makedirs(CONTEXT_DIR, exist_ok=True)

# Ollama configuration - LOCAL GPU for speed
OLLAMA_BASE_URL = "http://127.0.0.1:11434"
PRIMARY_MODEL = "qwen2.5-coder:7b"  # Best for structured responses
FAST_MODEL = "phi3.5:3.8b"  # Ultra-fast for quick feedback
GRAMMAR_MODEL = "deepseek-coder:6.7b-instruct"  # Good for detailed analysis

# ASR service configuration
ASR_SERVICE_URL = "http://localhost:8000"  # Local ASR service

app = FastAPI(
    title="Vietnamese Tutor Agent",
    description="EPIC AI-powered Vietnamese language learning assistant",
    version="1.0.0"
)


# ===== Request/Response Models =====

class PronunciationRequest(BaseModel):
    """Request for pronunciation feedback."""
    target_text: str = Field(..., description="Expected Vietnamese text")
    audio_file_path: Optional[str] = Field(None, description="Path to audio file")
    model_size: str = Field("small", description="Whisper model size")


class GrammarCheckRequest(BaseModel):
    """Request for grammar checking."""
    text: str = Field(..., description="Vietnamese text to check")
    level: str = Field("intermediate", description="Student level: beginner, intermediate, advanced")


class VocabularyRequest(BaseModel):
    """Request for vocabulary practice."""
    words: List[str] = Field(..., description="Vietnamese words to practice")
    include_examples: bool = Field(True, description="Include example sentences")
    include_tones: bool = Field(True, description="Include tone explanations")


class DialogueRequest(BaseModel):
    """Request for dialogue generation."""
    topic: str = Field(..., description="Dialogue topic (e.g., 'at the market', 'introducing yourself')")
    level: str = Field("intermediate", description="Difficulty level")
    num_exchanges: int = Field(5, description="Number of conversation exchanges")


class TranslationRequest(BaseModel):
    """Request for translation with explanation."""
    text: str = Field(..., description="Text to translate")
    source_lang: str = Field("en", description="Source language (en or vi)")
    target_lang: str = Field("vi", description="Target language (vi or en)")
    include_explanation: bool = Field(True, description="Include grammar/usage explanation")


class QuizRequest(BaseModel):
    """Request for quiz generation."""
    topic: str = Field(..., description="Quiz topic")
    level: str = Field("intermediate", description="Difficulty level")
    num_questions: int = Field(10, description="Number of questions")
    question_types: List[str] = Field(["multiple_choice", "fill_blank"], description="Question types")


class FlashcardRequest(BaseModel):
    """Request for flashcard generation."""
    vocabulary_list: List[str] = Field(..., description="List of Vietnamese words/phrases")
    include_audio_prompts: bool = Field(True, description="Include pronunciation guides")


# ===== Utility Functions =====

def get_expected_token():
    """Read token from env or workspace file."""
    token = os.environ.get('NEURO_AGENT_TOKEN')
    if token:
        return token
    token_file = os.path.join(ROOT, 'workspace', 'agents', '.token')
    try:
        with open(token_file, 'r', encoding='utf-8') as f:
            return f.read().strip()
    except Exception:
        return None


def require_token(authorization: str = Header(None)):
    """FastAPI dependency that validates Authorization: Bearer <token>."""
    expected = get_expected_token()
    if not expected:
        # No token configured; allow local access (developer mode)
        return True
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != 'bearer' or parts[1] != expected:
        raise HTTPException(status_code=403, detail="Invalid token")
    return True


def call_ollama(model: str, prompt: str, temperature: float = 0.3, max_tokens: int = 2000, system: str = None) -> Dict[str, Any]:
    """Call Ollama API to generate text."""
    try:
        payload = {
            "model": model,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": temperature,
                "num_predict": max_tokens
            }
        }
        
        if system:
            payload["system"] = system
        
        response = requests.post(
            f"{OLLAMA_BASE_URL}/api/generate",
            json=payload,
            timeout=180  # 3 minutes for complex responses
        )
        
        if response.status_code == 200:
            data = response.json()
            return {
                "success": True,
                "response": data.get("response", ""),
                "model": model
            }
        else:
            return {
                "success": False,
                "error": f"Ollama API error: {response.status_code}",
                "details": response.text
            }
    except Exception as e:
        return {
            "success": False,
            "error": f"Connection error: {str(e)}"
        }


def call_asr_service(audio_path: str, model_size: str = "small") -> Dict[str, Any]:
    """Call ASR service to transcribe audio."""
    try:
        with open(audio_path, 'rb') as f:
            files = {'file': (os.path.basename(audio_path), f, 'audio/wav')}
            data = {'model_size': model_size}
            
            response = requests.post(
                f"{ASR_SERVICE_URL}/transcribe",
                files=files,
                data=data,
                timeout=60
            )
        
        if response.status_code == 200:
            return response.json()
        else:
            return {
                "error": f"ASR service error: {response.status_code}",
                "details": response.text
            }
    except Exception as e:
        return {"error": f"ASR connection error: {str(e)}"}


def compare_pronunciation(target: str, transcribed: str) -> Dict[str, Any]:
    """Compare target text with transcribed text for pronunciation feedback."""
    # Normalize both texts
    target_norm = target.lower().strip()
    transcribed_norm = transcribed.lower().strip()
    
    # Calculate similarity using SequenceMatcher
    similarity = difflib.SequenceMatcher(None, target_norm, transcribed_norm).ratio()
    
    # Get detailed differences
    differ = difflib.Differ()
    diff = list(differ.compare(target_norm.split(), transcribed_norm.split()))
    
    # Identify mistakes
    mistakes = []
    for item in diff:
        if item.startswith('- '):
            mistakes.append({"type": "missing", "word": item[2:]})
        elif item.startswith('+ '):
            mistakes.append({"type": "extra", "word": item[2:]})
    
    # Generate feedback
    if similarity >= 0.95:
        feedback = "Excellent pronunciation! Very close to native."
        score = "A+"
    elif similarity >= 0.85:
        feedback = "Good pronunciation! Minor improvements needed."
        score = "A"
    elif similarity >= 0.70:
        feedback = "Fair pronunciation. Keep practicing the tones."
        score = "B"
    elif similarity >= 0.50:
        feedback = "Needs improvement. Focus on tone accuracy."
        score = "C"
    else:
        feedback = "Significant pronunciation issues. Practice with native speakers."
        score = "D"
    
    return {
        "similarity": round(similarity * 100, 2),
        "score": score,
        "feedback": feedback,
        "mistakes": mistakes,
        "target": target,
        "transcribed": transcribed
    }


# ===== API Endpoints =====

@app.get("/health")
def health():
    """Health check endpoint."""
    # Check Ollama connection
    ollama_status = "disconnected"
    try:
        response = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=5)
        if response.status_code == 200:
            ollama_status = "connected"
    except:
        pass
    
    # Check ASR service
    asr_status = "disconnected"
    try:
        response = requests.get(f"{ASR_SERVICE_URL}/health", timeout=5)
        if response.status_code == 200:
            asr_status = "connected"
    except:
        pass
    
    return {
        "status": "ok" if ollama_status == "connected" else "degraded",
        "agent": "vietnamese-tutor",
        "ollama_status": ollama_status,
        "asr_status": asr_status,
        "models": {
            "primary": PRIMARY_MODEL,
            "fast": FAST_MODEL,
            "grammar": GRAMMAR_MODEL
        }
    }


@app.post("/pronunciation/check")
async def check_pronunciation(
    target_text: str,
    file: UploadFile = File(...),
    model_size: str = "small",
    _auth: bool = Depends(require_token)
):
    """
    Check pronunciation by comparing target text with audio transcription.
    
    Returns detailed feedback on pronunciation accuracy, tone issues, and specific mistakes.
    """
    # Save uploaded audio to temp file
    suffix = os.path.splitext(file.filename)[1] or ".wav"
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        content = await file.read()
        tmp.write(content)
        tmp_path = tmp.name
    
    try:
        # Transcribe audio using ASR service
        asr_result = call_asr_service(tmp_path, model_size)
        
        if "error" in asr_result:
            return JSONResponse(
                status_code=500,
                content={"success": False, "error": asr_result["error"]}
            )
        
        transcribed_text = asr_result.get("text", "")
        
        # Compare with target text
        comparison = compare_pronunciation(target_text, transcribed_text)
        
        # Get AI feedback with specific pronunciation tips
        if comparison["similarity"] < 95:
            prompt = f"""You are a Vietnamese language teacher. A student tried to say:
Target: "{target_text}"
They said: "{transcribed_text}"

Similarity score: {comparison['similarity']}%

Provide specific feedback on:
1. Which Vietnamese tones they got wrong
2. Which consonants/vowels need practice
3. Specific tips to improve (e.g., "The word 'cảm' uses falling tone (grave accent), make your voice go down")
4. Cultural context or common mistakes for English speakers

Keep it encouraging and actionable. Max 200 words."""

            ai_result = call_ollama(GRAMMAR_MODEL, prompt, temperature=0.4, max_tokens=500)
            if ai_result.get("success"):
                comparison["ai_feedback"] = ai_result["response"]
        
        # Save to context
        log_file = os.path.join(CONTEXT_DIR, f"pronunciation_check_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(comparison, f, ensure_ascii=False, indent=2)
        
        return {"success": True, **comparison}
    
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"success": False, "error": str(e)}
        )
    finally:
        try:
            os.unlink(tmp_path)
        except:
            pass


@app.post("/grammar/check")
def check_grammar(req: GrammarCheckRequest, _auth: bool = Depends(require_token)):
    """
    Check Vietnamese grammar and provide detailed explanations.
    
    Returns corrections, explanations, and learning tips appropriate for student level.
    """
    system_prompt = f"""You are an expert Vietnamese language teacher specializing in grammar.
Student level: {req.level}
Provide grammar feedback that is clear, detailed, and appropriate for their level."""

    prompt = f"""Analyze this Vietnamese text for grammar issues:

Text: "{req.text}"

Provide:
1. **Overall Assessment**: Is the grammar correct? (Yes/No with brief reason)
2. **Specific Issues** (if any):
   - Quote the incorrect part
   - Explain why it's wrong
   - Provide the correct version
   - Explain the grammar rule
3. **Level-appropriate Tips**: 1-2 tips to improve their Vietnamese grammar
4. **Positive Feedback**: What they did well

Format your response clearly with these sections. Be encouraging!"""

    result = call_ollama(GRAMMAR_MODEL, prompt, temperature=0.3, max_tokens=1500, system=system_prompt)
    
    if result.get("success"):
        # Save to context
        log_file = os.path.join(CONTEXT_DIR, f"grammar_check_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump({
                "text": req.text,
                "level": req.level,
                "feedback": result["response"]
            }, f, ensure_ascii=False, indent=2)
    
    return result


@app.post("/vocabulary/practice")
def vocabulary_practice(req: VocabularyRequest, _auth: bool = Depends(require_token)):
    """
    Generate vocabulary practice materials with examples, tones, and usage tips.
    """
    words_list = "\n".join([f"- {word}" for word in req.words])
    
    prompt = f"""Create comprehensive vocabulary practice materials for these Vietnamese words:

{words_list}

For each word, provide:
1. **Word**: The Vietnamese word with proper tone marks
2. **Pronunciation Guide**: How to pronounce it (tone description)
3. **Meaning**: English translation(s)
{("4. **Example Sentence**: A natural Vietnamese sentence using this word with English translation" if req.include_examples else "")}
{("5. **Tone Details**: Explain which tone it uses and how to pronounce it correctly" if req.include_tones else "")}
6. **Usage Tips**: When and how to use this word naturally
7. **Cultural Context**: Any cultural notes or common mistakes

Make it engaging and practical for real conversations!"""

    result = call_ollama(PRIMARY_MODEL, prompt, temperature=0.4, max_tokens=2000)
    
    if result.get("success"):
        # Save to context
        log_file = os.path.join(CONTEXT_DIR, f"vocabulary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump({
                "words": req.words,
                "materials": result["response"]
            }, f, ensure_ascii=False, indent=2)
    
    return result


@app.post("/dialogue/generate")
def generate_dialogue(req: DialogueRequest, _auth: bool = Depends(require_token)):
    """
    Generate realistic Vietnamese dialogues for conversation practice.
    
    Perfect for role-play exercises and pronunciation practice.
    """
    prompt = f"""Create a natural Vietnamese dialogue about: {req.topic}

Requirements:
- Level: {req.level}
- Number of exchanges: {req.num_exchanges}
- Include 2 speakers (A and B)
- Use realistic, everyday Vietnamese
- Include tone marks and proper spelling
- After dialogue, provide:
  1. English translation for each line
  2. 3-5 key vocabulary words with definitions
  3. 2-3 cultural tips related to this topic
  4. Pronunciation notes for difficult words

Format:
**Dialogue:**
A: [Vietnamese]
B: [Vietnamese]
...

**Translations:**
A: [English]
B: [English]
...

**Key Vocabulary:**
- word: definition
...

**Cultural Tips:**
1. ...

**Pronunciation Notes:**
- word: how to pronounce correctly"""

    result = call_ollama(PRIMARY_MODEL, prompt, temperature=0.5, max_tokens=2000)
    
    if result.get("success"):
        # Save to context
        log_file = os.path.join(CONTEXT_DIR, f"dialogue_{req.topic.replace(' ', '_')}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md")
        with open(log_file, 'w', encoding='utf-8') as f:
            f.write(f"# Dialogue: {req.topic}\n\n")
            f.write(f"Level: {req.level}\n\n")
            f.write(result["response"])
    
    return result


@app.post("/translate")
def translate_text(req: TranslationRequest, _auth: bool = Depends(require_token)):
    """
    Translate text with detailed grammar and usage explanations.
    """
    if req.include_explanation:
        prompt = f"""Translate from {req.source_lang} to {req.target_lang} and explain:

Text: "{req.text}"

Provide:
1. **Translation**: Natural {req.target_lang} translation
2. **Literal Translation**: Word-by-word breakdown (if helpful)
3. **Grammar Notes**: Explain key grammar structures used
4. **Usage Context**: When/how to use this phrase naturally
5. **Alternative Versions**: Other ways to say the same thing
6. **Common Mistakes**: What learners often get wrong

Be thorough but clear!"""
    else:
        prompt = f"""Translate this text naturally from {req.source_lang} to {req.target_lang}:

"{req.text}"

Provide only the translation."""
    
    result = call_ollama(PRIMARY_MODEL, prompt, temperature=0.3, max_tokens=1000)
    
    return result


@app.post("/quiz/generate")
def generate_quiz(req: QuizRequest, _auth: bool = Depends(require_token)):
    """
    Generate quiz questions for Vietnamese practice.
    
    Exports in GIFT format ready for Moodle import.
    """
    types_str = ", ".join(req.question_types)
    
    prompt = f"""Create a Vietnamese quiz in GIFT format for Moodle:

Topic: {req.topic}
Level: {req.level}
Number of questions: {req.num_questions}
Question types: {types_str}

Guidelines:
- For multiple choice: Include 1 correct answer and 3 plausible distractors
- For fill-in-blank: Use {{1:SHORTANSWER:=correct answer}} format
- For matching: Use {{1:MATCHING:prompt -> answer}} format
- Include Vietnamese tone marks correctly
- Make questions practical and engaging
- Focus on real-world usage

Format in valid GIFT syntax ready for import to Moodle.
Start each question with:: [Vietnamese Quiz - {req.topic}]"""

    result = call_ollama(PRIMARY_MODEL, prompt, temperature=0.4, max_tokens=2000)
    
    if result.get("success"):
        # Save to context as .gift file
        gift_file = os.path.join(CONTEXT_DIR, f"quiz_{req.topic.replace(' ', '_')}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.gift")
        with open(gift_file, 'w', encoding='utf-8') as f:
            f.write(result["response"])
        
        result["gift_file"] = gift_file
    
    return result


@app.post("/flashcards/generate")
def generate_flashcards(req: FlashcardRequest, _auth: bool = Depends(require_token)):
    """
    Generate Anki-style flashcards for vocabulary practice.
    
    Exports as CSV ready for import to Anki or Moodle.
    """
    words_list = "\n".join([f"- {word}" for word in req.vocabulary_list])
    
    prompt = f"""Create flashcard data for these Vietnamese words:

{words_list}

For each word, create a CSV row with these fields:
Front (Vietnamese), Back (English), Example Sentence (Vietnamese), Example Translation (English), Pronunciation Guide, Tone Type, Usage Tips

Requirements:
- Include proper tone marks
- Use natural example sentences
- Make pronunciation guides detailed (e.g., "rising tone - start mid, rise sharply")
- Include cultural context in usage tips
- Format as CSV with pipes | as separators

Example format:
xin chào|hello|Xin chào! Bạn khỏe không?|Hello! How are you?|"shin chow" - both words use high rising tone|high rising (acute accent)|Standard greeting, formal enough for any situation

Generate CSV data for all words:"""

    result = call_ollama(PRIMARY_MODEL, prompt, temperature=0.3, max_tokens=2000)
    
    if result.get("success"):
        # Save to context as CSV
        csv_file = os.path.join(CONTEXT_DIR, f"flashcards_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv")
        with open(csv_file, 'w', encoding='utf-8') as f:
            f.write("Front|Back|Example|Translation|Pronunciation|Tone|Tips\n")
            f.write(result["response"])
        
        result["csv_file"] = csv_file
    
    return result


@app.get("/resources/lesson-plan")
def get_lesson_plan(_auth: bool = Depends(require_token)):
    """Retrieve the current Vietnamese course lesson plan."""
    lesson_plan_path = os.path.join(ROOT, 'course-improvements', 'vietnamese-course', 'lesson_plan.md')
    try:
        with open(lesson_plan_path, 'r', encoding='utf-8') as f:
            content = f.read()
        return {"success": True, "content": content}
    except Exception as e:
        return {"success": False, "error": str(e)}


@app.post("/study-session/personalized")
def create_personalized_session(
    level: str,
    focus_areas: List[str],
    duration_minutes: int = 30,
    _auth: bool = Depends(require_token)
):
    """
    Create a personalized study session plan with mixed activities.
    
    Perfect for daily practice!
    """
    focus_str = ", ".join(focus_areas)
    
    prompt = f"""Create a personalized {duration_minutes}-minute Vietnamese study session:

Student Level: {level}
Focus Areas: {focus_str}

Create a balanced session with:
1. **Warm-up (5 min)**: Quick vocabulary review or pronunciation drill
2. **Main Activities ({duration_minutes-15} min)**: Mix of {focus_str}
3. **Practice (5 min)**: Interactive exercise
4. **Cool-down (5 min)**: Review and next steps

For each activity, provide:
- Activity name and duration
- Clear instructions
- Specific content (vocabulary, phrases, or exercises)
- Success criteria

Make it engaging and achievable!"""

    result = call_ollama(FAST_MODEL, prompt, temperature=0.5, max_tokens=1500)
    
    if result.get("success"):
        session_file = os.path.join(CONTEXT_DIR, f"study_session_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md")
        with open(session_file, 'w', encoding='utf-8') as f:
            f.write(f"# Personalized Study Session\n\n")
            f.write(f"**Level**: {level}\n")
            f.write(f"**Duration**: {duration_minutes} minutes\n")
            f.write(f"**Focus**: {focus_str}\n\n")
            f.write(result["response"])
        
        result["session_file"] = session_file
    
    return result


# ===== MCP (Model Context Protocol) Support =====

@app.get("/mcp/sse")
async def mcp_sse_endpoint(request: Request):
    """
    MCP Server-Sent Events endpoint for Continue extension.
    Provides Vietnamese tutoring tools.
    """
    async def event_generator():
        yield f"event: connect\ndata: {json.dumps({'type': 'connect', 'agent': 'vietnamese-tutor', 'timestamp': datetime.now().isoformat()})}\n\n"
        
        tools = {
            "jsonrpc": "2.0",
            "method": "tools/list",
            "result": {
                "tools": [
                    {
                        "name": "check_pronunciation",
                        "description": "Check Vietnamese pronunciation accuracy using ASR comparison",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "target_text": {"type": "string", "description": "Expected Vietnamese text"},
                                "audio_file": {"type": "string", "description": "Path to audio file"}
                            },
                            "required": ["target_text", "audio_file"]
                        }
                    },
                    {
                        "name": "check_grammar",
                        "description": "Check Vietnamese grammar with detailed explanations",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "text": {"type": "string", "description": "Vietnamese text to check"},
                                "level": {"type": "string", "description": "Student level (beginner/intermediate/advanced)"}
                            },
                            "required": ["text"]
                        }
                    },
                    {
                        "name": "vocabulary_practice",
                        "description": "Generate vocabulary practice materials with examples and tones",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "words": {"type": "array", "items": {"type": "string"}, "description": "Vietnamese words"},
                                "include_examples": {"type": "boolean", "description": "Include example sentences"},
                                "include_tones": {"type": "boolean", "description": "Include tone explanations"}
                            },
                            "required": ["words"]
                        }
                    },
                    {
                        "name": "generate_dialogue",
                        "description": "Generate realistic Vietnamese dialogues for practice",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "topic": {"type": "string", "description": "Dialogue topic"},
                                "level": {"type": "string", "description": "Difficulty level"},
                                "num_exchanges": {"type": "integer", "description": "Number of exchanges"}
                            },
                            "required": ["topic"]
                        }
                    },
                    {
                        "name": "translate",
                        "description": "Translate with detailed grammar explanations",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "text": {"type": "string", "description": "Text to translate"},
                                "source_lang": {"type": "string", "description": "Source language"},
                                "target_lang": {"type": "string", "description": "Target language"},
                                "include_explanation": {"type": "boolean", "description": "Include explanations"}
                            },
                            "required": ["text"]
                        }
                    },
                    {
                        "name": "generate_quiz",
                        "description": "Generate quiz questions in GIFT format for Moodle",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "topic": {"type": "string", "description": "Quiz topic"},
                                "level": {"type": "string", "description": "Difficulty level"},
                                "num_questions": {"type": "integer", "description": "Number of questions"}
                            },
                            "required": ["topic"]
                        }
                    },
                    {
                        "name": "generate_flashcards",
                        "description": "Generate Anki-style flashcards as CSV",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "vocabulary_list": {"type": "array", "items": {"type": "string"}},
                                "include_audio_prompts": {"type": "boolean"}
                            },
                            "required": ["vocabulary_list"]
                        }
                    },
                    {
                        "name": "personalized_session",
                        "description": "Create personalized study session plan",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "level": {"type": "string"},
                                "focus_areas": {"type": "array", "items": {"type": "string"}},
                                "duration_minutes": {"type": "integer"}
                            },
                            "required": ["level", "focus_areas"]
                        }
                    }
                ]
            }
        }
        
        yield f"event: tools\ndata: {json.dumps(tools)}\n\n"
        
        while True:
            if await request.is_disconnected():
                break
            yield f"event: ping\ndata: {json.dumps({'timestamp': datetime.now().isoformat()})}\n\n"
            await asyncio.sleep(30)
    
    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no"
        }
    )


if __name__ == "__main__":
    print("=" * 70)
    print("EPIC Vietnamese Tutor Agent")
    print("=" * 70)
    print(f"Starting on port 5001")
    print(f"Ollama: {OLLAMA_BASE_URL}")
    print(f"ASR Service: {ASR_SERVICE_URL}")
    print(f"Models: {PRIMARY_MODEL} (primary), {FAST_MODEL} (fast), {GRAMMAR_MODEL} (grammar)")
    print(f"Context saved to: {CONTEXT_DIR}")
    print("=" * 70)
    uvicorn.run(app, host="127.0.0.1", port=5001)
