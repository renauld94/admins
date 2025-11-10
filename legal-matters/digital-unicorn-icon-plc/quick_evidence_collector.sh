#!/bin/bash
# Quick Evidence Collection Script for OneDrive Content
# Digital Unicorn vs ICON PLC Case

set -e

CASE_NAME="Digital Unicorn ICON PLC OneDrive Evidence"
EVIDENCE_DIR="./evidence_onedrive_$(date +%Y%m%d_%H%M%S)"
ONEDRIVE_URL="https://1drv.ms/f/c/6e5ed652c46b3548/EqV3fWEK_FFIjaLC1rbpab4BXfDDXobwU3379Lor8HcYEg?e=iK7ARH"

echo "=============================================="
echo "Evidence Collection Script"
echo "=============================================="
echo ""
echo "Case: $CASE_NAME"
echo "Evidence Directory: $EVIDENCE_DIR"
echo ""

# Create directory structure
mkdir -p "$EVIDENCE_DIR/downloaded_files"
mkdir -p "$EVIDENCE_DIR/screenshots"
mkdir -p "$EVIDENCE_DIR/web_archives"

echo "[1/6] Created directory structure"

# Archive the URL using web archiver
echo "[2/6] Archiving OneDrive link..."
python3 web_evidence_archiver.py \
  --case-name "$CASE_NAME" \
  --output-dir "$EVIDENCE_DIR/web_archives" \
  "$ONEDRIVE_URL" 2>&1 | tee "$EVIDENCE_DIR/archival_log.txt"

echo ""
echo "[3/6] Web archival complete"
echo ""
echo "=============================================="
echo "MANUAL STEPS REQUIRED"
echo "=============================================="
echo ""
echo "Please complete the following manually:"
echo ""
echo "1. Open this URL in your browser:"
echo "   $ONEDRIVE_URL"
echo ""
echo "2. Download all files from OneDrive to:"
echo "   $EVIDENCE_DIR/downloaded_files/"
echo ""
echo "3. Take screenshots and save to:"
echo "   $EVIDENCE_DIR/screenshots/"
echo "   - Include browser address bar"
echo "   - Include system date/time"
echo "   - Capture folder structure"
echo "   - Capture file metadata"
echo ""
echo "Press ENTER when downloads are complete..."
read

# Check if files were downloaded
if [ -z "$(ls -A $EVIDENCE_DIR/downloaded_files)" ]; then
    echo "⚠️  Warning: No files found in downloaded_files directory"
    echo "Please download files first, then run this script again"
    exit 1
fi

echo "[4/6] Generating file hashes..."

# Generate hashes for all downloaded files
cd "$EVIDENCE_DIR/downloaded_files"
find . -type f -exec sha256sum {} \; > ../file_hashes_sha256.txt
find . -type f -exec md5sum {} \; > ../file_hashes_md5.txt
cd ../..

echo "[5/6] Creating file manifest..."

# Create detailed file listing
find "$EVIDENCE_DIR/downloaded_files" -type f -ls > "$EVIDENCE_DIR/file_metadata.txt"

# Create human-readable inventory
cat > "$EVIDENCE_DIR/file_inventory.txt" << EOF
FILE INVENTORY
==============

Case: $CASE_NAME
Collection Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Source: $ONEDRIVE_URL
Evidence Directory: $EVIDENCE_DIR

Files Collected:
EOF

ls -lhR "$EVIDENCE_DIR/downloaded_files" >> "$EVIDENCE_DIR/file_inventory.txt"

# Create chain of custody document
cat > "$EVIDENCE_DIR/chain_of_custody.txt" << EOF
CHAIN OF CUSTODY LOG
====================

Case: Digital Unicorn vs ICON PLC - Course Material Plagiarism
Evidence Type: OneDrive Folder Contents
Source URL: $ONEDRIVE_URL

Collection Information:
-----------------------
Date/Time (UTC): $(date -u +"%Y-%m-%d %H:%M:%S")
Collected By: [FILL IN YOUR NAME]
Collection Method: Direct download from OneDrive shared link
Access Method: Authenticated browser session / Shared link

Collection Steps Performed:
----------------------------
1. Accessed OneDrive URL via web browser
2. Verified folder contents and file structure
3. Downloaded all files to local storage
4. Generated cryptographic hashes (SHA-256, MD5)
5. Captured screenshots of folder interface
6. Created detailed file manifest and inventory
7. Archived URL via multiple web archive services

Verification Checksums:
-----------------------
See file_hashes_sha256.txt for individual file hashes
See file_hashes_md5.txt for MD5 checksums

Web Archive URLs:
-----------------
See web_archives/ directory for archive links

Storage Information:
--------------------
Local Directory: $EVIDENCE_DIR
Hash Files: file_hashes_sha256.txt, file_hashes_md5.txt
Manifest: file_metadata.txt
Inventory: file_inventory.txt

Evidence Integrity:
-------------------
[ ] Hashes verified
[ ] Timestamps preserved
[ ] Screenshots captured
[ ] Metadata documented
[ ] Archive package created

Custodian: _______________________
Signature: _______________________
Date: _______________________

Notes:
------
[Add any relevant notes about the collection process]

EOF

echo "[6/6] Creating evidence package..."

# Create tarball of everything
cd "$(dirname $EVIDENCE_DIR)"
BASENAME=$(basename $EVIDENCE_DIR)
tar -czf "${BASENAME}.tar.gz" "$BASENAME/"

# Generate checksum for the package
sha256sum "${BASENAME}.tar.gz" > "${BASENAME}_checksum.txt"

cd - > /dev/null

echo ""
echo "=============================================="
echo "✅ EVIDENCE COLLECTION COMPLETE"
echo "=============================================="
echo ""
echo "Evidence Package: ${BASENAME}.tar.gz"
echo "Package Checksum: ${BASENAME}_checksum.txt"
echo ""
echo "Evidence Contents:"
echo "  - Downloaded files: $EVIDENCE_DIR/downloaded_files/"
echo "  - File hashes: $EVIDENCE_DIR/file_hashes_*.txt"
echo "  - File manifest: $EVIDENCE_DIR/file_metadata.txt"
echo "  - File inventory: $EVIDENCE_DIR/file_inventory.txt"
echo "  - Web archives: $EVIDENCE_DIR/web_archives/"
echo "  - Screenshots: $EVIDENCE_DIR/screenshots/ (if added)"
echo "  - Chain of custody: $EVIDENCE_DIR/chain_of_custody.txt"
echo ""
echo "Next Steps:"
echo "  1. Review chain_of_custody.txt and fill in details"
echo "  2. Add screenshots to screenshots/ directory"
echo "  3. Verify file_inventory.txt is complete"
echo "  4. Create backup of evidence package"
echo "  5. Provide to legal counsel"
echo ""
echo "Package SHA-256:"
cat "$(dirname $EVIDENCE_DIR)/${BASENAME}_checksum.txt"
echo ""
