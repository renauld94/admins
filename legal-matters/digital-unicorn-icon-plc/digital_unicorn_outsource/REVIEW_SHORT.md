# Quick Review — Simon Comments

Strengths
- Clear session structure (slides + executable notebooks).
- Databricks usage matches the agreed technical stack.
- DISPLAY (teacher) + EXERCISE (student) pairing improves teaching flow and reuse.

Areas to raise
- Verify CDISC SDTM naming / variable conventions for downstream compatibility.
- Add an environment spec (requirements.txt) and remove notebook outputs.
- Separate instructor solutions from student-facing files (private folder or branch).
- Ensure session complexity and duration align with the target audience.

Quick actions

- Add requirements.txt
- Run nbstripout (and add pre-commit) to clear outputs and enforce repo hygiene.
- Agree and document where instructor solutions will be stored

Why (brief)
- Structure aids navigation and consistent delivery.
- Databricks alignment reduces setup friction for trainees.
- DISPLAY vs EXERCISE separation supports learning and assessment.
- CDISC/variable checks are critical for regulatory integration.
- requirements.txt + nbstripout improve reproducibility and reduce merge noise.
- Separating instructor solutions protects assessment integrity and reduces cognitive load for learners.


### Notes meeting 09082025

- Jakes taking material 
- progress on materials: 
- Fstring example and mix up example in the logic is correct
- Nicholas origial class flow of convention, and walk SDTM modualized
- exercice B operator examples
- Data4U, DRM, any references and anonamyze , pre-QA server not real data - DRM studies data dummy (something like). Use it as a reference 
- ## Question Graham : questions per topic and quiz : 
   - Nicolas : traning adavances - basic 2-3 questions 
   - what its gonna be advance - end topic 
   - powerpoint and source python notebook format
   - david has access to databricks format 
   - separate notebooks - no duplicates information - powerpoint



   Hello David,

Please find the latest file attached addressing the feedback given.

Response to feedback items:
added an explanation in the display and slides for f-strings
adjusted all examples in slides, display and example notebooks to fit the SDTM standard
added a section in session 2.2 slides and display covering arithmetic operators
added a section covering collections in M2 2.2 slides and display
removed sequential part of logic structures
renamed the control structures to if/then/else and while/for loops
restructured M2 2.3 display notebook, moving the sections 'Logic Errors That Compromise Submissions' and 'Prevention Strategies' to directly before the summary. Expanded on them, provided examples and altered the slides to reflect this. Altered try/except example and the for loop example to give an explanation and added comments to example code. Furthermore, I removed the function definition since the student would not have had exposure to this
reworked the summary to fit the contents of session 2.3
for loop is now covered in the material
removed the exercise without replacement since there are already enough exercises

Let me know if you have any further comments and/or questions.

Many thanks,
Jake