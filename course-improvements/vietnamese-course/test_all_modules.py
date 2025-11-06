#!/usr/bin/env python3
"""
Test all course modules to check for:
1. Content exists
2. No duplicates
3. Engaging content quality
"""

import subprocess
import json
from collections import defaultdict
import re

def get_all_modules():
    """Get all modules from course via SSH"""
    cmd = r"""ssh moodle-vm9001 "sudo docker exec moodle-databricks-fresh php -r '
define(\"CLI_SCRIPT\", true);
require(\"/bitnami/moodle/config.php\");

$courseid = 10;

$sql = \"SELECT cm.id as cmid, p.name, SUBSTRING(p.content, 1, 2000) as content, cs.section
        FROM {course_modules} cm
        JOIN {modules} m ON m.id = cm.module AND m.name = '"'"'page'"'"'
        JOIN {page} p ON p.id = cm.instance
        JOIN {course_sections} cs ON cs.id = cm.section
        WHERE cs.course = ? AND cm.deletioninprogress = 0
        ORDER BY cs.section, cm.id\";
$pages = $DB->get_records_sql($sql, array($courseid));

echo json_encode(array_values($pages));
'"
"""
    
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0 or not result.stdout.strip():
        print(f"Error: {result.stderr}")
        return []
    return json.loads(result.stdout)

def analyze_content(content):
    """Analyze content quality"""
    if not content:
        return {"has_content": False, "length": 0, "has_vietnamese": False, "has_agent": False}
    
    length = len(content)
    has_vietnamese = bool(re.search(r'[àáảãạăắằẳẵặâấầẩẫậđèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵ]', content, re.IGNORECASE))
    has_agent = 'vietnamese-tutor-agent' in content.lower() or 'agent-widget' in content.lower()
    has_headings = bool(re.search(r'<h[1-6]', content))
    has_lists = bool(re.search(r'<[ou]l>', content))
    
    return {
        "has_content": True,
        "length": length,
        "has_vietnamese": has_vietnamese,
        "has_agent": has_agent,
        "has_headings": has_headings,
        "has_lists": has_lists,
        "quality_score": sum([has_vietnamese, has_agent, has_headings, has_lists, length > 500])
    }

def find_duplicates(modules):
    """Find duplicate content"""
    content_hashes = defaultdict(list)
    name_counts = defaultdict(list)
    
    for mod in modules:
        # Check duplicate names
        name_counts[mod['name']].append(mod['cmid'])
        
        # Check duplicate content (first 500 chars)
        content_start = mod['content'][:500] if mod['content'] else ""
        if content_start:
            content_hashes[content_start].append(mod['cmid'])
    
    # Find duplicates
    dup_names = {name: ids for name, ids in name_counts.items() if len(ids) > 1}
    dup_content = {ids[0]: ids for ids in content_hashes.values() if len(ids) > 1}
    
    return dup_names, dup_content

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║          VIETNAMESE COURSE - COMPREHENSIVE MODULE TEST               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    print("📊 Fetching all modules...")
    modules = get_all_modules()
    print(f"✅ Found {len(modules)} page modules\n")
    
    # Analyze each module
    print("=" * 70)
    print("CONTENT ANALYSIS")
    print("=" * 70)
    
    by_section = defaultdict(list)
    stats = {
        "total": len(modules),
        "has_content": 0,
        "has_vietnamese": 0,
        "has_agent": 0,
        "empty": 0,
        "high_quality": 0
    }
    
    for mod in modules:
        analysis = analyze_content(mod['content'])
        by_section[mod['section']].append({
            'id': mod['cmid'],
            'name': mod['name'],
            'analysis': analysis
        })
        
        if analysis['has_content']:
            stats['has_content'] += 1
        else:
            stats['empty'] += 1
        
        if analysis.get('has_vietnamese'):
            stats['has_vietnamese'] += 1
        
        if analysis.get('has_agent'):
            stats['has_agent'] += 1
        
        if analysis.get('quality_score', 0) >= 4:
            stats['high_quality'] += 1
    
    # Display by section
    for section in sorted(by_section.keys()):
        print(f"\n📚 SECTION {section}")
        print("-" * 70)
        for mod in by_section[section]:
            a = mod['analysis']
            status = "✅" if a['has_content'] else "❌"
            quality = f"Q:{a.get('quality_score', 0)}/5"
            viet = "🇻🇳" if a.get('has_vietnamese') else "  "
            agent = "🤖" if a.get('has_agent') else "  "
            length = f"{a['length']:>5}ch"
            
            print(f"{status} {viet} {agent} {quality} {length} | ID:{mod['id']:>3} | {mod['name'][:50]}")
    
    # Statistics
    print("\n" + "=" * 70)
    print("STATISTICS")
    print("=" * 70)
    print(f"Total modules:        {stats['total']}")
    print(f"With content:         {stats['has_content']} ({stats['has_content']*100//stats['total']}%)")
    print(f"Empty:                {stats['empty']}")
    print(f"With Vietnamese:      {stats['has_vietnamese']} ({stats['has_vietnamese']*100//stats['total']}%)")
    print(f"With Agent widget:    {stats['has_agent']} ({stats['has_agent']*100//stats['total']}%)")
    print(f"High quality (≥4/5):  {stats['high_quality']} ({stats['high_quality']*100//stats['total']}%)")
    
    # Check duplicates
    print("\n" + "=" * 70)
    print("DUPLICATE CHECK")
    print("=" * 70)
    
    dup_names, dup_content = find_duplicates(modules)
    
    if dup_names:
        print(f"\n⚠️  Found {len(dup_names)} duplicate names:")
        for name, ids in list(dup_names.items())[:10]:
            print(f"   '{name[:60]}' → IDs: {ids}")
    else:
        print("✅ No duplicate names found")
    
    if dup_content:
        print(f"\n⚠️  Found {len(dup_content)} potential duplicate content:")
        for main_id, ids in list(dup_content.items())[:10]:
            print(f"   ID {main_id} → Duplicates: {ids}")
    else:
        print("✅ No duplicate content found")
    
    # Sample content check
    print("\n" + "=" * 70)
    print("SAMPLE CONTENT CHECK (ID 220)")
    print("=" * 70)
    
    mod_220 = next((m for m in modules if m['cmid'] == 220), None)
    if mod_220:
        print(f"Name: {mod_220['name']}")
        print(f"Content length: {len(mod_220['content'])} characters")
        print(f"\nFirst 500 characters:")
        print("-" * 70)
        content_text = re.sub(r'<[^>]+>', '', mod_220['content'][:500])
        print(content_text)
        print("-" * 70)
        
        analysis = analyze_content(mod_220['content'])
        print(f"\nQuality Score: {analysis.get('quality_score', 0)}/5")
        print(f"✅ Vietnamese characters: {analysis.get('has_vietnamese')}")
        print(f"✅ Agent widget: {analysis.get('has_agent')}")
        print(f"✅ Headings: {analysis.get('has_headings')}")
        print(f"✅ Lists: {analysis.get('has_lists')}")
    
    print("\n" + "=" * 70)
    print("TEST COMPLETE")
    print("=" * 70)
    print(f"\n🌐 View course: https://moodle.simondatalab.de/course/view.php?id=10")

if __name__ == "__main__":
    main()
