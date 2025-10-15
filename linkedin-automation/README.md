# LinkedIn Automation & Job Search Toolkit

**Created**: October 15, 2025  
**Owner**: Simon Renauld  
**Purpose**: Comprehensive LinkedIn automation, resume optimization, and job search tools aligned with portfolio (simondatalab.de)

---

## 📁 Project Structure

```
linkedin-automation/
├── README.md                          # This file
├── content/                           # LinkedIn profile content
│   ├── LinkedIn_copy_paste.md        # Ready-to-paste profile sections
│   └── Enterprise_Data_Science_Lab_Case_Study.md
├── guides/                            # Implementation guides
│   ├── LinkedIn_Quick_Start_Guide.md
│   └── LinkedIn_Profile_Visual_Review_Checklist.md
├── tools/                             # Automation scripts
│   ├── resume_optimizer.py           # ATS resume optimization
│   ├── job_scraper.py                # Job board scraping
│   ├── linkedin_autofill.py          # Browser automation for LinkedIn
│   ├── cover_letter_generator.py    # AI cover letter generation
│   └── application_tracker.py       # Job application tracking
├── outputs/                           # Generated outputs
│   ├── optimized_resumes/           # ATS-optimized resumes
│   ├── cover_letters/               # Generated cover letters
│   ├── job_listings/                # Scraped job data
│   └── reports/                     # Analytics reports
├── config/                            # Configuration files
│   ├── keywords.json                # ATS keywords by role
│   ├── job_boards.json              # Job board URLs
│   ├── linkedin_credentials.enc     # Encrypted credentials
│   └── portfolio_alignment.json     # Portfolio branding config
└── data/                              # Data storage
    ├── applications.db               # SQLite tracking database
    └── templates/                    # Document templates
```

---

## 🎯 Features

### 1. LinkedIn Profile Automation
- ✅ Profile content generation (based on resume)
- ✅ Copy-paste package with professional tone
- ✅ Visual review checklist
- 🔄 Browser automation for profile updates (Playwright)
- 🔄 Company page content generation
- 🔄 Automated post scheduling

### 2. Resume Optimization
- 🔄 ATS keyword optimization
- 🔄 Multiple format generation (PDF, DOCX, TXT)
- 🔄 Role-specific resume tailoring
- 🔄 Alignment with simondatalab.de portfolio

### 3. Job Search Automation
- 🔄 Multi-board job scraping (LinkedIn, Indeed, Glassdoor)
- 🔄 Keyword-based filtering
- 🔄 Application tracking
- 🔄 Automated cover letter generation

### 4. Portfolio Alignment
- 🔄 Consistent branding across LinkedIn, resume, simondatalab.de
- 🔄 Metrics synchronization
- 🔄 Content consistency validation

---

## 🚀 Quick Start

### Prerequisites
```bash
# Python 3.11+
python --version

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
nano .env  # Add your credentials
```

### Usage

#### 1. Optimize Resume for ATS
```bash
python tools/resume_optimizer.py \
  --input ../portfolio-deployment-enhanced/assets/resume/simon-renauld-resume.pdf \
  --role "Lead Data Engineer" \
  --output outputs/optimized_resumes/
```

#### 2. Search Jobs
```bash
python tools/job_scraper.py \
  --keywords "Lead Data Engineer,Analytics Lead" \
  --location "Ho Chi Minh City,Remote" \
  --output outputs/job_listings/
```

#### 3. Generate Cover Letter
```bash
python tools/cover_letter_generator.py \
  --job-id JOB12345 \
  --company "Acme Corp" \
  --output outputs/cover_letters/
```

#### 4. Update LinkedIn (Browser Automation)
```bash
python tools/linkedin_autofill.py \
  --mode personal \
  --content content/LinkedIn_copy_paste.md \
  --headless false
```

#### 5. Track Applications
```bash
python tools/application_tracker.py \
  --add \
  --company "Acme Corp" \
  --role "Lead Data Engineer" \
  --status "Applied"
```

---

## 🔧 Configuration

### Portfolio Alignment (`config/portfolio_alignment.json`)

Ensures consistent branding across:
- **LinkedIn**: Professional, metrics-first
- **Resume**: ATS-optimized, detailed
- **simondatalab.de**: Strategic, healthcare-focused

**Key Metrics** (synced across all platforms):
- 500M+ healthcare records processed
- 85% research cycle acceleration
- 99.9% system reliability
- 100% HIPAA compliance
- 80% operational automation
- 30% faster delivery
- $150K cost savings

**Brand Voice**:
- LinkedIn: Professional, no emojis, action-oriented
- Resume: Quantified outcomes, role-specific
- Portfolio: Strategic impact, technical depth, engineering excellence

---

## 📊 Data Flow

```
Resume PDF (source of truth)
    ↓
├─→ LinkedIn Profile Content (professional tone)
├─→ ATS-Optimized Resumes (role-specific)
├─→ Cover Letters (company-specific)
└─→ Portfolio Alignment (simondatalab.de sync)
    ↓
Job Boards → Scraper → Filter → Tracker → Applications
```

---

## 🛡️ Security

- **Credentials**: Encrypted with Fernet (`linkedin_credentials.enc`)
- **API Keys**: Environment variables only (`.env` gitignored)
- **Personal Data**: Never committed to git
- **Browser Automation**: Local execution only

---

## 📈 Metrics & Reporting

### Application Tracking
- Applications sent: tracked in SQLite
- Response rate: calculated weekly
- Interview conversion: tracked by role/company
- Offer rate: tracked by industry

### Resume Optimization
- ATS score: keyword matching %
- Format compliance: PDF/DOCX validation
- Length: 1-2 pages target
- Keyword density: optimal 2-4% per role

---

## 🔄 Workflow Example

**Goal**: Apply to 10 Lead Data Engineer roles/week

1. **Monday**: Scrape jobs from LinkedIn, Indeed, Glassdoor
   ```bash
   python tools/job_scraper.py --keywords "Lead Data Engineer" --output outputs/job_listings/
   ```

2. **Tuesday**: Review scraped jobs, shortlist 10 best matches
   ```bash
   python tools/application_tracker.py --review outputs/job_listings/latest.json
   ```

3. **Wednesday**: Generate tailored resumes + cover letters
   ```bash
   for job in shortlist.json:
       python tools/resume_optimizer.py --role "$job_title"
       python tools/cover_letter_generator.py --job-id "$job_id"
   ```

4. **Thursday-Friday**: Apply via company websites / LinkedIn
   ```bash
   python tools/linkedin_autofill.py --job-id "$job_id"
   ```

5. **Saturday**: Update tracker, analyze metrics
   ```bash
   python tools/application_tracker.py --report weekly
   ```

---

## 🎓 Best Practices

### Resume Optimization
- **Tailor per role**: Use role-specific keywords from job description
- **Quantify outcomes**: 80% automation, 30% faster, $150K savings
- **ATS-friendly**: No tables, no images, standard fonts (Arial, Calibri)
- **1-2 pages**: Senior roles max 2 pages
- **PDF + DOCX**: Some ATS require DOCX

### Cover Letters
- **3 paragraphs**: Hook → Evidence → Call-to-action
- **Company research**: Reference specific projects/values
- **Quantified impact**: Mirror resume metrics
- **150-250 words**: Concise, scannable

### LinkedIn Profile
- **Headline**: Metrics-first, ≤220 chars
- **About**: 3 paragraphs, line breaks
- **Experience**: 3-4 bullets per role, action + scope + impact
- **Featured**: Resume, case studies, portfolio
- **Skills**: 20+ hard skills, endorsements

---

## 📚 Resources

### Internal
- [LinkedIn Copy-Paste Package](content/LinkedIn_copy_paste.md)
- [Quick Start Guide](guides/LinkedIn_Quick_Start_Guide.md)
- [Visual Review Checklist](guides/LinkedIn_Profile_Visual_Review_Checklist.md)
- [Enterprise Lab Case Study](content/Enterprise_Data_Science_Lab_Case_Study.md)

### External
- [Portfolio: simondatalab.de](https://www.simondatalab.de/)
- [Resume PDF](../portfolio-deployment-enhanced/assets/resume/simon-renauld-resume.pdf)
- [Training Courses](https://moodle.simondatalab.de/my/courses.php)

### Tools
- [Playwright Docs](https://playwright.dev/python/)
- [BeautifulSoup Docs](https://www.crummy.com/software/BeautifulSoup/)
- [Resume.io ATS Checker](https://resume.io/ats-resume-checker)

---

## 🚧 Roadmap

### Phase 1: Foundation (Week 1) ✅
- [x] LinkedIn content generation
- [x] Portfolio alignment strategy
- [x] Folder structure

### Phase 2: Automation (Week 2)
- [ ] Resume optimizer (ATS keywords)
- [ ] Job scraper (LinkedIn, Indeed, Glassdoor)
- [ ] Application tracker (SQLite)
- [ ] Cover letter generator (AI-powered)

### Phase 3: Advanced (Week 3)
- [ ] LinkedIn browser automation (Playwright)
- [ ] Company page content generator
- [ ] Post scheduling automation
- [ ] Analytics dashboard

### Phase 4: Integration (Week 4)
- [ ] Portfolio sync (simondatalab.de ↔ LinkedIn)
- [ ] API integrations (LinkedIn API for company page)
- [ ] Webhook notifications (new jobs, responses)
- [ ] Weekly reporting automation

---

## 🤝 Contributing

This is a personal automation toolkit. For questions or suggestions:
- **Email**: simon@simondatalab.de
- **LinkedIn**: [linkedin.com/in/simonrenauld](https://www.linkedin.com/in/simonrenauld)
- **Portfolio**: [simondatalab.de](https://www.simondatalab.de/)

---

## 📄 License

Personal use only. Not for redistribution.

© 2025 Simon Renauld. All rights reserved.
