# Databricks notebook source
# MAGIC %md
# MAGIC # Session 1.1: Welcome & Introduction
# MAGIC ## Johnson & Johnson Python Academy
# MAGIC 
# MAGIC **Instructor:** Simon Renauld  
# MAGIC **Duration:** 7 minutes  
# MAGIC **Module:** System Setup  
# MAGIC 
# MAGIC ### Learning Objectives
# MAGIC - Understand the clinical programming learning path
# MAGIC - Navigate Databricks for healthcare data processing
# MAGIC - Connect with the global J&J clinical programming community
# MAGIC - Establish professional development expectations

# COMMAND ----------

# MAGIC %md
# MAGIC ## Welcome to Professional Clinical Programming
# MAGIC 
# MAGIC This notebook serves as your introduction to the Johnson & Johnson Python Academy, specifically designed for clinical programming professionals working with large-scale healthcare data.
# MAGIC 
# MAGIC ### Program Scope
# MAGIC - **Target Audience:** 300+ clinical programming staff (J&J and vendors)
# MAGIC - **Global Reach:** Online/remote delivery worldwide
# MAGIC - **Focus:** Python fundamentals leading to PySpark mastery
# MAGIC - **Platform:** Databricks for hands-on clinical data processing

# COMMAND ----------

print("=== Johnson & Johnson Python Academy ===")
print("Welcome to professional clinical programming training")
print(f"Instructor: Simon Renauld")
print(f"Platform: Databricks")
print(f"Focus: Python + PySpark for Clinical Data")
print("=" * 50)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Environment Verification
# MAGIC 
# MAGIC Let's verify that your Databricks environment is ready for clinical programming training:

# COMMAND ----------

import sys
import platform
from datetime import datetime

print("=== Environment Verification ===")
print(f"Python Version: {sys.version}")
print(f"Platform: {platform.platform()}")
print(f"Session Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

# Test basic functionality
test_data = ["Clinical", "Programming", "Python", "PySpark"]
print(f"Basic Python Test: {', '.join(test_data)}")

print("✅ Environment ready for clinical programming training")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Program Structure Overview
# MAGIC 
# MAGIC The academy consists of six progressive modules:

# COMMAND ----------

modules = [
    {"name": "System Setup", "duration": "1 hour", "sessions": 9, "focus": "Development environment"},
    {"name": "Core Python", "duration": "2 hours", "sessions": 15, "focus": "Python fundamentals"},
    {"name": "PySpark", "duration": "1.5 hours", "sessions": 14, "focus": "Distributed computing"},
    {"name": "Git/Bitbucket", "duration": "1 hour", "sessions": 8, "focus": "Version control"},
    {"name": "Databricks", "duration": "1.5 hours", "sessions": 8, "focus": "Cloud analytics"},
    {"name": "Advanced", "duration": "1 hour", "sessions": 8, "focus": "Data pipelines"}
]

print("=== Johnson & Johnson Python Academy Modules ===")
for i, module in enumerate(modules, 1):
    print(f"Module {i}: {module['name']}")
    print(f"  Duration: {module['duration']}")
    print(f"  Sessions: {module['sessions']}")
    print(f"  Focus: {module['focus']}")
    print()

total_sessions = sum(module['sessions'] for module in modules)
print(f"Total Sessions: {total_sessions}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Clinical Programming Context
# MAGIC 
# MAGIC Understanding why Python and PySpark are essential for modern clinical programming:

# COMMAND ----------

clinical_applications = {
    "Clinical Trial Data Processing": "ETL for multi-site clinical studies",
    "Regulatory Submissions": "Automated generation of clinical study reports",
    "Drug Safety Analysis": "Large-scale adverse event pattern detection",
    "Real-World Evidence": "Population health outcomes research",
    "Healthcare Economics": "Claims data analysis and outcomes studies",
    "Data Quality Management": "Validation and cleansing of clinical datasets"
}

print("=== Clinical Programming Applications ===")
for application, description in clinical_applications.items():
    print(f"• {application}: {description}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Success Criteria
# MAGIC 
# MAGIC By program completion, you will demonstrate proficiency in:

# COMMAND ----------

success_outcomes = [
    "Utilize PySpark for clinical data manipulation within Databricks",
    "Process large-scale clinical datasets efficiently",
    "Implement professional data pipelines for clinical workflows",
    "Apply version control best practices for collaborative programming",
    "Meet J&J compliance requirements for clinical programming",
    "Integrate with existing J&J data infrastructure"
]

print("=== Program Success Outcomes ===")
for i, outcome in enumerate(success_outcomes, 1):
    print(f"{i}. {outcome}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Next Steps
# MAGIC 
# MAGIC Continue to **Session 1.2: Installing Python** to begin building your professional development environment.
# MAGIC 
# MAGIC ### Preparation Checklist
# MAGIC - [ ] Verify access to J&J Databricks workspace
# MAGIC - [ ] Confirm corporate network connectivity
# MAGIC - [ ] Review module overview and learning objectives
# MAGIC - [ ] Join the clinical programming community forums
# MAGIC 
# MAGIC **Ready to transform your clinical programming capabilities?**
