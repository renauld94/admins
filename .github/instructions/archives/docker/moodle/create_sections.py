import requests

# --- CONFIGURATION ---
MOODLE_URL = "http://localhost:8080"
TOKEN = "02ca4b0286043344eb20d1779a7b9d3f"
COURSE_ID = 3


# List of modules and sessions as (module_number, module_name, session_title)
modules_sessions = [
    (1, "System Setup", "Session 1.1: Welcome & Introduction"),
    (1, "System Setup", "Session 1.2: Installing Python"),
    (1, "System Setup", "Session 1.3: Installing Jupyter Notebooks"),
    (1, "System Setup", "Session 1.4: Installing Git and Bitbucket"),
    (1, "System Setup", "Session 1.5: Installing PySpark"),
    (1, "System Setup", "Session 1.6: Setting Up Virtual Environments"),
    (1, "System Setup", "Session 1.7: Configuring Environment Variables"),
    (1, "System Setup", "Session 1.8: Testing the Setup"),
    (1, "System Setup", "Session 1.9: Accessing Learning Resources"),
    (2, "Core Python", "Session 2.1: Welcome & Introduction"),
    (2, "Core Python", "Session 2.2: Python Basics (Variables, Types, Ops)"),
    (2, "Core Python", "Session 2.3: Control Structures (If, Loops)"),
    (2, "Core Python", "Session 2.4: Functions and Modules"),
    (2, "Core Python", "Session 2.5: Data Structures"),
    (2, "Core Python", "Session 2.6: File I/O"),
    (2, "Core Python", "Session 2.7: Error and Exception Handling"),
    (2, "Core Python", "Session 2.8: Regular Expressions"),
    (2, "Core Python", "Session 2.9: Classes and OOP"),
    (2, "Core Python", "Session 2.10: Decorators"),
    (2, "Core Python", "Session 2.11: Virtual Environments"),
    (2, "Core Python", "Session 2.12: Context Managers"),
    (2, "Core Python", "Session 2.13: Iterators and Generators"),
    (2, "Core Python", "Session 2.14: String Processing"),
    (2, "Core Python", "Session 2.15: APIs and JSON"),
    (3, "PySpark", "Session 3.1: Welcome & Introduction"),
    (3, "PySpark", "Session 3.2: Setting Up PySpark"),
    (3, "PySpark", "Session 3.3: SparkSession and SparkContext"),
    (3, "PySpark", "Session 3.4: RDD Fundamentals"),
    (3, "PySpark", "Session 3.5: DataFrames Basics"),
    (3, "PySpark", "Session 3.6: DataFrame Operations"),
    (3, "PySpark", "Session 3.7: PySpark SQL"),
    (3, "PySpark", "Session 3.8: User Defined Functions (UDFs)"),
    (3, "PySpark", "Session 3.9: Working with Dates and Timestamps"),
    (3, "PySpark", "Session 3.10: Window Functions"),
    (3, "PySpark", "Session 3.11: Reading and Writing Data"),
    (3, "PySpark", "Session 3.12: Performance Tuning Basics"),
    (3, "PySpark", "Session 3.13: Error Handling and Debugging"),
    (3, "PySpark", "Session 3.14: Practical Exercises"),
    (4, "Git/Bitbucket", "Session 4.1: Welcome & Introduction"),
    (4, "Git/Bitbucket", "Session 4.2: Introduction to Version Control"),
    (4, "Git/Bitbucket", "Session 4.3: Git Basics and Workflow"),
    (4, "Git/Bitbucket", "Session 4.4: Working with Bitbucket"),
    (4, "Git/Bitbucket", "Session 4.5: Branching and Merging"),
    (4, "Git/Bitbucket", "Session 4.6: Collaboration and Pull Requests"),
    (4, "Git/Bitbucket", "Session 4.7: Resolving Conflicts"),
    (4, "Git/Bitbucket", "Session 4.8: Best Practices"),
    (5, "Databricks", "Session 5.1: Welcome & Introduction"),
    (5, "Databricks", "Session 5.2: Introduction to Databricks"),
    (5, "Databricks", "Session 5.3: Setting Up a Workspace"),
    (5, "Databricks", "Session 5.4: Running Notebooks"),
    (5, "Databricks", "Session 5.5: Integrating with PySpark"),
    (5, "Databricks", "Session 5.6: Databricks Utilities"),
    (5, "Databricks", "Session 5.7: Job Scheduling"),
    (5, "Databricks", "Session 5.8: Best Practices"),
    (6, "Advanced", "Session 6.1: Welcome & Introduction"),
    (6, "Advanced", "Session 6.2: Advanced Python Concepts"),
    (6, "Advanced", "Session 6.3: Advanced PySpark Techniques"),
    (6, "Advanced", "Session 6.4: Performance Optimization"),
    (6, "Advanced", "Session 6.5: Real-world Data Pipelines"),
    (6, "Advanced", "Session 6.6: Testing and Debugging"),
    (6, "Advanced", "Session 6.7: Deployment Strategies"),
    (6, "Advanced", "Session 6.8: Capstone Project"),
]

# Get unique modules in order
unique_modules = []
for mod in modules_sessions:
    if mod[1] not in [m[1] for m in unique_modules]:
        unique_modules.append((mod[0], mod[1]))

# Create sections for each module
def create_sections():
    url = f"{MOODLE_URL}/webservice/rest/server.php"
    for idx, (mod_num, mod_name) in enumerate(unique_modules, start=1):
        params = {
            'wstoken': TOKEN,
            'wsfunction': 'core_course_create_sections',
            'moodlewsrestformat': 'json',
            'sections[0][courseid]': COURSE_ID,
            'sections[0][name]': mod_name,
            'sections[0][section]': idx
        }
        r = requests.post(url, params=params)
        if r.status_code == 200:
            print(f"Created section {idx}: {mod_name}")
        else:
            print(f"Failed to create section {idx}: {mod_name}")
            print(f"Status: {r.status_code}")
            print(f"Response: {r.text}")

# Add each session as a label in the correct section
def add_labels():
    url = f"{MOODLE_URL}/webservice/rest/server.php"
    for idx, (mod_num, mod_name, session_title) in enumerate(modules_sessions, start=1):
        params = {
            'wstoken': TOKEN,
            'wsfunction': 'mod_label_create_labels',
            'moodlewsrestformat': 'json',
            'labels[0][courseid]': COURSE_ID,
            'labels[0][name]': session_title,
            'labels[0][sectionnum]': mod_num  # Section number matches module number
        }
        r = requests.post(url, params=params)
        if r.status_code == 200:
            print(f"Added label to section {mod_num}: {session_title}")
        else:
            print(f"Failed to add label: {session_title}")
            print(f"Status: {r.status_code}")
            print(f"Response: {r.text}")

if __name__ == "__main__":
    create_sections()
    add_labels()
