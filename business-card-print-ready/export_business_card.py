#!/usr/bin/env python3
"""
Business Card HTML to Image Exporter
Exports business card HTML to high-quality PNG and JPEG for printing
Standard business card size: 3.5" x 2" at 300 DPI = 1050px x 600px
"""

import sys
import os
from pathlib import Path

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("❌ Playwright not installed. Installing now...")
    os.system(f"{sys.executable} -m pip install playwright")
    os.system(f"{sys.executable} -m playwright install chromium")
    from playwright.sync_api import sync_playwright

def export_business_card(html_file: str, output_dir: str = None):
    """
    Export business card HTML to PNG and JPEG images
    
    Args:
        html_file: Path to the HTML file
        output_dir: Directory to save images (default: same as HTML file)
    """
    html_path = Path(html_file).resolve()
    
    if not html_path.exists():
        print(f"❌ HTML file not found: {html_path}")
        return False
    
    if output_dir is None:
        output_dir = html_path.parent
    else:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"📄 Input: {html_path}")
    print(f"📁 Output directory: {output_dir}")
    print(f"🎨 Converting HTML to images...")
    
    with sync_playwright() as p:
        # Launch browser in headless mode
        browser = p.chromium.launch()
        page = browser.new_page(viewport={'width': 1200, 'height': 800})
        
        # Load the HTML file
        page.goto(f"file://{html_path}")
        
        # Wait for fonts and images to load
        page.wait_for_load_state("networkidle")
        page.wait_for_timeout(2000)  # Additional wait for font rendering
        
        # Find the business card elements
        cards = page.locator('.business-card').all()
        
        if not cards:
            print("❌ No business card elements found in HTML")
            browser.close()
            return False
        
        print(f"✅ Found {len(cards)} business card(s)")
        
        # Export each card
        for idx, card in enumerate(cards):
            card_name = "front" if idx == 0 else "back"
            
            # High-quality PNG (lossless, with transparency support)
            png_path = output_dir / f"business-card-{card_name}-300dpi.png"
            card.screenshot(
                path=str(png_path),
                type='png',
                scale='device'  # Use device pixel ratio for high quality
            )
            print(f"✅ Exported PNG: {png_path}")
            
            # High-quality JPEG (for printing)
            jpeg_path = output_dir / f"business-card-{card_name}-300dpi.jpg"
            card.screenshot(
                path=str(jpeg_path),
                type='jpeg',
                quality=100,  # Maximum quality
                scale='device'
            )
            print(f"✅ Exported JPEG: {jpeg_path}")
        
        # Also capture full page for reference
        full_png = output_dir / "business-card-full-page.png"
        page.screenshot(
            path=str(full_png),
            type='png',
            full_page=True
        )
        print(f"✅ Exported full page: {full_png}")
        
        browser.close()
    
    print("\n✨ Export complete!")
    print(f"\n📋 Print specifications:")
    print(f"   Size: 3.5\" × 2\" (89mm × 51mm)")
    print(f"   Resolution: 300 DPI")
    print(f"   Dimensions: 1050px × 600px")
    print(f"   Format: PNG (lossless) or JPEG (maximum quality)")
    print(f"\n💡 Tip: Use PNG for best quality, JPEG for smaller file size")
    
    return True

if __name__ == "__main__":
    # Default to the business card HTML in the current directory
    script_dir = Path(__file__).parent
    
    if len(sys.argv) > 1:
        html_file = sys.argv[1]
    else:
        # Try to find the business card HTML
        possible_files = [
            script_dir / "business-card.html",
            script_dir / "../portfolio-deployment-enhanced/assets/business-card.html",
        ]
        
        html_file = None
        for f in possible_files:
            if f.exists():
                html_file = f
                break
        
        if html_file is None:
            print("❌ No business card HTML file found!")
            print("Usage: python export_business_card.py [path/to/business-card.html]")
            sys.exit(1)
    
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None
    
    success = export_business_card(html_file, output_dir)
    sys.exit(0 if success else 1)
