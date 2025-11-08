#!/usr/bin/env python3
"""Local status summary for job-search agent and Vietnamese course generation.

Run this locally to get counts and a quick health snapshot of your job agent data
and the generated Vietnamese course assets.

Usage:
  python3 local_status_summary.py

The script reads your local home directory (for ~/.job_search_agent) so run it
on your machine.
"""
import os
import sys
import datetime


def human_mtime(path):
    try:
        ts = os.path.getmtime(path)
        return datetime.datetime.fromtimestamp(ts).isoformat(sep=' ', timespec='seconds')
    except Exception:
        return 'n/a'


def summarize_job_agent(job_dir):
    print('\n== Job Search Agent (~/.job_search_agent)')
    if not os.path.exists(job_dir):
        print(f'  Not found: {job_dir}!')
        print('  Run the job-search agent or point me at another path.')
        return

    entries = os.listdir(job_dir)
    print(f'  Path: {job_dir}')
    print(f'  Top-level entries: {len(entries)} -> {entries}')

    subdirs = ['opportunities', 'applications', 'companies', 'documents', 'reports', 'linkedin_integration']
    for d in subdirs:
        p = os.path.join(job_dir, d)
        if os.path.exists(p) and os.path.isdir(p):
            try:
                n = len(os.listdir(p))
            except Exception:
                n = 'err'
            print(f'    {d}: {n} items, last-modified: {human_mtime(p)}')
        else:
            print(f'    {d}: (missing)')


def summarize_generated(gen_dir):
    print('\n== Vietnamese course generated assets')
    if not os.path.exists(gen_dir):
        print(f'  Generated directory not found: {gen_dir}')
        return

    files = sorted(os.listdir(gen_dir))
    print(f'  Path: {gen_dir}')
    print(f'  Total files: {len(files)}')

    # audio files
    audio = [f for f in files if f.lower().endswith('.mp3')]
    print(f'  Audio files: {len(audio)}')

    # weekly assets
    weeks = {f for f in files if f.startswith('week')}
    weeks_by_n = {}
    for f in weeks:
        # weekN_xxx
        parts = f.split('_')
        if parts:
            w = parts[0]
            weeks_by_n.setdefault(w, []).append(f)

    for w in sorted(weeks_by_n.keys()):
        items = weeks_by_n[w]
        print(f'    {w}: {len(items)} files -> {sorted(items)}')

    # quick checks for expected files per week (1..8)
    expected_suffixes = ['lesson.html', 'quiz.gift', 'flashcards.csv', 'dialogue.txt']
    for i in range(1, 9):
        wk = f'week{i}_'
        present = [s for s in files if s.startswith(f'week{i}_')]
        if not present:
            print(f'    week{i}: MISSING all')
            continue
        missing = []
        for suf in expected_suffixes:
            name = f'week{i}_{suf}'
            if name not in files:
                missing.append(suf)
        if missing:
            print(f'    week{i}: MISSING -> {missing}')
        else:
            print(f'    week{i}: all expected files present')


def main():
    home = os.path.expanduser('~')
    job_dir = os.path.join(home, '.job_search_agent')
    gen_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'generated', 'professional'))

    print('Local status summary — run locally on your machine')
    print('Generated on:', datetime.datetime.now().isoformat(sep=' ', timespec='seconds'))

    summarize_job_agent(job_dir)
    summarize_generated(gen_dir)

    print('\nNext recommended commands:')
    print('  # Inspect job agent folders')
    print('  ls -la ~/.job_search_agent')
    print('  ls -la ~/.job_search_agent/opportunities | wc -l')
    print('\n  # Tail generation log (if running in background)')
    print(f"  tail -n 200 -f {os.path.abspath(os.path.join(os.path.dirname(__file__),'..','generation.log'))}")
    print('\n  # When ready, deploy to Moodle:')
    print('  python3 moodle_deployer.py --deploy-all --course-id 10  # requires ~/.moodle_token')


if __name__ == '__main__':
    main()
