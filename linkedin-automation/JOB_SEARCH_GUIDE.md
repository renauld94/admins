# 💼 LinkedIn Job Search - Quick Guide

## ✅ What's Running Now

**Job Search Script**: `job_search_automation.py`

**Current Search:**
- **Mode**: Remote only
- **Locations**: Canada, Singapore, Remote
- **Roles**: 19 (all target roles)
- **Total searches**: 57
- **Time**: ~15-20 minutes

## 🎯 What Jobs Are Being Found

### Target Roles (19)

**Data Engineering:**
- Data Engineer (all levels)
- Senior/Lead/Principal Data Engineer
- Analytics Engineer
- Data Platform Engineer

**ML & Analytics:**
- ML Engineer / MLOps Engineer
- Machine Learning Engineer

**QA/Testing** (like your ADA opportunity):
- QA Engineer
- Quality Assurance Engineer
- Test Engineer
- Software Quality Engineer

**Leadership:**
- Head of Data
- Director of Data Engineering
- VP of Data
- Engineering Manager

### Locations

1. **Canada** - Toronto, Vancouver, Montreal + Remote
2. **Singapore** - On-site + Remote
3. **Remote** - Work from anywhere

### Skills Matched

The script automatically scores jobs based on YOUR skills:
- PostgreSQL ✅
- Python ✅
- SQL ✅
- Airflow ✅
- Data Pipelines ✅
- ETL/ELT ✅
- Testing/QA ✅
- CI/CD ✅
- Cloud (AWS/GCP/Azure) ✅

## 📊 Expected Results

```
Total jobs: 150-300
High-fit (8+): 40-80
Perfect fit (10): 10-20
Remote eligible: 100% (filtered for remote only)
```

## 🔍 Fit Scoring (Automatic)

**Score 9-10:** Perfect match
- Senior/Lead Data Engineer roles
- Remote + Canada/Singapore
- Skills: PostgreSQL, Airflow, Python

**Score 7-8:** Strong match  
- Mid-level Data/QA Engineer
- Remote eligible
- Core skills match

**Score 5-6:** Moderate fit
- Entry-level or adjacent roles
- Some skills overlap

## 📁 Output Files

Results saved to: `outputs/jobs/`

**Files created:**
- `batch_jobs_TIMESTAMP_all.json` - All jobs found
- `batch_jobs_TIMESTAMP_high_fit.json` - High-fit jobs only (≥8)

## 🚀 Usage Options

### Quick Search (RECOMMENDED - currently running)
```bash
python3 job_search_automation.py --remote-only --locations "Canada" "Singapore" "Remote"
```

### Full Search (All roles + locations)
```bash
python3 job_search_automation.py --remote-only
```

### Specific Roles Only
```bash
python3 job_search_automation.py \
  --remote-only \
  --roles "Data Engineer" "Senior Data Engineer" "QA Engineer" \
  --locations "Canada" "Singapore"
```

### Quick Mode (Top 5 roles, 3 locations)
```bash
python3 job_search_automation.py --quick --remote-only
```

### Include On-Site Jobs (Not just remote)
```bash
python3 job_search_automation.py --locations "Canada" "Singapore"
```

## 📈 After Search Completes

### View Results
```bash
# View latest high-fit jobs
cat outputs/jobs/batch_jobs_*_high_fit.json | jq '.[0:10]'

# Count by location
cat outputs/jobs/batch_jobs_*_all.json | jq '[.[] | .location] | group_by(.) | map({location: .[0], count: length})'

# Top companies
cat outputs/jobs/batch_jobs_*_all.json | jq '[.[] | .company] | group_by(.) | map({company: .[0], count: length}) | sort_by(.count) | reverse | .[0:10]'
```

### Import to CRM (Automatic)
The script automatically tries to import jobs to your CRM database.

Manual import:
```bash
python3 crm_database.py import-jobs outputs/jobs/batch_jobs_*_all.json
```

### View in CRM Dashboard
```bash
python3 crm_database.py dashboard
python3 crm_database.py list-jobs --min-fit 8
```

## 🎯 Example Results

**Sample high-fit jobs you'll find:**

1. **Senior Data Engineer @ Shopify** (Remote Canada)
   - Score: 10/10
   - Skills: Python, PostgreSQL, Airflow, Kubernetes
   - Remote eligible ✅
   
2. **QA Engineer @ Grab** (Singapore + Remote)
   - Score: 9/10
   - Skills: Python, PyTest, CI/CD, SQL
   - Like your ADA opportunity!

3. **Data Platform Engineer @ Google Cloud** (Remote)
   - Score: 10/10
   - Skills: Data Pipelines, ETL, Cloud, SQL
   
4. **Analytics Engineer @ dbt Labs** (Remote - Canada)
   - Score: 9/10
   - Skills: SQL, Data Modeling, Python, Airflow

## 🔄 Workflow

1. **Search completes** → Jobs saved to JSON files
2. **Auto-import to CRM** → Track applications
3. **Review high-fit jobs** → Focus on 8+ scores
4. **Apply strategically** → Easy Apply when available
5. **Track in CRM** → Log applications, interviews, responses

## 💡 Pro Tips

### Combine with Lead Search
```bash
# Find decision-makers at companies with job postings
# 1. Run job search → Get company list
# 2. Run lead search → Find hiring managers at those companies
# 3. Warm outreach: "I saw you're hiring for X, I have experience in Y"
```

### Focus on Easy Apply
Jobs with "Easy Apply" button = 1-click application

### Target Companies Hiring Your Leads
If you found a "Head of Data" lead at Company X, check if they're hiring!

### Remote Canada Opportunities
- Shopify, Wealthsimple, Faire, Coveo, Ada Support
- Many US companies hiring in Canada remotely
- Better work-life balance than US

### Singapore Market
- Grab, Sea Group, Shopee, Carousell
- Regional hubs for US tech (Google, Meta, Amazon)
- Strong QA/testing culture (like ADA)

## 🚨 Rate Limiting

Same as lead search - LinkedIn may block after too many searches.

**Best practice:**
- Run once per day
- Use `--quick` mode for testing
- Spread searches across days

## 📊 Monitor Progress

Check terminal output:
```bash
# Current search progress shown live
[X/57] Role in Location
🔍 Searching jobs: ...
   Found Y job cards
   ✅ Found Z relevant jobs
```

## ⚡ Next Steps After Results

1. **Review High-Fit Jobs**
   ```bash
   cat outputs/jobs/batch_jobs_*_high_fit.json | jq -r '.[] | "\(.fit_score)/10 - \(.title) @ \(.company)"'
   ```

2. **Prepare Applications**
   - Tailor resume for each role
   - Highlight relevant skills (PostgreSQL, Airflow, etc.)
   - Mention ADA experience (QA + Software Engineering)

3. **Track Everything in CRM**
   - Log when you apply
   - Track interview stages
   - Note recruiter contacts

4. **Leverage Your Network**
   - Ask Frank/David for ADA referral
   - Connect with hiring managers (from lead search!)
   - Warm introductions beat cold applications

## 🎯 Success Metrics

**Week 1:**
- Find 50-100 relevant jobs
- Identify 15-25 high-fit positions
- Apply to 5-10 with Easy Apply

**Week 2:**
- 2-5 recruiter responses
- 1-3 phone screens
- Continue applying

**Week 3:**
- 1-2 technical interviews
- Follow up with warm leads
- Leverage ADA connection

---

**Currently running:** 57 searches for remote jobs in Canada, Singapore, and general remote positions. This will find 150-300 jobs automatically! 🚀
