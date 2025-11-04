# 🗄️ Universal CRM Database - Complete Guide

## Overview

**One database to rule them all!** This PostgreSQL database connects every aspect of your business:

```
┌─────────────────────────────────────────────────────────────┐
│                    UNIVERSAL CRM DATABASE                    │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   LinkedIn   │  │     Job      │  │    Moodle    │      │
│  │    Leads     │  │  Applications│  │   Training   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │               │
│         └─────────────────┼─────────────────┘               │
│                           │                                 │
│         ┌─────────────────┴─────────────────┐               │
│         │      ORGANIZATIONS & PEOPLE        │               │
│         └─────────────────┬─────────────────┘               │
│                           │                                 │
│         ┌─────────────────┴─────────────────┐               │
│         │                                   │               │
│  ┌──────┴───────┐              ┌───────────┴──────┐        │
│  │  Consulting  │              │  Infrastructure  │        │
│  │   Projects   │              │  VMs & Services  │        │
│  └──────────────┘              └──────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Real-World Example

**Scenario**: You find a lead, they become a client, train their team, and deploy infrastructure.

### Step 1: Find Lead on LinkedIn
```bash
./search-leads.sh
# Find "Jane Doe - CTO at HealthTech Inc"
# Fit score: 9/10
```

**Database stores**:
- Organization: HealthTech Inc (healthcare, 200 employees)
- Person: Jane Doe (CTO, high fit score)
- Lead: Status = "new", Source = LinkedIn search

### Step 2: Send Outreach
```bash
python3 lead_generation_engine.py outreach jane_doe_id inmail
```

**Database stores**:
- Outreach message (InMail sent on 2025-11-04)
- Interaction logged (outbound, InMail)

### Step 3: Jane Responds - Schedule Call
**Database stores**:
- Lead status updated: "new" → "contacted"
- Interaction: Response received (positive sentiment)
- Interaction: Discovery call scheduled

### Step 4: Win Project
```bash
python3 crm_database.py add-project \
  --client "HealthTech Inc" \
  --name "MLOps Platform Migration" \
  --value 75000
```

**Database stores**:
- Consulting project created
- Organization stage: "lead" → "client"
- Contract value: $75,000

### Step 5: Train Their Team in Moodle
**Database stores** (auto-synced from Moodle):
- 5 employees from HealthTech enrolled in "Data Engineering" course
- Links people → organization → project
- Training completion tracked

### Step 6: Deploy Infrastructure
**Database stores**:
- VM created (ProxmoxMCP ID: 159)
- Database instance for HealthTech
- Services linked to project & organization
- Access credentials tracked

### Step 7: Future Opportunities
**Query the CRM**:
```sql
-- Who are our warmest leads right now?
SELECT * FROM active_leads_view WHERE fit_score >= 8;

-- Which clients have trained employees?
SELECT * FROM client_summary_view WHERE trained_employees > 0;

-- Show me companies I contacted but haven't followed up in 2 weeks
SELECT o.name, p.full_name, MAX(i.interaction_date) as last_contact
FROM organizations o
JOIN people p ON o.id = p.organization_id
JOIN interactions i ON p.id = i.person_id
WHERE o.relationship_stage = 'prospect'
GROUP BY o.name, p.full_name
HAVING MAX(i.interaction_date) < NOW() - INTERVAL '14 days';
```

**The power**: When HealthTech needs help again next year, you know:
- Who their CTO is (Jane)
- What project you did ($75k MLOps migration)
- Which 5 employees you trained
- What infrastructure you deployed
- Complete interaction history

## 📊 Database Schema

### Core Tables

#### `organizations`
**Every company you interact with** (leads, clients, employers, partners)

Key fields:
- `name`, `domain`, `linkedin_url`, `website`
- `relationship_stage`: lead → prospect → client → partner
- `industry`, `employee_count`
- `source`: linkedin, moodle, referral, job_board
- `moodle_organization_id`: Link to training clients
- `technology_stack`: What technologies they use
- `pain_points`: Problems you can solve

#### `people`
**Every person** (leads, clients, hiring managers, students)

Key fields:
- `organization_id`: Which company
- `full_name`, `email`, `job_title`
- `linkedin_url`, `moodle_user_id`
- `relationship_stage`: cold → warm → engaged → client
- `fit_score` (1-10), `engagement_score` (1-10)
- `next_follow_up_date`: Never miss a follow-up!

### Lead Generation

#### `leads`
LinkedIn prospects and business development leads

Key fields:
- `person_id`, `organization_id`
- `lead_status`: new → contacted → qualified → converted
- `fit_score` (1-10): How well they match your services
- `outreach_status`: connection_sent → connected → messaged
- `pain_points_identified`: Their specific problems
- `relevant_capabilities`: Your services that match

#### `outreach_messages`
Every message sent (connection requests, InMail, emails)

Tracks:
- Message type & content
- Sent/delivered/opened/replied status
- Response sentiment
- Full conversation history

### Job Search

#### `job_opportunities`
Jobs you're interested in

Fields:
- `title`, `description`, `location`
- `salary_range_min/max`
- `required_skills`, `preferred_skills`
- `posting_url`, `job_board`
- `fit_score`: How well it matches you

#### `job_applications`
Track every application

Fields:
- `application_status`: submitted → screening → interview → offer
- `resume_version`: Which resume you sent
- `phone_screen_date`, `technical_interview_date`
- `recruiter_person_id`, `hiring_manager_person_id`
- `next_follow_up_date`
- `offer_amount`, `rejection_reason`

### Consulting Business

#### `consulting_projects`
Client engagements

Fields:
- `organization_id`: The client
- `project_name`, `project_type`, `description`
- `start_date`, `end_date`, `status`
- `contract_value`, `payment_terms`
- `deliverables[]`, `success_metrics[]`

#### `project_contacts`
Links people to projects (stakeholders, technical leads)

#### `project_milestones`
Track deliverables and deadlines

### Training Platform

#### `moodle_courses`
Courses on moodle.simondatalab.de

Synced from Moodle API:
- Course name, enrollments, completion rate
- Links to business relationships

#### `moodle_enrollments`
Who took which courses

**The magic**: Links students → people → organizations → projects

Example: When someone from a company takes your course, you can:
1. See if they're a lead (upsell opportunity!)
2. Track engagement for consulting proposals
3. Build relationship history

### Infrastructure

#### `infrastructure_services`
VMs, databases, apps you deploy

Fields:
- `service_name`, `service_type`, `description`
- `vm_id`: ProxmoxMCP VM ID (e.g., 159)
- `hostname`, `ip_address`, `port`
- `organization_id`: Client-specific services
- `project_id`: Project deployments
- `access_url`, `admin_credentials_location`

#### `service_users`
Who has access to what

Tracks:
- User → Service mapping
- Access levels (admin, user, readonly)
- Grant/revoke dates

### Activity Tracking

#### `interactions`
**Every touchpoint** (emails, calls, meetings, LinkedIn messages)

Fields:
- `person_id`, `organization_id`
- `interaction_type`: email, call, meeting, linkedin_message
- `direction`: inbound/outbound
- `subject`, `notes`, `outcome`
- `interaction_date`, `duration_minutes`
- Links to related leads/projects/jobs

**Automatic tracking**: Updates `last_contact_date` on people & orgs

### Analytics

#### `daily_metrics`
Business KPIs tracked daily

Tracks:
- New leads, outreach sent, responses
- Job applications, interviews, offers
- Opportunities, proposals, contracts
- Moodle enrollments, completions

## 🚀 Quick Start

### Step 1: Install Database
```bash
cd /home/simon/Learning-Management-System-Academy/linkedin-automation
./setup-crm-database.sh
```

This will:
1. Install PostgreSQL
2. Create `universal_crm` database
3. Create all tables and views
4. Install Python dependencies

### Step 2: Import LinkedIn Leads
```bash
# After running batch lead search
python3 crm_database.py import-leads

# Or specify file
python3 crm_database.py import-leads outputs/batch_searches/batch_search_20251104_all_leads.json
```

### Step 3: View Dashboard
```bash
python3 crm_database.py dashboard
```

Shows:
- Lead pipeline summary
- Top organizations
- Job application status
- Recent interactions

## 📊 Common Queries

### Find Hot Leads
```sql
SELECT 
    p.full_name,
    p.job_title,
    o.name as company,
    l.fit_score,
    l.lead_status,
    l.outreach_status
FROM leads l
JOIN people p ON l.person_id = p.id
JOIN organizations o ON l.organization_id = o.id
WHERE l.fit_score >= 8
  AND l.lead_status NOT IN ('lost', 'converted')
ORDER BY l.fit_score DESC, l.created_at DESC;
```

### Who Needs Follow-Up?
```sql
SELECT 
    p.full_name,
    p.job_title,
    o.name as company,
    p.next_follow_up_date,
    p.relationship_stage
FROM people p
JOIN organizations o ON p.organization_id = o.id
WHERE p.next_follow_up_date <= NOW() + INTERVAL '3 days'
  AND p.relationship_stage IN ('warm', 'engaged')
ORDER BY p.next_follow_up_date;
```

### Client Revenue Summary
```sql
SELECT 
    o.name as client,
    COUNT(DISTINCT cp.id) as projects,
    SUM(cp.contract_value) as total_revenue,
    COUNT(DISTINCT me.person_id) as employees_trained
FROM organizations o
JOIN consulting_projects cp ON o.id = cp.organization_id
LEFT JOIN moodle_enrollments me ON o.id = me.organization_id
WHERE o.relationship_stage = 'client'
GROUP BY o.name
ORDER BY total_revenue DESC;
```

### Job Application Pipeline
```sql
SELECT 
    ja.application_status,
    COUNT(*) as count,
    AVG(jo.fit_score) as avg_fit_score
FROM job_applications ja
JOIN job_opportunities jo ON ja.job_opportunity_id = jo.id
GROUP BY ja.application_status
ORDER BY count DESC;
```

### Infrastructure by Client
```sql
SELECT 
    o.name as client,
    COUNT(DISTINCT is.id) as services,
    string_agg(DISTINCT is.service_type, ', ') as service_types,
    COUNT(DISTINCT su.person_id) as users
FROM organizations o
JOIN infrastructure_services is ON o.id = is.organization_id
LEFT JOIN service_users su ON is.id = su.service_id
WHERE is.status = 'active'
GROUP BY o.name
ORDER BY services DESC;
```

## 🔄 Integrations

### Automatic LinkedIn Import
When you run `batch_lead_search.py`, leads are automatically imported to CRM.

### Moodle Sync (Coming Soon)
```bash
python3 crm_database.py import-moodle
```

Will sync:
- All courses from moodle.simondatalab.de
- Student enrollments
- Link students to organizations
- Track completion rates

### ProxmoxMCP Integration (Coming Soon)
Automatically track VMs and services deployed for clients.

## 📈 Workflows

### Daily Lead Generation
```bash
# Morning: Find new leads
./search-leads.sh

# Automatic import to CRM ✓

# Review top prospects
psql universal_crm -c "SELECT * FROM active_leads_view LIMIT 20;"

# Send outreach (manual for now)
python3 lead_generation_engine.py outreach <lead_id> inmail
```

### Weekly Business Review
```bash
python3 crm_database.py dashboard

# Or query directly
psql universal_crm -c "
SELECT 
    metric_date,
    new_leads_count,
    outreach_sent_count,
    responses_received_count,
    applications_submitted,
    opportunities_created
FROM daily_metrics
WHERE metric_date >= NOW() - INTERVAL '7 days'
ORDER BY metric_date;
"
```

### Monthly Client Check-In
```sql
-- Clients we haven't contacted in 30 days
SELECT 
    o.name,
    o.last_contact_date,
    NOW() - o.last_contact_date as days_since_contact
FROM organizations o
WHERE o.relationship_stage = 'client'
  AND (o.last_contact_date IS NULL OR o.last_contact_date < NOW() - INTERVAL '30 days')
ORDER BY o.last_contact_date NULLS FIRST;
```

## 🎯 Advanced Features

### Automatic Triggers

**Last Contact Date**: Automatically updated when you log interactions

**Relationship Progression**: Track lead → prospect → client journey

**Follow-Up Reminders**: Set `next_follow_up_date` on people

### Views for Quick Insights

**`active_leads_view`**: Hot leads with full context

**`active_applications_view`**: Job search pipeline

**`client_summary_view`**: Revenue and engagement per client

### Data Integrity

- **Unique constraints**: No duplicate LinkedIn URLs or emails
- **Foreign keys**: All relationships enforced
- **Check constraints**: Fit scores always 1-10
- **Automatic timestamps**: Created/updated tracked automatically

## 🔧 Maintenance

### Backup Database
```bash
pg_dump universal_crm > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
psql universal_crm < backup_20251104.sql
```

### View Schema
```bash
psql universal_crm -c "\dt"  # List tables
psql universal_crm -c "\d+ organizations"  # Describe table
```

## 🚀 Next Steps

1. **Run setup**: `./setup-crm-database.sh`
2. **Import leads**: `python3 crm_database.py import-leads`
3. **View dashboard**: `python3 crm_database.py dashboard`
4. **Explore**: `psql universal_crm`

**The CRM grows with you!** Every lead, job, project, and interaction builds a comprehensive business intelligence system.

---

**Questions? Run**: `python3 crm_database.py --help`
