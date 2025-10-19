#!/usr/bin/env python3
"""
Export brand SVG logo to PNGs for LinkedIn Company Page.
Outputs transparent PNGs in sizes: 400x400, 800x800, 240x240, 96x96.
"""
import os
from PIL import Image, ImageOps
try:
    import cairosvg
    HAS_CAIRO = True
except Exception:
    HAS_CAIRO = False

BASE_DIR = os.path.dirname(__file__)
SVG_PATH = os.path.join(BASE_DIR, 'simondatalab-logo.svg')
OUT_DIR = os.path.join(BASE_DIR, 'exports')
SIZES = [800, 400, 240, 96]

os.makedirs(OUT_DIR, exist_ok=True)

def export_with_cairosvg(size):
    out_path = os.path.join(OUT_DIR, f'simondatalab-logo-{size}.png')
    cairosvg.svg2png(url=SVG_PATH, write_to=out_path, output_width=size, output_height=size, background_color='transparent')
    return out_path

def export_with_pillow(size):
    # Fallback: rasterize by opening SVG via cairosvg bytes in-memory if available, else skip
    raise RuntimeError('CairoSVG is required for SVG rasterization. Please install cairosvg.')

exported = []
for s in SIZES:
    if HAS_CAIRO:
        p = export_with_cairosvg(s)
        exported.append(p)
    else:
        raise SystemExit('Please install CairoSVG: pip install cairosvg')

# Create white variant for dark backgrounds
for path in list(exported):
    img = Image.open(path).convert('RGBA')
    # Create a white-tinted version by replacing non-transparent pixels with white while preserving alpha
    r, g, b, a = img.split()
    white = Image.new('RGBA', img.size, (255, 255, 255, 255))
    white.putalpha(a)
    out_white = path.replace('.png', '-white.png')
    white.save(out_white, 'PNG', optimize=True)
    exported.append(out_white)

print('Exported files:')
for p in exported:
    print(' -', p)
