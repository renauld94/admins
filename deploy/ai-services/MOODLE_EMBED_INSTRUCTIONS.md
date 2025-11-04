# Embedding AI Services in Moodle Course

## Course Information
- **Course Name:** Vietnamese for Beginners
- **Course URL:** https://moodle.simondatalab.de/course/view.php?id=10
- **Course ID:** 10

## Available AI Services

### 1. AI Conversation Partner
**URL:** https://moodle.simondatalab.de/ai/conversation-practice.html
**Features:**
- Real-time AI conversations in Vietnamese
- Text-to-speech (audio responses)
- Speech-to-text (browser-based)
- Multiple conversation scenarios
- Professional design

### 2. Pronunciation Coach (NEW)
**URL:** https://moodle.simondatalab.de/pronunciation/
**Features:**
- Vietnamese tone analysis (6 tones)
- Pitch contour graphs
- Accuracy scoring (0-100)
- Real-time feedback
- Visual pitch comparison

## Embedding Instructions

### Method 1: Using Label Activity (Recommended)

1. **Login to Moodle**
   - Go to https://moodle.simondatalab.de
   - Login as admin/instructor

2. **Edit Course**
   - Navigate to course: https://moodle.simondatalab.de/course/view.php?id=10
   - Click "Turn editing on" (top right)

3. **Add AI Conversation Partner**
   - In the desired section, click "Add an activity or resource"
   - Select "Label"
   - Click "Add"
   - In the text editor, click "</>" (Source code button)
   - Paste this code:

```html
<div style="border: 2px solid #0066cc; border-radius: 12px; overflow: hidden; margin: 20px 0;">
    <div style="background: linear-gradient(135deg, #1a1a2e, #16213e); padding: 20px; color: white;">
        <h3 style="margin: 0 0 10px 0; color: #00bfa5;">🤖 AI Conversation Partner</h3>
        <p style="margin: 0; color: #b0b0b0;">Practice Vietnamese conversations with AI feedback</p>
    </div>
    <iframe 
        src="https://moodle.simondatalab.de/ai/conversation-practice.html" 
        style="width: 100%; height: 800px; border: none; display: block;"
        title="AI Conversation Practice">
    </iframe>
</div>
```

   - Click "</>" again to exit source mode
   - Click "Save and return to course"

4. **Add Pronunciation Coach**
   - In the next section, click "Add an activity or resource"
   - Select "Label"
   - Click "Add"
   - In the text editor, click "</>" (Source code button)
   - Paste this code:

```html
<div style="border: 2px solid #00bfa5; border-radius: 12px; overflow: hidden; margin: 20px 0;">
    <div style="background: linear-gradient(135deg, #1a1a2e, #16213e); padding: 20px; color: white;">
        <h3 style="margin: 0 0 10px 0; color: #00bfa5;">🎤 Pronunciation Coach</h3>
        <p style="margin: 0; color: #b0b0b0;">Master Vietnamese tones with AI analysis and pitch graphs</p>
    </div>
    <iframe 
        src="https://moodle.simondatalab.de/pronunciation/" 
        style="width: 100%; height: 1000px; border: none; display: block;"
        title="Pronunciation Coach">
    </iframe>
</div>
```

   - Click "</>" again to exit source mode
   - Click "Save and return to course"

### Method 2: Using Page Activity

1. **Add Page Activity**
   - Click "Add an activity or resource"
   - Select "Page"
   - Click "Add"

2. **Configure Page**
   - **Name:** "AI Practice Tools"
   - **Description:** "Interactive AI-powered tools for Vietnamese learning"
   - **Page content:** (Click "</>" for source mode, then paste):

```html
<h2>AI-Powered Vietnamese Learning Tools</h2>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">
    <div style="border: 2px solid #0066cc; border-radius: 8px; padding: 20px; background: #f5f5f5;">
        <h3 style="color: #0066cc;">🤖 Conversation Partner</h3>
        <p>Practice real conversations with AI</p>
        <ul>
            <li>Restaurant ordering</li>
            <li>Shopping scenarios</li>
            <li>Travel conversations</li>
            <li>Audio responses</li>
        </ul>
        <a href="https://moodle.simondatalab.de/ai/conversation-practice.html" target="_blank" 
           style="display: inline-block; background: #0066cc; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin-top: 10px;">
            Open Tool
        </a>
    </div>
    
    <div style="border: 2px solid #00bfa5; border-radius: 8px; padding: 20px; background: #f5f5f5;">
        <h3 style="color: #00bfa5;">🎤 Pronunciation Coach</h3>
        <p>Master Vietnamese tones with AI analysis</p>
        <ul>
            <li>6 tone practice</li>
            <li>Pitch graphs</li>
            <li>Accuracy scoring</li>
            <li>Real-time feedback</li>
        </ul>
        <a href="https://moodle.simondatalab.de/pronunciation/" target="_blank" 
           style="display: inline-block; background: #00bfa5; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin-top: 10px;">
            Open Tool
        </a>
    </div>
</div>

<hr>

<h3>Or use the tools directly below:</h3>

<div style="border: 2px solid #0066cc; border-radius: 12px; overflow: hidden; margin: 20px 0;">
    <iframe 
        src="https://moodle.simondatalab.de/ai/conversation-practice.html" 
        style="width: 100%; height: 800px; border: none; display: block;">
    </iframe>
</div>

<div style="border: 2px solid #00bfa5; border-radius: 12px; overflow: hidden; margin: 20px 0;">
    <iframe 
        src="https://moodle.simondatalab.de/pronunciation/" 
        style="width: 100%; height: 1000px; border: none; display: block;">
    </iframe>
</div>
```

   - Click "Save and display"

### Method 3: External Tool (LTI)

If you want to track student usage:

1. **Add External Tool**
   - Click "Add an activity or resource"
   - Select "External tool"
   - Click "Add"

2. **Configure**
   - **Activity name:** "AI Conversation Practice"
   - **Tool URL:** https://moodle.simondatalab.de/ai/conversation-practice.html
   - **Launch container:** Embed
   - Save

## Testing

After embedding:

1. **Turn editing off**
2. **Test as student:**
   - Login as test student
   - Navigate to course
   - Interact with embedded tools
   - Verify audio playback works
   - Test microphone recording

3. **Mobile testing:**
   - Open on mobile device
   - Check responsive design
   - Test touch interactions

## Troubleshooting

### Iframe not displaying
- Check browser console for errors
- Verify URLs are accessible
- Check Content Security Policy settings

### Audio not working
- Ensure HTTPS is used (required for microphone)
- Check browser permissions
- Test in different browsers

### Service not responding
- Check service health: https://moodle.simondatalab.de/ai/health
- Check Pronunciation Coach: https://moodle.simondatalab.de/pronunciation/health
- Verify nginx proxy is running
- Check VM services are active

## Next Steps

After embedding both services:

1. **Deploy remaining services:**
   - Grammar Helper (Port 8101)
   - Vocabulary Builder (Port 8102)
   - Cultural Context (Port 8104)
   - Reading Assistant (Port 8105)
   - Writing Practice (Port 8106)
   - Analytics Dashboard (Port 8107)

2. **Create navigation page** linking all 8 services

3. **Add analytics** to track student progress

4. **Customize** services based on student feedback
