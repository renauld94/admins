#!/usr/bin/env python3
"""
WebP HTML Converter
Automatically updates HTML files to use optimized WebP images with fallbacks
"""

import os
import re
from pathlib import Path

# Image mapping: original -> optimized
IMAGE_MAP = {
    'images/mergedpics.jpg': ('images/mergedpics_opt.jpg', 'jpg'),
    'images/mltmap.png': ('images/mltmap.webp', 'webp'),
    'images/bing1_analytics.png': ('images/bing1_analytics.webp', 'webp'),
    'images/dashboard.png': ('images/dashboard.webp', 'webp'),
    'images/gitcommands.png': ('images/gitcommands.webp', 'webp'),
    'images/AWS_solution_categories.png': ('images/AWS_solution_categories.webp', 'webp'),
    'images/simon2.png': ('images/simon2.webp', 'webp'),
    'images/bi/mltmap.png': ('images/bi/mltmap.webp', 'webp'),
    'images/bi/dashboard.png': ('images/bi/dashboard.webp', 'webp'),
}

def create_picture_element(src, fallback, alt):
    """Create <picture> element with WebP and fallback"""
    if src.endswith('.webp'):
        return f'''<picture>
  <source srcset="{src}" type="image/webp">
  <img src="{fallback}" alt="{alt}" loading="lazy">
</picture>'''
    else:
        return f'<img src="{src}" alt="{alt}" loading="lazy">'

def update_html_file(filepath):
    """Update HTML file to use WebP images"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    updated_count = 0
    
    # Pattern to find img tags
    img_pattern = r'<img\s+src="([^"]+)"([^>]*?)>'
    
    def replace_img(match):
        nonlocal updated_count
        src = match.group(1)
        attrs = match.group(2)
        
        # Check if this image should be optimized
        if src in IMAGE_MAP:
            opt_src, format_type = IMAGE_MAP[src]
            updated_count += 1
            
            # Extract alt text if present
            alt_match = re.search(r'alt="([^"]*)"', attrs)
            alt = alt_match.group(1) if alt_match else src
            
            if format_type == 'webp':
                # Create picture element
                return create_picture_element(opt_src, src, alt)
            else:
                # Just update src
                return f'<img src="{opt_src}"{attrs}>'
        
        # Add loading="lazy" if not already present
        if 'loading=' not in attrs:
            return f'<img src="{src}"{attrs} loading="lazy">'
        
        return match.group(0)
    
    content = re.sub(img_pattern, replace_img, content)
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return updated_count
    
    return 0

# Main execution
if __name__ == '__main__':
    portfolio_dir = '/home/simon/Learning-Management-System-Academy/portofio_simon_rennauld/simonrenauld.github.io'
    html_files = [
        'dataeng.html',
        'artificialintelligence.html',
        'cloudinfrastucture.html',
        'ds.html',
        'geointelligence.html',
    ]
    
    print("🔄 WebP HTML Converter")
    print("=" * 50)
    print("")
    
    total_updates = 0
    for filename in html_files:
        filepath = os.path.join(portfolio_dir, filename)
        if os.path.exists(filepath):
            updates = update_html_file(filepath)
            total_updates += updates
            status = "✅" if updates > 0 else "⏭️"
            print(f"{status} {filename}: {updates} images updated")
        else:
            print(f"❌ {filename}: NOT FOUND")
    
    print("")
    print("=" * 50)
    print(f"Total images updated: {total_updates}")
    print("✅ HTML files updated successfully!")
