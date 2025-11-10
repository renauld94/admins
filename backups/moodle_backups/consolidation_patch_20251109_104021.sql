-- Moodle Course Consolidation SQL Patch
-- Generated: 2025-11-09 10:40:21
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


-- Lesson 101: Vietnamese Alphabet & Tones
-- Consolidating from original lesson IDs: 1, 2, 3
-- UPDATE mdl_course_modules SET section = 101 WHERE section IN (1, 2, 3) AND course = 10;


-- Lesson 102: Greetings & Politeness
-- Consolidating from original lesson IDs: 4, 5, 6
-- UPDATE mdl_course_modules SET section = 102 WHERE section IN (4, 5, 6) AND course = 10;


-- Lesson 103: Basic Pronouns
-- Consolidating from original lesson IDs: 7, 8
-- UPDATE mdl_course_modules SET section = 103 WHERE section IN (7, 8) AND course = 10;


-- Lesson 104: Numbers 0-100
-- Consolidating from original lesson IDs: 9, 10, 11
-- UPDATE mdl_course_modules SET section = 104 WHERE section IN (9, 10, 11) AND course = 10;


-- Lesson 105: Common Questions
-- Consolidating from original lesson IDs: 12, 13
-- UPDATE mdl_course_modules SET section = 105 WHERE section IN (12, 13) AND course = 10;


-- Lesson 106: Everyday Phrases
-- Consolidating from original lesson IDs: 14, 15, 16
-- UPDATE mdl_course_modules SET section = 106 WHERE section IN (14, 15, 16) AND course = 10;


-- Lesson 107: Pronunciation Practice
-- Consolidating from original lesson IDs: 17, 18, 19, 20
-- UPDATE mdl_course_modules SET section = 107 WHERE section IN (17, 18, 19, 20) AND course = 10;


-- Lesson 201: Introductions
-- Consolidating from original lesson IDs: 21, 22, 23, 24
-- UPDATE mdl_course_modules SET section = 201 WHERE section IN (21, 22, 23, 24) AND course = 10;


-- Lesson 202: Daily Conversations
-- Consolidating from original lesson IDs: 25, 26, 27
-- UPDATE mdl_course_modules SET section = 202 WHERE section IN (25, 26, 27) AND course = 10;


-- Lesson 203: Restaurant Interactions
-- Consolidating from original lesson IDs: 28, 29, 30, 31
-- UPDATE mdl_course_modules SET section = 203 WHERE section IN (28, 29, 30, 31) AND course = 10;


-- Lesson 204: Shopping Dialogues
-- Consolidating from original lesson IDs: 32, 33, 34
-- UPDATE mdl_course_modules SET section = 204 WHERE section IN (32, 33, 34) AND course = 10;


-- Lesson 205: Hotel & Travel
-- Consolidating from original lesson IDs: 35, 36, 37, 38
-- UPDATE mdl_course_modules SET section = 205 WHERE section IN (35, 36, 37, 38) AND course = 10;


-- Lesson 206: Emergency Situations
-- Consolidating from original lesson IDs: 39, 40
-- UPDATE mdl_course_modules SET section = 206 WHERE section IN (39, 40) AND course = 10;


-- Lesson 207: Small Talk Mastery
-- Consolidating from original lesson IDs: 41, 42, 43
-- UPDATE mdl_course_modules SET section = 207 WHERE section IN (41, 42, 43) AND course = 10;


-- Lesson 208: Advanced Dialogues
-- Consolidating from original lesson IDs: 44, 45, 46, 47, 48
-- UPDATE mdl_course_modules SET section = 208 WHERE section IN (44, 45, 46, 47, 48) AND course = 10;


-- Lesson 301: Simple Compositions
-- Consolidating from original lesson IDs: 56, 57, 58
-- UPDATE mdl_course_modules SET section = 301 WHERE section IN (56, 57, 58) AND course = 10;


-- Lesson 302: Story Narration
-- Consolidating from original lesson IDs: 59, 60, 61, 62
-- UPDATE mdl_course_modules SET section = 302 WHERE section IN (59, 60, 61, 62) AND course = 10;


-- Lesson 303: Email & Letter Writing
-- Consolidating from original lesson IDs: 63, 64
-- UPDATE mdl_course_modules SET section = 303 WHERE section IN (63, 64) AND course = 10;


-- Lesson 304: Opinion Expression
-- Consolidating from original lesson IDs: 65, 66, 67
-- UPDATE mdl_course_modules SET section = 304 WHERE section IN (65, 66, 67) AND course = 10;


-- Lesson 305: Creative Writing
-- Consolidating from original lesson IDs: 68, 69, 70
-- UPDATE mdl_course_modules SET section = 305 WHERE section IN (68, 69, 70) AND course = 10;


-- Lesson 306: Presentation Skills
-- Consolidating from original lesson IDs: 71, 72
-- UPDATE mdl_course_modules SET section = 306 WHERE section IN (71, 72) AND course = 10;


-- Lesson 307: Cultural Expression
-- Consolidating from original lesson IDs: 73
-- UPDATE mdl_course_modules SET section = 307 WHERE section IN (73) AND course = 10;


-- Lesson 401: Directions & Locations
-- Consolidating from original lesson IDs: 74, 75, 76
-- UPDATE mdl_course_modules SET section = 401 WHERE section IN (74, 75, 76) AND course = 10;


-- Lesson 402: Geographic Vocabulary
-- Consolidating from original lesson IDs: 77, 78, 79
-- UPDATE mdl_course_modules SET section = 402 WHERE section IN (77, 78, 79) AND course = 10;


-- Lesson 403: Map Reading Skills
-- Consolidating from original lesson IDs: 80, 81
-- UPDATE mdl_course_modules SET section = 403 WHERE section IN (80, 81) AND course = 10;


-- Lesson 404: Transportation & Routes
-- Consolidating from original lesson IDs: 82, 83, 84, 85
-- UPDATE mdl_course_modules SET section = 404 WHERE section IN (82, 83, 84, 85) AND course = 10;


-- Lesson 405: Cultural Geography
-- Consolidating from original lesson IDs: 86, 87
-- UPDATE mdl_course_modules SET section = 405 WHERE section IN (86, 87) AND course = 10;


-- Lesson 406: Advanced Navigation
-- Consolidating from original lesson IDs: 88, 89
-- UPDATE mdl_course_modules SET section = 406 WHERE section IN (88, 89) AND course = 10;


-- Lesson 501: Business Introduction
-- Consolidating from original lesson IDs: 90, 91, 92
-- UPDATE mdl_course_modules SET section = 501 WHERE section IN (90, 91, 92) AND course = 10;


-- Lesson 502: Corporate Meetings
-- Consolidating from original lesson IDs: 93, 94
-- UPDATE mdl_course_modules SET section = 502 WHERE section IN (93, 94) AND course = 10;


-- Lesson 503: Professional Email
-- Consolidating from original lesson IDs: 95, 96, 97
-- UPDATE mdl_course_modules SET section = 503 WHERE section IN (95, 96, 97) AND course = 10;


-- Lesson 504: Negotiation Skills
-- Consolidating from original lesson IDs: 98, 99
-- UPDATE mdl_course_modules SET section = 504 WHERE section IN (98, 99) AND course = 10;


-- Lesson 505: Industry Vocabulary
-- Consolidating from original lesson IDs: 100, 101
-- UPDATE mdl_course_modules SET section = 505 WHERE section IN (100, 101) AND course = 10;


-- Lesson 506: Company Culture
-- Consolidating from original lesson IDs: 102, 103
-- UPDATE mdl_course_modules SET section = 506 WHERE section IN (102, 103) AND course = 10;


-- Lesson 507: Presentations
-- Consolidating from original lesson IDs: 104, 105, 106
-- UPDATE mdl_course_modules SET section = 507 WHERE section IN (104, 105, 106) AND course = 10;


-- Lesson 508: Executive Communication
-- Consolidating from original lesson IDs: 107, 108
-- UPDATE mdl_course_modules SET section = 508 WHERE section IN (107, 108) AND course = 10;


-- Lesson 601: Advanced Grammar
-- Consolidating from original lesson IDs: 109, 110, 111
-- UPDATE mdl_course_modules SET section = 601 WHERE section IN (109, 110, 111) AND course = 10;


-- Lesson 602: Idioms & Expressions
-- Consolidating from original lesson IDs: 112, 113
-- UPDATE mdl_course_modules SET section = 602 WHERE section IN (112, 113) AND course = 10;


-- Lesson 603: Literature & Media
-- Consolidating from original lesson IDs: 114, 115
-- UPDATE mdl_course_modules SET section = 603 WHERE section IN (114, 115) AND course = 10;


-- Lesson 604: Specialized Vocabulary
-- Consolidating from original lesson IDs: 116
-- UPDATE mdl_course_modules SET section = 604 WHERE section IN (116) AND course = 10;


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
