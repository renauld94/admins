#!/usr/bin/env python3
"""
Post a concise scan summary to the local Ollama API and save the JSON response
as `legal_report.json` in the repository root.

Usage: python3 tools/run_legal_agent_small.py
Environment variables:
  API_BASE (default: https://ollama.simondatalab.de)
  MODEL (default: deepseek-coder:6.7b)
"""
import json
import os
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

API_BASE = os.environ.get('API_BASE', 'https://ollama.simondatalab.de').rstrip('/')
MODEL = os.environ.get('MODEL', 'deepseek-coder:6.7b')

# Build a concise summary (derived from the detailed scan_summary.json)
try:
    full_scan = json.load(open('scan_summary.json'))
except Exception as e:
    print('Failed to open scan_summary.json:', e)
    raise

# Reduce the scan to a concise summary to avoid huge payloads
concise = {
    'flagged_files': len(full_scan.get('files', [])),
    'top_files': [f['path'] for f in sorted(full_scan.get('files', []), key=lambda x: len(x.get('matches', [])), reverse=True)[:10]],
    'key_files_present': {p: any(x['path'].endswith(p) for x in full_scan.get('files', [])) for p in ['user.json','conversations.json','shared_conversations.json','upload_to_moodle.sh','check_moodle_workspace.sh']}
}

prompt = (
    "You are the Legal Advisor Agent.\n\n"
    "Using the concise scan summary below, produce a structured JSON report matching this schema:\n"
    "{summary:string, findings:[{id,severity (Critical|High|Medium|Low),type (license|pii|data-export|vulnerability|other),files[],description,suggested_fix}], actions:[{step,priority,commands[],notes}]}\n\n"
    "Focus on critical and high severity issues; include exact file paths and practical remediation commands. Return ONLY valid JSON that conforms to the schema.\n\n"
    "ConciseScan:\n" + json.dumps(concise, indent=2)
)

payload = {'model': MODEL, 'prompt': prompt, 'max_tokens': 1800, 'temperature': 0.02}
url = API_BASE + '/api/generate'
req = Request(url, data=json.dumps(payload).encode('utf-8'), headers={'Content-Type': 'application/json'})

print('Posting to', url, 'model', MODEL)
try:
    with urlopen(req, timeout=120) as resp:
        out = resp.read().decode('utf-8', errors='replace')
        # attempt to parse JSON; if it is plain text containing JSON, try to extract
        try:
            parsed = json.loads(out)
            open('legal_report.json','w').write(json.dumps(parsed, indent=2))
            print('Saved legal_report.json (parsed JSON)')
        except Exception:
            # save raw response
            open('legal_report.json','w').write(out)
            print('Saved legal_report.json (raw response)')
        print('\n--- head of response ---\n')
        print(out[:2000])
except HTTPError as e:
    print('HTTP error', e.code, e.reason)
    try:
        print(e.read().decode())
    except Exception:
        pass
except URLError as e:
    print('URL error', e.reason)
except Exception as e:
    print('Unexpected', e)
