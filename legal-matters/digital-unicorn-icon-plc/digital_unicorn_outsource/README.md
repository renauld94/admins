# digital_unicorn_outsource — Databricks notebooks

This folder contains Databricks "NotebookV1" JSON-exported files with the `.python` extension.

What I did
- Added a small converter script at `scripts/convert_databricks_to_ipynb.py` that converts these Databricks JSON files into standard Jupyter `.ipynb` notebooks.
- The converter preserves markdown cells (`%md`) and code cells, sets `metadata.language` for each cell, and attempts to map simple command outputs (ANSI/stdout) into Jupyter outputs.

How to bulk-convert the folder (recommended)

Run the provided command from the repository root. It finds all `.python` files and runs the converter on each one:

```bash
find "/home/simon/Desktop/Learning Management System Academy/digital_unicorn_outsource" -name "*.python" -print0 \
  | xargs -0 -n1 python3 "/home/simon/Desktop/Learning Management System Academy/scripts/convert_databricks_to_ipynb.py"
```

This writes `.ipynb` files next to each source `.python` file.

VS Code tips
- Open the workspace file `Learning Management System Academy.code-workspace` (added `digital_unicorn_outsource` as a workspace folder). Use File → Open Workspace if needed.
- Install the Jupyter extension for VS Code to get the Notebook editor.
- After conversion, open any generated `.ipynb` file in VS Code's Notebook view.
- If VS Code still hides files, check `Settings → Files: Exclude` and ensure the folder isn't excluded.

Notes & next steps
- The converter maps simple ANSI/stdout outputs; more complex results (tables, images, HTML) may require enhancements. If you want outputs reconstructed for specific result types (images or tables), tell me which examples to support and I will extend the script.
- If you prefer the `.ipynb` files put into a separate output tree instead of next to sources, I can add an `--out-dir` option.

