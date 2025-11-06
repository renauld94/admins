#!/usr/bin/env python3
"""
ClickUp Job Search Tracker Integration
Syncs job applications, recruiter connections, and interview tracking to ClickUp
"""

import os
import json
import requests
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
from dotenv import load_dotenv

load_dotenv()

# ClickUp API Configuration
CLICKUP_API_KEY = os.getenv('CLICKUP_API_KEY', '')
CLICKUP_TEAM_ID = os.getenv('CLICKUP_TEAM_ID', '')
CLICKUP_SPACE_ID = os.getenv('CLICKUP_SPACE_ID', '')
CLICKUP_LIST_ID = os.getenv('CLICKUP_JOB_LIST_ID', '')

BASE_URL = "https://api.clickup.com/api/v2"


class ClickUpJobTracker:
    """Track job search activities in ClickUp"""
    
    def __init__(self, api_key: str = None):
        self.api_key = api_key or CLICKUP_API_KEY
        self.headers = {
            "Authorization": self.api_key,
            "Content-Type": "application/json"
        }
        
        if not self.api_key:
            raise ValueError("ClickUp API key not found. Set CLICKUP_API_KEY in .env file")
    
    def _request(self, method: str, endpoint: str, **kwargs) -> Dict:
        """Make API request to ClickUp"""
        url = f"{BASE_URL}/{endpoint}"
        
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=self.headers,
                **kwargs
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"❌ ClickUp API Error: {e}")
            if hasattr(e.response, 'text'):
                print(f"   Response: {e.response.text}")
            return {}
    
    def get_workspaces(self) -> List[Dict]:
        """Get all workspaces (teams)"""
        result = self._request("GET", "team")
        return result.get('teams', [])
    
    def get_spaces(self, team_id: str) -> List[Dict]:
        """Get all spaces in a team"""
        result = self._request("GET", f"team/{team_id}/space?archived=false")
        return result.get('spaces', [])
    
    def create_space(self, team_id: str, name: str = "Job Search Tracker") -> Dict:
        """Create a new space for job tracking"""
        data = {
            "name": name,
            "multiple_assignees": True,
            "features": {
                "due_dates": {"enabled": True},
                "time_tracking": {"enabled": True},
                "tags": {"enabled": True},
                "priorities": {"enabled": True}
            }
        }
        
        return self._request("POST", f"team/{team_id}/space", json=data)
    
    def get_lists(self, space_id: str) -> List[Dict]:
        """Get all lists in a space"""
        result = self._request("GET", f"space/{space_id}/list")
        return result.get('lists', [])
    
    def create_job_search_lists(self, space_id: str) -> Dict:
        """Create organized lists for job search tracking"""
        lists = {
            "applications": None,
            "recruiters": None,
            "interviews": None,
            "offers": None,
            "companies": None
        }
        
        # List 1: Job Applications
        app_list = self._request("POST", f"space/{space_id}/list", json={
            "name": "📝 Job Applications",
            "content": "Track all job applications with status, fit score, and follow-ups",
            "due_date": None,
            "priority": None,
            "assignee": None,
            "status": None
        })
        lists["applications"] = app_list.get('id')
        
        # List 2: Recruiter Connections
        rec_list = self._request("POST", f"space/{space_id}/list", json={
            "name": "🤝 Recruiter Network",
            "content": "Track recruiter connections, conversations, and relationship status"
        })
        lists["recruiters"] = rec_list.get('id')
        
        # List 3: Interview Pipeline
        int_list = self._request("POST", f"space/{space_id}/list", json={
            "name": "🎯 Interview Pipeline",
            "content": "Active interviews with prep notes and follow-up tasks"
        })
        lists["interviews"] = int_list.get('id')
        
        # List 4: Job Offers
        offer_list = self._request("POST", f"space/{space_id}/list", json={
            "name": "💼 Offers & Negotiations",
            "content": "Track offers, compensation, and negotiation status"
        })
        lists["offers"] = offer_list.get('id')
        
        # List 5: Target Companies
        comp_list = self._request("POST", f"space/{space_id}/list", json={
            "name": "🏢 Target Companies",
            "content": "Research and track target companies to apply to"
        })
        lists["companies"] = comp_list.get('id')
        
        return lists
    
    def create_custom_fields(self, list_id: str, list_type: str):
        """Create custom fields for job tracking"""
        
        if list_type == "applications":
            fields = [
                {"name": "Company", "type": "short_text"},
                {"name": "Job URL", "type": "url"},
                {"name": "Fit Score", "type": "number"},
                {"name": "Salary Range", "type": "short_text"},
                {"name": "Location", "type": "short_text"},
                {"name": "Applied Date", "type": "date"},
                {"name": "Last Contact", "type": "date"},
                {"name": "Next Action", "type": "short_text"},
                {"name": "Recruiter", "type": "short_text"},
                {"name": "Status", "type": "drop_down", "options": [
                    "Applied", "Screening", "Technical", "Final", "Offer", "Rejected"
                ]}
            ]
        elif list_type == "recruiters":
            fields = [
                {"name": "Company", "type": "short_text"},
                {"name": "LinkedIn URL", "type": "url"},
                {"name": "Email", "type": "email"},
                {"name": "Phone", "type": "phone"},
                {"name": "Connection Date", "type": "date"},
                {"name": "Last Contact", "type": "date"},
                {"name": "Jobs Shared", "type": "number"},
                {"name": "Response Rate", "type": "short_text"},
                {"name": "Quality", "type": "drop_down", "options": [
                    "Hot Lead", "Active", "Warm", "Cold"
                ]}
            ]
        elif list_type == "interviews":
            fields = [
                {"name": "Company", "type": "short_text"},
                {"name": "Round", "type": "short_text"},
                {"name": "Interview Date", "type": "date"},
                {"name": "Interview Type", "type": "drop_down", "options": [
                    "Phone Screen", "Technical", "System Design", "Behavioral", "Final"
                ]},
                {"name": "Interviewer", "type": "short_text"},
                {"name": "Prep Status", "type": "drop_down", "options": [
                    "Not Started", "In Progress", "Ready"
                ]},
                {"name": "Result", "type": "drop_down", "options": [
                    "Pending", "Passed", "Rejected", "Next Round"
                ]}
            ]
        else:
            fields = []
        
        for field in fields:
            try:
                self._request("POST", f"list/{list_id}/field", json=field)
            except Exception as e:
                print(f"⚠️  Field creation error: {field['name']} - {e}")
    
    def create_job_application_task(self, list_id: str, job_data: Dict) -> Dict:
        """Create a task for a job application"""
        
        # Determine priority based on fit score
        fit_score = job_data.get('fit_score', 5)
        if fit_score >= 9:
            priority = 1  # Urgent
        elif fit_score >= 7:
            priority = 2  # High
        else:
            priority = 3  # Normal
        
        # Determine status
        status_map = {
            'identified': 'to do',
            'applied': 'in progress',
            'screening': 'in progress',
            'interview': 'in progress',
            'offer': 'complete',
            'rejected': 'closed'
        }
        status = status_map.get(job_data.get('status', 'identified'), 'to do')
        
        task_data = {
            "name": f"{job_data.get('title', 'Job')} @ {job_data.get('company', 'Company')}",
            "description": self._format_job_description(job_data),
            "priority": priority,
            "status": status,
            "due_date": int((datetime.now() + timedelta(days=7)).timestamp() * 1000),  # 7 days to follow up
            "tags": [
                job_data.get('location', 'Remote'),
                f"Score:{fit_score}",
                job_data.get('employment_type', 'Full-time')
            ]
        }
        
        return self._request("POST", f"list/{list_id}/task", json=task_data)
    
    def _format_job_description(self, job_data: Dict) -> str:
        """Format job data into task description"""
        desc = f"""
**Company:** {job_data.get('company', 'N/A')}
**Title:** {job_data.get('title', 'N/A')}
**Location:** {job_data.get('location', 'N/A')}
**Fit Score:** {job_data.get('fit_score', 'N/A')}/10

**Job URL:** {job_data.get('job_url', 'N/A')}

**Key Requirements:**
{chr(10).join('- ' + req for req in job_data.get('key_requirements', []))}

**Status:** {job_data.get('status', 'identified')}
**Applied Date:** {job_data.get('posted_date', 'N/A')}

**Notes:**
{job_data.get('notes', 'No notes yet')}

---
**Next Actions:**
1. Research company culture and tech stack
2. Customize resume for this role
3. Prepare cover letter highlighting fit
4. Apply within 24 hours (Top Applicant badge!)
5. Connect with recruiter on LinkedIn
"""
        return desc.strip()
    
    def create_recruiter_task(self, list_id: str, recruiter_data: Dict) -> Dict:
        """Create a task for recruiter tracking"""
        
        task_data = {
            "name": f"🤝 {recruiter_data.get('name', 'Recruiter')} @ {recruiter_data.get('company', 'Company')}",
            "description": f"""
**Company:** {recruiter_data.get('company', 'N/A')}
**Title:** {recruiter_data.get('title', 'N/A')}
**LinkedIn:** {recruiter_data.get('linkedin_url', 'N/A')}
**Email:** {recruiter_data.get('email', 'N/A')}

**Connection Date:** {recruiter_data.get('connection_date', datetime.now().isoformat())}
**Status:** {recruiter_data.get('status', 'Connected')}

**Notes:**
{recruiter_data.get('notes', 'New connection - send follow-up message')}

**Next Actions:**
1. Send thank you message
2. Share resume and portfolio
3. Ask about current openings
4. Weekly check-in
""",
            "priority": 2,
            "status": "to do",
            "tags": [
                recruiter_data.get('company', 'Unknown'),
                recruiter_data.get('location', 'Remote')
            ]
        }
        
        return self._request("POST", f"list/{list_id}/task", json=task_data)
    
    def sync_jobs_from_file(self, jobs_file: Path, list_id: str):
        """Sync jobs from JSON file to ClickUp"""
        
        if not jobs_file.exists():
            print(f"❌ Jobs file not found: {jobs_file}")
            return
        
        with open(jobs_file, 'r') as f:
            jobs = json.load(f)
        
        print(f"\n🔄 Syncing {len(jobs)} jobs to ClickUp...")
        
        created = 0
        for job in jobs:
            try:
                result = self.create_job_application_task(list_id, job)
                if result.get('id'):
                    created += 1
                    print(f"   ✅ Created: {job.get('title')} @ {job.get('company')}")
            except Exception as e:
                print(f"   ⚠️  Failed: {job.get('title')} - {e}")
        
        print(f"\n✅ Synced {created}/{len(jobs)} jobs to ClickUp!")
    
    def get_weekly_report(self, list_id: str) -> Dict:
        """Generate weekly job search report"""
        
        # Get all tasks
        result = self._request("GET", f"list/{list_id}/task")
        tasks = result.get('tasks', [])
        
        # Analyze tasks
        report = {
            "total_applications": len(tasks),
            "by_status": {},
            "by_priority": {},
            "high_fit_jobs": [],
            "pending_actions": []
        }
        
        for task in tasks:
            # Count by status
            status = task.get('status', {}).get('status', 'unknown')
            report["by_status"][status] = report["by_status"].get(status, 0) + 1
            
            # Count by priority
            priority = task.get('priority', {}).get('priority', 'none')
            report["by_priority"][priority] = report["by_priority"].get(priority, 0) + 1
            
            # Identify high fit jobs (priority 1 = urgent)
            if task.get('priority', {}).get('priority') == '1':
                report["high_fit_jobs"].append({
                    "name": task.get('name'),
                    "url": task.get('url')
                })
            
            # Pending actions (tasks overdue or due soon)
            if task.get('due_date'):
                due_ts = int(task['due_date']) / 1000
                due_date = datetime.fromtimestamp(due_ts)
                if due_date < datetime.now():
                    report["pending_actions"].append({
                        "name": task.get('name'),
                        "due_date": due_date.strftime('%Y-%m-%d'),
                        "overdue_days": (datetime.now() - due_date).days
                    })
        
        return report


def setup_clickup_workspace():
    """Interactive setup for ClickUp job tracking"""
    
    print("=" * 70)
    print("🚀 CLICKUP JOB SEARCH TRACKER SETUP")
    print("=" * 70)
    
    # Check for API key
    api_key = os.getenv('CLICKUP_API_KEY')
    if not api_key:
        print("\n❌ ClickUp API key not found!")
        print("\n📝 To get your API key:")
        print("   1. Go to: https://app.clickup.com/")
        print("   2. Click your avatar → Settings")
        print("   3. Click 'Apps' in sidebar")
        print("   4. Generate API Token")
        print("   5. Add to .env file: CLICKUP_API_KEY=your_key_here")
        return
    
    tracker = ClickUpJobTracker(api_key)
    
    # Get workspaces
    print("\n📋 Fetching your ClickUp workspaces...")
    workspaces = tracker.get_workspaces()
    
    if not workspaces:
        print("❌ No workspaces found. Please create one at https://app.clickup.com/")
        return
    
    print(f"\n✅ Found {len(workspaces)} workspace(s):")
    for i, ws in enumerate(workspaces, 1):
        print(f"   {i}. {ws['name']} (ID: {ws['id']})")
    
    # Use first workspace or ask user
    team_id = workspaces[0]['id']
    print(f"\n📌 Using workspace: {workspaces[0]['name']}")
    
    # Create space
    print("\n📁 Creating 'Job Search Tracker' space...")
    space = tracker.create_space(team_id)
    
    if not space.get('id'):
        print("❌ Failed to create space")
        return
    
    space_id = space['id']
    print(f"✅ Space created! ID: {space_id}")
    
    # Create lists
    print("\n📝 Creating tracking lists...")
    lists = tracker.create_job_search_lists(space_id)
    
    print("\n✅ Lists created:")
    for list_name, list_id in lists.items():
        if list_id:
            print(f"   • {list_name}: {list_id}")
    
    # Save IDs to .env
    print("\n💾 Saving configuration...")
    
    env_file = Path(__file__).parent / '.env'
    env_content = []
    
    if env_file.exists():
        with open(env_file, 'r') as f:
            env_content = f.readlines()
    
    # Update or add IDs
    config_lines = [
        f"CLICKUP_TEAM_ID={team_id}\n",
        f"CLICKUP_SPACE_ID={space_id}\n",
        f"CLICKUP_JOB_LIST_ID={lists.get('applications', '')}\n",
        f"CLICKUP_RECRUITER_LIST_ID={lists.get('recruiters', '')}\n",
        f"CLICKUP_INTERVIEW_LIST_ID={lists.get('interviews', '')}\n"
    ]
    
    # Remove old entries
    env_content = [line for line in env_content if not line.startswith('CLICKUP_')]
    env_content.extend(config_lines)
    
    with open(env_file, 'w') as f:
        f.writelines(env_content)
    
    print("✅ Configuration saved to .env")
    
    # Create custom fields
    print("\n🔧 Setting up custom fields...")
    tracker.create_custom_fields(lists['applications'], 'applications')
    tracker.create_custom_fields(lists['recruiters'], 'recruiters')
    tracker.create_custom_fields(lists['interviews'], 'interviews')
    
    print("\n" + "=" * 70)
    print("🎉 CLICKUP SETUP COMPLETE!")
    print("=" * 70)
    print(f"\n📱 Access your tracker: https://app.clickup.com/{space_id}")
    print("\n✅ Next Steps:")
    print("   1. Run: python3 clickup_job_tracker.py --sync")
    print("   2. This will import existing jobs from outputs/jobs/")
    print("   3. Track applications, recruiters, interviews in ClickUp")
    print("   4. Get weekly reports with: python3 clickup_job_tracker.py --report")


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="ClickUp Job Search Tracker")
    parser.add_argument('--setup', action='store_true', help='Set up ClickUp workspace')
    parser.add_argument('--sync', action='store_true', help='Sync jobs from JSON files')
    parser.add_argument('--report', action='store_true', help='Generate weekly report')
    parser.add_argument('--jobs-file', type=str, help='Path to jobs JSON file')
    
    args = parser.parse_args()
    
    if args.setup:
        setup_clickup_workspace()
    elif args.sync:
        tracker = ClickUpJobTracker()
        list_id = os.getenv('CLICKUP_JOB_LIST_ID')
        
        if not list_id:
            print("❌ Run --setup first to configure ClickUp")
            return
        
        # Find latest jobs file
        jobs_dir = Path(__file__).parent / "outputs" / "jobs"
        if args.jobs_file:
            jobs_file = Path(args.jobs_file)
        else:
            jobs_files = list(jobs_dir.glob("batch_jobs_*_all.json"))
            if not jobs_files:
                print("❌ No job files found in outputs/jobs/")
                return
            jobs_file = max(jobs_files, key=lambda p: p.stat().st_mtime)
        
        tracker.sync_jobs_from_file(jobs_file, list_id)
    
    elif args.report:
        tracker = ClickUpJobTracker()
        list_id = os.getenv('CLICKUP_JOB_LIST_ID')
        
        if not list_id:
            print("❌ Run --setup first to configure ClickUp")
            return
        
        report = tracker.get_weekly_report(list_id)
        
        print("\n" + "=" * 70)
        print("📊 WEEKLY JOB SEARCH REPORT")
        print("=" * 70)
        print(f"\n📝 Total Applications: {report['total_applications']}")
        
        print("\n📈 By Status:")
        for status, count in report['by_status'].items():
            print(f"   {status}: {count}")
        
        print("\n🎯 High-Fit Jobs:")
        for job in report['high_fit_jobs'][:5]:
            print(f"   • {job['name']}")
        
        print("\n⏰ Pending Actions:")
        for action in report['pending_actions'][:5]:
            print(f"   • {action['name']} (overdue {action['overdue_days']} days)")
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
