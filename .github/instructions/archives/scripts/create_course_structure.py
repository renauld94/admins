import os
import nbformat

modules = {
    "1_System_Setup": [
        "1.1_Welcome_and_Introduction",
        "1.2_Installing_Python",
        "1.3_Installing_Jupyter_Notebooks",
        "1.4_Installing_Git_and_Bitbucket",
        "1.5_Installing_PySpark",
        "1.6_Setting_Up_Virtual_Environments",
        "1.7_Configuring_Environment_Variables",
        "1.8_Testing_the_Setup",
        "1.9_Accessing_Learning_Resources"
    ],
    "2_Core_Python": [
        "2.1_Welcome_and_Introduction",
        "2.2_Python_Basics_Variables_Types_Ops",
        "2.3_Control_Structures_If_Loops",
        "2.4_Functions_and_Modules",
        "2.5_Data_Structures",
        "2.6_File_IO",
        "2.7_Error_and_Exception_Handling",
        "2.8_Regular_Expressions",
        "2.9_Classes_and_OOP",
        "2.10_Decorators",
        "2.11_Virtual_Environments",
        "2.12_Context_Managers",
        "2.13_Iterators_and_Generators",
        "2.14_String_Processing",
        "2.15_APIs_and_JSON"
    ],
    "3_PySpark": [
        "3.1_Welcome_and_Introduction",
        "3.2_Setting_Up_PySpark",
        "3.3_SparkSession_and_SparkContext",
        "3.4_RDD_Fundamentals",
        "3.5_DataFrames_Basics",
        "3.6_DataFrame_Operations",
        "3.7_PySpark_SQL",
        "3.8_User_Defined_Functions_UDFs",
        "3.9_Working_with_Dates_and_Timestamps",
        "3.10_Window_Functions",
        "3.11_Reading_and_Writing_Data",
        "3.12_Performance_Tuning_Basics",
        "3.13_Error_Handling_and_Debugging",
        "3.14_Practical_Exercises"
    ],
    "4_Git_Bitbucket": [
        "4.1_Welcome_and_Introduction",
        "4.2_Introduction_to_Version_Control",
        "4.3_Git_Basics_and_Workflow",
        "4.4_Working_with_Bitbucket",
        "4.5_Branching_and_Merging",
        "4.6_Collaboration_and_Pull_Requests",
        "4.7_Resolving_Conflicts",
        "4.8_Best_Practices"
    ],
    "5_Databricks": [
        "5.1_Welcome_and_Introduction",
        "5.2_Introduction_to_Databricks",
        "5.3_Setting_Up_a_Workspace",
        "5.4_Running_Notebooks",
        "5.5_Integrating_with_PySpark",
        "5.6_Databricks_Utilities",
        "5.7_Job_Scheduling",
        "5.8_Best_Practices"
    ],
    "6_Advanced": [
        "6.1_Welcome_and_Introduction",
        "6.2_Advanced_Python_Concepts",
        "6.3_Advanced_PySpark_Techniques",
        "6.4_Performance_Optimization",
        "6.5_Real_world_Data_Pipelines",
        "6.6_Testing_and_Debugging",
        "6.7_Deployment_Strategies",
        "6.8_Capstone_Project"
    ]
}

roots = [
    "/home/simon/Desktop/Python_Academy/Python Academy Courses",
    "/home/simon/Desktop/learning-platform"
]

def create_notebook(path):
    nb = nbformat.v4.new_notebook()
    nb['cells'] = [nbformat.v4.new_markdown_cell("# " + os.path.basename(path).replace("_", " "))]
    with open(path, "w") as f:
        nbformat.write(nb, f)

for root in roots:
    for module, sessions in modules.items():
        module_path = os.path.join(root, module)
        os.makedirs(module_path, exist_ok=True)
        for session in sessions:
            notebook_path = os.path.join(module_path, f"{session}.ipynb")
            if not os.path.exists(notebook_path):
                create_notebook(notebook_path)

print("Course structure created successfully.")