# Comprehensive Evidence Collection Guide
## Digital Unicorn vs ICON PLC - Complete Documentation

**Case Reference**: Course Plagiarism / Intellectual Property Dispute  
**Date Created**: November 5, 2025  
**Evidence Location**: Multiple sources including OneDrive, local files, and web archives

---

## Table of Contents

1. [OneDrive Evidence Collection](#onedrive-evidence-collection)
2. [Local Evidence Documentation](#local-evidence-documentation)
3. [Web Archive Evidence](#web-archive-evidence)
4. [Screenshots & Pictures](#screenshots--pictures)
5. [Cryptographic Verification](#cryptographic-verification)
6. [Chain of Custody](#chain-of-custody)
7. [Evidence Packaging](#evidence-packaging)

---

## OneDrive Evidence Collection

### Evidence Sources

**OneDrive Links**:
1. **Primary Folder**: `https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=byAO2g`
2. **ICON PLC Documents**: `https://onedrive.live.com/?id=%2Fpersonal%2F6e5ed652c46b3548%2FDocuments%2F01%2EPersonnal%2Ficonplc`

### Method 1: Rclone Setup (Recommended for Bulk Download)

Rclone is a command-line tool for syncing files with cloud storage services.

#### Step 1: Install Rclone

```bash
# Install rclone if not already installed
curl https://rclone.org/install.sh | sudo bash

# Verify installation
rclone version
```

#### Step 2: Configure OneDrive Remote

```bash
# Start rclone configuration
rclone config

# Follow these steps:
# n) New remote
# name> iconplc_onedrive
# Storage> onedrive (or type 26 if numbered)
# client_id> (press Enter to skip)
# client_secret> (press Enter to skip)
# region> 1 (Microsoft Cloud Global)
# Edit advanced config? n
# Use auto config? y (this will open browser for authentication)

# After browser authentication completes:
# Choose drive type: 1 (OneDrive Personal)
# Confirm: y
# Quit: q
```

#### Step 3: Verify and List OneDrive Contents

```bash
# List remotes
rclone listremotes

# List contents of OneDrive root
rclone ls iconplc_onedrive:

# List specific folder (ICON PLC documents)
rclone ls iconplc_onedrive:Documents/01.Personnal/iconplc
```

#### Step 4: Download Evidence with Metadata Preservation

```bash
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc

# Create evidence directory
mkdir -p evidence_onedrive/iconplc_documents

# Download entire ICON PLC folder with full metadata
rclone copy --progress --metadata --checksum \
  "iconplc_onedrive:Documents/01.Personnal/iconplc" \
  "./evidence_onedrive/iconplc_documents" \
  --log-file=./evidence_onedrive/rclone_download.log

# Download with verification
rclone check "iconplc_onedrive:Documents/01.Personnal/iconplc" \
  "./evidence_onedrive/iconplc_documents" \
  --log-file=./evidence_onedrive/rclone_verify.log
```

#### Step 5: Generate File Inventory

```bash
# Create detailed file list from OneDrive
rclone lsl iconplc_onedrive:Documents/01.Personnal/iconplc > evidence_onedrive/onedrive_file_list.txt

# Create tree structure
rclone tree iconplc_onedrive:Documents/01.Personnal/iconplc > evidence_onedrive/onedrive_tree.txt

# Export as JSON with full metadata
rclone lsjson -R --hash --metadata \
  iconplc_onedrive:Documents/01.Personnal/iconplc > evidence_onedrive/onedrive_metadata.json
```

### Method 2: Manual Browser Download (Backup Method)

If rclone authentication fails:

1. **Open OneDrive links in browser** (already authenticated)
2. **Take full-page screenshots** showing:
   - URL in address bar
   - System date/time
   - File list with metadata
   - Folder structure
3. **Download files manually**:
   - Click "Download" button
   - Select "Download folder" or select all files
   - Save to `./evidence_onedrive/manual_download/`
4. **Document download process** with screenshots

### Method 3: Web Archive Capture

```bash
# Archive the OneDrive links using the web archiver tool
python3 web_evidence_archiver.py \
  --case-name "ICON PLC OneDrive Evidence" \
  --output-dir "./evidence_onedrive/web_archive" \
  "https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=byAO2g" \
  "https://onedrive.live.com/?id=%2Fpersonal%2F6e5ed652c46b3548%2FDocuments%2F01%2EPersonnal%2Ficonplc"
```

---

## Local Evidence Documentation

### Existing Evidence in digital_unicorn_outsource/

Your local folder already contains substantial evidence:

```bash
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/digital_unicorn_outsource
```

**Key Evidence Files**:
- ✅ **V1/** - Your original course materials (Version 1)
- ✅ **V2/** - Allegedly plagiarized materials (Version 2)
- ✅ **Requirements&Feedback_08SEP2025.xlsx** - Original requirements
- ✅ **ENHANCEMENT_REPORT.md** - Documentation
- ✅ **ai_detector.py** - AI detection analysis
- ✅ **shared_conversations.json** - Communication records
- ✅ **200+ image files** - Screenshots and evidence
- ✅ **Large ZIP archive** - Complete evidence package

### Document All Local Evidence

```bash
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc

# Create comprehensive inventory of local evidence
find digital_unicorn_outsource -type f -ls > evidence_inventory_local.txt

# Generate cryptographic hashes for all files
find digital_unicorn_outsource -type f -exec sha256sum {} \; > evidence_hashes_local_sha256.txt
find digital_unicorn_outsource -type f -exec md5sum {} \; > evidence_hashes_local_md5.txt

# Create detailed file manifest
python3 << 'EOFPYTHON'
import os
import json
import hashlib
from datetime import datetime
from pathlib import Path

def get_file_hash(filepath, algorithm='sha256'):
    """Calculate file hash"""
    hash_func = hashlib.sha256() if algorithm == 'sha256' else hashlib.md5()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            hash_func.update(chunk)
    return hash_func.hexdigest()

def analyze_directory(directory):
    """Analyze directory and create manifest"""
    manifest = {
        'evidence_source': 'Local Files - Digital Unicorn Outsource',
        'directory': str(directory),
        'analysis_date': datetime.utcnow().isoformat() + 'Z',
        'files': []
    }
    
    for root, dirs, files in os.walk(directory):
        for filename in files:
            filepath = Path(root) / filename
            try:
                stat = filepath.stat()
                file_info = {
                    'filename': filename,
                    'relative_path': str(filepath.relative_to(directory)),
                    'absolute_path': str(filepath),
                    'size_bytes': stat.st_size,
                    'size_human': f"{stat.st_size / 1024:.2f} KB" if stat.st_size < 1024*1024 else f"{stat.st_size / (1024*1024):.2f} MB",
                    'modified_time': datetime.fromtimestamp(stat.st_mtime).isoformat(),
                    'created_time': datetime.fromtimestamp(stat.st_ctime).isoformat(),
                    'extension': filepath.suffix,
                    'sha256': get_file_hash(filepath, 'sha256'),
                    'md5': get_file_hash(filepath, 'md5')
                }
                manifest['files'].append(file_info)
            except Exception as e:
                print(f"Error processing {filepath}: {e}")
    
    # Add summary statistics
    manifest['summary'] = {
        'total_files': len(manifest['files']),
        'total_size_bytes': sum(f['size_bytes'] for f in manifest['files']),
        'file_types': {}
    }
    
    # Count file types
    for file_info in manifest['files']:
        ext = file_info['extension'] or 'no_extension'
        manifest['summary']['file_types'][ext] = manifest['summary']['file_types'].get(ext, 0) + 1
    
    return manifest

# Generate manifest for local evidence
print("Analyzing digital_unicorn_outsource directory...")
evidence_dir = Path('./digital_unicorn_outsource')
if evidence_dir.exists():
    manifest = analyze_directory(evidence_dir)
    
    # Save manifest
    with open('./evidence_manifest_local.json', 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print(f"\n✅ Manifest created: evidence_manifest_local.json")
    print(f"📁 Total files: {manifest['summary']['total_files']}")
    print(f"💾 Total size: {manifest['summary']['total_size_bytes'] / (1024*1024):.2f} MB")
    print(f"\n📊 File type breakdown:")
    for ext, count in sorted(manifest['summary']['file_types'].items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"   {ext}: {count} files")
else:
    print(f"❌ Directory not found: {evidence_dir}")
EOFPYTHON
```

### Comparison Analysis V1 vs V2

Create detailed comparison of original vs allegedly plagiarized work:

```bash
# Create comparison directory
mkdir -p evidence_comparison

# Generate side-by-side comparison
python3 << 'EOFCOMP'
import json
from pathlib import Path
from difflib import unified_diff

def compare_notebooks(v1_path, v2_path):
    """Compare two Jupyter notebooks"""
    comparison = {
        'v1_file': str(v1_path),
        'v2_file': str(v2_path),
        'differences': []
    }
    
    try:
        with open(v1_path, 'r') as f1, open(v2_path, 'r') as f2:
            v1_content = f1.read()
            v2_content = f2.read()
            
            # Basic comparison
            comparison['identical'] = v1_content == v2_content
            comparison['v1_size'] = len(v1_content)
            comparison['v2_size'] = len(v2_content)
            
            # Calculate similarity percentage
            v1_lines = v1_content.splitlines()
            v2_lines = v2_content.splitlines()
            diff = list(unified_diff(v1_lines, v2_lines, lineterm=''))
            comparison['diff_lines'] = len([l for l in diff if l.startswith('+') or l.startswith('-')])
            comparison['similarity_pct'] = 100 * (1 - comparison['diff_lines'] / max(len(v1_lines), len(v2_lines), 1))
            
    except Exception as e:
        comparison['error'] = str(e)
    
    return comparison

# Compare V1 and V2 notebooks
v1_dir = Path('./digital_unicorn_outsource/V1/Sessions 2.1 2.2 2.3')
v2_dir = Path('./digital_unicorn_outsource/V2/Sessions 2.1 2.2 2.3')

comparisons = []

if v1_dir.exists() and v2_dir.exists():
    for v1_file in v1_dir.rglob('*.ipynb'):
        # Find corresponding V2 file
        rel_path = v1_file.relative_to(v1_dir)
        v2_file = v2_dir / rel_path
        
        if v2_file.exists():
            print(f"Comparing: {v1_file.name}")
            comp = compare_notebooks(v1_file, v2_file)
            comparisons.append(comp)
            print(f"  Similarity: {comp.get('similarity_pct', 0):.1f}%")
    
    # Save comparison results
    with open('./evidence_comparison/v1_v2_comparison.json', 'w') as f:
        json.dump({
            'comparison_date': '2025-11-05',
            'total_comparisons': len(comparisons),
            'comparisons': comparisons
        }, f, indent=2)
    
    print(f"\n✅ Comparison complete: {len(comparisons)} files analyzed")
else:
    print("❌ V1 or V2 directories not found")
EOFCOMP
```

---

## Screenshots & Pictures Evidence

You have `/home/simon/Pictures/` directory which may contain additional evidence.

### Document Pictures Directory

```bash
# Create inventory of Pictures directory
mkdir -p evidence_screenshots

# Note: Pictures directory is outside workspace, documenting approach:
# Manual steps needed:
# 1. Review /home/simon/Pictures/ for relevant screenshots
# 2. Copy relevant files to evidence_screenshots/
# 3. Organize by date and subject matter

# If you have relevant screenshots, copy them:
# cp /home/simon/Pictures/icon_plc_*.png evidence_screenshots/
# cp /home/simon/Pictures/digital_unicorn_*.png evidence_screenshots/

# Generate inventory of screenshots
ls -lh evidence_screenshots/ > evidence_screenshots/inventory.txt

# Generate hashes
find evidence_screenshots/ -type f -exec sha256sum {} \; > evidence_screenshots/hashes.txt
```

---

## Web Archive Evidence

### Archive All Relevant URLs

```bash
# List of URLs to archive
cat > urls_to_archive.txt << 'EOFURLS'
https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=byAO2g
https://onedrive.live.com/?id=%2Fpersonal%2F6e5ed652c46b3548%2FDocuments%2F01%2EPersonnal%2Ficonplc
# Add any other relevant URLs below:
# https://icon-plc.com/courses/...
# https://digital-unicorn.com/...
EOFURLS

# Archive all URLs
while IFS= read -r url; do
  echo "Archiving: $url"
  python3 web_evidence_archiver.py \
    --case-name "Digital Unicorn ICON PLC Evidence" \
    --output-dir "./evidence_web_archives" \
    "$url"
done < urls_to_archive.txt
```

---

## Cryptographic Verification

### Generate Master Evidence Manifest

```bash
# Create master manifest combining all evidence sources
python3 << 'EOFMASTER'
import json
import hashlib
from datetime import datetime
from pathlib import Path

def create_master_manifest():
    """Create master evidence manifest"""
    manifest = {
        'case': 'Digital Unicorn vs ICON PLC',
        'case_type': 'Course Plagiarism / Intellectual Property',
        'manifest_created': datetime.utcnow().isoformat() + 'Z',
        'evidence_sources': [],
        'total_evidence_files': 0,
        'verification': {}
    }
    
    # List all evidence directories
    evidence_dirs = [
        './digital_unicorn_outsource',
        './evidence_onedrive',
        './evidence_screenshots',
        './evidence_web_archives',
        './evidence_comparison'
    ]
    
    for evidence_dir in evidence_dirs:
        dir_path = Path(evidence_dir)
        if dir_path.exists():
            files = list(dir_path.rglob('*'))
            file_count = len([f for f in files if f.is_file()])
            
            source_info = {
                'directory': evidence_dir,
                'exists': True,
                'file_count': file_count,
                'subdirectories': len([f for f in files if f.is_dir()])
            }
            manifest['evidence_sources'].append(source_info)
            manifest['total_evidence_files'] += file_count
    
    # Add verification checksums
    manifest['verification']['manifest_hash'] = hashlib.sha256(
        json.dumps(manifest['evidence_sources'], sort_keys=True).encode()
    ).hexdigest()
    
    return manifest

# Create and save master manifest
master = create_master_manifest()
with open('./MASTER_EVIDENCE_MANIFEST.json', 'w') as f:
    json.dump(master, f, indent=2)

print("✅ Master Evidence Manifest created")
print(f"📁 Total evidence files: {master['total_evidence_files']}")
print(f"📂 Evidence sources: {len(master['evidence_sources'])}")
for source in master['evidence_sources']:
    print(f"   - {source['directory']}: {source['file_count']} files")
EOFMASTER
```

---

## Chain of Custody

### Create Chain of Custody Document

```bash
cat > CHAIN_OF_CUSTODY.md << 'EOFCOC'
# CHAIN OF CUSTODY LOG
## Digital Unicorn vs ICON PLC Case

### Case Information
- **Case Name**: Digital Unicorn vs ICON PLC
- **Case Type**: Course Material Plagiarism / Intellectual Property Dispute
- **Case Date**: 2025
- **Custodian**: Simon [Your Full Name]
- **Location**: /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc

---

### Evidence Collection Timeline

#### Phase 1: OneDrive Evidence Collection
- **Date**: November 5, 2025
- **Method**: Rclone automated download + manual verification
- **Source**: OneDrive Personal Account
- **URLs**:
  - https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=byAO2g
  - https://onedrive.live.com/?id=%2Fpersonal%2F6e5ed652c46b3548%2FDocuments%2F01%2EPersonnal%2Ficonplc
- **Files Collected**: [TO BE FILLED AFTER DOWNLOAD]
- **Verification**: SHA-256 and MD5 hashes generated
- **Storage**: ./evidence_onedrive/

#### Phase 2: Local Evidence Documentation
- **Date**: November 5, 2025
- **Method**: In-place hashing and manifest generation
- **Source**: Local filesystem - digital_unicorn_outsource/
- **Files Documented**: 200+ files including:
  - V1/ - Original course materials
  - V2/ - Allegedly plagiarized materials
  - Images, notebooks, documentation
- **Verification**: SHA-256 and MD5 hashes generated
- **Storage**: ./digital_unicorn_outsource/ (existing)

#### Phase 3: Web Archive Evidence
- **Date**: November 5, 2025
- **Method**: Wayback Machine, archive.today, local HTML capture
- **Source**: Public URLs related to case
- **Verification**: Wayback Machine timestamps, archive.today URLs
- **Storage**: ./evidence_web_archives/

#### Phase 4: Screenshot Evidence
- **Date**: November 5, 2025
- **Method**: System screenshots with timestamps
- **Source**: /home/simon/Pictures/ and new captures
- **Verification**: SHA-256 hashes, EXIF data preserved
- **Storage**: ./evidence_screenshots/

---

### Evidence Integrity Verification

All evidence files have been processed with:
- **SHA-256 hashes**: Cryptographically secure verification
- **MD5 hashes**: Additional verification layer
- **Timestamps**: UTC timestamps for all operations
- **File metadata**: Preserved original creation/modification times
- **Manifests**: JSON manifests with complete file information

---

### Access Log

| Date | Time (UTC) | Person | Action | Purpose |
|------|------------|--------|--------|---------|
| 2025-11-05 | [TIME] | Simon | Evidence collection initiated | Legal case preparation |
| 2025-11-05 | [TIME] | Simon | OneDrive access via rclone | Download ICON PLC documents |
| 2025-11-05 | [TIME] | Simon | Local evidence documented | Hash generation and manifest |
| 2025-11-05 | [TIME] | Simon | Web archives created | Third-party verification |
| | | | | |
| | | | | |

---

### Verification Signatures

**Evidence Custodian**:
- Name: ____________________________
- Signature: ________________________
- Date: _____________________________

**Legal Representative** (if applicable):
- Name: ____________________________
- Signature: ________________________
- Date: _____________________________

**Technical Expert** (if applicable):
- Name: ____________________________
- Signature: ________________________
- Date: _____________________________

---

### Evidence Storage & Backup

**Primary Storage**: 
- Location: /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc
- Media: Local SSD/HDD
- Access: Restricted to custodian

**Backup Storage**:
- Location 1: [SPECIFY EXTERNAL DRIVE OR CLOUD BACKUP]
- Location 2: [SPECIFY SECONDARY BACKUP]
- Backup Date: [TO BE FILLED]

**Archive Package**:
- File: evidence_complete_package_YYYYMMDD.tar.gz
- SHA-256: [TO BE FILLED AFTER PACKAGING]
- Size: [TO BE FILLED]

---

### Legal Notes

This evidence has been collected in accordance with:
- UK Computer Misuse Act 1990
- UK Copyright, Designs and Patents Act 1988
- GDPR (Data Protection Act 2018)
- Civil Procedure Rules - Evidence disclosure requirements

All evidence is the property of the evidence custodian and/or their legal representatives. Unauthorized access, modification, or distribution is prohibited.

---

### Contact Information

**Evidence Custodian**:
- Name: Simon [Full Name]
- Email: [Your Email]
- Phone: [Your Phone]

**Legal Representative**:
- Name: [Solicitor Name]
- Firm: [Law Firm]
- Email: [Solicitor Email]
- Phone: [Solicitor Phone]

---

Document Created: November 5, 2025
Last Updated: [TO BE UPDATED]
EOFCOC

echo "✅ Chain of Custody document created"
```

---

## Evidence Packaging

### Create Final Evidence Package

```bash
# Create final evidence package with all materials
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc

# Create package directory
mkdir -p evidence_final_package

# Copy all evidence with structure preservation
echo "📦 Packaging evidence..."

# Copy organized evidence
cp -r digital_unicorn_outsource evidence_final_package/
cp -r evidence_onedrive evidence_final_package/ 2>/dev/null || echo "Note: evidence_onedrive not yet created"
cp -r evidence_screenshots evidence_final_package/ 2>/dev/null || echo "Note: evidence_screenshots not yet created"
cp -r evidence_web_archives evidence_final_package/ 2>/dev/null || echo "Note: evidence_web_archives not yet created"
cp -r evidence_comparison evidence_final_package/ 2>/dev/null || echo "Note: evidence_comparison not yet created"

# Copy all manifests and logs
cp *.json evidence_final_package/ 2>/dev/null || true
cp *.txt evidence_final_package/ 2>/dev/null || true
cp *.md evidence_final_package/ 2>/dev/null || true

# Create package README
cat > evidence_final_package/README.txt << 'EOFREADME'
DIGITAL UNICORN VS ICON PLC - EVIDENCE PACKAGE
==============================================

Case: Course Material Plagiarism / Intellectual Property Dispute
Package Created: November 5, 2025
Custodian: Simon [Full Name]

CONTENTS:
---------

1. digital_unicorn_outsource/
   - V1/ - Original course materials
   - V2/ - Allegedly plagiarized materials  
   - Supporting documentation and images
   
2. evidence_onedrive/
   - Files downloaded from OneDrive ICON PLC folder
   - Metadata and verification logs
   
3. evidence_screenshots/
   - Screenshots showing evidence
   - Timestamps preserved
   
4. evidence_web_archives/
   - Web archive captures (Wayback Machine, archive.today)
   - Local HTML captures
   
5. evidence_comparison/
   - V1 vs V2 comparison analysis
   - Similarity metrics
   
6. Manifests and Verification:
   - MASTER_EVIDENCE_MANIFEST.json
   - evidence_hashes_*.txt
   - CHAIN_OF_CUSTODY.md

VERIFICATION:
-------------

All files include cryptographic hashes (SHA-256, MD5) for integrity verification.
See individual manifest files for complete file listings and hashes.

LEGAL NOTICE:
-------------

This evidence package is confidential and intended solely for use in legal 
proceedings related to the Digital Unicorn vs ICON PLC case. Unauthorized 
access, distribution, or use is prohibited.

CONTACT:
--------

Evidence Custodian: Simon [Full Name]
Email: [Your Email]
Legal Representative: [Solicitor Name, Firm]

For questions or verification requests, contact the evidence custodian.
EOFREADME

# Generate final package hash manifest
find evidence_final_package -type f -exec sha256sum {} \; > evidence_final_package_SHA256SUMS.txt

# Create compressed archive
PACKAGE_NAME="evidence_digital_unicorn_iconplc_$(date +%Y%m%d_%H%M%S).tar.gz"
echo "📦 Creating archive: $PACKAGE_NAME"
tar -czf "$PACKAGE_NAME" evidence_final_package/

# Generate archive hash
sha256sum "$PACKAGE_NAME" > "${PACKAGE_NAME}.sha256"
md5sum "$PACKAGE_NAME" > "${PACKAGE_NAME}.md5"

# Display results
echo ""
echo "✅ EVIDENCE PACKAGE COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Package: $PACKAGE_NAME"
echo "📊 Size: $(du -h "$PACKAGE_NAME" | cut -f1)"
echo "🔒 SHA-256: $(cat "${PACKAGE_NAME}.sha256" | cut -d' ' -f1)"
echo "🔒 MD5: $(cat "${PACKAGE_NAME}.md5" | cut -d' ' -f1)"
echo ""
echo "📁 Package location:"
echo "   $(pwd)/$PACKAGE_NAME"
echo ""
echo "⚠️  IMPORTANT: Store this package securely and create backups!"
```

---

## Quick Start Commands

### 1. Setup Rclone and Download OneDrive Evidence

```bash
# Install and configure rclone
curl https://rclone.org/install.sh | sudo bash
rclone config  # Follow interactive setup for OneDrive

# Download evidence
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc
rclone copy --progress --metadata \
  "iconplc_onedrive:Documents/01.Personnal/iconplc" \
  "./evidence_onedrive/iconplc_documents"
```

### 2. Document All Local Evidence

```bash
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc

# Run evidence documentation
find digital_unicorn_outsource -type f -exec sha256sum {} \; > evidence_hashes_sha256.txt
python3 -c "$(cat COMPREHENSIVE_EVIDENCE_COLLECTION.md | sed -n '/def analyze_directory/,/^EOFPYTHON$/p' | head -n -1)"
```

### 3. Create Web Archives

```bash
python3 web_evidence_archiver.py \
  --case-name "Digital Unicorn ICON PLC" \
  --output-dir "./evidence_web_archives" \
  "https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=byAO2g"
```

### 4. Run Complete Evidence Collection

```bash
# Use the automated script
./quick_evidence_collector.sh
```

---

## Troubleshooting

### Rclone Authentication Issues

If browser authentication fails:

```bash
# Try manual authentication
rclone config reconnect iconplc_onedrive:

# Or delete and recreate the remote
rclone config delete iconplc_onedrive
rclone config  # Start fresh
```

### OneDrive Access Denied

If you can't access OneDrive folders:
1. Verify you're logged into correct Microsoft account
2. Check folder sharing permissions
3. Use browser download as fallback
4. Screenshot everything for evidence

### File Permission Issues

```bash
# Fix permissions if needed
chmod -R u+rw digital_unicorn_outsource/
chmod +x *.sh
```

---

## Legal Best Practices

### ✅ DO:
- ✅ Document every step with timestamps
- ✅ Generate cryptographic hashes immediately
- ✅ Create multiple backups in different locations
- ✅ Maintain chain of custody documentation
- ✅ Use UTC timestamps for international cases
- ✅ Preserve original file metadata
- ✅ Get legal advice before sharing evidence
- ✅ Screenshot everything with visible timestamps

### ❌ DON'T:
- ❌ Modify original files
- ❌ Delete any evidence (even duplicates)
- ❌ Share evidence without legal authorization
- ❌ Access unauthorized systems or accounts
- ❌ Rely on single copy/storage location
- ❌ Use lossy compression on evidence
- ❌ Forget to document access/modifications

---

## Next Steps

1. ✅ **Complete OneDrive download** using rclone
2. ✅ **Generate all hashes and manifests**
3. ✅ **Create comparison analysis** (V1 vs V2)
4. ✅ **Take comprehensive screenshots**
5. ✅ **Package all evidence** into archive
6. ✅ **Create backup copies** (minimum 2 locations)
7. ✅ **Provide to legal representative**
8. ✅ **Prepare expert witness statement** if needed

---

## Support & Resources

- **Rclone Documentation**: https://rclone.org/docs/
- **Web Archiver Tool**: `./README_WEB_ARCHIVER.md`
- **Evidence Collection Guide**: `./evidence_collection_guide.md`
- **Tools Summary**: `./TOOLS_SUMMARY.md`

---

**Document Version**: 1.0  
**Last Updated**: November 5, 2025  
**Created By**: GitHub Copilot for Simon  

---

⚠️ **CONFIDENTIAL** - This document contains information related to legal proceedings. Handle with appropriate confidentiality and security measures.
