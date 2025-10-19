#!/usr/bin/env python3
"""
Render Simon Data Lab logo using Pillow only (no CairoSVG dependency).
Outputs transparent PNGs in sizes: 800, 400, 300, 240, 96 px.
Design matches site nav mark: cyan hexagon, white inner diamond, cyan dot.
"""
from PIL import Image, ImageDraw
import os
import math

SIZES = [800, 400, 300, 240, 96]
PRIMARY = (14, 165, 233, 255)  # #0ea5e9
WHITE = (255, 255, 255, 255)

OUT_DIR = os.path.join(os.path.dirname(__file__), 'exports')
os.makedirs(OUT_DIR, exist_ok=True)

def hexagon_points(cx, cy, r):
    pts = []
    for i in range(6):
        angle = math.radians(60 * i - 30)  # flat-top hexagon
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        pts.append((x, y))
    return pts

def draw_logo(size):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Safe margins
    m = int(size * 0.06)
    cx = cy = size // 2
    outer_r = (size // 2) - m

    # Outer hexagon
    draw.polygon(hexagon_points(cx, cy, outer_r), fill=PRIMARY)

    # Inner diamond (rotated square) ~ proportional to hex size
    inner_r = int(outer_r * 0.38)
    diamond = [
        (cx, cy - inner_r),
        (cx + inner_r, cy),
        (cx, cy + inner_r),
        (cx - inner_r, cy)
    ]
    draw.polygon(diamond, fill=WHITE)

    # Center dot
    dot_r = int(outer_r * 0.12)
    draw.ellipse([cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r], fill=PRIMARY)

    return img

def main():
    exported = []
    for s in SIZES:
        img = draw_logo(s)
        path = os.path.join(OUT_DIR, f'simondatalab-logo-{s}.png')
        img.save(path, 'PNG', optimize=True)
        exported.append(path)

        # White variant for dark backgrounds (keep shape in white, transparent bg)
        white = Image.new('RGBA', img.size, (255, 255, 255, 0))
        draw = ImageDraw.Draw(white)
        # Re-draw shapes in white
        m = int(s * 0.06)
        cx = cy = s // 2
        outer_r = (s // 2) - m
        draw.polygon(hexagon_points(cx, cy, outer_r), fill=WHITE)
        inner_r = int(outer_r * 0.38)
        diamond = [
            (cx, cy - inner_r), (cx + inner_r, cy), (cx, cy + inner_r), (cx - inner_r, cy)
        ]
        draw.polygon(diamond, fill=WHITE)
        dot_r = int(outer_r * 0.12)
        draw.ellipse([cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r], fill=WHITE)
        path_w = os.path.join(OUT_DIR, f'simondatalab-logo-{s}-white.png')
        white.save(path_w, 'PNG', optimize=True)
        exported.append(path_w)

    print('Exported:')
    for p in exported:
        print(' -', p)

if __name__ == '__main__':
    main()
