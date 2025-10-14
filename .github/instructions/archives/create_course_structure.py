import os
import nbformat

modules = [
    ("Module 1 - System Setup", [
        "1.1-Welcome-and-Introduction.ipynb",
        "1.2-Installing-Python.ipynb",
        "1.3-Installing-Jupyter-Notebooks.ipynb",
        "1.4-Installing-Git-and-Bitbucket.ipynb",
        "1.5-Installing-PySpark.ipynb",
        "1.6-Setting-Up-Virtual-Environments.ipynb",
        "1.7-Configuring-Environment-Variables.ipynb",
        "1.8-Testing-the-Setup.ipynb",
        "1.9-Accessing-Learning-Resources.ipynb"
    ]),
    ("Module 2 - Core Python", [
        "2.1-Welcome-and-Introduction.ipynb",
        "2.2-Python-Basics-Variables-Types-Ops.ipynb",
        "2.3-Control-Structures-If-Loops.ipynb",
        "2.4-Functions-and-Modules.ipynb",
        "2.5-Data-Structures.ipynb",
        "2.6-File-IO.ipynb",
        "2.7-Error-and-Exception-Handling.ipynb",
        "2.8-Regular-Expressions.ipynb",
        "2.9-Classes-and-OOP.ipynb",
        "2.10-Decorators.ipynb",
        "2.11-Virtual-Environments.ipynb",
        "2.12-Context-Managers.ipynb",
        "2.13-Iterators-and-Generators.ipynb",
        "2.14-String-Processing.ipynb",
        "2.15-APIs-and-JSON.ipynb"
    ]),
    ("Module 3 - PySpark", [
        "3.1-Welcome-and-Introduction.ipynb",
        "3.2-Setting-Up-PySpark.ipynb",
        "3.3-SparkSession-and-SparkContext.ipynb",
        "3.4-RDD-Fundamentals.ipynb",
        "3.5-DataFrames-Basics.ipynb",
        "3.6-DataFrame-Operations.ipynb",
        "3.7-PySpark-SQL.ipynb",
        "3.8-User-Defined-Functions-UDFs.ipynb",
        "3.9-Working-with-Dates-and-Timestamps.ipynb",
        "3.10-Window-Functions.ipynb",
        "3.11-Reading-and-Writing-Data.ipynb",
        "3.12-Performance-Tuning-Basics.ipynb",
        "3.13-Error-Handling-and-Debugging.ipynb",
        "3.14-Practical-Exercises.ipynb"
    ]),
    ("Module 4 - Git Bitbucket", [
        "4.1-Welcome-and-Introduction.ipynb",
        "4.2-Introduction-to-Version-Control.ipynb",
        "4.3-Git-Basics-and-Workflow.ipynb",
        "4.4-Working-with-Bitbucket.ipynb",
        "4.5-Branching-and-Merging.ipynb",
        "4.6-Collaboration-and-Pull-Requests.ipynb",
        "4.7-Resolving-Conflicts.ipynb",
        "4.8-Best-Practices.ipynb"
    ]),
    ("Module 5 - Databricks", [
        "5.1-Welcome-and-Introduction.ipynb",
        "5.2-Introduction-to-Databricks.ipynb",
        "5.3-Setting-Up-a-Workspace.ipynb",
        "5.4-Running-Notebooks.ipynb",
        "5.5-Integrating-with-PySpark.ipynb",
        "5.6-Databricks-Utilities.ipynb",
        "5.7-Job-Scheduling.ipynb",
        "5.8-Best-Practices.ipynb"
    ]),
    ("Module 6 - Advanced", [
        "6.1-Welcome-and-Introduction.ipynb",
        "6.2-Advanced-Python-Concepts.ipynb",
        "6.3-Advanced-PySpark-Techniques.ipynb",
        "6.4-Performance-Optimization.ipynb",
        "6.5-Real-world-Data-Pipelines.ipynb",
        "6.6-Testing-and-Debugging.ipynb",
        "6.7-Deployment-Strategies.ipynb",
        "6.8-Capstone-Project.ipynb"
    ])
]

roots = [
    "/home/simon/Desktop/Python_Academy/Python Academy Courses",
    "/home/simon/Desktop/learning-platform"
]

def create_notebook(path):
    nb = nbformat.v4.new_notebook()
    nb['cells'] = [nbformat.v4.new_markdown_cell(f"# {os.path.splitext(os.path.basename(path))[0].replace('-', ' ')}")]
    with open(path, "w") as f:
        nbformat.write(nb, f)

for root in roots:
    for module_name, files in modules:
        module_path = os.path.join(root, module_name)
        os.makedirs(module_path, exist_ok=True)
        for file in files:
            file_path = os.path.join(module_path, file)
            if not os.path.exists(file_path):
                create_notebook(file_path)

print("All modules and session files created in both target directories.")