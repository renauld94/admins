-- Consolidation dry-run SQL
-- This file contains placeholder SQL statements to move content from old module ids
-- to consolidated lesson entries. It MUST be reviewed and edited by the DB admin
-- before applying.

-- Example (replace with validated IDs and table names):
-- UPDATE mdl_course_modules SET section = <new_section_id> WHERE id IN (<old_module_ids>);
-- DELETE FROM mdl_course_sections WHERE id IN (<deprecated_section_ids>);
-- INSERT INTO mdl_course_sections (course, section, summary) VALUES (<course_id>, <new_section_number>, 'Consolidated section');

-- NOTE: The script intentionally does not attempt to modify data automatically.
-- Use this file as a starting point for a safe manual migration.

