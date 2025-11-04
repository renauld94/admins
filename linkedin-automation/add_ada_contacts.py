#!/usr/bin/env python3
"""
Add Real Contacts - David Nomber and Frank Plazanet from ADA Vietnam
Met in person on 2025-11-04
"""

import sys
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta
import json

# Database configuration
DB_CONFIG = {
    "database": "universal_crm",
    "user": "simon",
}

def add_ada_contacts():
    """Add David Nomber and Frank Plazanet from ADA Vietnam"""
    
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    print("=" * 70)
    print("🔥 ADDING HOT LEAD - ADA VIETNAM")
    print("=" * 70)
    print()
    
    # 1. Add ADA as organization
    print("Adding organization: ADA Global...")
    cur.execute("""
        INSERT INTO organizations (
            name, domain, website, linkedin_url, industry,
            size_category, headquarters_location, description,
            relationship_stage, first_contact_date, last_contact_date,
            source, source_details
        ) VALUES (
            'ADA Global',
            'adaglobal.com',
            'https://www.adaglobal.com',
            'https://www.linkedin.com/company/ada-global',
            'Data & AI / Analytics',
            'enterprise',
            'Singapore (Vietnam office: Ho Chi Minh)',
            'Leading data and AI company in Asia. 11 markets. Partners with top brands (CPG, retail, telco, BFSI) for digital transformation.',
            'warm',  -- Already met in person!
            NOW(),
            NOW(),
            'in_person_meeting',
            %s
        )
        ON CONFLICT (domain) DO UPDATE
        SET last_contact_date = NOW(),
            updated_at = NOW()
        RETURNING id
    """, (json.dumps({
        "meeting_date": "2025-11-04",
        "meeting_type": "in_person",
        "location": "Ho Chi Minh, Vietnam",
        "context": "Met David and Frank, discussed QA & QC Manager role"
    }),))
    
    org = cur.fetchone()
    org_id = org['id']
    print(f"✓ Organization added (ID: {org_id})")
    
    # 2. Add David Nomber
    print("\nAdding contact: David Nomber...")
    
    # Check if exists first
    cur.execute("SELECT id FROM people WHERE full_name = 'David Nomber' AND organization_id = %s", (org_id,))
    existing = cur.fetchone()
    
    if existing:
        david_id = existing['id']
        cur.execute("""
            UPDATE people SET
                last_contact_date = NOW(),
                next_follow_up_date = NOW() + INTERVAL '3 days',
                updated_at = NOW()
            WHERE id = %s
        """, (david_id,))
        print(f"✓ David Nomber updated (ID: {david_id})")
    else:
        cur.execute("""
            INSERT INTO people (
                organization_id, full_name, job_title, email,
                relationship_stage, fit_score, engagement_score,
                first_contact_date, last_contact_date,
                next_follow_up_date, source, source_details
            ) VALUES (
                %s, 'David Nomber', 
                'Unknown (ADA Vietnam)',  -- Update when you know
                NULL,  -- Get email from Frank
                'engaged',  -- Met in person = engaged!
                9,  -- High fit - they have the job you want
                8,  -- Good engagement - met in person
                NOW(),
                NOW(),
                NOW() + INTERVAL '3 days',  -- Follow up in 3 days
                'in_person_meeting',
                %s
            )
            RETURNING id
        """, (org_id, json.dumps({
            "met_date": "2025-11-04",
            "met_location": "Ho Chi Minh, Vietnam",
            "context": "In-person meeting, introduced by Frank"
        })))
        
        david_id = cur.fetchone()['id']
        print(f"✓ David Nomber added (ID: {david_id})")
    
    # 3. Add Frank Plazanet
    print("\nAdding contact: Frank Plazanet...")
    
    # Check if exists first
    cur.execute("SELECT id FROM people WHERE full_name = 'Frank Plazanet' AND organization_id = %s", (org_id,))
    existing = cur.fetchone()
    
    if existing:
        frank_id = existing['id']
        cur.execute("""
            UPDATE people SET
                last_contact_date = NOW(),
                next_follow_up_date = NOW() + INTERVAL '1 day',
                updated_at = NOW()
            WHERE id = %s
        """, (frank_id,))
        print(f"✓ Frank Plazanet updated (ID: {frank_id})")
    else:
        cur.execute("""
            INSERT INTO people (
                organization_id, full_name, job_title, email,
                relationship_stage, fit_score, engagement_score,
                first_contact_date, last_contact_date,
                next_follow_up_date, source, source_details
            ) VALUES (
                %s, 'Frank Plazanet',
                'Unknown (ADA Vietnam)',  -- Update when you know
                NULL,  -- Get during session
                'engaged',  -- Met in person!
                10,  -- HIGHEST FIT - Has upcoming session with you!
                9,  -- Very high engagement - scheduled session
                NOW(),
                NOW(),
                NOW() + INTERVAL '1 day',  -- Session scheduled soon!
                'in_person_meeting',
                %s
            )
            RETURNING id
        """, (org_id, json.dumps({
            "met_date": "2025-11-04",
            "met_location": "Ho Chi Minh, Vietnam",
            "upcoming_session": "Scheduled with Frank to assess fit for QA & QC Manager role",
            "context": "Primary contact, will determine if good fit"
        })))
        
        frank_id = cur.fetchone()['id']
        print(f"✓ Frank Plazanet added (ID: {frank_id})")
    
    # 4. Add the job opportunity
    print("\nAdding job opportunity: QA & QC Manager...")
    cur.execute("""
        INSERT INTO job_opportunities (
            organization_id, title, description, location,
            remote_policy, required_skills, preferred_skills,
            years_experience_required, posting_url, job_board,
            posted_date, status, fit_score
        ) VALUES (
            %s,
            'QA & QC Manager',
            %s,
            'Ho Chi Minh, Vietnam',
            'onsite',
            %s,  -- Required skills
            %s,  -- Preferred skills
            5,  -- 5-10 years
            'https://www.adaglobal.com/people-careers',
            'company_site',
            '2025-09-04',
            'active',
            10  -- PERFECT FIT!
        )
        RETURNING id
    """, (
        org_id,
        """ADA is the leading data and AI company in Asia. 
        
Role: Ensure 100% data accuracy by implementing enterprise-grade QC and automation.
Work with: Developer team building new data platform
Platform: Data from TikTok, Shopee, Lazada, Amazon → unified data model

Key Responsibilities:
1. Design/execute QA framework for data accuracy (manual + automated testing)
2. Quality Control - ongoing monitoring, audits, reviews
3. Automation - implement tools/scripts for data retrieval & validation
4. Collaboration - work with dev team, provide feedback
5. Documentation - maintain detailed QC processes, test plans

Perfect match for your skills:
- PostgreSQL, SQL ✓
- Airflow DAGs ✓
- Python scripts ✓
- Software engineering background ✓
- Automated test pipelines ✓
- Data platform experience ✓""",
        ["PostgreSQL", "SQL", "Automated Testing", "Quality Control", "Data Validation", "Team Management (3-4 people)", "Test Plan Development"],
        ["Airflow DAGs", "Python scripting", "Bash", "pytest", "GitHub Workflow", "Software Engineering background", "Software Logs analysis"]
    ))
    
    job_id = cur.fetchone()['id']
    print(f"✓ Job opportunity added (ID: {job_id})")
    
    # 5. Create job application record
    print("\nCreating job application...")
    cur.execute("""
        INSERT INTO job_applications (
            job_opportunity_id, organization_id,
            application_status, application_date,
            hiring_manager_person_id,
            next_follow_up_date,
            notes
        ) VALUES (
            %s, %s,
            'screening',  -- Met in person, have session scheduled
            NOW(),
            %s,  -- Frank is hiring manager
            NOW() + INTERVAL '1 day',  -- Session with Frank
            %s
        )
        RETURNING id
    """, (
        job_id, org_id, frank_id,
        """HOT LEAD - Met in person on 2025-11-04
        
Contacts:
- David Nomber (ADA Vietnam) - Met in person
- Frank Plazanet (ADA Vietnam) - Scheduled session to assess fit

Next Steps:
1. Session with Frank (scheduled soon)
2. Discuss QA & QC Manager role
3. Frank will determine if good fit
4. Get contact emails during session

Perfect Match Factors:
✓ PostgreSQL + SQL (required)
✓ Airflow DAGs (preferred) - YOU HAVE THIS
✓ Python scripts (preferred) - YOU HAVE THIS
✓ Automated test pipelines - YOU HAVE THIS
✓ Software engineering background - YOU HAVE THIS
✓ 5-10 years experience - YOU MATCH
✓ Data platform experience - YOU HAVE THIS (Moodle, healthcare analytics)

Why You're Perfect:
- Built automated data pipelines (ProxmoxMCP, Airflow)
- Healthcare analytics with PostgreSQL (500M+ records)
- MLOps platform (quality control critical)
- Training platform (data accuracy essential)
- Software engineering background (not just QA)

Preparation for Frank Session:
1. Emphasize automated test pipeline experience
2. Show Moodle data platform (quality control)
3. Discuss healthcare analytics QA (critical data)
4. Mention ProxmoxMCP automation (Airflow, Python)
5. Software engineering → QA perspective (unique advantage)
"""
    ))
    
    app_id = cur.fetchone()['id']
    print(f"✓ Job application created (ID: {app_id})")
    
    # 6. Create lead records
    print("\nCreating leads for David and Frank...")
    
    # David as lead
    cur.execute("""
        INSERT INTO leads (
            person_id, organization_id, lead_status, lead_source,
            fit_score, outreach_status, qualification_notes,
            pain_points_identified, relevant_capabilities
        ) VALUES (
            %s, %s,
            'qualified',  -- Met in person = qualified
            'in_person_meeting',
            9,
            'connected',  -- Already connected in person!
            'Met in person 2025-11-04. Works at ADA Vietnam. Introduced me to Frank for QA role.',
            %s,
            %s
        )
    """, (
        david_id, org_id,
        ["Data quality assurance needs", "Automated testing pipelines", "PostgreSQL/Airflow expertise"],
        ["Automated testing", "Data pipeline QA", "PostgreSQL expertise", "Airflow DAG development", "Software engineering background"]
    ))
    
    # Frank as lead (primary)
    cur.execute("""
        INSERT INTO leads (
            person_id, organization_id, lead_status, lead_source,
            fit_score, outreach_status, qualification_notes,
            pain_points_identified, relevant_capabilities,
            converted_to_opportunity, converted_date
        ) VALUES (
            %s, %s,
            'qualified',
            'in_person_meeting',
            10,  -- HIGHEST
            'connected',
            'PRIMARY CONTACT. Met in person 2025-11-04. Scheduled session to assess fit for QA & QC Manager role. Decision maker.',
            %s,
            %s,
            TRUE,  -- Already converted to job opportunity!
            NOW()
        )
    """, (
        frank_id, org_id,
        ["Need QA & QC Manager", "Data accuracy critical", "Building new data platform", "Automated testing needed"],
        ["Automated QA pipelines", "PostgreSQL/SQL expertise", "Airflow DAGs", "Python automation", "Software engineering mindset", "Data platform experience"]
    ))
    
    print("✓ Leads created for both contacts")
    
    # 7. Log the meeting interaction
    print("\nLogging in-person meeting interaction...")
    cur.execute("""
        INSERT INTO interactions (
            organization_id, interaction_type, direction,
            subject, notes, outcome, interaction_date,
            related_job_id
        ) VALUES (
            %s,
            'meeting',
            'inbound',  -- They approached about role
            'In-person meeting - QA & QC Manager opportunity',
            %s,
            'positive',
            NOW(),
            %s
        )
    """, (
        org_id,
        """Met David Nomber and Frank Plazanet from ADA Vietnam in person.

Discussion:
- QA & QC Manager role at ADA
- Data platform quality control (TikTok, Shopee, Lazada, Amazon data)
- Perfect fit for my skills: PostgreSQL, Airflow, Python, automated testing

Outcome:
- Frank scheduled session to assess fit
- Will discuss role requirements in detail
- Opportunity to implement QA from beginning (new platform version)

Next Actions:
1. Prepare for session with Frank
2. Showcase relevant experience (Moodle QA, healthcare data accuracy, ProxmoxMCP automation)
3. Get contact emails
4. Follow up after session""",
        app_id
    ))
    
    print("✓ Interaction logged")
    
    # 8. Update daily metrics
    print("\nUpdating daily metrics...")
    cur.execute("""
        INSERT INTO daily_metrics (
            metric_date, new_leads_count, opportunities_created,
            interviews_scheduled
        ) VALUES (
            CURRENT_DATE, 2, 1, 1
        )
        ON CONFLICT (metric_date) DO UPDATE
        SET new_leads_count = daily_metrics.new_leads_count + 2,
            opportunities_created = daily_metrics.opportunities_created + 1,
            interviews_scheduled = daily_metrics.interviews_scheduled + 1
    """)
    
    print("✓ Metrics updated")
    
    conn.commit()
    
    # Print summary
    print("\n" + "=" * 70)
    print("🎯 HOT LEAD ADDED TO CRM!")
    print("=" * 70)
    print(f"""
Organization: ADA Global (ID: {org_id})
  - Industry: Data & AI / Analytics
  - Stage: WARM (met in person!)
  - Location: Ho Chi Minh, Vietnam

Contacts:
  1. David Nomber (ID: {david_id})
     - Met: 2025-11-04 (in person)
     - Fit Score: 9/10
     - Follow up: In 3 days

  2. Frank Plazanet (ID: {frank_id}) ⭐ PRIMARY
     - Met: 2025-11-04 (in person)
     - Fit Score: 10/10 (HIGHEST!)
     - Session: SCHEDULED SOON!
     - Role: Decision maker for QA role

Job Opportunity (ID: {job_id}):
  - Title: QA & QC Manager
  - Fit Score: 10/10 (PERFECT MATCH!)
  - Status: Active screening
  - Posted: Sep 04, 2025
  - Required: PostgreSQL, SQL, Automated Testing ✓ YOU HAVE ALL
  - Preferred: Airflow, Python, Software Engineering ✓ YOU HAVE ALL

Application (ID: {app_id}):
  - Status: SCREENING (have session scheduled)
  - Next: Session with Frank (follow up in 1 day)

WHY THIS IS HOT:
✓ Met in person (not cold outreach!)
✓ Session scheduled with decision maker
✓ 10/10 fit score - perfect match for your skills
✓ Your unique advantage: Software engineer → QA (rare combo)
✓ All required + preferred skills matched
✓ New platform build = implement QA from scratch

NEXT ACTIONS:
1. Prepare for Frank session:
   - Showcase Moodle data platform QA
   - Discuss healthcare analytics accuracy (critical data)
   - Highlight automated test pipelines (ProxmoxMCP, Airflow)
   - Emphasize software engineering background (unique value)

2. Get contact emails during session

3. Send thank-you follow-up after session

4. Track in CRM:
   python3 crm_database.py dashboard
   psql universal_crm -c "SELECT * FROM active_applications_view;"
""")
    
    cur.close()
    conn.close()

if __name__ == "__main__":
    try:
        add_ada_contacts()
    except psycopg2.OperationalError:
        print("❌ Database not setup yet. Run:")
        print("   ./setup-crm-database.sh")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
