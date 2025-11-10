# 🎓 Vietnamese Moodle Master Agent - Demo Guide

**Created:** November 4, 2025  
**Agent Location:** `~/.continue/agents/vietnamese-moodle-master.yaml`  
**Status:** ✅ Ready to Use in Continue!

---

## 🚀 What This Agent Can Do

The **Vietnamese Moodle Master** is an epic AI agent that combines:
- Your local Ollama models (Gemma2, DeepSeek, Qwen2.5)
- Your existing Vietnamese course content
- Your AI services (Whisper ASR on VM104, Ollama on VM159)
- Moodle expertise

### Core Capabilities

1. **📊 Content Review & Analysis**
   - Scans all Vietnamese content in workspace
   - Detects duplicate lessons
   - Identifies quality issues
   - Recommends improvements

2. **✨ Creative Content Generation**
   - Complete lessons with cultural context
   - Interactive exercises
   - Pronunciation drills
   - Authentic dialogues
   - Moodle-ready HTML/CSS/JS

3. **🎤 AI-Powered Features**
   - Whisper ASR integration
   - Ollama conversation partners
   - Pronunciation coaching
   - Adaptive learning

4. **🚀 Moodle Deployment**
   - Course backup generation (.mbz)
   - Deployment scripts
   - Activity configurations

---

## 💬 How to Use in Continue

### Step 1: Reload VS Code
```
Ctrl+Shift+P → "Reload Window"
```

### Step 2: Open Continue Chat
```
Ctrl+L
```

### Step 3: Select the Agent
- Click the agent dropdown
- Select "Vietnamese Moodle Master 🎓"

### Step 4: Try These Commands!

#### Example 1: Review Existing Content
```
Review all Vietnamese course content in my workspace and identify duplicates
```

**Expected Output:**
```
📊 CONTENT INVENTORY
Found in workspace:
- learning-platform/vietnamese-epic-platform.html
- learning-platform/vietnamese-advanced-lessons.js
- course-improvements/vietnamese-course/
- vietnamese-course-builder/

⚠️ DUPLICATES DETECTED:
- Tone system explained in 3 different files
- Greeting dialogues duplicated

💡 RECOMMENDATIONS:
[Specific suggestions with file paths]
```

#### Example 2: Generate a New Lesson
```
Create an epic Vietnamese lesson about "Vietnamese Family Terminology" 
for intermediate learners
```

**Expected Output:**
```
🎓 LESSON: Vietnamese Family Terminology (Intermediate)

📖 LEARNING OBJECTIVES:
1. Master 15+ family relationship terms
2. Understand Vietnamese kinship hierarchy
3. Use respectful address forms correctly
4. Navigate family introductions

🌏 CULTURAL CONTEXT:
Vietnamese family structure is deeply hierarchical...

📝 VOCABULARY (15 words):
1. gia đình [ʒaː ɗɪ̃ŋ˧˨] (ngang-huyền) - family
   Example: Gia đình tôi có 5 người
   Cultural note: Extended family very important
   Northern/Southern: Same

2. bố [ɓɔ˦˥] (sắc) - father (informal)
   Example: Bố tôi là kỹ sư
   Usage: Use with immediate family
   Formal: cha

[... 13 more words ...]

💬 DIALOGUE: Family Dinner Introduction
[Complete authentic conversation with tones]

✍️ INTERACTIVE EXERCISES:
[5 fill-in-the-blank, 5 multiple choice, etc.]

🎤 PRONUNCIATION FOCUS:
[Tone drills for family terms]

🏮 CULTURAL DEEP DIVE:
[Vietnamese family etiquette]

💻 MOODLE CODE:
<!DOCTYPE html>
<html>
<head>
    <title>Vietnamese Family Terminology</title>
    <style>
        /* SimonDataLab theme styling */
        [Complete CSS]
    </style>
</head>
<body>
    [Complete interactive lesson]
</body>
</html>
```

#### Example 3: Create Pronunciation Drill
```
Generate an interactive pronunciation drill for the six Vietnamese tones
with Whisper ASR integration
```

**Expected Output:**
```
🎤 INTERACTIVE SIX-TONE DRILL

Target words: ma, má, mà, mả, mã, mạ

[Visual tone contours in ASCII art]
[Complete HTML/JS code with:]
- Audio recording interface
- Whisper ASR integration (http://10.0.0.104:8000)
- Real-time pitch visualization
- Scoring algorithm
- Gamification
```

#### Example 4: Cultural Module
```
Create a cultural module about "Vietnamese Coffee Culture"
```

**Expected Output:**
```
☕ CULTURAL MODULE: Vietnamese Coffee Culture

[Complete module with:]
- History of cà phê sữa đá
- 20+ coffee vocabulary words
- Café etiquette
- Regional variations (Hanoi vs Saigon)
- Interactive quiz
- Ordering dialogue
- Cultural quiz
```

#### Example 5: AI Enhancement Plan
```
Design a comprehensive AI enhancement plan for my Vietnamese course
```

**Expected Output:**
```
🤖 AI ENHANCEMENT PLAN - Course ID: 10

1. AI CONVERSATION PARTNER
   Architecture:
   [ASCII diagram of WebSocket setup]
   
   API Endpoints:
   - POST /api/ai/conversation/start
   - WS /ws/conversation
   - POST /api/ai/feedback
   
   Frontend Code:
   [Complete JavaScript implementation]
   
   Deployment:
   [Step-by-step on VM 10.0.0.110]

[... full plan for 5 AI services ...]
```

---

## 🎯 Predefined Prompts

The agent has 7 specialized prompts:

| Prompt | Description | Use When |
|--------|-------------|----------|
| `review-course-content` | Analyze existing content | Starting new work |
| `generate-vietnamese-lesson` | Create complete lesson | Need new module |
| `create-pronunciation-drill` | Build pronunciation exercise | Tone/sound practice |
| `generate-culture-module` | Cultural content module | Cultural topics |
| `create-moodle-backup` | Generate .mbz backup | Deployment |
| `ai-enhancement-plan` | Plan AI integrations | AI features |
| `quick-lesson-generate` | Rapid lesson creation | Quick content |

---

## 🛠️ Technical Integration

### Models Available
```yaml
1. Gemma2 9B (Best Reasoning)
   - Use for: Complex lesson planning, cultural analysis
   
2. DeepSeek Coder 6.7B (Best for Code)
   - Use for: HTML/CSS/JS generation, Moodle code
   
3. Qwen2.5 7B (Multilingual)
   - Use for: Vietnamese content, translations, dialogues
```

### AI Services Integration
```javascript
// Whisper ASR (VM104)
fetch('http://10.0.0.104:8000/transcribe', {
    method: 'POST',
    body: audioFormData
});

// Ollama (VM159)
fetch('http://10.0.0.110:11434/api/chat', {
    method: 'POST',
    body: JSON.stringify({
        model: 'qwen2.5:7b',
        messages: [...]
    })
});
```

---

## 📁 Workspace Resources Agent Can Access

The agent knows about and can use:

```
~/Learning-Management-System-Academy/
├── learning-platform/
│   ├── vietnamese-epic-platform.html
│   ├── vietnamese-epic-platform.js
│   ├── vietnamese-epic-platform.css
│   ├── vietnamese-audio-speech-module.js
│   ├── vietnamese-audio-animation.js
│   └── vietnamese-audio-animation.css
├── vietnamese-course-builder/
├── course-improvements/vietnamese-course/
├── deployment/
│   └── deploy_vietnamese_to_moodle.sh
└── AI_VIETNAMESE_COURSE_INTEGRATION.md
```

---

## 🎮 Slash Commands

Quick shortcuts in Continue chat:

```
/review-course    → Analyze existing content
/new-lesson       → Generate new lesson module
/pronunciation    → Create pronunciation exercise
/culture          → Generate cultural content
/deploy           → Create Moodle deployment package
```

---

## 💡 Pro Tips

### 1. Be Specific with Levels
```
❌ "Create a Vietnamese lesson"
✅ "Create an intermediate Vietnamese lesson about business greetings"
```

### 2. Request Moodle-Ready Format
```
❌ "Explain Vietnamese tones"
✅ "Create a Moodle-ready HTML lesson on Vietnamese tones with interactive exercises"
```

### 3. Leverage Existing Content
```
✅ "Review my existing Vietnamese content and create a lesson that fills the biggest gap"
```

### 4. Ask for AI Integration
```
✅ "Generate a pronunciation drill with Whisper ASR integration for business phrases"
```

### 5. Request Cultural Context
```
✅ "Create a lesson on numbers but include cultural significance (lucky/unlucky numbers)"
```

---

## 🎨 What Makes This Agent Epic

### 1. **No Duplicates Promise**
Agent always reviews existing content first to avoid redundancy

### 2. **Cultural Authenticity**
Every lesson includes:
- Cultural context
- Regional variations (North/South)
- Etiquette notes
- Historical background

### 3. **Production Ready**
All output is Moodle-compatible and deployment-ready

### 4. **AI Service Integration**
Leverages your existing infrastructure:
- Ollama models
- Whisper ASR
- Vietnamese audio files

### 5. **Quality Standards**
- IPA pronunciation
- Tone markers
- Example sentences
- Memory techniques
- Interactive exercises

---

## 🚀 Sample Workflow

### Complete Course Enhancement Project

**Step 1: Analysis**
```
@vietnamese-moodle-master Review all Vietnamese content and create a comprehensive improvement plan
```

**Step 2: Fill Gaps**
```
Based on your analysis, create the 3 most important missing lessons
```

**Step 3: Add AI Features**
```
Design AI conversation partners for the 5 most common scenarios
```

**Step 4: Cultural Content**
```
Create cultural modules for: food, business, family, holidays, daily life
```

**Step 5: Pronunciation**
```
Generate pronunciation drills for all tone combinations
```

**Step 6: Deployment**
```
Create a complete Moodle backup with all new content
```

---

## 📊 Expected Output Quality

### Lesson Structure Example
```html
<!-- Every lesson includes -->
<div class="vietnamese-lesson">
    <section class="objectives">
        <!-- 3-5 clear learning goals -->
    </section>
    
    <section class="cultural-context">
        <!-- Why this matters culturally -->
    </section>
    
    <section class="vocabulary">
        <!-- 10-15 words with full details -->
    </section>
    
    <section class="grammar">
        <!-- Clear explanation + examples -->
    </section>
    
    <section class="dialogue">
        <!-- Authentic conversation -->
    </section>
    
    <section class="exercises">
        <!-- 5+ interactive activities -->
    </section>
    
    <section class="pronunciation">
        <!-- Tone drills + practice -->
    </section>
    
    <section class="cultural-dive">
        <!-- Deep cultural insights -->
    </section>
</div>
```

---

## 🎯 Success Metrics

After using this agent, you should have:

✅ **No duplicate content** across course  
✅ **Every lesson has cultural context**  
✅ **All content is Moodle-ready**  
✅ **Interactive exercises throughout**  
✅ **AI features integrated**  
✅ **Professional production quality**  
✅ **Authentic Vietnamese language**  
✅ **Regional variations included**

---

## 🔥 Ready to Test!

### Quick Start Commands

1. **Review everything first:**
```
Review all Vietnamese course content and identify opportunities for improvement
```

2. **Create your first lesson:**
```
Create an intermediate lesson about "Vietnamese Market Shopping" with cultural context and Moodle-ready code
```

3. **Build pronunciation tools:**
```
Generate an interactive tone drill with visual feedback and ASR integration
```

4. **Plan AI features:**
```
Design a comprehensive AI enhancement plan for Course ID 10
```

---

## 📝 Notes

- Agent uses `http://localhost:11434` (SSH tunnel to VM159)
- Whisper ASR at `http://10.0.0.104:8000`
- All content follows SimonDataLab design theme
- Output is production-ready (no placeholders!)
- Cultural sensitivity prioritized
- Northern/Southern variations included

---

**🎉 Now reload VS Code, open Continue (Ctrl+L), select the Vietnamese Moodle Master agent, and let's create an epic course!**

**First command to try:**
```
Hello! Please review all my Vietnamese course content and show me what you can do to make it epic!
```
