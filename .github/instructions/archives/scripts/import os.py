import os
import nbformat

# Map your .py files to notebook names
file_map = [
    ("session1.1_Basics.py", "2.1-Welcome-and-Introduction.ipynb"),
    ("session1.2_Modules_and_Packages.py", "2.2-Python-Basics-Variables-Types-Ops.ipynb"),
    ("session1.3_Data_Structures.py", "2.3-Control-Structures-If-Loops.ipynb"),
    ("session1.4_Advanced_Data_Structures.py", "2.4-Functions-and-Modules.ipynb"),
    ("session1.5_Conditions_and_Loops.py", "2.5-Data-Structures.ipynb"),
    ("session1.6_Functions.py", "2.6-File-IO.ipynb"),
    ("session1.7_Dates_and_Times.py", "2.7-Error-and-Exception-Handling.ipynb"),
    ("session1.8_Regular_Expressions.py", "2.8-Regular-Expressions.ipynb"),
    ("session1.9_Classes.py", "2.9-Classes-and-OOP.ipynb"),
    ("session1.10_Decorators.py", "2.10-Decorators.ipynb"),
    ("session1.11_Virtual_Environments.py", "2.11-Virtual-Environments.ipynb"),
    ("session1.12_Exception_Handling.py", "2.12-Context-Managers.ipynb"),
    ("session1.13_Context_Managers.py", "2.13-Iterators-and-Generators.ipynb"),
    ("session1.14_Iterators_and_Generators.py", "2.14-String-Processing.ipynb"),
    ("session1.15_String_Processing.py", "2.15-APIs-and-JSON.ipynb"),
    ("session1.16_APIs_and_JSON.py", "2.16-APIs-and-JSON.ipynb"),
]

src_dir = "/home/simon/Downloads/Module 1 - Core Python/Module 1 - Core Python"
dst_dir = "/home/simon/Desktop/learning-platform/Module 2 - Core Python"

def py_to_ipynb(py_path, ipynb_path):
    with open(py_path, "r") as f:
        lines = f.readlines()
    cells = []
    cell = []
    cell_type = "code"
    for line in lines:
        if line.strip().startswith("# MAGIC %md"):
            if cell:
                if cell_type == "code":
                    cells.append(nbformat.v4.new_code_cell("".join(cell)))
                else:
                    cells.append(nbformat.v4.new_markdown_cell("".join(cell)))
                cell = []
            cell_type = "markdown"
        elif line.strip().startswith("# COMMAND ----------"):
            if cell:
                if cell_type == "code":
                    cells.append(nbformat.v4.new_code_cell("".join(cell)))
                else:
                    cells.append(nbformat.v4.new_markdown_cell("".join(cell)))
                cell = []
            cell_type = "code"
        elif line.strip().startswith("# MAGIC"):
            cell.append(line.replace("# MAGIC", ""))
        else:
            cell.append(line)
    if cell:
        if cell_type == "code":
            cells.append(nbformat.v4.new_code_cell("".join(cell)))
        else:
            cells.append(nbformat.v4.new_markdown_cell("".join(cell)))
    nb = nbformat.v4.new_notebook()
    nb['cells'] = cells
    with open(ipynb_path, "w") as f:
        nbformat.write(nb, f)

for src, dst in file_map:
    py_path = os.path.join(src_dir, src)
    ipynb_path = os.path.join(dst_dir, dst)
    py_to_ipynb(py_path, ipynb_path)

print("Conversion complete.")