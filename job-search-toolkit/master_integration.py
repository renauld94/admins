"""
Master Integration Script
- Orchestrates: job discovery, resume tailoring for top matches, LinkedIn outreach trigger, and interview scheduler prep
- Intended to be run manually or scheduled as a final integration test

Usage:
  python3 master_integration.py --test
"""

import subprocess
import argparse
import sqlite3
from pathlib import Path
import json
import os
from resume_auto_adjuster import ResumeAutoAdjuster
from interview_scheduler import InterviewScheduler

BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / 'data'
OUT_DIR = BASE_DIR / 'outputs' / 'integration'
OUT_DIR.mkdir(parents=True, exist_ok=True)


def run_job_discovery():
    print('Running job discovery...')
    proc = subprocess.run(['/usr/bin/python3', 'epic_job_search_agent.py', 'daily'], capture_output=True, text=True)
    print(proc.stdout)
    if proc.returncode != 0:
        print('Job discovery returned non-zero exit code')
    return proc.returncode


def get_top_opportunities(limit=3):
    db_path = DATA_DIR / 'job_search.db'
    if not db_path.exists():
        print('Job database not found')
        return []
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    try:
        cur.execute('SELECT id, title, company, description, score FROM opportunities ORDER BY score DESC LIMIT ?', (limit,))
        rows = cur.fetchall()
    except Exception as e:
        print('Error querying opportunities:', e)
        rows = []
    conn.close()
    return rows


def tailor_resumes_for_opps(opps):
    adjuster = ResumeAutoAdjuster()
    tailored = []
    for row in opps:
        job_id, title, company, desc, score = row
        print(f'Tailoring resume for {title} @ {company} (score {score})')
        custom = adjuster.generate_custom_resume(title, desc, company, job_id)
        path = adjuster.save_resume(custom, job_id)
        tailored.append((job_id, title, company, path))
    return tailored


def schedule_sample_interview(company='Databricks'):
    sched = InterviewScheduler()
    interview = sched.schedule_interview(
        job_title='Senior Data Engineer',
        company=company,
        interviewer_name='Recruiter',
        interviewer_email='recruiter@example.com',
        interview_date='2025-11-20',
        interview_time='14:00',
        duration_minutes=45,
        interview_type='Phone Screen',
        round_number=1
    )
    print('Scheduled interview (demo):', interview)
    return interview


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--test', action='store_true')
    args = parser.parse_args()

    if args.test:
        print('=== MASTER INTEGRATION TEST ===')
        run_job_discovery()
        opps = get_top_opportunities(2)
        if opps:
            tailor_resumes_for_opps(opps)
        else:
            print('No opportunities to tailor for')
        print('Integration test complete')

if __name__ == '__main__':
    main()
