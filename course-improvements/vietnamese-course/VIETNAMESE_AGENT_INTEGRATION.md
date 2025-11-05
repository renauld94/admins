# Vietnamese Tutor AI Agent - EPIC Integration Guide

## Overview

The **Vietnamese Tutor Agent** is an AI-powered learning assistant that provides:

- 🎤 **Pronunciation Feedback**: ASR-based comparison with detailed tips
- ✍️ **Grammar Checking**: Contextual explanations for all levels
- 📚 **Vocabulary Practice**: Examples, tones, and cultural context
- 💬 **Dialogue Generation**: Realistic conversations for practice
- 🔄 **Translation**: With grammar explanations and usage notes
- 📝 **Quiz Generation**: GIFT format ready for Moodle import
- 🗂️ **Flashcard Creation**: CSV export for Anki or Moodle
- 🎯 **Personalized Sessions**: Custom study plans based on level and goals

## Architecture

```
┌─────────────────────┐
│   Moodle Course     │
│    (Course ID=10)   │
└──────────┬──────────┘
           │
           ├──────────────────────────────────┐
           │                                  │
┌──────────▼──────────┐          ┌───────────▼──────────┐
│  ASR Service        │          │ Vietnamese Tutor     │
│  (Port 8000)        │◄─────────┤ Agent (Port 5001)    │
│  - Whisper model    │          │ - Qwen 7B (primary)  │
│  - Audio transcribe │          │ - Phi 3.5 (fast)     │
└─────────────────────┘          │ - DeepSeek (grammar) │
                                 └──────────┬───────────┘
                                            │
                                 ┌──────────▼───────────┐
                                 │  Ollama (Local GPU)  │
                                 │  127.0.0.1:11434     │
                                 │  - RTX 3000 6GB      │
                                 └──────────────────────┘
```

## Installation

### 1. Install Dependencies

```bash
cd /home/simon/Learning-Management-System-Academy/.continue/agents/agents_continue

# Install Python requirements
pip3 install fastapi uvicorn pydantic requests python-multipart

# Check Ollama is running locally
curl http://127.0.0.1:11434/api/tags
```

### 2. Start ASR Service (if not already running)

```bash
cd /home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course/asr_service

# Start ASR service
docker-compose up -d

# Check status
curl http://localhost:8000/health
```

### 3. Install Systemd Service

```bash
# Copy service file
sudo cp /home/simon/Learning-Management-System-Academy/.continue/systemd/vietnamese-tutor-agent.service \
  /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start
sudo systemctl enable vietnamese-tutor-agent
sudo systemctl start vietnamese-tutor-agent

# Check status
sudo systemctl status vietnamese-tutor-agent
sudo journalctl -u vietnamese-tutor-agent -f
```

### 4. Test Agent

```bash
# Run test script
python3 /home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course/test_vietnamese_agent.py
```

## API Usage Examples

### Pronunciation Check

Check student pronunciation against target text:

```bash
curl -X POST http://localhost:5001/pronunciation/check \
  -F "target_text=Xin chào! Bạn khỏe không?" \
  -F "file=@/path/to/audio.wav" \
  -F "model_size=small"
```

**Response:**
```json
{
  "success": true,
  "similarity": 87.5,
  "score": "A",
  "feedback": "Good pronunciation! Minor improvements needed.",
  "mistakes": [
    {"type": "missing", "word": "chào"},
    {"type": "extra", "word": "chau"}
  ],
  "target": "Xin chào! Bạn khỏe không?",
  "transcribed": "Sin chau! Ban khoe khong?",
  "ai_feedback": "Focus on the 'ch' sound in 'chào' - it should be softer..."
}
```

### Grammar Check

Check Vietnamese text for grammar issues:

```bash
curl -X POST http://localhost:5001/grammar/check \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Tôi đi chợ hôm qua",
    "level": "intermediate"
  }'
```

**Response:**
```json
{
  "success": true,
  "response": "**Overall Assessment**: The grammar is correct! ✓\n\n**What you did well:**\n- Correct use of past tense marker 'hôm qua'\n- Proper word order: Subject-Verb-Object-Time\n- Accurate tone marks on all words\n\n**Level-appropriate Tips:**\n1. To make it more natural, you could add 'đã' before the verb: 'Tôi đã đi chợ hôm qua'\n2. Practice other time expressions: 'hôm nay' (today), 'ngày mai' (tomorrow)"
}
```

### Vocabulary Practice

Generate practice materials for Vietnamese words:

```bash
curl -X POST http://localhost:5001/vocabulary/practice \
  -H "Content-Type: application/json" \
  -d '{
    "words": ["cảm ơn", "xin lỗi", "tạm biệt"],
    "include_examples": true,
    "include_tones": true
  }'
```

### Generate Dialogue

Create realistic conversation for practice:

```bash
curl -X POST http://localhost:5001/dialogue/generate \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "ordering food at a restaurant",
    "level": "beginner",
    "num_exchanges": 5
  }'
```

### Translation with Explanation

Translate with detailed grammar notes:

```bash
curl -X POST http://localhost:5001/translate \
  -H "Content-Type: application/json" \
  -d '{
    "text": "I would like to order pho",
    "source_lang": "en",
    "target_lang": "vi",
    "include_explanation": true
  }'
```

### Generate Quiz (GIFT Format for Moodle)

Create quiz questions ready for Moodle import:

```bash
curl -X POST http://localhost:5001/quiz/generate \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "greetings and introductions",
    "level": "beginner",
    "num_questions": 10,
    "question_types": ["multiple_choice", "fill_blank"]
  }'
```

**Response includes GIFT-formatted quiz:**
```
:: [Vietnamese Quiz - greetings and introductions] What is the Vietnamese word for "hello"?
{
  =xin chào
  ~chào
  ~xin
  ~hello
}

:: [Vietnamese Quiz - greetings and introductions] Fill in the blank: "Tôi tên là ____" (My name is ____)
{1:SHORTANSWER:=John~=Mary~=Alex}
```

### Generate Flashcards

Create Anki-style flashcards:

```bash
curl -X POST http://localhost:5001/flashcards/generate \
  -H "Content-Type: application/json" \
  -d '{
    "vocabulary_list": ["xin chào", "cảm ơn", "tạm biệt"],
    "include_audio_prompts": true
  }'
```

**CSV Output:**
```csv
Front|Back|Example|Translation|Pronunciation|Tone|Tips
xin chào|hello|Xin chào! Bạn khỏe không?|Hello! How are you?|"shin chow" - both words use high rising tone|high rising (acute accent)|Standard greeting, formal enough for any situation
```

### Personalized Study Session

Create custom study plan:

```bash
curl -X POST http://localhost:5001/study-session/personalized \
  -H "Content-Type: application/json" \
  -d '{
    "level": "intermediate",
    "focus_areas": ["pronunciation", "vocabulary", "grammar"],
    "duration_minutes": 30
  }'
```

## Integration with Moodle

### 1. Add Pronunciation Practice Activity

Create a Moodle assignment where students:
1. Record themselves saying Vietnamese phrases
2. Upload audio to the agent via API
3. Receive instant feedback on pronunciation

**JavaScript snippet for Moodle:**
```javascript
// Add to Moodle page HTML
<script>
async function checkPronunciation(audioBlob, targetText) {
  const formData = new FormData();
  formData.append('file', audioBlob, 'recording.wav');
  formData.append('target_text', targetText);
  
  const response = await fetch('http://localhost:5001/pronunciation/check', {
    method: 'POST',
    body: formData
  });
  
  const result = await response.json();
  
  // Display feedback to student
  document.getElementById('feedback').innerHTML = `
    <h3>Score: ${result.score} (${result.similarity}%)</h3>
    <p>${result.feedback}</p>
    <div>${result.ai_feedback}</div>
  `;
}
</script>
```

### 2. Grammar Checker Widget

Add grammar checking to text input fields:

```javascript
async function checkGrammar(text, level) {
  const response = await fetch('http://localhost:5001/grammar/check', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({text, level})
  });
  
  const result = await response.json();
  showGrammarFeedback(result.response);
}
```

### 3. Auto-generate Quizzes

Use the agent to generate quiz banks:

```bash
# Generate 50 questions for Week 1
curl -X POST http://localhost:5001/quiz/generate \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Week 1: Greetings and Basic Phrases",
    "level": "beginner",
    "num_questions": 50,
    "question_types": ["multiple_choice", "fill_blank", "matching"]
  }' > week1_quiz.gift

# Import to Moodle
# Site Administration -> Question bank -> Import -> GIFT format
# Upload week1_quiz.gift
```

### 4. Daily Vocabulary Widget

Add to Moodle course page:

```html
<div id="daily-vocab">
  <h3>Daily Vocabulary Practice</h3>
  <div id="vocab-content">Loading...</div>
</div>

<script>
// Fetch daily vocabulary from agent
fetch('http://localhost:5001/vocabulary/practice', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    words: ['hôm nay', 'ngày mai', 'hôm qua'],
    include_examples: true,
    include_tones: true
  })
})
.then(r => r.json())
.then(data => {
  document.getElementById('vocab-content').innerHTML = data.response;
});
</script>
```

## Performance & Speed

Using **local GPU models** (RTX 3000):

| Model | Task | Expected Time | Quality |
|-------|------|---------------|---------|
| **Phi 3.5** | Quick feedback, simple Q&A | 1-2 min | Good |
| **DeepSeek 6.7B** | Grammar checking, detailed feedback | 3-6 min | Excellent |
| **Qwen 7B** | Dialogue generation, complex tasks | 3-5 min | Excellent |

For **faster responses** (under 15s), consider:
- Using VM models with SSH tunnel for background batch jobs
- Pre-generating common content (dialogues, quizzes) and caching
- Running multiple models in parallel for different tasks

## MCP Integration (Continue Extension)

The agent supports **Model Context Protocol** for VS Code Continue extension:

**SSE Endpoint:** `http://localhost:5001/mcp/sse`

Available tools:
- `check_pronunciation` - Pronunciation feedback
- `check_grammar` - Grammar checking
- `vocabulary_practice` - Generate vocab materials
- `generate_dialogue` - Create conversations
- `translate` - Translate with explanations
- `generate_quiz` - Create GIFT quizzes
- `generate_flashcards` - Create Anki flashcards
- `personalized_session` - Custom study plans

### Add to Continue config:

```json
{
  "mcpServers": {
    "vietnamese-tutor": {
      "command": "http",
      "args": ["http://localhost:5001/mcp/sse"]
    }
  }
}
```

## Troubleshooting

### Agent won't start

```bash
# Check Ollama is running
curl http://127.0.0.1:11434/api/tags

# Check ASR service
curl http://localhost:8000/health

# Check agent logs
sudo journalctl -u vietnamese-tutor-agent -n 100
```

### Slow responses (>5 minutes)

This is normal with CPU fallback. The 6GB GPU can only fit part of each 7B model:

**Solutions:**
1. Use **Phi 3.5** for faster responses (1-2 min)
2. Pre-generate content in background
3. Use VM models overnight for batch processing

### ASR service not transcribing

```bash
# Restart ASR service
cd /home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course/asr_service
docker-compose restart

# Check logs
docker-compose logs -f
```

### Models not found

```bash
# List installed models
ollama list

# Pull missing models
ollama pull qwen2.5-coder:7b
ollama pull deepseek-coder:6.7b-instruct
ollama pull phi3.5:3.8b
```

## Future Enhancements

- [ ] WebSocket support for real-time pronunciation feedback
- [ ] Voice synthesis (TTS) for audio examples
- [ ] Student progress tracking and analytics
- [ ] Gamification (points, badges, leaderboards)
- [ ] Mobile app integration
- [ ] Multi-language support (add Thai, Lao, etc.)
- [ ] Video lesson generation with Vietnamese subtitles
- [ ] Cultural immersion content (Vietnamese culture, etiquette)

## Example Workflows

### Daily Study Routine

```bash
# 1. Generate personalized session
curl -X POST http://localhost:5001/study-session/personalized \
  -H "Content-Type: application/json" \
  -d '{"level": "intermediate", "focus_areas": ["pronunciation", "vocabulary"], "duration_minutes": 30}'

# 2. Practice vocabulary
curl -X POST http://localhost:5001/vocabulary/practice \
  -H "Content-Type: application/json" \
  -d '{"words": ["hôm nay", "buổi sáng", "ăn sáng"], "include_examples": true, "include_tones": true}'

# 3. Check pronunciation (record yourself saying the words)
curl -X POST http://localhost:5001/pronunciation/check \
  -F "target_text=Buổi sáng tôi ăn phở" \
  -F "file=@my_recording.wav"
```

### Teacher Workflow (Batch Content Generation)

```bash
# Generate 10 dialogues for different topics
topics=("at the market" "at a restaurant" "meeting friends" "asking for directions" "shopping for clothes")

for topic in "${topics[@]}"; do
  curl -X POST http://localhost:5001/dialogue/generate \
    -H "Content-Type: application/json" \
    -d "{\"topic\": \"$topic\", \"level\": \"intermediate\", \"num_exchanges\": 6}" \
    > "dialogue_${topic// /_}.json"
done

# Generate quiz bank for entire course
curl -X POST http://localhost:5001/quiz/generate \
  -H "Content-Type: application/json" \
  -d '{"topic": "Complete Vietnamese Course", "level": "all", "num_questions": 100}' \
  > complete_course_quiz.gift
```

## Support

- **Agent Logs**: `sudo journalctl -u vietnamese-tutor-agent -f`
- **Context Files**: `/home/simon/Learning-Management-System-Academy/workspace/agents/context/vietnamese-tutor/`
- **Test Script**: `/home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course/test_vietnamese_agent.py`

---

**Status**: ✅ Ready for deployment
**Last Updated**: 2025-11-05
**Author**: AI Infrastructure Team
