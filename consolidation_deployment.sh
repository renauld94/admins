#!/usr/bin/env bash
set -euo pipefail

# consolidation_deployment.sh
# Safe migration helper for consolidating 117 modules -> 43 lessons.
# Usage (dry-run): ./consolidation_deployment.sh
# To actually run migration (requires DB credentials and explicit consent):
# RUN_MIGRATE=1 ./consolidation_deployment.sh

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$BASE_DIR/backups/moodle_backups"
DRYSQL="$BACKUP_DIR/consolidation_dryrun_$(date +%Y%m%d_%H%M%S).sql"

echo "🚀 Consolidation Deployment Helper"
echo "Base dir: $BASE_DIR"
echo "Backup dir: $BACKUP_DIR"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "Creating backup directory: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
fi

echo "\n📋 Generating dry-run SQL to: $DRYSQL"
cat > "$DRYSQL" <<'SQL'
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

SQL

echo "✅ Dry-run SQL created: $DRYSQL"

if [ "${RUN_MIGRATE:-0}" != "1" ]; then
  echo "\n⚠️ RUN_MIGRATE not set. This is a dry-run only. To execute migration, set RUN_MIGRATE=1 and rerun."
  echo "   Example: RUN_MIGRATE=1 bash consolidation_deployment.sh"
  exit 0
fi

echo "\n🔐 RUN_MIGRATE=1 set — applying migration (FINAL STEP)"

read -p "Are you absolutely sure you want to apply the consolidation to the production DB? (type 'YES' to continue) " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
  echo "Aborting — confirmation not received. No changes applied." >&2
  exit 1
fi

echo "\n⏳ Executing SQL in: $DRYSQL"
echo "Please run the following command as DB admin to apply (example):"
echo "  mysql -u <user> -p <database> < $DRYSQL"
echo "\n-- The script will not attempt to run mysql automatically to avoid accidental damage."

echo "\n✅ Consolidation helper finished. Dry-run available. Review before applying."

exit 0
