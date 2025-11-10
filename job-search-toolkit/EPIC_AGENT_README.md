# 🚀 EPIC Job Search Agent - AI-Powered Job Search Orchestrator

**Version**: 1.0 EPIC  
**Author**: Simon Renauld  
**Created**: November 9, 2025  
**Status**: Production Ready

---

## 📊 Overview

EPIC Job Search Agent is a comprehensive, AI-powered automation system that coordinates all aspects of your job search:

✅ **Intelligent Job Discovery** - Finds and scores opportunities against your profile  
✅ **LinkedIn Automation** - Connects with hiring managers, recruiters, and peers  
✅ **Smart Application Generation** - Creates tailored resume + cover letter packages  
✅ **Relationship Management** - Tracks interactions and schedules follow-ups  
✅ **Real-time Analytics** - Dashboards showing applications, responses, interviews, offers  
✅ **Automated Workflows** - Daily + weekly automation via cron jobs  

---

## 🎯 What It Does

### 1. **Daily Workflow** (30-45 minutes automated)
- 🔍 Discovers 50+ job opportunities from target companies
- 🎯 Scores each job 0-100 based on skill match, salary, location, culture
- 📋 Generates top 5 applications with tailored resume + cover letters
- 👥 Connects with 3-5 hiring managers at target companies
- 💬 Sends personalized LinkedIn messages
- 📊 Tracks and records all metrics

### 2. **Weekly Workflow** (Analysis + insights)
- 📈 Aggregates weekly metrics (applications, responses, interviews, offers)
- 🤝 Reviews pending follow-ups and schedules next actions
- 📊 Generates comprehensive analytics report
- 🎓 Provides insights on response rates, conversion funnels, salary trends

### 3. **Real-time Analytics**
- 📋 **Pipeline Status**: Applied → Responded → Interview → Offer
- 📊 **Conversion Rates**: Response %, Interview %, Offer %
- ⏱️ **Timing**: Average response time, time-to-offer prediction
- 💰 **Salary**: Offer pipeline, market rates by role/company
- 🤝 **Network**: Total contacts, by type, interactions, follow-ups

---

## 🏗️ Architecture

```
EPIC Job Search Agent
├── epic_job_search_agent.py          # Main orchestrator (job discovery + scoring)
├── advanced_job_scorer.py            # AI job relevance scoring engine
├── linkedin_contact_orchestrator.py  # LinkedIn automation + outreach
├── networking_crm.py                 # Contact tracking + relationship management
├── job_search_dashboard.py           # Analytics + metrics visualization
├── run_daily_job_search.sh           # Daily automation (cron-friendly)
├── run_weekly_job_search.sh          # Weekly analysis (cron-friendly)
└── setup_agent.sh                    # Setup & initialization

Data Layer
├── data/job_search.db                # Jobs, applications, tracking
├── data/linkedin_contacts.db         # LinkedIn profiles, outreach logs
├── data/networking_crm.db            # Contacts, interactions, follow-ups
└── data/job_search_metrics.db        # Daily/weekly metrics

Config Layer
└── config/profile.json               # Your profile (skills, roles, salary)

Output Layer
├── outputs/logs/                     # Daily logs (agent_YYYYMMDD.log)
├── outputs/reports/                  # Daily/weekly reports
└── outputs/resumes/                  # Generated tailored resumes
```

---

## 🚀 Quick Start

### 1. Initialize Setup

```bash
cd /home/simon/Learning-Management-System-Academy/job-search-toolkit
bash setup_agent.sh
```

This will:
- ✅ Create directories
- ✅ Initialize all databases
- ✅ Generate config files
- ✅ Make scripts executable

### 2. Configure Your Profile

Edit `config/profile.json`:
```bash
nano config/profile.json
```

Update with your information:
- Skills, experience, certifications
- Target roles, locations, salary
- LinkedIn, email, portfolio URLs

### 3. Run Manual Test

```bash
# Test the daily workflow
python3 epic_job_search_agent.py daily

# Check status
python3 epic_job_search_agent.py status

# View analytics
python3 job_search_dashboard.py full
```

### 4. Enable Automation (Cron)

```bash
# Open crontab editor
crontab -e

# Add these lines:

# Daily at 7 AM - job search + LinkedIn outreach
0 7 * * * cd /home/simon/Learning-Management-System-Academy/job-search-toolkit && ./run_daily_job_search.sh

# Weekly Sunday 6 PM - analytics + follow-ups
0 18 * * 0 cd /home/simon/Learning-Management-System-Academy/job-search-toolkit && ./run_weekly_job_search.sh
```

---

## 📖 Component Guide

### 1. Main Agent: `epic_job_search_agent.py`

Orchestrates entire job search workflow.

**Features:**
- Job discovery from multiple sources
- Intelligent relevance scoring
- Application package generation
- Workflow automation

**Usage:**
```bash
python3 epic_job_search_agent.py daily       # Daily workflow
python3 epic_job_search_agent.py weekly      # Weekly workflow
python3 epic_job_search_agent.py status      # Show status
```

**Database**: `data/job_search.db`

---

### 2. Job Scorer: `advanced_job_scorer.py`

AI-powered job relevance scoring (0-100).

**Scoring Breakdown:**
- 🎯 **Skills Match** (30 pts): Keyword matching + skill level
- 📚 **Experience Level** (20 pts): Years match + seniority alignment
- 💰 **Salary Fit** (15 pts): Within your range?
- 📍 **Location** (10 pts): Remote? Target location?
- 🏢 **Company Culture** (15 pts): Values aligned?
- 📈 **Growth** (10 pts): Learning + leadership opportunities

**Red Flags Detected:**
- Conflicting requirements
- Unrealistic deadlines
- No testing culture
- Outdated tech stack
- High turnover indicators

**Usage:**
```bash
python3 advanced_job_scorer.py score \
  --title "Lead Data Engineer" \
  --company "Shopee" \
  --location "Singapore" \
  --description "job_description.txt"
```

---

### 3. LinkedIn Orchestrator: `linkedin_contact_orchestrator.py`

Intelligent LinkedIn connection + outreach automation.

**Capabilities:**
- Identify hiring managers, recruiters, peers
- Generate personalized messages
- Respect rate limits (30 connections/day)
- Track connection success
- Build relationship momentum

**Message Templates:**
- Hiring Manager: Professional, role-focused
- Recruiter: Highlight achievements
- Peer Engineer: Technical, collaborative

**Usage:**
```bash
# Campaign outreach
python3 linkedin_contact_orchestrator.py campaign \
  --companies "Shopee,Grab,Atlassian"

# Identify contacts
python3 linkedin_contact_orchestrator.py identify \
  --company "Shopee"
```

**Database**: `data/linkedin_contacts.db`

---

### 4. Networking CRM: `networking_crm.py`

Comprehensive contact relationship management.

**Tracks:**
- Contact information (email, phone, LinkedIn)
- Interaction history (messages, calls, interviews)
- Relationship quality score (0-100)
- Opportunity referrals
- Follow-up scheduling

**Contact Types:**
- Recruiter
- Hiring Manager
- Peer Engineer
- Referral Source
- Company Contact

**Usage:**
```bash
# Add contact
python3 networking_crm.py add-contact \
  --name "Jane Doe" \
  --title "Recruiter" \
  --company "Shopee"

# View pending follow-ups
python3 networking_crm.py pending-followups

# View network statistics
python3 networking_crm.py report
```

**Database**: `data/networking_crm.db`

---

### 5. Analytics Dashboard: `job_search_dashboard.py`

Real-time metrics and performance analytics.

**Metrics Tracked:**
- 📋 Applications sent (by role, company, date)
- 📊 Response rate (responses / applications)
- 🎯 Interview conversion (interviews / responses)
- 💼 Offer rate (offers / interviews)
- ⏱️ Average response time (days)
- 💰 Salary pipeline (offers, ranges, trends)
- 🤝 Network reach (connections, interactions)

**Usage:**
```bash
# Daily metrics
python3 job_search_dashboard.py daily

# Weekly report
python3 job_search_dashboard.py weekly

# Application pipeline
python3 job_search_dashboard.py pipeline

# Full dashboard
python3 job_search_dashboard.py full

# Record metrics
python3 job_search_dashboard.py record --apps 5 --connections 3
```

**Database**: `data/job_search_metrics.db`

---

## 📅 Automation Schedule

### Daily (7:00 AM)
```bash
./run_daily_job_search.sh
```

**What it does:**
1. Searches for new opportunities
2. Scores and prioritizes (top 5)
3. Generates application packages
4. LinkedIn outreach (hiring managers)
5. Records metrics

**Output**: `outputs/reports/daily_report_YYYYMMDD_HHMMSS.txt`

### Weekly (Sunday 6:00 PM)
```bash
./run_weekly_job_search.sh
```

**What it does:**
1. Aggregates weekly metrics
2. Reviews pending follow-ups
3. Generates insights
4. Updates CRM
5. Comprehensive analysis report

**Output**: `outputs/reports/weekly_report_YYYYMMDD_HHMMSS.txt`

---

## 📊 Expected Results (4 weeks)

| Metric | Target | Your System |
|--------|--------|------------|
| **Applications/week** | 12-15 | ✅ Auto-generated |
| **Response rate** | 20%+ | ✅ Tracked & optimized |
| **LinkedIn connections** | 50+ | ✅ Auto-connect |
| **Interviews/week** | 3-5 (week 2+) | ✅ Tracked |
| **Total offers** | 2-3 | ✅ Pipeline tracked |
| **Time invested** | 2-3 hrs/day | ✅ 30-45 min automated |

**Conversion Funnel:**
```
100 Applications
   ↓ (20-30%)
20-30 Responses
   ↓ (30-40%)
6-12 Interviews
   ↓ (20-30%)
1-4 Offers
```

---

## 🔧 Configuration

### Profile Config (`config/profile.json`)

```json
{
  "name": "Simon Renauld",
  "title": "Data Engineer & QA Automation",
  "years_experience": 8,
  "current_level": "senior",
  "remote_preference": true,
  "core_skills": {
    "languages": ["Python", "SQL"],
    "platforms": ["Airflow", "Spark"],
    "cloud": ["AWS", "GCP"]
  },
  "target_roles": [
    "Lead Data Engineer",
    "Analytics Lead"
  ],
  "target_locations": [
    "Remote",
    "Singapore",
    "Australia"
  ],
  "salary_expectations": {
    "min": 80000,
    "target": 120000,
    "max": 200000
  }
}
```

### Environment Variables

Create `.env` (optional):
```bash
# LinkedIn API credentials (when available)
LINKEDIN_EMAIL=your_email@example.com
LINKEDIN_PASSWORD=your_password

# Email notifications
SEND_EMAIL=true
EMAIL_TO=your_email@example.com

# OpenAI API (for LLM features)
OPENAI_API_KEY=sk-...
```

---

## 📈 Sample Workflow

### Week 1: Setup & Discovery

**Monday-Tuesday**: Setup
```bash
bash setup_agent.sh
nano config/profile.json
python3 epic_job_search_agent.py daily
```

**Wednesday-Friday**: Initial searching
```bash
# Run daily searches
python3 epic_job_search_agent.py daily

# Check early results
python3 job_search_dashboard.py daily
```

**Weekend**: Review & adjust
```bash
python3 job_search_dashboard.py weekly
# Adjust config based on insights
```

### Week 2-3: Active Outreach & Applications

**Daily**: Automated workflow handles
- Job discovery
- Scoring
- Applications
- LinkedIn outreach

**Your manual tasks**:
- Submit applications (generated packages)
- Follow up on promising leads
- Schedule interviews

### Week 4: Focus on Interviews

**Daily**: Continue automation, but focus shifts to

- Interview prep
- Salary negotiation
- Offer comparison

---

## 🔒 Security & Privacy

✅ **Credentials**: Encrypted in environment variables (`.env`)  
✅ **LinkedIn Automation**: Respects rate limits, no API violations  
✅ **Data Storage**: Local SQLite only (not cloud-synced)  
✅ **Git**: Sensitive files in `.gitignore`  
✅ **Automation**: Local execution only (no cloud services required)  

---

## 🐛 Troubleshooting

### "Command not found: python3"
```bash
# Install Python 3.8+
sudo apt-get install python3 python3-pip  # Ubuntu/Debian
brew install python3  # macOS
```

### Database errors
```bash
# Reset all databases
rm -rf data/*.db
bash setup_agent.sh
```

### Permission denied on scripts
```bash
chmod +x run_daily_job_search.sh run_weekly_job_search.sh
```

### Cron not running
```bash
# Check cron service
sudo systemctl status cron

# View cron logs
grep CRON /var/log/syslog

# Verify entry
crontab -l
```

### Low job matching scores
```bash
# Update profile config
nano config/profile.json
# Make sure skills match your actual experience
```

---

## 📚 Next Steps & Enhancements

### Phase 2 (Future):
- [ ] LinkedIn API integration (for official connections)
- [ ] OpenAI GPT-4 integration (advanced message generation)
- [ ] Email automation (Gmail API)
- [ ] Slack notifications (daily reports)
- [ ] Web dashboard (Flask/React frontend)

### Phase 3:
- [ ] Machine learning job scoring
- [ ] Predictive analytics (offer probability)
- [ ] Browser extension (auto-fill applications)
- [ ] Mobile app (iOS/Android tracking)

---

## 💡 Pro Tips

1. **Customize config early**: Better profile = better matches
2. **Run daily**: Consistency matters in job search
3. **Quality over quantity**: Target 5-10 high-fit applications/day
4. **Follow up**: 3 days, 1 week, 2 weeks if no response
5. **Network first**: Get referrals before applying when possible
6. **Track everything**: Use CRM to remember conversations

---

## 📞 Support & Feedback

**Issues?** Check logs:
```bash
cat outputs/logs/agent_$(date +%Y%m%d).log
```

**Questions?** Review documentation:
```bash
ls -la # See all components
cat README.md  # This file
```

**Want to contribute?** Fork and submit PR!

---

## 📄 License

Personal use only. Not for redistribution.

© 2025 Simon Renauld. All rights reserved.

---

**Last Updated**: November 9, 2025  
**Status**: ✅ Production Ready  
**Version**: 1.0 EPIC

Happy job searching! 🚀
