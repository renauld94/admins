# 🚀 Setup Guide - Job Search Toolkit

**Version**: 1.0.0  
**Created**: October 17, 2025  
**Author**: Simon Renauld

---

## Prerequisites

Before you begin, ensure you have:

1. **Python 3.11+** installed
   ```bash
   python3 --version  # Should be 3.11 or higher
   ```

2. **Git** (for version control)
   ```bash
   git --version
   ```

3. **Virtual environment** (recommended)

4. **API Keys** (optional, for advanced features):
   - OpenAI API key (for AI cover letters)
   - LinkedIn API credentials (for automation - use carefully!)
   - Ollama (local alternative to OpenAI)

---

## Step 1: Environment Setup

### Create Virtual Environment

```bash
# Navigate to job-search-toolkit
cd /home/simon/Learning-Management-System-Academy/job-search-toolkit

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # On Linux/Mac
# venv\Scripts\activate   # On Windows

# Verify activation (prompt should show (venv))
which python  # Should point to venv/bin/python
```

### Install Dependencies

```bash
# Upgrade pip
pip install --upgrade pip

# Install all requirements
pip install -r requirements.txt

# Download Spacy model (required for NLP)
python -m spacy download en_core_web_sm
```

**Note**: If you encounter installation issues:
```bash
# Install dependencies one by one
pip install requests beautifulsoup4 pandas
pip install spacy scikit-learn
pip install python-docx reportlab
pip install selenium playwright
pip install python-dotenv
```

---

## Step 2: Configuration

### Create Environment File

```bash
# Create .env file for sensitive data
cp .env.example .env
nano .env  # Or use your preferred editor
```

Add the following to `.env`:
```bash
# OpenAI API (for GPT-4 cover letters)
OPENAI_API_KEY=sk-your-api-key-here

# Ollama (local LLM alternative)
OLLAMA_URL=http://localhost:11434

# LinkedIn (use with caution - respect LinkedIn TOS)
LINKEDIN_EMAIL=your-email@example.com
LINKEDIN_PASSWORD=your-password-here

# Email automation (optional)
SENDGRID_API_KEY=your-sendgrid-key-here
```

**Important**: Never commit `.env` to git!

### Configure Your Profile

```bash
# Copy example profile
cp config/profile.example.json config/profile.json

# Edit with your details
nano config/profile.json
```

Update `config/profile.json` with:
- Your name, contact information
- Target roles and locations
- Skills (core, leadership, cloud, etc.)
- Experience level
- Salary expectations
- Company preferences

**Example**:
```json
{
  "name": "Simon Renauld",
  "email": "sn.renauld@gmail.com",
  "phone": "+84 923 180 061",
  "linkedin": "https://www.linkedin.com/in/simonrenauld",
  "portfolio": "https://www.simondatalab.de/",
  "target_roles": [
    "Lead Data Engineer",
    "Analytics Lead",
    "Head of Data Engineering"
  ],
  "experience_years": 10,
  "locations": {
    "preferred": ["Remote", "Ho Chi Minh City"],
    "acceptable": ["Singapore", "Australia"]
  },
  "skills": {
    "core": ["Python", "SQL", "PySpark", "Airflow", "Databricks"],
    "leadership": ["Team Leadership", "Agile", "Mentoring"],
    "cloud": ["AWS", "Azure", "Kubernetes"]
  },
  "salary_range": {
    "min": 80000,
    "target": 120000,
    "max": 180000,
    "currency": "USD"
  }
}
```

---

## Step 3: Initialize Database

```bash
# Create SQLite database for application tracking
python tools/00_init_database.py
```

This creates `data/applications.db` with tables for:
- Jobs
- Applications
- Contacts
- Interviews
- Offers

---

## Step 4: Test the Tools

### Test 1: Job Matcher

```bash
python tools/01_job_matcher.py \
  --keywords "Lead Data Engineer" \
  --location "Remote" \
  --min-score 70 \
  --max-results 20
```

**Expected output**: List of scored jobs with fit analysis

### Test 2: Cover Letter Generator

```bash
python tools/03_cover_letter_ai.py \
  --job-id TEST001 \
  --company "Test Company" \
  --role "Lead Data Engineer" \
  --model template \
  --format txt
```

**Expected output**: Generated cover letter in `outputs/cover_letters/`

### Test 3: Interview Prep

```bash
python tools/05_interview_prep.py \
  --company "Databricks" \
  --role "Lead Data Engineer" \
  --generate-report
```

**Expected output**: Comprehensive prep document in `outputs/interview_notes/`

---

## Step 5: Optional - Advanced Setup

### Install Ollama (Local LLM)

For privacy-first AI cover letters without sending data to OpenAI:

```bash
# Install Ollama (Linux/Mac)
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama server
ollama serve

# In another terminal, download a model
ollama pull mistral

# Test
python tools/03_cover_letter_ai.py \
  --job-id TEST001 \
  --company "Test" \
  --role "Lead Data Engineer" \
  --model ollama \
  --ollama-model mistral
```

### Install Browser Drivers (for Selenium/Playwright)

```bash
# Playwright (recommended)
playwright install chromium

# Selenium (alternative)
# Download ChromeDriver from: https://chromedriver.chromium.org/
```

### Set Up Email Automation (Optional)

For automated follow-ups via SendGrid:

1. Sign up at [SendGrid](https://sendgrid.com/)
2. Create API key
3. Add to `.env` file
4. Test with `tools/06_follow_up_manager.py`

---

## Step 6: Folder Organization

Ensure proper folder structure:

```bash
# Create output directories
mkdir -p outputs/resumes
mkdir -p outputs/cover_letters
mkdir -p outputs/interview_notes
mkdir -p outputs/reports

# Set permissions
chmod 755 tools/*.py
```

---

## Step 7: Integrate with Existing Tools

Link with your `linkedin-automation` folder:

```bash
# Symlink resume from portfolio
ln -s ../portfolio-deployment-enhanced/assets/resume/simon-renauld-resume.pdf data/resume.pdf

# Symlink LinkedIn content
ln -s ../linkedin-automation/content content/linkedin

# Use shared config
ln -s ../linkedin-automation/config/portfolio_alignment.json config/portfolio_alignment.json
```

---

## Verification Checklist

Before using the toolkit in production, verify:

- [x] Python 3.11+ installed
- [ ] Virtual environment activated
- [ ] All dependencies installed (`pip list | grep -E "requests|pandas|spacy"`)
- [ ] Spacy model downloaded (`python -m spacy info en_core_web_sm`)
- [ ] `.env` file created with API keys
- [ ] `config/profile.json` updated with your details
- [ ] Database initialized (`data/applications.db` exists)
- [ ] Test tools run successfully
- [ ] Output directories created
- [ ] Resume linked/copied to `data/`

---

## Troubleshooting

### Issue: ImportError for packages

**Solution**:
```bash
# Ensure virtual environment is activated
source venv/bin/activate

# Reinstall specific package
pip install --upgrade <package-name>
```

### Issue: Spacy model not found

**Solution**:
```bash
python -m spacy download en_core_web_sm
```

### Issue: Ollama connection refused

**Solution**:
```bash
# Start Ollama server
ollama serve

# In another terminal, test
curl http://localhost:11434/api/tags
```

### Issue: Permission denied on scripts

**Solution**:
```bash
chmod +x tools/*.py
```

### Issue: OpenAI API rate limit

**Solution**:
- Use Ollama (local, free)
- Use template-based generation
- Reduce API calls frequency

---

## Usage Workflow

### Week 1: Setup & Initial Job Search

**Day 1**: Setup toolkit (this guide)
```bash
source venv/bin/activate
python tools/01_job_matcher.py --keywords "Lead Data Engineer" --min-score 75
```

**Day 2-3**: Review matched jobs, shortlist top 10

**Day 4-5**: Generate applications
```bash
for job_id in JOB001 JOB002 JOB003; do
  python tools/03_cover_letter_ai.py --job-id $job_id --company "..." --role "..."
done
```

### Week 2-3: Applications & Interviews

**Daily**: Check application status, prepare for interviews
```bash
python tools/05_interview_prep.py --company "Databricks" --generate-report
```

### Week 4: Offers & Negotiation

**Ongoing**: Track offers, compare, negotiate
```bash
python tools/07_salary_negotiator.py --compare-offers
```

---

## Best Practices

1. **Daily routine**:
   - Check job boards (30 min)
   - Apply to 2-3 high-quality jobs
   - Follow up on pending applications

2. **Weekly routine**:
   - Review analytics dashboard
   - Update application tracker
   - Network with 3-5 professionals

3. **Version control**:
   - Commit config changes (but not `.env`!)
   - Track application versions
   - Back up database regularly

4. **Privacy**:
   - Never commit API keys or passwords
   - Use local LLM (Ollama) when possible
   - Respect LinkedIn rate limits

---

## Support

If you encounter issues:

1. Check this guide first
2. Review tool-specific `--help` output
3. Search existing GitHub issues
4. Contact: sn.renauld@gmail.com

---

## Next Steps

Once setup is complete:

1. Read [README.md](README.md) for tool details
2. Customize `config/profile.json`
3. Run your first job search
4. Generate your first application package
5. Track everything in the database

---

**Good luck with your job search! 🚀**

*Last Updated*: October 17, 2025  
*Tested On*: Ubuntu 22.04, macOS Sonoma, Python 3.11
