"""CLI wrapper for ai_detector.py

Usage:
  python cli.py /path/to/digital_unicorn_outsource --json
"""
from __future__ import annotations
import argparse
import json
import os
from . import ai_detector


def main():
    ap = argparse.ArgumentParser(prog='du-ai-detector')
    ap.add_argument('path', nargs='?', default='.', help='Directory to scan')
    ap.add_argument('--json', action='store_true', help='Output JSON')
    args = ap.parse_args()
    path = os.path.abspath(args.path)
    res = ai_detector.detect_files(path)
    if args.json:
        print(json.dumps(res, indent=2))
    else:
        for p, r in res.items():
            if isinstance(r, dict) and 'score' in r:
                print(f"{p}: {r['verdict']} (score={r['score']})")
            else:
                print(f"{p}: error {r}")


if __name__ == '__main__':
    main()
