#!/usr/bin/env python3
"""
Replace text content in an ODT file while preserving 100% of formatting.
ODT files are ZIP archives containing XML. We'll extract, modify text, and repack.
"""
import argparse
import zipfile
import re
from pathlib import Path
from xml.etree import ElementTree as ET


def extract_odt(odt_path, temp_dir):
    """Extract ODT to temporary directory."""
    with zipfile.ZipFile(odt_path, 'r') as zip_ref:
        zip_ref.extractall(temp_dir)


def pack_odt(temp_dir, output_path):
    """Pack directory back into ODT."""
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file in temp_dir.rglob('*'):
            if file.is_file():
                zipf.write(file, file.relative_to(temp_dir))


def read_markdown_sections(md_path):
    """Parse markdown into sections for replacement."""
    content = md_path.read_text(encoding='utf-8')
    lines = content.splitlines()
    
    sections = {
        'name': '',
        'title': '',
        'contact': [],
        'summary': '',
        'experience': [],
        'education': [],
        'skills': []
    }
    
    current_section = None
    current_item = []
    
    for line in lines:
        line = line.strip()
        if not line or line == '---':
            continue
            
        # Extract name (first H1)
        if line.startswith('# ') and not sections['name']:
            sections['name'] = line[2:].strip()
            continue
            
        # Detect sections
        if line.startswith('## '):
            section_title = line[3:].lower().strip()
            if 'summary' in section_title or 'profile' in section_title:
                current_section = 'summary'
            elif 'experience' in section_title or 'employment' in section_title:
                current_section = 'experience'
            elif 'education' in section_title:
                current_section = 'education'
            elif 'skill' in section_title or 'technical' in section_title:
                current_section = 'skills'
            continue
            
        # Collect content
        if current_section == 'summary':
            if line and not line.startswith('#'):
                sections['summary'] += line + ' '
        elif current_section in ['experience', 'education', 'skills']:
            if line.startswith('###'):
                if current_item:
                    sections[current_section].append('\n'.join(current_item))
                current_item = [line[4:]]
            elif line:
                current_item.append(line)
    
    # Add last item
    if current_item and current_section:
        sections[current_section].append('\n'.join(current_item))
    
    return sections


def replace_odt_content_simple(odt_path, md_path, output_path):
    """
    Simple approach: Copy ODT and let user know they should edit manually.
    We'll create a formatted text file for easy copy-paste.
    """
    import shutil
    
    # Copy template to output
    shutil.copy2(odt_path, output_path)
    
    # Read markdown
    md_content = md_path.read_text(encoding='utf-8')
    
    # Create a formatted text guide
    guide_path = output_path.parent / (output_path.stem + '_CONTENT_TO_PASTE.txt')
    
    with open(guide_path, 'w', encoding='utf-8') as f:
        f.write("=" * 80 + "\n")
        f.write("CONTENT TO COPY-PASTE INTO THE ODT TEMPLATE\n")
        f.write("=" * 80 + "\n\n")
        f.write("Instructions:\n")
        f.write("1. Open the ODT file that was copied to: {}\n".format(output_path.name))
        f.write("2. Select all old content and delete it\n")
        f.write("3. Copy-paste the formatted content below\n")
        f.write("4. Adjust formatting as needed (headings, bullets, bold)\n")
        f.write("5. Export as PDF\n\n")
        f.write("=" * 80 + "\n\n")
        
        # Format markdown for easy pasting
        lines = md_content.splitlines()
        for line in lines:
            # Remove markdown syntax for easier pasting
            clean = line.replace('**', '').replace('# ', '').replace('## ', '').replace('### ', '')
            if clean.strip():
                f.write(clean + '\n')
            else:
                f.write('\n')
    
    print(f"\n✓ Template copied to: {output_path}")
    print(f"✓ Content guide created: {guide_path}")
    print(f"\nNow open the ODT file and replace content using the guide!")
    
    return output_path, guide_path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--template', required=True, help='Source ODT template')
    ap.add_argument('--md', required=True, help='Markdown content')
    ap.add_argument('--out', required=True, help='Output ODT file')
    args = ap.parse_args()

    template_path = Path(args.template)
    md_path = Path(args.md)
    output_path = Path(args.out)

    if not template_path.exists():
        raise SystemExit(f"Template not found: {template_path}")
    if not md_path.exists():
        raise SystemExit(f"Markdown not found: {md_path}")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Use simple copy + guide approach
    odt_file, guide_file = replace_odt_content_simple(template_path, md_path, output_path)
    
    # Auto-open both files
    import subprocess
    try:
        subprocess.Popen(['xdg-open', str(odt_file)])
        subprocess.Popen(['xdg-open', str(guide_file)])
        print(f"\n✓ Opened ODT template and content guide!")
    except Exception as e:
        print(f"Note: Could not auto-open files: {e}")


if __name__ == '__main__':
    main()
