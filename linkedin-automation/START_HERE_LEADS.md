# 🎯 LEAD GENERATION - START HERE

## ✅ Dependencies Installed

All Python packages are now installed:
- `python-dotenv` - Environment variable management
- `playwright` - Browser automation for LinkedIn
- `pandas` - Data processing for lead analysis

## 🚀 Quick Start (Do This Now)

### Step 1: Configure LinkedIn Credentials

Edit the `.env` file with your LinkedIn credentials:

```bash
nano .env
```

Update these lines:
```bash
LINKEDIN_EMAIL=your_linkedin_email@gmail.com
LINKEDIN_PASSWORD=your_linkedin_password
```

**Security Note**: This file is in `.gitignore` - your credentials won't be committed to git.

### Step 2: Install Playwright Browsers

```bash
python3 -m playwright install chromium
```

This downloads the browser used for automation (~300MB).

### Step 3: Run Your First Lead Search

You have **3 options**:

#### Option A: Interactive Search (EASIEST)
```bash
./search-leads.sh
```
This will:
- Ask for locations (Vietnam, Canada, Singapore, etc.)
- Let you choose Quick vs Comprehensive mode
- Search all target roles automatically

#### Option B: Batch Search - Quick Mode
```bash
python3 batch_lead_search.py --quick --locations Vietnam Canada Singapore
```
Searches top 4 roles in your chosen locations (~10-15 minutes)

#### Option C: Batch Search - Comprehensive
```bash
python3 batch_lead_search.py --locations Vietnam Canada Singapore
```
Searches all roles + healthcare variations (~2 hours)

## 🎯 All Target Roles Included

The batch search automatically includes:

### Primary Roles (Always Searched)
1. **Head of Data** / VP Data
2. **CTO** / VP Engineering  
3. **Director of Analytics**
4. **ML Engineering Lead**

### Additional High-Value Roles
5. Chief Data Officer
6. Chief Technology Officer
7. VP Data Analytics
8. VP Data Science
9. Analytics Lead
10. Machine Learning Lead
11. Head of Machine Learning
12. Data Science Lead
13. Head of AI

### Healthcare-Focused Variations (Comprehensive Mode)
- All above roles + "Healthcare"
- All above roles + "Health Tech"
- All above roles + "Medical"
- All above roles + "Biotech"
- All above roles + "Pharmaceutical"

## 📊 What You'll Get

After each search, you'll receive:

1. **All Leads File**
   - `outputs/batch_searches/batch_search_YYYYMMDD_HHMMSS_all_leads.json`
   - Every prospect found (deduplicated)

2. **High-Fit Leads File**
   - `outputs/batch_searches/batch_search_YYYYMMDD_HHMMSS_high_fit.json`
   - Only leads with fit score ≥ 7/10
   - **Start here for outreach**

3. **Statistics Report**
   - Total searches completed
   - Unique leads found
   - Duplicates removed
   - Score distribution
   - Top roles and locations

## 📈 Lead Scoring (1-10)

Each lead gets a fit score based on:

### Score 9-10 (Perfect Fit)
- Title: "Head of Data", "Chief Data Officer", "VP Data"
- Company: Healthcare, biotech, health tech
- **Action**: InMail immediately

### Score 7-8 (Strong Fit)
- Title: "Director of Analytics", "Data Science Lead"
- Company: Tech, finance, e-commerce
- **Action**: Connection request with personalized message

### Score 5-6 (Good Fit)
- Title: "Senior Data Scientist", "Analytics Manager"
- Company: Any industry
- **Action**: Connect and engage with content first

### Score 1-4 (Low Fit)
- Junior roles, unrelated titles
- **Action**: Skip or low-priority

## 🎨 Sample Search Results

### Example: Quick Search (3 locations, 4 roles)
```
Searches: 12
Time: ~15 minutes
Expected leads: 50-100
High-fit leads: 10-20
```

### Example: Comprehensive Search (10 locations, 16 roles)
```
Searches: 160+
Time: ~2 hours
Expected leads: 500-800
High-fit leads: 50-100
```

## 🚀 After Search - Generate Outreach

### View Your Pipeline
```bash
python3 lead_generation_engine.py pipeline
```

### Generate Personalized Messages

For a specific lead:
```bash
# Connection request (300 characters)
python3 lead_generation_engine.py outreach <lead_id> connection

# InMail pitch (full message)
python3 lead_generation_engine.py outreach <lead_id> inmail

# Cold email
python3 lead_generation_engine.py outreach <lead_id> email
```

Messages are saved to `outputs/outreach/`

## 🎯 Your Infrastructure Assets (Used in Pitches)

Every generated message highlights relevant assets:

1. **Portfolio**: https://www.simondatalab.de
   - 500M+ healthcare records processed
   - 85% research acceleration
   - 99.9% uptime

2. **Training Platform**: https://moodle.simondatalab.de
   - Live courses (Python, Data Engineering, MLOps)
   - Real-world healthcare case studies

3. **AI Infrastructure**: ProxmoxMCP + VM 159 agents
   - Production-grade homelab
   - Full MLOps pipeline
   - Automated data pipelines

4. **Company Page**: https://linkedin.com/company/105307318
   - Technical thought leadership
   - Case studies and demos

## ⚡ Quick Workflow (Daily Routine)

### Monday Morning (30 min)
```bash
# Search for new leads
./search-leads.sh

# Review high-fit leads
cat outputs/batch_searches/*_high_fit.json | jq '.[0:5]'
```

### Every Day (1 hour)
```bash
# Send 10 connection requests
python3 lead_generation_engine.py pipeline
# Copy connection messages from outputs/outreach/

# Engage with 5 prospect posts (manual on LinkedIn)
# Comment with insights, share relevant content
```

### Friday (1 hour)
```bash
# Review responses
# Schedule discovery calls
# Generate InMail for non-responders
python3 lead_generation_engine.py outreach <lead_id> inmail
```

## 🔧 Troubleshooting

### Error: "ModuleNotFoundError: No module named 'dotenv'"
**Fixed!** We just installed it. If you still see this:
```bash
pip3 install python-dotenv
```

### Error: "Playwright browsers not installed"
```bash
python3 -m playwright install chromium
```

### LinkedIn Login Issues
- Check credentials in `.env`
- Try logging in manually first to verify password
- May need to handle 2FA (we'll add support if needed)

### Rate Limiting (429 errors)
- LinkedIn limits search frequency
- Use `--quick` mode for testing
- Spread searches over multiple days for comprehensive mode
- Script automatically waits 30s between searches

## 📊 Expected Results (30 Days)

### Week 1
- **Searches**: 3-5 batch searches
- **Leads**: 200-300 total, 40-60 high-fit
- **Outreach**: 50 connection requests
- **Responses**: 5-10 (10% response rate)

### Week 2-3
- **Conversations**: 10-15 active
- **Discovery calls**: 2-3 scheduled
- **Opportunities**: 1-2 qualified leads

### Week 4
- **Proposals**: 1-2 sent
- **Contracts**: 0-1 signed (realistic timeline: 60-90 days)

## 🎓 Pro Tips

1. **Personalize Every Message**
   - Reference their recent posts
   - Mention specific company challenges
   - Offer value (case study, free consultation)

2. **Lead with Value**
   - Share infrastructure showcase
   - Offer training resources (Moodle courses)
   - Provide industry insights

3. **Follow Up Consistently**
   - Week 1: Initial outreach
   - Week 2: Follow up with value-add content
   - Week 3: Offer discovery call
   - Week 4: Final follow-up

4. **Track Everything**
   - Use lead_generation_engine.py pipeline
   - Note response patterns
   - Optimize messages based on what works

## 🚀 Ready to Start?

Run this now:
```bash
./search-leads.sh
```

Choose locations: **Vietnam, Canada, Singapore**  
Choose mode: **Quick** (for first test)

You'll have 50-100 leads in ~15 minutes! 🎯
