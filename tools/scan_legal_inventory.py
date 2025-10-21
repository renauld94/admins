#!/usr/bin/env python3
"""
Scan a folder for likely legal/privacy concerns and output a small JSON summary.
"""
import json, re, sys, os

ROOT = sys.argv[1] if len(sys.argv) > 1 else "digital_unicorn_outsource"
PATTERNS = {
    "upload_or_export": re.compile(r"\b(upload|upload_to_moodle|upload_to|export|push|publish)\b", re.I),
    "secrets": re.compile(r"\b(token|api_key|apikey|secret|password|passwd|PAT)\b", re.I),
    "user_fields": re.compile(r'"?(user|email|name|id|student|participant|conversation)"?\s*[:=]', re.I),
    "license": re.compile(r"\bMIT|Apache|GPL|BSD|LICENSE\b", re.I)
}

summary = {"root": ROOT, "files": []}

for dirpath, dirs, files in os.walk(ROOT):
    for f in files:
        path = os.path.join(dirpath, f)
        try:
            text = open(path, "r", encoding="utf-8", errors="ignore").read()
        except Exception:
            continue
        matches = []
        for k, pat in PATTERNS.items():
            for m in pat.finditer(text):
                start = max(0, m.start()-60)
                snippet = text[start: m.end()+60].replace("\n","\\n")
                matches.append({"type": k, "match": m.group(0), "snippet": snippet[:800]})
        if matches:
            summary["files"].append({
                "path": path,
                "size": os.path.getsize(path),
                "matches": matches
            })

open("scan_summary.json","w").write(json.dumps(summary, indent=2))
print("Wrote scan_summary.json with", len(summary["files"]), "files flagged.")
