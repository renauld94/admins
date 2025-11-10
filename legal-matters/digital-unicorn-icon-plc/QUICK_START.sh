#!/bin/bash
# Forensic Evidence Agent Quick-Start Guide

# =============================================================================
# LOCATION OF ALL GENERATED EVIDENCE
# =============================================================================
EVIDENCE_DIR="/home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/DEEP_EVIDENCE_CAPTURE_20251107"
AGENT_SCRIPT="/home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/forensic_evidence_agent.py"

echo "📁 Evidence Directory:"
echo "   $EVIDENCE_DIR"
echo ""

# =============================================================================
# QUICK ACCESS TO KEY EXHIBITS
# =============================================================================

echo "📋 KEY EXHIBITS (COURT-READY):"
echo ""
echo "1️⃣  Oct 29 Account Deactivation Bounce:"
echo "   File: $EVIDENCE_DIR/EXHIBIT_LUCAS_OCT29_BOUNCE.md"
echo "   Hash Manifest: $EVIDENCE_DIR/EXHIBIT_LUCAS_OCT29_BOUNCE_HASHES.csv"
echo "   → Top 3 candidate bounce messages with SHA-256"
echo ""

echo "2️⃣  Scope Abuse Evidence Report:"
echo "   File: $EVIDENCE_DIR/EXHIBIT_ICON_SCOPE_ABUSE_REPORT.md"
echo "   → Analysis of DALLE images and scope violation screenshots"
echo ""

echo "3️⃣  ChatGPT Transcript Catalog:"
echo "   File: $EVIDENCE_DIR/EXHIBIT_CHATGPT_TRANSCRIPTS_SUMMARY.md"
echo "   → Identified transcript sources and metadata"
echo ""

echo "4️⃣  Screenshot & AI Content Classification:"
echo "   File: $EVIDENCE_DIR/screenshot_classification_complete.csv"
echo "   Summary: $EVIDENCE_DIR/SCREENSHOT_CLASSIFICATION_SUMMARY.md"
echo "   → 9 DALL-E images classified and hashed"
echo ""

# =============================================================================
# LEGAL TEMPLATES (ATTORNEY REVIEW REQUIRED)
# =============================================================================

echo "📝 LEGAL TEMPLATES (For Attorney Customization):"
echo ""
echo "→ Demand Letter:  $EVIDENCE_DIR/DEMAND_LETTER_TEMPLATE.md"
echo "→ CNIL Complaint: $EVIDENCE_DIR/CNIL_COMPLAINT_TEMPLATE.md"
echo "→ Vietnam Packet: $EVIDENCE_DIR/VIETNAM_LAWYER_PACKET.md"
echo ""

# =============================================================================
# HOW TO USE THE AGENT
# =============================================================================

echo "🚀 HOW TO RUN THE AGENT:"
echo ""
echo "  Option 1 - Run all phases:"
echo "    python3 $AGENT_SCRIPT --phase all --verbose"
echo ""
echo "  Option 2 - Run single phase:"
echo "    python3 $AGENT_SCRIPT --phase 1  # Bounce extraction only"
echo "    python3 $AGENT_SCRIPT --phase 3  # Screenshot classification only"
echo ""
echo "  Option 3 - Silent mode:"
echo "    python3 $AGENT_SCRIPT --phase all"
echo ""

# =============================================================================
# VERIFY EVIDENCE INTEGRITY
# =============================================================================

echo "🔐 VERIFY EVIDENCE (Chain-of-Custody Check):"
echo ""
echo "  Navigate to: $EVIDENCE_DIR/mbox_matches"
echo "  Run: sha256sum -c EXHIBIT_LUCAS_OCT29_BOUNCE_HASHES.csv"
echo "  All files should show ✓ OK"
echo ""

# =============================================================================
# FILE STRUCTURE
# =============================================================================

echo "📂 FILE STRUCTURE:"
echo ""
echo "DEEP_EVIDENCE_CAPTURE_20251107/"
echo "├── AGENT_EXECUTION_SUMMARY.md           ← Read this first!"
echo "├── AGENT_RUN_INDEX.md                   ← Index of all outputs"
echo "│"
echo "├── 📑 FORMAL EXHIBITS:"
echo "│   ├── EXHIBIT_LUCAS_OCT29_BOUNCE.md"
echo "│   ├── EXHIBIT_LUCAS_OCT29_BOUNCE_HASHES.csv"
echo "│   ├── EXHIBIT_ICON_SCOPE_ABUSE_REPORT.md"
echo "│   └── EXHIBIT_CHATGPT_TRANSCRIPTS_SUMMARY.md"
echo "│"
echo "├── 📋 CLASSIFICATION:"
echo "│   ├── screenshot_classification_complete.csv"
echo "│   └── SCREENSHOT_CLASSIFICATION_SUMMARY.md"
echo "│"
echo "├── ⚖️  LEGAL TEMPLATES:"
echo "│   ├── DEMAND_LETTER_TEMPLATE.md"
echo "│   ├── CNIL_COMPLAINT_TEMPLATE.md"
echo "│   └── VIETNAM_LAWYER_PACKET.md"
echo "│"
echo "├── 📧 EMAIL EVIDENCE:"
echo "│   └── mbox_matches/"
echo "│       ├── bounce_000000.eml through bounce_007790.eml"
echo "│       ├── mbox_manifest.csv           (7,791 bounce messages)"
echo "│       ├── candidates_bounce_top20.csv (ranked candidates)"
echo "│       └── CANDIDATE_BOUNCE_EXHIBITS.md"
echo "│"
echo "├── 🖼️  VISUAL EVIDENCE:"
echo "│   ├── dalle_samples/                   (9 DALL-E images)"
echo "│   └── screenshot_samples/"
echo "│"
echo "└── 📦 RAW DATA:"
echo "    ├── AllMail.mbox                     (Full Gmail mailbox)"
echo "    ├── shared_conversations.json        (Chat metadata)"
echo "    └── message_feedback.json"
echo ""

# =============================================================================
# NEXT STEPS
# =============================================================================

echo "⏭️  NEXT STEPS:"
echo ""
echo "1. Read: AGENT_EXECUTION_SUMMARY.md"
echo "2. Review: Top 3 bounce candidates in EXHIBIT_LUCAS_OCT29_BOUNCE.md"
echo "3. Share with attorney:"
echo "   - DEMAND_LETTER_TEMPLATE.md"
echo "   - CNIL_COMPLAINT_TEMPLATE.md"
echo "   - VIETNAM_LAWYER_PACKET.md"
echo "4. File formal complaints (30-day escalation cycle)"
echo ""

# =============================================================================
# TROUBLESHOOTING
# =============================================================================

echo "❓ TROUBLESHOOTING:"
echo ""
echo "Q: Where are the individual bounce .eml files?"
echo "A: $EVIDENCE_DIR/mbox_matches/bounce_*.eml (7,791 total)"
echo ""
echo "Q: How do I view a specific bounce message?"
echo "A: cat $EVIDENCE_DIR/mbox_matches/bounce_000000.eml | less"
echo ""
echo "Q: How do I verify file integrity?"
echo "A: sha256sum -c $EVIDENCE_DIR/EXHIBIT_LUCAS_OCT29_BOUNCE_HASHES.csv"
echo ""
echo "Q: Can I re-run the agent?"
echo "A: Yes! python3 $AGENT_SCRIPT --phase all"
echo ""
echo "Q: What if I need to re-rank bounce candidates?"
echo "A: Edit mbox_matches/candidates_bounce_top20.csv and re-run Phase 1"
echo ""

echo "✅ Agent ready. Start with: cat $EVIDENCE_DIR/AGENT_EXECUTION_SUMMARY.md"
