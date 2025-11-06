# Automated Moodle Deployment Guide

## Overview

Complete automation of Vietnamese Course deployment to Moodle (Course ID: 10):
- ✅ Import quizzes to Question Bank (GIFT format)
- ✅ Upload HTML lessons as Page resources
- ✅ Distribute flashcards as File resources
- ✅ Link dialogues in assignments
- ✅ Configure Vietnamese Tutor Agent widgets
- ✅ Create all assignments with rubrics

## Prerequisites

### 1. Generate Course Content

First, generate all course content:

```bash
cd ~/Learning-Management-System-Academy/course-improvements/vietnamese-course
python3 course_content_generator.py --generate-all
```

This creates 33+ files in `generated/professional/`:
- 8× HTML lessons
- 8× GIFT quizzes
- 8× CSV flashcards
- 8× Dialogue texts
- 1× index.html
- 1× deployment_manifest.json

### 2. Enable Moodle Web Services

Run the setup script to configure Moodle:

```bash
./setup_moodle_webservices.sh
```

Or manually:

1. **Enable Web Services**
   - Site Administration → Advanced Features
   - Enable "Enable web services"

2. **Enable REST Protocol**
   - Site Administration → Plugins → Web services → Manage protocols
   - Enable "REST protocol"

3. **Create External Service**
   - Site Administration → Plugins → Web services → External services
   - Add service: "Vietnamese Course Deployment"
   - Add functions:
     * `core_course_get_contents`
     * `core_course_get_courses`
     * `core_question_get_categories`
     * `core_question_import_questions`
     * `core_question_create_categories`
     * `mod_page_add_page`
     * `mod_assign_create_assignments`
     * `mod_resource_add_resource`

4. **Create Token**
   - Site Administration → Plugins → Web services → Manage tokens
   - User: Your admin account
   - Service: Vietnamese Course Deployment
   - Save token to: `~/.moodle_token`

## Usage

### Deploy Everything (Recommended)

```bash
python3 moodle_deployer.py --deploy-all
```

This will:
1. Import all 8 weeks of quizzes to Question Bank
2. Create 8 Page resources with HTML lessons + Agent widgets
3. Upload 8 flashcard files as File resources
4. Upload 8 dialogue files as File resources
5. Create 7 assignments with detailed instructions
6. Configure Vietnamese Tutor Agent widgets on all pages

### Deploy Components Individually

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

## Vietnamese Tutor Agent Widget

### Features

The agent widget is automatically injected into every lesson page:

- **Fixed Position**: Bottom-right corner (mobile-responsive)
- **Interactive Chat**: Direct communication with AI agent
- **Quick Actions**: Grammar, Pronunciation, Vocabulary, Translation
- **Week-Specific**: Tailored to each week's content

### Widget Capabilities

1. **Grammar Checking**: Submit Vietnamese text for analysis
2. **Pronunciation Help**: Get feedback on tones and sounds
3. **Vocabulary Practice**: Practice week-specific vocabulary
4. **Translation**: Translate between English and Vietnamese
5. **Dialogue Generation**: Generate practice conversations
6. **Quiz Help**: Get hints and explanations

### API Integration

Widget connects to Vietnamese Tutor Agent at:
- URL: `http://localhost:5001`
- Authentication: Bearer token from `workspace/agents/.token`
- Endpoints: `/grammar/check`, `/pronunciation/check`, `/vocabulary/practice`, etc.

## Deployment Structure

### Course Organization

Each week (1-8) contains:

```
Week N: [Title]
├── Page: "Week N: [Title]"
│   └── HTML lesson with Agent widget
├── File: "Week N Flashcards - Anki Deck"
│   └── CSV file for Anki import
├── File: "Week N Practice Dialogues"
│   └── Text file with dialogues
└── Assignment: "[Assignment Name]"
    └── Recording/Video/Project submission
```

### Question Bank Structure

```
Question Bank
└── Course: Vietnamese Language Course
    ├── Week 1 - Foundation: Greetings & Personal Information
    │   └── [15 GIFT questions]
    ├── Week 2 - Navigation: Directions & Transportation
    │   └── [15 GIFT questions]
    ├── ... (weeks 3-7)
    └── Week 8 - Capstone: Final Assessment & Showcase
        └── [15 GIFT questions]
```

## Assignments Created

1. **Week 1**: 30-Second Self Introduction (recording)
2. **Week 2**: Direction Giving Video (2-3 min)
3. **Week 3**: Restaurant Dialogue Recording (2-3 min)
4. **Week 4**: Academic Presentation (3 min)
5. **Week 5**: Job Application Package (CV + interview)
6. **Week 6**: Travel Itinerary Group Project (video)
7. **Week 7**: Personal Narrative Story (3-5 min, polished)

Each assignment includes:
- Detailed instructions
- Requirements checklist
- Grading rubric
- Due date (1 week intervals)

## Verification

After deployment, verify:

### 1. Check Question Bank

```
Site Administration → Question bank → Questions
```

Should see 8 categories with 15 questions each (120 total)

### 2. Check Course Content

```
https://moodle.simondatalab.de/course/view.php?id=10
```

Should see:
- 8 weeks of content
- Page resources with lessons
- File resources with flashcards and dialogues
- Assignments with descriptions

### 3. Test Agent Widget

1. Open any lesson page
2. Click the 🎓 button (bottom-right)
3. Try quick actions: Grammar, Pronunciation, etc.
4. Verify API connectivity

### 4. Test Quiz Import

```
Course → Question bank → Questions → Select category
```

Preview questions to ensure proper import

## Troubleshooting

### Token Issues

```bash
# Verify token exists
cat ~/.moodle_token

# Recreate token in Moodle
# Site Admin → Web services → Manage tokens
```

### Permission Errors

```
Error: "You do not have permission to use this function"
```

Solution: Add missing functions to web service in Moodle

### API Connection Errors

```
Error: "Connection error. Please try again."
```

Check:
1. Vietnamese Tutor Agent is running: `systemctl status vietnamese-tutor-agent`
2. Agent URL is correct in widget: `http://localhost:5001`
3. Agent token is valid: `~/../workspace/agents/.token`

### Content Not Found

```
Error: "Content directory not found"
```

Solution: Generate content first:
```bash
python3 course_content_generator.py --generate-all
```

## Advanced Configuration

### Custom Moodle URL

```bash
python3 moodle_deployer.py --deploy-all --moodle-url https://your-moodle.com
```

### Custom Course ID

```bash
python3 moodle_deployer.py --deploy-all --course-id 20
```

### Modify Widget Appearance

Edit `moodle_deployer.py`, method `inject_agent_widget()`:

```python
# Change widget position
style="position: fixed; bottom: 20px; left: 20px;"

# Change widget color
background: linear-gradient(135deg, #059669, #0891b2);

# Change widget size
width: 500px; max-height: 700px;
```

## API Reference

### MoodleAPI Class

```python
api = MoodleAPI(url, token)

# Call any Moodle web service function
result = api.call('function_name', param1=value1, param2=value2)

# Upload file
file_info = api.upload_file(filepath, context_id)

# Get course modules
modules = api.get_course_modules(course_id)

# Create page
page = api.create_page(course_id, section, name, content)

# Create assignment
assignment = api.create_assignment(course_id, section, name, intro, duedate)

# Create resource
resource = api.create_resource(course_id, section, name, files)

# Import questions
result = api.import_questions(course_id, category_id, gift_content, category_name)
```

### MoodleDeployer Class

```python
deployer = MoodleDeployer(moodle_url, token, course_id)

# Deploy components
deployer.deploy_quizzes()
deployer.deploy_lessons()
deployer.deploy_resources()
deployer.deploy_assignments()

# Deploy everything
deployer.deploy_all()
```

## Maintenance

### Update Content

To update course content after initial deployment:

1. Regenerate specific week:
   ```python
   # In course_content_generator.py
   generator.generate_quiz(COURSE_STRUCTURE[0])  # Week 1
   ```

2. Re-deploy specific component:
   ```bash
   python3 moodle_deployer.py --deploy-lessons
   ```

### Monitor Agent Usage

Check agent logs:
```bash
sudo journalctl -u vietnamese-tutor-agent -f
```

View agent metrics:
```bash
curl http://localhost:5001/health
```

## Support

- **Moodle Documentation**: https://docs.moodle.org/en/Web_services
- **Vietnamese Tutor Agent**: `VIETNAMESE_AGENT_INTEGRATION.md`
- **Content Generator**: `EPIC_CONTENT_GENERATION.md`
- **Course Structure**: `lesson_plan.md`

## Success Metrics

After deployment, you should have:

- ✅ 120 questions in Question Bank (8 weeks × 15 questions)
- ✅ 8 interactive lesson pages with Agent widgets
- ✅ 8 flashcard files for Anki import
- ✅ 8 dialogue practice files
- ✅ 7 assignments with detailed rubrics
- ✅ Functional Vietnamese Tutor Agent integration
- ✅ Mobile-responsive design
- ✅ Professional, minimal-emoji interface

## Next Steps

1. **Train Teachers**: Familiarize instructors with Agent widget
2. **Student Onboarding**: Create welcome video showing features
3. **Monitor Usage**: Track agent interactions and quiz completions
4. **Gather Feedback**: Collect student feedback after Week 1
5. **Iterate**: Update content based on usage data

---

**Generated**: November 5, 2025  
**Version**: 1.0  
**Course**: Vietnamese Language Course (ID: 10)  
**Platform**: Moodle 4.x
