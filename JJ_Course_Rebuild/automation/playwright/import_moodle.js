const { chromium } = require('playwright');
const fs = require('fs');

// Config - read from environment
const MOODLE_URL = process.env.MOODLE_URL || 'https://moodle.simondatalab.de';
const ADMIN_USER = process.env.MOODLE_ADMIN_USER || 'admin';
const ADMIN_PASS = process.env.MOODLE_ADMIN_PASS || '';
const COURSE_ID = process.env.MOODLE_COURSE_ID || '2';
const HEADLESS = process.env.MOODLE_HEADLESS === '1' || process.env.MOODLE_HEADLESS === 'true';
const QUIZ_PATH = process.env.MOODLE_QUIZ_PATH || '../../moodle_import/quiz_module1_lesson1.xml';

if (!ADMIN_PASS) {
  console.error('ERROR: Set MOODLE_ADMIN_PASS environment variable');
  process.exit(1);
}

(async () => {
  const browser = await chromium.launch({ headless: !!HEADLESS });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Login
  await page.goto(`${MOODLE_URL}/login/index.php`);
  await page.fill('input[name="username"]', ADMIN_USER);
  await page.fill('input[name="password"]', ADMIN_PASS);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
  console.log('Logged in');

  // Navigate to question bank import page
  await page.goto(`${MOODLE_URL}/question/edit.php?courseid=${COURSE_ID}`);
  await page.waitForSelector('a[data-action="import"]', { timeout: 10000 }).catch(()=>{});

  // Click Import (may be a tab link)
  // If import tab exists as link, click it; otherwise click the import form button
  const importTab = await page.$('a[href*="/question/import.php"], a[data-action="import"]');
  if (importTab) {
    await importTab.click();
  } else {
    // try tab by text
    await page.click('text=Import');
  }
  await page.waitForLoadState('networkidle');
  console.log('Import page open');

  // Select format Moodle XML
  await page.selectOption('select[name="format"]', 'moodle_xml');

  // Choose server files - open file picker and select path
  // This is brittle across themes; instead we will use the filepicker 'Upload a file' -> choose file input
  // We'll upload local copy of quiz XML that should be present next to script

  const quizPathLocal = QUIZ_PATH;
  if (!fs.existsSync(quizPathLocal)) {
    console.error('Quiz XML not found: ' + quizPathLocal);
    await browser.close();
    process.exit(1);
  }

  // Look for file input and set file
  const fileInput = await page.$('input[type="file"]');
  if (fileInput) {
    await fileInput.setInputFiles(quizPathLocal);
    console.log('Uploaded quiz XML');
  } else {
    console.warn('No file input found; trying alternative file picker...');
    // Try clicking 'Choose a file' then upload via dialog selector
    const chooseBtn = await page.$('button[data-action="choosefile"], button:has-text("Choose a file")');
    if (chooseBtn) {
      const [fileChooser] = await Promise.all([
        page.waitForEvent('filechooser'),
        chooseBtn.click()
      ]);
      await fileChooser.setFiles(quizPathLocal);
      console.log('Uploaded quiz XML via file chooser');
    } else {
      console.error('Unable to find file picker to upload XML');
      await browser.close();
      process.exit(1);
    }
  }

  // Click Import button - guess selector
  const importBtn = await page.$('button:has-text("Import")');
  if (importBtn) {
    await importBtn.click();
  } else {
    await page.click('input[type="submit"][value*="Import"], button[type="submit"]');
  }

  await page.waitForLoadState('networkidle');
  console.log('Import submitted; waiting for completion');
  await page.waitForTimeout(5000);

  // Add Page resource in the course
  await page.goto(`${MOODLE_URL}/course/view.php?id=${COURSE_ID}`);
  await page.waitForLoadState('networkidle');

  // Turn editing on
  const turnOn = await page.$('button[title="Turn editing on"], a[title="Turn editing on"], text=Turn editing on');
  if (turnOn) {
    await turnOn.click();
    await page.waitForLoadState('networkidle');
  }

  console.log('Editing mode enabled');
  // Add activity - click Add an activity or resource in section 1
  // This depends on theme. Try to find 'Add an activity or resource' link in first section
  const addLinks = await page.$$('a:has-text("Add an activity or resource")');
  if (addLinks.length > 0) {
    await addLinks[0].click();
  } else {
    // Try alternative
    await page.click('text=Add an activity or resource');
  }
  await page.waitForSelector('div#modal-add', { timeout: 5000 }).catch(()=>{});

  // Click Page
  await page.click('button:has-text("Page"), a:has-text("Page")');
  await page.waitForLoadState('networkidle');

  // Fill page name and content
  await page.fill('input[name="name"]', 'Lesson 1: CDISC Standards Overview');
  // Click HTML editor toggle and set content
  const editorBody = await page.$('div[data-region="editor"] iframe, iframe.editor_ifr');
  if (editorBody) {
    const frame = await editorBody.contentFrame();
    await frame.fill('body', `<iframe src="/moodledata/repository/course_2/lessons/Lesson1_CDISC_Standards_Overview/index.html" width="100%" height="1200px" frameborder="0"></iframe>`);
    console.log('Page content set via iframe');
  } else {
    // Fallback: fill textarea
    await page.fill('textarea[name="content\[text\]"]', `<iframe src="/moodledata/repository/course_2/lessons/Lesson1_CDISC_Standards_Overview/index.html" width="100%" height="1200px" frameborder="0"></iframe>`);
  }

  // Save and return to course
  await page.click('button:has-text("Save and return to course"), button:has-text("Save and display")');
  await page.waitForLoadState('networkidle');
  console.log('Page resource created');

  // Create Quiz activity
  await page.click('text=Add an activity or resource');
  await page.waitForSelector('div#modal-add', { timeout: 5000 }).catch(()=>{});
  await page.click('button:has-text("Quiz"), a:has-text("Quiz")');
  await page.waitForLoadState('networkidle');
  await page.fill('input[name="name"]', 'Module 1, Lesson 1 Quiz - CDISC Standards');
  await page.click('button:has-text("Save and return to course"), button:has-text("Save and display")');
  await page.waitForLoadState('networkidle');
  console.log('Quiz created');

  // Edit quiz and add questions from category
  await page.click('text=Edit quiz');
  await page.waitForLoadState('networkidle');
  await page.click('text=Add');
  await page.click('text=from question bank');
  await page.waitForSelector('div#questionbank', { timeout: 5000 }).catch(()=>{});
  // Select all questions in category - depends on UI; try checkbox select all
  const selectAll = await page.$('input[name="selectall"]');
  if (selectAll) {
    await selectAll.check();
    await page.click('button:has-text("Add selected questions to the quiz")');
  } else {
    // fallback: click first "Add" buttons inside list
    const addButtons = await page.$$('button:has-text("Add")');
    for (const btn of addButtons.slice(0, 20)) {
      await btn.click();
      await page.waitForTimeout(300);
    }
  }
  console.log('Questions added to quiz (best-effort)');

  // Finished
  await page.waitForTimeout(2000);
  await browser.close();
  console.log('Automation complete');
})();
