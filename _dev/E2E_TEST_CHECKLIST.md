# CampusIQ — End-to-End User Test Checklist

Use this document to manually test the app as a real user would, from first launch through every major feature. Work through each section in order — later sections depend on data created in earlier ones (e.g. courses added in CWA are used in Sessions and Exam Prep).

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
- [ ] Lands on the **Plan** screen (not a blank screen)
- [ ] Bottom navigation bar shows 6 tabs: Plan, CWA, Table, Sessions, Streak, AI

### 1.2 Bottom navigation
- [ ] Tap **CWA** — navigates to CWA screen
- [ ] Tap **Table** — navigates to Timetable screen
- [ ] Tap **Sessions** — navigates to Sessions screen
- [ ] Tap **Streak** — navigates to Streak screen
- [ ] Tap **AI** — navigates to AI Chat screen
- [ ] Tap **Plan** — navigates back to Plan screen
- [ ] Active tab is visually highlighted
- [ ] No crash or blank screen on any tab

---

## 2. CWA Target Planner (`/cwa`)

> **Do this before Sessions and AI features** — courses added here appear in those screens.

### 2.1 Empty state
- [ ] Screen shows empty state message and a "+" FAB

### 2.2 Add a course
- [ ] Tap the **FAB (+)**
- [ ] `AddCourseSheet` opens from the bottom
- [ ] Fill in: Course name (e.g. "Engineering Mathematics"), credit hours (e.g. 3), expected score (e.g. 72)
- [ ] Tap **Save**
- [ ] Course card appears in the list
- [ ] Repeat — add at least **3 courses** with different credit hours and scores

### 2.3 CWA calculation
- [ ] Summary bar at the top shows a projected CWA
- [ ] Tap the **Target CWA** area — slider dialog opens
- [ ] Drag the slider to set a target (e.g. 75)
- [ ] Confirm — summary bar now shows Target, Projected, and Gap
- [ ] Adjust the score slider on a course card — projected CWA updates live

### 2.4 High-impact indicator
- [ ] One course card should show a "high impact" indicator (the one whose score change affects CWA most)

### 2.5 Edit and delete
- [ ] Tap the **edit icon** on a course card — `AddCourseSheet` opens pre-filled
- [ ] Change the score, save — card updates
- [ ] Delete a course (swipe or delete button) — card disappears, CWA recalculates
- [ ] Re-add the course so you have at least 3 for later tests

### 2.6 AI Coaching
- [ ] Tap **"Get AI Coaching"** button
- [ ] `CwaCoachSheet` opens with AI-generated advice
- [ ] Advice is relevant to your current courses and gap
- [ ] Sheet dismisses on back/swipe

---

## 3. Timetable (`/timetable`)

### 3.1 Day selector
- [ ] Horizontal day picker shows all 7 days
- [ ] Tap a different day — grid updates (may be empty for that day)
- [ ] Today is highlighted by default

### 3.2 Three-page swipe views
- [ ] Default view is **"Both"** (classes + personal blocks)
- [ ] Swipe **left** → switches to **Personal Only** view
- [ ] Swipe **right** from Both → switches to **Classes Only** view
- [ ] Page indicator at the bottom updates correctly

### 3.3 Add a class slot
- [ ] Swipe to **Classes Only** view (or Both)
- [ ] Tap the FAB — label reads **"Add Class"**
- [ ] `AddSlotSheet` opens
- [ ] Fill in: Course (e.g. "Engineering Mathematics"), day, start time, end time, venue
- [ ] Tap **Save** — slot appears on the grid for that day/time
- [ ] Add at least **2 class slots** on different days

### 3.4 Add a personal block
- [ ] Swipe to **Personal Only** view
- [ ] Tap the FAB — label reads **"Add Block"**
- [ ] `AddPersonalSlotSheet` opens
- [ ] Fill in: Label (e.g. "Gym"), day, start time, end time
- [ ] Tap **Save** — personal block appears on the grid

### 3.5 Tap on an existing slot
- [ ] Tap a class slot on the grid → `SlotDetailSheet` opens with details
- [ ] Edit the venue — saves correctly
- [ ] Tap a personal block → `PersonalSlotDetailSheet` opens
- [ ] Delete the personal block — it disappears from the grid

### 3.6 Tap empty grid area
- [ ] Tap an empty time cell on the grid
- [ ] Add sheet opens with that time pre-filled

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

### 4.6 History management
- [ ] History list shows saved sessions
- [ ] Swipe a history item to **delete** it — it disappears

### 4.7 Plan tab
- [ ] Tap the **Plan** tab inside Sessions
- [ ] AI study plan displays (or empty state if no data yet)

### 4.8 Insights
- [ ] Tap the **Insights** icon in the AppBar (if visible)
- [ ] Navigates to `/insights` screen with insight cards
- [ ] Back arrow returns to Sessions

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

### 6.3 Usage counter
- [ ] A counter near the top or input shows remaining free queries (e.g. "2 queries left today")
- [ ] Counter decrements with each message sent
- [ ] After using all free queries, a **"Upgrade to Premium"** gate card appears

### 6.4 Chat history drawer
- [ ] Tap the **History icon** in the AppBar (top right)
- [ ] End drawer opens with list of past conversations
- [ ] Tap a past conversation — chat loads with previous messages
- [ ] Swipe drawer closed

### 6.5 Exam Prep card
- [ ] On the AI screen, an **"Exam Prep"** card or button is visible
- [ ] Tap it — navigates to `/ai/exam-prep`
- [ ] Back arrow returns to AI screen

---

## 7. Exam Prep Generator (`/ai/exam-prep`)

> Requires courses from Step 2.

### 7.1 Course selection
- [ ] Course chips (FilterChips) are listed — your CWA courses appear
- [ ] Tap a course chip to select it (chip highlights)
- [ ] Tap again to deselect

### 7.2 Question type selection
- [ ] Three buttons visible: **MCQ**, **Short Answer**, **Flashcard**
- [ ] Tap each — selected button is highlighted
- [ ] Default is MCQ

### 7.3 Optional topic input
- [ ] Text field with placeholder "e.g. Thevenin's Theorem" is visible
- [ ] Type a topic — input is accepted
- [ ] Leave blank — generation should still work

### 7.4 Generate questions (MCQ)
- [ ] Select a course, select **MCQ**, (optionally enter a topic)
- [ ] Tap **"Generate 5 Questions"**
- [ ] Button shows a loading spinner while generating
- [ ] Button is disabled while loading (no double-tap spam)
- [ ] 5 MCQ question cards appear below
- [ ] Each card shows: question text + 4 radio button options

### 7.5 Answer reveal (MCQ)
- [ ] Tap a radio option — it selects
- [ ] Tap **"Reveal Answer"** — correct option highlighted, explanation shown

### 7.6 Short Answer questions
- [ ] Change type to **Short Answer**, tap **"Generate 5 Questions"**
- [ ] Cards show question text and a **"Reveal Answer"** button
- [ ] Tap reveal — answer text appears below

### 7.7 Flashcards
- [ ] Change type to **Flashcard**, tap **"Generate 5 Questions"**
- [ ] Cards show the front (question) of the flashcard
- [ ] Tap a flashcard — it **flips** to show the answer (animation)
- [ ] Tap again — flips back to the question

### 7.8 Generate more
- [ ] After first batch, button reads **"Generate 5 More"**
- [ ] Tap it — 5 additional questions appear below existing ones

### 7.9 Clear questions
- [ ] Tap the **Clear** button in the AppBar
- [ ] All questions are removed
- [ ] Button label resets to "Generate 5 Questions"

---

## 8. Plan Screen (`/plan`)

> Works best after adding courses (Step 2) and timetable slots (Step 3).

### 8.1 Generate a daily plan
- [ ] Navigate to **Plan** tab
- [ ] Tap the **Generate** button (AppBar)
- [ ] Loading state is shown (spinner or shimmer)
- [ ] Plan cards appear organized into sections: Classes, Study, Personal
- [ ] Tasks are sensible (study tasks for your courses, class tasks matching timetable)

### 8.2 Task sections
- [ ] **Classes section** (blue): shows timetabled classes for today
- [ ] **Study section** (green/orange): shows AI-suggested study tasks
- [ ] **Personal section** (yellow): shows personal time blocks from timetable

### 8.3 Mark a task complete
- [ ] Tap a task — it marks as complete (checkbox/strikethrough)
- [ ] Progress bar at the top increments

### 8.4 Add a manual task
- [ ] Tap the **small FAB** (pencil/plus icon stacked above the main FAB)
- [ ] `AddManualTaskSheet` opens
- [ ] Fill in a task name and optionally a course
- [ ] Save — task appears in the plan

### 8.5 Dismiss/delete a task
- [ ] Swipe a task tile left or right to dismiss it
- [ ] Task is removed from the list

### 8.6 Exam Mode activation
- [ ] Tap the **main FAB** (exam/fire icon)
- [ ] `ExamModeActivationSheet` opens (if exams are scheduled) OR `ExamManagerSheet` opens (to add exams)
- [ ] Add an exam: subject, date (future date)
- [ ] After saving, **exam mode banner** appears at the top of the Plan screen
- [ ] Banner shows exam name + countdown
- [ ] Plan icon in bottom nav changes to a fire/flame icon

### 8.7 Exam mode progress
- [ ] With exam mode active, per-exam progress bars are shown in the Plan screen
- [ ] Completing study tasks increments the exam's progress bar

### 8.8 Exit exam mode
- [ ] On the banner, tap **Exit**
- [ ] Exam mode deactivates
- [ ] Banner disappears, plan icon reverts to normal

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

### 11.4 CWA course → Exam Prep course chips
- [ ] Go to Exam Prep
- [ ] Course chips match the courses from CWA

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
- [ ] From Exam Prep, press system back — returns to AI Chat (not to Plan or a blank screen)
- [ ] From Settings, press system back — returns to the screen you came from
- [ ] From Weekly Review, press system back — returns to AI Chat
- [ ] No "back press" results in a blank screen

---

## 13. Performance & Stability

- [ ] Scroll the CWA course list quickly — no jank or dropped frames
- [ ] Scroll the Streak heatmap — no jank
- [ ] Scroll the Sessions history list with 10+ items — smooth
- [ ] Open and close bottom sheets 5+ times rapidly — no crashes or ghost sheets
- [ ] Switch between all 6 bottom nav tabs rapidly — no crash, state is preserved
- [ ] Leave the session timer running for 5+ minutes — timer is still accurate on return
- [ ] Kill and reopen the app during an active session — session state is restored (timer continues or session is recoverable)

---

## Sign-Off

| Section | Status | Notes |
|---|---|---|
| 1. App Launch & Navigation | | |
| 2. CWA Planner | | |
| 3. Timetable | | |
| 4. Study Sessions | | |
| 5. Streak System | | |
| 6. AI Coach & Chat | | |
| 7. Exam Prep Generator | | |
| 8. Plan Screen | | |
| 9. Settings | | |
| 10. Weekly Review | | |
| 11. Cross-Feature Tests | | |
| 12. Edge Cases | | |
| 13. Performance | | |

**Tester:** ___________________  
**Date:** ___________________  
**Build / Commit:** ___________________  
**Device / Emulator:** ___________________  
**Android Version:** ___________________
