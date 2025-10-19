#!/bin/bash
#
# Convert Resume Markdown to PDF and DOCX
#
# Usage: ./convert_resume.sh [resume_markdown_file]
#
# Requirements: pandoc (sudo apt-get install pandoc texlive-latex-base)
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: pandoc is not installed${NC}"
    echo "Install with: sudo apt-get install pandoc texlive-latex-base"
    exit 1
fi

# Get input file
if [ -z "$1" ]; then
    echo "Usage: $0 <markdown_file>"
    echo "Example: $0 resumes/manpower_19096/Simon_Renauld_Resume_Director_AI_Analytics.md"
    exit 1
fi

INPUT_FILE="$1"
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: File not found: $INPUT_FILE${NC}"
    exit 1
fi

# Get directory and filename
DIR=$(dirname "$INPUT_FILE")
FILENAME=$(basename "$INPUT_FILE" .md)

# Output files
PDF_OUTPUT="${DIR}/${FILENAME}.pdf"
DOCX_OUTPUT="${DIR}/${FILENAME}.docx"

echo -e "${BLUE}Converting: $INPUT_FILE${NC}"
echo ""

# Convert to PDF
echo -e "${BLUE}📄 Generating PDF...${NC}"
pandoc "$INPUT_FILE" \
    -o "$PDF_OUTPUT" \
    --pdf-engine=pdflatex \
    -V geometry:margin=0.75in \
    -V fontsize=11pt \
    -V mainfont="Arial" \
    --variable colorlinks=true \
    --variable linkcolor=blue \
    --variable urlcolor=blue

if [ -f "$PDF_OUTPUT" ]; then
    echo -e "${GREEN}✓ PDF created: $PDF_OUTPUT${NC}"
    echo "  Size: $(du -h "$PDF_OUTPUT" | cut -f1)"
else
    echo -e "${RED}✗ Failed to create PDF${NC}"
fi

echo ""

# Convert to DOCX
echo -e "${BLUE}📝 Generating DOCX...${NC}"
pandoc "$INPUT_FILE" \
    -o "$DOCX_OUTPUT" \
    --reference-doc=/dev/null \
    -V fontsize=11pt

if [ -f "$DOCX_OUTPUT" ]; then
    echo -e "${GREEN}✓ DOCX created: $DOCX_OUTPUT${NC}"
    echo "  Size: $(du -h "$DOCX_OUTPUT" | cut -f1)"
else
    echo -e "${RED}✗ Failed to create DOCX${NC}"
fi

echo ""
echo -e "${GREEN}✓ Conversion complete!${NC}"
echo ""
echo "Files generated:"
echo "  - $PDF_OUTPUT (for viewing/submission)"
echo "  - $DOCX_OUTPUT (for ATS parsing)"
echo ""
echo "Next steps:"
echo "  1. Open and review both files"
echo "  2. Test DOCX with ATS checker (resume.io, jobscan)"
echo "  3. Ensure PDF formatting looks good"
echo "  4. Attach to job application"
