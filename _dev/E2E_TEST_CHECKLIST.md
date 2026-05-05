# CampusIQ — End-to-End User Test Checklist

Use this document to manually test the app as a real user would, from first launch through every major feature. Work through each section in order.

**This checklist has been updated for the redesigned premium UI.** The app now uses a floating pill-shaped bottom nav (Home | CWA | Table | Sessions), a gold AI sparkles FAB, and a calm premium design system (deep navy, muted gold, soft off-white, Inter font, Lucide icons).

Mark each item `[x]` as you confirm it works.

---

## Prerequisites

- Fresh install **or** cleared app data (Settings → Apps → CampusIQ → Clear Data)
- Device/emulator has internet access (needed for AI features)
- Notifications are NOT yet granted (test the permission dialog)

---

## 1. Fresh Install / Launch

### 1.1 First launch
- [ ] App opens without crash
- [ ] Lands on the **Today** screen at `/plan` (Home tab)
- [ ] Soft off-white background (`AppColors.surface`) appears
- [ ] Bottom navigation bar shows exactly 4 tabs: **Home, CWA, Table, Sessions**
- [ ] Bottom nav is a floating pill shape (rounded, semi-transparent, with shadow)
- [ ] Gold AI sparkles FAB is visible at the bottom-right, above the nav bar
- [ ] If no session is active, no mini timer is shown
- [ ] No overflow on launch

### 1.2 Hot restart / relaunch
- [ ] Hot restart — app returns to Today without crash
- [ ] Full app kill and relaunch — app opens to Today

---

## 2. App Shell / Navigation

### 2.1 Bottom navigation
- [ ] Tap **Home** — navigates to Today screen (`/plan`)
- [ ] Tap **CWA** — navigates to CWA screen (`/cwa`)
- [ ] Tap **Table** — navigates to Timetable screen (`/timetable`)
- [ ] Tap **Sessions** — navigates to Sessions screen (`/sessions`)
- [ ] Active bottom tab is visually highlighted (tinted background, bold label)
- [ ] No crash or blank screen on any tab

### 2.2 AI FAB
- [ ] AI FAB is visible on all 4 shell tabs (Home, CWA, Table, Sessions)
- [ ] Tap AI FAB — navigates to AI Chat screen (`/ai`)
- [ ] AI Chat screen has **no bottom nav**
- [ ] Back from AI Chat returns to the previous tab
- [ ] AI FAB shows a gold sparkles icon and has a pill shape

### 2.3 Full-screen routes (no bottom nav)
- [ ] `/ai` — no bottom nav visible
- [ ] `/streak` — no bottom nav visible
- [ ] `/insights` — no bottom nav visible
- [ ] `/settings` — no bottom nav visible
- [ ] `/ai/weekly-review` — no bottom nav visible
- [ ] `/course/:courseCode` — no bottom nav visible
- [ ] `/timetable/import` — no bottom nav visible
- [ ] `/cwa/manual-entry` — no bottom nav, no AI FAB visible
- [ ] `/subscribe` — no bottom nav visible

### 2.4 Back navigation
- [ ] From AI Chat (opened via FAB), press system back — returns to the previous tab
- [ ] From Streak (opened via drawer), press system back — returns to Today
- [ ] From Insights (opened via drawer), press system back — returns to Today
- [ ] From Settings, press system back — returns to the screen you came from
- [ ] From Weekly Review, press system back — returns to the previous screen
- [ ] From Course Hub, press system back — returns to the screen that opened it
- [ ] From any bottom nav tab (Home, CWA, Table, Sessions), press system back — exits to phone launcher (expected)
- [ ] No "back press" results in a blank screen

### 2.5 Bottom nav content clearance
- [ ] Shell tabs render full height
- [ ] Content on each tab scrolls fully above the floating bottom nav, AI FAB, and mini timer (when active)
- [ ] No content permanently hidden behind the nav bar
- [ ] No persistent dead band at the bottom of any tab

---

## 3. Home Screen (Today)

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

## 4. CWA Screen

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

### 4.8 AI Coaching
- [ ] In the "Course performance" section header, tap the **"Coach"** button (sparkles icon)
- [ ] `CwaCoachSheet` opens with AI-generated advice
- [ ] Advice is relevant to your current courses and gap
- [ ] Sheet dismisses on back/swipe

### 4.9 Cumulative mode
- [ ] Switch to **Cumulative** mode
- [ ] Cumulative CWA summary displayed
- [ ] Past semesters / academic history visible (if data exists)
- [ ] Total credits or history/trend context shown
- [ ] Existing cumulative actions still work

### 4.10 Bottom-nav / overflow
- [ ] Add Course not hidden behind nav
- [ ] Lower CWA content scrolls fully above the floating bottom nav
- [ ] No overflow on hero card or stats cards
- [ ] Semester/Cumulative switcher does not overlap with course list

---

## 5. CWA Import / Manual Entry

### 5.1 Import bottom sheet
- [ ] Tap the **Import** action in the CWA AppBar
- [ ] A polished rounded bottom sheet opens
- [ ] Background dims behind the sheet
- [ ] Drag handle is visible
- [ ] Four tappable rows shown: **Take Photo**, **Upload Image**, **Choose PDF**, **Enter Manually**
- [ ] Each row shows a clear icon
- [ ] Swiping down or tapping outside dismisses the sheet safely

### 5.2 Registration Slip Import (Semester mode)
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

### 5.3 Result Slip Import (Cumulative mode)
- [ ] Switch to **Cumulative** mode
- [ ] Tap **Import** → **Take Photo**, **Upload Image**, or **Choose PDF**
- [ ] `ResultSlipImportScreen` opens
- [ ] Select a valid result slip image → loading state
- [ ] **Label step** appears — text field with placeholder "e.g. Year 1 Sem 1"
- [ ] Quick-pick chips shown (Year 1 Sem 1 … Year 4 Sem 2)
- [ ] Tap **Continue to Review** → Review screen appears
- [ ] Review screen shows: semester label, courses found count, CWA chips
- [ ] Each course shows: code, name, mark input, grade dropdown, credit stepper
- [ ] Grades are colour-coded (A=green, F=red, etc.)
- [ ] Tap **"Import N courses"** → saving → Done screen
- [ ] Tap Done → returns to CWA or PastSemestersScreen
- [ ] Cumulative CWA on main CWA screen reflects the imported semester

### 5.4 Manual Entry screen
- [ ] From **Semester** mode, tap **Import** → **Enter Manually**
- [ ] Full-screen `Enter Courses Manually` page opens
- [ ] Bottom navigation is **not** visible
- [ ] AI FAB is **not** visible
- [ ] Segmented switcher shows **Semester** and **Cumulative**
- [ ] Default mode matches the CWA mode before opening
- [ ] Semester information card is visible
- [ ] At least one course card is visible by default
- [ ] Tap **Add Another Course** — a new course card appears
- [ ] Tap **Remove Course** — that card disappears
- [ ] Live Summary updates when course fields change

### 5.5 Manual Entry validation
- [ ] Empty course code shows validation
- [ ] Empty course title shows validation
- [ ] Non-numeric or zero credits show validation
- [ ] Non-numeric or out-of-range score shows validation
- [ ] Duplicate course code shows a warning
- [ ] Duplicate course code does not silently save duplicate data

### 5.6 Manual Entry save / cancel
- [ ] Tap **Cancel** — returns safely to CWA
- [ ] Tap **Back** with unsaved changes — discard confirmation appears
- [ ] Discard confirmation behaves safely (cancel keeps editing, discard returns to CWA)
- [ ] Fill valid values, tap **Save Courses**
- [ ] Screen closes back to CWA
- [ ] Newly saved courses appear in CWA course list
- [ ] CWA refreshes immediately after save

### 5.7 Manual Entry keyboard and scroll
- [ ] Screen scrolls correctly on a small device
- [ ] Opening the keyboard does not cover the active field or the bottom action area
- [ ] Sticky `Cancel` and `Save Courses` actions remain usable on a small screen
- [ ] No RenderFlex overflow while entering data

### 5.8 Past Semesters management
- [ ] Semester card is collapsed by default — tap to expand
- [ ] Each course row shows: code, name, mark field, credit stepper, grade dropdown — all editable inline
- [ ] Edit a grade inline → CWA badge recalculates immediately
- [ ] Tap **delete icon** on semester card → confirmation dialog appears
- [ ] Confirm delete → semester card disappears; cumulative CWA updates
- [ ] Import a second past semester — both cards appear; cumulative CWA includes both

---

## 6. Table / Timetable

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
- [ ] Final timetable content scrolls above the floating bottom nav and AI FAB
- [ ] No persistent blank band remains above the navbar
- [ ] Bottom nav does not hide the last timetable entry

### 6.7 Timetable import — entry point
- [ ] Scanner icon is visible in the Timetable AppBar alongside the "+" button
- [ ] Tap the scanner icon → navigates to `/timetable/import` (no bottom nav visible)
- [ ] Back arrow returns to the Timetable screen without saving

---

## 7. Sessions

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

## 8. AI Chat

### 8.1 Open and basic chat
- [ ] Tap gold AI FAB → AI Chat opens as full-screen route (no bottom nav)
- [ ] Premium header with back navigation visible
- [ ] Chat input field is at the bottom
- [ ] Empty state / starter prompts visible (if implemented)
- [ ] Type a study-related question (e.g. "How should I prepare for my exams?")
- [ ] Tap **Send** — message appears as a user bubble on the right
- [ ] Typing indicator (dots) appears briefly
- [ ] AI response appears on the left
- [ ] Response is readable, relevant, no crash

### 8.2 Markdown and math rendering
- [ ] Ask **"Explain compound interest with the formula"** — response uses **bold** text and bullet points rendered correctly (not raw `**` or `-`)
- [ ] Ask **"What is the quadratic formula?"** — formula renders as typeset math (not raw LaTeX)
- [ ] Ask **"Show me step-by-step Gaussian elimination on a 2×2 system"** — display math blocks (`$$...$$`) render centred, no red crash screen
- [ ] Ask **"What are the roots of x² - 5x + 6 = 0, show working"** — mixed markdown + math renders without crash
- [ ] Confirm no red error screen on any math-heavy response
- [ ] Inline code in AI responses renders with monospace grey background
- [ ] If AI outputs an unparseable LaTeX expression, it falls back to monospace plain text (not a crash)

### 8.3 Long response and scrolling
- [ ] Send a prompt that produces a long multi-paragraph response
- [ ] Chat scrolls smoothly
- [ ] Input is not hidden by the keyboard

### 8.4 Usage counter
- [ ] A counter near the top or input shows remaining free queries (e.g. "2 queries left today")
- [ ] Counter decrements with each message sent
- [ ] After using all free queries, a **"Upgrade to Premium"** gate card appears

### 8.5 Chat history drawer
- [ ] Tap the **History icon** in the AppBar (top right)
- [ ] End drawer opens with list of past conversations
- [ ] Tap a past conversation — chat loads with previous messages
- [ ] Swipe drawer closed
- [ ] Delete chat confirmation works (if implemented)

### 8.6 Back navigation
- [ ] Press system back — returns to the previous tab (not phone launcher)

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
- [ ] CWA Coach sheet — AI advice loads, dismisses on back/swipe
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

### 11.1 Settings
- [ ] Settings screen loads without crash
- [ ] All notification toggle switches visible: Study Reminders, Streak Alerts, Milestone Alerts, Weekly Review prompt
- [ ] Each toggle persists if you leave and return to Settings
- [ ] Tap the **daily reminder time card** → TimePicker dialog opens
- [ ] Select a time (e.g. 8:00 PM) → card updates
- [ ] Tap **"Cancel all notifications"** → confirmation → all scheduled notifications cleared
- [ ] DEV premium toggle visible (debug builds only)
- [ ] No overflow on the settings screen

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
- [ ] Long AI response — chat scrolls smoothly, no crash

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
- [ ] Scroll to bottom of AI Chat — all messages visible
- [ ] Scroll to bottom of Course Hub tabs — all content visible

### 12.6 No internet — AI features
- [ ] Turn on airplane mode
- [ ] Go to AI Chat — type a message and send → error message (not crash)
- [ ] Error message is user-friendly (not a raw stack trace)
- [ ] Go to CWA Coach → error message shown, app does not hang
- [ ] Go to Timetable Import → pick an image → offline error shown
- [ ] Go to Registration Slip Import → pick an image → offline error shown
- [ ] Turn airplane mode off → retry each feature → works normally

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

### 13.2 Build APK
- [ ] `flutter build apk --debug` — builds successfully
- [ ] `flutter build apk --release` — builds successfully (if signing configured)
- [ ] APK installs on real device
- [ ] App opens on real device without crash

### 13.3 Device testing
- [ ] Installed APK on real Android device
- [ ] Sent APK to at least one friend/tester
- [ ] Tester feedback collected
- [ ] Critical crashes documented and fixed
- [ ] Major overflow issues documented and fixed

### 13.4 Pre-store checks
- [ ] Privacy policy reviewed for Play Store compliance
- [ ] App permissions reviewed (notifications, camera, storage)
- [ ] App icon and name correct
- [ ] No test/debug data visible to users
- [ ] API keys in `.env` (not hardcoded)

---

## Sign-Off

| Section | Status | Notes |
|---|---|---|
| 1. Fresh Install / Launch | | |
| 2. App Shell / Navigation | | |
| 3. Home Screen (Today) | | |
| 4. CWA Screen | | |
| 5. CWA Import / Manual Entry | | |
| 6. Table / Timetable | | |
| 7. Sessions (Normal + Pomodoro) | | |
| 8. AI Chat | | |
| 9. Course Hub | | |
| 10. Modals / Bottom Sheets / Dialogs | | |
| 11. Settings / Streak / Insights / Weekly Review | | |
| 12. Edge Case Testing | | |
| 13. Release / Beta Readiness | | |

**Tester:** ___________________
**Date:** ___________________
**Build / Commit:** ___________________
**Device / Emulator:** ___________________
**Android Version:** ___________________
