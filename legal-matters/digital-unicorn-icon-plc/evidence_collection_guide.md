# Evidence Collection Guide - Digital Unicorn vs ICON PLC

## OneDrive Evidence Link

**URL**: https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=iK7ARH

## Recommended Evidence Collection Steps

### Step 1: Archive the OneDrive Link

```bash
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc

python3 web_evidence_archiver.py \
  --case-name "Digital Unicorn ICON PLC - OneDrive Evidence Folder" \
  --output-dir "./evidence_onedrive" \
  "https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=iK7ARH"
```

### Step 2: Manual Download and Documentation

Since OneDrive requires authentication and the web archiver may not capture the full content:

1. **Open the link in your browser** (already authenticated)
2. **Take screenshots** showing:
   - Full URL in address bar with timestamp
   - Folder structure and file list
   - File metadata (dates, sizes, owners)
   - Each file preview if possible

3. **Download all files** from the OneDrive folder:
   - Right-click → Download
   - Or use "Download" button if folder shared
   - Keep original timestamps

4. **Document the download**:
   ```bash
   # Create evidence folder
   mkdir -p evidence_onedrive/downloaded_files
   
   # After downloading, move files there and create inventory
   ls -lh evidence_onedrive/downloaded_files > evidence_onedrive/file_inventory.txt
   ```

### Step 3: Hash Verification

Generate cryptographic hashes of all downloaded files:

```bash
cd evidence_onedrive/downloaded_files

# Generate SHA-256 hashes for all files
find . -type f -exec sha256sum {} \; > ../file_hashes.txt

# Also create MD5 hashes
find . -type f -exec md5sum {} \; > ../file_hashes_md5.txt
```

### Step 4: Metadata Extraction

Create a detailed manifest:

```bash
# File listing with full metadata
find . -type f -ls > ../file_metadata_detailed.txt

# Create JSON inventory (if you want programmatic access)
python3 << 'EOF'
import os
import json
import hashlib
from datetime import datetime
from pathlib import Path

def get_file_info(filepath):
    stat = filepath.stat()
    
    # Calculate hashes
    with open(filepath, 'rb') as f:
        content = f.read()
        sha256 = hashlib.sha256(content).hexdigest()
        md5 = hashlib.md5(content).hexdigest()
    
    return {
        'filename': filepath.name,
        'path': str(filepath),
        'size_bytes': stat.st_size,
        'modified_time': datetime.fromtimestamp(stat.st_mtime).isoformat(),
        'created_time': datetime.fromtimestamp(stat.st_ctime).isoformat(),
        'sha256': sha256,
        'md5': md5
    }

evidence_dir = Path('./evidence_onedrive/downloaded_files')
files_info = []

if evidence_dir.exists():
    for filepath in evidence_dir.rglob('*'):
        if filepath.is_file():
            files_info.append(get_file_info(filepath))

manifest = {
    'evidence_source': 'OneDrive folder',
    'source_url': 'https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=iK7ARH',
    'collection_date': datetime.utcnow().isoformat(),
    'total_files': len(files_info),
    'files': files_info
}

with open('./evidence_onedrive/manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)

print(f"Created manifest for {len(files_info)} files")
EOF
```

### Step 5: Screenshot Evidence

**Manual steps** (most important for legal evidence):

1. Open the OneDrive link in browser
2. Press `PrtScn` or use screenshot tool
3. Capture showing:
   - Browser address bar with full URL
   - System clock/date clearly visible
   - Full folder contents
   - File names, dates, sizes
   - Owner information if visible

4. Save screenshots as:
   - `evidence_onedrive/screenshot_01_folder_view.png`
   - `evidence_onedrive/screenshot_02_file_list.png`
   - `evidence_onedrive/screenshot_03_metadata.png`
   - etc.

### Step 6: Alternative - Use Browser Developer Tools

If you need to capture the exact HTML:

1. Open OneDrive link in Chrome/Firefox
2. Press F12 (Developer Tools)
3. Right-click on `<html>` element → Copy → Copy outerHTML
4. Save to file:
   ```bash
   # Paste the HTML content
   nano evidence_onedrive/onedrive_page_source.html
   ```

### Step 7: Video Recording (Strongest Evidence)

For the most compelling evidence:

1. Use screen recording software (OBS Studio, SimpleScreenRecorder)
2. Record your screen while:
   - Showing system date/time
   - Typing the URL in address bar
   - Navigating through folders
   - Opening files
   - Showing metadata
3. Save as: `evidence_onedrive/screen_recording.mp4`

```bash
# Install screen recorder if needed
sudo apt install simplescreenrecorder

# Or use OBS Studio (already mentioned in your workspace)
```

## What to Look For in OneDrive Folder

Based on your case (course plagiarism), look for:

### 1. Course Materials
- [ ] Jupyter notebooks (.ipynb files)
- [ ] Python scripts (.py files)
- [ ] Documentation files
- [ ] Assignment files
- [ ] Presentation slides

### 2. Metadata to Document
- [ ] File creation dates
- [ ] File modification dates
- [ ] File owner/creator information
- [ ] Folder structure
- [ ] Sharing settings/permissions
- [ ] Version history (if available)

### 3. Comparative Analysis Files
- [ ] Your original work (V1 files)
- [ ] Allegedly plagiarized work (V2 files)
- [ ] Side-by-side comparisons
- [ ] Highlighted differences

### 4. Communications
- [ ] Email screenshots
- [ ] Chat logs
- [ ] Comments on files
- [ ] Sharing invitations

## Evidence Chain of Custody

Document each step:

```bash
cat > evidence_onedrive/chain_of_custody.txt << 'EOF'
CHAIN OF CUSTODY LOG
====================

Case: Digital Unicorn vs ICON PLC - Course Material Plagiarism

Evidence Item: OneDrive Folder Contents
Source URL: https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=iK7ARH

Collection Steps:
-----------------

Date/Time: [FILL IN]
Collected By: [YOUR NAME]
Method: Direct download from OneDrive
Access: [Owner access / Shared link access]

1. Accessed OneDrive link via authenticated browser session
2. Verified folder contents and metadata
3. Downloaded all files preserving timestamps
4. Generated cryptographic hashes (SHA-256, MD5)
5. Captured screenshots of folder structure
6. Created detailed file manifest

Verification:
-------------
- Hash values generated: Yes
- Timestamps preserved: Yes
- Screenshots captured: Yes
- Metadata documented: Yes

Storage Location: ./evidence_onedrive/
Backup Location: [SPECIFY BACKUP LOCATION]

Custodian Signature: _____________________
Date: _____________________
EOF
```

## Creating Evidence Package

Once collected, package everything:

```bash
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc

# Create evidence archive
tar -czf evidence_onedrive_$(date +%Y%m%d_%H%M%S).tar.gz evidence_onedrive/

# Create checksums for the archive
sha256sum evidence_onedrive_*.tar.gz > evidence_package_checksums.txt
```

## Legal Considerations

### Admissibility Factors
1. **Authentication**: Can you prove this is the actual OneDrive folder?
2. **Best Evidence**: Original files are better than screenshots
3. **Chain of Custody**: Document every step
4. **Timestamps**: Use UTC timestamps, show system time
5. **Hash Values**: Prove content hasn't been altered

### Documentation to Include
- Web archive URLs (Wayback Machine, archive.today)
- Local HTML/screenshot captures
- Downloaded files with hashes
- Metadata extracts
- Chain of custody log
- Witness statements (if applicable)

## Next Steps After Collection

1. **Analyze the content** - compare with your original work
2. **Document similarities** - create comparison documents
3. **Timeline analysis** - prove which came first
4. **Expert witness** - technical expert to verify analysis
5. **Legal submission** - provide to your solicitor

## Quick Command Reference

```bash
# 1. Archive the link
python3 web_evidence_archiver.py --case-name "Digital Unicorn OneDrive Evidence" \
  "https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=iK7ARH"

# 2. Generate hashes after download
find evidence_onedrive/downloaded_files -type f -exec sha256sum {} \; > evidence_onedrive/hashes.txt

# 3. Create manifest
ls -lhR evidence_onedrive/downloaded_files > evidence_onedrive/file_list.txt

# 4. Package everything
tar -czf evidence_package_$(date +%Y%m%d).tar.gz evidence_onedrive/
```

## Important Notes

⚠️ **Privacy Considerations**: Ensure you have legal right to access and download this content
⚠️ **Backup**: Keep multiple backups in different locations
⚠️ **Legal Advice**: Consult with your solicitor on evidence collection procedures
⚠️ **Timestamps**: All times should be in UTC for international cases
⚠️ **Verification**: Independent third party should verify hashes if possible

---

**Remember**: I cannot access the OneDrive link directly or share any financial information. You need to manually access the link, download the content, and use the tools above to document it properly.
