# 🚀 ClickUp Job Search Tracker - Setup Guide

## 📋 **What You'll Get**

A complete ClickUp workspace to track:
- ✅ **Job Applications** (status, fit score, follow-ups)
- ✅ **Recruiter Network** (connections, conversations, quality)
- ✅ **Interview Pipeline** (prep, notes, results)
- ✅ **Offers & Negotiations** (compensation, deadlines)
- ✅ **Target Companies** (research, contacts)

---

## 🎯 **Quick Start** (10 Minutes)

### **Step 1: Get ClickUp API Key** (3 min)

1. Go to: https://app.clickup.com/
2. Click your **avatar** (top-right) → **Settings**
3. Click **Apps** in left sidebar
4. Scroll to **API Token** section
5. Click **Generate** → Copy your API key
6. Save it somewhere safe!

### **Step 2: Add API Key to .env File** (2 min)

```bash
cd /home/simon/Learning-Management-System-Academy/linkedin-automation

# Open .env file
nano .env

# Add this line (replace with your actual key):
CLICKUP_API_KEY=pk_123456789_ABCDEFGHIJKLMNOPQRSTUVWXYZ
```

**Save:** `Ctrl+O`, `Enter`, `Ctrl+X`

### **Step 3: Run Setup Script** (5 min)

```bash
# Make sure you're in the linkedin-automation folder
cd /home/simon/Learning-Management-System-Academy/linkedin-automation

# Run setup
python3 clickup_job_tracker.py --setup
```

**This will:**
- ✅ Create "Job Search Tracker" space in ClickUp
- ✅ Create 5 organized lists (Applications, Recruiters, Interviews, Offers, Companies)
- ✅ Set up custom fields for tracking
- ✅ Save configuration to .env file

### **Step 4: Sync Your Existing Jobs** (2 min)

```bash
# Sync jobs from your automation runs
python3 clickup_job_tracker.py --sync
```

**This imports all jobs you found with the automation script!**

---

## 📱 **Using ClickUp for Job Search**

### **Access Your Tracker**

After setup, go to: https://app.clickup.com/

You'll see **"Job Search Tracker"** space with 5 lists.

---

## 📝 **List 1: Job Applications**

**Track every job you apply to!**

### **Custom Fields:**
- **Company**: Company name
- **Job URL**: Link to job posting
- **Fit Score**: 1-10 (how well you match)
- **Salary Range**: SGD 120-180K / AUD 150-200K
- **Location**: Singapore / Sydney / Remote
- **Applied Date**: When you applied
- **Last Contact**: When you last heard from them
- **Next Action**: What to do next
- **Recruiter**: Who to contact
- **Status**: Applied → Screening → Technical → Final → Offer

### **How to Use:**

**Add New Application (Manual):**
1. Click **"+ Task"** in "📝 Job Applications" list
2. Title: `Lead Data Engineer @ Grab`
3. Fill in custom fields
4. Add tags: `Singapore`, `Score:9`, `Remote`
5. Set due date: 7 days (follow-up reminder)
6. Set priority: 
   - Urgent (red) = Fit score 9-10
   - High (yellow) = Fit score 7-8
   - Normal (white) = Fit score 5-6

**Description Template:**
```
**Company:** Grab
**Title:** Lead Data Engineer
**Location:** Singapore
**Fit Score:** 9/10

**Job URL:** https://grab.careers/job/...

**Key Requirements:**
- Python, PostgreSQL, Airflow ✅
- 8+ years experience ✅
- AWS/Cloud experience ✅
- Data quality focus ✅

**Why I'm a Good Fit:**
- 10+ years data engineering
- 500M+ records processed monthly
- 99.9% uptime & accuracy
- Strong QA/testing background

**Status:** Applied
**Applied Date:** 2025-11-05

**Next Actions:**
- [ ] Research Grab's data platform
- [ ] Connect with recruiter on LinkedIn
- [ ] Follow up in 3 days if no response
- [ ] Prepare for technical interview
```

---

## 🤝 **List 2: Recruiter Network**

**Track all recruiter connections!**

### **Custom Fields:**
- **Company**: Recruiter's company (e.g., Robert Half, Grab)
- **LinkedIn URL**: Profile link
- **Email**: Contact email
- **Phone**: Phone number
- **Connection Date**: When you connected
- **Last Contact**: Last message/call date
- **Jobs Shared**: Number of jobs they sent you
- **Response Rate**: How quickly they respond
- **Quality**: Hot Lead / Active / Warm / Cold

### **How to Use:**

**Add New Recruiter:**
1. Click **"+ Task"** in "🤝 Recruiter Network"
2. Title: `🤝 Jane Smith @ Robert Half Singapore`
3. Fill LinkedIn URL, email, phone
4. Set Quality: "Hot Lead" if they're responsive
5. Track every job they share

**Description Template:**
```
**Company:** Robert Half Singapore
**Title:** Technical Recruiter - Data & Analytics
**LinkedIn:** https://linkedin.com/in/janesmith
**Email:** jane.smith@roberthalf.com
**Phone:** +65 1234 5678

**Connection Date:** 2025-11-05
**Status:** Active

**Conversation History:**
- 2025-11-05: Connected on LinkedIn
- 2025-11-05: Sent thank you message + resume
- 2025-11-06: She responded! Shared 3 data engineer roles
- 2025-11-07: Applied to 2 of the 3 roles

**Jobs Shared:**
1. Lead Data Engineer @ Grab (Applied ✅)
2. Senior Data Engineer @ Sea Group (Applied ✅)
3. Data Platform Engineer @ Shopee (Saved for later)

**Next Actions:**
- [ ] Weekly check-in every Friday
- [ ] Ask about new roles
- [ ] Send thank you after interviews
```

---

## 🎯 **List 3: Interview Pipeline**

**Prepare for every interview!**

### **Custom Fields:**
- **Company**: Company name
- **Round**: Phone Screen / Technical / Final
- **Interview Date**: Scheduled date/time
- **Interview Type**: Phone / Technical / System Design / Behavioral / Final
- **Interviewer**: Name & title
- **Prep Status**: Not Started / In Progress / Ready
- **Result**: Pending / Passed / Rejected / Next Round

### **How to Use:**

**Add Interview:**
1. Click **"+ Task"** in "🎯 Interview Pipeline"
2. Title: `📞 Phone Screen: Grab - Lead Data Engineer`
3. Set interview date/time
4. Add prep checklist in description

**Description Template:**
```
**Company:** Grab
**Role:** Lead Data Engineer
**Round:** Phone Screen (Round 1 of 4)
**Date:** 2025-11-12 at 10:00 AM SGT
**Duration:** 30 minutes

**Interviewer:** Sarah Lee, Engineering Manager

**Interview Type:** Behavioral + Technical Overview

**Prep Checklist:**
- [ ] Research Grab's data platform (check tech blog)
- [ ] Review job description 3 times
- [ ] Prepare STAR stories (3-5 examples)
- [ ] Practice talking points:
  - 500M+ healthcare records
  - 99.9% uptime achievement
  - $150K cost savings
  - HIPAA compliance expertise
- [ ] Prepare questions to ask (3-5)
- [ ] Test Zoom/call setup

**Questions to Ask:**
1. What does success look like in first 6 months?
2. How does data team collaborate with product/eng?
3. What's the biggest data quality challenge now?
4. What's the interview process timeline?
5. Team size and structure?

**Key Points to Highlight:**
- Data quality obsession (99.9% accuracy)
- Led 50+ person teams
- Healthcare data compliance (HIPAA/GDPR)
- Infrastructure expertise (Proxmox, K8s)
- QA + Data Engineering hybrid (rare!)

**Result:** [Update after interview]

**Follow-Up:**
- [ ] Send thank you email within 24 hours
- [ ] Connect with interviewer on LinkedIn
- [ ] Ask about next steps/timeline
```

---

## 💼 **List 4: Offers & Negotiations**

**Track offers and negotiate!**

### **When You Get an Offer:**

1. Create task: `💼 OFFER: Lead Data Engineer @ Grab`
2. Add all offer details in description
3. Set due date = offer expiration date
4. Track negotiation conversations

**Description Template:**
```
**Company:** Grab
**Role:** Lead Data Engineer
**Offer Date:** 2025-11-20
**Expiration:** 2025-11-27 (7 days)

**BASE OFFER:**
- Base Salary: SGD 150,000/year
- Bonus: 10% (SGD 15,000)
- Equity: 5,000 RSUs (4-year vest)
- Total Comp: ~SGD 180,000

**BENEFITS:**
- Health insurance (full coverage)
- 18 days vacation
- Remote work: 2 days/week
- Visa sponsorship: YES ✅
- Relocation: SGD 5,000 package

**MY TARGET:**
- Base Salary: SGD 165,000 (ask for 10% more)
- Bonus: 15% (SGD 24,750)
- Equity: 7,500 RSUs
- Target Total: ~SGD 210,000

**NEGOTIATION STRATEGY:**
1. Thank them enthusiastically
2. Ask for 2-3 days to review
3. Research market rates (Levels.fyi)
4. Prepare counter-offer
5. Negotiate over phone (not email!)

**LEVERAGE:**
- Other offers in pipeline: [Yes/No]
- Competing offer from: [Company if any]
- Unique skills: Data + QA + Healthcare compliance

**COUNTER-OFFER SCRIPT:**
"Thank you for the offer! I'm very excited about Grab.
Based on my 10+ years experience, healthcare data expertise,
and market research, I was hoping for SGD 165K base.
Can we explore that?"

**DECISION CRITERIA:**
- [ ] Compensation meets target
- [ ] Visa/relocation support confirmed
- [ ] Team culture fit (based on interviews)
- [ ] Growth opportunities clear
- [ ] Work-life balance acceptable

**DEADLINE:** 2025-11-27

**Next Actions:**
- [ ] Send thank you email
- [ ] Research market rates
- [ ] Prepare counter-offer
- [ ] Schedule negotiation call
- [ ] Make final decision
```

---

## 🏢 **List 5: Target Companies**

**Research companies before applying!**

### **How to Use:**

**Add Target Company:**
1. Click **"+ Task"** in "🏢 Target Companies"
2. Title: `🏢 RESEARCH: Grab Singapore`
3. Add research notes
4. Track when you apply

**Description Template:**
```
**Company:** Grab
**Location:** Singapore
**Industry:** Super-app (Transport, Food, Payments)
**Size:** 10,000+ employees
**Stage:** Public (NASDAQ: GRAB)

**WHY GOOD FIT:**
- Massive data scale (similar to my experience)
- QA critical for payments/rides/food
- Regional leader in SEA
- Strong engineering culture

**TECH STACK:**
- Languages: Go, Python, Java
- Data: Kafka, Airflow, Spark, Flink
- Cloud: AWS
- Infrastructure: Kubernetes, Docker

**RECENT NEWS:**
- Q3 2024: Revenue up 17% YoY
- Expanding in Vietnam (my network!)
- Investing in AI/ML for fraud detection

**KEY CONTACTS:**
- Recruiter: Jane Smith (Connected ✅)
- Engineering Manager: John Doe (Target to connect)
- Data Team Lead: Sarah Lee (Found on LinkedIn)

**OPEN ROLES:**
- [ ] Lead Data Engineer (Score: 9/10) - APPLIED ✅
- [ ] Senior Data Engineer (Score: 8/10) - Saved
- [ ] QA Engineer - Data Platform (Score: 10/10) - Apply next!

**APPLICATION STRATEGY:**
1. Apply via career page (faster than LinkedIn)
2. Connect with recruiter same day
3. Reference my ADA experience (similar scale)
4. Highlight Southeast Asia experience

**RESEARCH LINKS:**
- Career page: https://grab.careers/
- Tech blog: https://engineering.grab.com/
- LinkedIn: https://linkedin.com/company/grab
- Glassdoor: 4.1/5 stars

**Status:** Researched → Applied → [Update after applying]
```

---

## 📊 **Weekly Job Search Report**

**Get weekly metrics automatically!**

```bash
python3 clickup_job_tracker.py --report
```

**Report includes:**
- Total applications
- Applications by status (Applied, Screening, Interview, Offer, Rejected)
- High-fit jobs (score 8+)
- Pending actions (overdue follow-ups)
- Recruiter connections this week

---

## 🔄 **Daily/Weekly Workflow**

### **DAILY** (15 min - Morning)

1. **Check ClickUp**:
   - Any tasks due today?
   - Any interviews scheduled?
   - Any follow-ups needed?

2. **Apply to New Jobs**:
   - Find 5-10 jobs on LinkedIn
   - Create ClickUp task for each application
   - Apply immediately (Easy Apply)
   - Update task status to "Applied"

3. **Recruiter Follow-Ups**:
   - Check "🤝 Recruiter Network" list
   - Send weekly check-in to active recruiters
   - Update "Last Contact" date

### **WEEKLY** (Sunday Evening - 30 min)

1. **Review Week**:
   ```bash
   python3 clickup_job_tracker.py --report
   ```

2. **Update All Tasks**:
   - Mark completed interviews
   - Update application statuses
   - Archive rejected applications

3. **Plan Next Week**:
   - Set goals (e.g., 20 applications, 5 recruiter connections)
   - Schedule interview prep time
   - Identify target companies

### **MONTHLY** (End of Month - 1 hour)

1. **Generate Report**:
   - Total applications: ___
   - Phone screens: ___
   - Technical interviews: ___
   - Offers: ___

2. **Analyze & Adjust**:
   - Which companies respond most?
   - Which recruiters are best?
   - What's my conversion rate?
   - What's working? What's not?

3. **Update Strategy**:
   - Focus on high-response companies
   - Double down on hot recruiters
   - Refine resume/cover letter

---

## 🎯 **Success Metrics to Track**

### **Week 1** (Nov 5-11)
- Applications: 20
- Recruiters: 10
- Phone Screens: 3

### **Week 2** (Nov 12-18)
- Applications: 15
- Recruiters: 5
- Phone Screens: 5
- Technical Interviews: 2

### **Week 3** (Nov 19-25)
- Applications: 10
- Phone Screens: 3
- Technical Interviews: 3
- Final Rounds: 1

### **Week 4** (Nov 26-Dec 2)
- Applications: 5
- Technical Interviews: 2
- Final Rounds: 2
- **OFFERS: 1-2** 🎉

---

## 📱 **Mobile App**

**ClickUp has excellent mobile apps!**

- iOS: https://apps.apple.com/app/clickup/id1067457368
- Android: https://play.google.com/store/apps/details?id=com.clickup.app

**Use mobile app to:**
- Update task status on-the-go
- Add notes after interviews
- Set reminders for follow-ups
- Check upcoming tasks

---

## 🆘 **Troubleshooting**

### **Setup Failed**

```bash
# Check if API key is correct
cat .env | grep CLICKUP_API_KEY

# Try setup again
python3 clickup_job_tracker.py --setup
```

### **Sync Not Working**

```bash
# Check if jobs files exist
ls -la outputs/jobs/

# Manually specify file
python3 clickup_job_tracker.py --sync --jobs-file outputs/jobs/batch_jobs_20251105_153120_all.json
```

### **Can't Access ClickUp**

1. Make sure you're logged in: https://app.clickup.com/login
2. Check your workspace dropdown (top-left)
3. Find "Job Search Tracker" space

---

## 💡 **Pro Tips**

### **1. Use Templates**

Create task templates for:
- Job applications
- Recruiter first messages
- Interview prep checklists

### **2. Set Automations**

ClickUp can auto-update tasks:
- When status changes → Send notification
- When due date approaches → Create reminder
- When task completed → Move to archive

### **3. Use Time Tracking**

Track time spent on:
- Job applications (aim for 15 min each)
- Interview prep (2-3 hours per interview)
- Recruiter outreach (5 min per connection)

### **4. Weekly Reviews**

Every Sunday:
- Review completed tasks
- Celebrate wins! 🎉
- Adjust strategy for next week

---

## 🎉 **You're All Set!**

Your ClickUp job search tracker is ready!

**Next Steps:**
1. ✅ Run setup (if not done): `python3 clickup_job_tracker.py --setup`
2. ✅ Sync existing jobs: `python3 clickup_job_tracker.py --sync`
3. ✅ Apply to 10 jobs today
4. ✅ Add them to ClickUp
5. ✅ Connect with 5 recruiters
6. ✅ Track everything!

**Goal:** 50 applications + 2 offers by December 1! 💪

**Let's go! 🚀**
