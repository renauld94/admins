# LinkedIn Company Page Automation - Complete Guide

**Created**: November 4, 2025  
**Company Page ID**: 105307318  
**Owner**: Simon Renauld  

---

## 🎯 What This Does

Complete automation suite for LinkedIn Company Page management:

1. **Content Generation** - Automatically creates posts from your:
   - Moodle courses
   - Portfolio case studies (simondatalab.de)
   - Homelab/infrastructure updates
   - Thought leadership topics

2. **Post Scheduling** - Queue posts for optimal engagement times
   - Monday 9am: Thought leadership
   - Wednesday 10am: Technical content
   - Friday 2pm: Case studies

3. **Automated Publishing** - Browser automation via Playwright
   - Text posts
   - Image carousels
   - PDF documents (LinkedIn carousels)
   - Link previews

4. **Analytics Tracking** - Scrape and analyze:
   - Follower growth
   - Post engagement (impressions, clicks, reactions)
   - Demographic data
   - Competitor benchmarks

5. **Reporting** - Generate weekly reports with:
   - Performance metrics
   - Growth trends
   - Content recommendations
   - Next steps

---

## 🚀 Quick Start

### 1. Installation

```bash
cd /home/simon/Learning-Management-System-Academy/linkedin-automation
./setup.sh
```

This will:
- Create Python virtual environment
- Install all dependencies (Playwright, Pillow, etc.)
- Install Playwright browsers
- Create directory structure
- Copy `.env.example` to `.env`

### 2. Configuration

Edit `.env` with your LinkedIn credentials:

```bash
nano .env
```

**Required:**
- `LINKEDIN_EMAIL`: Your LinkedIn email
- `LINKEDIN_PASSWORD`: Your LinkedIn password
- `COMPANY_PAGE_ID`: 105307318

**Optional:**
- `MOODLE_URL`: https://moodle.simondatalab.de
- `MOODLE_TOKEN`: (for course integration)
- `OPENAI_API_KEY`: (for AI content generation)

### 3. Test Setup

```bash
# Activate virtual environment
source venv/bin/activate

# Generate test content
python content_generator.py healthcare

# Test posting (will prompt for confirmation)
python company_page_automation.py post "Test post from automation suite"
```

---

## 📋 Usage

### Content Generation

```bash
# Generate weekly content (3 posts)
python content_generator.py weekly

# Generate specific content types
python content_generator.py healthcare   # Healthcare analytics post
python content_generator.py homelab      # Homelab update post
python content_generator.py governance   # Data governance post
```

### Manual Posting

```bash
# Text post
python company_page_automation.py post "Your content here"

# Image post
python company_page_automation.py post "Content" --image path/to/image.png

# Document post (PDF carousel)
python company_page_automation.py post "Content" --document path/to/carousel.pdf
```

### Scheduled Posting

```bash
# Setup weekly schedule
python orchestrator.py setup

# Publish pending posts
python orchestrator.py publish

# View schedule
cat config/post_schedule.json
```

### Analytics

```bash
# Scrape company page analytics
python analytics_tracker.py scrape-page

# Scrape post metrics
python analytics_tracker.py scrape-posts

# Generate weekly report
python analytics_tracker.py report
```

### Full Automation

```bash
# Daily workflow (publish + analytics)
python orchestrator.py daily

# Weekly workflow (setup content + report)
python orchestrator.py weekly
```

---

## ⏰ Automated Workflows (Cron)

Add to crontab for full automation:

```bash
crontab -e
```

Add these lines:

```bash
# Daily workflow: Publish pending posts + scrape analytics (Mon-Fri 10am)
0 10 * * 1-5 cd /home/simon/Learning-Management-System-Academy/linkedin-automation && ./venv/bin/python orchestrator.py daily >> logs/cron_daily.log 2>&1

# Weekly workflow: Setup next week's content + generate report (Sunday 6pm)
0 18 * * 0 cd /home/simon/Learning-Management-System-Academy/linkedin-automation && ./venv/bin/python orchestrator.py weekly >> logs/cron_weekly.log 2>&1

# Analytics only: Scrape metrics (Daily 8am)
0 8 * * * cd /home/simon/Learning-Management-System-Academy/linkedin-automation && ./venv/bin/python analytics_tracker.py scrape-page >> logs/cron_analytics.log 2>&1
```

---

## 📁 Directory Structure

```
linkedin-automation/
├── setup.sh                          # Setup script (run first)
├── .env.example                      # Environment template
├── requirements.txt                  # Python dependencies
│
├── company_page_automation.py        # Core posting automation
├── content_generator.py              # Content generation
├── analytics_tracker.py              # Analytics scraping
├── orchestrator.py                   # Workflow orchestration
│
├── config/
│   ├── post_schedule.json           # Scheduled posts
│   └── portfolio_alignment.json     # Brand config
│
├── content/                          # Content templates
├── outputs/
│   ├── generated_content/           # Generated posts (JSON)
│   ├── analytics/                   # Analytics data (JSON, CSV)
│   ├── reports/                     # Weekly reports (TXT)
│   ├── screenshots/                 # Post previews
│   └── logs/                        # Automation logs
│
└── guides/                           # Documentation
```

---

## 🎨 Content Strategy

### Weekly Posting Schedule

**Monday 9am** - Thought Leadership
- Healthcare analytics insights
- Data engineering best practices
- Industry trends

**Wednesday 10am** - Technical Content
- Homelab updates (ProxmoxMCP, Jellyfin)
- Infrastructure projects
- Tool comparisons

**Friday 2pm** - Case Studies
- Portfolio achievements
- Client success stories
- Metrics-driven outcomes

### Content Templates

1. **Healthcare Analytics** - Focus on:
   - 500M+ records processed
   - 85% research cycle acceleration
   - 100% HIPAA compliance
   - 99.9% system reliability

2. **Homelab/MLOps** - Highlight:
   - ProxmoxMCP automation
   - AI-native infrastructure
   - Cost-efficient ML experimentation
   - Private data residency

3. **Data Governance** - Emphasize:
   - Automated compliance
   - Data lineage tracking
   - Access controls
   - Audit trails

### Brand Voice

- **Tone**: Professional, metrics-first, action-oriented
- **No emojis** in company page posts
- **Max length**: 1,300 characters
- **Hashtags**: 3 max per post
- **CTA**: Always include link to portfolio/course

---

## 📊 Analytics & Metrics

### Key Metrics Tracked

1. **Follower Growth**
   - Daily/weekly/monthly growth rate
   - Net follower change
   - Growth velocity

2. **Post Engagement**
   - Impressions
   - Clicks (CTR)
   - Reactions
   - Comments
   - Shares
   - Engagement rate: (reactions + comments + shares) / impressions × 100

3. **Demographics**
   - Top locations
   - Top industries
   - Job functions
   - Seniority levels

### Weekly Report Includes

- Current follower count
- Week-over-week growth
- Average daily page views
- Top performing posts
- Engagement trends
- Content recommendations
- Competitor benchmarks

---

## 🔒 Security & Safety

### Rate Limiting

**Built-in protections:**
- Max 3 posts/day
- Max 10 posts/week
- Min 4 hours between posts
- 1-minute delay between automation actions

**Why?** LinkedIn monitors for bot behavior. Stay conservative.

### Credentials

- **Never commit** `.env` to git (already in `.gitignore`)
- **Encrypt sensitive data** using Fernet encryption
- **Use environment variables** for all secrets
- **Rotate passwords** quarterly

### Browser Automation

- **Headless mode** by default (set `HEADLESS_BROWSER=false` for debugging)
- **User-agent spoofing** to appear as regular browser
- **Random delays** to mimic human behavior
- **Screenshot previews** before posting (manual review)

---

## 🐛 Troubleshooting

### Setup Issues

**Problem**: `playwright install` fails
```bash
# Install system dependencies first
sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1
python -m playwright install chromium
```

**Problem**: Import errors
```bash
# Ensure virtual environment is activated
source venv/bin/activate
pip install --upgrade -r requirements.txt
```

### Automation Issues

**Problem**: Login fails
- Check LinkedIn credentials in `.env`
- LinkedIn may require 2FA - use app password or temporarily disable
- Try with `HEADLESS_BROWSER=false` to see login screen

**Problem**: Selectors not working
- LinkedIn UI changes frequently
- Update CSS selectors in `company_page_automation.py`
- Run with headless=false to inspect elements

**Problem**: Posts not publishing
- Check schedule file: `cat config/post_schedule.json`
- Verify scheduled time is in the past
- Check logs: `tail -f outputs/logs/orchestrator_*.log`

### Analytics Issues

**Problem**: Analytics not scraped
- LinkedIn analytics may have changed layout
- Update selectors in `analytics_tracker.py`
- Check if company page has analytics enabled (requires admin access)

---

## 📈 Optimization Tips

### Maximize Engagement

1. **Post timing**: Monday/Wednesday/Friday mornings (9-11am)
2. **Content mix**: 40% thought leadership, 30% case studies, 30% technical
3. **Visuals**: Posts with images get 2x engagement
4. **Hashtags**: Use 3 relevant hashtags per post
5. **Links**: Always include portfolio/course link

### Growth Strategies

1. **Cross-promote**: Share company posts from personal profile
2. **Employee advocacy**: Tag team members (if applicable)
3. **Engage**: Respond to comments within 24 hours
4. **Consistency**: Stick to posting schedule (2-3x/week minimum)
5. **Quality over quantity**: Focus on high-value content

### Content Ideas

**Monthly themes:**
- Week 1: Healthcare data challenges
- Week 2: Homelab innovations
- Week 3: Data governance deep-dive
- Week 4: Course/training spotlight

**Evergreen topics:**
- ETL/ELT pipeline design
- HIPAA compliance automation
- MLOps on-premise
- Data quality frameworks
- Career advice for data engineers

---

## 🔄 Maintenance

### Weekly

- Review scheduled posts: `cat config/post_schedule.json`
- Check analytics: `python analytics_tracker.py report`
- Verify cron jobs ran: `tail logs/cron_*.log`

### Monthly

- Update content templates in `content_generator.py`
- Review engagement metrics for content optimization
- Update portfolio alignment: `config/portfolio_alignment.json`
- Check LinkedIn UI for selector changes

### Quarterly

- Rotate LinkedIn password
- Update Python dependencies: `pip install --upgrade -r requirements.txt`
- Backup analytics data: `tar -czf analytics_backup.tar.gz outputs/analytics/`
- Review and archive old logs

---

## 🎓 Next Steps

### Phase 1: Foundation (Week 1) ✅
- [x] Setup automation suite
- [x] Configure environment
- [x] Test manual posting
- [x] Generate sample content

### Phase 2: Automation (Week 2)
- [ ] Run daily workflow for 7 days
- [ ] Monitor analytics trends
- [ ] Adjust posting schedule based on engagement
- [ ] Setup cron jobs

### Phase 3: Optimization (Week 3)
- [ ] A/B test content formats
- [ ] Analyze top-performing posts
- [ ] Cross-promote with personal profile
- [ ] Engage with followers

### Phase 4: Scale (Week 4+)
- [ ] Apply for LinkedIn API access (optional)
- [ ] Integrate with Moodle for course updates
- [ ] Automate portfolio → LinkedIn sync
- [ ] Build analytics dashboard

---

## 🤝 Support

For issues or questions:
- **Email**: simon@simondatalab.de
- **LinkedIn**: [linkedin.com/in/simonrenauld](https://www.linkedin.com/in/simonrenauld)
- **Portfolio**: [simondatalab.de](https://www.simondatalab.de/)

---

## 📄 License

Personal use only. Not for redistribution.

© 2025 Simon Renauld. All rights reserved.
