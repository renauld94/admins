# Proxmox Server Cleanup Instructions

## Server Information
- **Server IP**: 136.243.155.166
- **Server Type**: Proxmox VE 6.8.12-14-pve
- **Target Directory**: /root

## Files to Delete
Based on your request, these files should be deleted from `/root`:

### Course Files:
- `course1.mbz`
- `course2.mbz`
- `course3.mbz`
- `course5.mbz`

### Backup Files:
- `moodle_backup.tar.gz`
- `moodle_db_backup.sql`
- `moodle_project.tar.gz`
- `portfolio_backup_20251003_155807.tar.gz`
- `portfolio_backup_20251003_155814.tar.gz`
- `portfolio-site.tgz`

### Directories:
- `portfolio-backups/`

### Other Files:
- `t`

## Manual Cleanup Commands

Since SSH connection is timing out, you can run these commands directly on your Proxmox server:

### Option 1: Safe Deletion with Confirmation
```bash
cd /root

# Check what files exist
ls -la | grep -E "(course[1-5]\.mbz|moodle_backup|moodle_db_backup|moodle_project|portfolio_backup|portfolio-site\.tgz|^t$|portfolio-backups)"

# Delete files one by one (safer)
rm -f course1.mbz course2.mbz course3.mbz course5.mbz
rm -f moodle_backup.tar.gz moodle_db_backup.sql moodle_project.tar.gz
rm -f portfolio_backup_20251003_155807.tar.gz portfolio_backup_20251003_155814.tar.gz
rm -f portfolio-site.tgz
rm -f t
rm -rf portfolio-backups
```

### Option 2: Bulk Deletion
```bash
cd /root

# Delete all specified files at once
rm -f course1.mbz course2.mbz course3.mbz course5.mbz \
      moodle_backup.tar.gz moodle_db_backup.sql moodle_project.tar.gz \
      portfolio_backup_20251003_155807.tar.gz portfolio_backup_20251003_155814.tar.gz \
      portfolio-site.tgz t

# Delete directory
rm -rf portfolio-backups
```

### Option 3: Using the Cleanup Script
If you can copy the cleanup script to your server:

1. **Copy the script** to your Proxmox server:
   ```bash
   # On your local machine, copy the script content and paste it into a file on the server
   nano /root/cleanup_proxmox_root.sh
   ```

2. **Make it executable**:
   ```bash
   chmod +x /root/cleanup_proxmox_root.sh
   ```

3. **Run the script**:
   ```bash
   ./cleanup_proxmox_root.sh
   ```

## Verification

After deletion, verify the cleanup:

```bash
# Check remaining files
ls -la /root

# Check disk space (optional)
df -h

# Check if any of the deleted files still exist
ls -la /root | grep -E "(course[1-5]\.mbz|moodle_backup|moodle_db_backup|moodle_project|portfolio_backup|portfolio-site\.tgz|^t$|portfolio-backups)"
```

## Safety Notes

- **Backup Important Data**: Make sure these files are not needed before deletion
- **Check Dependencies**: Ensure no services depend on these files
- **Verify Paths**: Double-check you're in the correct directory (`/root`)

## Alternative: Copy Script Content

If you can't transfer the script file, here's the content you can copy-paste directly on your Proxmox server:

```bash
#!/bin/bash
echo "🧹 Starting cleanup of Proxmox server root directory..."
cd /root

files_to_delete=(
    "course1.mbz"
    "course2.mbz" 
    "course3.mbz"
    "course5.mbz"
    "moodle_backup.tar.gz"
    "moodle_db_backup.sql"
    "moodle_project.tar.gz"
    "portfolio_backup_20251003_155807.tar.gz"
    "portfolio_backup_20251003_155814.tar.gz"
    "portfolio-backups"
    "portfolio-site.tgz"
    "t"
)

echo "📋 Files to be deleted:"
existing_files=()
for file in "${files_to_delete[@]}"; do
    if [ -e "$file" ]; then
        existing_files+=("$file")
        echo "  ✅ Found: $file"
    else
        echo "  ❌ Not found: $file"
    fi
done

if [ ${#existing_files[@]} -eq 0 ]; then
    echo "ℹ️  No files to delete found."
    exit 0
fi

echo ""
echo "⚠️  About to delete ${#existing_files[@]} files/directories"
read -p "🤔 Are you sure? (yes/no): " confirm

if [ "$confirm" = "yes" ] || [ "$confirm" = "y" ]; then
    echo "🗑️  Deleting files..."
    for file in "${existing_files[@]}"; do
        if rm -rf "$file"; then
            echo "  ✅ Deleted: $file"
        else
            echo "  ❌ Failed to delete: $file"
        fi
    done
    echo "🎉 Cleanup completed!"
else
    echo "❌ Cleanup cancelled."
fi
```

---

**Next Steps:**
1. Log into your Proxmox server console
2. Run the cleanup commands above
3. Verify the files are deleted
4. Check available disk space
