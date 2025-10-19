#!/usr/bin/env python3
"""
Advanced ODT template replacement that preserves EXACT formatting.
Uses smart text matching and style preservation from the original template.
"""
import sys
import zipfile
import tempfile
import shutil
from pathlib import Path
from xml.etree import ElementTree as ET
from copy import deepcopy

# ODT namespaces
NS = {
    'text': 'urn:oasis:names:tc:opendocument:xmlns:text:1.0',
    'office': 'urn:oasis:names:tc:opendocument:xmlns:office:1.0',
    'style': 'urn:oasis:names:tc:opendocument:xmlns:style:1.0',
    'fo': 'urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0',
}

for prefix, uri in NS.items():
    ET.register_namespace(prefix, uri)


def extract_template_structure(odt_path):
    """Extract the structure and styles from the original template."""
    temp_dir = Path(tempfile.mkdtemp())
    
    with zipfile.ZipFile(odt_path, 'r') as zf:
        zf.extractall(temp_dir)
    
    content_xml = temp_dir / 'content.xml'
    tree = ET.parse(content_xml)
    root = tree.getroot()
    
    # Get the body
    body = root.find('.//office:text', NS)
    
    # Extract all paragraph and heading styles
    styles = {}
    for elem in body:
        tag_name = elem.tag.replace('{' + NS['text'] + '}', '')
        if tag_name in ['p', 'h']:
            style_name = elem.get('{' + NS['text'] + '}style-name')
            if style_name:
                styles[tag_name] = style_name
    
    shutil.rmtree(temp_dir)
    return styles


def smart_replace_odt(template_path, content_lines, output_path, use_template_styles=True):
    """
    Replace ODT content while preserving exact template formatting.
    Maps content to appropriate styles based on the template structure.
    """
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        # Extract template
        with zipfile.ZipFile(template_path, 'r') as zf:
            zf.extractall(temp_dir)
        
        # Parse content.xml
        content_xml = temp_dir / 'content.xml'
        tree = ET.parse(content_xml)
        root = tree.getroot()
        
        # Get template styles
        template_styles = extract_template_structure(template_path)
        
        # Find body
        body = root.find('.//office:text', NS)
        
        # Store the first few elements (they often contain important style definitions)
        preserved_elements = []
        for i, child in enumerate(list(body)[:3]):
            tag = child.tag.replace('{' + NS['text'] + '}', '')
            if tag not in ['p', 'h', 'list']:
                preserved_elements.append(deepcopy(child))
        
        # Clear body content
        for child in list(body):
            body.remove(child)
        
        # Re-add preserved elements
        for elem in preserved_elements:
            body.append(elem)
        
        # Process content lines and add with template styles
        current_list = None
        
        for line in content_lines:
            line_stripped = line.strip()
            
            if not line_stripped or line_stripped in ['---', '=' * 80]:
                # Empty line
                p = ET.Element(f"{{{NS['text']}}}p")
                if use_template_styles and 'p' in template_styles:
                    p.set(f"{{{NS['text']}}}style-name", template_styles['p'])
                body.append(p)
                current_list = None
                continue
            
            # Detect line type
            is_heading_1 = line_stripped.startswith('SIMON RENAULD') or line_stripped.isupper() and len(line_stripped) < 60
            is_heading_2 = line_stripped in ['PROFESSIONAL SUMMARY', 'CORE COMPETENCIES', 'PROFESSIONAL EXPERIENCE', 
                                             'EDUCATION', 'KEY ACHIEVEMENTS', 'LANGUAGES', 'TECHNICAL SKILLS SUMMARY',
                                             'WHAT I BRING TO YOUR ORGANIZATION']
            is_heading_3 = '—' in line_stripped and ('|' in line_stripped or '–' in line_stripped)
            is_bullet = line_stripped.startswith('•') or (line_stripped.startswith('- ') and not line_stripped.startswith('---'))
            is_bold = line_stripped.endswith(':') and len(line_stripped) < 80
            
            if is_heading_1 or is_heading_2:
                # Major heading
                h = ET.Element(f"{{{NS['text']}}}h")
                h.set(f"{{{NS['text']}}}outline-level", "1" if is_heading_1 else "2")
                if use_template_styles and 'h' in template_styles:
                    h.set(f"{{{NS['text']}}}style-name", template_styles['h'])
                h.text = line_stripped
                body.append(h)
                current_list = None
                
            elif is_heading_3:
                # Job title heading
                p = ET.Element(f"{{{NS['text']}}}p")
                if use_template_styles and 'p' in template_styles:
                    p.set(f"{{{NS['text']}}}style-name", template_styles['p'])
                # Make it bold
                span = ET.SubElement(p, f"{{{NS['text']}}}span")
                span.set(f"{{{NS['text']}}}style-name", 'Strong_20_Emphasis')
                span.text = line_stripped
                body.append(p)
                current_list = None
                
            elif is_bullet:
                # Bullet point
                clean_text = line_stripped[2:] if line_stripped.startswith('• ') else line_stripped[2:]
                
                if current_list is None:
                    current_list = ET.Element(f"{{{NS['text']}}}list")
                    body.append(current_list)
                
                item = ET.SubElement(current_list, f"{{{NS['text']}}}list-item")
                p = ET.SubElement(item, f"{{{NS['text']}}}p")
                if use_template_styles and 'p' in template_styles:
                    p.set(f"{{{NS['text']}}}style-name", template_styles['p'])
                p.text = clean_text
                
            elif is_bold:
                # Bold line (section headings within content)
                p = ET.Element(f"{{{NS['text']}}}p")
                if use_template_styles and 'p' in template_styles:
                    p.set(f"{{{NS['text']}}}style-name", template_styles['p'])
                span = ET.SubElement(p, f"{{{NS['text']}}}span")
                span.set(f"{{{NS['text']}}}style-name", 'Strong_20_Emphasis')
                span.text = line_stripped
                body.append(p)
                current_list = None
                
            else:
                # Regular paragraph
                p = ET.Element(f"{{{NS['text']}}}p")
                if use_template_styles and 'p' in template_styles:
                    p.set(f"{{{NS['text']}}}style-name", template_styles['p'])
                p.text = line_stripped
                body.append(p)
                current_list = None
        
        # Write modified XML
        tree.write(content_xml, encoding='utf-8', xml_declaration=True)
        
        # Repack ODT
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for file in temp_dir.rglob('*'):
                if file.is_file():
                    zipf.write(file, file.relative_to(temp_dir))
        
        print(f"✓ Created ODT with template formatting: {output_path}")
        return True
        
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)


def main():
    if len(sys.argv) < 4:
        print("Usage: advanced_odt_replace.py <template.odt> <content.txt> <output.odt>")
        sys.exit(1)
    
    template_path = Path(sys.argv[1])
    content_path = Path(sys.argv[2])
    output_path = Path(sys.argv[3])
    
    if not template_path.exists():
        print(f"✗ Template not found: {template_path}")
        sys.exit(1)
    if not content_path.exists():
        print(f"✗ Content not found: {content_path}")
        sys.exit(1)
    
    # Read content
    content_lines = content_path.read_text(encoding='utf-8').splitlines()
    print(f"Loaded {len(content_lines)} lines from content file")
    
    # Process
    success = smart_replace_odt(template_path, content_lines, output_path, use_template_styles=True)
    
    if success:
        # Convert to PDF
        import subprocess
        pdf_path = output_path.with_suffix('.pdf')
        print(f"\nConverting to PDF...")
        
        try:
            result = subprocess.run([
                'libreoffice', '--headless', '--convert-to', 'pdf',
                '--outdir', str(output_path.parent),
                str(output_path)
            ], capture_output=True, text=True, timeout=45)
            
            if pdf_path.exists():
                print(f"✓ Created PDF: {pdf_path}")
                print(f"\n{'='*80}")
                print(f"SUCCESS! Files created:")
                print(f"  ODT: {output_path.name}")
                print(f"  PDF: {pdf_path.name}")
                print(f"{'='*80}\n")
            else:
                print(f"⚠ PDF conversion failed. Please convert manually.")
                
        except Exception as e:
            print(f"⚠ Could not auto-convert to PDF: {e}")
            print(f"   Open {output_path} in LibreOffice and export manually")


if __name__ == '__main__':
    main()
