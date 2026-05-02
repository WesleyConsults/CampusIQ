# CampusIQ — End-to-End User Test Checklist

Use this document to manually test the app as a real user would, from first launch through every major feature. Work through each section in order. The checklist below has been updated to match the final UI navigation redesign completed through Phase 8.

Mark each item `[x]` as you confirm it works.

---

## Prerequisites

- Fresh install **or** cleared app data (Settings → Apps → CampusIQ → Clear Data)
- Device/emulator has internet access (needed for AI features)
- Notifications are NOT yet granted (test the permission dialog)

---

## 1. App Launch & Navigation Shell

### 1.1 Cold launch
- [ ] App opens without crash
- [ ] Lands on the **Today** screen at `/plan` (not a blank screen)
- [ ] Top-left AppBar action is a visible **menu/drawer** icon, not a Home button
- [ ] Bottom navigation bar shows 3 tabs: **CWA, Table, Sessions**
- [ ] AI Assistant is visible as a Floating Action Button (FAB)
- [ ] If no session is active, no mini timer is shown above the shell

### 1.2 Bottom navigation
- [ ] Tap **CWA** — navigates to CWA screen
- [ ] Tap **Table** — navigates to Timetable screen
- [ ] Tap **Sessions** — navigates to Sessions screen
- [ ] Tap **AI** (FAB) — navigates to AI Chat screen
- [ ] Active bottom tab is visually highlighted
- [ ] No crash or blank screen on any tab or FAB

### 1.3 Today home base
- [ ] Today AppBar title reads **Today** (or equivalent user-facing Today label)
- [ ] Notification/bell action is visible in the header
- [ ] Screen shows a greeting / welcome section
- [ ] Screen shows today's classes if timetable data exists
- [ ] Screen shows free-time blocks if timetable data exists
- [ ] Screen shows suggested study tasks / daily plan content
- [ ] Screen shows a streak summary
- [ ] Screen shows a current CWA snapshot
- [ ] If a study session is active, a resume/active-session surface is visible on Today

### 1.4 Drawer navigation from Today
- [ ] Tap the top-left menu icon on Today — drawer opens
- [ ] Drawer includes **Today**
- [ ] Drawer includes **Streak**
- [ ] Drawer includes **Insights**
- [ ] Drawer includes **Weekly Review**
- [ ] Drawer includes **Settings**
- [ ] Drawer includes **Subscribe**
- [ ] Tap **Today** — returns to `/plan`
- [ ] Tap **Streak** — opens `/streak`
- [ ] Tap **Insights** — opens `/insights`
- [ ] Tap **Weekly Review** — opens `/ai/weekly-review`
- [ ] Tap **Settings** — opens `/settings`
- [ ] Tap **Subscribe** — opens `/subscribe`
- [ ] Back/close safely dismisses the drawer without crash

### 1.5 Home-return pattern on module screens
- [ ] From Today, open **CWA** — visible top-left **Home** button appears
- [ ] Tap **Home** on CWA — returns to Today (`/plan`)
- [ ] From Today, open **Table** — visible top-left **Home** button appears
- [ ] Tap **Home** on Table — returns to Today (`/plan`)
- [ ] From Today, open **Sessions** — visible top-left **Home** button appears
- [ ] Tap **Home** on Sessions — returns to Today (`/plan`)

### 1.6 Shell-only chrome rules
- [ ] Bottom navigation appears on shell screens only
- [ ] AI FAB appears on shell screens only
- [ ] Full-screen routes such as `/cwa/manual-entry`, `/timetable/import`, `/course/:courseCode`, and `/ai/weekly-review` do not show the bottom nav
- [ ] `/cwa/manual-entry` does not show the AI FAB

---

## 2. CWA Target Planner (`/cwa`)

> **Do this before Sessions and AI features** — courses added here appear in those screens.

### 2.1 Empty state
- [ ] CWA opens without crash
- [ ] AppBar shows a visible **Home** button on the left
- [ ] AppBar title reads **CWA**
- [ ] AppBar shows a visible **Import** action on the right
- [ ] Overflow / More action is visible if secondary actions exist
- [ ] The **Semester / Cumulative** segmented switcher is visible directly under the app bar

### 2.2 Semester / Cumulative switcher
- [ ] Default selection is **Semester**
- [ ] Tap **Cumulative** — cumulative content appears
- [ ] Tap **Semester** — current semester content appears again
- [ ] Existing CWA data remains visible after switching modes
- [ ] Existing CWA calculations still update correctly

### 2.3 Semester mode structure
- [ ] Semester mode shows a **Current Semester CWA** summary/card
- [ ] Semester mode shows course-wise CWA content
- [ ] Semester mode shows a credits summary
- [ ] Semester mode shows an import helper row or CTA near the top

### 2.4 Cumulative mode structure
- [ ] Cumulative mode shows cumulative CWA summary
- [ ] Cumulative mode shows past semesters / academic history
- [ ] Cumulative mode shows total credits or history/trend context if data exists
- [ ] Existing cumulative actions still work

### 2.5 CWA calculation
- [ ] Summary bar at the top shows a projected CWA
- [ ] Tap the **Target CWA** area — slider dialog opens
- [ ] Drag the slider to set a target (e.g. 75)
- [ ] Confirm — summary bar now shows Target, Projected, and Gap
- [ ] Adjust the score slider on a course card — projected CWA updates live

### 2.6 High-impact indicator
- [ ] One course card should show a "high impact" indicator (the one whose score change affects CWA most)

### 2.7 Edit and delete
- [ ] Tap the **edit icon** on a course card — `AddCourseSheet` opens pre-filled
- [ ] Change the score, save — card updates
- [ ] Delete a course (swipe or delete button) — card disappears, CWA recalculates
- [ ] Re-add the course so you have at least 3 for later tests

### 2.8 Open Course Hub from CWA
- [ ] Tap the **⋮ menu** on any course card → menu shows "Open Workspace", Edit, Delete
- [ ] Tap **"Open Workspace"** → navigates to that course's Course Hub
- [ ] Back arrow returns to the CWA screen

### 2.9 AI Coaching
- [ ] Tap **"Get AI Coaching"** button
- [ ] `CwaCoachSheet` opens with AI-generated advice
- [ ] Advice is relevant to your current courses and gap
- [ ] Sheet dismisses on back/swipe

### 2.10 Import bottom sheet
- [ ] Tap the **Import** action in the CWA AppBar
- [ ] A rounded bottom sheet opens
- [ ] Background dims behind the sheet
- [ ] Drag handle is visible
- [ ] Four large tappable rows are shown:
  - [ ] `Take Photo`
  - [ ] `Upload Image`
  - [ ] `Choose PDF`
  - [ ] `Enter Manually`
- [ ] Each row shows a clear icon:
  - [ ] Camera
  - [ ] Image/gallery
  - [ ] PDF/document
  - [ ] Pencil/edit
- [ ] Swiping down or tapping outside dismisses the sheet safely
- [ ] Import button has a tooltip/semantic label

### 2.11 Registration Slip Import from Semester mode
- [ ] In **Semester** mode, tap **Import**
- [ ] Tap **Take Photo**, **Upload Image**, or **Choose PDF**
- [ ] `RegistrationSlipImportScreen` opens (no bottom nav, no AI FAB)
- [ ] Cancel without selecting — returns to idle screen (no crash)
- [ ] Select a valid registration slip image → loading state shows "AI is reading your slip…"
- [ ] Review screen appears listing all extracted courses with checkboxes
- [ ] Each course shows: course code, course name, credit hours (stepper, 1–6)
- [ ] Adjust credit hours on one course using the stepper — value updates
- [ ] Deselect one course — it greys out
- [ ] Tap **"Select all"** — all checkboxes re-tick
- [ ] Tap **"Import N courses"** → saving overlay → Done screen
- [ ] Done screen confirms count of courses added
- [ ] Tap **Done** → returns to CWA screen
- [ ] Imported courses are now visible in the CWA course list
- [ ] Back button at any step resets the flow and returns to CWA without crash

- [ ] Tap **Home** after import — returns to Today safely

### 2.12 Result Slip Import from Cumulative mode
- [ ] Switch to **Cumulative** mode
- [ ] Tap **Import**
- [ ] Tap **Take Photo**, **Upload Image**, or **Choose PDF**
- [ ] `ResultSlipImportScreen` opens
- [ ] In cumulative mode, the import title/label is appropriate for results or semester records
- [ ] Review / save flow still works
- [ ] Tap the existing cumulative history entry point (if present) → `PastSemestersScreen` opens
- [ ] Empty state shows "No past results yet" with an **Import First Result** button
- [ ] Back arrow returns to CWA

### 2.13 Result Slip Import (Cumulative CWA)
- [ ] On `PastSemestersScreen`, tap the **FAB (+ Add Semester)**
- [ ] `ResultSlipImportScreen` opens
- [ ] Three option tiles visible: **Take a photo**, **Upload image from gallery**, **Choose a PDF**
- [ ] Select a valid result slip image → loading state shows "AI is reading your result slip…"
- [ ] **Label step** appears — text field with placeholder "e.g. Year 1 Sem 1"
- [ ] Quick-pick chips shown (Year 1 Sem 1 … Year 4 Sem 2) — tap one to fill the field
- [ ] Type a label manually → **Continue to Review** button enables
- [ ] Tap Continue — Review screen appears
- [ ] Review screen shows: semester label, courses found count, optional "Reported Sem CWA" and "Reported Cum CWA" chips (if printed on slip)
- [ ] Each selected course shows: course code, course name, mark input (numeric), grade dropdown (A/B/C/D/F, colour-coded), credit hours stepper
- [ ] Change a grade to 'A' → grade chip turns green
- [ ] Type a mark (e.g. 82) — mark field updates
- [ ] Deselect a course — controls hide; row greys out
- [ ] Tap **"Import N courses"** → saving → Done screen confirming label saved
- [ ] Tap Done → returns to `PastSemestersScreen`
- [ ] Imported semester card appears with: label, course count, calculated CWA badge

### 2.14 Manual entry screen
- [ ] From **Semester** mode, tap **Import** → **Enter Manually**
- [ ] Full-screen `Enter Courses Manually` page opens
- [ ] Bottom navigation is not visible
- [ ] AI FAB is not visible
- [ ] AppBar shows Back, title, and `Save draft`
- [ ] Segmented switcher shows **Semester** and **Cumulative**
- [ ] Default mode matches the mode used on CWA before opening the screen
- [ ] Helper text updates when switching between Semester and Cumulative
- [ ] Semester information card is visible
- [ ] At least one course card is visible by default
- [ ] Home button is not shown on this screen
- [ ] Manual-entry screen scrolls correctly on a small device
- [ ] Opening the keyboard does not cover the active field or the bottom action area
- [ ] Sticky `Cancel` and `Save Courses` actions remain usable on a small screen
- [ ] No RenderFlex overflow appears while entering data
- [ ] Tap **Add Another Course** — a new course card is added
- [ ] Tap **Remove Course** on a removable card — that card disappears safely
- [ ] Live Summary updates when course fields change
- [ ] Add, Remove, Save Courses, and Cancel actions expose semantic labels/tooltips
- [ ] Empty course code shows validation
- [ ] Empty course title shows validation
- [ ] Non-numeric or zero credits show validation
- [ ] Non-numeric or out-of-range score shows validation
- [ ] Duplicate course code shows a warning
- [ ] Duplicate course code does not silently save duplicate data
- [ ] Tap **Cancel** — returns safely to CWA
- [ ] Tap **Back** with unsaved changes — discard confirmation appears and behaves safely
- [ ] Re-open manual entry, fill valid values, tap **Save Courses**
- [ ] Screen closes back to CWA
- [ ] Newly saved semester courses appear in Semester mode or saved cumulative records appear in Cumulative/history flows
- [ ] CWA refreshes immediately after save

### 2.15 Past Semesters Screen management
- [ ] Semester card is collapsed by default — tap to expand, reveals course rows
- [ ] Each course row shows: code, name, mark field, credit stepper, grade dropdown — all editable inline
- [ ] Edit a grade inline → card CWA badge recalculates immediately
- [ ] Tap **delete icon** on semester card → confirmation dialog appears
- [ ] Confirm delete → semester card disappears; cumulative CWA on CWA screen updates
- [ ] Import a second past semester — both cards appear; cumulative CWA updates to include both
- [ ] Cumulative CWA on the main CWA screen now reflects all past semesters + current semester

### 2.16 Final redesign regression smoke checks
- [ ] Launch app → Today
- [ ] Today → CWA
- [ ] CWA → Home → Today
- [ ] Today → Table
- [ ] Table → Home → Today
- [ ] Today → Sessions
- [ ] Sessions → Home → Today
- [ ] CWA `Semester` / `Cumulative` switching still preserves visible data
- [ ] Existing Course Hub entry points from CWA still work
- [ ] CWA → Import bottom sheet still shows all four options
- [ ] Existing photo/image/PDF import flows still open the correct screens
- [ ] Manual entry save returns to CWA and refreshed data is visible
- [ ] Active session mini timer still appears when a session is active
- [ ] `Settings`, `Insights`, `Streak`, `Weekly Review`, and `Subscribe` routes still open

---

## 3. Timetable (`/timetable`)

### 3.1 Day selector
- [ ] Horizontal day picker shows all 7 days
- [ ] Tap a different day — grid updates (may be empty for that day)
- [ ] Today is highlighted by default

### 3.2 Add a class slot
- [ ] Swipe to **Classes Only** view (or Both)
- [ ] Tap the FAB — label reads **"Add Class"**
- [ ] `AddSlotSheet` opens
- [ ] Fill in: Course (e.g. "Engineering Mathematics"), day, start time, end time, venue
- [ ] Tap **Save** — slot appears on the grid for that day/time
- [ ] Add at least **2 class slots** on different days

### 3.4 Tap on an existing slot
- [ ] Tap a class slot on the grid → `SlotDetailSheet` opens with details
- [ ] Edit the venue — saves correctly
- [ ] Tap **"Open Workspace"** on a class slot → navigates to that course's Course Hub (no bottom nav visible)
- [ ] Back arrow on Course Hub returns to the Timetable screen

### 3.5 Tap empty grid area
- [ ] Tap an empty time cell on the grid
- [ ] Add sheet opens with that time pre-filled

### 3.6 Import from image — entry point
- [ ] Scanner icon (document scanner) is visible in the Timetable AppBar alongside the "+" button
- [ ] Tap the scanner icon → navigates to `/timetable/import` (no bottom nav visible)
- [ ] Back arrow returns to the Timetable screen without saving anything

---

## 4. Study Sessions (`/sessions`)

> Requires at least one course from Step 2.

### 4.1 Start a session
- [ ] Sessions screen shows **"Start Session"** card (no active session)
- [ ] Tap **"Start Session"** — `CoursePickerSheet` opens
- [ ] Sheet lists courses from your CWA (Engineering Mathematics, etc.)
- [ ] Select a course — sheet closes
- [ ] Active session card appears with a live timer running
- [ ] Timer counts up in real time

### 4.2 Floating mini timer
- [ ] Navigate to another tab (e.g. CWA or AI) while session is running
- [ ] A **floating timer chip** appears at the bottom of the screen
- [ ] Tap the floating timer — navigates back to Sessions screen

### 4.3 Stop and save
- [ ] Return to Sessions tab
- [ ] Tap **Stop** on the active session card
- [ ] Session is saved and appears in the **History** list
- [ ] History item shows: course name, start time, duration
- [ ] Timer card returns to "Start Session" state

### 4.4 Cancel a session (without saving)
- [ ] Start a new session
- [ ] Tap **Cancel** (not Stop)
- [ ] Session is discarded — does NOT appear in history

### 4.5 Analytics
- [ ] After saving at least one session, analytics cards appear:
  - Today's duration and session count
  - Course breakdown
  - Weekly bar chart (may show one bar)

### 4.6 Open Course Hub from Sessions breakdown
- [ ] Scroll to the **"By course"** breakdown card
- [ ] Tap any course row → navigates to that course's Course Hub
- [ ] Back arrow returns to the Sessions screen

### 4.7 History management
- [ ] History list shows saved sessions
- [ ] Swipe a history item to **delete** it — it disappears

### 4.8 Plan tab
- [ ] Tap the **Plan** tab inside Sessions
- [ ] AI study plan displays (or empty state if no data yet)

### 4.9 Insights
- [ ] Tap the **Insights** icon in the AppBar (if visible)
- [ ] Navigates to `/insights` screen with insight cards
- [ ] Back arrow returns to Sessions

### 4.10 Pomodoro mode — setup and UI

- [ ] Start card shows a **Normal / Pomodoro** segmented toggle at the top
- [ ] Default selection is **Normal** — button reads "Start Session" with a play icon
- [ ] Tap the **Pomodoro** chip — button changes to "Start Pomodoro" with an hourglass icon
- [ ] Subtitle below toggle reads "25 min focus · 5 min break · 4 rounds"
- [ ] Tap **"Start Pomodoro"** — `CoursePickerSheet` opens; select a course
- [ ] Active timer card appears — background is **primary blue** (same as Normal)
- [ ] Timer shows a **countdown** (24:59, 24:58…) not a count-up
- [ ] Label below countdown reads **"Round 1 of 4  ·  Focus"**
- [ ] Four progress dots are visible — first dot filled (accent color), rest hollow
- [ ] Buttons show **Cancel** (left) and **Stop & Save** (right)

### 4.11 Pomodoro mode — floating mini-timer

- [ ] Navigate to another tab while Pomodoro is running
- [ ] Floating pill shows **"R1 Focus · 24:xx"** with a countdown (not a count-up)
- [ ] Pill color is **primary blue** during focus phase
- [ ] Tapping the pill navigates back to Sessions
- [ ] Timer count is still accurate after returning

### 4.12 Pomodoro mode — break phase transition

> To test this quickly, set a short focus duration manually in code or wait; for manual testing use a real 25-min focus block. The key behaviors to verify:

- [ ] When the focus countdown reaches **0:00**, the card background changes to **green**
- [ ] Label updates to **"Round 1 of 4  ·  Short Break"** with a 5:00 countdown
- [ ] Left button changes to **"Skip Break"**; right button remains **"Stop & Save"**
- [ ] Floating mini-timer pill turns **green** and shows "R1 Break · 04:xx"
- [ ] Tap **"Skip Break"** — immediately transitions to Round 2 focus (primary blue card, Round 2 of 4 label)
- [ ] Round 2 progress dot fills; Round 1 dot remains filled

### 4.13 Pomodoro mode — session complete state

- [ ] After Round 4 focus ends, the card enters a **Long Break** (green, "Round 4 of 4 · Long Break")
- [ ] When long break ends (or after skipping it), card shows **"Session Complete!"** in accent color
- [ ] Below the title: "4 rounds · 100m focused" (or actual rounds completed × minutes)
- [ ] Only a **"Stop & Save"** button is shown (no Cancel or Skip)
- [ ] Tap **"Stop & Save"** — session is saved and appears in History

### 4.14 Pomodoro mode — save and history

- [ ] Pomodoro session tile in History shows a **small hourglass icon** next to the duration
- [ ] Duration shown reflects **focus time only** — 25 min × completed rounds (break time excluded)
- [ ] Stopping mid-round (during a focus phase) includes partial focus time in the saved duration
- [ ] Stopping during a break saves only the focus time accumulated so far (break minutes not counted)
- [ ] A Pomodoro session where the user stops with < 1 minute of focus **does NOT** appear in history
- [ ] Normal sessions in the same history list show **no hourglass icon**

### 4.15 Pomodoro — analytics and weekly summary

- [ ] After saving a Pomodoro session, **today's analytics card** shows the correct focus minutes
- [ ] The **weekly bar chart** includes Pomodoro focus minutes for the correct day
- [ ] Tap **"This Week"** in the AppBar → weekly review sheet shows total minutes including Pomodoro focus time
- [ ] No double-counting of break time in any summary

---

## 5. Streak System (`/streak`)

> Streaks build automatically as you log sessions. After Step 4 you should have at least 1 study day.

### 5.1 Streak display
- [ ] Streak hero card shows current streak count (at least 1 after logging a session today)
- [ ] Summary row shows: Study Streak, Attendance Streak, Active Course Streaks

### 5.2 Milestones
- [ ] Milestone grid is visible
- [ ] Locked milestones show as greyed out (7-day, 14-day, 30-day, etc.)
- [ ] "Next milestone" progress card shows how many days to the next badge

### 5.3 Attendance tracker
- [ ] Attendance row shows days of the week
- [ ] Tap a day to toggle attendance — visual indicator changes
- [ ] Attendance streak count updates

### 5.4 Per-course streaks
- [ ] List shows a streak entry per course you've studied
- [ ] Streaks reflect sessions logged in Step 4

### 5.5 Activity heatmap
- [ ] Heatmap calendar renders without error
- [ ] Today's cell has a colored dot (indicating a session was logged)

### 5.6 At-risk badge
- [ ] (Simulate or wait) If no session is logged on a new day, the Streak tab badge should appear
- [ ] Badge is red/orange fire indicator

---

## 6. AI Coach & Chat (`/ai`)

### 6.1 Notification permission dialog (first visit only)
- [ ] On the very first visit to the AI tab, a dialog appears: **"Allow notifications?"**
- [ ] Tap **"Not now"** — dialog dismisses, chat screen loads
- [ ] Revisit AI tab — dialog does NOT appear again

### 6.2 Chat interface
- [ ] Chat input field is at the bottom
- [ ] Type a study-related question (e.g. "How should I prepare for my exams?")
- [ ] Tap **Send** — message appears as a user bubble on the right
- [ ] Typing indicator (dots) appears briefly
- [ ] AI response appears on the left
- [ ] Response is readable, relevant, no crash

### 6.2a Markdown & math rendering
- [ ] Ask **"Explain compound interest with the formula"** — response uses **bold** text and bullet points rendered correctly (not as raw `**` or `-`)
- [ ] Ask **"What is the quadratic formula?"** — formula renders as typeset math (not raw LaTeX like `\frac{-b \pm ...}`)
- [ ] Ask **"Find the eigenvalues of the matrix [[2,1],[1,2]]"** — eigenvalue expressions render inline
- [ ] Ask **"Show me step-by-step Gaussian elimination on a 2×2 system"** — display math blocks (`$$...$$`) render centered, no red crash screen
- [ ] Ask **"What are the roots of x² - 5x + 6 = 0, show working"** — mixed markdown steps + math renders without crash
- [ ] Confirm no red error screen on any math-heavy response
- [ ] Inline code in AI responses (e.g. variable names) renders with monospace grey background
- [ ] If AI outputs an unparseable LaTeX expression, it falls back to monospace plain text (not a crash)

### 6.3 Usage counter
- [ ] A counter near the top or input shows remaining free queries (e.g. "2 queries left today")
- [ ] Counter decrements with each message sent
- [ ] After using all free queries, a **"Upgrade to Premium"** gate card appears

### 6.4 Chat history drawer
- [ ] Tap the **History icon** in the AppBar (top right)
- [ ] End drawer opens with list of past conversations
- [ ] Tap a past conversation — chat loads with previous messages
- [ ] Swipe drawer closed

### 6.5 ~~Exam Prep card~~ *(Removed in v1.0)*

> The Exam Prep feature card and `/ai/exam-prep` route have been removed. The AI screen no longer shows this card.

---

## 8. Plan Screen (`/plan`)

> Works best after adding courses (Step 2) and timetable slots (Step 3).

### 8.1 Generate a daily plan
- [ ] Navigate to **Plan** tab
- [ ] Tap the **Generate** button (AppBar)
- [ ] Loading state is shown (spinner or shimmer)
- [ ] Plan cards appear organized into sections: Classes, Study
- [ ] Tasks are sensible (study tasks for your courses, class tasks matching timetable)

### 8.2 Task sections
- [ ] **Classes section** (blue): shows timetabled classes for today
- [ ] **Study section** (green): shows AI-suggested study tasks

### 8.3 Mark a task complete
- [ ] Tap a task — it marks as complete (checkbox/strikethrough)
- [ ] Progress bar at the top increments

### 8.4 Add a manual task
- [ ] Tap the **FAB** (+ icon)
- [ ] `AddManualTaskSheet` opens
- [ ] Fill in a task name and optionally a course
- [ ] Save — task appears in the plan

### 8.5 Dismiss/delete a task
- [ ] Swipe a task tile left or right to dismiss it
- [ ] Task is removed from the list

### 8.6 ~~Exam Mode~~ *(Removed in v1.0)*

> Exam Mode FAB, ExamModeActivationSheet, ExamManagerSheet, exam banner, and exam progress cards have been removed.

---

## 9. Settings (`/settings`)

Navigate to Settings via the AppBar icon on any supported screen (e.g. AI or Plan screens — look for a gear icon).

### 9.1 Open settings
- [ ] Settings screen loads without crash
- [ ] All toggle switches are visible

### 9.2 Notification toggles
- [ ] Toggle **Study Reminders** on — switch flips
- [ ] Toggle **Streak Alerts** on
- [ ] Toggle **Milestone Alerts** on
- [ ] Toggle **Weekly Review prompt** on
- [ ] Each toggle persists if you leave and return to Settings

### 9.3 Daily reminder time picker
- [ ] Tap the **daily reminder time card**
- [ ] `TimePicker` dialog opens
- [ ] Select a time (e.g. 8:00 PM)
- [ ] Confirm — card now shows "8:00 PM"

### 9.4 Cancel all notifications
- [ ] Tap **"Cancel all notifications"** (red button)
- [ ] Confirm action — all scheduled notifications are cleared
- [ ] A snackbar or feedback confirms cancellation

---

## 10. Weekly Review (`/ai/weekly-review`)

> Best tested on a Monday or after logging multiple sessions across several days.

### 10.1 Navigate to weekly review
- [ ] On the AI screen, look for a **Weekly Review banner** (visible on Mondays or when a review is ready)
- [ ] Tap it — navigates to `/ai/weekly-review`

### 10.2 Review sections
- [ ] **"Your week at a glance"** — always visible, shows session stats
- [ ] **"Wins this week"** — visible or blurred (free users see blur overlay)
- [ ] **"Something to fix"** — visible or blurred
- [ ] **"Your #1 priority"** — visible or blurred

### 10.3 Premium gate (free user)
- [ ] Blurred sections show **"Upgrade to Premium"** overlay text
- [ ] Tapping the overlay may navigate to `/subscribe`

### 10.4 "Ask about this review"
- [ ] If on premium (or in dev mode), **"Ask about this review"** button is visible
- [ ] Tapping it navigates to the AI Chat screen with the review pre-loaded as context

---

## 11. Cross-Feature Smoke Tests

These tests verify features work together correctly.

### 11.1 Session → Streak update
- [ ] Log a study session (Step 4)
- [ ] Go to Streak tab
- [ ] Study streak count has incremented or is at least 1

### 11.2 Session → Analytics
- [ ] After logging 2+ sessions for different courses, go to Sessions → Analytics cards
- [ ] Course breakdown shows multiple courses with correct durations

### 11.3 CWA course → Sessions course picker
- [ ] Go to Sessions → Start Session
- [ ] `CoursePickerSheet` lists the same courses you added in CWA (Step 2)

### 11.4 ~~CWA course → Exam Prep course chips~~ *(Removed in v1.0)*

> Exam Prep Generator has been removed; this cross-feature test no longer applies.

### 11.5 Timetable → Plan screen
- [ ] Go to Plan, tap Generate
- [ ] Class tasks in the plan match the class slots you added in Timetable (Step 3)

### 11.6 Notifications flow
- [ ] Go to Settings, enable all notification types
- [ ] Set a study reminder time to 1–2 minutes from now
- [ ] Lock device / minimize app
- [ ] Notification appears at the set time with correct message

### 11.7 Mini timer persistence
- [ ] Start a session in Sessions tab
- [ ] Navigate through all 6 bottom nav tabs one by one
- [ ] Mini floating timer is visible on every tab
- [ ] Timer count is still running (not reset)
- [ ] Return to Sessions — active session card is still live

### 11.8 Pomodoro → Streak update
- [ ] Complete a Pomodoro session (at least 1 focus round saved)
- [ ] Go to Streak tab — study streak count reflects the session logged today

### 11.9 Pomodoro → Weekly Review minutes
- [ ] Log a Pomodoro session (e.g. 2 rounds = 50 min focus)
- [ ] Tap **"This Week"** on the Sessions AppBar
- [ ] Weekly Review sheet total minutes includes the 50 min (not 60 min with breaks, not 0)

---

## 12. Edge Cases & Error States

### 12.1 No internet — AI features
- [ ] Turn off internet / airplane mode
- [ ] Go to AI Chat — type a message and send
- [ ] App shows an error message (not a crash)
- [ ] Error message is user-friendly (not a raw stack trace)
- [ ] Repeat for Exam Prep generation and CWA Coach

### 12.2 Empty states
- [ ] Clear all courses from CWA — screen shows empty state prompt
- [ ] Go to Exam Prep with no courses — shows "No courses found" message
- [ ] Start app with no sessions logged — Sessions history shows empty state

### 12.3 Long content
- [ ] Add a course name longer than 30 characters — card still renders without overflow
- [ ] In AI Chat, send a very long message — input field scrolls or wraps correctly
- [ ] AI response that is several paragraphs long — chat scrolls smoothly

### 12.4 Back navigation
- [ ] From Settings, press system back — returns to the screen you came from
- [ ] From Weekly Review, press system back — returns to AI Chat
- [ ] From Course Hub, press system back — returns to the screen that opened it
- [ ] No "back press" results in a blank screen

---

## 13. Course Hub Workspace (`/course/:courseCode`)

> **Setup:** complete Steps 2, 3, and 4 first — courses, timetable slots, sessions, and streaks must exist.
> Current launch scope: 3 tabs only — Overview, Sessions, Notes.

### 13.1 Entry points
- [ ] Timetable → tap a class slot → tap **"Open Workspace"** → hub opens for that course, no bottom nav visible
- [ ] CWA → tap **⋮** on a course card → tap **"Open Workspace"** → hub opens for that course
- [ ] Sessions → tap any course row in the "By course" breakdown → hub opens for that course
- [ ] Back arrow on the hub returns to the screen that launched it
- [ ] Open hub for Course A → back → open hub for Course B → Course B's data is shown (no stale data from A)

### 13.2 Overview tab
- [ ] Course code, name, and credit hours are correct
- [ ] Expected score % and grade letter chip match the CWA planner
- [ ] "This course contributes X pts" is shown under CWA Impact
- [ ] Current CWA figure is shown
- [ ] Session count and total study time are accurate (cross-check with Sessions history)
- [ ] "Last studied" shows a sensible day count, or "Not studied yet" for an unused course
- [ ] Streak mini-card shows the correct per-course streak and alive/broken status

### 13.3 Sessions tab
- [ ] Only sessions for **this** course appear — sessions from other courses are absent
- [ ] Sessions are in reverse-chronological order
- [ ] Weekly bar chart reflects only this course's study time
- [ ] Empty state shows for a course that has never been studied

### 13.4 Notes tab — create
- [ ] Tap the **+** FAB → `NoteEditorSheet` opens
- [ ] Enter a title and body → tap **Save** → note appears in the list immediately (Isar stream, no refresh needed)
- [ ] Note tile shows: title, first line of body as a preview, and timestamp

### 13.5 Notes tab — edit & delete
- [ ] Tap an existing note → editor opens pre-filled with the title and body
- [ ] Edit the body → Save → list shows updated content
- [ ] Swipe a note left → it disappears from the list immediately
- [ ] Notes from Course A do **not** appear in Course B's Notes tab
- [ ] Empty state shows when no notes exist

### 13.6 Tab scope confirmation
- [ ] Tab bar shows exactly **3 tabs**: **Overview**, **Sessions**, **Notes**
- [ ] **Files** tab is not visible
- [ ] **AI Chat** tab is not visible
- [ ] Switching between the 3 tabs works without crash

### 13.7 Stability
- [ ] Hot restart → notes and per-course stats are still present on their respective tabs
- [ ] Full app restart → notes and per-course stats are still present
- [ ] No red-screen errors on any of the 3 tabs
- [ ] No overflow or render errors on a standard ~360 dp width screen

### 13.8 ~~Flashcards tab~~ *(Removed in v1.0)*

> The Flashcards tab, Files tab, and per-course AI Chat tab have been removed from the Course Hub for the launch build. The hub now has 3 tabs: Overview, Sessions, Notes.

---

## 14. Timetable Image Import (`/timetable/import`)

> **Setup:** requires internet access (DeepSeek Vision API call). Have a clear photo of a university timetable ready — a printed KNUST timetable or a screenshot of one.

### 14.1 Idle screen
- [ ] Screen shows a scanner icon, a title "Import Timetable", explanatory subtitle text
- [ ] Two buttons visible: **"Take Photo"** and **"Choose from Gallery"**
- [ ] No bottom navigation bar is shown

### 14.2 Camera path
- [ ] Tap **"Take Photo"** → device camera opens
- [ ] Take a photo of a timetable → camera closes
- [ ] Screen transitions to **"Extracting timetable…"** loading state (spinner + message)
- [ ] After API response, screen shows the review list (not a crash or blank screen)

### 14.3 Gallery path
- [ ] Tap **"Choose from Gallery"** → system image picker opens
- [ ] Select an existing timetable image → picker closes
- [ ] Loading state appears ("Extracting timetable…") then review list

### 14.4 Cancel — camera
- [ ] Tap **"Take Photo"** → camera opens → press back without taking a photo
- [ ] Returns to the idle screen (no error, no crash)

### 14.5 Cancel — gallery
- [ ] Tap **"Choose from Gallery"** → picker opens → press back without selecting
- [ ] Returns to the idle screen

### 14.6 Review screen
- [ ] At least one slot card is shown for a real timetable image
- [ ] Each slot tile shows: course code + course name, day, start–end time, venue (if detected), slot type chip
- [ ] Slot type chip is color-coded: Lecture (navy), Practical (teal), Tutorial (orange)
- [ ] All slots are pre-selected (checkboxes are ticked) by default
- [ ] Slot count chip at the top reflects the number found (e.g. "8 slots found")
- [ ] AppBar shows **"Import (N)"** action button (N = selected count)
- [ ] Bottom bar shows **"Import N Slot(s)"** button

### 14.7 Select / deselect
- [ ] Tap a slot tile → checkbox toggles off; "Import (N)" count decrements
- [ ] Tap again → checkbox toggles back on
- [ ] Tap **"Deselect All"** → all checkboxes clear; Import button becomes disabled (greyed)
- [ ] Tap **"Select All"** → all checkboxes re-tick; Import button re-enables
- [ ] When zero slots selected, bottom bar shows "Select slots to import" (disabled)

### 14.8 Confirm import
- [ ] With at least one slot selected, tap **"Import N Slot(s)"**
- [ ] Saving overlay (semi-transparent + spinner) appears briefly
- [ ] App navigates automatically to `/timetable`
- [ ] Imported slots appear on the correct days in the Class Timetable grid
- [ ] No duplicate imports if navigated away and returned

### 14.9 Error — no slots found
- [ ] Upload a non-timetable image (e.g. a selfie or blank page)
- [ ] Error state shows: **"No timetable slots found. Try a clearer photo."**
- [ ] **"Try Again"** button resets to the idle screen

### 14.10 Error — no internet
- [ ] Turn off internet → pick a timetable image
- [ ] Error state shows an API error message (not a crash, not a raw stack trace)
- [ ] **"Try Again"** button resets to idle

### 14.11 Imported slots persist
- [ ] After a successful import, hot-restart the app
- [ ] Go to Timetable → imported slots are still present on their respective days
- [ ] Tap an imported slot → `SlotDetailSheet` opens with correct details
- [ ] "Open Workspace" on an imported slot navigates to the correct Course Hub

---

## 15. Performance & Stability

- [ ] Scroll the CWA course list quickly — no jank or dropped frames
- [ ] Scroll the Streak heatmap — no jank
- [ ] Scroll the Sessions history list with 10+ items — smooth
- [ ] Open and close bottom sheets 5+ times rapidly — no crashes or ghost sheets
- [ ] Switch between all 4 bottom nav tabs rapidly — no crash, state is preserved
- [ ] Leave the session timer running for 5+ minutes — timer is still accurate on return
- [ ] Kill and reopen the app during an active session — session state is restored (timer continues or session is recoverable)
- [ ] Switch rapidly between Course Hub tabs — no crash, tab state is preserved
- [ ] Open and close the Course Hub for 3 different courses in sequence — correct data each time

---

## 16. Phase 15.5 — Stability Hardening Smoke Tests

> These tests verify the hardening work from Phase 15.5. Run them after completing sections 1–15.

### 16.1 Offline detection — AI features

- [ ] Turn on **airplane mode**
- [ ] Go to **AI Chat** → type a message and send → error state appears with `"You are offline. AI features require a connection."` — no crash, no stuck spinner
- [ ] Go to **Exam Prep** → tap Generate → same offline error state appears
- [ ] Go to **CWA screen** → tap "Get AI Coaching" → error message shown — app does not hang
- [ ] Go to **Timetable Import** → pick an image → offline error state shown before any API call
- [ ] Go to **Registration Slip Import** → pick an image → offline error shown
- [ ] Turn airplane mode **off** → retry each feature → it works normally

### 16.2 Error states — every screen shows feedback on failure

- [ ] Simulate a provider failure (or fresh-install with empty Isar) and verify each screen shows a spinner or empty state — **no blank white screen**
- [ ] On any screen with an `ErrorRetryWidget`, tap **"Try Again"** — provider reloads and content appears (or shows loading)
- [ ] **CWA screen**: delete all courses → empty state message visible, no crash
- [ ] **Sessions screen**: no sessions → empty state message visible
- [ ] **Streak screen**: no study days → empty state message (not a blank card)
- [ ] **Plan screen**: no tasks → empty state visible
- [ ] **Course Hub — Notes tab**: no notes → empty state visible

### 16.3 Navigation safety — invalid course code

- [ ] Manually navigate to `/course/` (empty code) — redirects to `/cwa` with a snackbar "Course not found."
- [ ] Navigate to `/course/FAKE999` (nonexistent course) → fallback scaffold appears: "This course no longer exists" with a back button — no crash
- [ ] Back button on the fallback scaffold navigates correctly (no stuck nav stack)

### 16.4 Course Hub scope safety

- [ ] Open any Course Hub and confirm **Files** tab is absent
- [ ] Open any Course Hub and confirm **AI Chat** tab is absent
- [ ] Navigation into and out of the 3-tab hub still works from CWA, Timetable, and Sessions

### 16.5 Timer reliability — edge cases

- [ ] Start a **Normal session** → background the app for 2+ minutes → return → elapsed time is correct (not reset to zero, not stuck)
- [ ] Start a **Pomodoro session** → background the app mid-countdown → return → countdown is still accurate (time not frozen)
- [ ] During Pomodoro focus, rapidly tap **Skip Break** (when break starts) multiple times → only one phase transition fires — no double advance
- [ ] Kill the app during an active Pomodoro → relaunch → no active session shown, no crash, no phantom timer

### 16.6 Isar write safety

- [ ] In **CWA screen**, add a course → summary bar updates → hot restart → course persists
- [ ] In **Course Hub → Notes tab**, add a note → hot restart → note persists
- [ ] In **Session screen**, stop & save a session → hot restart → session appears in history
- [ ] No red-screen or crash on any of the above — if an Isar write fails, a snackbar is shown

### 16.7 Global crash capture

- [ ] Check logcat (or flutter logs) during normal use — no unhandled `🔴 UNCAUGHT ERROR:` lines during normal flows
- [ ] App recovers from any in-app error without showing a red debug screen to the user

---

## Sign-Off

| Section | Status | Notes |
|---|---|---|
| 1. App Launch & Navigation | | |
| 2. CWA Planner | | |
| 3. Timetable | | |
| 4. Study Sessions — Normal mode | | |
| 4a. Pomodoro mode (4.10–4.15) | | |
| 5. Streak System | | |
| 6. AI Coach & Chat | | |
| 6a. AI Markdown & Math Rendering | | |
| 7. ~~Exam Prep Generator~~ | REMOVED | Deleted in v1.0 |
| 8. Plan Screen | | |
| 9. Settings | | |
| 10. Weekly Review | | |
| 11. Cross-Feature Tests | | |
| 11a. Pomodoro cross-feature (11.8–11.9) | | |
| 12. Edge Cases | | |
| 13. Course Hub Workspace (3-tab) | | |
| 14. Timetable Image Import | | |
| 15. Performance & Stability | | |
| 16a. Offline detection (15.5) | | |
| 16b. Error/empty states (15.5) | | |
| 16c. Navigation safety (15.5) | | |
| 16d. Course Hub scope safety (15.5) | | |
| 16e. Timer reliability (15.5) | | |
| 16f. Isar write safety (15.5) | | |

**Tester:** ___________________  
**Date:** ___________________  
**Build / Commit:** ___________________  
**Device / Emulator:** ___________________  
**Android Version:** ___________________
