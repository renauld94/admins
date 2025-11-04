# Daily Lead Research Plan - Manual LinkedIn Strategy

**Goal:** 5 quality leads/day = 25 leads/week = 100 leads/month  
**Time Investment:** 30 minutes/day  
**Current Status:** 20 leads in CRM (18 new @ 8.8 fit, 2 qualified @ 9.5 fit)

---

## Your Profile Strengths (For Lead Matching)

### Technical Skills
- **Data Engineering:** PostgreSQL, Python, Airflow, ETL pipelines
- **QA & Testing:** pytest, Great Expectations, data quality frameworks
- **DevOps:** Docker, Proxmox, infrastructure automation
- **Platforms:** Moodle, Databricks, healthcare analytics
- **Specialties:** Data governance, GDPR/HIPAA compliance, federated learning

### Unique Value Props
1. **Software Engineering Background** - Can read code, enhance logging, build from scratch
2. **Quality-First Mindset** - 99.92% accuracy on 500M records (proven track record)
3. **Education Platform Experience** - Built complete LMS with course automation
4. **Cross-Domain Expertise** - Healthcare data + e-commerce + infrastructure

### Ideal Roles (Ranked by Fit)
1. **QA & QC Manager** (10/10) - ADA role, perfect match
2. **Data Quality Engineer** (9/10) - Governance focus, Python/SQL
3. **Senior QA Engineer - Data** (8/10) - Testing data pipelines
4. **Data Engineer - Quality Focus** (8/10) - Building validated ETL
5. **Head of Data Quality** (7/10) - Leadership + technical
6. **Analytics Engineer** (7/10) - dbt, testing, documentation

---

## Week 1 Search Plan (Nov 4-8)

### Monday Nov 4 - Canada Data Quality Roles

**Search Queries:**
1. "Data Quality Engineer Canada" + "Remote"
2. "QA Engineer Data" + "Toronto" OR "Vancouver"
3. "Senior Data Engineer" + "Quality" + "Canada"

**Target Companies:**
- Shopify (Toronto) - E-commerce data platform
- Wealthsimple (Toronto) - FinTech, compliance-heavy
- Lightspeed (Montreal) - Retail analytics
- Clio (Vancouver) - Legal tech, data governance
- FreshBooks (Toronto) - SaaS, financial data

**What to Look For:**
- Job postings 0-7 days old
- Decision makers (VP Engineering, Head of Data, CTO)
- Engineers recently posting about data quality challenges
- Companies with 100-500 employees (right size for impact)

**Expected Output:** 5 leads saved to `manual_leads_20251104.json`

---

### Tuesday Nov 5 - Singapore/Asia QA Roles

**Search Queries:**
1. "QA Engineer" + "Singapore" + "Data Platform"
2. "Test Engineer" + "Ho Chi Minh City" + "Python"
3. "Quality Assurance" + "Bangkok" + "ETL"

**Target Companies:**
- Grab (Singapore) - Super-app, massive data
- Sea Group (Singapore) - Shopee parent, e-commerce
- VNG Corporation (HCMC) - Gaming + social, data-driven
- Lazada (Singapore) - E-commerce, quality focus
- Agoda (Bangkok) - Travel tech, data pipelines

**Why Asia:**
- Lower competition for remote roles
- Your Vietnam experience (David, Frank contacts)
- Time zone overlap with EU/Middle East
- Growing tech scenes, Western practices

**Expected Output:** 5 leads saved to `manual_leads_20251105.json`

---

### Wednesday Nov 6 - Leadership Roles (Head of Data)

**Search Queries:**
1. "Head of Data Quality" + "Remote"
2. "Director Data Engineering" + "Canada" OR "Europe"
3. "VP Data" + "Startup" + "Series A" OR "Series B"

**Target Companies:**
- Series A/B startups (need to build quality from scratch)
- Scale-ups (50-200 employees, rapid growth pain)
- Healthcare tech (HIPAA compliance = your strength)
- FinTech (regulatory requirements = governance needs)

**What to Look For:**
- Companies raising recent funding (hiring surge)
- Job posts mentioning "build from scratch" or "greenfield"
- Tech stacks: Python, Airflow, PostgreSQL, dbt
- Culture mentions: "quality-first", "data-driven decisions"

**Expected Output:** 5 leads (may be lower fit score 6-7, but high potential)

---

### Thursday Nov 7 - Healthcare & Compliance Roles

**Search Queries:**
1. "Data Engineer Healthcare" + "HIPAA"
2. "QA Engineer" + "Medical Device" OR "Pharma"
3. "Data Governance" + "Healthcare Analytics"

**Target Companies:**
- TELUS Health (Canada) - Healthcare platform
- Epic Systems (USA) - EHR, data pipelines
- Roche (Switzerland) - Pharma, data quality
- Philips Healthcare (Netherlands) - Medical devices
- Veeva Systems (USA) - Life sciences cloud

**Why Healthcare:**
- Your proven 500M records healthcare experience
- HIPAA expertise is rare and valuable
- High compliance stakes = quality premium
- Less price-sensitive than consumer tech

**Expected Output:** 5 leads (high fit 8-9, may require relocation/visa)

---

### Friday Nov 8 - E-Commerce & Marketplace Roles

**Search Queries:**
1. "Data Engineer E-commerce" + "Marketplace"
2. "Analytics Engineer" + "Shopify" OR "Amazon"
3. "Data Quality" + "Retail Tech"

**Target Companies:**
- Amazon (Marketplace integrity team)
- Etsy (Seller data quality)
- Wayfair (Product catalog quality)
- Instacart (Grocery data accuracy)
- DoorDash (Restaurant + menu data)

**Why E-Commerce:**
- Massive data volumes (like TikTok/Shopee at ADA)
- Product catalog quality = revenue impact
- Duplicate detection, schema validation (your skills)
- Fast-paced, experimentation culture

**Expected Output:** 5 leads (mix of fit scores 7-9)

---

## Daily Research Workflow (30 minutes)

### Step 1: LinkedIn Search (10 minutes)
1. Open LinkedIn, use search query
2. Filter: "Past Week" + "Remote" or target location
3. Open 10 promising profiles in new tabs
4. Quick scan: Title, Company, Skills, Recent posts

### Step 2: Lead Qualification (10 minutes)
For each profile, check:
- **Fit Score Calculation:**
  - 10: All your skills + warm intro available + decision maker
  - 9: 90%+ skill match + senior role + good location
  - 8: Strong skill overlap + right level + okay location
  - 7: Most skills + potential growth + learnable gaps
  - 6: Some skills missing but interest in area

- **Red Flags (Skip):**
  - Profile inactive >6 months
  - Company in layoff mode (check news)
  - Role is clearly junior (despite title)
  - Tech stack completely different (Java/C#, no Python)

### Step 3: Data Entry (10 minutes)
For each qualified lead, copy template from `manual_lead_template.json`:

```json
{
  "name": "John Doe",
  "title": "Senior Data Engineer",
  "company": "Shopify",
  "location": "Toronto, Canada",
  "linkedin_url": "https://linkedin.com/in/johndoe",
  "fit_score": 8,
  "source": "linkedin_manual",
  "notes": "Posted about data quality challenges last week. Company hiring for QA role. Tech stack: Python, Airflow, PostgreSQL - perfect match.",
  "skills": ["Python", "PostgreSQL", "Airflow", "Data Quality"],
  "industry": "E-commerce"
}
```

Save as: `manual_leads_YYYYMMDD.json`

### Step 4: Import to CRM (2 minutes)
```bash
cd /home/simon/Learning-Management-System-Academy/linkedin-automation
python3 crm_database.py import-leads manual_leads_20251104.json
```

Verify:
```bash
python3 crm_database.py dashboard
# Should show +5 new leads
```

---

## Job Search Strategy (Active Applications)

### Where to Search (Beyond LinkedIn)
1. **Company Career Pages** - Direct applications, no LinkedIn blocks
2. **AngelList/Wellfound** - Startup jobs, equity info
3. **Built In** - Tech hubs (Toronto, Boston, Austin)
4. **Remote OK** - Fully remote positions
5. **Hacker News "Who's Hiring"** - Monthly thread, technical roles
6. **We Work Remotely** - Quality remote jobs

### Daily Job Search (15 minutes)
**Every morning, check:**
- LinkedIn Jobs: "Data Quality Engineer" + "Posted in last 24 hours"
- AngelList: "Data Engineer" + "Remote" + "Canada"
- Hacker News: Monthly "Who's Hiring" thread (search "data quality", "QA", "Python")

**Quality over quantity:**
- Apply to 1-2 perfect-fit roles/day (like ADA)
- 5-10 good-fit roles/week
- Track in CRM: `python3 crm_database.py import-jobs jobs_YYYYMMDD.json`

### Your Perfect Job Posting Keywords
**Must Have (Green Light):**
- "Python" + "SQL" OR "PostgreSQL"
- "Data quality" OR "QA" OR "Testing"
- "Airflow" OR "ETL" OR "Data pipelines"
- "Remote" OR "Canada" OR "Asia"

**Bonus (Extra Points):**
- "Build from scratch" OR "Greenfield"
- "GDPR" OR "HIPAA" OR "Compliance"
- "Startup" OR "Series A/B"
- "Moodle" OR "Education tech" OR "Healthcare"

**Red Flags (Skip):**
- "5+ years Java" (you're Python-focused)
- "On-site only" + obscure location
- "Requires PhD" OR "ML research"
- "Seeking ninja rockstar 10x" (culture fit issue)

---

## Week 2-4 Search Themes

### Week 2: Remote-First Companies
Focus on companies with proven remote culture:
- GitLab, Zapier, Automattic, Buffer, Doist
- Search for data roles at remote-first orgs

### Week 3: Your Network Expansion
- Research ADA competitors (e-commerce analytics platforms)
- Find people who worked with Frank/David previously
- Connect with Moodle community (your platform expertise)

### Week 4: International Opportunities
- European tech hubs: Berlin, Amsterdam, Barcelona
- Middle East: Dubai, Abu Dhabi (growing tech scenes)
- Australia/NZ: Sydney, Melbourne, Auckland

---

## Tracking & Metrics

### Weekly Review (Every Friday)
```bash
python3 crm_database.py dashboard
```

**Track:**
- Leads added this week (goal: 25)
- Average fit score (target: 7.5+)
- Source breakdown (LinkedIn manual, referrals, job boards)
- Conversion: Leads → Messages → Responses → Interviews

### Monthly Goals
- **November:** 100 leads, 10 applications, 3 interviews
- **December:** 150 leads total, 5 active interview processes
- **January:** Job offer(s) secured

---

## Today's Action (Monday Nov 4)

### Immediate Tasks:
1. ✅ Send ADA thank-you email (PRIORITY #1 - 10/10 match)
2. 🔍 Search "Data Quality Engineer Canada Remote" (30 min)
3. 📝 Create `manual_leads_20251104.json` with 5 leads
4. 💾 Import to CRM: `python3 crm_database.py import-leads manual_leads_20251104.json`
5. 📊 Verify: `python3 crm_database.py dashboard` (should show 25 leads)

### This Week's Pipeline Goal:
- Monday: 5 Canada data quality leads
- Tuesday: 5 Singapore/Asia QA leads  
- Wednesday: 5 leadership roles (heads of data)
- Thursday: 5 healthcare/compliance roles
- Friday: 5 e-commerce roles
- **Total: 25 new leads by Friday = 45 total in CRM**

---

## Quick Reference: Fit Score Guide

| Score | Criteria | Example |
|-------|----------|---------|
| **10** | Perfect match + warm intro + decision maker | Frank Plazanet at ADA |
| **9** | 90%+ skills + senior role + ideal location | David Nomber at ADA |
| **8** | Strong skills + right level + good location | Most target leads |
| **7** | Most skills + growth potential + okay location | Stretch roles |
| **6** | Some gaps but learnable + interest shown | Junior leadership |
| **5** | Significant gaps, only apply if desperate | Skip for now |

**Current CRM Status:**
- 2 qualified leads @ 9.5 avg fit (Frank, David)
- 18 new leads @ 8.8 avg fit
- 1 active application (ADA - screening)

**Your advantage:** You have a 10/10 opportunity (ADA) AND building sustainable pipeline for backup/future.

---

**Start with ADA email, then 30 minutes of lead research. Let's build that pipeline!**
