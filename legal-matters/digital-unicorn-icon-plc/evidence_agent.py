#!/usr/bin/env python3
"""
evidence_agent.py

Local orchestrator for the forensic evidence pipeline.

Runs these steps (idempotent where possible):
- ensure evidence folders exist
- use existing AllMail.mbox (or extract from takeout zip if missing)
- parse mbox for bounce/delivery messages and write .eml + manifest
- classify images under digital_unicorn_outsource and write CSV
- collect chat metadata (shared_conversations.json) into evidence folder
- create top-candidates CSV and a small markdown summary
- generate a draft demand letter with exhibit references

Usage: python3 evidence_agent.py
"""
import os
import sys
import mailbox
import re
import csv
import hashlib
import shutil
from datetime import datetime
from email.utils import parsedate_to_datetime


BASE = os.path.dirname(__file__)
EVID_DIR = os.path.join(BASE, 'DEEP_EVIDENCE_CAPTURE_20251107')
MB_DIR = os.path.join(EVID_DIR, 'mbox_matches')
OUTSOURCE_DIR = os.path.join(BASE, 'digital_unicorn_outsource')

BOUNCE_PATTERNS = re.compile(r'(?i)(mailer-daemon|mail delivery subsystem|550 5\.2\.1|the email account that you tried to reach is inactive|delivery to the following recipient failed|disabled user|bounce|undeliverable|recipient address rejected)')


def ensure_dirs():
    os.makedirs(EVID_DIR, exist_ok=True)
    os.makedirs(MB_DIR, exist_ok=True)


def extract_mbox_from_takeout():
    # If AllMail.mbox already exists in EVID_DIR, skip
    mbox_path = os.path.join(EVID_DIR, 'AllMail.mbox')
    if os.path.exists(mbox_path):
        print('AllMail.mbox already present:', mbox_path)
        return mbox_path

    # Look for takeout parts under /tmp/fab_takeouts
    candidate = '/tmp/fab_takeouts/takeout-20251104T155928Z-2-001.zip'
    if os.path.exists(candidate):
        print('Extracting All Mail mbox from takeout:', candidate)
        import subprocess
        try:
            subprocess.check_call(['unzip', '-p', candidate, 'Takeout/Mail/All mail Including Spam and Trash.mbox'], stdout=open(mbox_path, 'wb'))
            print('Extraction complete:', mbox_path)
            return mbox_path
        except Exception as e:
            print('Failed to extract mbox from takeout:', e)
            return None
    else:
        print('No takeout zip found at expected path; please provide AllMail.mbox manually if needed')
        return None


def parse_mbox_and_extract_bounces(mbox_path):
    if not mbox_path or not os.path.exists(mbox_path):
        print('mbox not found, skipping parse')
        return 0

    manifest = os.path.join(MB_DIR, 'mbox_manifest.csv')
    count = 0
    with open(manifest, 'w', newline='') as mf:
        writer = csv.writer(mf)
        writer.writerow(['filename','sha256','date','subject','from','message-id'])
        mbox = mailbox.mbox(mbox_path)
        total = len(mbox)
        print(f'Parsing mbox ({total} messages) for bounce patterns...')
        for idx, msg in enumerate(mbox):
            try:
                # build compact text for search
                hdrs = []
                for k in ('from','to','cc','subject','date','message-id','return-path'):
                    v = msg.get(k)
                    if v:
                        hdrs.append(f'{k}: {v}')
                headers_text = '\n'.join(hdrs)
                body = ''
                if msg.is_multipart():
                    for part in msg.walk():
                        if part.get_content_type() == 'text/plain':
                            p = part.get_payload(decode=True)
                            if p:
                                body += p.decode('utf-8', 'ignore')
                else:
                    p = msg.get_payload(decode=True)
                    if p:
                        body = p.decode('utf-8', 'ignore')
                text = headers_text + '\n' + (body[:20000])
                if BOUNCE_PATTERNS.search(text):
                    fname = os.path.join(MB_DIR, f'bounce_{idx:06d}.eml')
                    with open(fname, 'wb') as fh:
                        fh.write(msg.as_bytes())
                    with open(fname, 'rb') as fh:
                        sha = hashlib.sha256(fh.read()).hexdigest()
                    writer.writerow([os.path.basename(fname), sha, msg.get('date',''), msg.get('subject',''), msg.get('from',''), msg.get('message-id','')])
                    count += 1
            except Exception as e:
                print('ERR parsing message', idx, e)
    print(f'Extracted {count} matching messages to', MB_DIR)
    return count


def classify_outsource_images():
    out_csv = os.path.join(EVID_DIR, 'screenshot_classification.csv')
    rows = []
    if not os.path.exists(OUTSOURCE_DIR):
        print('Outsource directory not found:', OUTSOURCE_DIR)
        return 0
    for root, dirs, files in os.walk(OUTSOURCE_DIR):
        for f in files:
            if not f.lower().endswith(('.png','.jpg','.jpeg','.webp','.gif')):
                continue
            path = os.path.join(root, f)
            kind = 'unknown'
            fname = f.lower()
            if 'dalle' in root.lower() or 'dalle' in fname or 'dall' in fname:
                kind = 'dalle-ai'
            elif 'screenshot' in fname or 'screen' in fname or 'ss' in fname:
                kind = 'screenshot'
            elif 'video' in fname or 'frame' in fname:
                kind = 'video-frame'
            else:
                # heuristics by dimension could be added, but keep simple
                kind = 'capture'
            rows.append({'filename': os.path.relpath(path, OUTSOURCE_DIR), 'path': path, 'type': kind})
    with open(out_csv, 'w', newline='') as cf:
        w = csv.DictWriter(cf, fieldnames=['filename','path','type'])
        w.writeheader()
        for r in rows:
            w.writerow(r)
    print('Wrote image classification CSV:', out_csv)
    return len(rows)


def collect_chat_metadata():
    found = 0
    targets = ['shared_conversations.json','message_feedback.json']
    for root, dirs, files in os.walk(os.path.dirname(BASE)):
        for t in targets:
            if t in files:
                src = os.path.join(root, t)
                dst = os.path.join(EVID_DIR, os.path.basename(src))
                try:
                    if os.path.abspath(src) == os.path.abspath(dst):
                        print('Skipping copy; source is same as destination:', src)
                        continue
                    shutil.copy2(src, dst)
                    print('Copied chat metadata:', src, '->', dst)
                    found += 1
                except shutil.SameFileError:
                    print('Skipping same file copy for', src)
                except Exception as e:
                    print('Failed to copy', src, e)
    if found == 0:
        print('No chat metadata files found under', os.path.dirname(BASE))
    return found


def create_top_candidates_summary():
    mbox_manifest = os.path.join(MB_DIR, 'mbox_manifest.csv')
    if not os.path.exists(mbox_manifest):
        print('mbox manifest missing, cannot create top candidates')
        return 0
    rows = []
    with open(mbox_manifest, newline='') as mf:
        r = csv.DictReader(mf)
        for rec in r:
            rows.append(rec)
    # simple scoring similar to earlier
    def score(r):
        s = 0
        subj = (r.get('subject') or '').lower()
        frm = (r.get('from') or '').lower()
        if re.search(r'mail delivery subsystem|delivery status notification|delivery failure|undeliverable|returned mail', subj):
            s += 50
        if 'mailer-daemon' in frm or 'mailer-daemon' in r.get('filename',''):
            s += 40
        try:
            dt = parsedate_to_datetime(r.get('date',''))
            if dt.tzinfo is not None:
                dt = dt.astimezone(tz=None).replace(tzinfo=None)
            days = abs((dt - datetime(2025,10,29)).days)
            if days == 0:
                s += 30
            elif days <= 3:
                s += 20
        except Exception:
            pass
        return s

    scored = []
    for rec in rows:
        rec['score'] = score(rec)
        scored.append(rec)
    scored.sort(key=lambda x: int(x.get('score',0)), reverse=True)
    top = scored[:20]
    out_csv = os.path.join(MB_DIR, 'candidates_bounce_top20.csv')
    with open(out_csv, 'w', newline='') as outf:
        w = csv.DictWriter(outf, fieldnames=['filename','date','subject','from','message-id','sha256','score'])
        w.writeheader()
        for r in top:
            w.writerow({k: r.get(k,'') for k in w.fieldnames})
    out_md = os.path.join(MB_DIR, 'CANDIDATE_BOUNCE_EXHIBITS.md')
    with open(out_md, 'w') as md:
        md.write('# Candidate Bounce Exhibits — Top 20\n\n')
        md.write('Scored by subject/from/date proximity to 2025-10-29.\n\n')
        md.write('|Rank|Filename|Date|From|Subject|Score|\n')
        md.write('|-:|:-|:-|:-|:-|:-:|\n')
        for i,r in enumerate(top, start=1):
            subj = (r.get('subject') or '')[:80].replace('|','\\\\|')
            from_s = (r.get('from') or '')[:40].replace('|','\\\\|')
            md.write('|%d|%s|%s|%s|%s|%s|\\n' % (i, r.get('filename',''), r.get('date',''), from_s, subj, r.get('score')))
    print('Top candidates summary written:', out_csv, out_md)
    return len(top)


def generate_demand_letter():
    letter = os.path.join(EVID_DIR, 'DEMAND_LETTER_DRAFT.md')
    with open(letter, 'w') as f:
        f.write('# Draft Demand Letter\n\n')
        f.write('To: ICON PLC / Digital Unicorn Services\n\n')
        f.write('Re: Contract 0925/CONSULT/DU — Evidence of non-payment, account deactivation, and scope abuse.\n\n')
        f.write('Summary of key exhibits (automatically generated):\n\n')
        f.write('- `EXHIBIT_LUCAS_OCT10_PROMISE.txt` — payment promise (if present)\n')
        f.write('- Bounce evidence: see `mbox_matches/candidates_bounce_top20.csv` and selected `mbox_matches/bounce_*.eml`\n')
        f.write('- Screenshots & AI images: `screenshot_classification.csv` and `dalle_samples/` in evidence folder\n')
        f.write('\nPlease find attached exhibits and contact the undersigned to resolve this matter within 7 days.\n')
    print('Draft demand letter written:', letter)
    return letter


def main():
    ensure_dirs()
    # extract or use existing mbox
    mbox_path = os.path.join(EVID_DIR, 'AllMail.mbox')
    if not os.path.exists(mbox_path):
        mbox_path = extract_mbox_from_takeout()
    else:
        print('Using existing mbox at', mbox_path)

    parse_mbox_and_extract_bounces(mbox_path)
    classify_outsource_images()
    collect_chat_metadata()
    create_top_candidates_summary()
    generate_demand_letter()
    print('\nEvidence agent run complete. See', EVID_DIR)


if __name__ == '__main__':
    main()
