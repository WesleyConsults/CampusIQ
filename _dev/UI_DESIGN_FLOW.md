# CampusIQ — UI Design Flow (Figma Redesign Reference)

This document maps every screen, state, overlay, and transition in CampusIQ v1.0. Use it to create linked Figma frames for each page and modal.

---

## Global Shell (AppWrapper)

The app opens into a ShellRoute with a persistent bottom navigation bar and a global AI FAB. A floating mini-timer appears above the shell when a study session is active.

### Bottom Navigation Bar (4 destinations)

| Tab | Icon | Route | Description |
|-----|------|-------|-------------|
| Dashboard | `dashboard` | `/plan` | Daily Study Plan (initial route) |
| CWA | `calculate` | `/cwa` | CWA Target Planner |
| Table | `calendar_month` | `/timetable` | Class Timetable |
| Sessions | `timer` | `/sessions` | Study Session Tracker |

### Global FAB

- **AI FAB**: Floating action button (bottom-right, above nav bar). Always visible inside the shell. Opens `/ai` (AI Chat).
- Visible on: Dashboard, CWA, Table, Sessions tabs.
- Hidden on: full-screen push routes (Course Hub, Timetable Import, Weekly Review, Settings, Subscribe, AI Chat itself, Slip Import screens).

### Floating Mini-Timer

- **When visible**: Only when a study session is active (timer running).
- **Position**: Above the bottom nav bar, floating as a pill-shaped overlay.
- **Content during Normal mode**: Course code + elapsed time (e.g., "MATH101 · 12:34").
- **Content during Pomodoro Focus**: Round + "Focus" + countdown (e.g., "R2 Focus · 18:42") on primary blue.
- **Content during Pomodoro Break**: Round + "Break" + countdown (e.g., "R2 Break · 04:31") on green.
- **Tap behaviour**: Navigates to `/sessions` (the active timer screen).

### AppBar Patterns

Most screens show a standard AppBar with:
- Screen title
- Optional action icons (settings gear, scanner, history, etc.)

Streak indicator may appear in AppBar headers.

---

## 1. Dashboard / Daily Plan (`/plan`) — Initial Route

The landing screen when the app opens. Shows the student's daily study plan.

### 1.1 States

**Loading State**
- Centred `CircularProgressIndicator`.
- AppBar title: "Today's Plan".

**Empty State (No Plan Generated)**
- Date header showing today's date.
- Empty state illustration or message: "No plan for today."
- "Generate Plan" button (calls AI to create a plan based on timetable free blocks).
- "Add Task" FAB or button for manual task entry.
- If free-tier user: PlanFreeGateCard shown instead of generate button.

**Has Plan (With Tasks)**
- Date header: today's date (e.g., "Saturday, 3 May 2026").
- `PlanProgressBar`: completed/total tasks with a celebration message when all done.
- Section: **Classes** — list of `PlanTaskTile` with type "attend". Each tile has:
  - Course code + name
  - Time slot
  - Checkbox (toggle completed/pending)
- Section: **Study** — list of `PlanTaskTile` with type "study". Each tile has:
  - Course code + name
  - Suggested time block
  - Checkbox
- "Generate Plan" button (regenerate).
- "Add Task" FAB → opens AddManualTaskSheet.

**Error State**
- `ErrorRetryWidget` with message and "Try Again" button.
- Retry re-fetches the plan.

**Premium Gate (Free-tier users)**
- `PlanFreeGateCard`: message explaining AI plan generation is premium.
- Manual task adding remains available.
- "Upgrade" button → navigates to `/subscribe`.

### 1.2 Sheets & Dialogs

**AddManualTaskSheet** (bottom sheet)
- Text field: task description.
- Dropdown: course selector (pulled from CWA courses).
- Segmented toggle: task type (Attend Class / Study).
- Time picker (optional).
- "Add Task" button.

### 1.3 Navigation Destinations from this Screen

| Trigger | Destination |
|---------|-------------|
| Bottom nav: CWA | `/cwa` |
| Bottom nav: Table | `/timetable` |
| Bottom nav: Sessions | `/sessions` |
| AI FAB | `/ai` |
| "Upgrade" on gate card | `/subscribe` |
| AppBar gear icon | `/settings` |

---

## 2. CWA Planner (`/cwa`)

Course-weighted average target planner. Two viewing modes toggled via `SegmentedButton`.

### 2.1 States

**Loading State**
- `CircularProgressIndicator`.
- AppBar title: "CWA Planner".

**Empty State (No Courses — Semester Mode)**
- Empty illustration: "No courses added yet."
- "Add Course" FAB.
- AppBar actions: scanner icon (registration slip import), view mode toggle (Semester | Cumulative).

**Has Courses (Semester Mode)**
- AppBar title: "CWA Planner".
- AppBar actions:
  - Scanner icon → opens Registration Slip Import.
  - History icon (only in Cumulative mode).
- `SegmentedButton`: **Semester** | **Cumulative**.
- `CwaSummaryBar`: Projected CWA, Target CWA, gap indicator.
- Scrollable list of `CourseCard` widgets. Each card shows:
  - Course code + name.
  - Credit hours badge.
  - Expected score (drag slider or tap to edit).
  - "High Impact" badge (if tied for highest credit hours).
  - PopupMenuButton: Edit, Delete, **Open Workspace**.
- "Add Course" FAB → opens AddCourseSheet.
- Drag score slider → live CWA recalculation.
- When slider differs from saved value: "Explain" chip appears → taps calls AI what-if explainer.

**Has Past Semesters (Cumulative Mode)**
- Same `SegmentedButton` (Cumulative selected).
- AppBar actions: scanner icon → opens Result Slip Import. History icon → opens Past Semesters Screen.
- `CwaSummaryBar` shows: Cumulative CWA, total credit hours, semester count.
- List of past semester cards (expandable).
- Current semester courses below.
- "Add Past Semester" button (if none) or scanner icon.

**Error State**
- `ErrorRetryWidget` with "Try Again".

### 2.2 Sheets & Dialogs

**AddCourseSheet** (bottom sheet)
- Text fields: Course Code, Course Name.
- Credit Hours stepper (1–6).
- Score slider (0–100) or text input.
- "Add Course" button.
- Validation: course code and name required.

**Edit Course Sheet** (same layout as Add, pre-filled).

**CwaCoachSheet** (bottom sheet)
- Trigger: "Coach" chip/button on CWA screen.
- Loading: skeleton/spinner while AI responds.
- Content: AI-generated academic advice based on student's full course context.
- "Ask a follow-up" button → seeds AI chat with coaching advice as initial message, navigates to `/ai`.
- Premium gate: if free quota exhausted, shows `PremiumGateWidget`.

**WhatIfExplainer**
- Trigger: "Explain" chip appears when score slider changes from saved value.
- Loading: small inline spinner on chip.
- Content: AI explanation of how the score change impacts CWA.
- Cached per score value — re-drag to same value shows cached explanation.

**TargetCWADialog**
- Trigger: tap on target CWA in summary bar.
- Slider + `−`/`+` stepper buttons (±1 step).
- Current target display.
- "Save" / "Cancel" buttons.

### 2.3 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Course card → "Open Workspace" | `/course/:courseCode` |
| Scanner icon (Semester mode) | Registration Slip Import (pushed) |
| Scanner icon (Cumulative mode) | Result Slip Import (pushed) |
| History icon (Cumulative mode) | Past Semesters Screen (pushed) |
| Bottom nav tabs | `/plan`, `/timetable`, `/sessions` |
| AI FAB | `/ai` |

---

## 3. Timetable (`/timetable`)

Single-layer class timetable grid (6AM–8PM, hourly rows).

### 3.1 States

**Loading State**
- `CircularProgressIndicator`.
- AppBar title: "Timetable".

**Empty State (No Slots)**
- Empty illustration: "No classes scheduled."
- AppBar actions: "+" (add slot), scanner icon (import timetable image).
- Day selector pills: Mon–Sun (current day selected by default).

**Has Slots**
- AppBar title: "Timetable".
- AppBar actions: "+" (add slot), scanner icon.
- Day selector row: horizontal scrollable pills (Mon/Tue/Wed/Thu/Fri/Sat/Sun). Current day highlighted.
- Swipe left/right on grid to navigate days.
- Time grid: 6AM–8PM, 14 rows at 60px/hr.
- `TimetableSlotCard` on grid: shows course code, name, venue. For slots ≥ 80 min: also start time + type.
- Overlapping slots: split side-by-side in equal columns.
- `FreeBlockIndicator`: shown in gaps where no class is scheduled.
- Tap slot → opens `SlotDetailSheet`.

**Error State**
- `ErrorRetryWidget` with "Try Again".

### 3.2 Sheets & Dialogs

**AddSlotSheet** (bottom sheet)
- Fast-select CWA course chips (auto-fill course code, name).
- Or manual entry fields.
- Day dropdown (Mon–Sun).
- Start time picker, End time picker.
- Venue text field.
- Slot type dropdown: Lecture / Practical / Tutorial.
- Colour picker (cycling defaults from `TimetableConstants`).
- "Add Slot" button.

**SlotDetailSheet** (bottom sheet)
- Course code + name.
- Time, day, venue, type.
- Colour indicator.
- "Open Workspace" `OutlinedButton` → navigates to `/course/:courseCode`.
- "Delete" button (with confirmation).

### 3.3 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Scanner icon | `/timetable/import` (full-screen push) |
| Slot detail → "Open Workspace" | `/course/:courseCode` |
| "+" button | AddSlotSheet |
| Bottom nav tabs | `/plan`, `/cwa`, `/sessions` |
| AI FAB | `/ai` |

---

## 4. Session Tracker (`/sessions`)

Study session timer + analytics dashboard.

### 4.1 States (Timer)

**Idle State (No Active Session)**
- `ActiveTimerCard`: large start button.
- Mode toggle: **Normal** | **Pomodoro** (segmented control).
- Normal mode: "Start Session" button.
- Pomodoro mode: shows "4 rounds · 25 min focus / 5 min break" info. "Start Pomodoro" button.
- Course picker: tap to select course → opens `CoursePickerSheet`.
- Selected course chip shown below toggle.

**Running — Normal Mode**
- Card turns primary/accent colour.
- Count-up timer display: `HH:MM:SS`.
- Course code + name shown prominently.
- "Stop" button (red/outlined).
- Mini-timer appears in shell.

**Running — Pomodoro Focus Phase**
- Card colour: primary blue.
- Countdown display: `MM:SS` remaining in current focus round.
- Round progress dots (e.g., ● ○ ○ ○ for round 1 of 4).
- Label: "Focus — Round X of 4".
- "Stop" button.
- Mini-timer in shell shows "RX Focus · MM:SS".

**Running — Pomodoro Break Phase**
- Card colour: green.
- Countdown display: `MM:SS` remaining in break.
- Label: "Break — X min".
- "Skip Break" button.
- Mini-timer turns green with "RX Break · MM:SS".

**Complete — Pomodoro**
- Card shows: "Session Complete!".
- Summary: rounds completed, total focus minutes.
- Celebration animation.

### 4.2 States (Analytics)

**Loading State**
- Skeleton cards for charts and lists.

**Empty State (No Past Sessions)**
- "No study sessions recorded yet."
- Analytics cards show zeros.

**Has Data**
- `AnalyticsSummaryCard`: today's total, weekly total, session count.
- `WeeklyBarChart`: 7-day bar chart (Mon–Sun).
- `CourseBreakdownCard`: per-course totals with progress bars.
  - Tap a course row → navigates to `/course/:courseCode`.
- `SessionTile` list: reverse-chronological session history.
  - Each tile: date, course code, duration, session type icon (hourglass for Pomodoro).
  - Swipe-to-delete with confirmation.

**Error State**
- `ErrorRetryWidget`.

### 4.3 Sheets & Dialogs

**CoursePickerSheet** (bottom sheet)
- Merged list: CWA courses + today's timetable slots.
- Search/filter field.
- Each item: course code + name.
- Tap to select → closes sheet, updates selected course.

### 4.4 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Course row in breakdown | `/course/:courseCode` |
| "Insights" button | `/insights` |
| Bottom nav tabs | `/plan`, `/cwa`, `/timetable` |
| AI FAB | `/ai` |
| Mini-timer tap (from any tab) | `/sessions` |

---

## 5. AI Chat (`/ai`)

Full-screen AI coach chat interface (pushed route, no bottom nav).

### 5.1 States

**Loading State**
- AppBar: "AI Coach".
- Chat area: skeleton/spinner while loading chat history.

**Empty State (No Chats)**
- Welcome message from AI coach.
- Context-aware greeting (references student's courses, CWA).
- Text input field at bottom.
- Usage counter chip: "X/3 free today".

**Has Chat History**
- AppBar: "AI Coach" + drawer/menu icon (opens chat history).
- Message list:
  - User bubbles (right-aligned, primary colour).
  - AI bubbles (left-aligned, surface colour).
  - AI bubbles support **Markdown** (bold, italic, lists, code) and **LaTeX math** (inline `$...$` and display `$$...$$`).
  - Typing indicator (animated dots) when AI is responding.
- Text input field + send button at bottom.
- `UsageCounterChip`: "X/3 free today".
- `WeeklyReviewBanner`: card/button directing to `/ai/weekly-review`.

**Premium Gate (Quota Exhausted)**
- `PremiumGateWidget` replaces text input.
- Message: "You've used all 3 free prompts today."
- "Upgrade to Premium" button → `/subscribe`.

**Error State**
- `ErrorRetryWidget` if chat history fails to load.
- Offline: `OfflineBanner` shown. AI features blocked with offline message.

### 5.2 Sheets & Drawers

**ChatHistoryDrawer** (end drawer)
- List of past chat sessions.
- Each item: title (auto-generated from first message), date, preview.
- Tap to switch to that conversation.
- Long press or swipe to delete.

### 5.3 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Weekly Review banner | `/ai/weekly-review` |
| "Upgrade" on premium gate | `/subscribe` |
| AppBar settings gear | `/settings` |
| Back | Previous route (shell tab) |
| "Ask a follow-up" (from CWA coach) | Seeded chat in this same screen |

---

## 6. Streak System (`/streak`)

### 6.1 States

**Loading State**
- Skeleton cards.

**Has Data**
- AppBar: "Streaks".
- `StreakHeroCard`: current study streak (large number), longest streak, alive/broken indicator.
- `NextMilestoneCard`: next target (e.g., "7 days"), days remaining.
- `MilestoneGrid`: 12 milestones (3, 7, 14, 21, 30, 40, 50, 60, 70, 80, 90, 100 days).
  - Locked: greyed out with lock icon.
  - Unlocked: coloured with check/celebration.
- `ActivityHeatmap`: calendar-style grid of study activity (current + past months).
- `CourseStreakList`: per-course streak breakdown.
- `AttendanceTracker`: mark/unmark attendance for each day.

**Error State**
- `ErrorRetryWidget`.

### 6.2 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Back | Previous route |
| Bottom nav tabs | `/plan`, `/cwa`, `/timetable`, `/sessions` |

---

## 7. Insights (`/insights`)

Reached via button on Sessions screen.

### 7.1 States

**Loading State**
- Skeleton cards.

**Empty State (Not Enough Data)**
- "Not enough study data yet. Complete a few sessions to see insights."

**Has Insights**
- AppBar: "Insights".
- List of `InsightCard` widgets (sorted: warnings first, then positives, then neutrals).
- Card types:
  - **Best study day**: "Your best study day is Wednesday (4.2 hrs avg)."
  - **Neglected course**: "MATH101 hasn't been studied in 8 days."
  - **Best study window**: "You're most productive between 7PM–9PM."
  - **Late-night efficiency**: "Your late sessions (after 9PM) average 22 min — try studying earlier."
  - **Consistent course**: "You've studied CSCI201 5 times in the last 14 days — great consistency!"
  - **Weekly trend**: "You studied 40% more this week compared to last week."
- Each card has icon, colour coding (warning = amber, positive = green, neutral = grey).
- Animated entry (staggered fade + slide).

**Error State**
- `ErrorRetryWidget`.

### 7.2 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Back | `/sessions` |

---

## 8. Settings (`/settings`)

### 8.1 States

- AppBar: "Settings".
- Section: **Notifications**
  - Toggle: Study Reminders (on/off).
  - Toggle: Streak Alerts (on/off).
  - Toggle: Milestone Alerts (on/off).
  - Toggle: Weekly Review Prompt (on/off).
  - Daily reminder time picker (tap to open time dialog).
  - "Cancel All Notifications" button (with confirmation dialog).
- Section: **Account** (or debug section)
  - DEV Premium Toggle (visible only in debug builds) — flips `isPremium` for testing.
- Back navigation.

---

## 9. Weekly Review (`/ai/weekly-review`)

Full-screen AI-generated weekly review.

### 9.1 States

**Loading State**
- Skeleton/spinner while AI generates review.

**Has Review**
- AppBar: "Weekly Review".
- Week range header: "Apr 27 — May 3, 2026".
- Stats summary row (3 cards):
  - Total study time this week.
  - Best day.
  - Current streak.
- AI narrative section: paragraph-form summary of the week's performance.
- `ReviewSectionCard` widgets: structured review segments.
- Animated entry for each section.

**Premium Gate (Free Users)**
- `ReviewGateOverlay`: stats summary visible, AI narrative blocked.
- "Upgrade to unlock AI weekly reviews" message.
- "Upgrade" button → `/subscribe`.

**Error State**
- `ErrorRetryWidget`.

### 9.2 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Back | `/ai` |
| "Upgrade" on gate | `/subscribe` |

---

## 10. Subscribe (`/subscribe`)

### 10.1 States

- AppBar: "Premium".
- **Current state**: Stub/placeholder screen.
- Content: Premium feature list, pricing placeholder.
- "Restore Purchases" button (if applicable).
- Back navigation.

---

## 11. Course Hub Workspace (`/course/:courseCode`)

Full-screen push route (no bottom nav). 3-tab workspace for a specific course.

### 11.1 Entry Points

1. CWA screen → course card PopupMenuButton → "Open Workspace".
2. Timetable → slot detail sheet → "Open Workspace" button.
3. Sessions → course breakdown → tap course row.

### 11.2 States (Loading / Not Found)

**Loading State**
- `CircularProgressIndicator`.
- AppBar with course code (from route param).

**Not Found (Invalid courseCode)**
- Fallback Scaffold with error message and back button.

### 11.3 Tab: Overview

**Loading State**
- Skeleton cards.

**Has Data**
- Course info card: Course code, name, credit hours.
- Expected score: `LinearProgressIndicator` + grade chip (A/B/C/D/F).
- CWA impact card: contribution points, current CWA, weight percentage.
- Study stats: session count, total study time, last studied date.
- Streak mini-card: course-specific streak.
- `CourseHubContextBuilder` summary at bottom.

**Error State**
- `ErrorRetryWidget`.

### 11.4 Tab: Sessions

**Loading State**
- Skeleton chart + list.

**Empty State**
- "No sessions recorded for this course."

**Has Data**
- `WeeklyBarChart`: course-specific weekly session minutes.
- Session list: reverse-chronological, course-scoped.
- Each tile: date, duration.
- Swipe-to-delete with snackbar.

**Error State**
- `ErrorRetryWidget`.

### 11.5 Tab: Notes

**Loading State**
- Skeleton list.

**Empty State**
- "No notes yet. Tap + to add one."
- FAB: "+" (create note).

**Has Notes**
- List of note cards (title + preview + date).
- Tap note → opens `NoteEditorSheet` in edit mode (pre-filled).
- `Dismissible` swipe-to-delete with undo snackbar.
- FAB: "+" (create note).

**Error State**
- `ErrorRetryWidget`.

### 11.6 Sheets

**NoteEditorSheet** (`DraggableScrollableSheet`)
- Mode: Create (blank) or Edit (pre-filled).
- Text field: Note title.
- Text area: Note body (markdown supported).
- "Save" button.
- "Delete" button (edit mode only, with confirmation).

### 11.7 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Back | Previous route (CWA, Timetable, or Sessions) |

---

## 12. Timetable Import (`/timetable/import`)

Full-screen push route. 7-state import state machine.

### 12.1 State Machine Flow

**1. Idle State**
- AppBar: "Import Timetable".
- Instruction text: "Take a photo of your timetable or pick one from your gallery."
- Two large buttons (or cards):
  - "Take Photo" (camera icon).
  - "Pick from Gallery" (gallery icon).
- Back button in AppBar.

**2. Picking State**
- System image picker UI (camera or gallery).
- If image > 4MB: error snackbar + return to idle.

**3. Parsing State**
- AppBar: "Import Timetable".
- Centred spinner.
- Message: "Reading your timetable..."
- Back button disabled during parse.

**4. Reviewing State**
- AppBar: "Review Slots" + "X found" chip.
- Checkbox list of all extracted `TimetableSlotImport` entries.
  - Each tile: course code, course name, day, time, type, venue.
  - Toggle checkbox to include/exclude.
- Header: "Select All" / "Deselect All" TextButton.
- Bottom bar: "Import X Selected" button (count updates live).
- Back button → returns to idle (with confirmation to discard).

**5. Saving State**
- AppBar: "Import Timetable".
- Centred spinner.
- Message: "Saving your timetable..."
- Overlay, non-dismissible.

**6. Done State**
- Success illustration/icon.
- Message: "X slots imported successfully!"
- Auto-navigates to `/timetable` after short delay.
- Or: "View Timetable" button → `context.go('/timetable')`.

**7. Error State**
- Error icon + message (contextual):
  - "No timetable slots could be detected. Try a clearer image."
  - "Image is too large. Please crop and try again." (size > 4MB).
  - "The AI couldn't finish reading. Try a cropped photo."
  - "No internet connection." (offline).
- "Try Again" button → resets to idle.
- Back button → returns to idle.

### 12.2 Navigation Destinations

| Trigger | Destination |
|---------|-------------|
| Done auto-navigate | `/timetable` |
| "Try Again" | Resets to idle (stays on this screen) |
| Back (idle state) | `/timetable` |

---

## 13. Registration Slip Import (Pushed from CWA — Semester Mode)

Pushed as `MaterialPageRoute` from CWA screen (scanner icon in Semester mode).

### 13.1 State Machine Flow

**1. Idle State**
- AppBar: "Import Courses".
- Instruction: "Import your course registration slip."
- Three input options (cards/buttons):
  - "Take Photo" (camera).
  - "Pick from Gallery" (image).
  - "Pick PDF" (file picker).
- Back button.

**2. Picking State**
- Camera / Gallery / File picker system UI.

**3. Parsing State**
- Centred spinner.
- Message: "Reading your registration slip..."
- Back disabled.

**4. Reviewing State**
- AppBar: "Review Courses" + "X found" chip.
- Checkbox list of `RegistrationCourseImport` entries.
  - Each tile: course code, course name, credit hours stepper (1–6, inline).
- "Select All" / "Deselect All" header button.
- Bottom bar: "Import X Courses" button.

**5. Saving State**
- Spinner + "Adding courses..."

**6. Done State**
- Success: "X courses added!"
- Instruction: "Set your expected scores from the CWA screen."
- "Go to CWA" button → pops back to `/cwa`.

**7. Error State**
- Error message + "Try Again" → resets to idle.

---

## 14. Result Slip Import (Pushed from CWA — Cumulative Mode)

Pushed from CWA screen (scanner icon in Cumulative mode).

### 14.1 State Machine Flow

**1. Idle State**
- AppBar: "Import Results".
- Instruction: "Import a past semester result slip."
- Three input options: Camera, Gallery, PDF.
- Back button.

**2. Picking State**
- System picker.

**3. Parsing State**
- Spinner: "Reading your result slip..."

**4. Labelling State**
- AppBar: "Name This Semester".
- Text input: semester label (e.g., "Year 1 Semester 1").
- Quick-pick chips: "Year 1 Sem 1", "Year 1 Sem 2", "Year 2 Sem 1", ... "Year 4 Sem 2".
- Reported CWA chips (if extracted from slip): "Semester CWA: 68.5", "Cumulative CWA: 71.2".
- "Continue" button.

**5. Reviewing State**
- AppBar: "Review Results" + "X courses" chip.
- List of extracted courses with editable fields:
  - Checkbox (include/exclude).
  - Course code, course name (read-only from AI).
  - Grade dropdown: A / B / C / D / F (colour-coded).
  - Mark input field (optional, exact %).
  - Credit hours stepper.
- Changes auto-save to review state.
- Bottom bar: "Save Results" button.

**6. Saving State**
- Spinner: "Saving results..."

**7. Done State**
- Success: "Semester saved!"
- "View Cumulative CWA" → pops back to `/cwa` (cumulative mode).

**8. Error State**
- Error + "Try Again" → resets to idle.

---

## 15. Past Semesters Screen (Pushed from CWA — Cumulative Mode)

Pushed from CWA screen (history icon in Cumulative mode).

### 15.1 States

**Loading State**
- Spinner.

**Empty State**
- "No past semesters added yet."
- "Import Result Slip" button → opens Result Slip Import.

**Has Past Semesters**
- AppBar: "Past Semesters".
- List of expandable `PastSemesterModel` cards:
  - Collapsed: semester label, reported CWA, course count, date added.
  - Expanded: list of `PastCourseEntry` items.
    - Each item: course code, name, credit hours, grade chip (colour-coded), mark (if available).
    - Inline editing: grade dropdown, mark input, credits stepper.
    - Changes auto-save.
  - Delete button per semester (confirmation dialog).
- Adding/deleting triggers live cumulative CWA recalculation.

---

## 16. Overlays, Sheets & Dialogs (Alphabetical Reference)

| Name | Type | Triggered From | Purpose |
|------|------|----------------|---------|
| Add Course Sheet | Bottom sheet | CWA screen (FAB) | Add new course with code, name, credits, score |
| Add Manual Task Sheet | Bottom sheet | Plan screen | Add custom task to daily plan |
| Add Slot Sheet | Bottom sheet | Timetable screen (+) | Add class slot with course, time, venue, type |
| Chat History Drawer | End drawer | AI Chat screen | View and switch between past conversations |
| Course Picker Sheet | Bottom sheet | Sessions screen | Select course for study session |
| CWA Coach Sheet | Bottom sheet | CWA screen | AI-generated academic coaching advice |
| Note Editor Sheet | Draggable sheet | Course Hub (Notes tab) | Create or edit a course note |
| Notification Permission Dialog | Dialog | First notification enable | Custom dialog before requesting OS permission |
| Slot Detail Sheet | Bottom sheet | Timetable (tap slot) | View slot details, open workspace, delete slot |
| Target CWA Dialog | Dialog | CWA summary bar | Set personal target CWA |
| Weekly Review Sheet | Draggable sheet | Sessions/Streak (legacy) | Weekly stats + reflection (now superseded by full-screen AI review) |

---

## 17. Complete Navigation Map

```
ShellRoute (Bottom Nav)
├── /plan ─────────────────── Dashboard / Daily Plan
│   ├── [Add Task Sheet]
│   ├── [Premium Gate Card]
│   └── → /subscribe
├── /cwa ──────────────────── CWA Planner
│   ├── [Semester | Cumulative toggle]
│   ├── [Add Course Sheet]
│   ├── [CWA Coach Sheet]
│   ├── [What-If Explainer chip]
│   ├── [Target CWA Dialog]
│   ├── → Registration Slip Import (push)
│   ├── → Result Slip Import (push)
│   ├── → Past Semesters Screen (push)
│   └── → /course/:courseCode
├── /timetable ────────────── Class Timetable
│   ├── [Add Slot Sheet]
│   ├── [Slot Detail Sheet]
│   │   └── → /course/:courseCode
│   └── → /timetable/import (push)
├── /sessions ─────────────── Session Tracker
│   ├── [Course Picker Sheet]
│   ├── [Active Timer (Normal | Pomodoro)]
│   ├── → /insights
│   └── → /course/:courseCode
│
├── [AI FAB] → /ai ───────── AI Chat
│   ├── [Chat History Drawer]
│   ├── [Premium Gate (quota exhausted)]
│   ├── → /ai/weekly-review
│   ├── → /subscribe
│   └── → /settings
│
├── /streak ───────────────── Streak System
├── /insights ─────────────── Insights (from /sessions)
├── /settings ─────────────── Settings
├── /subscribe ────────────── Premium upsell
│
├── Full-screen pushes (no bottom nav):
│   ├── /course/:courseCode ── Course Hub Workspace (3 tabs)
│   │   ├── Overview tab
│   │   ├── Sessions tab
│   │   └── Notes tab
│   │       └── [Note Editor Sheet]
│   ├── /timetable/import ─── Timetable Image Import (7 states)
│   ├── /ai/weekly-review ─── AI Weekly Review
│   │   └── [Premium Gate overlay]
│   ├── Registration Slip Import (pushed, 6 states)
│   ├── Result Slip Import (pushed, 7 states)
│   └── Past Semesters Screen (pushed)
│
└── [Floating Mini-Timer] ── Visible globally in shell when session active
    └── Tap → /sessions
```

---

## 18. States Checklist (for Figma frames)

Every screen/component needs these state frames:

| Screen | Loading | Empty | Data | Error | Premium Gate | Offline |
|--------|---------|-------|------|-------|--------------|---------|
| Dashboard /plan | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| CWA /cwa (Semester) | ✓ | ✓ | ✓ | ✓ | — | — |
| CWA /cwa (Cumulative) | ✓ | ✓ | ✓ | ✓ | — | — |
| Timetable /timetable | ✓ | ✓ | ✓ | ✓ | — | — |
| Sessions /sessions (idle) | ✓ | ✓ | ✓ | ✓ | — | — |
| Sessions (Normal running) | — | — | ✓ | — | — | — |
| Sessions (Pomodoro focus) | — | — | ✓ | — | — | — |
| Sessions (Pomodoro break) | — | — | ✓ | — | — | — |
| Sessions (Pomodoro complete) | — | — | ✓ | — | — | — |
| AI Chat /ai | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Streak /streak | ✓ | — | ✓ | ✓ | — | — |
| Insights /insights | ✓ | ✓ | ✓ | ✓ | — | — |
| Settings /settings | — | — | ✓ | — | — | — |
| Weekly Review /ai/weekly-review | ✓ | — | ✓ | ✓ | ✓ | — |
| Subscribe /subscribe | — | — | ✓ | — | — | — |
| Course Hub /course/:code | ✓ | — | ✓ | ✓ | — | — |
| Course Hub (Notes empty) | — | ✓ | — | — | — | — |
| Course Hub (Sessions empty) | — | ✓ | — | — | — | — |
| Timetable Import | — | — | 7 states | ✓ | — | ✓ |
| Registration Slip Import | — | — | 6 states | ✓ | — | ✓ |
| Result Slip Import | — | — | 7 states | ✓ | — | ✓ |
| Past Semesters | ✓ | ✓ | ✓ | ✓ | — | — |

---

## 19. Reusable Components (Design System)

These should have their own Figma component/variant sets:

- **ErrorRetryWidget**: icon + message + "Try Again" button.
- **OfflineBanner**: animated grey banner "You are offline".
- **PremiumGateWidget**: locked content + "Upgrade" button.
- **PlanTaskTile**: course info + time + checkbox.
- **CourseCard**: course code, name, credits badge, score slider, popup menu.
- **TimetableSlotCard**: course code, name, venue, time (adaptive layout).
- **SessionTile**: date, course, duration, type icon.
- **InsightCard**: icon, colour strip, message text.
- **StreakHeroCard**: large streak number, alive/broken indicator.
- **MilestoneGrid**: grid of 12 milestone chips (locked/unlocked).
- **CwaSummaryBar**: projected CWA, target CWA, gap indicator.
- **PlanProgressBar**: completed/total with celebration state.
- **ActivityHeatmap**: calendar grid with colour intensity.
- **WeeklyBarChart**: 7 bars (Mon–Sun).
- **AiMessageBubble**: user (right, primary) / assistant (left, surface) with markdown + math.
- **BottomNavBar**: 4-destination persistent nav.
- **FloatingMiniTimer**: pill overlay, Normal vs Pomodoro variants.
- **DaySelector**: horizontal scrollable pill row.
- **SegmentedButton**: Semester | Cumulative or Normal | Pomodoro.
