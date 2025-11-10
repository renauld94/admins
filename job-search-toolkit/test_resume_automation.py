#!/usr/bin/env python3
"""Quick test - generate sample resume and cover letter"""

import sys
sys.path.insert(0, "/home/simon/Learning-Management-System-Academy/job-search-toolkit")

from resume_cover_letter_automation import ResumeOptimizer, CoverLetterGenerator
from pathlib import Path

# Sample job description
sample_job = """
Senior Data Engineer - Stripe

We're looking for an experienced Senior Data Engineer to join our data platform team.

Requirements:
- 10+ years of data engineering experience
- Expert-level proficiency in Python and SQL
- Strong experience with Apache Spark and distributed systems
- Kubernetes and containerization expertise
- Experience with real-time data pipelines (Kafka, Flink)
- Leadership and mentoring capabilities

Responsibilities:
- Design and build scalable data infrastructure
- Lead architectural decisions for our data platform
- Mentor junior engineers
- Implement data quality frameworks
"""

sample_company = "Stripe"
sample_role = "Senior Data Engineer"

# Generate optimized resume
print("🔧 OPTIMIZING RESUME...")
optimizer = ResumeOptimizer("")
from resume_cover_letter_automation import BASE_RESUME
optimizer = ResumeOptimizer(BASE_RESUME)
optimized_resume = optimizer.optimize_for_job(sample_job, sample_role)

print("✅ Resume sample (first 600 chars):")
print(optimized_resume[:600])
print("\n...\n")

# Generate cover letter
print("\n📝 GENERATING COVER LETTER...")
generator = CoverLetterGenerator()
cover_letter = generator.generate_cover_letter(1, sample_role, sample_company, sample_job)

print("✅ Cover letter:")
print(cover_letter[:800])
print("\n...\n")

# Save samples
output_dir = Path("outputs/applications")
output_dir.mkdir(parents=True, exist_ok=True)

resume_file = output_dir / "SAMPLE_RESUME.txt"
resume_file.write_text(optimized_resume)
print(f"\n💾 Resume saved to: {resume_file}")

cover_file = output_dir / "SAMPLE_COVER_LETTER.txt"
cover_file.write_text(cover_letter)
print(f"💾 Cover letter saved to: {cover_file}")

print("\n✨ Sample generation complete!")
