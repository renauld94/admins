#!/usr/bin/env python3
"""
Fully automated ODT text replacement preserving all formatting.
Directly manipulates the content.xml inside the ODT ZIP archive.
"""
import argparse
import zipfile
import tempfile
import shutil
from pathlib import Path
from xml.etree import ElementTree as ET

# ODT namespaces
NS = {
    'text': 'urn:oasis:names:tc:opendocument:xmlns:text:1.0',
    'office': 'urn:oasis:names:tc:opendocument:xmlns:office:1.0',
    'style': 'urn:oasis:names:tc:opendocument:xmlns:style:1.0',
}

for prefix, uri in NS.items():
    ET.register_namespace(prefix, uri)


def parse_markdown_to_structure(md_path):
    """Parse markdown into a structured format."""
    lines = md_path.read_text(encoding='utf-8').splitlines()
    elements = []
    
    for line in lines:
        line_stripped = line.strip()
        if not line_stripped or line_stripped == '---':
            elements.append({'type': 'empty'})
            continue
            
        if line_stripped.startswith('# '):
            elements.append({'type': 'h1', 'text': line_stripped[2:]})
        elif line_stripped.startswith('## '):
            elements.append({'type': 'h2', 'text': line_stripped[3:]})
        elif line_stripped.startswith('### '):
            elements.append({'type': 'h3', 'text': line_stripped[4:]})
        elif line_stripped.startswith(('- ', '* ', '• ')):
            elements.append({'type': 'bullet', 'text': line_stripped[2:]})
        else:
            # Regular text - strip markdown bold
            clean_text = line_stripped.replace('**', '')
            elements.append({'type': 'text', 'text': clean_text})
    
    return elements


def modify_odt_content(odt_path, elements, output_path):
    """Modify ODT content.xml with new text."""
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        # Extract ODT
        with zipfile.ZipFile(odt_path, 'r') as zf:
            zf.extractall(temp_dir)
        
        # Parse content.xml
        content_xml = temp_dir / 'content.xml'
        tree = ET.parse(content_xml)
        root = tree.getroot()
        
        # Find the office:body/office:text element
        body = root.find('.//office:text', NS)
        if body is None:
            raise ValueError("Could not find office:text in content.xml")
        
        # Clear existing content (keep first few elements for styles)
        children = list(body)
        # Keep automatic-styles, forms, etc. but remove text content
        for child in children:
            tag = child.tag.replace('{' + NS['text'] + '}', '')
            if tag in ['p', 'h', 'list', 'section']:
                body.remove(child)
        
        # Add new content
        for elem in elements:
            if elem['type'] == 'empty':
                # Empty paragraph
                p = ET.Element(f"{{{NS['text']}}}p")
                body.append(p)
            elif elem['type'] == 'h1':
                h = ET.Element(f"{{{NS['text']}}}h", attrib={
                    f"{{{NS['text']}}}outline-level": "1"
                })
                h.text = elem['text']
                body.append(h)
            elif elem['type'] == 'h2':
                h = ET.Element(f"{{{NS['text']}}}h", attrib={
                    f"{{{NS['text']}}}outline-level": "2"
                })
                h.text = elem['text']
                body.append(h)
            elif elem['type'] == 'h3':
                h = ET.Element(f"{{{NS['text']}}}h", attrib={
                    f"{{{NS['text']}}}outline-level": "3"
                })
                h.text = elem['text']
                body.append(h)
            elif elem['type'] == 'bullet':
                # Create list with list-item
                lst = ET.Element(f"{{{NS['text']}}}list")
                item = ET.SubElement(lst, f"{{{NS['text']}}}list-item")
                p = ET.SubElement(item, f"{{{NS['text']}}}p")
                p.text = elem['text']
                body.append(lst)
            elif elem['type'] == 'text':
                p = ET.Element(f"{{{NS['text']}}}p")
                p.text = elem['text']
                body.append(p)
        
        # Write modified content.xml
        tree.write(content_xml, encoding='utf-8', xml_declaration=True)
        
        # Repack into new ODT
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zf:
            for file in temp_dir.rglob('*'):
                if file.is_file():
                    zf.write(file, file.relative_to(temp_dir))
        
        print(f"✓ Created modified ODT: {output_path}")
        
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--template', required=True)
    ap.add_argument('--md', required=True)
    ap.add_argument('--out', required=True)
    args = ap.parse_args()

    template_path = Path(args.template)
    md_path = Path(args.md)
    output_path = Path(args.out)

    if not template_path.exists():
        raise SystemExit(f"Template not found: {template_path}")
    if not md_path.exists():
        raise SystemExit(f"Markdown not found: {md_path}")

    # Parse markdown
    elements = parse_markdown_to_structure(md_path)
    print(f"Parsed {len(elements)} elements from markdown")
    
    # Modify ODT
    modify_odt_content(template_path, elements, output_path)
    
    # Convert to PDF
    import subprocess
    pdf_path = output_path.with_suffix('.pdf')
    print(f"\nConverting to PDF...")
    try:
        result = subprocess.run([
            'libreoffice', '--headless', '--convert-to', 'pdf',
            '--outdir', str(output_path.parent),
            str(output_path)
        ], capture_output=True, text=True, timeout=30)
        
        if pdf_path.exists():
            print(f"✓ Created PDF: {pdf_path}")
            # Open PDF
            subprocess.Popen(['xdg-open', str(pdf_path)])
        else:
            print(f"⚠ PDF conversion may have failed")
    except Exception as e:
        print(f"Note: Could not convert to PDF automatically: {e}")
        print(f"You can open {output_path} in LibreOffice and export manually")


if __name__ == '__main__':
    main()
