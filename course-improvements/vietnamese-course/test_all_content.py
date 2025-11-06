#!/usr/bin/env python3
"""
Test all course modules for content, duplicates, and quality
Uses the working moodle_client.py approach
"""

import sys
import base64
import subprocess
import json
import re
from collections import defaultdict

def get_page_modules():
    """Get all page modules with content"""
    php_code = """<?php
define('CLI_SCRIPT', true);
require('/bitnami/moodle/config.php');

$courseid = 10;

$sql = "SELECT cm.id as cmid, p.name, LENGTH(p.content) as content_len, 
               SUBSTRING(p.content, 1, 1000) as content_sample, cs.section
        FROM {course_modules} cm
        JOIN {modules} m ON m.id = cm.module AND m.name = 'page'
        JOIN {page} p ON p.id = cm.instance
        JOIN {course_sections} cs ON cs.id = cm.section
        WHERE cs.course = ? AND cm.deletioninprogress = 0
        ORDER BY cs.section, cm.id";
        
$pages = $DB->get_records_sql($sql, array($courseid));
echo json_encode(array_values($pages));
?>"""
    
    encoded = base64.b64encode(php_code.encode('utf-8')).decode('utf-8')
    cmd = [
        "ssh", "moodle-vm9001",
        f"sudo docker exec moodle-databricks-fresh bash -c 'echo {encoded} | base64 -d | php' 2>&1"
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    # Filter out PHP warnings
    lines = result.stdout.strip().split('\n')
    json_lines = [l for l in lines if l.strip().startswith('[')]
    
    if json_lines:
        return json.loads(json_lines[-1])
    return []

def analyze_content(sample, length):
    """Analyze content quality"""
    has_vietnamese = bool(re.search(r'[àáảãạăắằẳẵặâấầẩẫậđèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵ]', sample, re.IGNORECASE))
    has_agent = 'vietnamese-tutor-agent' in sample.lower() or 'agent-widget' in sample.lower()
    has_headings = bool(re.search(r'<h[1-6]', sample))
    has_lists = bool(re.search(r'<[ou]l>', sample))
    has_tables = bool(re.search(r'<table', sample))
    
    quality_score = sum([
        has_vietnamese,
        has_agent,
        has_headings,
        has_lists,
        length > 500,
        length > 2000
    ])
    
    return {
        "has_content": length > 0,
        "length": length,
        "has_vietnamese": has_vietnamese,
        "has_agent": has_agent,
        "has_headings": has_headings,
        "has_lists": has_lists,
        "has_tables": has_tables,
        "quality_score": quality_score
    }

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║          VIETNAMESE COURSE - CONTENT QUALITY TEST                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    print("📊 Fetching all page modules...")
    modules = get_page_modules()
    print(f"✅ Found {len(modules)} page modules\n")
    
    if not modules:
        print("❌ No modules found!")
        return 1
    
    # Group by section
    by_section = defaultdict(list)
    stats = {
        "total": len(modules),
        "has_content": 0,
        "has_vietnamese": 0,
        "has_agent": 0,
        "high_quality": 0,
        "medium_quality": 0,
        "low_quality": 0
    }
    
    name_counts = defaultdict(list)
    
    for mod in modules:
        section = int(mod['section'])
        name = mod['name']
        length = int(mod['content_len'])
        sample = mod['content_sample']
        
        analysis = analyze_content(sample, length)
        
        by_section[section].append({
            'id': mod['cmid'],
            'name': name,
            'analysis': analysis
        })
        
        name_counts[name].append(mod['cmid'])
        
        if analysis['has_content']:
            stats['has_content'] += 1
        
        if analysis['has_vietnamese']:
            stats['has_vietnamese'] += 1
        
        if analysis['has_agent']:
            stats['has_agent'] += 1
        
        if analysis['quality_score'] >= 5:
            stats['high_quality'] += 1
        elif analysis['quality_score'] >= 3:
            stats['medium_quality'] += 1
        else:
            stats['low_quality'] += 1
    
    # Display by section
    print("=" * 70)
    print("CONTENT ANALYSIS BY SECTION")
    print("=" * 70)
    
    for section in sorted(by_section.keys()):
        print(f"\n📚 SECTION {section}")
        print("-" * 70)
        for mod in by_section[section]:
            a = mod['analysis']
            status = "✅" if a['has_content'] else "❌"
            quality = f"Q:{a['quality_score']}/6"
            viet = "🇻🇳" if a['has_vietnamese'] else "  "
            agent = "🤖" if a['has_agent'] else "  "
            length = f"{a['length']:>5}ch"
            
            # Color code quality
            if a['quality_score'] >= 5:
                q_icon = "🌟"
            elif a['quality_score'] >= 3:
                q_icon = "⭐"
            else:
                q_icon = "⚠️ "
            
            print(f"{status} {viet} {agent} {q_icon} {quality} {length} | ID:{mod['id']:>3} | {mod['name'][:45]}")
    
    # Statistics
    print("\n" + "=" * 70)
    print("OVERALL STATISTICS")
    print("=" * 70)
    print(f"Total modules:        {stats['total']}")
    print(f"With content:         {stats['has_content']} ({stats['has_content']*100//stats['total']}%)")
    print(f"With Vietnamese:      {stats['has_vietnamese']} ({stats['has_vietnamese']*100//stats['total']}%)")
    print(f"With Agent widget:    {stats['has_agent']} ({stats['has_agent']*100//stats['total']}%)")
    print(f"High quality (5-6/6): {stats['high_quality']} ({stats['high_quality']*100//stats['total']}%)")
    print(f"Medium quality (3-4): {stats['medium_quality']} ({stats['medium_quality']*100//stats['total']}%)")
    print(f"Low quality (0-2):    {stats['low_quality']} ({stats['low_quality']*100//stats['total']}%)")
    
    # Check duplicates
    print("\n" + "=" * 70)
    print("DUPLICATE NAMES CHECK")
    print("=" * 70)
    
    duplicates = {name: ids for name, ids in name_counts.items() if len(ids) > 1}
    
    if duplicates:
        print(f"\n⚠️  Found {len(duplicates)} duplicate names:\n")
        for name, ids in sorted(duplicates.items(), key=lambda x: len(x[1]), reverse=True):
            print(f"   [{len(ids)}x] '{name[:55]}'")
            print(f"         IDs: {', '.join(map(str, ids))}\n")
    else:
        print("✅ No duplicate names found")
    
    # Recommendations
    print("\n" + "=" * 70)
    print("RECOMMENDATIONS")
    print("=" * 70)
    
    if stats['low_quality'] > 0:
        print(f"⚠️  {stats['low_quality']} modules have low quality scores")
        print("   Consider adding: Vietnamese text, headings, lists, and more content")
    
    if stats['has_agent'] < stats['total'] * 0.5:
        print(f"⚠️  Only {stats['has_agent']} modules have AI Agent widgets")
        print("   Consider adding Vietnamese Tutor Agent to more lessons")
    
    if len(duplicates) > 0:
        print(f"⚠️  {len(duplicates)} duplicate names found")
        print("   Consider renaming or removing duplicates")
    
    if stats['high_quality'] >= stats['total'] * 0.7:
        print("✅ Great job! Most modules are high quality!")
    
    print("\n" + "=" * 70)
    print(f"🌐 View course: https://moodle.simondatalab.de/course/view.php?id=10")
    print("=" * 70)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
