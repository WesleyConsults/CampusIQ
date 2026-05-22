# CampusIQ — End-to-End User Test Checklist

Use this document to manually test the app as a real user would, from first launch through every major feature. Work through each section in order.

**This checklist has been updated for v1.0 production polish (2026-05-22).** The app now uses a floating pill-shaped bottom nav (Home | CWA/GPA/CGPA | Table | Sessions) with dynamic grading system labels, 6-step university onboarding, multi-grading-system support (CWA, GPA 4.0, GPA 4.0 GIMPA, CGPA 5.0), dark mode (System/Light/Dark), timer feedback toggles (vibrate/sound), course reminders, Android-only Firebase Crashlytics, and a restructured Settings with About section. All AI requests route through a Vercel proxy (`campusiq-api.vercel.app`) — no API keys live on-device. The AI FAB, AI Chat (`/ai`), CWA AI Coach, and What-If AI feature have all been removed. No `/subscribe` route exists in the current build.

Mark each item `[x]` as you confirm it works.

---

## Prerequisites

- Fresh install **or** cleared app data (Settings → Apps → UniMate → Clear Data)
- Device/emulator has internet access (needed for AI features)
- Notifications are NOT yet granted (test the permission dialog)
- Firebase project `unimate-69516` is open in Firebase Console when testing Crashlytics.
- Crashlytics tests must run on an Android emulator/device, not Chrome.

---

## 1. University Onboarding

> The onboarding is shown on first launch only. Clear app data to re-test.

### 1.1 Welcome screen
- [ ] App opens to onboarding welcome screen (not Today)
- [ ] App logo and tagline visible
- [ ] "Get Started" button visible
- [ ] "Skip" button visible in the top-right
- [ ] Progress dots at the bottom show 6 steps

### 1.2 University selection
- [ ] Tap "Get Started" → university selection screen
- [ ] Grid of university cards with logos visible
- [ ] Scrollable — 20+ universities shown
- [ ] Tap a university (e.g. KNUST) → university is selected (highlighted)
- [ ] Tap "Next" → programme screen
- [ ] Back arrow returns to welcome screen

### 1.3 Programme
- [ ] Text input for programme name visible
- [ ] Can skip (leave blank) without issue
- [ ] Enter a programme (e.g. "Computer Engineering") → persists
- [ ] Tap "Next" → grading system screen

### 1.4 Grading system
- [ ] 4 grading systems shown: CWA, GPA 4.0, GPA 4.0 (GIMPA), CGPA 5.0
- [ ] Each shows score range and default target
- [ ] The university's default is pre-selected (e.g. KNUST → CWA)
- [ ] Tap a different system → selection updates
- [ ] Tap "Next" → target screen

### 1.5 Target score
- [ ] Target slider shown with the grading system's range
- [ ] Default target matches the grading system's default
- [ ] Drag slider → value updates
- [ ] Tap "Next" → notifications screen

### 1.6 Notifications
- [ ] 4 toggles shown, all default to on: Study reminders, Streak alerts, Milestone alerts, Weekly review prompt
- [ ] Toggle one off → switch flips
- [ ] Tap "Complete" → loading state, then navigates to Today (`/plan`)
- [ ] Bottom nav now visible with 4 tabs

### 1.7 Skip and redirect guard
- [ ] Clear app data → relaunch → onboarding shown again
- [ ] Tap "Skip" on welcome screen → navigates directly to Today
- [ ] Clear app data → relaunch → kill app on university screen → relaunch → back on onboarding (redirect guard active)
- [ ] Complete onboarding → kill and relaunch → opens Today (not onboarding)

### 1.8 Reset onboarding
- [ ] Go to Settings → Dev → Reset onboarding → confirm
- [ ] App navigates to `/onboarding`
- [ ] Completing onboarding again works correctly

---

## 2. Fresh Install / Launch (Post-Onboarding)

### 2.1 First launch after onboarding
- [ ] App opens without crash
- [ ] Lands on the **Today** screen at `/plan` (Home tab)
- [ ] Soft off-white background (`AppColors.surface`) appears
- [ ] Bottom navigation bar shows exactly 4 tabs: **Home**, grades label (CWA/GPA/CGPA), **Table**, **Sessions**
- [ ] Bottom nav is a floating pill shape (rounded, semi-transparent, with shadow)
- [ ] No AI FAB is visible (AI chat removed from current MVP)
- [ ] If no session is active, no mini timer is shown
- [ ] No overflow on launch

### 2.2 Hot restart / relaunch
- [ ] Hot restart — app returns to Today without crash
- [ ] Full app kill and relaunch — app opens to Today (onboarding already completed)

---

## 3. App Shell / Navigation

### 3.1 Bottom navigation
- [ ] Tap **Home** — navigates to Today screen (`/plan`)
- [ ] Tap the **grades tab** (label varies: CWA/GPA/CGPA) — navigates to academic planner (`/cwa`)
- [ ] Tap **Table** — navigates to Timetable screen (`/timetable`)
- [ ] Tap **Sessions** — navigates to Sessions screen (`/sessions`)
- [ ] Active bottom tab is visually highlighted (tinted background, bold label)
- [ ] No crash or blank screen on any tab
- [ ] The second tab label changes when grading system is changed in Settings

### 3.2 Navigation — no AI FAB
- [ ] No gold sparkles FAB is visible on any shell tab
- [ ] No `/ai` chat route exists — verify by checking that tapping bottom-right of any tab does nothing unexpected

### 3.3 Full-screen routes (no bottom nav)
- [ ] `/onboarding` — no bottom nav visible (first-run only)
- [ ] `/streak` — no bottom nav visible
- [ ] `/insights` — no bottom nav visible
- [ ] `/settings` — no bottom nav visible
- [ ] `/ai/weekly-review` — no bottom nav visible
- [ ] `/course/:courseCode` — no bottom nav visible
- [ ] `/timetable/import` — no bottom nav visible
- [ ] `/timetable/reminders` — no bottom nav visible
- [ ] `/cwa/manual-entry` — no bottom nav visible
- [ ] `/cwa/history` — no bottom nav visible
- [ ] `/cwa/import/registration` — no bottom nav visible
- [ ] `/cwa/import/results` — no bottom nav visible

### 3.4 Back navigation
- [ ] From Streak (opened via drawer), press system back — returns to Today
- [ ] From Insights (opened via drawer), press system back — returns to Today
- [ ] From Settings, press system back — returns to the screen you came from
- [ ] From Weekly Review, press system back — returns to the previous screen
- [ ] From Course Hub, press system back — returns to the screen that opened it
- [ ] From Course Reminders, press system back — returns to Timetable
- [ ] From any bottom nav tab (Home, CWA, Table, Sessions), press system back — exits to phone launcher (expected)
- [ ] No "back press" results in a blank screen

### 3.5 Offline banner in shell
- [ ] Turn on airplane mode → a grey "You are offline" banner appears at the top of every shell tab (Home, CWA, Table, Sessions)
- [ ] Banner pushes shell content down cleanly — no overlap with AppBar
- [ ] Turn off airplane mode → banner disappears, content returns to normal position
- [ ] Banner does NOT appear on full-screen routes outside the shell (Course Hub, Settings, etc.)

### 3.6 Bottom nav content clearance
- [ ] Shell tabs render full height
- [ ] Content on each tab scrolls fully above the floating bottom nav and mini timer (when active)
- [ ] No content permanently hidden behind the nav bar
- [ ] No persistent dead band at the bottom of any tab

---

## 4. Home Screen (Today)

### 3.1 Header and structure
- [ ] Greeting header visible with date
- [ ] AppBar shows hamburger menu icon (left), streak action button, bell icon, and Generate button (right)
- [ ] Title reads **Today**
- [ ] Hero card is visible near the top (context-sensitive: active session resume, current class, next class, or "day open")

### 3.2 Academic Pulse
- [ ] Academic Pulse section visible
- [ ] Renders as a **2-column grid** of compact tiles
- [ ] Shows CWA metrics and streak context
- [ ] No text clipping or overflow in tiles on a standard ~360dp screen

### 3.3 Today at a Glance
- [ ] Today at a Glance section visible
- [ ] Shows class count, pending study tasks, and progress
- [ ] Does **not** show a free-block metric
- [ ] No overflow

### 3.4 Progress section
- [ ] Progress section visible with plan progress bar
- [ ] Progress bar shows completed/total tasks
- [ ] Celebration message shown when all tasks done

### 3.5 Lower content
- [ ] Active session resume card visible if a session is active
- [ ] Today's classes section shows timetable slots for today (if data exists)
- [ ] Free blocks section shows detected free windows (if timetable data exists)
- [ ] Task list shows three groups: Planned classes, Suggested study tasks, Personal tasks
- [ ] Long task labels wrap/truncate cleanly without overlapping the time/duration column
- [ ] Lower content scrolls fully above the floating bottom nav

### 3.6 Sections not present
- [ ] Suggested focus section is **not** present
- [ ] Local add-task FAB is **not** present (task creation available via inline actions)

### 3.7 Drawer (Today's local menu)
- [ ] Tap hamburger menu icon — drawer opens from the left
- [ ] Drawer includes: Today, Streak, Insights, Weekly Review, Settings, Subscribe
- [ ] Tap **Today** — closes drawer, stays on Today
- [ ] Tap **Streak** — opens `/streak` (full-screen, no bottom nav)
- [ ] Tap **Insights** — opens `/insights` (full-screen, no bottom nav)
- [ ] Tap **Weekly Review** — opens `/ai/weekly-review`
- [ ] Tap **Settings** — opens `/settings`
- [ ] Tap **Subscribe** — opens `/subscribe`
- [ ] Back/close safely dismisses the drawer without crash

---

## 5. CWA Screen

> Do this before Sessions and AI features — courses added here appear in those screens.

### 4.1 Empty state and header
- [ ] CWA opens without crash
- [ ] AppBar title reads **CWA**
- [ ] AppBar shows a visible **Import** action on the right
- [ ] The **Semester / Cumulative** segmented control is visible directly under the app bar
- [ ] Default selection is **Semester**

### 4.2 Semester / Cumulative switcher
- [ ] Tap **Cumulative** — cumulative content appears
- [ ] Tap **Semester** — current semester content appears again
- [ ] Existing CWA data remains visible after switching modes
- [ ] CWA calculations still update correctly after mode switch

### 4.3 Semester mode
- [ ] CWA hero card displays projected CWA, target, and gap
- [ ] Compact stats cards show credits summary and course count
- [ ] Import helper row or CTA visible near the top
- [ ] Course cards are compact and readable
- [ ] Long course names do not overflow
- [ ] CWA calculation updates correctly when scores change

### 4.4 CWA calculation
- [ ] Tap the **Target CWA** area — slider dialog opens
- [ ] Drag the slider to set a target (e.g. 75)
- [ ] Confirm — hero card now shows Target, Projected, and Gap
- [ ] Adjust the score slider on a course card — projected CWA updates live

### 4.5 High-impact indicator
- [ ] One course card shows a "high impact" indicator (course whose score change affects CWA most)

### 4.6 Edit and delete courses
- [ ] Tap the **edit icon** on a course card — `AddCourseSheet` opens pre-filled
- [ ] Change the score, save — card updates
- [ ] Delete a course (swipe or delete button) — confirmation appears
- [ ] Confirm delete — card disappears, CWA recalculates
- [ ] Re-add the course so you have at least 3 for later tests

### 4.7 Open Course Hub from CWA
- [ ] Tap the **⋮ menu** on any course card → menu shows "Open Workspace", Edit, Delete
- [ ] Tap **"Open Workspace"** → navigates to that course's Course Hub
- [ ] Back arrow returns to the CWA screen

### 4.8 AI Coach removal verification
- [ ] No "Coach" or sparkles button visible on CWA screen (CWA Coach removed)
- [ ] No AI-related UI elements on CWA screen beyond the import flow

### 4.8b What-If feature removal verification
- [ ] Drag a course score slider away from its saved value → no "Explain" chip appears (what-if feature is removed)
- [ ] The CWA recalculation still happens live as the slider moves
- [ ] No what-if related UI elements visible anywhere on the CWA screen

### 4.9 Cumulative mode
- [ ] Switch to **Cumulative** mode
- [ ] Cumulative CWA summary displayed
- [ ] Past semesters / academic history visible (if data exists)
- [ ] Total credits or history/trend context shown
- [ ] Existing cumulative actions still work

### 4.10 Active semester picker
- [ ] Tap the semester picker in the CWA AppBar — a sheet or dropdown opens showing academic year + semester options
- [ ] Select a different semester — the course list rescopes to that semester
- [ ] Newly selected semester persists across hot restart
- [ ] Courses from semester A do not appear when semester B is selected
- [ ] Default semester matches `UserPrefsModel.activeSemesterKey`

### 4.11 Target CWA persistence
- [ ] Set a target CWA (e.g. 75) via the target dialog
- [ ] Kill the app and relaunch → target CWA is still 75 (not reset to 70)
- [ ] Change target CWA → hero card gap indicator updates live

### 4.12 Complete Semester flow
- [ ] In Semester mode with courses present, a "Complete Semester" action is visible (AppBar or section action)
- [ ] Tap "Complete Semester" → `CompleteSemesterScreen` opens (no bottom nav, no AI FAB)
- [ ] All current courses are pre-filled in the grade-entry form (course code, name, credit hours carry forward)
- [ ] Each course row shows a **grade dropdown** (A–F, colour-coded) — primary field
- [ ] Each course row shows an optional **mark/score** input — secondary field
- [ ] "Next Semester" preview shows the calculated next semester (e.g. "2025-Sem1" after "2024-Sem2")
- [ ] Tap "Complete & Save" → confirmation dialog appears showing the target semester
- [ ] Confirm → courses are saved as a `PastSemesterModel`, old `CourseModel` entries are cleared, `activeSemesterKey` advances
- [ ] Cancel on confirmation dialog → no data changed, user stays on the Complete Semester screen
- [ ] Back button on Complete Semester screen → returns to CWA without changes
- [ ] After completing a semester, switch to Cumulative mode → the completed semester appears in history

### 4.13 Semester progression card (Cumulative mode)
- [ ] Switch to Cumulative mode with at least 2 past semesters
- [ ] A semester progression card is visible showing chronological semester list
- [ ] Each semester row shows: label, semester CWA, cumulative CWA after that semester
- [ ] Delta indicators (↑/↓) show change from the previous semester
- [ ] With only 1 past semester, no delta is shown (nothing to compare)

### 4.14 Bottom-nav / overflow
- [ ] Add Course not hidden behind nav
- [ ] Lower CWA content scrolls fully above the floating bottom nav
- [ ] No overflow on hero card or stats cards
- [ ] Semester/Cumulative switcher does not overlap with course list

---

## 6. CWA Import / Manual Entry

### 5.1 Import bottom sheet
- [ ] Tap the **Import** action in the CWA AppBar
- [ ] A polished rounded bottom sheet opens
- [ ] Background dims behind the sheet
- [ ] Drag handle is visible
- [ ] Four tappable rows shown: **Take Photo**, **Upload Image**, **Choose PDF**, **Enter Manually**
- [ ] Each row shows a clear icon
- [ ] Swiping down or tapping outside dismisses the sheet safely

### 5.2 GoRouter-based import navigation
- [ ] From CWA Semester mode, tap Import → Take Photo → navigates to `/cwa/import/registration?source=camera`
- [ ] From CWA Cumulative mode, tap Import → Upload Image → navigates to `/cwa/import/results?source=gallery`
- [ ] Press system back from any import screen → returns to CWA (not phone launcher)
- [ ] From CWA, tap the history icon → navigates to `/cwa/history`
- [ ] Press system back from Past Semesters History → returns to CWA
- [ ] All three CWA routes (`/cwa/history`, `/cwa/import/registration`, `/cwa/import/results`) have no bottom nav and no AI FAB

### 5.3 Registration Slip Import (Semester mode)
- [ ] In **Semester** mode, tap **Import**
- [ ] Tap **Take Photo**, **Upload Image**, or **Choose PDF**
- [ ] `RegistrationSlipImportScreen` opens (no bottom nav, no AI FAB)
- [ ] Cancel without selecting — returns to idle screen (no crash)
- [ ] Select a valid registration slip image → loading state shows "AI is reading your slip…"
- [ ] Review screen appears listing all extracted courses with checkboxes
- [ ] Each course shows: course code, course name, credit hours (stepper, 1–**12**)
- [ ] **Expected score slider** is visible on each course row (default ~70, adjustable)
- [ ] Adjust expected score on one course using the slider — value updates
- [ ] Adjust credit hours on one course using the stepper — value updates
- [ ] Deselect one course — it greys out
- [ ] Tap **"Select all"** — all checkboxes re-tick
- [ ] If AI skipped any malformed rows, a warning chip shows "N courses could not be parsed" with an "Add Manually" button
- [ ] Tap "Add Manually" → a blank course row appears for manual fill-in
- [ ] Tap **"Import N courses"** → saving overlay → Done screen
- [ ] Done screen confirms count of courses added
- [ ] Tap **Done** → returns to CWA screen
- [ ] Imported courses are now visible in the CWA course list with their reviewed expected scores
- [ ] Back button at any step resets the flow and returns to CWA without crash

### 5.4 Result Slip Import (Cumulative mode)
- [ ] Switch to **Cumulative** mode
- [ ] Tap **Import** → **Take Photo**, **Upload Image**, or **Choose PDF**
- [ ] `ResultSlipImportScreen` opens
- [ ] Select a valid result slip image → loading state
- [ ] **Label step** appears — **semester name is auto-populated** from AI-parsed metadata if the slip had `reportedSemesterCwa`
- [ ] Quick-pick chips shown (Year 1 Sem 1 … Year 4 Sem 2)
- [ ] Tap **Continue to Review** → Review screen appears
- [ ] Review screen shows: semester label, courses found count, CWA chips
- [ ] Each course shows: code, name, mark input, **grade dropdown** (A–F, colour-coded), credit stepper (1–12)
- [ ] Grades are colour-coded (A=green, F=red, etc.)
- [ ] If AI skipped any malformed rows, a warning chip shows "N courses could not be parsed"
- [ ] Tap **"Import N courses"** → saving → Done screen
- [ ] Tap Done → returns to CWA or PastSemestersScreen
- [ ] Cumulative CWA on main CWA screen reflects the imported semester

### 5.5 Duplicate semester detection
- [ ] Import a result slip for a semester that already exists (same `semesterKey`)
- [ ] A dialog appears: "This semester already exists. Replace it?"
- [ ] Tap **Replace** → old record is overwritten, new data saved
- [ ] Tap **Cancel** → import is cancelled, no duplicate created
- [ ] Verify cumulative CWA does NOT double-count courses from the duplicate

### 5.6 Manual Entry screen
- [ ] From **Semester** mode, tap **Import** → **Enter Manually**
- [ ] Full-screen `Enter Courses Manually` page opens
- [ ] Bottom navigation is **not** visible
- [ ] AI FAB is **not** visible
- [ ] Segmented switcher shows **Semester** and **Cumulative**
- [ ] Default mode matches the CWA mode before opening
- [ ] In **Cumulative** mode, course rows show **grade dropdown** (A–F) as the primary field, with an optional mark input
- [ ] Semester information card is visible
- [ ] At least one course card is visible by default
- [ ] Tap **Add Another Course** — a new course card appears
- [ ] Tap **Remove Course** — that card disappears
- [ ] Live Summary updates when course fields change

### 5.7 Manual Entry — draft auto-save
- [ ] Enter partial data (e.g. one course filled, one empty)
- [ ] Kill the app (swipe away from recents) without saving
- [ ] Reopen app → navigate to Manual Entry → the partial form is restored
- [ ] Fill all fields and save → reopen Manual Entry → form is blank (draft was cleared on save)
- [ ] The old "Draft saving is coming in a later phase" placeholder is no longer visible

### 5.8 Manual Entry validation
- [ ] Empty course code shows validation
- [ ] Empty course title shows validation
- [ ] Non-numeric or zero credits show validation
- [ ] Credit hours above **12** show validation (cap raised from 6)
- [ ] Non-numeric or out-of-range score shows validation
- [ ] Duplicate course code shows a warning
- [ ] Duplicate course code does not silently save duplicate data

### 5.9 Manual Entry save / cancel
- [ ] Tap **Cancel** — returns safely to CWA
- [ ] Tap **Back** with unsaved changes — discard confirmation appears
- [ ] Discard confirmation behaves safely (cancel keeps editing, discard returns to CWA)
- [ ] Fill valid values, tap **Save Courses**
- [ ] Screen closes back to CWA
- [ ] Newly saved courses appear in CWA course list
- [ ] CWA refreshes immediately after save

### 5.10 Manual Entry keyboard and scroll
- [ ] Screen scrolls correctly on a small device
- [ ] Opening the keyboard does not cover the active field or the bottom action area
- [ ] Sticky `Cancel` and `Save Courses` actions remain usable on a small screen
- [ ] No RenderFlex overflow while entering data

### 5.11 Past Semesters management
- [ ] Semester card is collapsed by default — tap to expand
- [ ] Each course row shows: code, name, mark field, credit stepper (1–12), grade dropdown — all editable inline
- [ ] Edit a grade inline → CWA badge recalculates immediately (no need to leave the card)
- [ ] Tap **delete icon** on semester card → confirmation dialog appears
- [ ] Confirm delete → semester card disappears; cumulative CWA updates
- [ ] Import a second past semester — both cards appear; cumulative CWA includes both
- [ ] Past Semesters screen now opens via GoRouter (`/cwa/history`) — press back returns to CWA

---

## 7. Table / Timetable

### 6.1 Header, day selector, and summary
- [ ] AppBar title reads **Table**
- [ ] Scanner/import action is visible in the AppBar
- [ ] Add (`+`) action is visible in the AppBar
- [ ] Horizontal day picker shows all 7 days
- [ ] Tap a different day — grid updates (may be empty for that day)
- [ ] Today is highlighted by default
- [ ] Compact day summary card is visible near the top
- [ ] Summary card updates when the selected day changes
- [ ] Summary card shows: selected day, class count, next/first class, free-block count — no overflow

### 6.2 Timeline layout and scrolling
- [ ] `Daily timeline` header is visible above the timetable
- [ ] The timetable grid is the main page content — full-page scrollable
- [ ] Timetable is **not** trapped inside a small nested vertical scroll box
- [ ] Class blocks are visible and readable with calmer card styling
- [ ] Free blocks are visible and are visually lighter than class blocks
- [ ] Long course/location text does not overflow on slot cards

### 6.3 Add a class slot
- [ ] Tap the AppBar `+` action
- [ ] `AddSlotSheet` opens
- [ ] Fill in: Course, day, start time, end time, venue
- [ ] Tap **Save** — slot appears on the grid for that day/time
- [ ] Add at least **2 class slots** on different days

### 6.4 Tap on an existing slot
- [ ] Tap a class slot on the grid → `SlotDetailSheet` opens with details
- [ ] Edit the venue — saves correctly
- [ ] Tap **"Open Workspace"** on a class slot → navigates to Course Hub (no bottom nav)
- [ ] Back arrow on Course Hub returns to the Timetable screen

### 6.5 Free blocks and empty state
- [ ] Tap a visible free block — add sheet opens with that time range pre-filled
- [ ] On a day with no classes, a calm empty state is shown instead of a blank page
- [ ] Empty-state add action still opens the add sheet
- [ ] Tapping open timetable space still opens the add flow without crashing

### 6.6 Bottom-nav / overflow
- [ ] Final timetable content scrolls above the floating bottom nav
- [ ] No persistent blank band remains above the navbar
- [ ] Bottom nav does not hide the last timetable entry

### 6.7 Timetable import — entry point
- [ ] Scanner icon is visible in the Timetable AppBar alongside the reminders and "+" buttons
- [ ] Tap the scanner icon → navigates to `/timetable/import` (no bottom nav visible)
- [ ] Back arrow returns to the Timetable screen without saving

### 6.8 Course reminders — entry point
- [ ] Reminders icon (bell) is visible in the Timetable AppBar
- [ ] Tap the reminders icon → navigates to `/timetable/reminders` (no bottom nav)
- [ ] Back arrow returns to Timetable

### 6.9 Course reminders — add and edit
- [ ] Course Reminders screen shows empty state if no reminders exist
- [ ] Tap **+** or "Add Reminder" → bottom sheet opens
- [ ] Sheet shows course picker (from timetable slots), time display, and offset selector (10/15/30/60/120 min)
- [ ] Select a course and offset → tap Save → reminder appears in list
- [ ] Reminder shows: course code, course name, day, time, and offset (e.g. "30 min before")
- [ ] Tap an existing reminder → edit sheet opens pre-filled
- [ ] Change the offset → save → list updates
- [ ] Swipe to delete a reminder → confirmation → reminder removed

### 6.10 Course reminders — notification scheduling
- [ ] Add a course reminder for a class today (within the next hour)
- [ ] Notification should fire at the scheduled offset time
- [ ] Notification shows course name and time
- [ ] Kill and relaunch → reminders still listed in Course Reminders screen
- [ ] Disable all notifications in Settings → reminders list still visible but no notifications fire

---

## 8. Sessions

> Requires at least one course from Section 4.

### 7.1 AppBar and header
- [ ] AppBar title reads **Sessions**
- [ ] **"This Week"** button visible in AppBar (calendarRange icon) — opens weekly review sheet
- [ ] Streak action button visible in AppBar (fire icon)
- [ ] Insights button visible in AppBar (sparkles icon) — navigates to `/insights`

### 7.2 Start a session — Normal mode
- [ ] Sessions screen shows calm focus room layout
- [ ] Start card shows **Normal / Pomodoro** segmented toggle
- [ ] Default selection is **Normal** — button reads "Start Session" with a play icon
- [ ] Tap **"Start Session"** — `CoursePickerSheet` opens
- [ ] Sheet lists courses from your CWA
- [ ] Select a course — sheet closes
- [ ] Active session card appears with a live timer running (counts up)

### 7.3 Today's progress
- [ ] Today's progress card is visible
- [ ] Shows today's duration and session count
- [ ] No overflow on the progress card

### 7.4 Floating mini timer
- [ ] Navigate to another tab (e.g. CWA or Home) while session is running
- [ ] A **floating timer chip** appears at the bottom of the screen
- [ ] Timer shows running elapsed time
- [ ] Tap the floating timer — navigates back to Sessions screen
- [ ] Mini timer does not overlap nav badly
- [ ] Lower Sessions content still scrolls above the floating nav/FAB/timer

### 7.5 Stop and save
- [ ] Return to Sessions tab
- [ ] Tap **Stop** on the active session card
- [ ] Session is saved and appears in the **History** list
- [ ] History item shows: course name, start time, duration
- [ ] Timer card returns to "Start Session" state

### 7.6 Cancel a session (without saving)
- [ ] Start a new session
- [ ] Tap **Cancel** (not Stop)
- [ ] Session is discarded — does NOT appear in history

### 7.7 History and analytics
- [ ] History tab shows saved sessions in reverse-chronological order
- [ ] Swipe a history item to **delete** it — it disappears
- [ ] After saving at least one session, analytics cards appear:
  - Today's duration and session count
  - Course breakdown
  - Weekly bar chart

### 7.8 Plan tab
- [ ] Tap the **Plan** tab inside Sessions
- [ ] Plan tab does **not** throw FormatException
- [ ] AI study plan displays (or empty state if no data yet)
- [ ] Malformed plan values show fallback instead of crashing
- [ ] Plan content scrolls above the floating bottom nav

### 7.9 Open Course Hub from Sessions breakdown
- [ ] Scroll to the **"By course"** breakdown card
- [ ] Tap any course row → navigates to that course's Course Hub
- [ ] Back arrow returns to the Sessions screen

### 7.10 Pomodoro mode — setup and UI
- [ ] Start card shows **Normal / Pomodoro** segmented toggle
- [ ] Tap the **Pomodoro** chip — button changes to "Start Pomodoro" with an hourglass icon
- [ ] Subtitle reads "25 min focus · 5 min break · 4 rounds"
- [ ] Tap **"Start Pomodoro"** — `CoursePickerSheet` opens; select a course
- [ ] Active timer card appears — background is primary blue
- [ ] Timer shows a **countdown** (24:59, 24:58…) not a count-up
- [ ] Label reads **"Round 1 of 4  ·  Focus"**
- [ ] Four progress dots are visible — first dot filled, rest hollow
- [ ] Buttons show **Cancel** (left) and **Stop & Save** (right)

### 7.11 Pomodoro — floating mini-timer
- [ ] Navigate to another tab while Pomodoro is running
- [ ] Floating pill shows **"R1 Focus · 24:xx"** with a countdown
- [ ] Pill colour is primary blue during focus phase
- [ ] Tapping the pill navigates back to Sessions
- [ ] Timer count is still accurate after returning

### 7.12 Pomodoro — break phase transition
- [ ] When focus countdown reaches **0:00**, card background changes to **green**
- [ ] Label updates to **"Round 1 of 4  ·  Short Break"** with a 5:00 countdown
- [ ] Left button changes to **"Skip Break"**; right button remains **"Stop & Save"**
- [ ] Floating mini-timer turns **green** and shows "R1 Break · 04:xx"
- [ ] Tap **"Skip Break"** — immediately transitions to Round 2 focus (primary blue, Round 2 of 4)
- [ ] Round 2 progress dot fills; Round 1 dot remains filled

### 7.13 Pomodoro — session complete
- [ ] After Round 4 focus ends, card enters **Long Break** (green, "Round 4 of 4 · Long Break")
- [ ] When all phases done, card shows **"Session Complete!"**
- [ ] Below the title: "4 rounds · 100m focused" (or actual rounds × minutes)
- [ ] Only **"Stop & Save"** button shown (no Cancel or Skip)
- [ ] Tap **"Stop & Save"** — session saved and appears in History

### 7.14 Pomodoro — save and history
- [ ] Pomodoro session tile in History shows a **small hourglass icon** next to the duration
- [ ] Duration reflects **focus time only** — break time excluded
- [ ] Stopping mid-round includes partial focus time
- [ ] Stopping during a break saves only accumulated focus time
- [ ] Pomodoro session with < 1 minute of focus does NOT appear in history
- [ ] Normal sessions in the same history list show **no hourglass icon**

### 7.15 Pomodoro — analytics
- [ ] Today's analytics card shows correct focus minutes (not break time)
- [ ] Weekly bar chart includes Pomodoro focus minutes for the correct day
- [ ] "This Week" review sheet shows total minutes including Pomodoro focus time
- [ ] No double-counting of break time in any summary

---

## 9. Course Hub

> Setup: complete Sections 4, 6, and 7 first. Current launch scope: 3 tabs — Overview, Sessions, Notes.

### 9.1 Entry points
- [ ] CWA → tap **⋮** on a course card → tap **"Open Workspace"** → hub opens, no bottom nav
- [ ] Timetable → tap a class slot → tap **"Open Workspace"** → hub opens for that course
- [ ] Sessions → tap any course row in "By course" breakdown → hub opens
- [ ] Back arrow on the hub returns to the screen that launched it
- [ ] Open hub for Course A → back → open hub for Course B → Course B's data is shown (no stale data)

### 9.2 Tab bar
- [ ] Tab bar shows exactly **3 tabs**: **Overview**, **Sessions**, **Notes**
- [ ] **Files** tab is not visible
- [ ] **AI Chat** tab is not visible
- [ ] Switching between tabs works without crash

### 9.3 Overview tab
- [ ] Course code, name, and credit hours are correct
- [ ] Expected score % and grade letter chip match the CWA planner
- [ ] "This course contributes X pts" shown under CWA Impact
- [ ] Current CWA figure shown
- [ ] Session count and total study time accurate
- [ ] "Last studied" shows sensible day count or "Not studied yet"
- [ ] Streak mini-card shows correct per-course streak and alive/broken status

### 9.4 Sessions tab
- [ ] Only sessions for **this** course appear
- [ ] Sessions are in reverse-chronological order
- [ ] Weekly bar chart reflects only this course's study time
- [ ] Empty state shows for a course never studied

### 9.5 Notes tab — create
- [ ] Tap the **+** FAB → note editor opens
- [ ] Enter a title and body → tap **Save** → note appears in the list immediately
- [ ] Note tile shows: title, first line preview, and timestamp

### 9.6 Notes tab — edit and delete
- [ ] Tap an existing note → editor opens pre-filled
- [ ] Edit the body → Save → list shows updated content
- [ ] Swipe a note left → it disappears from the list
- [ ] Notes from Course A do not appear in Course B's Notes tab
- [ ] Empty state shows when no notes exist

### 9.7 Stability
- [ ] Hot restart → notes and per-course stats persist
- [ ] Full app restart → notes and per-course stats persist
- [ ] No red-screen errors on any of the 3 tabs
- [ ] No overflow on a standard ~360dp screen

---

## 10. Modals / Bottom Sheets / Dialogs

### 10.1 Bottom sheets
- [ ] Add Course sheet — opens, closes, saves correctly
- [ ] Add Slot sheet — opens, closes, saves correctly
- [ ] Course Picker sheet — lists courses, selection works
- [ ] Import Options sheet — four options, each navigates correctly
- [ ] Slot Detail sheet — details visible, edit works, Open Workspace works
- [ ] Note Editor sheet — opens in create and edit modes
- [ ] All sheets have a drag handle
- [ ] All sheets dismiss on swipe down
- [ ] All sheets dim the background

### 10.2 Confirmation dialogs
- [ ] Delete course confirmation appears and works
- [ ] Delete session confirmation appears and works
- [ ] Delete note confirmation appears and works
- [ ] Delete timetable slot confirmation appears and works
- [ ] Discard unsaved changes confirmation appears and works
- [ ] No destructive action executes without confirmation

### 10.3 Keyboard behaviour
- [ ] Bottom sheets adjust correctly when keyboard opens
- [ ] Form fields inside sheets are not hidden by keyboard
- [ ] Dismissing keyboard does not break sheet state

### 10.4 Visual consistency
- [ ] No white-on-light buttons (contrast issue)
- [ ] All sheet headers use consistent styling
- [ ] Action rows are consistently positioned
- [ ] No overflow on any sheet

---

## 11. Settings / Streak / Insights / Weekly Review

### 11.1 Settings — Academic section
- [ ] Settings screen loads without crash
- [ ] **Academic** section visible with: Active semester, Grading system
- [ ] Tap Active semester → picker opens, select different semester, card updates
- [ ] Tap Grading system → picker opens showing 4 systems (CWA, GPA 4.0, GPA 4.0 GIMPA, CGPA 5.0)
- [ ] Select a different grading system → Settings card updates
- [ ] Switch to a different grading system → navigate to CWA tab → tab label and screen title reflect new system

### 11.1b Settings — Timer Feedback
- [ ] **Timer Feedback** section visible with: Vibrate on phase end, Sound on phase end
- [ ] Both toggles work and persist on leaving and returning

### 11.1c Settings — Notifications
- [ ] **Notifications** section visible with toggles: Study reminders, Streak alerts, Milestone alerts, Weekly review prompt
- [ ] Each toggle persists if you leave and return to Settings
- [ ] Tap the **daily reminder time card** → TimePicker dialog opens
- [ ] Select a time (e.g. 8:00 PM) → card updates
- [ ] Tap **"Cancel all notifications"** → confirmation → all scheduled notifications cleared

### 11.1d Settings — Appearance (Dark Mode)
- [ ] **Appearance** section visible with Theme picker
- [ ] Tap Theme → bottom sheet opens with Light / Dark / System options
- [ ] Select **Dark** → entire app switches to dark theme immediately
- [ ] All shell tabs render correctly in dark mode (nav, cards, text)
- [ ] Bottom sheets and dialogs render correctly in dark mode
- [ ] Select **Light** → app switches back to light theme
- [ ] Select **System** → follows device dark/light setting
- [ ] Theme choice persists across app restart

### 11.1e Settings — About
- [ ] **About** section visible with: About UniMate, Privacy policy, Terms of service, Send feedback
- [ ] Tap About UniMate → system About dialog opens showing app name and version
- [ ] Tap Privacy policy → browser or system sheet opens with URL
- [ ] Tap Terms of service → opens correctly
- [ ] Tap Send feedback → email composer opens with `hello@campusiq.app`

### 11.1f Settings — Dev
- [ ] **Dev** section visible with Reset onboarding
- [ ] In debug builds only, **Test Crashlytics crash** is visible in Settings → Dev
- [ ] In release builds, **Test Crashlytics crash** is not visible
- [ ] Tap Reset onboarding → confirmation
- [ ] Confirm → app navigates to onboarding flow
- [ ] No overflow on the settings screen

### 11.1g Settings — Dev Crashlytics test
- [ ] Run the app on Android in debug mode (`flutter run -d <android-device-id>`)
- [ ] Go to Settings → Dev → Test Crashlytics crash
- [ ] Tap the test crash row — the app closes/crashes immediately
- [ ] Reopen the app after the crash so Crashlytics can upload the report
- [ ] In Firebase Console → `unimate-69516` → Crashlytics, select Android app `com.wesleyconsults.campusiq`
- [ ] A crash issue appears within a few minutes
- [ ] No new `Zone mismatch` issue appears after the startup zone fix; previously recorded historical issues may remain visible

### 11.1h Analytics and non-fatal reporting smoke test
- [ ] In Firebase Console → Analytics → DebugView, confirm screen views appear while navigating: Today, planner, timetable, sessions, settings
- [ ] Complete onboarding on a fresh install → `onboarding_completed` appears with anonymous parameters only
- [ ] Change grading system in Settings → `grading_system_selected` appears
- [ ] Change theme in Settings → `settings_theme_changed` appears
- [ ] Add or edit a course → `course_added` or `course_updated` appears
- [ ] Add or edit a timetable slot → `timetable_slot_added` or `timetable_slot_updated` appears
- [ ] Start and save a normal study session → `study_session_started` and `study_session_completed` appear
- [ ] Start and save a Pomodoro session → `pomodoro_started` and `pomodoro_completed` appear
- [ ] Trigger an offline import or AI generation failure → matching failure event appears and, where applicable, a non-fatal Crashlytics report appears
- [ ] Confirm analytics parameters do not include course names, exact grades/scores, venues, notes, uploaded file contents, AI prompt/response text, programme name, or personal identifiers

### 11.2 Streak
- [ ] Streak screen opens (via drawer from Today)
- [ ] Streak hero card shows current streak count
- [ ] Summary row shows: Study Streak, Attendance Streak, Active Course Streaks
- [ ] Milestone grid visible with locked/unlocked states
- [ ] "Next milestone" progress card shows days remaining
- [ ] Attendance tracker — tap a day to toggle attendance
- [ ] Per-course streak list reflects sessions logged
- [ ] Activity heatmap renders without error
- [ ] Today's cell has a coloured dot (if session logged)
- [ ] No overflow on the streak screen

### 11.3 Insights
- [ ] Insights screen opens (via drawer from Today)
- [ ] Insight cards display with animated entry
- [ ] Cards show relevant analysis (best study day, neglected courses, etc.)
- [ ] No crash with zero data
- [ ] No overflow

### 11.4 Weekly Review
- [ ] Weekly Review opens (via drawer from Today or Mondays auto-prompt)
- [ ] Stats display: total minutes, best day, streak
- [ ] Highlight chips visible
- [ ] Reflection text field works
- [ ] Save works — reflection persists
- [ ] Keyboard does not hide actions
- [ ] No overflow

---

## 12. Edge Case Testing

### 12.1 No data states
- [ ] No courses — CWA shows empty state prompt, no crash
- [ ] No timetable entries — Timetable shows calm empty state
- [ ] No sessions — Sessions history shows empty state
- [ ] No study days — Streak shows empty/zero state
- [ ] No tasks — Plan/Home shows empty state
- [ ] No notes — Course Hub Notes tab shows empty state

### 12.2 Many data states
- [ ] Many courses (10+) — CWA scrolls smoothly, no overflow
- [ ] Many timetable entries — grid renders correctly, overlapping slots split into columns
- [ ] Many sessions (20+) — History scrolls smoothly
- [ ] Long course names (30+ chars) — cards render without overflow
- [ ] Long locations — timetable slot cards do not overflow

### 12.3 Screen size extremes
- [ ] Small Android screen (~360dp) — no overflow on any major screen
- [ ] Large Android screen — layout scales appropriately, no stretched cards

### 12.4 Keyboard behaviour
- [ ] Keyboard open on forms — fields remain visible
- [ ] Keyboard open on bottom sheets — sheet adjusts correctly
- [ ] Dismissing keyboard — no layout jump or broken state

### 12.5 Scrolling
- [ ] Scroll to bottom of Home screen — all content visible above nav
- [ ] Scroll to bottom of CWA screen — all courses visible
- [ ] Scroll to bottom of Table screen — full timetable visible
- [ ] Scroll to bottom of Sessions History — all sessions visible
- [ ] Scroll to bottom of Course Hub tabs — all content visible

### 12.6 No internet — AI features
- [ ] Turn on airplane mode
- [ ] Go to Timetable Import → pick an image → offline error shown
- [ ] Go to Registration Slip Import → pick an image → offline error shown
- [ ] Go to Weekly Review → generate → offline error message shown (not crash)
- [ ] Error messages are user-friendly (not raw stack traces)
- [ ] Turn airplane mode off → retry each feature → works normally

### 12.8 Dark mode edge cases
- [ ] Switch to dark mode → all screens render with correct contrast
- [ ] Cards, sheets, and dialogs all use dark surface colours
- [ ] Text is readable (no dark text on dark background)
- [ ] Grade dropdowns in Complete Semester / Manual Entry are legible in dark mode
- [ ] Bottom nav is semi-transparent dark with adjusted shadow
- [ ] Switch back to light mode → no residual dark styling

### 12.7 Active Pomodoro edge cases
- [ ] Background app mid-Pomodoro countdown → return → countdown is still accurate
- [ ] Rapidly tap Skip Break multiple times → only one phase transition fires
- [ ] Kill app during active Pomodoro → relaunch → no active session shown, no phantom timer
- [ ] Rapid tab switching during active Pomodoro → timer remains accurate

---

## 13. Release / Beta Readiness

### 13.1 Build and analyze
- [ ] `flutter clean` — completes without error
- [ ] `flutter pub get` — completes without error
- [ ] `flutter analyze` — no new issues (pre-existing baseline acceptable)
- [ ] `dart run build_runner build --delete-conflicting-outputs` — completes
- [ ] `flutter test` — all tests pass
- [ ] `lib/firebase_options.dart` exists and contains only Android options for project `unimate-69516`
- [ ] `firebase.json` maps FlutterFire to Android app `1:796338316529:android:a8e523b52360f724953550`
- [ ] `android/app/google-services.json` exists
- [ ] No `ios/Runner/GoogleService-Info.plist` is present while Firebase scope remains Android-only
- [ ] `flutter analyze` remains clean after analytics instrumentation
- [ ] `flutter test` remains clean after analytics instrumentation

### 13.2 Build APK
- [ ] `flutter build apk --debug` — builds successfully
- [ ] `flutter build apk --release` — builds successfully (if signing configured)
- [ ] APK installs on real device
- [ ] App opens on real device without crash

### 13.3 Device testing
- [ ] Installed APK on real Android device
- [ ] Crashlytics test crash uploaded from Android debug build
- [ ] Sent APK to at least one friend/tester
- [ ] Tester feedback collected
- [ ] Critical crashes documented and fixed
- [ ] Major overflow issues documented and fixed

### 13.4 Pre-store checks
- [ ] Privacy policy reviewed for Play Store compliance
- [ ] App permissions reviewed (notifications, camera, storage, internet)
- [ ] App icon and name correct
- [ ] No test/debug data visible to users
- [ ] Debug-only Crashlytics test crash row is hidden in release builds
- [ ] AI proxy configured (no API keys on-device; requests route through `campusiq-api.vercel.app`)
- [ ] Firebase Crashlytics configured for Android only (`com.wesleyconsults.campusiq`)
- [ ] Analytics and non-fatal Crashlytics tracking remain privacy-safe: counts/modes/sources/error reasons only

---

## Sign-Off

| Section | Status | Notes |
|---|---|---|
| 1. University Onboarding | | |
| 2. Fresh Install / Launch (Post-Onboarding) | | |
| 3. App Shell / Navigation (incl. offline banner, no AI FAB) | | |
| 4. Home Screen (Today) | | |
| 5. CWA/GPA Screen (incl. Complete Semester, active semester picker, target persistence, progression card, what-if/coach removal verification) | | |
| 6. CWA Import / Manual Entry (incl. GoRouter routes, duplicate detection, draft saving, credit cap 12, parse warnings, auto-label, grade-first entry) | | |
| 7. Table / Timetable (incl. course reminders, import) | | |
| 8. Sessions (Normal + Pomodoro + timer feedback) | | |
| 9. Course Hub | | |
| 10. Modals / Bottom Sheets / Dialogs | | |
| 11. Settings / Streak / Insights / Weekly Review (incl. dark mode, timer feedback, about, grading system picker, debug Crashlytics test) | | |
| 12. Edge Case Testing (incl. dark mode edge cases) | | |
| 13. Release / Beta Readiness | | |

**Tester:** ___________________
**Date:** ___________________
**Build / Commit:** ___________________
**Device / Emulator:** ___________________
**Android Version:** ___________________
