"""Powerful AI Detector Report Generator

This script generates detailed reports from AI detection results.
Use it to export analyses in various formats for further review.
"""
from __future__ import annotations
import argparse
import json
import os
import sys

# Add the current directory to the path so we can import ai_detector
sys.path.insert(0, os.path.dirname(__file__))
from ai_detector import detect_files, generate_report


def main():
    ap = argparse.ArgumentParser(description='Generate AI detection reports')
    ap.add_argument('folder', help='Folder to analyze')
    ap.add_argument('--format', choices=['markdown', 'html', 'csv', 'json'], default='markdown', help='Report format')
    ap.add_argument('--output', required=True, help='Output file path')
    ap.add_argument('--threshold', type=float, default=0.5, help='Score threshold for flagging')
    ap.add_argument('--patterns', nargs='*', default=['*.txt', '*.md', '*.html', '*.py', '*.ipynb'], help='File patterns to include')
    ap.add_argument('--exclude', nargs='*', default=[], help='Files to exclude from analysis')
    args = ap.parse_args()

    print(f"Analyzing folder: {args.folder}")
    results = detect_files(args.folder, tuple(args.patterns), exclude_files=args.exclude)
    print(f"Analyzed {len(results)} files")

    report = generate_report(results, args.format, args.threshold)

    with open(args.output, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"Report saved to: {args.output}")
    print(f"Format: {args.format}, Threshold: {args.threshold}")


if __name__ == '__main__':
    main()
