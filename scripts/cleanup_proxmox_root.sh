#!/bin/bash

# Cleanup Script for Proxmox Server Root Directory
# Author: Simon Renauld
# Date: $(date)

echo "🧹 Starting cleanup of Proxmox server root directory..."

# Change to root directory
cd /root

echo "📁 Current directory: $(pwd)"
echo "📋 Files to be deleted:"

# List files that will be deleted
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

# Check which files exist
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
echo "⚠️  About to delete ${#existing_files[@]} files/directories:"
for file in "${existing_files[@]}"; do
    if [ -d "$file" ]; then
        echo "  📁 Directory: $file"
    else
        echo "  📄 File: $file"
    fi
done

echo ""
read -p "🤔 Are you sure you want to delete these files? (yes/no): " confirm

if [ "$confirm" = "yes" ] || [ "$confirm" = "y" ]; then
    echo "🗑️  Deleting files..."
    
    deleted_count=0
    for file in "${existing_files[@]}"; do
        if rm -rf "$file"; then
            echo "  ✅ Deleted: $file"
            ((deleted_count++))
        else
            echo "  ❌ Failed to delete: $file"
        fi
    done
    
    echo ""
    echo "🎉 Cleanup completed!"
    echo "📊 Summary:"
    echo "  - Files deleted: $deleted_count"
    echo "  - Files failed: $((${#existing_files[@]} - deleted_count))"
    
    echo ""
    echo "📁 Remaining files in /root:"
    ls -la | head -20
    
else
    echo "❌ Cleanup cancelled by user."
    exit 1
fi
