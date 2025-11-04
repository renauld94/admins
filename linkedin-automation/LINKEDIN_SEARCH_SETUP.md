# 🔍 LinkedIn Lead Search - Setup & Execution

## ✅ What's Already Done

1. **CRM Database** - Fully operational with 8 existing contacts
2. **Exclusion Filter** - Frank Plazanet and David Nomber will be automatically skipped
3. **Search Engine** - Ready to find decision-makers across multiple locations
4. **Auto-Import** - New leads automatically added to your CRM

## 🚀 Quick Start (3 Steps)

### Step 1: Add LinkedIn Credentials

```bash
./setup-linkedin-credentials.sh
```

This will prompt you for:
- LinkedIn Email
- LinkedIn Password (hidden input)

**Note:** Credentials are stored in `.env` file (git-ignored, secure)

### Step 2: Run Quick Search

```bash
# Quick search (Vietnam, Canada, Singapore - ~50 leads)
python3 batch_lead_search.py --quick --locations Vietnam Canada Singapore --auto-import
```

**What happens:**
- Searches for 16 target roles (Head of Data, CTO, Directors, etc.)
- Filters for 3 locations (Vietnam, Canada, Singapore)
- **Automatically excludes Frank Plazanet and David Nomber**
- Scores each lead (fit score 1-10)
- Auto-imports to your CRM database
- Generates personalized outreach templates

**Time:** 5-10 minutes  
**Expected Results:** 30-70 new leads

### Step 3: Review Results

```bash
# View CRM dashboard
python3 crm_database.py dashboard

# View all leads
python3 crm_database.py list-leads

# View high-fit leads only (8+)
python3 crm_database.py list-leads --min-fit 8
```

## 🎯 Search Options

### Quick Search (Recommended for Testing)
```bash
python3 batch_lead_search.py --quick --locations Vietnam Canada Singapore --auto-import
```
- 16 roles × 3 locations = 48 searches
- ~50-70 leads
- 5-10 minutes

### Full Search (Comprehensive)
```bash
python3 batch_lead_search.py --auto-import
```
- 16 roles × 10 locations = 160 searches
- ~150-250 leads
- 30-60 minutes

### Custom Search (Specific Roles/Locations)
```bash
python3 batch_lead_search.py \
  --roles "Head of Data" "CTO" "VP Engineering" \
  --locations Vietnam Canada \
  --auto-import
```

### Interactive Search
```bash
./search-leads.sh
```
Prompts you for:
- Job title
- Location
- Number of results

## 📊 Target Roles (Default)

1. Head of Data
2. CTO
3. VP Engineering
4. Director of Data Science
5. Director of Analytics
6. Chief Data Officer
7. VP of Data
8. Director of Engineering
9. Head of Analytics
10. Director of AI/ML
11. VP of Technology
12. Head of Data Engineering
13. Data Engineering Lead
14. ML Engineering Lead
15. Healthcare Data Director
16. Clinical Analytics Director

## 🌍 Target Locations (Default)

1. Vietnam
2. Canada
3. Singapore
4. United States
5. United Kingdom
6. Germany
7. Australia
8. Hong Kong
9. Thailand
10. Philippines

## 🚫 Excluded Contacts (Existing Hot Leads)

**The system automatically excludes:**
- Frank Plazanet (ADA Vietnam - 10/10 fit, session scheduled)
- David Nomber (ADA Vietnam - 9/10 fit, in-person contact)

These are already in your CRM with:
- Organization: ADA Global
- Job Application: QA & QC Manager (SCREENING)
- Interaction: In-person meeting logged

## 📁 Output Files

All results saved to: `outputs/batch_searches/`

**File naming:**
- `batch_search_YYYYMMDD_HHMMSS_all_leads.json` - All leads
- `batch_search_YYYYMMDD_HHMMSS_high_fit_8plus.json` - High-fit leads only
- `batch_search_YYYYMMDD_HHMMSS_summary.txt` - Search summary

**Auto-import:** Leads automatically added to CRM if `--auto-import` flag used

## 🔄 Workflow After Search

1. **Search completes** → Leads saved to JSON + CRM
2. **Review dashboard** → `python3 crm_database.py dashboard`
3. **View leads** → `python3 crm_database.py list-leads --min-fit 8`
4. **Generate outreach** → (Coming soon - outreach templates per lead)
5. **Track interactions** → Log every call/email/meeting in CRM

## 🎯 Lead Scoring (Automatic)

**Fit Score 9-10:** Perfect match
- Senior titles (CTO, Head of X, VP)
- Target industries (Healthcare, AI/ML, Data)
- **Action:** Priority outreach

**Fit Score 7-8:** Strong fit
- Director/Manager level
- Relevant industries
- **Action:** Personalized outreach

**Fit Score 5-6:** Moderate fit
- Mid-level roles
- Adjacent industries
- **Action:** Standard outreach template

**Fit Score 1-4:** Low fit
- Junior roles or unrelated industries
- **Action:** Skip or very light touch

## 🔍 Example Search Output

```
🔍 LINKEDIN LEAD GENERATION - BATCH SEARCH
==========================================

TARGET ROLES: 16
TARGET LOCATIONS: 3 (quick mode)
EXCLUDED CONTACTS: 2 (Frank Plazanet, David Nomber)

Progress: [##########] 48/48 searches

📊 RESULTS:
Total leads found: 67
- Fit score 9-10: 12 leads
- Fit score 7-8: 23 leads
- Fit score 5-6: 32 leads

✅ Auto-imported to CRM: 67 leads
📁 Saved to: outputs/batch_searches/batch_search_20251104_080000_all_leads.json

TOP 5 HIGH-FIT LEADS:
1. Sarah Thompson - CTO @ HealthTech Vietnam (10/10)
2. Michael Chen - VP Data @ MedAnalytics Canada (9/10)
3. Jessica Wong - Head of Data @ Singapore General Hospital (9/10)
4. Robert Kim - Director Analytics @ VietHealth (8/10)
5. Amanda Li - CDO @ DataCorp Asia (8/10)
```

## 🛡️ Privacy & Security

- **Credentials:** Stored in `.env` (git-ignored)
- **Rate Limiting:** Built-in delays to avoid LinkedIn throttling
- **Headless Mode:** Browser runs in background
- **Data Storage:** All data local (PostgreSQL)
- **No API Keys:** Uses browser automation (no LinkedIn API needed)

## 🔧 Troubleshooting

### "No module named 'playwright'"
```bash
pip3 install playwright
playwright install chromium
```

### "LinkedIn login failed"
- Check credentials in `.env`
- LinkedIn may require 2FA verification (use browser first)
- Try non-headless mode: edit `lead_generation_engine.py` line 116: `headless=False`

### "Connection to database failed"
```bash
# Check PostgreSQL status
systemctl status postgresql

# Restart if needed
sudo systemctl restart postgresql
```

### "No leads found"
- Check network connection
- LinkedIn may have changed HTML structure (update selectors)
- Try different job titles or locations

## 📚 Next Steps

After finding leads:

1. **Review ADA Hot Lead**
   ```bash
   cat ADA_HOT_LEAD.md
   ```

2. **Prepare for Frank Session**
   - Read preparation guide
   - Review your skill match (100%)
   - Practice talking points

3. **Outreach to High-Fit Leads**
   - Use generated templates
   - Personalize with their pain points
   - Highlight relevant case studies

4. **Track Everything in CRM**
   ```bash
   # Log interaction
   python3 crm_database.py add-interaction \
     --lead-id <id> \
     --type "email" \
     --subject "Quick outreach" \
     --notes "Sent connection request"
   ```

## 🎯 Success Metrics

**Week 1:**
- ✅ Find 50-100 qualified leads
- ✅ Import to CRM
- ✅ Prepare Frank session (ADA)

**Week 2:**
- Send 20 connection requests/day
- 5-10 responses expected
- 2-3 qualified conversations

**Week 3:**
- Schedule 2-3 discovery calls
- 1-2 concrete opportunities
- Frank session follow-up

---

**Need Help?** Check:
- `SYSTEM_SUMMARY.md` - Complete system overview
- `CRM_DATABASE_GUIDE.md` - Database documentation
- `ADA_HOT_LEAD.md` - Prep for Frank session
