import os
import csv
import urllib.parse

# Base directory containing your modules and sessions
base_dir = "/home/simon/Desktop/Python_Academy/Python Academy Courses"
# Databricks workspace base URL (edit if your path changes)
dbx_base_url = "https://dbc-cb78cc7d-0514.cloud.databricks.com/workspace/Shared/Python%20Academy%20Courses"

# Output CSV file
output_csv = "/home/simon/Desktop/Python_Academy/modules_sessions.csv"

rows = []

for module in sorted(os.listdir(base_dir)):
    module_path = os.path.join(base_dir, module)
    if os.path.isdir(module_path):
        for session in sorted(os.listdir(module_path)):
            if session.endswith(".ipynb"):
                session_name = os.path.splitext(session)[0]
                # Build the Databricks notebook link
                module_url = urllib.parse.quote(module)
                session_url = urllib.parse.quote(session)
                notebook_link = f"{dbx_base_url}/{module_url}/{session_url.replace('.ipynb','')}"
                rows.append({
                    "module": module,
                    "session": session_name,
                    "notebook_link": notebook_link
                })

# Write to CSV
with open(output_csv, "w", newline='') as csvfile:
    fieldnames = ["module", "session", "notebook_link"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for row in rows:
        writer.writerow(row)

print(f"Dashboard links CSV created at: {output_csv}")