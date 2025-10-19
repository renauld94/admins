#!/usr/bin/env python3
"""
Convert a PDF resume to DOCX using pdf2docx, preserving layout as much as possible.
Usage:
  python convert_pdf_to_docx.py --pdf <input.pdf> --out <output.docx>
"""
import argparse
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pdf', required=True)
    ap.add_argument('--out', required=True)
    args = ap.parse_args()

    pdf_path = Path(args.pdf)
    out_path = Path(args.out)

    if not pdf_path.exists():
        raise SystemExit(f"PDF not found: {pdf_path}")

    try:
        from pdf2docx import Converter
    except Exception as e:
        raise SystemExit("Missing dependency pdf2docx. Please install it in your environment: pip install pdf2docx")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    cv = Converter(str(pdf_path))
    # Use default settings to preserve layout
    cv.convert(str(out_path))
    cv.close()
    print(f"Saved DOCX: {out_path}")


if __name__ == '__main__':
    main()
