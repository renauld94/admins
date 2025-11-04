# 🎓 Moodle Integration Guide - AI Conversation Partner

## 📋 Quick Start

### Step 1: Access Moodle Course
1. Navigate to: https://moodle.simondatalab.de
2. Log in as admin or teacher
3. Go to **Vietnamese for Beginners** course
   - Direct link: https://moodle.simondatalab.de/course/view.php?id=10

### Step 2: Add AI Conversation Partner

#### Option A: Add as Label (Embedded on Course Page)
1. Click **"Turn editing on"** (top right)
2. In the section where you want to add it, click **"Add an activity or resource"**
3. Select **"Label"**
4. Click **"HTML"** button in the editor to view source code
5. Copy the iframe code from `MOODLE_IFRAME_CODE.html`
6. Paste into the HTML editor
7. Click **"Save and return to course"**

#### Option B: Add as Page (Dedicated Page)
1. Click **"Turn editing on"**
2. Click **"Add an activity or resource"**
3. Select **"Page"**
4. Name: "AI Conversation Practice"
5. Description: "Practice Vietnamese with AI tutor"
6. In **Page content**, click **"HTML"** to edit source
7. Paste the iframe code
8. **Display** → Select "Embedded" or "New window"
9. Click **"Save and display"**

### Step 3: Test the Integration
1. Turn editing OFF
2. Scroll to the AI Conversation Partner section
3. Verify:
   - [ ] Interface loads correctly
   - [ ] Scenario cards are visible
   - [ ] Click a scenario (e.g., "Coffee Shop")
   - [ ] Choose difficulty level
   - [ ] Type a message in Vietnamese
   - [ ] AI responds within 2-5 seconds
   - [ ] Feedback appears (vocabulary, grammar, cultural notes)

---

## 🔧 Customization Options

### Iframe Height Adjustment
If the interface is cut off, adjust the height:

```html
<!-- Default: 700px -->
<iframe src="..." style="height: 700px; ...">

<!-- Taller for more content -->
<iframe src="..." style="height: 850px; ...">

<!-- Shorter for compact view -->
<iframe src="..." style="height: 550px; ...">
```

### Color Theme Matching
Match the header gradient to your course theme:

```html
<!-- Default: Purple gradient -->
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

<!-- Blue gradient -->
background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);

<!-- Green gradient (matches success theme) -->
background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);

<!-- Red/Orange gradient -->
background: linear-gradient(135deg, #ff6a00 0%, #ee0979 100%);
```

### Responsive Design
The iframe is already responsive, but you can add mobile-specific adjustments:

```html
<style>
    @media (max-width: 768px) {
        .ai-conversation-wrapper iframe {
            height: 500px !important;
        }
    }
</style>
```

---

## 🎨 Interface Features

### Available Scenarios

| Scenario | Vietnamese Focus | Best For |
|----------|------------------|----------|
| ☕ Coffee Shop | Food & drink ordering | Beginners |
| 👋 Greetings | Basic introductions | Absolute beginners |
| 💼 Business Meeting | Formal language | Advanced learners |
| 🛍️ Shopping | Numbers, bargaining | Intermediate |
| 🍜 Restaurant | Menu navigation | Intermediate |

### Difficulty Levels

- **🟢 Beginner**: Simple vocabulary, slower AI responses, basic grammar
- **🟡 Intermediate**: Complex sentences, cultural context, idiomatic expressions
- **🔴 Advanced**: Natural conversation speed, advanced grammar, slang

### AI Feedback Types

1. **Vocabulary Highlighting**: Shows new words used in the conversation
2. **Grammar Feedback**: Corrects mistakes and suggests improvements
3. **Cultural Notes**: Explains Vietnamese customs and etiquette
4. **Confidence Score**: AI's confidence in understanding your message

---

## 📊 Student Usage Instructions

### Create a Student Guide (Optional)

Add this below the iframe or on a separate page:

```html
<div style="background: #e3f2fd; padding: 20px; border-radius: 8px; margin-top: 20px;">
    <h3>📖 How to Use the AI Conversation Partner</h3>
    
    <ol>
        <li><strong>Choose a Scenario</strong>: Click on one of the cards (Coffee Shop, Greetings, etc.)</li>
        <li><strong>Select Your Level</strong>: Pick Beginner, Intermediate, or Advanced</li>
        <li><strong>Start Chatting</strong>: Type in Vietnamese (or use Google Translate to help!)</li>
        <li><strong>Get Feedback</strong>: The AI will respond and give you tips</li>
        <li><strong>Practice Daily</strong>: Try to have at least one conversation per day!</li>
    </ol>
    
    <h4>💡 Pro Tips:</h4>
    <ul>
        <li>Don't worry about making mistakes - that's how you learn!</li>
        <li>Try different scenarios to practice varied vocabulary</li>
        <li>Start at Beginner level and work your way up</li>
        <li>Read the cultural notes - they're very helpful!</li>
        <li>Practice the same scenario multiple times to build confidence</li>
    </ul>
</div>
```

---

## 🔐 Privacy & Data Considerations

### What Gets Stored?
Currently: **Nothing is permanently stored**
- Conversations exist only during the active session
- Closing the browser clears all chat history
- No student data is sent to external services (runs on your server)

### Future Analytics (Service 8107)
When the Analytics Dashboard is deployed, we will track:
- Number of conversations per student
- Vocabulary progress
- Most practiced scenarios
- Time spent in conversation
- **Note**: All data stays on your Moodle server (10.0.0.104 and 10.0.0.110)

### GDPR Compliance
- ✅ Data is hosted on your servers (not third-party)
- ✅ No personal data is collected beyond Moodle login
- ✅ Students can request conversation history deletion (when analytics is enabled)
- ⚠️ Consider adding a privacy notice to the course page

---

## 🚀 Advanced Integration Ideas

### 1. Add to Multiple Course Sections

Place the AI partner in strategic locations:
- **Week 1**: Use "Greetings" scenario for ice-breaking
- **Week 3**: Add "Coffee Shop" after vocabulary lesson
- **Week 5**: Introduce "Restaurant" scenario
- **Week 8**: "Business Meeting" for advanced students

### 2. Create Assignments Around AI Practice

Example assignment:
```
Title: AI Conversation Challenge - Week 3
Instructions:
1. Complete at least 3 conversations using the "Coffee Shop" scenario
2. Try Beginner and Intermediate levels
3. Screenshot one conversation where you used at least 5 new vocabulary words
4. Submit your screenshot and write a short reflection (100 words):
   - What did you learn?
   - What was challenging?
   - What cultural notes did you find interesting?

Grading criteria:
- Completion of 3 conversations: 40%
- Use of new vocabulary: 30%
- Quality of reflection: 30%
```

### 3. Gamification Ideas

Create a "AI Practice Leaderboard" forum post:
- Track who uses the AI most frequently
- Award badges for:
  - 🏆 "Conversation Master" - 50 total conversations
  - 🌟 "Polyglot" - Used all 5 scenarios
  - 🔥 "Streak Champion" - 7 days of consecutive practice
  - 📈 "Level Up" - Completed conversations at all 3 difficulty levels

### 4. Peer Learning Activity

**Group Challenge**:
1. Divide class into teams of 3-4 students
2. Each team member practices a different scenario
3. They teach each other the vocabulary they learned
4. Teams present their favorite cultural note to the class

---

## 🐛 Troubleshooting

### Issue: Iframe Doesn't Load

**Check:**
1. Is the URL correct? `https://moodle.simondatalab.de/ai/conversation-practice.html`
2. Open the URL directly in a new tab - does it work?
3. Check browser console for errors (F12 → Console tab)
4. Verify nginx service is running: 
   ```bash
   ssh root@136.243.155.166 -p 2222 "systemctl status nginx"
   ```

### Issue: WebSocket Connection Failed

**Symptoms**: 
- "Connecting..." message doesn't disappear
- No AI responses to messages

**Solutions**:
1. Check if service is running:
   ```bash
   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 "ps aux | grep python3"
   ```
2. Verify health endpoint: https://moodle.simondatalab.de/ai/health
3. Restart service if needed:
   ```bash
   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110
   cd ~/vietnamese-ai/conversation
   ./deploy_conversation_service.sh
   ```

### Issue: Slow AI Responses

**Expected Response Time**: 2-5 seconds
**If > 10 seconds**:

1. Check VM resources:
   ```bash
   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 "top -bn1 | head -20"
   ```
2. Verify Ollama is running:
   ```bash
   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 "systemctl status ollama"
   ```
3. Consider switching to a smaller model if needed (contact admin)

### Issue: Interface Appears Blank

**Possible causes**:
1. Browser blocking iframe (check browser settings)
2. Adblocker interfering (whitelist moodle.simondatalab.de)
3. Old browser version (update to latest Chrome/Firefox)
4. JavaScript disabled (enable in browser settings)

---

## 📞 Support Contacts

### For Technical Issues
- **Service Health**: https://moodle.simondatalab.de/ai/health
- **Check Logs**: Contact system admin for log access

### For Content/Pedagogy Questions
- Review the scenario descriptions
- Check cultural notes in AI responses
- Consider adding custom scenarios (future feature)

---

## 🎯 Success Metrics

Track these to measure AI integration success:

### Engagement Metrics
- [ ] % of students who try the AI at least once
- [ ] Average conversations per student per week
- [ ] Most popular scenario
- [ ] Preferred difficulty level by week

### Learning Outcomes
- [ ] Vocabulary retention (pre/post tests)
- [ ] Student confidence in speaking Vietnamese (surveys)
- [ ] Participation in class discussions (before/after AI)

### Feedback Collection
Add a survey after 2 weeks:
1. How helpful was the AI conversation partner? (1-5)
2. Which scenario did you find most useful?
3. Did the AI feedback help you learn? (Y/N)
4. What features would you like to see added?
5. Would you recommend this to other language learners? (Y/N)

---

## 🔮 Coming Soon

### Service 8103: Pronunciation Coach
- **Feature**: Record your voice speaking Vietnamese
- **AI Analysis**: Phonetic accuracy scoring
- **Feedback**: Tone correction (very important in Vietnamese!)

### Service 8107: Analytics Dashboard
- **Student View**: Track your own progress
- **Teacher View**: Class-wide statistics
- **Insights**: Identify struggling students, popular topics

### Additional Scenarios
- 🏥 At the Doctor
- 🏨 Hotel Check-in
- 🚕 Taking a Taxi
- 📱 Phone Conversation
- 🎉 Family Gathering

---

## ✅ Integration Checklist

### Pre-Launch
- [ ] Test iframe loads correctly
- [ ] Verify all 5 scenarios work
- [ ] Test WebSocket connection
- [ ] Check on mobile devices
- [ ] Review with another teacher/admin

### Launch
- [ ] Add iframe to Moodle course
- [ ] Create student guide/instructions
- [ ] Announce to students (forum post, email)
- [ ] Add to course syllabus/schedule

### Post-Launch
- [ ] Monitor student usage first week
- [ ] Collect initial feedback
- [ ] Address any technical issues
- [ ] Share success stories with students

### Ongoing
- [ ] Weekly check of service health
- [ ] Monthly review of student engagement
- [ ] Quarterly feedback surveys
- [ ] Plan for new scenarios based on curriculum

---

**Last Updated**: November 4, 2025  
**Version**: 1.0  
**Service Status**: ✅ Operational
