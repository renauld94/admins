# 🤖 AI-POWERED VIETNAMESE COURSE - COMPLETE INTEGRATION PLAN

**VM**: 10.0.0.110 (AI Services Hub)  
**Deploy Target**: Moodle Vietnamese Course (ID: 10)  
**Access**: `ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110`  
**Vision**: Transform static course into intelligent, adaptive learning system

---

## 🎯 AI SERVICES ARCHITECTURE

### Service Stack on VM 10.0.0.110

```
┌─────────────────────────────────────────────────────────┐
│          VM 10.0.0.110 - AI Services Hub                │
├─────────────────────────────────────────────────────────┤
│  Port 8100: AI Conversation Partner (Ollama + TTS)     │
│  Port 8101: Adaptive Learning Engine (Analytics)       │
│  Port 8102: Intelligent Content Generator              │
│  Port 8103: AI Pronunciation Coach (Whisper + LLM)     │
│  Port 8104: Grammar & Writing Assistant                │
│  Port 8105: Cultural Context Explainer                 │
│  Port 8106: Real-time Translation & Comparison         │
│  Port 8107: Progress Analytics Dashboard API           │
└─────────────────────────────────────────────────────────┘
                         ↓
              Nginx Reverse Proxy
                         ↓
┌─────────────────────────────────────────────────────────┐
│        Moodle Course Integration (iframe/API)           │
│  https://moodle.simondatalab.de/course/view.php?id=10  │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 SERVICE 1: AI CONVERSATION PARTNER

**Port**: 8100  
**Purpose**: Real-time Vietnamese conversation practice with voice

### Technical Stack
- **LLM**: Ollama (llama3.1 or qwen2.5 for multilingual)
- **TTS**: Coqui-TTS with Vietnamese voice model
- **STT**: Existing Whisper service (10.0.0.104:8000)
- **Framework**: FastAPI + WebSockets for real-time

### Features
```javascript
// Real-time conversation interface
class AIConversationPartner {
    constructor() {
        this.ws = new WebSocket('wss://moodle.simondatalab.de/ai/conversation');
        this.audioContext = new AudioContext();
        this.mediaRecorder = null;
        this.conversationHistory = [];
    }
    
    async startConversation(scenario) {
        // Scenarios: Restaurant, Airport, Business Meeting, Shopping
        this.ws.send(JSON.stringify({
            type: 'start_scenario',
            scenario: scenario,
            student_level: this.getUserLevel()
        }));
    }
    
    async sendAudio(audioBlob) {
        // Send student's speech to AI
        const formData = new FormData();
        formData.append('audio', audioBlob);
        
        // Get transcription from Whisper
        const transcription = await this.transcribe(audioBlob);
        
        // Send to AI for response
        const aiResponse = await fetch('/api/ai/respond', {
            method: 'POST',
            body: JSON.stringify({
                transcript: transcription,
                context: this.conversationHistory
            })
        });
        
        const response = await aiResponse.json();
        
        // Play AI voice response
        this.playTTS(response.vietnamese_text);
        
        // Show transcript and translation
        this.displayResponse(response);
        
        // Analyze student's Vietnamese
        this.showFeedback(response.feedback);
    }
    
    showFeedback(feedback) {
        // AI analyzes:
        // - Grammar accuracy
        // - Tone correctness
        // - Vocabulary appropriateness
        // - Cultural context
        // - Suggestions for improvement
    }
}
```

### Conversation Scenarios
1. **Beginner**: 
   - Ordering coffee (Cà phê)
   - Introducing yourself
   - Asking directions
   
2. **Intermediate**:
   - Business introductions
   - Phone conversations
   - Restaurant discussions
   
3. **Advanced**:
   - Negotiations
   - Technical discussions
   - Cultural debates

### AI Prompt Engineering
```python
# conversation_prompts.py

SYSTEM_PROMPT = """You are Lan, a friendly Vietnamese language tutor from Hanoi. 
You're having a conversation with a {level} student learning Vietnamese.

RULES:
1. Respond ONLY in Vietnamese
2. Keep responses at {level} difficulty
3. Naturally correct errors without being pedantic
4. Use cultural context when appropriate
5. Be encouraging and patient
6. Match the conversation scenario: {scenario}
7. Gradually increase difficulty if student does well

FEEDBACK FORMAT:
After each response, provide analysis:
- Grammar: [score 0-100]
- Tone accuracy: [score 0-100]
- Vocabulary: [appropriate/too simple/too complex]
- Improvement tip: [one specific suggestion]
"""

SCENARIOS = {
    'coffee_shop': {
        'context': "You're a barista at a Hanoi coffee shop",
        'vocabulary_focus': ['cà phê', 'sữa đá', 'nóng', 'lạnh', 'bao nhiêu tiền'],
        'cultural_notes': "Vietnamese coffee culture, condensed milk usage"
    },
    'business_meeting': {
        'context': "You're a Vietnamese business partner",
        'vocabulary_focus': ['hợp đồng', 'thương lượng', 'đối tác', 'doanh thu'],
        'cultural_notes': "Business etiquette, hierarchy respect"
    }
}
```

### Backend Implementation
```python
# ai_conversation_service.py
from fastapi import FastAPI, WebSocket, UploadFile
from fastapi.responses import StreamingResponse
import ollama
import asyncio
import json

app = FastAPI()

class ConversationManager:
    def __init__(self):
        self.sessions = {}
        self.ollama_client = ollama.Client()
        
    async def generate_response(self, user_message: str, context: list, scenario: str, level: str):
        """Generate AI response using Ollama"""
        
        # Build conversation context
        system_prompt = SYSTEM_PROMPT.format(level=level, scenario=scenario)
        
        messages = [
            {"role": "system", "content": system_prompt}
        ] + context + [
            {"role": "user", "content": user_message}
        ]
        
        # Generate response with streaming
        response = self.ollama_client.chat(
            model='qwen2.5:7b',  # Great for Vietnamese
            messages=messages,
            stream=True
        )
        
        full_response = ""
        for chunk in response:
            content = chunk['message']['content']
            full_response += content
            yield content
            
        # Analyze student's Vietnamese
        feedback = await self.analyze_student_vietnamese(user_message, level)
        
        yield json.dumps({
            "type": "feedback",
            "feedback": feedback
        })
    
    async def analyze_student_vietnamese(self, text: str, level: str):
        """AI-powered analysis of student's Vietnamese"""
        
        analysis_prompt = f"""Analyze this Vietnamese text from a {level} student:
        "{text}"
        
        Provide:
        1. Grammar score (0-100)
        2. Tone accuracy (0-100) 
        3. Vocabulary appropriateness
        4. One specific improvement tip
        5. Encouragement
        
        Return as JSON."""
        
        response = self.ollama_client.chat(
            model='qwen2.5:7b',
            messages=[{"role": "user", "content": analysis_prompt}]
        )
        
        return json.loads(response['message']['content'])

manager = ConversationManager()

@app.websocket("/ws/conversation")
async def conversation_websocket(websocket: WebSocket):
    await websocket.accept()
    session_id = str(uuid.uuid4())
    
    try:
        while True:
            data = await websocket.receive_json()
            
            if data['type'] == 'start_scenario':
                # Initialize conversation
                scenario = data['scenario']
                level = data['student_level']
                
                # AI introduces scenario
                intro = await manager.generate_scenario_intro(scenario, level)
                await websocket.send_json({
                    "type": "ai_message",
                    "text": intro,
                    "audio_url": await generate_tts(intro)
                })
                
            elif data['type'] == 'student_message':
                # Student's transcribed Vietnamese
                user_message = data['text']
                context = data['context']
                
                # Generate AI response (streaming)
                async for chunk in manager.generate_response(
                    user_message, 
                    context, 
                    data['scenario'],
                    data['level']
                ):
                    await websocket.send_text(chunk)
                    
    except WebSocketDisconnect:
        manager.cleanup_session(session_id)

@app.post("/api/tts")
async def text_to_speech(text: str):
    """Convert Vietnamese text to speech using Coqui TTS"""
    from TTS.api import TTS
    
    tts = TTS(model_name="tts_models/vi/cv/vits", progress_bar=False)
    
    # Generate audio
    audio_path = f"/tmp/{uuid.uuid4()}.wav"
    tts.tts_to_file(text=text, file_path=audio_path)
    
    return StreamingResponse(
        open(audio_path, "rb"),
        media_type="audio/wav"
    )
```

---

## 🧠 SERVICE 2: ADAPTIVE LEARNING ENGINE

**Port**: 8101  
**Purpose**: Personalized learning paths based on student performance

### Features
- **Learning Style Detection**: Visual, auditory, kinesthetic
- **Difficulty Adjustment**: Real-time based on success rates
- **Weak Area Identification**: Focus on struggling concepts
- **Optimal Review Scheduling**: Spaced repetition algorithm
- **Progress Prediction**: ML model predicts mastery timeline

### Analytics Dashboard
```javascript
class AdaptiveLearningDashboard {
    async loadStudentProfile() {
        const profile = await fetch('/api/ai/student-profile').then(r => r.json());
        
        // Display:
        // - Mastery level per topic (0-100%)
        // - Learning velocity (lessons/week)
        // - Predicted completion date
        // - Recommended next lesson
        // - Weak areas needing review
        
        this.renderMasteryMap(profile.mastery);
        this.renderLearningPath(profile.recommended_path);
        this.renderWeakAreas(profile.weak_areas);
    }
    
    renderMasteryMap(mastery) {
        // D3.js tree visualization showing:
        // - Completed topics (green)
        // - In progress (yellow)
        // - Locked topics (gray)
        // - Recommended next (pulsing blue)
    }
}
```

### ML Model
```python
# adaptive_learning_ml.py
import numpy as np
from sklearn.ensemble import GradientBoostingRegressor
import pandas as pd

class AdaptiveLearningModel:
    def __init__(self):
        self.model = GradientBoostingRegressor()
        self.student_data = {}
        
    def analyze_student_performance(self, student_id: int):
        """Analyze and predict student performance"""
        
        # Features
        features = {
            'lessons_completed': 0,
            'avg_quiz_score': 0,
            'pronunciation_accuracy': 0,
            'tone_mastery': 0,
            'vocabulary_retention': 0,
            'study_time_hours': 0,
            'days_since_start': 0,
            'consecutive_study_days': 0,
            'review_frequency': 0
        }
        
        # Load student data from database
        data = self.load_student_data(student_id)
        
        # Calculate current mastery
        mastery_score = self.calculate_mastery(data)
        
        # Predict future performance
        predicted_completion = self.predict_completion_date(data)
        
        # Identify weak areas
        weak_areas = self.identify_weak_areas(data)
        
        # Generate personalized recommendations
        recommendations = self.generate_recommendations(
            mastery_score,
            weak_areas,
            data['learning_style']
        )
        
        return {
            'mastery_score': mastery_score,
            'predicted_completion': predicted_completion,
            'weak_areas': weak_areas,
            'recommendations': recommendations,
            'optimal_next_lesson': self.select_optimal_lesson(data)
        }
    
    def identify_weak_areas(self, data):
        """AI identifies struggling topics"""
        weak_areas = []
        
        for topic, scores in data['topic_scores'].items():
            avg_score = np.mean(scores)
            attempts = len(scores)
            
            if avg_score < 70 and attempts >= 3:
                weak_areas.append({
                    'topic': topic,
                    'avg_score': avg_score,
                    'attempts': attempts,
                    'recommendation': self.generate_topic_help(topic, scores)
                })
                
        return sorted(weak_areas, key=lambda x: x['avg_score'])
    
    def generate_topic_help(self, topic: str, scores: list):
        """AI generates personalized help for struggling topics"""
        
        # Use LLM to generate custom explanation
        prompt = f"""Student is struggling with Vietnamese topic: {topic}
        Their scores: {scores}
        
        Generate:
        1. Simplified explanation
        2. 3 practice exercises (beginner level)
        3. Memory technique/mnemonic
        4. Cultural context to make it memorable
        5. Encouragement message
        """
        
        response = ollama.chat(
            model='qwen2.5:7b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        return response['message']['content']
```

---

## 📝 SERVICE 3: INTELLIGENT CONTENT GENERATOR

**Port**: 8102  
**Purpose**: Auto-generate custom exercises, quizzes, dialogues

### Features
```python
# content_generator.py

class IntelligentContentGenerator:
    def __init__(self):
        self.ollama = ollama.Client()
        
    async def generate_custom_exercises(self, topic: str, difficulty: str, count: int):
        """Generate personalized practice exercises"""
        
        prompt = f"""Generate {count} Vietnamese language exercises for topic: {topic}
        Difficulty: {difficulty}
        
        Include:
        1. Fill-in-the-blank sentences
        2. Translation challenges (English ↔ Vietnamese)
        3. Tone identification
        4. Conversation completion
        5. Cultural context questions
        
        Return as JSON with answers and explanations."""
        
        response = await self.ollama.chat(
            model='qwen2.5:14b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        exercises = json.loads(response['message']['content'])
        return exercises
    
    async def generate_dialogue(self, scenario: str, participants: int, length: int):
        """Generate realistic Vietnamese dialogues"""
        
        prompt = f"""Create a natural Vietnamese dialogue:
        Scenario: {scenario}
        Participants: {participants}
        Exchanges: {length}
        
        Include:
        - Natural Vietnamese expressions
        - Cultural nuances
        - Tone markers
        - English translations
        - Pronunciation tips
        - Cultural notes
        """
        
        dialogue = await self.ollama.chat(
            model='qwen2.5:14b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        return self.format_dialogue(dialogue['message']['content'])
    
    async def generate_quiz(self, topics: list, difficulty: str, questions: int):
        """Generate comprehensive quiz"""
        
        quiz_data = {
            'title': f"Vietnamese Mastery Quiz - {difficulty.title()}",
            'questions': []
        }
        
        for i in range(questions):
            question = await self.generate_question(
                random.choice(topics),
                difficulty
            )
            quiz_data['questions'].append(question)
            
        return quiz_data
    
    async def generate_story_with_blanks(self, theme: str, target_vocab: list):
        """Generate engaging story with fill-in-the-blank"""
        
        prompt = f"""Write an engaging Vietnamese story about: {theme}
        
        Requirements:
        - Include these vocabulary words: {', '.join(target_vocab)}
        - Make it culturally authentic
        - Replace 20% of words with blanks for practice
        - Provide word bank
        - Include English translation
        - Add comprehension questions
        """
        
        story = await self.ollama.chat(
            model='qwen2.5:14b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        return self.format_story(story['message']['content'])
```

### Frontend Integration
```html
<!-- Exercise Generator Interface -->
<div class="ai-content-generator">
    <h2>🎨 AI Exercise Generator</h2>
    
    <div class="generator-controls">
        <select id="topic">
            <option value="tones">Six-Tone System</option>
            <option value="greetings">Greetings & Introductions</option>
            <option value="numbers">Numbers & Counting</option>
            <option value="business">Business Vietnamese</option>
        </select>
        
        <select id="difficulty">
            <option value="beginner">Beginner</option>
            <option value="intermediate">Intermediate</option>
            <option value="advanced">Advanced</option>
        </select>
        
        <input type="number" id="count" value="10" min="5" max="50">
        
        <button onclick="generateExercises()">✨ Generate Exercises</button>
    </div>
    
    <div id="generated-content"></div>
</div>

<script>
async function generateExercises() {
    const topic = document.getElementById('topic').value;
    const difficulty = document.getElementById('difficulty').value;
    const count = document.getElementById('count').value;
    
    const response = await fetch('/api/ai/generate-exercises', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({topic, difficulty, count})
    });
    
    const exercises = await response.json();
    displayExercises(exercises);
}

function displayExercises(exercises) {
    const container = document.getElementById('generated-content');
    container.innerHTML = exercises.map((ex, i) => `
        <div class="exercise-card">
            <h3>Exercise ${i + 1}</h3>
            <p class="question">${ex.question}</p>
            <div class="answer-options">
                ${ex.options.map(opt => `
                    <button onclick="checkAnswer(${i}, '${opt}')">${opt}</button>
                `).join('')}
            </div>
            <div class="explanation hidden" id="exp-${i}">
                ${ex.explanation}
            </div>
        </div>
    `).join('');
}
</script>
```

---

## 🎤 SERVICE 4: AI PRONUNCIATION COACH

**Port**: 8103  
**Purpose**: Advanced pronunciation analysis with AI feedback

### Enhanced Features Beyond Basic ASR
```python
# ai_pronunciation_coach.py

class AIPronunciationCoach:
    def __init__(self):
        self.whisper_service = "http://10.0.0.104:8000/transcribe"
        self.ollama = ollama.Client()
        
    async def analyze_pronunciation(self, audio_file, target_text: str, target_tone: str):
        """Comprehensive pronunciation analysis"""
        
        # 1. Get transcription from Whisper
        transcription = await self.transcribe(audio_file)
        
        # 2. Extract pitch contour (for tone analysis)
        pitch_data = await self.extract_pitch(audio_file)
        
        # 3. Compare with native speaker reference
        tone_accuracy = self.compare_tone_contours(
            pitch_data,
            self.get_reference_tone(target_tone)
        )
        
        # 4. AI analyzes and generates feedback
        feedback = await self.generate_ai_feedback(
            transcription,
            target_text,
            tone_accuracy,
            pitch_data
        )
        
        return {
            'transcription': transcription,
            'target': target_text,
            'tone_accuracy': tone_accuracy,
            'overall_score': self.calculate_score(transcription, target_text, tone_accuracy),
            'feedback': feedback,
            'pitch_visualization': pitch_data,
            'improvement_tips': feedback['tips']
        }
    
    async def generate_ai_feedback(self, student_text, target_text, tone_acc, pitch_data):
        """AI generates personalized pronunciation feedback"""
        
        prompt = f"""As a Vietnamese pronunciation coach, analyze this student's attempt:

Student said: "{student_text}"
Target phrase: "{target_text}"
Tone accuracy: {tone_acc}%
Pitch data: {pitch_data}

Provide:
1. What they did well (specific encouragement)
2. Main issue to fix (one specific area)
3. How to fix it (mouth position, breathing, pitch)
4. Practice technique
5. Cultural context (why this pronunciation matters)
6. Next practice phrase (slightly harder)

Be encouraging and specific!"""

        response = await self.ollama.chat(
            model='qwen2.5:7b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        return json.loads(response['message']['content'])
    
    def extract_pitch(self, audio_file):
        """Extract F0 (fundamental frequency) for tone analysis"""
        import librosa
        
        y, sr = librosa.load(audio_file)
        
        # Extract pitch using YIN algorithm
        f0 = librosa.yin(y, fmin=80, fmax=400)
        
        # Normalize and smooth
        f0_normalized = self.normalize_pitch(f0)
        
        return {
            'f0_contour': f0_normalized.tolist(),
            'mean_f0': np.mean(f0),
            'f0_range': np.ptp(f0),
            'f0_variance': np.var(f0)
        }
    
    def compare_tone_contours(self, student_pitch, reference_pitch):
        """DTW-based tone comparison"""
        from dtaidistance import dtw
        
        # Dynamic Time Warping distance
        distance = dtw.distance(
            student_pitch['f0_contour'],
            reference_pitch['f0_contour']
        )
        
        # Convert to accuracy score (0-100)
        accuracy = max(0, 100 - (distance * 10))
        
        return accuracy
    
    REFERENCE_TONES = {
        'level': {  # Ngang tone (ma)
            'f0_contour': [220, 220, 220, 220, 220],  # Flat
            'description': 'Steady mid-level pitch'
        },
        'rising': {  # Sắc tone (má)
            'f0_contour': [200, 220, 240, 260, 280],  # Sharp rise
            'description': 'Rising sharply in pitch'
        },
        'falling': {  # Huyền tone (mà)
            'f0_contour': [240, 230, 220, 210, 200],  # Gentle fall
            'description': 'Falling gently in pitch'
        },
        'question': {  # Hỏi tone (mả)
            'f0_contour': [220, 210, 200, 210, 220],  # Dip and rise
            'description': 'Dip down then rise'
        },
        'tumbling': {  # Ngã tone (mã)
            'f0_contour': [220, 240, 210, 200, 190],  # Rise then fall
            'description': 'Rise sharply, then fall'
        },
        'heavy': {  # Nặng tone (mạ)
            'f0_contour': [200, 190, 180, 170, 160],  # Heavy drop with glottal
            'description': 'Heavy falling with glottal stop'
        }
    }
```

### Frontend - Enhanced Pronunciation Practice
```html
<!DOCTYPE html>
<html>
<head>
    <title>AI Pronunciation Coach</title>
</head>
<body>
    <div class="pronunciation-coach">
        <h1>🎤 AI Pronunciation Coach</h1>
        
        <!-- Target Word Display -->
        <div class="target-word">
            <h2 id="target-vietnamese">má</h2>
            <p id="target-tone">Rising Tone (Sắc)</p>
            <button onclick="playReference()">🔊 Hear Native Speaker</button>
        </div>
        
        <!-- Dual Visualization -->
        <div class="visualization-container">
            <div class="reference-viz">
                <h3>Native Speaker</h3>
                <canvas id="reference-pitch" width="400" height="200"></canvas>
            </div>
            
            <div class="student-viz">
                <h3>Your Attempt</h3>
                <canvas id="student-pitch" width="400" height="200"></canvas>
            </div>
        </div>
        
        <!-- Recording Controls -->
        <div class="controls">
            <button id="record-btn" onclick="startRecording()">
                🎤 Record Your Pronunciation
            </button>
            <div id="recording-indicator" class="hidden">
                <span class="pulse-dot"></span> Recording...
            </div>
        </div>
        
        <!-- AI Feedback Panel -->
        <div id="ai-feedback" class="feedback-panel hidden">
            <h3>🤖 AI Coach Feedback</h3>
            
            <div class="score-display">
                <div class="score-circle">
                    <span id="overall-score">0</span>%
                </div>
                <div class="score-breakdown">
                    <div>Tone Accuracy: <span id="tone-score">0</span>%</div>
                    <div>Clarity: <span id="clarity-score">0</span>%</div>
                </div>
            </div>
            
            <div class="feedback-sections">
                <div class="feedback-section positive">
                    <h4>✅ What You Did Well:</h4>
                    <p id="positive-feedback"></p>
                </div>
                
                <div class="feedback-section improvement">
                    <h4>🎯 Main Area to Improve:</h4>
                    <p id="improvement-area"></p>
                </div>
                
                <div class="feedback-section technique">
                    <h4>💡 How to Fix It:</h4>
                    <p id="technique-tip"></p>
                    <!-- Include 3D mouth animation -->
                    <div id="mouth-animation"></div>
                </div>
                
                <div class="feedback-section cultural">
                    <h4>🏮 Cultural Context:</h4>
                    <p id="cultural-note"></p>
                </div>
                
                <div class="feedback-section next">
                    <h4>📈 Next Challenge:</h4>
                    <p id="next-phrase"></p>
                    <button onclick="loadNextChallenge()">Try It!</button>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        let mediaRecorder;
        let audioChunks = [];
        
        async function startRecording() {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            mediaRecorder = new MediaRecorder(stream);
            
            mediaRecorder.ondataavailable = (e) => audioChunks.push(e.data);
            
            mediaRecorder.onstop = async () => {
                const audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
                audioChunks = [];
                
                // Send to AI for analysis
                await analyzePronunciation(audioBlob);
            };
            
            mediaRecorder.start();
            document.getElementById('recording-indicator').classList.remove('hidden');
            
            // Auto-stop after 3 seconds
            setTimeout(() => {
                mediaRecorder.stop();
                document.getElementById('recording-indicator').classList.add('hidden');
            }, 3000);
        }
        
        async function analyzePronunciation(audioBlob) {
            const formData = new FormData();
            formData.append('audio', audioBlob);
            formData.append('target_text', document.getElementById('target-vietnamese').textContent);
            formData.append('target_tone', document.getElementById('target-tone').textContent);
            
            // Show loading
            showLoading();
            
            const response = await fetch('/api/ai/pronunciation-analysis', {
                method: 'POST',
                body: formData
            });
            
            const analysis = await response.json();
            
            // Display results
            displayAIFeedback(analysis);
            visualizePitchComparison(analysis.pitch_visualization);
        }
        
        function displayAIFeedback(analysis) {
            document.getElementById('overall-score').textContent = analysis.overall_score;
            document.getElementById('tone-score').textContent = analysis.tone_accuracy;
            
            const feedback = analysis.feedback;
            document.getElementById('positive-feedback').textContent = feedback.well_done;
            document.getElementById('improvement-area').textContent = feedback.main_issue;
            document.getElementById('technique-tip').textContent = feedback.how_to_fix;
            document.getElementById('cultural-note').textContent = feedback.cultural_context;
            document.getElementById('next-phrase').textContent = feedback.next_phrase;
            
            document.getElementById('ai-feedback').classList.remove('hidden');
            
            // Animate score
            animateScore(analysis.overall_score);
            
            // Show 3D mouth position
            render3DMouthPosition(feedback.mouth_position);
        }
        
        function visualizePitchComparison(pitchData) {
            const canvas = document.getElementById('student-pitch');
            const ctx = canvas.getContext('2d');
            
            // Draw student's pitch contour
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.strokeStyle = '#00ffff';
            ctx.lineWidth = 3;
            
            ctx.beginPath();
            pitchData.f0_contour.forEach((f0, i) => {
                const x = (i / pitchData.f0_contour.length) * canvas.width;
                const y = canvas.height - ((f0 - 100) / 200 * canvas.height);
                
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            });
            ctx.stroke();
        }
        
        function render3DMouthPosition(position) {
            // Use Three.js to show 3D mouth animation
            // showing correct tongue/lip position for the tone
        }
    </script>
</body>
</html>
```

---

## ✍️ SERVICE 5: GRAMMAR & WRITING ASSISTANT

**Port**: 8104  
**Purpose**: AI-powered grammar correction and writing improvement

### Features
```python
# grammar_assistant.py

class VietnameseGrammarAssistant:
    def __init__(self):
        self.ollama = ollama.Client()
        
    async def check_grammar(self, vietnamese_text: str):
        """Comprehensive grammar analysis"""
        
        prompt = f"""Analyze this Vietnamese text for grammar:
        "{vietnamese_text}"
        
        Check:
        1. Sentence structure (Subject-Verb-Object)
        2. Classifier usage (cái, con, người, etc.)
        3. Tone marker placement
        4. Verb tense indicators (đã, sẽ, đang)
        5. Politeness levels (formal vs informal)
        6. Common Vietnamese mistakes
        
        Return JSON:
        {{
            "errors": [
                {{
                    "type": "classifier",
                    "location": "word position",
                    "error": "wrong text",
                    "correction": "correct text",
                    "explanation": "why it's wrong",
                    "example": "correct usage example"
                }}
            ],
            "score": 0-100,
            "level": "beginner/intermediate/advanced",
            "suggestions": ["overall improvement tips"]
        }}"""
        
        response = await self.ollama.chat(
            model='qwen2.5:14b',  # Larger model for better grammar analysis
            messages=[{"role": "user", "content": prompt}]
        )
        
        return json.loads(response['message']['content'])
    
    async def improve_writing(self, text: str, style: str = "formal"):
        """AI suggests improvements for Vietnamese writing"""
        
        prompt = f"""Improve this Vietnamese text:
        "{text}"
        
        Target style: {style}
        
        Provide:
        1. Improved version
        2. What was changed and why
        3. Alternative phrasings
        4. More natural Vietnamese expressions
        5. Cultural appropriateness notes
        """
        
        response = await self.ollama.chat(
            model='qwen2.5:14b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        return self.parse_improvement_response(response['message']['content'])
    
    async def explain_grammar_concept(self, concept: str):
        """AI explains Vietnamese grammar concepts"""
        
        prompt = f"""Explain this Vietnamese grammar concept: {concept}
        
        Include:
        1. Simple explanation
        2. 5 example sentences
        3. Common mistakes to avoid
        4. Practice exercises
        5. Memory technique
        """
        
        explanation = await self.ollama.chat(
            model='qwen2.5:7b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        return explanation['message']['content']

@app.post("/api/ai/grammar-check")
async def grammar_check_endpoint(text: str):
    assistant = VietnameseGrammarAssistant()
    analysis = await assistant.check_grammar(text)
    return analysis
```

### Frontend Integration
```html
<div class="grammar-assistant">
    <h2>✍️ AI Writing Assistant</h2>
    
    <textarea id="vietnamese-text" rows="10" 
              placeholder="Type your Vietnamese here...">
    </textarea>
    
    <button onclick="checkGrammar()">🔍 Check Grammar</button>
    
    <div id="grammar-feedback">
        <!-- AI highlights errors inline with explanations -->
    </div>
</div>
```

---

## 🌏 SERVICE 6: CULTURAL CONTEXT EXPLAINER

**Port**: 8105  
**Purpose**: AI explains cultural nuances and context

### Features
```python
# cultural_explainer.py

class CulturalContextExplainer:
    async def explain_cultural_context(self, word_or_phrase: str):
        """AI provides cultural context"""
        
        prompt = f"""Explain the cultural significance of this Vietnamese word/phrase:
        "{word_or_phrase}"
        
        Include:
        1. Literal meaning
        2. Cultural context and usage
        3. When/where it's appropriate
        4. Historical background (if relevant)
        5. Regional variations (North/Central/South Vietnam)
        6. Similar expressions in English
        7. Common situations to use it
        8. Etiquette notes
        """
        
        response = await ollama.chat(
            model='qwen2.5:14b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        return response['message']['content']
    
    async def explain_business_etiquette(self, situation: str):
        """Vietnamese business culture guide"""
        
        prompt = f"""Explain Vietnamese business etiquette for: {situation}
        
        Cover:
        1. Proper greeting protocol
        2. Business card exchange etiquette
        3. Appropriate titles and honorifics
        4. Gift-giving customs
        5. Meeting behavior
        6. Do's and Don'ts
        7. Cultural sensitivity points
        """
        
        # ... implementation
```

---

## 📊 SERVICE 7: PROGRESS ANALYTICS DASHBOARD

**Port**: 8107  
**Purpose**: Real-time learning analytics with AI insights

### Metrics Tracked
- Total study time
- Lessons completed
- Quiz scores over time
- Pronunciation accuracy trends
- Vocabulary mastery
- Conversation practice hours
- Weak areas
- Learning velocity
- Predicted completion date

### AI Insights
```python
class ProgressAnalytics:
    async def generate_weekly_insights(self, student_id: int):
        """AI generates personalized weekly report"""
        
        data = await self.get_student_data(student_id)
        
        prompt = f"""Analyze this student's Vietnamese learning progress:
        
        Week's data:
        - Study hours: {data['study_hours']}
        - Lessons completed: {data['lessons_completed']}
        - Avg quiz score: {data['avg_quiz_score']}
        - Pronunciation accuracy: {data['pronunciation_avg']}
        - Weak topics: {data['weak_topics']}
        - Learning streak: {data['streak_days']} days
        
        Generate:
        1. Celebration message (highlight achievements)
        2. Progress summary
        3. Areas needing attention
        4. Next week's goals (specific, achievable)
        5. Motivation message
        6. Recommended focus areas
        """
        
        insights = await ollama.chat(
            model='qwen2.5:7b',
            messages=[{"role": "user", "content": prompt}]
        )
        
        return insights['message']['content']
```

---

## 🎮 GAMIFICATION WITH AI

### Achievement System
```javascript
const AI_ACHIEVEMENTS = {
    'conversation_master': {
        title: 'Conversation Master',
        description: 'Complete 50 AI conversations',
        icon: '💬',
        xp: 500,
        unlocked_by_ai: true
    },
    'perfect_tones': {
        title: 'Tone Perfectionist',
        description: 'Score 95%+ on 10 consecutive tone practices',
        icon: '🎵',
        xp: 300
    },
    'cultural_expert': {
        title: 'Cultural Expert',
        description: 'Learn 100 cultural context explanations',
        icon: '🏮',
        xp: 400
    },
    'ai_challenged': {
        title: 'AI Challenged',
        description: 'AI increased your difficulty level',
        icon: '🚀',
        xp: 200
    }
};
```

---

## 🚀 DEPLOYMENT PLAN

### Phase 1: Setup VM 10.0.0.110 (Week 1)
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull Vietnamese-capable models
ollama pull qwen2.5:7b
ollama pull qwen2.5:14b

# Install Python deps
pip install fastapi uvicorn websockets python-multipart
pip install librosa dtaidistance TTS
pip install numpy pandas scikit-learn
pip install sqlalchemy asyncpg

# Install audio processing
sudo apt install ffmpeg portaudio19-dev

# Setup PostgreSQL for user data
sudo apt install postgresql
```

### Phase 2: Deploy Services (Week 2)
1. AI Conversation Partner → Port 8100
2. Adaptive Learning Engine → Port 8101
3. Content Generator → Port 8102
4. Pronunciation Coach → Port 8103

### Phase 3: Nginx Configuration (Week 3)
```nginx
# /etc/nginx/sites-enabled/moodle-ai.conf

server {
    listen 443 ssl http2;
    server_name moodle.simondatalab.de;
    
    # AI Services
    location /ai/conversation {
        proxy_pass http://10.0.0.110:8100;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    location /ai/learning {
        proxy_pass http://10.0.0.110:8101;
    }
    
    location /ai/generate {
        proxy_pass http://10.0.0.110:8102;
    }
    
    location /ai/pronunciation {
        proxy_pass http://10.0.0.110:8103;
    }
    
    location /ai/grammar {
        proxy_pass http://10.0.0.110:8104;
    }
}
```

### Phase 4: Moodle Integration (Week 4)
1. Embed iframe in course sections
2. Add JavaScript API calls
3. Integrate with existing ASR service
4. Deploy analytics dashboard

---

## 📱 MOODLE COURSE STRUCTURE WITH AI

```
Vietnamese Mastery Course (ID: 10)
│
├── Module 1: Alphabet & Tones
│   ├── 🎤 Interactive Alphabet [EXISTING]
│   ├── 🎵 Six-Tone System [EXISTING]
│   ├── NEW: 🤖 AI Pronunciation Coach [iframe]
│   └── NEW: 🎮 AI-Generated Tone Exercises
│
├── Module 2: Basic Conversations
│   ├── NEW: 💬 AI Conversation Partner - Coffee Shop
│   ├── NEW: 💬 AI Conversation Partner - Greetings
│   ├── NEW: ✍️ Grammar Assistant
│   └── NEW: 🏮 Cultural Context Explainer
│
├── Module 3: Business Vietnamese
│   ├── NEW: 💬 AI Business Conversation Partner
│   ├── NEW: 📝 AI Writing Improvement
│   └── NEW: 🌏 Business Etiquette Guide (AI)
│
├── Module 4: Advanced Topics
│   ├── NEW: 🎨 AI Content Generator (custom exercises)
│   ├── NEW: 📖 AI Story Generator
│   └── NEW: 🎓 AI Tutor (1-on-1 help)
│
└── Module 5: Progress & Analytics
    ├── NEW: 📊 AI Learning Dashboard
    ├── NEW: 🎯 Personalized Learning Path
    ├── NEW: 📈 Weekly AI Insights
    └── NEW: 🏆 Achievement System
```

---

## 💰 COST ESTIMATION

### Hardware (VM 10.0.0.110)
- **Recommended**: 32GB RAM, 8+ CPU cores
- **Storage**: 100GB for models
- **GPU**: Optional (speeds up inference 10x)

### Model Sizes
- qwen2.5:7b → ~4.5GB
- qwen2.5:14b → ~9GB
- Whisper (already deployed)
- Coqui TTS models → ~500MB

### Performance
- Ollama CPU: ~1-2 sec response time
- Ollama GPU: ~0.1-0.3 sec response time
- Concurrent users: 10-20 on CPU, 50+ on GPU

---

## 🎯 SUCCESS METRICS

### Student Engagement
- ✅ Target: 300% increase in practice time
- ✅ Target: 80% course completion rate (vs current 40%)
- ✅ Target: 90% student satisfaction

### Learning Outcomes
- ✅ 50% faster pronunciation mastery
- ✅ 40% better grammar accuracy
- ✅ 60% increase in conversation confidence

### AI Performance
- ✅ AI response time < 2 seconds
- ✅ 95% AI feedback accuracy
- ✅ 85% student agreement with AI recommendations

---

## 🔐 SECURITY & PRIVACY

### Data Protection
```python
# Anonymize student data
- Hash student IDs
- Encrypt audio recordings
- Delete recordings after analysis
- GDPR-compliant data storage
```

### API Security
```python
# JWT authentication
- Secure API endpoints
- Rate limiting (prevent abuse)
- Input validation
- SQL injection prevention
```

---

## 📚 DOCUMENTATION FOR STUDENTS

### "How to Use AI Features" Guide

**Getting Started with Your AI Tutor:**

1. **AI Conversation Partner** 🗣️
   - Click "Start Conversation"
   - Choose scenario (coffee shop, business, etc.)
   - Speak in Vietnamese
   - AI responds with voice + feedback

2. **Pronunciation Coach** 🎤
   - Select word/phrase to practice
   - Click microphone
   - See your tone curve vs native speaker
   - Get personalized tips

3. **Exercise Generator** ✨
   - Choose topic and difficulty
   - AI creates custom exercises just for you
   - Unlimited practice content

4. **Your Learning Dashboard** 📊
   - See your progress
   - AI recommends what to study next
   - Track achievements
   - Weekly AI insights

---

## ⚡ QUICK START COMMANDS

```bash
# SSH to AI VM
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110

# Check Ollama status
systemctl status ollama

# Test Ollama
ollama run qwen2.5:7b "Translate to Vietnamese: Hello, how are you?"

# Deploy AI services
cd /home/simonadmin/vietnamese-ai
./deploy_all_services.sh

# Monitor logs
journalctl -u ai-conversation -f
journalctl -u ai-pronunciation -f

# Test endpoints
curl http://10.0.0.110:8100/health
curl http://10.0.0.110:8101/health
```

---

## 🎨 CREATIVE AI FEATURES (SKY IS THE LIMIT!)

### 1. AI-Generated Vietnamese Music
- AI composes songs with Vietnamese lyrics
- Students sing along for pronunciation practice
- Karaoke mode with real-time feedback

### 2. Virtual Reality Vietnamese City
- VR environment (Hanoi streets)
- AI NPCs for conversation practice
- Cultural immersion

### 3. AI Dream Interpreter (Vietnamese)
- Students describe dreams in Vietnamese
- AI provides cultural interpretation
- Vocabulary building through storytelling

### 4. Vietnamese Poetry Generator
- AI creates poems in Vietnamese
- Students learn literary language
- Cultural appreciation

### 5. AI Debate Partner
- Argue topics in Vietnamese
- AI challenges your arguments
- Advanced conversation practice

### 6. Vietnamese Recipe AI
- AI teaches cooking with Vietnamese instructions
- Voice commands in Vietnamese
- Cultural food context

### 7. AI Language Exchange Matcher
- Match students by level
- AI moderates conversations
- Suggests topics

### 8. Augmented Reality Flashcards
- Point phone at objects
- AI provides Vietnamese word + cultural context
- Real-world vocabulary building

---

## 🚀 READY TO DEPLOY!

**Next Steps:**
1. ✅ VM 10.0.0.110 rebooting
2. ⏳ Once online: Install Ollama + models
3. ⏳ Deploy AI services
4. ⏳ Configure nginx reverse proxy
5. ⏳ Integrate into Moodle course
6. ⏳ Test with students
7. 🎉 **LAUNCH!**

---

**Document Version:** 1.0  
**Created:** November 4, 2025  
**Author:** Simon Renauld  
**Status:** Ready for Implementation 🚀
