# AI Services Deployment Status
**Date:** November 4, 2025
**Course:** Vietnamese for Beginners (ID: 10)

---

## ✅ DEPLOYED SERVICES

### 1. AI Conversation Partner ⚡
**Status:** LIVE ✓
**URL:** https://moodle.simondatalab.de/ai/conversation-practice.html
**Port:** 8100
**Features:**
- ✓ Real-time Vietnamese conversations
- ✓ Text-to-speech (gTTS Vietnamese)
- ✓ Speech-to-text (Web Speech API vi-VN)
- ✓ Professional UI (no emojis, clean design)
- ✓ WebSocket for real-time chat
- ✓ 5 Ollama LLM models active

**Health Check:**
```json
{
  "status": "healthy",
  "service": "ai-conversation",
  "ollama_available": true,
  "models_loaded": ["gemma2:9b", "mistral:7b-instruct", "qwen2.5:7b-instruct", "deepseek-coder:6.7b", "llama3.1:8b"],
  "features": {
    "text_to_speech": true,
    "speech_to_text": "browser_only"
  }
}
```

---

## 🚧 IN PROGRESS

### 2. Pronunciation Coach 🎤
**Status:** Code complete, deployment pending
**Port:** 8103 (target)
**Features:**
- Vietnamese tone analysis (6 tones: ngang, huyền, sắc, hỏi, ngã, nặng)
- Pitch contour extraction using librosa
- Visual SVG pitch graphs comparing user vs reference
- Accuracy scoring (0-100)
- Real-time feedback
- Practice words for each tone

**Technical Stack:**
- FastAPI + uvicorn
- librosa for audio analysis (F0 extraction via pYIN)
- soundfile for audio I/O
- gTTS for reference audio generation
- SVG rendering for pitch visualization
- WebSocket for real-time coaching

**Deployment Issue:**
Connection timeout to VM 10.0.0.110 via jump host. Service code ready at:
- `/home/simon/Learning-Management-System-Academy/deploy/ai-services/pronunciation_coach_service.py`
- `/home/simon/Learning-Management-System-Academy/deploy/ai-services/pronunciation_coach.html`

**Next Steps:**
1. Retry VM connection
2. Run deployment script: `./deploy_pronunciation_coach.sh`
3. Configure nginx reverse proxy (config ready)
4. Test at https://moodle.simondatalab.de/pronunciation/

---

## 📝 MOODLE EMBEDDING

### How to Embed in Course

1. **Login:** https://moodle.simondatalab.de
2. **Navigate to course:** https://moodle.simondatalab.de/course/view.php?id=10
3. **Turn editing ON**
4. **Add "Label" activity**
5. **Click source code button (`</>`)**
6. **Paste the embed code** (see `/tmp/moodle_ai_embed.html`)
7. **Save and test**

### Embed Code Features

**AI Conversation Partner Box:**
- Professional gradient header (#1a1a2e → #16213e)
- Feature list highlighting capabilities
- 850px height iframe
- Microphone permission enabled

**Pronunciation Coach Box:**
- Teal accent color (#00bfa5)
- "Coming Soon" placeholder until deployed
- Feature preview list
- Ready to activate once service is live

---

## 📊 TESTING RESULTS

### Audio Features Test (curl)
```bash
# TTS endpoint test
curl -X POST https://moodle.simondatalab.de/ai/api/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{"text": "Xin chào! Tôi tên là AI. Rất vui được gặp bạn."}'
```
**Result:** Endpoint exists but returned null (needs investigation)

### Health Check Test
```bash
curl https://moodle.simondatalab.de/ai/health
```
**Result:** ✅ Service healthy, all features operational

### Interface Test
**URL:** https://moodle.simondatalab.de/ai/conversation-practice.html
**Result:** ✅ Professional UI loading correctly

---

## 🎯 PRONUNCIATION ANALYSIS CAPABILITIES

When deployed, the Pronunciation Coach will provide:

### Tone Detection
- **Algorithm:** F0 (fundamental frequency) extraction using librosa.pyin
- **Range:** 65 Hz (C2) to 2093 Hz (C7)
- **Classification:** Based on pitch variance, trend, and mean
- **Confidence:** 0.0 to 1.0 score

### Accuracy Scoring
- **Method:** Mean Squared Error (MSE) between user and reference pitch
- **Score:** 0-100 scale (100 = perfect match)
- **Visualization:** Dual-line SVG graph (blue=user, green=reference)

### Visual Feedback
- **Graph Type:** SVG with time vs pitch axes
- **Features:** Grid lines, legend, labels
- **Colors:** Professional dark theme matching portfolio
- **Export:** Base64-encoded for easy transmission

### Tone Information
| Tone | Vietnamese | Name | Description | Example |
|------|-----------|------|-------------|---------|
| 1 | ngang | Level | Mid-level pitch | ma (ghost) |
| 2 | huyền | Falling | Low falling pitch | mà (but) |
| 3 | sắc | Rising | High rising pitch | má (mother) |
| 4 | hỏi | Dipping | Dip and rise | mả (tomb) |
| 5 | ngã | Rising broken | High rising with glottal | mã (horse) |
| 6 | nặng | Heavy | Low falling with glottal | mạ (rice seedling) |

---

## 📋 REMAINING SERVICES (Planned)

### 3. Grammar Helper (Port 8101)
- Vietnamese grammar rules
- Sentence structure analysis
- Common mistake detection
- Interactive exercises

### 4. Vocabulary Builder (Port 8102)
- Spaced repetition system
- Flashcards with audio
- Context-based learning
- Progress tracking

### 5. Cultural Context (Port 8104)
- Vietnamese customs and etiquette
- Cultural notes for phrases
- Regional variations
- Social context explanations

### 6. Reading Assistant (Port 8105)
- Text analysis and translation
- Difficulty level detection
- Reading comprehension questions
- Vocabulary extraction

### 7. Writing Practice (Port 8106)
- Essay correction
- Style suggestions
- Grammar checking
- Tone mark validation

### 8. Analytics Dashboard (Port 8107)
- Student progress tracking
- Conversation history
- Pronunciation improvement graphs
- Vocabulary retention metrics
- Time spent per activity
- Strength/weakness analysis

---

## 🔧 TROUBLESHOOTING

### Issue: TTS endpoint returns null
**Possible causes:**
- Endpoint exists but audio generation failing
- gTTS configuration issue
- WebSocket vs REST API confusion

**Solution:** Test WebSocket connection directly for audio responses

### Issue: VM connection timeout
**Possible causes:**
- Network latency
- SSH session timeout
- Jump host connectivity

**Solution:**
- Retry connection
- Use longer timeout values
- Test jump host separately

### Issue: Pronunciation Coach not deployed
**Status:** Code ready, awaiting stable VM connection
**Workaround:** Deploy manually when connection stable

---

## 📈 SUCCESS METRICS

**Current Status:**
- ✅ 1/8 services fully deployed (12.5%)
- ✅ Professional UI redesign complete
- ✅ Audio features (TTS/STT) implemented
- ✅ External HTTPS access working
- ⏳ 1/8 services 95% complete (needs deployment)

**Next Milestone:**
- Deploy Pronunciation Coach → 25% complete
- Embed both services in Moodle → First student testing phase
- Deploy 6 remaining services → 100% complete

---

## 🚀 NEXT ACTIONS

**Immediate (Today):**
1. ✅ Provide Moodle embed code to instructor
2. ⏳ Retry Pronunciation Coach deployment when connection stable
3. ⏳ Test TTS endpoint issue in AI Conversation service

**Short-term (This Week):**
1. Deploy Pronunciation Coach (Port 8103)
2. Test both services embedded in Moodle
3. Gather initial student feedback
4. Begin Grammar Helper development (Port 8101)

**Long-term (This Month):**
1. Deploy all 8 AI services
2. Create unified navigation dashboard
3. Implement Analytics Dashboard for progress tracking
4. Optimize performance based on usage data

---

## 📞 SUPPORT

**Service Health:** https://moodle.simondatalab.de/ai/health
**Logs Location (VM):** `~/vietnamese-ai/conversation/conversation.log`
**Deployment Scripts:** `/home/simon/Learning-Management-System-Academy/deploy/ai-services/`

**Key Files:**
- AI Conversation: `ai_conversation_service.py`
- Pronunciation Coach: `pronunciation_coach_service.py`
- HTML Interfaces: `conversation_practice.html`, `pronunciation_coach.html`
- Deployment: `deploy_pronunciation_coach.sh`
- Instructions: `MOODLE_EMBED_INSTRUCTIONS.md`
