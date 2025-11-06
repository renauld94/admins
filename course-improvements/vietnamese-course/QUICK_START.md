# Quick Start: Automated Moodle Deployment

## 🚀 One-Command Deployment

```bash
# Complete deployment in 3 commands
./setup_moodle_webservices.sh       # Step 1: Configure Moodle (5 min)
python3 course_content_generator.py --generate-all  # Step 2: Generate content (30 min)
python3 moodle_deployer.py --deploy-all            # Step 3: Deploy to Moodle (15 min)
```

## ✅ Pre-Deployment Checklist

- [ ] Vietnamese Tutor Agent running: `systemctl status vietnamese-tutor-agent`
- [ ] Moodle admin access to: https://moodle.simondatalab.de
- [ ] Course ID known: `10`
- [ ] Generated content exists: `ls -la generated/professional/`

## 📋 Step-by-Step

### Step 1: Enable Moodle Web Services (5 minutes)

```bash
./setup_moodle_webservices.sh
```

This interactive script will guide you through:
1. Enabling web services in Moodle
2. Creating an external service
3. Adding required API functions
4. Generating and saving your token

**Token will be saved to:** `~/.moodle_token`

### Step 2: Generate Course Content (30 minutes)

```bash
cd ~/Learning-Management-System-Academy/course-improvements/vietnamese-course
python3 course_content_generator.py --generate-all
```

**Generates 33+ files:**
- 8× Interactive HTML lessons
- 8× GIFT format quizzes
- 8× Anki flashcard decks (CSV)
- 8× Practice dialogue scripts
- 1× Course overview page
- 1× Deployment manifest

**Output directory:** `generated/professional/`

### Step 3: Deploy to Moodle (15 minutes)

```bash
python3 moodle_deployer.py --deploy-all
```

**Deploys:**
- ✅ 120 quiz questions to Question Bank
- ✅ 8 HTML lessons as Page resources
- ✅ 8 flashcard files
- ✅ 8 dialogue files
- ✅ 7 assignments with rubrics
- ✅ Vietnamese Tutor Agent widgets

**You'll be asked to confirm before deployment.**

## 🎯 Verify Deployment

### Check Moodle Course

Visit: https://moodle.simondatalab.de/course/view.php?id=10

You should see:
- 8 weeks of content (sections 1-8)
- Page resources (HTML lessons)
- File resources (flashcards + dialogues)
- Assignments (weeks 1-7)

### Test Agent Widget

1. Open any lesson page
2. Click the 🎓 button (bottom-right corner)
3. Try typing: "Xin chào" → Check grammar
4. Verify chat interface loads

### Check Question Bank

1. Go to Course → Question bank → Questions
2. Select category: "Week 1 - Foundation: Greetings & Personal Information"
3. Preview questions

## 🔧 Troubleshooting

### Issue: "Token not found"

```bash
# Check token exists
cat ~/.moodle_token

# If missing, run setup again
./setup_moodle_webservices.sh
```

### Issue: "Permission denied"

```bash
# Make scripts executable
chmod +x setup_moodle_webservices.sh
chmod +x deploy_all_content.sh
```

### Issue: "Vietnamese Tutor Agent not responding"

```bash
# Check agent status
systemctl status vietnamese-tutor-agent

# Restart if needed
sudo systemctl restart vietnamese-tutor-agent

# Test connectivity
curl http://localhost:5001/health
```

### Issue: "Content directory not found"

```bash
# Generate content first
python3 course_content_generator.py --generate-all

# Verify output
ls -la generated/professional/
```

## 📖 Detailed Documentation

- **Complete deployment guide**: `MOODLE_DEPLOYMENT_GUIDE.md`
- **Content generation**: `EPIC_CONTENT_GENERATION.md`
- **Agent integration**: `VIETNAMESE_AGENT_INTEGRATION.md`
- **Course structure**: `lesson_plan.md`

## 🎓 What Gets Deployed

### Question Bank (120 questions)

```
Vietnamese Language Course
├── Week 1 - Foundation (15 questions)
├── Week 2 - Navigation (15 questions)
├── Week 3 - Culinary (15 questions)
├── Week 4 - Academic (15 questions)
├── Week 5 - Professional (15 questions)
├── Week 6 - Cultural (15 questions)
├── Week 7 - Narrative (15 questions)
└── Week 8 - Capstone (15 questions)
```

### Course Content (per week)

- **HTML Lesson** (Page resource)
  - Interactive animations (Anime.js)
  - Progress tracking (Chart.js)
  - Vietnamese Tutor Agent widget
  - Responsive design

- **Flashcards** (File resource)
  - Anki-compatible CSV format
  - Week-specific vocabulary
  - Example sentences

- **Dialogues** (File resource)
  - Practical conversations
  - Audio script format
  - Cultural context

- **Assignment** (Assignment activity)
  - Detailed instructions
  - Grading rubric
  - Due date (1 week)

## 🔍 Advanced Options

### Deploy specific components only

```bash
# Deploy only quizzes
python3 moodle_deployer.py --deploy-quizzes

# Deploy only lessons
python3 moodle_deployer.py --deploy-lessons

# Deploy only resources (flashcards + dialogues)
python3 moodle_deployer.py --deploy-resources

# Deploy only assignments
python3 moodle_deployer.py --deploy-assignments
```

### Custom Moodle URL

```bash
python3 moodle_deployer.py --deploy-all --moodle-url https://your-moodle.com
```

### Custom Course ID

```bash
python3 moodle_deployer.py --deploy-all --course-id 20
```

## 📊 Expected Results

After successful deployment:

| Component | Count | Location |
|-----------|-------|----------|
| Questions | 120 | Question Bank |
| Lessons | 8 | Course sections 1-8 |
| Flashcards | 8 | Course sections 1-8 |
| Dialogues | 8 | Course sections 1-8 |
| Assignments | 7 | Course sections 1-7 |
| Agent Widgets | 8 | Embedded in lessons |

## 🎉 Success!

Your Vietnamese Language Course is now fully deployed with:

- ✅ Professional, interactive content
- ✅ AI-powered Vietnamese Tutor Agent
- ✅ Comprehensive assessments
- ✅ Practice materials (flashcards + dialogues)
- ✅ Structured assignments
- ✅ Mobile-responsive design

**Course URL:** https://moodle.simondatalab.de/course/view.php?id=10

---

**Need help?** Check `MOODLE_DEPLOYMENT_GUIDE.md` for detailed troubleshooting.
