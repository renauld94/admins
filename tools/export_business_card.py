#!/usr/bin/env python3
"""
Export business card HTML to printer-ready PDF and 300 DPI PNG assets.

Outputs per input HTML:
- <name>_standard.pdf   (3.5in × 2in, no margins)
- <name>_bleed.pdf      (3.75in × 2.25in, 0.125in bleed each side)
- <name>_300dpi.png     (1050×600 px)
- <name>_300dpi_bleed.png (1125×675 px)

Usage:
  python tools/export_business_card.py \
    --input portfolio-deployment-enhanced/assets/business-card.html \
    --name personal \
    --outdir output/business-card

  python tools/export_business_card.py \
    --input portfolio-deployment-enhanced/assets/business-card-brand.html \
    --name neurodata \
    --outdir output/business-card

Requires: playwright (Chromium installed via `python -m playwright install chromium`).
"""
from pathlib import Path
import argparse
from playwright.sync_api import sync_playwright


INCH = 96  # CSS inches -> px conversion used by Chromium for screenshots


def inject_bleed_css(page):
    """Inject CSS to expand the card to bleed size while keeping content safe."""
    bleed_css = """
    /* Expand card to full-bleed size for export */
    .business-card { width: 3.75in !important; height: 2.25in !important; }
    /* Keep safe padding inside */
    .card-content { padding: 0.3in !important; }
    @media print { @page { size: 3.75in 2.25in; margin: 0; } }
    """
    page.add_style_tag(content=bleed_css)


def hide_non_print_elements(page):
        hide_css = """
            .instructions { display: none !important; }
        """
        page.add_style_tag(content=hide_css)


def export_pdf(page, outpath: Path, width_in: float, height_in: float):
    page.pdf(
        path=str(outpath),
        print_background=True,
        width=f"{width_in}in",
        height=f"{height_in}in",
        margin={"top": "0in", "right": "0in", "bottom": "0in", "left": "0in"},
        prefer_css_page_size=True,
    )


def export_png(page, outpath: Path, pixel_width: int, pixel_height: int):
    # Ensure the element is present and clip to it
    card = page.locator(".business-card").first
    card.wait_for()
    # Set viewport large enough to contain the clip
    page.set_viewport_size({"width": max(pixel_width, 1200), "height": max(pixel_height, 800)})
    box = card.bounding_box()
    # Fallback: if bounding box is None (rare), just full-page screenshot
    if not box:
        page.screenshot(path=str(outpath), type="png", full_page=True)
        return
    # Use requested size by scaling clip to exact pixel target
    # Compute scale factor so that the clip width maps to desired pixels
    scale_x = pixel_width / box["width"]
    scale_y = pixel_height / box["height"]
    scale = min(scale_x, scale_y)
    # Set CSS transform scale on the card for exact output pixels
    page.evaluate(
        "arg => { const el = document.querySelector(arg.sel); if (!el) return; el.style.transformOrigin='top left'; el.style.transform = `scale(${arg.scale})`; }",
        {"sel": ".business-card", "scale": scale},
    )
    # Recompute bounding box after scale
    box = card.bounding_box()
    clip = {
        "x": box["x"],
        "y": box["y"],
        "width": pixel_width,
        "height": pixel_height,
    }
    page.screenshot(path=str(outpath), type="png", clip=clip)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="Path to input HTML file")
    parser.add_argument("--name", required=True, help="Base name for outputs (no extension)")
    parser.add_argument("--outdir", default="output/business-card", help="Output directory")
    parser.add_argument("--front-and-back", action="store_true", help="Export both front and back as separate images and combined PDF")
    args = parser.parse_args()

    in_path = Path(args.input).resolve()
    out_dir = Path(args.outdir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    url = in_path.as_uri()

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        # Load page and ensure visual elements are ready
        page.goto(url, wait_until="networkidle")
        hide_non_print_elements(page)

        if args.front_and_back:
            # Export front and back separately
            # Front: first .business-card without .card-back
            front_card = page.locator(".business-card").first
            front_card.wait_for()
            # Standard front
            export_pdf_single_card(page, out_dir / f"{args.name}_front_standard.pdf", 3.5, 2.0, ".business-card:not(.card-back)")
            export_png_single_card(page, out_dir / f"{args.name}_front_300dpi.png", 1050, 600, ".business-card:not(.card-back)")
            # Bleed front
            inject_bleed_css(page)
            export_pdf_single_card(page, out_dir / f"{args.name}_front_bleed.pdf", 3.75, 2.25, ".business-card:not(.card-back)")
            export_png_single_card(page, out_dir / f"{args.name}_front_300dpi_bleed.png", 1125, 675, ".business-card:not(.card-back)")
            # Reset for back
            page.reload(wait_until="networkidle")
            hide_non_print_elements(page)
            # Back: .business-card.card-back
            export_pdf_single_card(page, out_dir / f"{args.name}_back_standard.pdf", 3.5, 2.0, ".business-card.card-back")
            export_png_single_card(page, out_dir / f"{args.name}_back_300dpi.png", 1050, 600, ".business-card.card-back")
            # Bleed back
            inject_bleed_css(page)
            export_pdf_single_card(page, out_dir / f"{args.name}_back_bleed.pdf", 3.75, 2.25, ".business-card.card-back")
            export_png_single_card(page, out_dir / f"{args.name}_back_300dpi_bleed.png", 1125, 675, ".business-card.card-back")
        else:
            # Standard (no bleed)
            export_pdf(page, out_dir / f"{args.name}_standard.pdf", 3.5, 2.0)
            export_png(page, out_dir / f"{args.name}_300dpi.png", 1050, 600)

            # Bleed version
            inject_bleed_css(page)
            export_pdf(page, out_dir / f"{args.name}_bleed.pdf", 3.75, 2.25)
            export_png(page, out_dir / f"{args.name}_300dpi_bleed.png", 1125, 675)

        browser.close()

    # Write a simple spec file once (idempotent)
    spec_path = out_dir / "README_FOR_PRINTER.txt"
    if not spec_path.exists():
        spec_path.write_text(
            """
Deliverables
-----------
Files provided are print-ready in both standard and full-bleed formats:

- neurodata_front_standard.pdf       (3.5in × 2in, no margins)
- neurodata_front_bleed.pdf          (3.75in × 2.25in, 0.125in bleed per side)
- neurodata_front_300dpi.png         (1050 × 600 px)
- neurodata_front_300dpi_bleed.png   (1125 × 675 px)
- neurodata_back_* equivalents for card back

Color & Fonts
-------------
- Color profile: sRGB. Please convert to CMYK if required by your workflow.
- Backgrounds and brand colors are embedded; no spot colors.
- Fonts: System sans (Inter fallbacks). Rasterized in PNG; embedded as vectors in PDF.

Trim & Bleed
------------
- Bleed: 0.125in on all sides (use the *_bleed.* files for edge-to-edge printing).
- No crop marks are included by default; add if your RIP requires.

Notes
-----
- If further adjustments to margins/bleed are needed, request the source HTML.
""".strip()
        )


def export_pdf_single_card(page, outpath: Path, width_in: float, height_in: float, selector: str):
    """Export PDF clipped to a specific card selector."""
    card = page.locator(selector).first
    card.wait_for()
    box = card.bounding_box()
    if not box:
        page.pdf(path=str(outpath), print_background=True, width=f"{width_in}in", height=f"{height_in}in",
                 margin={"top": "0in", "right": "0in", "bottom": "0in", "left": "0in"}, prefer_css_page_size=True)
        return
    # Use viewport scaling trick to clip to desired card only
    # For PDF, simpler approach: use CSS to hide other cards temporarily
    page.evaluate(f"() => {{ document.querySelectorAll('.business-card').forEach(el => el.style.display = 'none'); document.querySelector('{selector}').style.display = 'block'; }}")
    page.pdf(path=str(outpath), print_background=True, width=f"{width_in}in", height=f"{height_in}in",
             margin={"top": "0in", "right": "0in", "bottom": "0in", "left": "0in"}, prefer_css_page_size=True)
    page.evaluate("() => { document.querySelectorAll('.business-card').forEach(el => el.style.display = ''); }")


def export_png_single_card(page, outpath: Path, pixel_width: int, pixel_height: int, selector: str):
    """Export PNG clipped to a specific card selector."""
    card = page.locator(selector).first
    card.wait_for()
    page.set_viewport_size({"width": max(pixel_width, 1200), "height": max(pixel_height, 800)})
    box = card.bounding_box()
    if not box:
        page.screenshot(path=str(outpath), type="png", full_page=True)
        return
    scale_x = pixel_width / box["width"]
    scale_y = pixel_height / box["height"]
    scale = min(scale_x, scale_y)
    page.evaluate(
        "arg => { const el = document.querySelector(arg.sel); if (!el) return; el.style.transformOrigin='top left'; el.style.transform = `scale(${arg.scale})`; }",
        {"sel": selector, "scale": scale},
    )
    box = card.bounding_box()
    clip = {
        "x": box["x"],
        "y": box["y"],
        "width": pixel_width,
        "height": pixel_height,
    }
    page.screenshot(path=str(outpath), type="png", clip=clip)


if __name__ == "__main__":
    main()
