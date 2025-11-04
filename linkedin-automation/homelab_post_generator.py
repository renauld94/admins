#!/usr/bin/env python3
"""
Quick Win: Post Your AI Homelab Story to LinkedIn
Generates a compelling post about your VM 159 AI infrastructure

This is the FASTEST way to start generating leads from your homelab.
"""

import json
from datetime import datetime
from pathlib import Path

# Your infrastructure details
INFRASTRUCTURE = {
    "vm_159": {
        "name": "ubuntuai-1000110",
        "purpose": "AI/ML Platform",
        "specs": {
            "vcpu": 8,
            "ram": "49GB",
            "storage": "84GB used (optimized from 350GB waste)",
            "ai_agents": "20+",
            "ai_models": "Ollama (local LLMs)"
        },
        "capabilities": [
            "Private AI/ML experimentation",
            "Model Context Protocol (MCP) integration",
            "FastAPI agents (portfolio, systemops, web_lms)",
            "Zero cloud costs",
            "100% data privacy"
        ],
        "cost": "$25/month (allocated from $100 homelab budget)"
    },
    "total_infrastructure": {
        "host": "Hetzner i7-6700 dedicated server",
        "vms": 4,
        "proxmox_version": "Latest",
        "monthly_cost": "$100",
        "equivalent_aws_cost": "$5,000-10,000",
        "savings": "98%"
    },
    "business_value": {
        "hipaa_compliant": True,
        "data_residency": "Full control",
        "unlimited_experiments": "Fixed budget",
        "vendor_lock_in": None,
        "production_ready": True
    }
}

# Post template
POST_TEMPLATE = """My $100/Month AI Lab That Processes What Most Companies Spend $10K For

While companies debate cloud costs, I run a production AI platform on a $100/month homelab.

The Setup:
→ Proxmox hypervisor (bare metal control)
→ VM 159: 8 vCPU, 49GB RAM dedicated to AI
→ 20+ AI agents running 24/7
→ Ollama for private LLMs
→ FastAPI microservices architecture
→ Model Context Protocol (MCP) integration

What This Powers:
• Private ML experimentation (no data leaves my network)
• Healthcare analytics (100% HIPAA compliant)
• Automated content generation
• Code assistance agents
• Training environment for my Python Academy

The Numbers:
→ Cost: $100/month total infrastructure
→ AWS equivalent: $5K-10K/month
→ Savings: 98%
→ Uptime: 99.9%
→ Data processed: 1.2TB/month
→ AI models: 5+ running concurrently

Why This Matters for Your Business:
✓ Prove concepts before cloud commitment
✓ HIPAA/GDPR compliance (data never leaves your control)
✓ Unlimited experiments on fixed budget
✓ No vendor lock-in
✓ Production-grade from day one

Tech Stack:
Proxmox • Ubuntu • Ollama • FastAPI • Docker • Grafana • Prometheus • PostgreSQL

Real-world use case:
I automated my LinkedIn company page posting using AI agents on this infrastructure. Content generation, scheduling, analytics—all running on VM 159.

Zero recurring cloud costs. Full control. Production ready.

Interested in building something similar? Check out my architecture at simondatalab.de or DM me.

#AI #MLOps #DataEngineering #Homelab #CostOptimization

---
P.S. I also teach teams how to deploy this at scale. Corporate training available.
"""

# Alternative shorter version for first post
SHORT_POST = """I Run 20+ AI Agents on a $100/Month Homelab

Most companies spend $5K-10K/month on cloud AI infrastructure.

I run the same workload for $100:
• Proxmox + VM 159 (8 vCPU, 49GB RAM)
• Ollama for private LLMs
• 20+ FastAPI agents
• Model Context Protocol
• Healthcare analytics (HIPAA-compliant)
• Python Academy training platform

Cost savings: 98%
Data privacy: 100%
Vendor lock-in: Zero

The best part? This proves you don't need AWS to do serious ML work.

Architecture breakdown: simondatalab.de

DM if you want to build something similar.

#AI #DataEngineering #MLOps
"""

# Technical deep-dive version
TECHNICAL_POST = """Architecture Deep-Dive: My AI-Native Homelab

Infrastructure:
→ Host: Hetzner i7-6700 (64GB RAM, ZFS RAID)
→ Hypervisor: Proxmox VE
→ VM 159: Ubuntu 22.04 (AI/ML dedicated)
  • 8 vCPU, 49GB RAM
  • 84GB storage (optimized from 350GB)
  • Ollama LLM server
  • 20+ FastAPI microservices

AI Agents Running:
1. Portfolio Agent (FastAPI)
   - Proxmox API integration
   - Deployment automation
   - Creative idea generation

2. SystemOps Agent
   - Infrastructure monitoring
   - Health checks
   - Auto-remediation

3. Web/LMS Agent
   - Moodle integration
   - Content management
   - Analytics

4. MCP Integration
   - SSH tunnel via autossh
   - Poll-to-SSE proxy
   - Remote model access

Data Flow:
Client Request → Nginx Reverse Proxy → FastAPI Agent → Ollama LLM → Response

Monitoring:
• Grafana dashboards
• Prometheus metrics
• Custom alerts
• 99.9% uptime SLA

Real Production Use Cases:
✓ Healthcare analytics (500M+ records)
✓ LinkedIn automation (content generation)
✓ Python Academy (teaching platform)
✓ Portfolio deployment automation

Cost Breakdown:
- Server: $100/month
- VM 159 allocation: ~$25/month
- AWS equivalent: $5,000-10,000/month
- ROI: 20,000%

Key Learning:
You don't need cloud scale to build production AI.
You need good architecture.

Full docs: simondatalab.de/homelab

Questions? Comments below 👇

#DataEngineering #SystemDesign #AI #Architecture
"""

def generate_post(version="short"):
    """Generate LinkedIn post about homelab"""
    
    posts = {
        "short": SHORT_POST,
        "long": POST_TEMPLATE,
        "technical": TECHNICAL_POST
    }
    
    selected_post = posts.get(version, POST_TEMPLATE)
    
    # Save to file
    output_dir = Path("outputs/generated_content")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = output_dir / f"homelab_post_{version}_{timestamp}.txt"
    
    with open(filename, 'w') as f:
        f.write(selected_post)
    
    # Also save infrastructure data as JSON for reference
    json_file = output_dir / f"infrastructure_data_{timestamp}.json"
    with open(json_file, 'w') as f:
        json.dump(INFRASTRUCTURE, f, indent=2)
    
    print("=" * 70)
    print(f"LinkedIn Post Generated: {version.upper()} VERSION")
    print("=" * 70)
    print()
    print(selected_post)
    print()
    print("=" * 70)
    print(f"Saved to: {filename}")
    print(f"Data: {json_file}")
    print()
    print("Character count:", len(selected_post))
    print("LinkedIn limit: 1,300 characters")
    print()
    if len(selected_post) > 1300:
        print("⚠️  WARNING: Post exceeds LinkedIn character limit!")
        print(f"   Trim {len(selected_post) - 1300} characters")
    else:
        print("✅ Post is within LinkedIn character limit")
    print()
    print("=" * 70)
    print("NEXT STEPS:")
    print("=" * 70)
    print()
    print("Option 1: Post manually to LinkedIn")
    print("  1. Copy the post above")
    print("  2. Go to: https://www.linkedin.com/in/simonrenauld/")
    print("  3. Click 'Start a post'")
    print("  4. Paste and publish")
    print()
    print("Option 2: Post via automation")
    print("  1. Ensure .env is configured (LINKEDIN_EMAIL, LINKEDIN_PASSWORD)")
    print(f"  2. Run: python company_page_automation.py post \"$(cat {filename})\"")
    print()
    print("Option 3: Schedule for later")
    print("  1. Add to content generator")
    print("  2. Run: python orchestrator.py setup")
    print()
    print("Recommended: Start with Option 1 (manual) to test engagement")
    print()
    
    return filename

def main():
    import sys
    
    version = "short" if len(sys.argv) < 2 else sys.argv[1]
    
    if version not in ["short", "long", "technical"]:
        print("Usage: python homelab_post_generator.py [short|long|technical]")
        print()
        print("Versions:")
        print("  short     - Quick post (~500 chars, high engagement)")
        print("  long      - Detailed post (~1,200 chars, more info)")
        print("  technical - Deep-dive post (~1,500 chars, technical audience)")
        print()
        print("Default: short")
        sys.exit(1)
    
    generate_post(version)

if __name__ == "__main__":
    main()
