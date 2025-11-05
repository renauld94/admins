# 🎓 EPIC Vietnamese Tutor Agent - Quick Start

## What Is This?

An AI-powered Vietnamese learning assistant that makes your Vietnamese course **EPIC**! 🇻🇳✨

## Features at a Glance

| Feature | What It Does | Example Use |
|---------|-------------|-------------|
| 🎤 **Pronunciation Feedback** | Compare student audio with target text using ASR | Student says "Xin chào", gets score + tips |
| ✍️ **Grammar Checking** | Analyze Vietnamese text for errors | Check "Tôi đi chợ hôm qua" → detailed feedback |
| 📚 **Vocabulary Practice** | Generate study materials with tones/examples | Input: ["cảm ơn"] → full practice sheet |
| 💬 **Dialogue Generation** | Create realistic conversations | Topic: "at restaurant" → 5-turn dialogue |
| 🔄 **Smart Translation** | Translate with grammar explanations | "I want coffee" → Vietnamese + grammar notes |
| 📝 **Quiz Generation** | Create GIFT format quizzes for Moodle | Generate 10 questions on greetings |
| 🗂️ **Flashcard Creation** | Export Anki-ready CSV flashcards | Words → CSV with tones + examples |
| 🎯 **Personalized Sessions** | Custom study plans by level/goals | 30-min session for pronunciation practice |

## Quick Deploy

```bash
# 1. Deploy the agent (one command!)
cd /home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course
./deploy_vietnamese_agent.sh

# 2. Test it
python3 test_vietnamese_agent.py

# 3. Check status
sudo systemctl status vietnamese-tutor-agent
```

## Usage Examples

### Check Pronunciation
```bash
curl -X POST http://localhost:5001/pronunciation/check \
  -F "target_text=Xin chào! Bạn khỏe không?" \
  -F "file=@student_audio.wav"
```

**Response:**
- Similarity score (0-100%)
- Letter grade (A+ to D)
- Specific mistakes identified
- AI tips for improvement

### Check Grammar
```bash
curl -X POST http://localhost:5001/grammar/check \
  -H "Content-Type: application/json" \
  -d '{"text": "Tôi đi chợ hôm qua", "level": "intermediate"}'
```

### Generate Quiz
```bash
curl -X POST http://localhost:5001/quiz/generate \
  -H "Content-Type: application/json" \
  -d '{"topic": "greetings", "level": "beginner", "num_questions": 10}'
```

Output: GIFT format ready for Moodle import!

## Integration with Moodle

### Option 1: Direct API Calls (JavaScript)
```javascript
// Add to Moodle activity page
async function checkPronunciation(audioBlob, targetText) {
  const formData = new FormData();
  formData.append('file', audioBlob);
  formData.append('target_text', targetText);
  
  const response = await fetch('http://localhost:5001/pronunciation/check', {
    method: 'POST',
    body: formData
  });
  
  return await response.json();
}
```

### Option 2: MCP with Continue Extension
The agent automatically integrates with VS Code Continue for:
- Quick Vietnamese translations while coding course content
- Grammar checking lesson materials
- Generating quiz questions on the fly
- Creating flashcards from vocabulary lists

## Performance

Using **local GPU models** (RTX 3000 6GB):

| Model | Speed | Best For |
|-------|-------|----------|
| Phi 3.5 (3.8B) | 1-2 min | Quick feedback, simple Q&A |
| DeepSeek 6.7B | 3-6 min | Grammar checks, detailed analysis |
| Qwen 7B | 3-5 min | Dialogues, complex tasks |

## Architecture

```
Student → Moodle → Vietnamese Agent → Ollama (Local GPU)
                          ↓
                     ASR Service (Whisper)
```

## Monitoring

```bash
# View logs
sudo journalctl -u vietnamese-tutor-agent -f

# Check health
curl http://localhost:5001/health

# View API docs
xdg-open http://localhost:5001/docs
```

## Files Structure

```
course-improvements/vietnamese-course/
├── VIETNAMESE_AGENT_INTEGRATION.md  # Full documentation
├── deploy_vietnamese_agent.sh       # One-click deployment
├── test_vietnamese_agent.py         # Test suite
├── asr_service/                     # Whisper ASR service
│   ├── docker-compose.yml
│   └── fastapi_app.py
└── generated/                       # AI-generated content

.continue/agents/agents_continue/
└── vietnamese_tutor_agent.py        # Main agent (750+ lines)

.continue/systemd/
└── vietnamese-tutor-agent.service   # Systemd service
```

## API Endpoints

- `GET /health` - Health check
- `POST /pronunciation/check` - Check pronunciation
- `POST /grammar/check` - Check grammar
- `POST /vocabulary/practice` - Generate vocab materials
- `POST /dialogue/generate` - Create dialogues
- `POST /translate` - Translate with explanations
- `POST /quiz/generate` - Generate GIFT quizzes
- `POST /flashcards/generate` - Create CSV flashcards
- `POST /study-session/personalized` - Custom study plans
- `GET /mcp/sse` - MCP Server-Sent Events endpoint
- `POST /mcp/call` - MCP JSON-RPC tool calls

## Troubleshooting

### Agent won't start
```bash
# Check dependencies
curl http://127.0.0.1:11434/api/tags  # Ollama running?
ollama list                           # Models installed?

# View logs
sudo journalctl -u vietnamese-tutor-agent -n 50
```

### Slow responses
This is expected (GPU can only fit part of 7B models). Solutions:
1. Use Phi 3.5 for faster responses (1-2 min)
2. Pre-generate content in background
3. Cache common responses

### ASR not working
```bash
# Restart ASR service
cd course-improvements/vietnamese-course/asr_service
docker-compose restart
```

## Next Steps

1. ✅ Deploy agent: `./deploy_vietnamese_agent.sh`
2. ✅ Run tests: `python3 test_vietnamese_agent.py`
3. ✅ Add pronunciation practice to Moodle course
4. ✅ Generate quiz bank for Week 1
5. ✅ Create vocabulary flashcards
6. ✅ Set up daily grammar checker widget

## Full Documentation

See [`VIETNAMESE_AGENT_INTEGRATION.md`](./VIETNAMESE_AGENT_INTEGRATION.md) for:
- Complete API reference
- Moodle integration examples
- Performance tuning
- Advanced workflows
- Troubleshooting guide

---

**Status**: ✅ Ready for production  
**Port**: 5001  
**Service**: `vietnamese-tutor-agent.service`  
**Commit**: `68ffd07be`  

**Make Vietnamese class EPIC!** 🚀🇻🇳
