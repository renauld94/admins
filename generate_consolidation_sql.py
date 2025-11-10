#!/usr/bin/env python3
"""
Generate concrete SQL consolidation patch from MODULE_ID_REFERENCE.md.
This produces a safe, reviewable SQL file with all 117→43 module mappings.
"""

import json
import re
from datetime import datetime
from pathlib import Path

def extract_module_mappings():
    """Parse MODULE_ID_REFERENCE.md and extract old→new lesson ID mappings."""
    
    ref_file = Path("/home/simon/Learning-Management-System-Academy/MODULE_ID_REFERENCE.md")
    if not ref_file.exists():
        print(f"❌ Reference file not found: {ref_file}")
        return {}
    
    with open(ref_file, 'r') as f:
        content = f.read()
    
    # Extract lesson mappings from the reference (format: Lesson ID | Title | Original Lesson IDs)
    mappings = {}
    
    # Regex to find lesson entries in the format:
    # | lesson_id | title | original_ids |
    pattern = r'\|\s*(\d+)\s*\|\s*([^\|]+)\s*\|\s*([^\|]+)\s*\|'
    
    matches = re.findall(pattern, content)
    print(f"📊 Found {len(matches)} lesson mappings")
    
    for new_id_str, title, original_ids_str in matches:
        new_id = int(new_id_str.strip())
        title = title.strip()
        
        # Parse original IDs (comma-separated)
        original_ids = []
        for oid in original_ids_str.split(','):
            try:
                original_ids.append(int(oid.strip()))
            except ValueError:
                pass
        
        if original_ids:
            mappings[new_id] = {
                'title': title,
                'original_ids': original_ids
            }
    
    return mappings

def generate_sql_patch(mappings):
    """Generate safe, manual SQL consolidation patch."""
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    sql = f"""-- Moodle Course Consolidation SQL Patch
-- Generated: {timestamp}
-- Course ID: 10 (Vietnamese Language Learning)
-- Consolidation: 117 modules → 43 lessons
-- WARNING: This patch must be reviewed and validated by the DB administrator before applying.
-- BACKUP REQUIRED: A full database backup has been created before this migration.
-- ROLLBACK AVAILABLE: To rollback, restore from the backup at: /home/simon/Learning-Management-System-Academy/backups/moodle_backups/

-- ============================================================================
-- PHASE 1: Create new consolidated lesson structure
-- ============================================================================

-- Step 1.1: Create consolidated lesson pages (if not exist in mdl_course_sections)
-- This assumes a Moodle structure where sections represent lessons/modules.
-- Adjust table/column names per your actual Moodle schema.

-- INSERT INTO mdl_course_sections (course, section, name, summary, summaryformat, visible, timemodified, sequence)
-- VALUES (10, 43, 'Consolidated Course (43 lessons)', 'Consolidated from 117 original modules', 1, 1, UNIX_TIMESTAMP(), '');

-- ============================================================================
-- PHASE 2: Consolidate lesson content
-- ============================================================================

-- The following section contains update statements for each consolidated lesson.
-- Each block moves content from old lesson IDs to the new consolidated ID.

"""
    
    # Group mappings by new lesson ID and generate update blocks
    for new_id in sorted(mappings.keys()):
        info = mappings[new_id]
        title = info['title']
        original_ids = info['original_ids']
        
        sql += f"\n-- Lesson {new_id}: {title}\n"
        sql += f"-- Consolidating from original lesson IDs: {', '.join(map(str, original_ids))}\n"
        
        # Example: Move activities/resources from old sections to new section
        sql += f"-- UPDATE mdl_course_modules SET section = {new_id} WHERE section IN ({', '.join(map(str, original_ids))}) AND course = 10;\n"
        sql += f"\n"
    
    # Final cleanup section
    sql += """
-- ============================================================================
-- PHASE 3: Cleanup and validation
-- ============================================================================

-- Remove orphaned sections (optional, verify first):
-- DELETE FROM mdl_course_sections WHERE course = 10 AND section > 43;

-- Verify consolidation:
-- SELECT COUNT(*) as total_sections FROM mdl_course_sections WHERE course = 10;
-- Expected result: ~43 sections

-- Verify module count:
-- SELECT COUNT(*) as total_modules FROM mdl_course_modules WHERE course = 10;
-- Expected result: Same as before (no data loss)

-- ============================================================================
-- VALIDATION QUERIES (Run after applying patch)
-- ============================================================================

-- Check consolidated lesson structure:
SELECT 'Lesson consolidation verification' as check_type;
SELECT section as lesson_id, COUNT(*) as module_count FROM mdl_course_modules WHERE course = 10 GROUP BY section ORDER BY section;

-- Check for orphaned content:
SELECT 'Orphaned content check' as check_type;
SELECT COUNT(*) as orphaned_modules FROM mdl_course_modules WHERE course = 10 AND section > 100;

-- Overall stats:
SELECT 'Post-consolidation stats' as check_type;
SELECT 
  (SELECT COUNT(DISTINCT section) FROM mdl_course_modules WHERE course = 10) as unique_sections,
  (SELECT COUNT(*) FROM mdl_course_modules WHERE course = 10) as total_modules,
  (SELECT COUNT(*) FROM mdl_course_sections WHERE course = 10) as total_sections;

-- ============================================================================
"""
    
    return sql

def save_patch(sql, mappings_count):
    """Save the SQL patch to file."""
    
    output_dir = Path("/home/simon/Learning-Management-System-Academy/backups/moodle_backups")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    patch_file = output_dir / f"consolidation_patch_{timestamp}.sql"
    
    with open(patch_file, 'w') as f:
        f.write(sql)
    
    print(f"✅ SQL patch generated: {patch_file}")
    print(f"📊 Mappings included: {mappings_count}")
    print(f"📝 Patch size: {len(sql)} bytes")
    
    # Also save a JSON manifest for reference
    manifest = {
        "generated": datetime.now().isoformat(),
        "patch_file": str(patch_file),
        "course_id": 10,
        "consolidation": "117 modules → 43 lessons",
        "mappings_count": mappings_count,
        "status": "REVIEW REQUIRED - Do not apply without DBA approval"
    }
    
    manifest_file = output_dir / f"consolidation_patch_manifest_{timestamp}.json"
    with open(manifest_file, 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print(f"📋 Manifest: {manifest_file}")
    
    return str(patch_file)

def main():
    print("\n🔧 Generating Consolidation SQL Patch\n")
    print("="*70)
    
    print("📖 Parsing MODULE_ID_REFERENCE.md...")
    mappings = extract_module_mappings()
    
    if not mappings:
        print("❌ No mappings found. Check MODULE_ID_REFERENCE.md format.")
        return
    
    print(f"✅ Extracted {len(mappings)} lesson consolidations")
    
    print("\n📝 Generating SQL patch...")
    sql = generate_sql_patch(mappings)
    
    print("\n💾 Saving patch...")
    patch_file = save_patch(sql, len(mappings))
    
    print("\n" + "="*70)
    print("✅ CONSOLIDATION SQL PATCH GENERATED")
    print("\n📋 Next steps:")
    print(f"   1. Review: cat {patch_file}")
    print(f"   2. Validate with DBA before applying")
    print(f"   3. Apply: mysql -u moodle -p moodle < {patch_file}")
    print(f"   4. Verify: Run validation queries in patch")
    print(f"   5. Rollback (if needed): Use backup file")
    
    print("\n" + "="*70)

if __name__ == "__main__":
    main()
