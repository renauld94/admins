#!/usr/bin/env python3
"""
Batch Lead Search - Find all target roles across multiple locations

Searches for high-value prospects across key roles and locations,
then consolidates results with deduplication and smart scoring.

Usage:
    python3 batch_lead_search.py              # Search all default targets
    python3 batch_lead_search.py --quick      # Quick search (top roles only)
    python3 batch_lead_search.py --location Vietnam  # Single location
"""

import sys
import time
import json
import asyncio
import argparse
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Set
from collections import defaultdict

# Import the lead generation engine
from lead_generation_engine import LeadGenerationEngine


class BatchLeadSearch:
    """Orchestrates batch searches across multiple roles and locations"""
    
    # Target roles in priority order
    TARGET_ROLES = [
        "Head of Data",
        "VP Data",
        "VP Data Analytics",
        "Chief Data Officer",
        "CTO",
        "VP Engineering",
        "Chief Technology Officer",
        "Director of Analytics",
        "Director Data Analytics",
        "Analytics Lead",
        "ML Engineering Lead",
        "Machine Learning Lead",
        "Head of Machine Learning",
        "Data Science Lead",
        "Head of AI",
        "VP Data Science",
    ]
    
    # Target locations
    TARGET_LOCATIONS = [
        "Vietnam",
        "Canada", 
        "Singapore",
        "United States",
        "United Kingdom",
        "Germany",
        "France",
        "Netherlands",
        "Australia",
        "Hong Kong",
    ]
    
    # Industry modifiers for healthcare-focused search
    INDUSTRY_MODIFIERS = [
        "",  # Generic search
        "Healthcare",
        "Health Tech",
        "Medical",
        "Biotech",
        "Pharmaceutical",
    ]
    
    def __init__(self, quick_mode: bool = False):
        self.engine = LeadGenerationEngine()
        self.quick_mode = quick_mode
        self.all_leads: Dict[str, Dict] = {}  # Deduplicated leads
        self.search_stats = {
            "searches_completed": 0,
            "total_leads_found": 0,
            "unique_leads": 0,
            "duplicates_removed": 0,
            "high_fit_leads": 0,  # Score >= 7
        }
        
    async def run_batch_search(self, 
                        roles: List[str] = None,
                        locations: List[str] = None,
                        include_healthcare: bool = True) -> Dict:
        """
        Run batch searches across multiple roles and locations
        
        Args:
            roles: List of job titles to search (defaults to TARGET_ROLES)
            locations: List of locations (defaults to TARGET_LOCATIONS)
            include_healthcare: Whether to include healthcare-specific searches
            
        Returns:
            Dictionary with search results and statistics
        """
        roles = roles or (self.TARGET_ROLES[:4] if self.quick_mode else self.TARGET_ROLES)
        locations = locations or (self.TARGET_LOCATIONS[:3] if self.quick_mode else self.TARGET_LOCATIONS)
        
        print("=" * 70)
        print("🔍 BATCH LEAD SEARCH")
        print("=" * 70)
        print(f"\nSearching for {len(roles)} roles across {len(locations)} locations")
        print(f"Mode: {'Quick' if self.quick_mode else 'Comprehensive'}")
        print(f"Healthcare focus: {'Yes' if include_healthcare else 'No'}\n")
        
        total_searches = len(roles) * len(locations)
        if include_healthcare:
            total_searches += len(roles) * len(locations) * (len(self.INDUSTRY_MODIFIERS) - 1)
        
        print(f"Total searches planned: {total_searches}")
        print(f"Estimated time: {total_searches * 2} minutes (with rate limiting)\n")
        
        current_search = 0
        
        # Primary searches (role + location)
        for role in roles:
            for location in locations:
                current_search += 1
                print(f"\n[{current_search}/{total_searches}] Searching: {role} in {location}")
                
                try:
                    leads = await self.engine.scrape_linkedin_search(role, location)
                    self._process_leads(leads, role, location)
                    self.search_stats["searches_completed"] += 1
                    
                    # Rate limiting - be nice to LinkedIn
                    if current_search < total_searches:
                        wait_time = 10 if self.quick_mode else 30
                        print(f"   Waiting {wait_time}s before next search...")
                        time.sleep(wait_time)
                        
                except Exception as e:
                    print(f"   ⚠️  Search failed: {str(e)}")
                    continue
        
        # Healthcare-focused searches
        if include_healthcare and not self.quick_mode:
            for role in roles[:4]:  # Top 4 roles only for healthcare
                for location in locations[:3]:  # Top 3 locations
                    for modifier in self.INDUSTRY_MODIFIERS[1:]:  # Skip empty modifier
                        current_search += 1
                        search_term = f"{role} {modifier}"
                        print(f"\n[{current_search}/{total_searches}] Searching: {search_term} in {location}")
                        
                        try:
                            leads = await self.engine.scrape_linkedin_search(search_term, location)
                            self._process_leads(leads, search_term, location)
                            self.search_stats["searches_completed"] += 1
                            
                            if current_search < total_searches:
                                print(f"   Waiting 30s before next search...")
                                time.sleep(30)
                                
                        except Exception as e:
                            print(f"   ⚠️  Search failed: {str(e)}")
                            continue
        
        # Generate final report
        self._generate_report()
        
        return {
            "leads": self.all_leads,
            "stats": self.search_stats,
        }
    
    def _process_leads(self, leads: List[Dict], role: str, location: str):
        """Process and deduplicate leads from a search"""
        if not leads:
            print(f"   No leads found")
            return
            
        print(f"   Found {len(leads)} leads")
        self.search_stats["total_leads_found"] += len(leads)
        
        new_leads = 0
        for lead in leads:
            lead_id = lead.get("linkedin_url", lead.get("name", "unknown"))
            
            if lead_id in self.all_leads:
                # Duplicate - update if better fit score
                existing = self.all_leads[lead_id]
                if lead.get("fit_score", 0) > existing.get("fit_score", 0):
                    self.all_leads[lead_id] = lead
                self.search_stats["duplicates_removed"] += 1
            else:
                # New lead
                lead["search_role"] = role
                lead["search_location"] = location
                lead["found_date"] = datetime.now().isoformat()
                self.all_leads[lead_id] = lead
                new_leads += 1
                
                if lead.get("fit_score", 0) >= 7:
                    self.search_stats["high_fit_leads"] += 1
        
        self.search_stats["unique_leads"] = len(self.all_leads)
        print(f"   New unique leads: {new_leads}")
        print(f"   Total unique leads: {self.search_stats['unique_leads']}")
    
    def _generate_report(self):
        """Generate and save comprehensive search report"""
        print("\n" + "=" * 70)
        print("📊 SEARCH COMPLETE - GENERATING REPORT")
        print("=" * 70)
        
        # Create outputs directory
        output_dir = Path("outputs/batch_searches")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Save all leads
        leads_file = output_dir / f"batch_search_{timestamp}_all_leads.json"
        with open(leads_file, 'w') as f:
            json.dump(list(self.all_leads.values()), f, indent=2)
        
        # Save high-fit leads (score >= 7)
        high_fit_leads = [l for l in self.all_leads.values() if l.get("fit_score", 0) >= 7]
        high_fit_file = output_dir / f"batch_search_{timestamp}_high_fit.json"
        with open(high_fit_file, 'w') as f:
            json.dump(high_fit_leads, f, indent=2)
        
        # Generate summary statistics by role
        role_stats = defaultdict(int)
        location_stats = defaultdict(int)
        score_distribution = defaultdict(int)
        
        for lead in self.all_leads.values():
            role_stats[lead.get("search_role", "Unknown")] += 1
            location_stats[lead.get("search_location", "Unknown")] += 1
            score = lead.get("fit_score", 0)
            score_bucket = f"{(score // 2) * 2}-{(score // 2) * 2 + 1}"
            score_distribution[score_bucket] += 1
        
        # Print summary
        print(f"\n📈 SEARCH STATISTICS:")
        print(f"   Searches completed: {self.search_stats['searches_completed']}")
        print(f"   Total leads found: {self.search_stats['total_leads_found']}")
        print(f"   Unique leads: {self.search_stats['unique_leads']}")
        print(f"   Duplicates removed: {self.search_stats['duplicates_removed']}")
        print(f"   High-fit leads (≥7): {self.search_stats['high_fit_leads']}")
        
        print(f"\n🎯 TOP ROLES:")
        for role, count in sorted(role_stats.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"   {role}: {count}")
        
        print(f"\n🌍 TOP LOCATIONS:")
        for location, count in sorted(location_stats.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"   {location}: {count}")
        
        print(f"\n📊 SCORE DISTRIBUTION:")
        for score_range in sorted(score_distribution.keys()):
            count = score_distribution[score_range]
            bar = "█" * (count // 2)
            print(f"   {score_range}: {bar} {count}")
        
        print(f"\n💾 FILES SAVED:")
        print(f"   All leads: {leads_file}")
        print(f"   High-fit leads: {high_fit_file}")
        
        print(f"\n🚀 NEXT STEPS:")
        print(f"   1. Review high-fit leads: cat {high_fit_file}")
        print(f"   2. Generate outreach: python3 lead_generation_engine.py outreach <lead_id> inmail")
        print(f"   3. Start connecting on LinkedIn")
        print("\n")


def main():
    parser = argparse.ArgumentParser(
        description="Batch search for leads across multiple roles and locations"
    )
    parser.add_argument(
        "--quick",
        action="store_true",
        help="Quick mode - search top 4 roles and top 3 locations only"
    )
    parser.add_argument(
        "--roles",
        nargs="+",
        help="Specific roles to search (space-separated)"
    )
    parser.add_argument(
        "--locations",
        nargs="+", 
        help="Specific locations to search (space-separated)"
    )
    parser.add_argument(
        "--no-healthcare",
        action="store_true",
        help="Skip healthcare-specific searches"
    )
    
    args = parser.parse_args()
    
    # Create batch searcher
    searcher = BatchLeadSearch(quick_mode=args.quick)
    
    # Run search with asyncio
    result = asyncio.run(searcher.run_batch_search(
        roles=args.roles,
        locations=args.locations,
        include_healthcare=not args.no_healthcare
    ))
    
    # Auto-import to CRM if available
    print("\n" + "="*70)
    print("💾 IMPORTING TO CRM DATABASE")
    print("="*70)
    
    try:
        import subprocess
        output_dir = Path("outputs/batch_searches")
        latest_file = sorted(output_dir.glob("*_all_leads.json"))[-1]
        
        result = subprocess.run(
            ["python3", "crm_database.py", "import-leads", str(latest_file)],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print(result.stdout)
        else:
            print("⚠️  CRM import failed. Run manually:")
            print(f"  python3 crm_database.py import-leads {latest_file}")
            
    except Exception as e:
        print(f"⚠️  CRM auto-import skipped: {e}")
        print("To import later:")
        print("  python3 crm_database.py import-leads outputs/batch_searches/<file>")


if __name__ == "__main__":
    main()
