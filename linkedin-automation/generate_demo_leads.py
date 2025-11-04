#!/usr/bin/env python3
"""
Quick Lead Finder - Demo Mode
Generates sample high-fit leads for immediate use

Run this to see what leads look like without LinkedIn scraping
"""

import json
from pathlib import Path
from datetime import datetime

# Sample high-fit leads based on your target profile
SAMPLE_LEADS = [
    {
        "name": "Sarah Chen",
        "title": "Head of Data",
        "company": "TechViet Solutions",
        "location": "Ho Chi Minh, Vietnam",
        "linkedin_url": "https://www.linkedin.com/in/sarah-chen-techviet",
        "fit_score": 9,
        "search_role": "Head of Data",
        "search_location": "Vietnam",
        "industry": "Technology",
        "pain_points": ["Data quality assurance", "Automated testing pipelines", "PostgreSQL optimization"],
        "relevant_solutions": ["Automated QA", "Data pipeline expertise", "PostgreSQL/Airflow skills"],
        "found_date": datetime.now().isoformat()
    },
    {
        "name": "Michael Nguyen",
        "title": "VP Engineering",
        "company": "DataFlow Asia",
        "location": "Ho Chi Minh, Vietnam",
        "linkedin_url": "https://www.linkedin.com/in/michael-nguyen-dataflow",
        "fit_score": 8,
        "search_role": "VP Engineering",
        "search_location": "Vietnam",
        "industry": "Data Analytics",
        "pain_points": ["MLOps platform migration", "Test automation", "Team scaling"],
        "relevant_solutions": ["MLOps expertise", "Automated testing", "Data engineering"],
        "found_date": datetime.now().isoformat()
    },
    {
        "name": "Jennifer Wong",
        "title": "Director of Analytics",
        "company": "HealthTech Vietnam",
        "location": "Hanoi, Vietnam",
        "linkedin_url": "https://www.linkedin.com/in/jennifer-wong-healthtech",
        "fit_score": 9,
        "search_role": "Director of Analytics",
        "search_location": "Vietnam",
        "industry": "Healthcare Technology",
        "pain_points": ["Healthcare data accuracy", "HIPAA compliance", "Analytics platform QA"],
        "relevant_solutions": ["Healthcare analytics experience", "Data accuracy expertise", "Compliance knowledge"],
        "found_date": datetime.now().isoformat()
    },
    {
        "name": "David Kim",
        "title": "CTO",
        "company": "AI Innovations Canada",
        "location": "Toronto, Canada",
        "linkedin_url": "https://www.linkedin.com/in/david-kim-ai-innovations",
        "fit_score": 8,
        "search_role": "CTO",
        "search_location": "Canada",
        "industry": "Artificial Intelligence",
        "pain_points": ["AI model quality assurance", "Data pipeline reliability", "Automated testing"],
        "relevant_solutions": ["ML pipeline QA", "Automated testing frameworks", "Data platform experience"],
        "found_date": datetime.now().isoformat()
    },
    {
        "name": "Amanda Rodriguez",
        "title": "Chief Data Officer",
        "company": "Singapore Data Hub",
        "location": "Singapore",
        "linkedin_url": "https://www.linkedin.com/in/amanda-rodriguez-sg",
        "fit_score": 10,
        "search_role": "Chief Data Officer",
        "search_location": "Singapore",
        "industry": "Data Platform",
        "pain_points": ["Data governance", "Quality control automation", "PostgreSQL optimization"],
        "relevant_solutions": ["Data governance experience", "Automated QA", "PostgreSQL expertise"],
        "found_date": datetime.now().isoformat()
    },
    {
        "name": "Robert Tran",
        "title": "ML Engineering Lead",
        "company": "VietAI Labs",
        "location": "Ho Chi Minh, Vietnam",
        "linkedin_url": "https://www.linkedin.com/in/robert-tran-vietai",
        "fit_score": 9,
        "search_role": "ML Engineering Lead",
        "search_location": "Vietnam",
        "industry": "Machine Learning",
        "pain_points": ["ML pipeline testing", "Model quality assurance", "Airflow orchestration"],
        "relevant_solutions": ["MLOps platform", "Airflow expertise", "Automated ML testing"],
        "found_date": datetime.now().isoformat()
    }
]

def generate_demo_leads():
    """Generate demo leads and save to outputs"""
    
    output_dir = Path("outputs/batch_searches")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Save all leads
    all_leads_file = output_dir / f"demo_leads_{timestamp}_all_leads.json"
    with open(all_leads_file, 'w') as f:
        json.dump(SAMPLE_LEADS, f, indent=2)
    
    # Save high-fit leads (score >= 8)
    high_fit_leads = [l for l in SAMPLE_LEADS if l['fit_score'] >= 8]
    high_fit_file = output_dir / f"demo_leads_{timestamp}_high_fit.json"
    with open(high_fit_file, 'w') as f:
        json.dump(high_fit_leads, f, indent=2)
    
    print("="*70)
    print("🎯 DEMO LEADS GENERATED")
    print("="*70)
    print(f"\nGenerated {len(SAMPLE_LEADS)} sample leads")
    print(f"High-fit leads (≥8): {len(high_fit_leads)}")
    print(f"\nFiles saved:")
    print(f"  - All leads: {all_leads_file}")
    print(f"  - High-fit:  {high_fit_file}")
    
    print("\n📊 LEAD SUMMARY:")
    for lead in SAMPLE_LEADS:
        print(f"\n  {lead['name']} - {lead['title']}")
        print(f"    Company: {lead['company']}")
        print(f"    Location: {lead['location']}")
        print(f"    Fit Score: {lead['fit_score']}/10")
        print(f"    Pain Points: {', '.join(lead['pain_points'][:2])}")
    
    print("\n"+"="*70)
    print("NEXT STEPS:")
    print("="*70)
    print("\n1. Import to CRM:")
    print(f"   python3 crm_database.py import-leads {all_leads_file}")
    print("\n2. View in database:")
    print("   psql universal_crm -c 'SELECT * FROM active_leads_view;'")
    print("\n3. For REAL LinkedIn leads:")
    print("   - Configure LinkedIn credentials in .env")
    print("   - Run: python3 batch_lead_search.py --quick --locations Vietnam Canada")
    print()
    
    return str(all_leads_file)

if __name__ == "__main__":
    leads_file = generate_demo_leads()
    
    # Auto-import to CRM
    print("\n"+"="*70)
    print("💾 AUTO-IMPORTING TO CRM...")
    print("="*70)
    
    try:
        import subprocess
        result = subprocess.run(
            ["python3", "crm_database.py", "import-leads", leads_file],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print(result.stdout)
        else:
            print("⚠️  CRM import failed. Import manually:")
            print(f"  python3 crm_database.py import-leads {leads_file}")
    except Exception as e:
        print(f"⚠️  Auto-import skipped: {e}")
        print(f"Import manually: python3 crm_database.py import-leads {leads_file}")
