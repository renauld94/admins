Job Search Automation - Local README

This folder contains automation scripts for job discovery, LinkedIn outreach, resume tailoring, interview scheduling, and a Streamlit dashboard.

Quick commands

Run job discovery now:

```bash
cd /home/simon/Learning-Management-System-Academy/job-search-toolkit
/usr/bin/python3 epic_job_search_agent.py daily
```

Run LinkedIn outreach:

```bash
/usr/bin/python3 daily_linkedin_outreach.py
```

Run Resume Auto-Adjuster (example):

```bash
/usr/bin/python3 resume_auto_adjuster.py
```

Run Interview Scheduler demo:

```bash
/usr/bin/python3 interview_scheduler.py
```

Run Streamlit dashboard:

```bash
streamlit run streamlit_dashboard.py
```

Master integration test:

```bash
/usr/bin/python3 master_integration.py --test
```

Notes

- The Interview Scheduler creates a local SQLite DB at `data/interview_scheduler.db` and stores invites in `outputs/interviews`.
- The Resume Auto-Adjuster writes tailored resumes to `outputs/resumes`.
- The Streamlit dashboard reads local databases in `data/` and renders charts.
- Installing dependencies: `pip install -r requirements.txt` (prefer a virtualenv)
