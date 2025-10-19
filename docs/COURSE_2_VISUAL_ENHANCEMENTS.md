# Course ID 2 — Visual Enhancements

Summary of CSS selectors and how to tweak visuals for [Course 2](https://moodle.simondatalab.de/course/view.php?id=2).

- Header banner and title:
  - Selector: `body.path-course.course-2 #page-header`
  - Title: `body.path-course.course-2 .page-context-header .page-header-headings h1`
  - Change gradient, border, and font weight.

- Section cards:
  - Selector: `body.path-course.course-2 .course-content .section.main`
  - Hover: subtle lift and border tint.
  - Adjust padding, gap, and radius.

- Activities:
  - Selector: `body.path-course.course-2 .section.main .activity`
  - Hover background: `#f8fafc` and border tint.
  - Titles: `.activity .activityinstance a` (weight and color).

- Progress bars:
  - Selector: `body.path-course.course-2 .progress .progress-bar`
  - Brand color: `var(--primary)` and rounded caps.

- Mobile tweaks:
  - Reduce section/activity padding under 600px.

Edit the stylesheet at `learning-platform/moodle-simondatalab.css` and redeploy with `scripts/deploy_moodle_brand_style.sh`.
