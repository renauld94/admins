#!/usr/bin/env python3
"""
Universal CRM Database Manager
Integrates all systems: Leads, Jobs, Moodle, Projects, Infrastructure

Usage:
    python3 crm_database.py setup              # Create database
    python3 crm_database.py import-leads       # Import LinkedIn leads
    python3 crm_database.py import-moodle      # Sync Moodle data
    python3 crm_database.py dashboard          # View CRM dashboard
"""

import os
import sys
import json
import psycopg2
from psycopg2.extras import RealDictCursor, execute_values
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Optional
import subprocess

# Database configuration
DB_CONFIG = {
    "database": os.getenv("CRM_DB_NAME", "universal_crm"),
    "user": os.getenv("CRM_DB_USER", "simon"),
}


class UniversalCRM:
    """Unified CRM database for all business activities"""
    
    def __init__(self):
        self.conn = None
        self.cur = None
        
    def connect(self):
        """Connect to PostgreSQL database"""
        try:
            self.conn = psycopg2.connect(**DB_CONFIG)
            self.cur = self.conn.cursor(cursor_factory=RealDictCursor)
            print(f"✓ Connected to {DB_CONFIG['database']}")
        except psycopg2.OperationalError as e:
            print(f"⚠️  Database connection failed: {e}")
            print("\nTo setup PostgreSQL:")
            print("  sudo apt install postgresql postgresql-contrib")
            print("  sudo -u postgres createuser -s simon")
            print("  createdb universal_crm")
            sys.exit(1)
    
    def close(self):
        """Close database connection"""
        if self.cur:
            self.cur.close()
        if self.conn:
            self.conn.close()
    
    def setup_database(self):
        """Create all tables from schema"""
        print("\n" + "="*70)
        print("🗄️  SETTING UP UNIVERSAL CRM DATABASE")
        print("="*70)
        
        schema_path = Path(__file__).parent / "database" / "schema.sql"
        
        if not schema_path.exists():
            print(f"❌ Schema file not found: {schema_path}")
            return
        
        with open(schema_path, 'r') as f:
            schema_sql = f.read()
        
        try:
            self.cur.execute(schema_sql)
            self.conn.commit()
            print("✓ Database schema created successfully")
            
            # Verify tables
            self.cur.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """)
            tables = [row['table_name'] for row in self.cur.fetchall()]
            print(f"\n✓ Created {len(tables)} tables:")
            for table in tables:
                print(f"  - {table}")
                
        except Exception as e:
            print(f"❌ Error creating schema: {e}")
            self.conn.rollback()
    
    def import_linkedin_leads(self, leads_file: str):
        """Import leads from LinkedIn batch search results"""
        print(f"\n📥 Importing leads from {leads_file}")
        
        if not Path(leads_file).exists():
            print(f"❌ File not found: {leads_file}")
            return
        
        with open(leads_file, 'r') as f:
            leads_data = json.load(f)
        
        imported = 0
        skipped = 0
        
        for lead in leads_data:
            try:
                # Insert organization
                org_id = self._upsert_organization({
                    "name": lead.get("company", "Unknown"),
                    "linkedin_url": lead.get("company_linkedin_url"),
                    "industry": lead.get("industry"),
                    "relationship_stage": "lead",
                    "source": "linkedin",
                    "source_details": json.dumps({
                        "search_query": lead.get("search_role"),
                        "search_location": lead.get("search_location"),
                        "found_date": lead.get("found_date")
                    })
                })
                
                # Insert person
                person_id = self._upsert_person({
                    "organization_id": org_id,
                    "full_name": lead.get("name"),
                    "job_title": lead.get("title"),
                    "linkedin_url": lead.get("linkedin_url"),
                    "relationship_stage": "cold",
                    "fit_score": lead.get("fit_score", 5),
                    "source": "linkedin",
                    "source_details": json.dumps(lead)
                })
                
                # Insert lead record
                self.cur.execute("""
                    INSERT INTO leads (
                        person_id, organization_id, lead_status, lead_source,
                        search_query, search_location, fit_score,
                        pain_points_identified, relevant_capabilities
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT DO NOTHING
                    RETURNING id
                """, (
                    person_id, org_id, "new", "linkedin_search",
                    lead.get("search_role"), lead.get("search_location"),
                    lead.get("fit_score", 5),
                    lead.get("pain_points", []),
                    lead.get("relevant_solutions", [])
                ))
                
                if self.cur.fetchone():
                    imported += 1
                else:
                    skipped += 1
                    
            except Exception as e:
                print(f"⚠️  Error importing lead {lead.get('name')}: {e}")
                skipped += 1
                continue
        
        self.conn.commit()
        print(f"✓ Imported {imported} leads ({skipped} duplicates skipped)")
    
    def _upsert_organization(self, data: Dict) -> int:
        """Insert or update organization, return ID"""
        # Try to find existing by LinkedIn URL or name
        linkedin_url = data.get("linkedin_url")
        name = data.get("name", "Unknown")
        
        if linkedin_url:
            self.cur.execute(
                "SELECT id FROM organizations WHERE linkedin_url = %s",
                (linkedin_url,)
            )
            existing = self.cur.fetchone()
            if existing:
                return existing['id']
        
        # Insert new organization
        self.cur.execute("""
            INSERT INTO organizations (
                name, linkedin_url, industry, relationship_stage,
                source, source_details, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s, NOW())
            ON CONFLICT (linkedin_url) DO UPDATE
            SET name = EXCLUDED.name,
                industry = EXCLUDED.industry,
                updated_at = NOW()
            RETURNING id
        """, (
            name,
            linkedin_url,
            data.get("industry"),
            data.get("relationship_stage", "lead"),
            data.get("source", "linkedin"),
            data.get("source_details")
        ))
        
        return self.cur.fetchone()['id']
    
    def _upsert_person(self, data: Dict) -> int:
        """Insert or update person, return ID"""
        linkedin_url = data.get("linkedin_url")
        email = data.get("email")
        
        # Try to find existing
        if linkedin_url:
            self.cur.execute(
                "SELECT id FROM people WHERE linkedin_url = %s",
                (linkedin_url,)
            )
            existing = self.cur.fetchone()
            if existing:
                return existing['id']
        
        if email:
            self.cur.execute(
                "SELECT id FROM people WHERE email = %s",
                (email,)
            )
            existing = self.cur.fetchone()
            if existing:
                return existing['id']
        
        # Insert new person
        self.cur.execute("""
            INSERT INTO people (
                organization_id, full_name, job_title, linkedin_url,
                email, relationship_stage, fit_score, source,
                source_details, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
            RETURNING id
        """, (
            data.get("organization_id"),
            data.get("full_name"),
            data.get("job_title"),
            linkedin_url,
            email,
            data.get("relationship_stage", "cold"),
            data.get("fit_score", 5),
            data.get("source", "linkedin"),
            data.get("source_details")
        ))
        
        return self.cur.fetchone()['id']
    
    def import_moodle_data(self):
        """Sync Moodle enrollments and courses"""
        print("\n📥 Importing Moodle data...")
        
        # TODO: Integrate with Moodle API
        # This would fetch courses and enrollments from moodle.simondatalab.de
        # For now, show the structure
        
        print("✓ Moodle integration ready")
        print("  - Set MOODLE_URL and MOODLE_TOKEN in .env")
        print("  - Script will sync courses and enrollments")
        print("  - Links students to organizations for relationship tracking")
    
    def track_job_application(self, job_data: Dict):
        """Add a job application to CRM"""
        # Insert organization
        org_id = self._upsert_organization({
            "name": job_data["company"],
            "website": job_data.get("company_website"),
            "industry": job_data.get("industry"),
            "relationship_stage": "employer",
            "source": "job_search"
        })
        
        # Insert job opportunity
        self.cur.execute("""
            INSERT INTO job_opportunities (
                organization_id, title, description, location,
                remote_policy, salary_range_min, salary_range_max,
                posting_url, job_board, posted_date, status
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            org_id,
            job_data["title"],
            job_data.get("description"),
            job_data.get("location"),
            job_data.get("remote_policy", "unknown"),
            job_data.get("salary_min"),
            job_data.get("salary_max"),
            job_data.get("url"),
            job_data.get("source", "linkedin"),
            job_data.get("posted_date"),
            "active"
        ))
        
        job_id = self.cur.fetchone()['id']
        
        # Insert application
        self.cur.execute("""
            INSERT INTO job_applications (
                job_opportunity_id, organization_id,
                application_status, application_date
            ) VALUES (%s, %s, %s, NOW())
            RETURNING id
        """, (job_id, org_id, "submitted"))
        
        app_id = self.cur.fetchone()['id']
        self.conn.commit()
        
        print(f"✓ Tracked job application: {job_data['title']} at {job_data['company']}")
        return app_id
    
    def add_consulting_project(self, project_data: Dict):
        """Add a new consulting project"""
        # Ensure organization exists
        org_id = self._upsert_organization({
            "name": project_data["client_name"],
            "relationship_stage": "client",
            "source": "consulting"
        })
        
        # Insert project
        self.cur.execute("""
            INSERT INTO consulting_projects (
                organization_id, project_name, project_type,
                description, start_date, end_date, status,
                contract_value, deliverables
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            org_id,
            project_data["project_name"],
            project_data.get("project_type", "data_engineering"),
            project_data.get("description"),
            project_data.get("start_date"),
            project_data.get("end_date"),
            "planning",
            project_data.get("contract_value"),
            project_data.get("deliverables", [])
        ))
        
        project_id = self.cur.fetchone()['id']
        self.conn.commit()
        
        print(f"✓ Created project: {project_data['project_name']}")
        return project_id
    
    def log_interaction(self, interaction_data: Dict):
        """Log any interaction (email, call, meeting)"""
        self.cur.execute("""
            INSERT INTO interactions (
                person_id, organization_id, interaction_type,
                direction, subject, notes, outcome,
                interaction_date
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            interaction_data.get("person_id"),
            interaction_data.get("organization_id"),
            interaction_data["interaction_type"],
            interaction_data.get("direction", "outbound"),
            interaction_data.get("subject"),
            interaction_data.get("notes"),
            interaction_data.get("outcome"),
            interaction_data.get("date", datetime.now())
        ))
        
        self.conn.commit()
        print("✓ Interaction logged")
    
    def show_dashboard(self):
        """Display CRM dashboard"""
        print("\n" + "="*70)
        print("📊 UNIVERSAL CRM DASHBOARD")
        print("="*70)
        
        # Lead stats
        self.cur.execute("""
            SELECT 
                lead_status,
                COUNT(*) as count,
                AVG(fit_score) as avg_fit_score
            FROM leads
            GROUP BY lead_status
            ORDER BY count DESC
        """)
        
        print("\n🎯 LEADS:")
        for row in self.cur.fetchall():
            print(f"  {row['lead_status']:20s}: {row['count']:3d} (avg fit: {row['avg_fit_score']:.1f})")
        
        # Top organizations
        self.cur.execute("""
            SELECT 
                o.name,
                o.relationship_stage,
                COUNT(DISTINCT p.id) as contact_count,
                MAX(i.interaction_date) as last_contact
            FROM organizations o
            LEFT JOIN people p ON o.id = p.organization_id
            LEFT JOIN interactions i ON o.id = i.organization_id
            WHERE o.relationship_stage IN ('client', 'prospect')
            GROUP BY o.id, o.name, o.relationship_stage
            ORDER BY contact_count DESC
            LIMIT 10
        """)
        
        print("\n🏢 TOP ORGANIZATIONS:")
        for row in self.cur.fetchall():
            last = row['last_contact'].strftime("%Y-%m-%d") if row['last_contact'] else "Never"
            print(f"  {row['name']:30s} | {row['relationship_stage']:10s} | Contacts: {row['contact_count']} | Last: {last}")
        
        # Job applications
        self.cur.execute("""
            SELECT application_status, COUNT(*) as count
            FROM job_applications
            GROUP BY application_status
            ORDER BY count DESC
        """)
        
        print("\n💼 JOB APPLICATIONS:")
        for row in self.cur.fetchall():
            print(f"  {row['application_status']:20s}: {row['count']}")
        
        # Recent interactions
        self.cur.execute("""
            SELECT 
                i.interaction_type,
                p.full_name,
                o.name as org_name,
                i.subject,
                i.interaction_date
            FROM interactions i
            LEFT JOIN people p ON i.person_id = p.id
            LEFT JOIN organizations o ON i.organization_id = o.id
            ORDER BY i.interaction_date DESC
            LIMIT 10
        """)
        
        print("\n💬 RECENT INTERACTIONS:")
        for row in self.cur.fetchall():
            date = row['interaction_date'].strftime("%Y-%m-%d %H:%M") if row['interaction_date'] else ""
            person = row['full_name'] or "Unknown"
            org = row['org_name'] or ""
            print(f"  {date} | {row['interaction_type']:15s} | {person} @ {org}")
        
        print("\n")


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 crm_database.py <command>")
        print("\nCommands:")
        print("  setup              - Create database schema")
        print("  import-leads FILE  - Import LinkedIn leads from JSON")
        print("  import-moodle      - Sync Moodle data")
        print("  dashboard          - Show CRM dashboard")
        print("  test               - Add test data")
        return
    
    crm = UniversalCRM()
    
    try:
        crm.connect()
        
        command = sys.argv[1]
        
        if command == "setup":
            crm.setup_database()
            
        elif command == "import-leads":
            if len(sys.argv) < 3:
                # Find latest batch search file
                batch_dir = Path("outputs/batch_searches")
                if batch_dir.exists():
                    files = sorted(batch_dir.glob("*_all_leads.json"))
                    if files:
                        crm.import_linkedin_leads(str(files[-1]))
                    else:
                        print("❌ No lead files found in outputs/batch_searches/")
                else:
                    print("❌ Please provide leads file: crm_database.py import-leads <file>")
            else:
                crm.import_linkedin_leads(sys.argv[2])
        
        elif command == "import-moodle":
            crm.import_moodle_data()
            
        elif command == "dashboard":
            crm.show_dashboard()
            
        elif command == "test":
            # Add test job application
            crm.track_job_application({
                "company": "Example Tech Corp",
                "title": "Senior Data Engineer",
                "location": "Remote",
                "remote_policy": "remote",
                "salary_min": 120000,
                "salary_max": 160000,
                "url": "https://example.com/jobs/123",
                "source": "linkedin"
            })
            
            # Add test consulting project
            crm.add_consulting_project({
                "client_name": "Healthcare Innovators Inc",
                "project_name": "MLOps Platform Migration",
                "project_type": "mlops",
                "description": "Migrate legacy ML infrastructure to modern platform",
                "contract_value": 75000,
                "deliverables": ["Architecture design", "Platform deployment", "Training"]
            })
            
            print("✓ Test data added")
        
        else:
            print(f"❌ Unknown command: {command}")
    
    finally:
        crm.close()


if __name__ == "__main__":
    main()
