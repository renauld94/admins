"""Generate a visual matrix display for AI detection results."""
from __future__ import annotations
import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from ai_detector import detect_files

def generate_matrix_html(v1_results: dict, v2_results: dict, threshold: float = 0.5) -> str:
    """Generate HTML matrix comparing V1 and V2 results."""
    html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>AI Detection Matrix - V1 vs V2</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        h1 {{ color: #333; }}
        table {{ border-collapse: collapse; width: 100%; margin-top: 20px; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #f2f2f2; }}
        tr:nth-child(even) {{ background-color: #f9f9f9; }}
        .ai {{ background-color: #ffe6e6; }}
        .human {{ background-color: #e6ffe6; }}
        .uncertain {{ background-color: #fff2e6; }}
        .score {{ font-weight: bold; }}
    </style>
</head>
<body>
    <h1>AI Detection Results Matrix</h1>
    <p>Comparing V1 and V2 folders. Threshold: {threshold}</p>
    <table>
        <tr>
            <th>File</th>
            <th>Folder</th>
            <th>Score</th>
            <th>Verdict</th>
            <th>AI Phrases</th>
            <th>Total Words</th>
        </tr>
"""

    all_results = []
    for path, res in v1_results.items():
        if 'score' in res:
            all_results.append((path, 'V1', res))
    for path, res in v2_results.items():
        if 'score' in res:
            all_results.append((path, 'V2', res))

    for path, folder, res in all_results:
        verdict_class = res['verdict'].lower()
        flagged = "flagged" if res['score'] >= threshold else ""
        html += f"""
        <tr class="{verdict_class} {flagged}">
            <td>{os.path.basename(path)}</td>
            <td>{folder}</td>
            <td class="score">{res['score']}</td>
            <td>{res['verdict']}</td>
            <td>{res['features'].get('ai_phrase_count', 0)}</td>
            <td>{res['features'].get('total_words', 0)}</td>
        </tr>
        """

    html += """
    </table>
    <p><strong>Legend:</strong> Red = AI, Green = Human, Orange = Uncertain</p>
</body>
</html>
"""
    return html

def main():
    ap = argparse.ArgumentParser(description='Generate visual matrix for AI detection')
    ap.add_argument('--v1', required=True, help='V1 folder path')
    ap.add_argument('--v2', required=True, help='V2 folder path')
    ap.add_argument('--output', required=True, help='Output HTML file')
    ap.add_argument('--threshold', type=float, default=0.5, help='Threshold for flagging')
    ap.add_argument('--exclude', nargs='*', default=[], help='Files to exclude')
    args = ap.parse_args()

    print("Analyzing V1...")
    v1_results = detect_files(args.v1, exclude_files=args.exclude)
    print("Analyzing V2...")
    v2_results = detect_files(args.v2, exclude_files=args.exclude)

    html = generate_matrix_html(v1_results, v2_results, args.threshold)

    with open(args.output, 'w', encoding='utf-8') as f:
        f.write(html)

    print(f"Matrix saved to: {args.output}")

if __name__ == '__main__':
    main()
