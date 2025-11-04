"""
Universal CRM Database Schema
Unified data model connecting:
- Lead generation (LinkedIn, job boards)
- Moodle training platform (students, courses)
- Consulting projects (clients, engagements)
- Infrastructure (VMs, databases, services)
- Job applications tracking
"""

-- ============================================================================
-- CORE ENTITIES: Organizations & People
-- ============================================================================

CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255), -- company.com
    linkedin_url VARCHAR(500),
    website VARCHAR(500),
    industry VARCHAR(100),
    size_category VARCHAR(50), -- startup, small, medium, enterprise
    employee_count INTEGER,
    headquarters_location VARCHAR(255),
    description TEXT,
    
    -- Relationship tracking
    relationship_stage VARCHAR(50), -- lead, prospect, client, partner, alumni
    first_contact_date TIMESTAMP,
    last_contact_date TIMESTAMP,
    
    -- Business potential
    annual_revenue_estimate DECIMAL(15,2),
    technology_stack TEXT[], -- Array of technologies they use
    pain_points TEXT[],
    
    -- Source tracking
    source VARCHAR(100), -- linkedin, moodle, referral, job_board
    source_details JSONB, -- Flexible metadata
    
    -- Integration IDs
    moodle_organization_id INTEGER, -- If they're a Moodle training client
    linkedin_company_id VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    UNIQUE(domain),
    UNIQUE(linkedin_url)
);

CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    
    -- Identity
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    
    -- Professional info
    job_title VARCHAR(255),
    department VARCHAR(100),
    seniority_level VARCHAR(50), -- IC, manager, director, vp, c-level
    linkedin_url VARCHAR(500),
    
    -- Contact tracking
    relationship_stage VARCHAR(50), -- cold, warm, engaged, client, advocate
    first_contact_date TIMESTAMP,
    last_contact_date TIMESTAMP,
    next_follow_up_date TIMESTAMP,
    
    -- Lead scoring
    fit_score INTEGER CHECK (fit_score BETWEEN 1 AND 10),
    engagement_score INTEGER CHECK (engagement_score BETWEEN 1 AND 10),
    
    -- Integration IDs
    moodle_user_id INTEGER, -- If they're enrolled in courses
    linkedin_profile_id VARCHAR(100),
    
    -- Source
    source VARCHAR(100),
    source_details JSONB,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    UNIQUE(email),
    UNIQUE(linkedin_url)
);

CREATE INDEX idx_people_org ON people(organization_id);
CREATE INDEX idx_people_email ON people(email);
CREATE INDEX idx_people_relationship ON people(relationship_stage);

-- ============================================================================
-- LEAD GENERATION & OUTREACH
-- ============================================================================

CREATE TABLE leads (
    id SERIAL PRIMARY KEY,
    person_id INTEGER REFERENCES people(id),
    organization_id INTEGER REFERENCES organizations(id),
    
    -- Lead details
    lead_status VARCHAR(50), -- new, contacted, qualified, unqualified, converted, lost
    lead_source VARCHAR(100), -- linkedin_search, company_page, referral, inbound
    search_query VARCHAR(255), -- Original search that found them
    search_location VARCHAR(255),
    
    -- Qualification
    fit_score INTEGER CHECK (fit_score BETWEEN 1 AND 10),
    qualification_notes TEXT,
    pain_points_identified TEXT[],
    relevant_capabilities TEXT[], -- Which of our services match their needs
    
    -- Outreach tracking
    outreach_status VARCHAR(50), -- not_contacted, connection_sent, connected, messaged, replied
    connection_request_sent_date TIMESTAMP,
    connection_accepted_date TIMESTAMP,
    first_message_sent_date TIMESTAMP,
    first_reply_received_date TIMESTAMP,
    
    -- Conversion
    converted_to_opportunity BOOLEAN DEFAULT FALSE,
    converted_date TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE outreach_messages (
    id SERIAL PRIMARY KEY,
    lead_id INTEGER REFERENCES leads(id),
    person_id INTEGER REFERENCES people(id),
    
    -- Message details
    message_type VARCHAR(50), -- connection_request, inmail, email, linkedin_comment
    subject VARCHAR(255),
    body TEXT,
    
    -- Delivery
    sent_date TIMESTAMP,
    delivered BOOLEAN DEFAULT FALSE,
    opened BOOLEAN DEFAULT FALSE,
    clicked BOOLEAN DEFAULT FALSE,
    replied BOOLEAN DEFAULT FALSE,
    
    -- Response tracking
    response_text TEXT,
    response_date TIMESTAMP,
    sentiment VARCHAR(50), -- positive, neutral, negative
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- JOB APPLICATIONS TRACKING
-- ============================================================================

CREATE TABLE job_opportunities (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    
    -- Job details
    title VARCHAR(255),
    description TEXT,
    location VARCHAR(255),
    remote_policy VARCHAR(50), -- remote, hybrid, onsite
    salary_range_min DECIMAL(10,2),
    salary_range_max DECIMAL(10,2),
    salary_currency VARCHAR(10) DEFAULT 'USD',
    
    -- Requirements
    required_skills TEXT[],
    preferred_skills TEXT[],
    years_experience_required INTEGER,
    
    -- Job posting
    posting_url VARCHAR(500),
    job_board VARCHAR(100), -- linkedin, indeed, company_site
    posted_date DATE,
    application_deadline DATE,
    
    -- Tracking
    status VARCHAR(50), -- active, applied, expired, filled
    fit_score INTEGER CHECK (fit_score BETWEEN 1 AND 10),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE job_applications (
    id SERIAL PRIMARY KEY,
    job_opportunity_id INTEGER REFERENCES job_opportunities(id),
    organization_id INTEGER REFERENCES organizations(id),
    
    -- Application tracking
    application_status VARCHAR(50), -- draft, submitted, screening, interview, offer, rejected, accepted, declined
    application_date TIMESTAMP,
    
    -- Documents
    resume_version VARCHAR(100), -- Which resume version was used
    cover_letter_path VARCHAR(500),
    portfolio_links TEXT[],
    
    -- Interview tracking
    phone_screen_date TIMESTAMP,
    technical_interview_date TIMESTAMP,
    final_interview_date TIMESTAMP,
    
    -- Contacts
    recruiter_person_id INTEGER REFERENCES people(id),
    hiring_manager_person_id INTEGER REFERENCES people(id),
    
    -- Follow-ups
    last_follow_up_date TIMESTAMP,
    next_follow_up_date TIMESTAMP,
    follow_up_count INTEGER DEFAULT 0,
    
    -- Outcome
    offer_received BOOLEAN DEFAULT FALSE,
    offer_amount DECIMAL(10,2),
    offer_date TIMESTAMP,
    rejection_reason TEXT,
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- CONSULTING PROJECTS & ENGAGEMENTS
-- ============================================================================

CREATE TABLE consulting_projects (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id) NOT NULL,
    
    -- Project details
    project_name VARCHAR(255),
    project_type VARCHAR(100), -- data_engineering, mlops, analytics, training
    description TEXT,
    
    -- Timeline
    start_date DATE,
    end_date DATE,
    estimated_duration_weeks INTEGER,
    status VARCHAR(50), -- planning, active, paused, completed, cancelled
    
    -- Commercial
    contract_value DECIMAL(15,2),
    currency VARCHAR(10) DEFAULT 'USD',
    payment_terms VARCHAR(100),
    
    -- Deliverables
    deliverables TEXT[],
    success_metrics TEXT[],
    
    -- Team
    primary_contact_id INTEGER REFERENCES people(id),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE project_contacts (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES consulting_projects(id),
    person_id INTEGER REFERENCES people(id),
    role VARCHAR(100), -- stakeholder, technical_lead, decision_maker, end_user
    
    UNIQUE(project_id, person_id)
);

CREATE TABLE project_milestones (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES consulting_projects(id),
    
    milestone_name VARCHAR(255),
    description TEXT,
    due_date DATE,
    completed_date DATE,
    status VARCHAR(50), -- pending, in_progress, completed, blocked
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MOODLE INTEGRATION
-- ============================================================================

CREATE TABLE moodle_courses (
    id SERIAL PRIMARY KEY,
    moodle_course_id INTEGER UNIQUE,
    
    course_name VARCHAR(255),
    category VARCHAR(100),
    description TEXT,
    url VARCHAR(500),
    
    -- Tracking
    total_enrollments INTEGER DEFAULT 0,
    active_enrollments INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE moodle_enrollments (
    id SERIAL PRIMARY KEY,
    person_id INTEGER REFERENCES people(id),
    organization_id INTEGER REFERENCES organizations(id),
    course_id INTEGER REFERENCES moodle_courses(id),
    
    moodle_user_id INTEGER,
    enrollment_date TIMESTAMP,
    completion_date TIMESTAMP,
    progress_percentage INTEGER,
    final_grade DECIMAL(5,2),
    
    -- Business connection
    related_project_id INTEGER REFERENCES consulting_projects(id),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- INFRASTRUCTURE TRACKING
-- ============================================================================

CREATE TABLE infrastructure_services (
    id SERIAL PRIMARY KEY,
    
    -- Service details
    service_name VARCHAR(255),
    service_type VARCHAR(100), -- vm, database, app, monitoring
    description TEXT,
    
    -- Infrastructure
    vm_name VARCHAR(100),
    vm_id INTEGER, -- ProxmoxMCP VM ID
    hostname VARCHAR(255),
    ip_address VARCHAR(50),
    port INTEGER,
    
    -- Client relationship
    organization_id INTEGER REFERENCES organizations(id), -- If client-specific
    project_id INTEGER REFERENCES consulting_projects(id), -- If project-specific
    
    -- Status
    status VARCHAR(50), -- active, inactive, maintenance
    environment VARCHAR(50), -- dev, staging, production
    
    -- Resources
    cpu_cores INTEGER,
    ram_gb INTEGER,
    storage_gb INTEGER,
    
    -- Access
    access_url VARCHAR(500),
    admin_credentials_location VARCHAR(255), -- Path to secrets vault
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE service_users (
    id SERIAL PRIMARY KEY,
    service_id INTEGER REFERENCES infrastructure_services(id),
    person_id INTEGER REFERENCES people(id),
    
    username VARCHAR(100),
    access_level VARCHAR(50), -- admin, user, readonly
    granted_date TIMESTAMP DEFAULT NOW(),
    revoked_date TIMESTAMP,
    
    UNIQUE(service_id, username)
);

-- ============================================================================
-- INTERACTIONS & ACTIVITIES
-- ============================================================================

CREATE TABLE interactions (
    id SERIAL PRIMARY KEY,
    person_id INTEGER REFERENCES people(id),
    organization_id INTEGER REFERENCES organizations(id),
    
    -- Interaction details
    interaction_type VARCHAR(100), -- email, call, meeting, linkedin_message, linkedin_comment
    direction VARCHAR(20), -- inbound, outbound
    subject VARCHAR(255),
    notes TEXT,
    
    -- Outcome
    outcome VARCHAR(100), -- positive, neutral, negative, no_response
    next_action VARCHAR(255),
    
    -- Scheduling
    interaction_date TIMESTAMP DEFAULT NOW(),
    duration_minutes INTEGER,
    
    -- Relations
    related_lead_id INTEGER REFERENCES leads(id),
    related_project_id INTEGER REFERENCES consulting_projects(id),
    related_job_id INTEGER REFERENCES job_applications(id),
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_interactions_person ON interactions(person_id);
CREATE INDEX idx_interactions_org ON interactions(organization_id);
CREATE INDEX idx_interactions_date ON interactions(interaction_date);

-- ============================================================================
-- ANALYTICS & METRICS
-- ============================================================================

CREATE TABLE daily_metrics (
    id SERIAL PRIMARY KEY,
    metric_date DATE UNIQUE,
    
    -- Lead generation
    new_leads_count INTEGER DEFAULT 0,
    outreach_sent_count INTEGER DEFAULT 0,
    responses_received_count INTEGER DEFAULT 0,
    
    -- Job search
    applications_submitted INTEGER DEFAULT 0,
    interviews_scheduled INTEGER DEFAULT 0,
    offers_received INTEGER DEFAULT 0,
    
    -- Business development
    opportunities_created INTEGER DEFAULT 0,
    proposals_sent INTEGER DEFAULT 0,
    contracts_signed INTEGER DEFAULT 0,
    
    -- Training
    new_moodle_enrollments INTEGER DEFAULT 0,
    courses_completed INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- UTILITY VIEWS
-- ============================================================================

-- Active leads with full context
CREATE VIEW active_leads_view AS
SELECT 
    l.id,
    l.lead_status,
    l.fit_score,
    p.full_name as person_name,
    p.job_title,
    p.email,
    o.name as organization_name,
    o.industry,
    o.relationship_stage,
    l.outreach_status,
    l.created_at as lead_created_at,
    (SELECT COUNT(*) FROM outreach_messages om WHERE om.lead_id = l.id) as message_count,
    (SELECT MAX(sent_date) FROM outreach_messages om WHERE om.lead_id = l.id) as last_message_date
FROM leads l
LEFT JOIN people p ON l.person_id = p.id
LEFT JOIN organizations o ON l.organization_id = o.id
WHERE l.lead_status NOT IN ('lost', 'converted')
ORDER BY l.fit_score DESC, l.created_at DESC;

-- Active job applications
CREATE VIEW active_applications_view AS
SELECT
    ja.id,
    ja.application_status,
    jo.title as job_title,
    o.name as company_name,
    jo.location,
    jo.salary_range_min,
    jo.salary_range_max,
    ja.application_date,
    ja.next_follow_up_date,
    jo.fit_score
FROM job_applications ja
JOIN job_opportunities jo ON ja.job_opportunity_id = jo.id
LEFT JOIN organizations o ON jo.organization_id = o.id
WHERE ja.application_status NOT IN ('rejected', 'accepted', 'declined')
ORDER BY ja.next_follow_up_date ASC;

-- Client relationship summary
CREATE VIEW client_summary_view AS
SELECT
    o.id,
    o.name,
    o.industry,
    o.relationship_stage,
    COUNT(DISTINCT cp.id) as project_count,
    SUM(cp.contract_value) as total_contract_value,
    COUNT(DISTINCT me.person_id) as trained_employees,
    COUNT(DISTINCT p.id) as total_contacts,
    MAX(i.interaction_date) as last_interaction_date
FROM organizations o
LEFT JOIN consulting_projects cp ON o.id = cp.organization_id
LEFT JOIN moodle_enrollments me ON o.id = me.organization_id
LEFT JOIN people p ON o.id = p.organization_id
LEFT JOIN interactions i ON o.id = i.organization_id
WHERE o.relationship_stage IN ('client', 'prospect')
GROUP BY o.id, o.name, o.industry, o.relationship_stage
ORDER BY total_contract_value DESC NULLS LAST;

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================================

-- Update organization.last_contact_date when interaction is added
CREATE OR REPLACE FUNCTION update_last_contact_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.organization_id IS NOT NULL THEN
        UPDATE organizations
        SET last_contact_date = NEW.interaction_date,
            updated_at = NOW()
        WHERE id = NEW.organization_id;
    END IF;
    
    IF NEW.person_id IS NOT NULL THEN
        UPDATE people
        SET last_contact_date = NEW.interaction_date,
            updated_at = NOW()
        WHERE id = NEW.person_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_last_contact
AFTER INSERT ON interactions
FOR EACH ROW
EXECUTE FUNCTION update_last_contact_date();

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_organizations_modtime BEFORE UPDATE ON organizations
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_people_modtime BEFORE UPDATE ON people
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_leads_modtime BEFORE UPDATE ON leads
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ============================================================================
-- INITIAL DATA - Example records
-- ============================================================================

-- Insert example organization
INSERT INTO organizations (name, domain, industry, relationship_stage, source)
VALUES ('Example Healthcare Corp', 'example-health.com', 'Healthcare', 'lead', 'linkedin')
ON CONFLICT (domain) DO NOTHING;

-- Create indexes for performance
CREATE INDEX idx_orgs_relationship ON organizations(relationship_stage);
CREATE INDEX idx_orgs_industry ON organizations(industry);
CREATE INDEX idx_leads_status ON leads(lead_status);
CREATE INDEX idx_jobs_status ON job_applications(application_status);
CREATE INDEX idx_projects_status ON consulting_projects(status);

COMMENT ON TABLE organizations IS 'Central registry of all companies (leads, clients, employers)';
COMMENT ON TABLE people IS 'All contacts across all contexts (leads, employees, hiring managers)';
COMMENT ON TABLE leads IS 'Business development leads from LinkedIn and other sources';
COMMENT ON TABLE job_applications IS 'Job search tracking';
COMMENT ON TABLE consulting_projects IS 'Client engagements and deliverables';
COMMENT ON TABLE moodle_enrollments IS 'Training platform data linked to business relationships';
COMMENT ON TABLE infrastructure_services IS 'VMs, databases, and services mapped to clients/projects';
