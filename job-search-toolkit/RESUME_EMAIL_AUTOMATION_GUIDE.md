# 📧 AUTOMATED RESUME & COVER LETTER SYSTEM - SETUP GUIDE

## Overview

Complete automated system to:
- ✅ Dynamically adjust resumes based on job descriptions (ATS optimization)
- ✅ Generate personalized cover letters for each opportunity
- ✅ Email applications to your two email addresses
- ✅ Track all applications with logging

## 🚀 Quick Start

### Step 1: Generate Sample Resume & Cover Letter

```bash
cd /home/simon/Learning-Management-System-Academy/job-search-toolkit

# Test with sample data
python3 test_resume_automation.py
```

**Output:** 
- `outputs/applications/SAMPLE_RESUME.txt`
- `outputs/applications/SAMPLE_COVER_LETTER.txt`

### Step 2: Review Generated Files

```bash
cat outputs/applications/SAMPLE_RESUME.txt
cat outputs/applications/SAMPLE_COVER_LETTER.txt
```

### Step 3: Choose Email Delivery Method

#### Option A: Manual Email (Recommended for Setup)
Files are saved to `outputs/email_log/` for you to send manually.

```bash
# Configure for manual sending
echo "EMAIL_METHOD=manual" > .env

# Test
python3 email_delivery_system.py

# Check saved email files
ls -la outputs/email_log/
```

#### Option B: Gmail SMTP (Production)

1. **Generate Gmail App Password** (2FA required):
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Copy the 16-character password

2. **Add to .env:**
```bash
cat > .env << 'EOF'
EMAIL_METHOD=gmail
GMAIL_EMAIL=your_email@gmail.com
GMAIL_PASSWORD=xxxx_xxxx_xxxx_xxxx
EOF
```

3. **Test:**
```bash
python3 email_delivery_system.py
```

#### Option C: Local Testing with MailHog

1. **Install & Run MailHog:**
```bash
# On Linux/Mac
brew install mailhog  # or download from https://github.com/mailhog/MailHog

# Start MailHog
mailhog  # Starts on localhost:1025 (SMTP) and localhost:8025 (Web UI)
```

2. **Configure:**
```bash
echo "EMAIL_METHOD=mailhog" > .env
python3 email_delivery_system.py
```

3. **View in Browser:**
   - http://localhost:8025

## 📋 Full Workflow

### 1. Run Job Discovery (if needed)

```bash
python3 live_results_generator.py
python3 expanded_global_search.py
```

This populates the job database with opportunities.

### 2. Generate Resume & Cover Letter Packages

For single job:
```bash
python3 test_resume_automation.py
```

For batch (all top jobs in database):
```bash
python3 resume_cover_letter_automation.py
```

### 3. Review & Customize

```bash
# Check what was generated
ls -la outputs/applications/

# Edit cover letters if needed for personalization
vim outputs/applications/SAMPLE_COVER_LETTER.txt
```

### 4. Send Applications

```bash
# Via Email Delivery System
python3 email_delivery_system.py

# Or send manually from email_log/ files
cat outputs/email_log/20251110_053833_Stripe_Senior_Data_Engineer.eml | \
  sendmail -t  # If using local MTA
```

## 🔧 Configuration Files

### .env (Email Configuration)
```
EMAIL_METHOD=manual  # Options: manual, gmail, mailhog
GMAIL_EMAIL=your_email@gmail.com
GMAIL_PASSWORD=app_password_here
```

### config/profile.json (Already Updated)
- ✅ Your personal info
- ✅ Technical skills (50+)
- ✅ Target roles (22)
- ✅ Target regions (6: Vietnam, APAC, USA, Canada, Europe)
- ✅ Salary preferences ($80K-$350K, de-prioritized)

## 📊 System Architecture

```
Resume & Cover Letter Automation
├── resume_cover_letter_automation.py
│   ├── ResumeOptimizer
│   │   ├── Extract keywords from job description
│   │   ├── ATS-optimize resume content
│   │   └── Prioritize matching technologies/skills
│   ├── CoverLetterGenerator
│   │   ├── Detect role seniority level
│   │   ├── Create personalized opening
│   │   └── Highlight relevant achievements
│   └── EmailAutomationSystem
│       ├── Generate application package
│       ├── Save resume + cover letter
│       └── Log tracking info
│
├── email_delivery_system.py
│   ├── Gmail SMTP sender
│   ├── MailHog test server
│   ├── Manual file saver
│   └── Application logger
│
└── Database: data/job_search.db
    └── jobs table with opportunities
```

## ✨ Features

### ATS Resume Optimization
- ✅ Extracts 50+ technical keywords from job description
- ✅ Reorders skills to emphasize matches
- ✅ Adjusts summary based on role level (Principal → Lead → Senior)
- ✅ Maintains professional formatting

### Personalized Cover Letters
- ✅ Detects role seniority and tailors tone
- ✅ Identifies industry from job description
- ✅ Opens with company-specific interest
- ✅ Highlights relevant achievements
- ✅ Mentions timezone flexibility (Ho Chi Minh City)
- ✅ Includes all contact info

### Email Delivery
- ✅ Multiple methods (Manual, Gmail, MailHog)
- ✅ Sends to both email addresses
- ✅ Attaches resume + cover letter
- ✅ Comprehensive logging
- ✅ Error handling & retries

## 📧 Your Email Addresses

**Primary:**  
📬 contact@simondatalab.de

**Backup:**  
📬 sn@gmail.com

Both will receive identical application packages automatically.

## 🎯 Usage Recommendations

### For Initial Setup:
1. Use `EMAIL_METHOD=manual`
2. Generate sample resume/cover letter
3. Review in outputs/applications/
4. Edit if needed
5. Send manually or via Gmail

### For Bulk Applications:
1. Set `EMAIL_METHOD=gmail` (after getting app password)
2. Run resume_cover_letter_automation.py
3. Automatically generates + sends to both emails
4. Check outputs/email_log/ for confirmation

### Daily Automation:
Add to cron job:
```bash
# Add to crontab
0 8 * * *  cd /path/to/toolkit && python3 resume_cover_letter_automation.py && python3 email_delivery_system.py
```

## 🔒 Security Notes

- Never commit .env with credentials to git
- .gitignore already includes .env
- Use Gmail App Passwords (not main password)
- Consider 2FA on both email accounts
- Review generated cover letters before sending

## 📊 Output Files

```
outputs/
├── applications/
│   ├── 20251110_053832_Amplitude_Resume.txt
│   ├── 20251110_053832_Amplitude_CoverLetter.txt
│   ├── SAMPLE_RESUME.txt
│   └── SAMPLE_COVER_LETTER.txt
└── email_log/
    ├── application_log_20251110_053833.json
    └── 20251110_053833_Stripe_Senior_Data_Engineer.eml
```

## 🐛 Troubleshooting

### "No jobs in database"
```bash
# Run job discovery first
python3 live_results_generator.py
python3 expanded_global_search.py
```

### Email not sending
```bash
# Check SMTP connection
python3 -c "import smtplib; s=smtplib.SMTP('smtp.gmail.com', 587); print('✅ Connected')"

# Check .env file
cat .env
```

### Cover letters too generic
- Edit the `CoverLetterGenerator._infer_industry()` method
- Add company-specific opening paragraphs
- Or manually edit generated files before sending

## 🚀 Next Steps

1. ✅ Run sample generation: `python3 test_resume_automation.py`
2. ✅ Review outputs in `outputs/applications/`
3. ✅ Set up email method in `.env`
4. ✅ Test email delivery: `python3 email_delivery_system.py`
5. ✅ Generate for all top jobs: `python3 resume_cover_letter_automation.py`
6. ✅ Review and send applications

## 📞 Support

All files integrated with your existing job search system:
- ✅ Resume optimization (ATS-friendly)
- ✅ Cover letter personalization
- ✅ Email tracking & logging
- ✅ Database integration (data/job_search.db)
- ✅ Profile customization (config/profile.json)

---

**Status:** ✅ Ready to deploy  
**Emails:** contact@simondatalab.de, sn@gmail.com  
**Date:** November 10, 2025
