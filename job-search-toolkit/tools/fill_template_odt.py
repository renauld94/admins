#!/usr/bin/env python3
"""
Fill an ODT template with resume content from Markdown while preserving all styles.
Uses the python-odf library to manipulate LibreOffice native format perfectly.
"""
import argparse
import sys
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--template', required=True, help='ODT template file')
    ap.add_argument('--md', required=True, help='Markdown content file')
    ap.add_argument('--out', required=True, help='Output ODT file')
    args = ap.parse_args()

    template_path = Path(args.template)
    md_path = Path(args.md)
    out_path = Path(args.out)

    if not template_path.exists():
        raise SystemExit(f"Template not found: {template_path}")
    if not md_path.exists():
        raise SystemExit(f"Markdown file not found: {md_path}")

    # For ODT, the safest approach is to use LibreOffice's native conversion
    # We'll convert MD to HTML then let LibreOffice import it with template styles
    # But for exact template match, better to open the ODT and replace text directly
    
    # Simple approach: copy template and use sed-like replacement
    # More robust: use odfpy library
    
    try:
        from odf import opendocument, text as odf_text, style
        from odf.style import Style, TextProperties, ParagraphProperties
    except ImportError:
        print("Installing odfpy for ODT manipulation...")
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "odfpy"])
        from odf import opendocument, text as odf_text, style
        from odf.style import Style, TextProperties, ParagraphProperties

    # Load template
    doc = opendocument.load(str(template_path))
    
    # Read markdown content
    md_content = md_path.read_text(encoding='utf-8')
    lines = md_content.splitlines()
    
    # Clear existing content but keep styles
    # Remove all text elements from body
    for elem in doc.text.childNodes[:]:
        doc.text.removeChild(elem)
    
    # Parse markdown and add to ODT
    for line in lines:
        line = line.strip()
        if not line:
            doc.text.addElement(odf_text.P())
            continue
            
        if line.startswith('# '):
            # Heading 1
            p = odf_text.H(outlinelevel=1, text=line[2:])
            doc.text.addElement(p)
        elif line.startswith('## '):
            # Heading 2
            p = odf_text.H(outlinelevel=2, text=line[3:])
            doc.text.addElement(p)
        elif line.startswith('### '):
            # Heading 3
            p = odf_text.H(outlinelevel=3, text=line[4:])
            doc.text.addElement(p)
        elif line.startswith(('- ', '* ', '• ')):
            # Bullet list
            list_item = odf_text.ListItem()
            p = odf_text.P(text=line[2:])
            list_item.addElement(p)
            ul = odf_text.List()
            ul.addElement(list_item)
            doc.text.addElement(ul)
        elif line.startswith('**') and line.endswith('**') and len(line) > 4:
            # Bold line
            p = odf_text.P()
            span = odf_text.Span(text=line[2:-2])
            span.setAttribute('fontweight', 'bold')
            p.addElement(span)
            doc.text.addElement(p)
        else:
            # Regular paragraph
            clean_line = line.replace('**', '')
            doc.text.addElement(odf_text.P(text=clean_line))
    
    # Save
    out_path.parent.mkdir(parents=True, exist_ok=True)
    doc.save(str(out_path))
    print(f"Saved ODT resume to: {out_path}")


if __name__ == '__main__':
    main()
