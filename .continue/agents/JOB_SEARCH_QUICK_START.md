# 🎯 Job Search Agent - Quick Start Guide

## Overview

The Job Search Agent is a comprehensive AI-powered assistant to help you:
- **Discover** relevant job opportunities
- **Track** your applications and progress
- **Automate** outreach and follow-ups
- **Analyze** your job search metrics
- **Integrate** with LinkedIn for maximum visibility

## Installation

### 1. Make scripts executable

```bash
chmod +x ~/.job_search_agent/job_search_agent.py
chmod +x ~/.job_search_agent/job_search_dashboard.py
```

### 2. Create symlinks for easy access

```bash
ln -sf ~/.job_search_agent/job_search_agent.py ~/bin/job-search
ln -sf ~/.job_search_agent/job_search_dashboard.py ~/bin/job-dashboard
```

## Quick Start

### Start Interactive Agent

```bash
python3 ~/.job_search_agent/job_search_agent.py --interactive
```

### View Dashboard

```bash
python3 ~/.job_search_agent/job_search_dashboard.py
# Then open ~/.job_search_agent/job_search_dashboard.html in your browser
```

### View Statistics

```bash
python3 ~/.job_search_agent/job_search_agent.py --stats
```

### Generate Weekly Report

```bash
python3 ~/.job_search_agent/job_search_agent.py --report
```

### List All Opportunities

```bash
python3 ~/.job_search_agent/job_search_agent.py --list
```

## Features

### 1. Add Job Opportunities
```bash
python3 ~/.job_search_agent/job_search_agent.py --interactive
# Select option 1: Add job opportunity
```

**What you can track:**
- Job title, company, location
- Salary range
- Job type (full-time, contract, part-time)
- Requirements and benefits
- Application deadline
- Custom notes

### 2. Track Applications
```bash
# Record an application
python3 ~/.job_search_agent/job_search_agent.py --interactive
# Select option 3: Record application

# Schedule follow-up automatically
# Default: 7 days from application
```

**Features:**
- Track application date
- Store cover letter and modified resume
- Schedule follow-ups
- Record interview dates and notes
- Track salary discussions

### 3. Generate Cover Letters
```bash
python3 ~/.job_search_agent/job_search_agent.py --interactive
# Select option 4: Generate cover letter
```

**AI-Generated Content:**
- Tailored to job description
- Includes your key skills
- Professional formatting
- Save to file for editing

### 4. Company Research
```bash
python3 ~/.job_search_agent/job_search_agent.py --interactive
# Select option 5: Research company
```

**Gather:**
- Company website and industry
- Size and locations
- Culture fit assessment
- Recent news
- Salary ranges
- Glassdoor ratings

### 5. Analytics & Reports

```bash
# View comprehensive statistics
python3 ~/.job_search_agent/job_search_agent.py --stats

# Generate weekly progress report
python3 ~/.job_search_agent/job_search_agent.py --report

# Open interactive dashboard
python3 ~/.job_search_agent/job_search_dashboard.py
```

**Metrics Tracked:**
- Total opportunities discovered
- Applications submitted
- Interview conversion rate
- Offer close rate
- Average match score
- Weekly progress against targets

## LinkedIn Integration

### 1. Setup LinkedIn Resources

```bash
python3 ~/.job_search_agent/linkedin_job_integration.py
```

This creates:
- LinkedIn profile optimization guide
- Recruiter tracking template
- 30-day outreach plan

### 2. Optimize Your Profile

Follow the generated guide to:
- Update headline (include "Open to Opportunities")
- Enhance About section
- Highlight key skills
- Request recommendations

### 3. Execute 30-Day Outreach Plan

```bash
# Follow the day-by-day plan to:
# - Research target recruiters
# - Send personalized connection requests
# - Engage with company content
# - Schedule informational interviews
```

### 4. Share Job Opportunities

```bash
# Use the integration to:
# - Share posted opportunities with your network
# - Generate engaging LinkedIn post copy
# - Track recruiter responses
```

## Configuration

Edit your preferences in `~/.job_search_agent/config.json`:

```json
{
  "user_name": "Your Name",
  "current_role": "Your Role",
  "desired_roles": ["Role 1", "Role 2", "Role 3"],
  "skills": ["Skill1", "Skill2", "Skill3"],
  "preferences": {
    "min_salary": 120000,
    "max_salary": 250000,
    "locations": ["Remote", "Berlin"],
    "job_types": ["full-time", "contract"],
    "visa_sponsorship_required": false
  },
  "targets": {
    "applications_per_week": 5,
    "interview_rate_target": 0.2,
    "offer_close_rate_target": 0.3
  }
}
```

## Workflow Examples

### Example 1: Weekly Workflow

```bash
# Monday: Check for new opportunities
python3 ~/.job_search_agent/job_search_agent.py --list

# Tuesday: Add 3-5 new jobs
python3 ~/.job_search_agent/job_search_agent.py --interactive

# Wednesday: Record applications
python3 ~/.job_search_agent/job_search_agent.py --interactive

# Thursday: Engage on LinkedIn
# (Use LinkedIn integration to reach out to recruiters)

# Friday: Check progress
python3 ~/.job_search_agent/job_search_agent.py --report
python3 ~/.job_search_agent/job_search_dashboard.py
```

### Example 2: Application to Interview

```bash
# 1. Discover job
python3 ~/.job_search_agent/job_search_agent.py --interactive
# Add opportunity

# 2. Research company
python3 ~/.job_search_agent/job_search_agent.py --interactive
# Research company section

# 3. Generate cover letter
python3 ~/.job_search_agent/job_search_agent.py --interactive
# Generate cover letter option

# 4. Record application
python3 ~/.job_search_agent/job_search_agent.py --interactive
# Record application + schedule 7-day follow-up

# 5. Follow up on day 7
# Agent reminds you of follow-up
python3 ~/.job_search_agent/job_search_agent.py --report
# Check upcoming follow-ups section

# 6. Interview prep
# Review interview date and generate Q&A (future feature)
```

## Best Practices

### ✅ DO

- **Update regularly**: Add jobs as you find them
- **Personalize outreach**: Use company research in applications
- **Track everything**: Record all interactions
- **Follow up**: Schedule and execute follow-ups
- **Analyze metrics**: Review weekly report to improve
- **Optimize profile**: Keep LinkedIn profile updated

### ❌ DON'T

- Don't send generic applications
- Don't forget to follow up
- Don't skip company research
- Don't ignore your metrics
- Don't let applications pile up
- Don't neglect LinkedIn engagement

## Directory Structure

```
~/.job_search_agent/
├── config.json                    # Your preferences
├── opportunities/                 # Job opportunities (JSON)
├── applications/                  # Applications tracking (JSON)
├── companies/                     # Company research (JSON)
├── documents/                     # Generated cover letters
├── reports/                       # Weekly reports
└── linkedin_integration/          # LinkedIn resources
    ├── linkedin_profile_optimization.txt
    ├── recruiter_tracking.json
    └── 30day_outreach_plan.txt
```

## Command Reference

| Command | Purpose |
|---------|---------|
| `--interactive` | Start interactive menu |
| `--stats` | View statistics |
| `--report` | Generate weekly report |
| `--list` | List all opportunities |

## Troubleshooting

### "File not found" error
- Make sure you've run the agent once: `python3 ~/.job_search_agent/job_search_agent.py --interactive`
- This creates the necessary directories

### Dashboard shows no data
- Make sure you've added opportunities first
- Run: `python3 ~/.job_search_agent/job_search_agent.py --interactive` and add some jobs

### Config changes not taking effect
- Edit `~/.job_search_agent/config.json`
- Restart the agent

## Integration with Other Tools

### Connect with Vietnamese Tutor Agent
- Your job search data is stored locally
- Can be accessed by other agents for insights
- Export reports as JSON for analysis

### Share Data
```bash
# Export as JSON
cat ~/.job_search_agent/opportunities/*.json > my_opportunities.json

# Export report as markdown
python3 ~/.job_search_agent/job_search_agent.py --report > job_search_report.txt
```

## Next Steps

1. **Run the agent**: `python3 ~/.job_search_agent/job_search_agent.py --interactive`
2. **Add your first opportunity**: Test the system
3. **Optimize LinkedIn**: Run integration and update profile
4. **Schedule weekly reviews**: Friday = Review day
5. **Track metrics**: Monitor conversion rates

## Support & Resources

- **Agent Documentation**: View inline help in interactive menu
- **Configuration**: Edit `config.json` for your preferences
- **Data Location**: All data stored in `~/.job_search_agent/`
- **Dashboard**: Visual overview at `~/.job_search_agent/job_search_dashboard.html`

## Pro Tips

💡 **Tip 1**: Set a reminder for Fridays to review your weekly report

💡 **Tip 2**: Keep your LinkedIn profile in sync with your job search goals

💡 **Tip 3**: Use the match score to prioritize high-fit opportunities

💡 **Tip 4**: Generate multiple versions of your cover letter for similar roles

💡 **Tip 5**: Track conversion rates and adjust your strategy accordingly

---

**Last Updated**: November 7, 2025  
**Version**: 1.0  
**Status**: Production Ready ✅

Happy job searching! 🎯
