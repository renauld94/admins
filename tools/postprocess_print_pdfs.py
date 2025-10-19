#!/usr/bin/env python3
"""
Add crop marks to bleed PDFs, verify page sizes, and convert PDFs to CMYK.

Requirements:
- PyMuPDF (pymupdf)
- Ghostscript (`gs`) installed on system for CMYK conversion

Usage example:
  python tools/postprocess_print_pdfs.py \
    --standard output/business-card/neurodata_standard.pdf \
    --bleed output/business-card/neurodata_bleed.pdf \
    --outdir output/business-card

Optional:
  Set environment variable CMYK_ICC_PROFILE to an ICC path (e.g., FOGRA39.icc or GRACoL.icc)
"""
from __future__ import annotations
import argparse
import os
import shutil
import subprocess
from pathlib import Path
import sys

import fitz  # PyMuPDF

PT_PER_IN = 72.0


def verify_size(pdf_path: Path, expected_in: tuple[float, float], name: str) -> bool:
    doc = fitz.open(pdf_path)
    if len(doc) < 1:
        print(f"FAIL: {name}: no pages in {pdf_path}")
        return False
    page = doc[0]
    rect = page.mediabox
    width_pt = rect.width
    height_pt = rect.height
    doc.close()
    exp_w_pt = expected_in[0] * PT_PER_IN
    exp_h_pt = expected_in[1] * PT_PER_IN
    tol = 0.75  # points tolerance
    ok = abs(width_pt - exp_w_pt) <= tol and abs(height_pt - exp_h_pt) <= tol
    status = "PASS" if ok else "FAIL"
    print(f"{status}: {name} size: {width_pt:.2f}×{height_pt:.2f} pt (expected {exp_w_pt:.2f}×{exp_h_pt:.2f} pt)")
    return ok


def add_crop_marks(bleed_pdf: Path, out_pdf: Path, bleed_inset_in: float = 0.125, mark_len_in: float = 0.25, line_w_pt: float = 0.5):
    doc = fitz.open(bleed_pdf)
    page = doc[0]
    rect = page.mediabox
    w, h = rect.width, rect.height
    inset = bleed_inset_in * PT_PER_IN
    mark_len = mark_len_in * PT_PER_IN
    # Trim rectangle
    left = inset
    right = w - inset
    top = inset
    bottom = h - inset
    # Draw lines (K-only black)
    shape = page.new_shape()
    # Corners: draw vertical and horizontal marks extending outward from trim edges
    # Left edge: vertical marks at top and bottom
    shape.draw_line(fitz.Point(left, top), fitz.Point(left, top - mark_len))
    shape.draw_line(fitz.Point(left, bottom), fitz.Point(left, bottom + mark_len))
    # Right edge
    shape.draw_line(fitz.Point(right, top), fitz.Point(right, top - mark_len))
    shape.draw_line(fitz.Point(right, bottom), fitz.Point(right, bottom + mark_len))
    # Top edge: horizontal marks at left and right
    shape.draw_line(fitz.Point(left, top), fitz.Point(left - mark_len, top))
    shape.draw_line(fitz.Point(right, top), fitz.Point(right + mark_len, top))
    # Bottom edge
    shape.draw_line(fitz.Point(left, bottom), fitz.Point(left - mark_len, bottom))
    shape.draw_line(fitz.Point(right, bottom), fitz.Point(right + mark_len, bottom))
    # Stroke the lines (K-only black) and commit to page
    shape.finish(color=(0, 0, 0), fill=None, width=line_w_pt)
    shape.commit()
    doc.save(out_pdf)
    doc.close()
    print(f"Added crop marks: {out_pdf}")


def convert_to_cmyk(in_pdf: Path, out_pdf: Path, icc_path: Path | None = None) -> bool:
    """Convert PDF to CMYK using Ghostscript. Returns True on success."""
    if shutil.which("gs") is None:
        print("WARN: Ghostscript 'gs' not found; skipping CMYK conversion.")
        return False
    cmd = [
        "gs", "-dSAFER", "-dBATCH", "-dNOPAUSE", "-dQUIET",
        "-sDEVICE=pdfwrite",
        "-sProcessColorModel=DeviceCMYK",
        "-dColorConversionStrategy=/CMYK",
        "-dColorConversionStrategyForImages=/CMYK",
        "-dOverrideICC",
        f"-sOutputFile={str(out_pdf)}",
    ]
    if icc_path and icc_path.exists():
        # Prefer using provided ICC profile as default CMYK output profile
        cmd.extend([f"-sDefaultCMYKProfile={str(icc_path)}"])
    cmd.append(str(in_pdf))
    try:
        subprocess.run(cmd, check=True)
        print(f"Converted to CMYK: {out_pdf}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"ERROR: Ghostscript failed for {in_pdf}: {e}")
        return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--standard", required=True, help="Path to standard (no-bleed) PDF")
    ap.add_argument("--bleed", required=True, help="Path to bleed PDF")
    ap.add_argument("--outdir", default="output/business-card", help="Output directory for processed files")
    ap.add_argument("--icc", default=os.environ.get("CMYK_ICC_PROFILE", ""), help="Path to CMYK ICC profile (optional)")
    args = ap.parse_args()

    standard = Path(args.standard).resolve()
    bleed = Path(args.bleed).resolve()
    outdir = Path(args.outdir).resolve()
    outdir.mkdir(parents=True, exist_ok=True)
    icc_path = Path(args.icc).resolve() if args.icc else None

    # Verify sizes
    ok_std = verify_size(standard, (3.5, 2.0), "Standard (3.5×2 in)")
    ok_bleed = verify_size(bleed, (3.75, 2.25), "Bleed (3.75×2.25 in)")
    if not (ok_std and ok_bleed):
        print("One or more sizes did not match expected; continue with caution.")

    # Add crop marks to bleed
    bleed_crop = outdir / (bleed.stem + "_cropmarks.pdf")
    add_crop_marks(bleed, bleed_crop)

    # CMYK conversions
    std_cmyk = outdir / (standard.stem + "_cmyk.pdf")
    bleed_cmyk = outdir / (bleed.stem + "_cmyk.pdf")
    bleed_crop_cmyk = outdir / (bleed_crop.stem + "_cmyk.pdf")

    convert_to_cmyk(standard, std_cmyk, icc_path)
    convert_to_cmyk(bleed, bleed_cmyk, icc_path)
    convert_to_cmyk(bleed_crop, bleed_crop_cmyk, icc_path)

    print("\nDone. Outputs:")
    for p in [bleed_crop, std_cmyk, bleed_cmyk, bleed_crop_cmyk]:
        if p.exists():
            print(" -", p)


if __name__ == "__main__":
    sys.exit(main())
