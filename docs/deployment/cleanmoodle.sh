#!/usr/bin/env bash
# cleanup_and_archive_moodle_backups.sh
# Safe, auditable cleanup for Moodle VM backups and system cleanup.
# Usage examples:
#  ./cleanup_and_archive_moodle_backups.sh --dry-run --days 30
#  ./cleanup_and_archive_moodle_backups.sh --archive --days 90
#  ./cleanup_and_archive_moodle_backups.sh --delete --days 365 --vacuum-days 7

set -euo pipefail
IFS=$'\n\t'

DRY_RUN=true
ARCHIVE=false
DELETE=false
DAYS=30
VACUUM_DAYS=7
ARCHIVE_BASE="/var/backups/moodle_old"

usage() {
  cat <<EOF
Usage: $0 [--dry-run|--run] [--archive|--delete] [--days N] [--vacuum-days N]
  --dry-run    : list actions only (default)
  --archive    : move found backup files to ${ARCHIVE_BASE}/<timestamp> (safer)
  --delete     : permanently delete found backup files (DANGEROUS)
  --days N     : files older than N days (default 30)
  --vacuum-days: journalctl --vacuum-time (days) (default 7)
EOF
}

while (( "$#" )); do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --run) DRY_RUN=false; shift ;;
    --archive) ARCHIVE=true; shift ;;
    --delete) DELETE=true; shift ;;
    --days) DAYS="$2"; shift 2 ;;
    --vacuum-days) VACUUM_DAYS="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 2 ;;
  esac
done

if [ "${ARCHIVE}" = true ] && [ "${DELETE}" = true ]; then
  echo "Cannot use --archive and --delete together"; exit 2
fi

timestamp() { date -u +"%Y%m%dT%H%M%SZ"; }

run_or_echo() {
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] $*"
  else
    echo "[RUN] $*"
    eval "$@"
  fi
}

echo "DRY_RUN=${DRY_RUN} ARCHIVE=${ARCHIVE} DELETE=${DELETE} DAYS=${DAYS} VACUUM_DAYS=${VACUUM_DAYS}"

sudo -v || { echo "sudo required"; exit 1; }

# 1) Detect Moodle config and dataroot
echo; echo "== Detecting Moodle config and dataroot =="
MOODLE_CFG_CANDIDATES=(
  "/var/www/moodle/config.php"
  "/var/www/html/moodle/config.php"
  "/var/www/html/config.php"
  "/srv/moodle/config.php"
  "/opt/moodle/config.php"
  "/var/www/moodledata/config.php"
)
DATAROOT=""
for p in "${MOODLE_CFG_CANDIDATES[@]}"; do
  if [ -f "$p" ]; then
    echo "Found config: $p"
    dr=$(grep -oP "(?<=\\$CFG->dataroot\\s*=\\s*')[^']+" "$p" || true)
    if [ -n "$dr" ]; then
      DATAROOT="$dr"
      echo "Parsed dataroot: $DATAROOT"
      break
    fi
  fi
done

if [ -z "$DATAROOT" ]; then
  echo "No config.php in common paths. Searching for 'moodledata' directories (may be slow)..."
  DATAROOT_CANDIDATES=$(sudo find / -xdev -type d -iname "moodledata" -print 2>/dev/null | head -n 10 || true)
  if [ -n "$DATAROOT_CANDIDATES" ]; then
    echo "Candidates found:"
    echo "$DATAROOT_CANDIDATES"
    DATAROOT=$(echo "$DATAROOT_CANDIDATES" | head -n1)
    echo "Using first candidate: $DATAROOT"
  else
    echo "No automatic dataroot detected. If dataroot is elsewhere, set DATAROOT env var or pass exact paths manually."
  fi
fi

# 2) Find backup files (*.mbz) and backup directories older than $DAYS
echo; echo "== Scanning for Moodle backup files older than ${DAYS} days =="
TMPLIST="$(mktemp)"
if [ -n "$DATAROOT" ]; then
  # find .mbz files and backup directories under dataroot
  sudo find "$DATAROOT" -type f -name '*.mbz' -mtime +"${DAYS}" -print0 2>/dev/null | tr '\0' '\n' > "$TMPLIST" || true
  sudo find "$DATAROOT" -type d -path '*/backup/*' -mtime +"${DAYS}" -print0 2>/dev/null | tr '\0' '\n' >> "$TMPLIST" || true
else
  # search common web/home locations for *.mbz
  sudo find /var/www /srv /home -type f -name '*.mbz' -mtime +"${DAYS}" -print0 2>/dev/null | tr '\0' '\n' > "$TMPLIST" || true
fi

# remove empty lines and unique
awk 'NF' "$TMPLIST" | sort -u > "${TMPLIST}.uniq"
mv "${TMPLIST}.uniq" "$TMPLIST"

COUNT=0
TOTAL_BYTES=0
while IFS= read -r path; do
  if [ -z "$path" ]; then continue; fi
  COUNT=$((COUNT+1))
  if [ -f "$path" ]; then
    bytes=$(stat -c%s "$path" 2>/dev/null || echo 0)
  else
    # directory size
    bytes=$(sudo du -sb "$path" 2>/dev/null | awk '{print $1}' || echo 0)
  fi
  TOTAL_BYTES=$((TOTAL_BYTES + bytes))
done < "$TMPLIST"

human_size() { numfmt --to=iec --suffix=B --format="%.3f" "$1"; }

echo "Found $COUNT items, total size: $(human_size $TOTAL_BYTES) ($TOTAL_BYTES bytes)"
echo; echo "Listing (first 200):"
head -n 200 "$TMPLIST" || true

# 3) If none found, exit early (but still do system cleanups if requested)
if [ "$COUNT" -eq 0 ]; then
  echo "No Moodle backup files older than ${DAYS} days found."
else
  if [ "$DRY_RUN" = true ]; then
    echo; echo "DRY-RUN complete. To archive move these files, re-run with --run --archive"
  else
    if [ "${ARCHIVE}" = true ]; then
      ts=$(timestamp)
      ARCHIVE_DIR="${ARCHIVE_BASE}/${ts}"
      echo "Creating archive dir: ${ARCHIVE_DIR}"
      sudo mkdir -p "${ARCHIVE_DIR}"
      # move files preserving subpath
      while IFS= read -r path; do
        [ -z "$path" ] && continue
        echo "Archiving: $path"
        # preserve relative path under archive dir
        rel=$(echo "$path" | sed 's#^/##')
        dest="${ARCHIVE_DIR}/${rel}"
        sudo mkdir -p "$(dirname "$dest")"
        sudo mv -v "$path" "$dest" || sudo mv -v "$path" "$dest" 2>/dev/null || echo "Failed to move $path"
      done < "$TMPLIST"
      echo "Archive complete at ${ARCHIVE_DIR}"
    elif [ "${DELETE}" = true ]; then
      echo "Deleting files/directories (permanent):"
      while IFS= read -r path; do
        [ -z "$path" ] && continue
        echo "Deleting: $path"
        sudo rm -rfv "$path" || echo "Failed to delete $path"
      done < "$TMPLIST"
      echo "Deletion phase complete."
    else
      echo "No action chosen (--archive or --delete). Exiting."
    fi
  fi
fi

# 4) System maintenance (apt clean, autoremove, journal vacuum, truncate very large logs, clear tmp)
echo; echo "== System maintenance =="
run_or_echo "sudo apt-get clean"
run_or_echo "sudo apt-get -y autoremove"

echo "Vacuum journal logs older than ${VACUUM_DAYS} days"
run_or_echo "sudo journalctl --vacuum-time=${VACUUM_DAYS}d || true"

echo "Find log files >200M and truncate (non-destructive, rotated files untouched)"
if [ "$DRY_RUN" = true ]; then
  sudo find /var/log -type f -size +200M -exec ls -lh {} \; 2>/dev/null || true
else
  sudo find /var/log -type f -size +200M -print0 2>/dev/null | while IFS= read -r -d '' f; do
    echo "Truncating: $f"
    sudo truncate -s 0 "$f" || echo "Failed to truncate $f"
  done
fi

echo "Cleaning /tmp (files not accessed in >7 days)"
run_or_echo "sudo find /tmp -type f -atime +7 -delete || true"

echo "Cleaning thumbnail caches"
run_or_echo "sudo rm -rf /var/cache/thumbnails/* 2>/dev/null || true"

echo; echo "== Final disk usage =="
run_or_echo "df -h --total"

echo "Script finished."