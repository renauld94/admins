"""Enhanced AI-generated text detector with improved accuracy and performance.

This module implements a more sophisticated heuristic detector that scores text
for likelihood of being AI-generated. It includes additional features for better
accuracy while remaining offline and lightweight.

API:
  analyze_text(text: str) -> dict
  detect_files(folder: str, patterns=('*.txt','*.md','*.html','*.py','*.ipynb')) -> dict
  generate_report(results: dict, format: str = 'markdown') -> str

The detector returns a score 0..1 where higher means more likely AI-generated,
plus per-feature breakdown used for the score.
"""
from __future__ import annotations
import math
import os
import re
import json
import csv
import io
from collections import Counter, defaultdict
from typing import List, Dict, Tuple, Optional
from concurrent.futures import ThreadPoolExecutor, as_completed

# Expanded helper sets for better detection
STOPWORDS = {
    "the", "and", "is", "in", "to", "of", "a", "that", "it", "for",
    "on", "with", "as", "this", "are", "was", "be", "by", "an",
    "i", "you", "he", "she", "we", "they", "me", "him", "her", "us", "them",
}

AI_PHRASES = [
    "as an ai", "as an ai language model", "as an ai model", "as an ai assistant",
    "i'm an ai", "i am an ai", "i cannot browse", "i don't have access",
    "i do not have access", "cannot provide", "unable to", "cannot help",
    "based on my training", "my knowledge cutoff", "i'm sorry but", "i apologize",
    "let me explain", "in other words", "to put it simply", "essentially",
]

FORMAL_CONNECTORS = {
    "however", "moreover", "furthermore", "nevertheless", "consequently",
    "therefore", "additionally", "in conclusion", "to summarize", "hence",
    "thus", "accordingly", "subsequently", "conversely", "similarly",
}

CONTRACTIONS = {
    "n't", "don't", "can't", "won't", "i'm", "it's", "they're", "we're",
    "you're", "he's", "she's", "that's", "there's", "here's", "where's",
}

# Simple unigram model for perplexity approximation (trained on common English)
UNIGRAM_FREQ = {
    'the': 0.07, 'and': 0.04, 'is': 0.03, 'in': 0.03, 'to': 0.03,
    'of': 0.03, 'a': 0.03, 'that': 0.02, 'it': 0.02, 'for': 0.02,
    # ... add more for better approximation, but keep lightweight
}
DEFAULT_UNIGRAM_PROB = 1e-6  # for unseen words


def _sentences(text: str) -> List[str]:
    # Improved sentence splitter with better regex
    parts = re.split(r'(?<=[.!?])\s+', text.strip())
    return [p.strip() for p in parts if p.strip()]


def _word_tokens(text: str) -> List[str]:
    return re.findall(r"\b\w+\b", text)


def _shannon_entropy(s: str) -> float:
    if not s:
        return 0.0
    counts = Counter(s)
    length = len(s)
    ent = sum(- (c / length) * math.log2(c / length) for c in counts.values())
    max_ent = math.log2(len(counts)) if len(counts) > 1 else 1.0
    return ent / max_ent if max_ent > 0 else 0.0


def _repeated_phrase_ratio(words: List[str], n: int = 4) -> float:
    if len(words) < n:
        return 0.0
    ngrams = [' '.join(words[i:i+n]).lower() for i in range(len(words)-n+1)]
    c = Counter(ngrams)
    repeats = sum(v - 1 for v in c.values() if v > 1)  # count extra occurrences
    return repeats / max(1, len(ngrams))


def _burstiness(sentences: List[str]) -> float:
    """Measure variation in sentence lengths (burstiness)."""
    if len(sentences) < 2:
        return 0.0
    lengths = [len(_word_tokens(s)) for s in sentences]
    mean_len = sum(lengths) / len(lengths)
    variance = sum((l - mean_len) ** 2 for l in lengths) / len(lengths)
    std_dev = math.sqrt(variance)
    return std_dev / max(1, mean_len)  # coefficient of variation


def _perplexity_approx(words: List[str]) -> float:
    """Simple unigram perplexity approximation."""
    if not words:
        return 1.0
    log_prob_sum = 0.0
    for w in words:
        prob = UNIGRAM_FREQ.get(w.lower(), DEFAULT_UNIGRAM_PROB)
        log_prob_sum += math.log2(prob)
    avg_log_prob = log_prob_sum / len(words)
    return 2 ** (-avg_log_prob)


def _syntactic_complexity(text: str) -> float:
    """Simple syntactic complexity based on punctuation and structure."""
    words = _word_tokens(text)
    sentences = _sentences(text)
    if not words or not sentences:
        return 0.0
    avg_words_per_sent = len(words) / len(sentences)
    punct_count = sum(1 for c in text if c in '.,;:!?()[]{}')
    punct_ratio = punct_count / len(text) if text else 0.0
    return (avg_words_per_sent / 20.0) + punct_ratio


def analyze_text(text: str) -> Dict[str, object]:
    """Analyze a single text and return a feature breakdown and score.

    Returns:
      { 'score': float,  # 0..1, higher means more likely AI
        'verdict': 'ai'|'human'|'uncertain',
        'features': { ... }
      }
    """
    if not text or not text.strip():
        return {'score': 0.0, 'verdict': 'uncertain', 'features': {}}

    text_l = text.lower()
    sentences = _sentences(text)
    words = _word_tokens(text)
    chars = [c for c in text if not c.isspace()]

    total_words = len(words)
    unique_words = len(set(w.lower() for w in words))

    avg_sentence_len = sum(len(_word_tokens(s)) for s in sentences) / max(1, len(sentences))
    avg_word_len = sum(len(w) for w in words) / max(1, total_words)
    stopword_ratio = sum(1 for w in words if w.lower() in STOPWORDS) / max(1, total_words)
    contraction_ratio = sum(1 for w in words if any(c in w.lower() for c in CONTRACTIONS)) / max(1, total_words)
    punctuation_ratio = sum(1 for c in text if c in '.,;:!?') / max(1, len(chars))
    repeated_ratio = _repeated_phrase_ratio(words, n=4)
    char_entropy = _shannon_entropy(''.join(chars))
    lexical_diversity = unique_words / max(1, total_words)
    formal_word_ratio = sum(1 for w in words if w.lower() in FORMAL_CONNECTORS) / max(1, total_words)
    short_sentence_ratio = sum(1 for s in sentences if len(_word_tokens(s)) <= 6) / max(1, len(sentences))

    # New features
    burstiness = _burstiness(sentences)
    perplexity = _perplexity_approx(words)
    syntactic_complexity = _syntactic_complexity(text)

    # detect direct AI phrases (strong signal)
    ai_phrase_count = sum(text_l.count(p) for p in AI_PHRASES)

    # Enhanced heuristic scoring with new features
    score = 0.0
    score += 0.25 * min(1.0, (avg_sentence_len / 20.0))
    score += 0.15 * min(1.0, formal_word_ratio * 10.0)
    score += 0.20 * (1.0 if ai_phrase_count > 0 else 0.0)
    score += 0.10 * (1.0 - min(1.0, contraction_ratio * 50.0))
    score += 0.10 * (1.0 - min(1.0, lexical_diversity))
    score += 0.05 * (1.0 - char_entropy)
    score += 0.05 * repeated_ratio
    score += 0.05 * min(1.0, burstiness * 2.0)  # AI text often has consistent lengths
    score += 0.05 * min(1.0, perplexity / 1000.0)  # Lower perplexity for AI
    score += 0.05 * syntactic_complexity

    # clamp
    score = max(0.0, min(1.0, score))

    if score >= 0.65:
        verdict = 'ai'
    elif score <= 0.35:
        verdict = 'human'
    else:
        verdict = 'uncertain'

    features = {
        'avg_sentence_len': avg_sentence_len,
        'avg_word_len': avg_word_len,
        'stopword_ratio': stopword_ratio,
        'contraction_ratio': contraction_ratio,
        'punctuation_ratio': punctuation_ratio,
        'repeated_phrase_ratio': repeated_ratio,
        'char_entropy_norm': char_entropy,
        'lexical_diversity': lexical_diversity,
        'formal_word_ratio': formal_word_ratio,
        'short_sentence_ratio': short_sentence_ratio,
        'burstiness': burstiness,
        'perplexity_approx': perplexity,
        'syntactic_complexity': syntactic_complexity,
        'ai_phrase_count': ai_phrase_count,
        'total_words': total_words,
    }

    return {'score': round(score, 3), 'verdict': verdict, 'features': features}


def detect_files(folder: str, patterns: Tuple[str, ...] = ('*.txt', '*.md', '*.html', '*.py', '*.ipynb'), max_workers: int = 4, exclude_files: Optional[List[str]] = None) -> Dict[str, dict]:
    """Scan text-like files under `folder` and return analysis per file.

    Uses parallel processing for better performance on large folders.
    """
    out = {}
    if not os.path.isdir(folder):
        raise FileNotFoundError(folder)

    files_to_process = []
    for root, dirs, files in os.walk(folder):
        for fn in files:
            lower = fn.lower()
            if any(lower.endswith(p.lstrip('*.')) for p in patterns):
                path = os.path.join(root, fn)
                if exclude_files and any(excl in path for excl in exclude_files):
                    continue  # Skip excluded files
                files_to_process.append(path)

    def process_file(path: str) -> Tuple[str, dict]:
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                txt = f.read()
            return path, analyze_text(txt)
        except Exception as e:
            return path, {'error': str(e)}

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [executor.submit(process_file, path) for path in files_to_process]
        for future in as_completed(futures):
            path, result = future.result()
            out[path] = result

    return out


def generate_report(results: Dict[str, dict], format: str = 'markdown', threshold: float = 0.5) -> str:
    """Generate a report from detection results.

    Formats: 'markdown', 'html', 'csv', 'json'
    """
    if format == 'json':
        return json.dumps(results, indent=2)

    flagged = {k: v for k, v in results.items() if isinstance(v, dict) and v.get('score', 0) >= threshold}

    if format == 'csv':
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(['File', 'Verdict', 'Score', 'AI Phrases', 'Total Words'])
        for path, res in results.items():
            if 'score' in res:
                writer.writerow([path, res['verdict'], res['score'], res['features'].get('ai_phrase_count', 0), res['features'].get('total_words', 0)])
        return output.getvalue()

    if format == 'html':
        html = "<html><head><title>AI Detection Report</title></head><body><h1>AI Detection Report</h1><table border='1'><tr><th>File</th><th>Verdict</th><th>Score</th><th>AI Phrases</th><th>Total Words</th></tr>"
        for path, res in results.items():
            if 'score' in res:
                html += f"<tr><td>{path}</td><td>{res['verdict']}</td><td>{res['score']}</td><td>{res['features'].get('ai_phrase_count', 0)}</td><td>{res['features'].get('total_words', 0)}</td></tr>"
        html += "</table></body></html>"
        return html

    # Default to markdown
    md = "# AI Detection Report\n\n"
    md += f"## Summary\n- Total files analyzed: {len(results)}\n- Files flagged (score >= {threshold}): {len(flagged)}\n\n"
    md += "## Flagged Files\n\n"
    for path, res in flagged.items():
        md += f"- **{path}**: {res['verdict']} (score={res['score']})\n"
    md += "\n## All Results\n\n"
    for path, res in results.items():
        if 'score' in res:
            md += f"- {path}: {res['verdict']} (score={res['score']})\n"
        else:
            md += f"- {path}: Error - {res.get('error', 'Unknown')}\n"
    return md


if __name__ == '__main__':
    import argparse
    ap = argparse.ArgumentParser(description='Enhanced AI-generated text detector')
    ap.add_argument('folder', nargs='?', default='.', help='Folder to scan')
    ap.add_argument('--json', action='store_true', help='Emit JSON output')
    ap.add_argument('--report', choices=['markdown', 'html', 'csv'], default='markdown', help='Report format')
    ap.add_argument('--output', help='Output file for report')
    ap.add_argument('--threshold', type=float, default=0.5, help='Threshold for flagging')
    args = ap.parse_args()
    res = detect_files(args.folder)
    report = generate_report(res, args.report, args.threshold)
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"Report saved to {args.output}")
    elif args.json:
        print(json.dumps(res, indent=2))
    else:
        print(report)
