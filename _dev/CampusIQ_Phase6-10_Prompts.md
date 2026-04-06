# CampusIQ — Phase 6 to 10 Agent Prompts

Each phase is a self-contained prompt. Run them one at a time.
Complete one phase fully before starting the next.

---

---

# PHASE 6 — Daily Plan: Data Layer + Domain Logic

## Context

CampusIQ is a Flutter app (Android-first) for university students.
Tech stack: Flutter, Dart, Riverpod (riverpod_annotation + riverpod_generator),
Isar 3.x, Go Router, flutter_animate, intl.

Architecture rule: every feature lives in `lib/features/<feature>/` with three
sub-layers: `data/`, `domain/`, `presentation/`. Business logic never goes in
widgets. Domain files have zero Flutter dependencies.

Existing collections:
- `CourseModel` — courses with credit hours + expected scores
- `TimetableSlotModel` — official class slots
- `PersonalSlotModel` — personal/recurring slots
- `StudySessionModel` — completed study session records
- `UserPrefsModel` — single-row key/value persistent flags

Existing domain files you will read and use:
- `lib/features/timetable/domain/free_time_detector.dart` — computes free blocks for a day
- `lib/features/timetable/domain/slot_expander.dart` — expands recurring personal slots
- `lib/features/cwa/domain/cwa_calculator.dart` — CWA logic

---

## Your task — Phase 6

Create the **data layer and domain logic** for the Today's Plan feature.
Do NOT build any UI in this phase.

---

### Step 1 — Create `DailyPlanTaskModel` Isar schema

File: `lib/features/plan/data/models/daily_plan_task_model.dart`

Fields:
- `id` — Isar auto-increment
- `date` — `DateTime` (store as date only, no time component — use `DateTime(y,m,d)`)
- `taskType` — `String` — one of: `'attend'`, `'study'`, `'personal'`
- `label` — `String` — human-readable label e.g. "Attend MATH 151", "Study PHYSICS"
- `courseCode` — `String?` — nullable, links to a course or timetable slot
- `durationMinutes` — `int` — planned duration in minutes
- `startTime` — `DateTime?` — nullable, the suggested start time for this task
- `isCompleted` — `bool` — default false
- `isManual` — `bool` — true if the student added this task themselves, false if auto-generated
- `sortOrder` — `int` — display order of the task in the list

Add the `@collection` annotation and generate the `.g.dart` file with build_runner.

---

### Step 2 — Create `DailyPlanRepository`

File: `lib/features/plan/data/repositories/daily_plan_repository.dart`

Methods:
- `Future<List<DailyPlanTaskModel>> getTasksForDate(DateTime date)` — fetch all tasks for a given date, ordered by `sortOrder`
- `Future<void> saveTask(DailyPlanTaskModel task)` — insert or update a task
- `Future<void> saveTasks(List<DailyPlanTaskModel> tasks)` — batch insert/update, used when saving a generated plan
- `Future<void> markComplete(int taskId, bool completed)` — toggle `isCompleted`
- `Future<void> deleteTask(int taskId)` — delete a single task
- `Future<void> deleteAllTasksForDate(DateTime date)` — wipe all tasks for a date (used when regenerating the plan)
- `Stream<List<DailyPlanTaskModel>> watchTasksForDate(DateTime date)` — reactive stream, ordered by `sortOrder`

Use the existing Isar singleton from `lib/core/providers/isar_provider.dart`.

---

### Step 3 — Create `PlanTask` value object

File: `lib/features/plan/domain/plan_task.dart`

A pure Dart immutable value object (no Isar dependency):

```dart
class PlanTask {
  final String taskType;       // 'attend' | 'study' | 'personal'
  final String label;
  final String? courseCode;
  final int durationMinutes;
  final DateTime? startTime;
  final bool isManual;
  final int sortOrder;
}
```

Include a `copyWith` method and a `toDailyPlanTaskModel(DateTime date)` method
that converts this value object into a `DailyPlanTaskModel` with `isCompleted = false`.

---

### Step 4 — Create `PlanGenerator`

File: `lib/features/plan/domain/plan_generator.dart`

Pure Dart class. Zero Flutter imports. Takes all inputs as constructor parameters.

Constructor:
```dart
PlanGenerator({
  required List<TimetableSlotModel> todaySlots,
  required List<PersonalSlotModel> expandedPersonalSlots,
  required List<CourseModel> courses,
  required List<StudySessionModel> recentSessions,  // last 14 days
  required int dailyStudyGoalMinutes,               // from user prefs, default 120
})
```

Method: `List<PlanTask> generate(DateTime date)`

Generation logic (implement in this order):

1. **Attend tasks** — for each `TimetableSlotModel` in `todaySlots`, create a
   `PlanTask` with `taskType = 'attend'`, label = "Attend {courseCode} — {venue}",
   `durationMinutes` = slot duration in minutes, `startTime` = slot start time.

2. **Free block detection** — use `FreeTimeDetector` logic (copy the approach,
   do not import Flutter widgets) to find gaps between class slots today that
   are at least 30 minutes long.

3. **Course priority scoring** — score each course for study priority:
   - Base score: credit hours × 10
   - Bonus: +20 if the course has had no study session in the last 7 days
   - Bonus: +10 if expected score is below 60
   - Sort courses descending by priority score

4. **Study tasks** — distribute free blocks across prioritised courses.
   For each free block, assign the top-priority course that has not yet been
   assigned a block today. Create a `PlanTask` with `taskType = 'study'`,
   label = "Study {courseName}", `durationMinutes` = free block duration,
   `startTime` = free block start time.
   Stop assigning once the sum of study task durations >= `dailyStudyGoalMinutes`.

5. **Personal tasks** — for each expanded personal slot (from `SlotExpander`),
   create a `PlanTask` with `taskType = 'personal'`, label = category name,
   `durationMinutes` = slot duration, `startTime` = slot start time.

6. **Sort order** — assign `sortOrder` values by chronological start time.
   Tasks with no start time go at the end.

7. Return the final `List<PlanTask>`.

---

### Step 5 — Run build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

Verify the Isar schema generates without errors. Fix any issues before finishing.

---

### Commit

```
feat: Phase 6 complete — Daily Plan data layer + PlanGenerator domain logic
```

---

---

# PHASE 7 — Daily Plan: UI

## Context

Same stack as Phase 6. Phase 6 is complete — `DailyPlanTaskModel`,
`DailyPlanRepository`, `PlanTask`, and `PlanGenerator` all exist and compile.

---

## Your task — Phase 7

Build the **Today's Plan screen and all its widgets**. Wire up providers.
Add the Plan tab to the bottom navigation.

---

### Step 1 — Create Riverpod providers

File: `lib/features/plan/presentation/providers/plan_provider.dart`

Providers to create:

**`dailyStudyGoalMinutesProvider`** — `NotifierProvider<int>`
- Reads and writes an int from `UserPrefsModel` keyed as `'daily_study_goal_minutes'`
- Default value: 120 (2 hours)

**`todayPlanProvider`** — `StreamProvider<List<DailyPlanTaskModel>>`
- Calls `DailyPlanRepository.watchTasksForDate(today)`
- `today` = `DateTime(now.year, now.month, now.day)`

**`planProgressProvider`** — derived provider
- Reads `todayPlanProvider`
- Returns a record `(int completed, int total)` — count of completed vs total tasks

**`generatePlanProvider`** — `FutureProvider.family<void, DateTime>`  
- Takes a date
- Reads today's timetable slots, personal slots (via `SlotExpander`), courses,
  recent sessions, and daily goal from other providers
- Instantiates `PlanGenerator` and calls `generate(date)`
- Calls `DailyPlanRepository.deleteAllTasksForDate(date)` then
  `DailyPlanRepository.saveTasks(...)` with the result converted to models

---

### Step 2 — Create `PlanScreen`

File: `lib/features/plan/presentation/screens/plan_screen.dart`

Layout (top to bottom):

**Header area:**
- Title: "Today's Plan" with today's date below it (e.g. "Sunday, 5 April")
- A **Generate Plan** button (outlined, with a wand/sparkle icon) — tapping it
  calls `generatePlanProvider` for today's date and shows a loading indicator
  while generating

**Progress section:**
- A `PlanProgressBar` widget (see Step 3) showing tasks completed / total
- Below the bar: "{n} of {total} tasks done" in small text
- If all tasks are done, show a celebratory message: "You crushed it today 🎉"

**Task list:**
- A `ListView` of `PlanTaskTile` widgets (see Step 4), grouped by task type:
  - Section header "Classes" — attend tasks
  - Section header "Study" — study tasks
  - Section header "Personal" — personal tasks
- Show an empty state if no tasks exist yet, with a prompt to tap Generate Plan

**Add task button:**
- A floating action button (+ icon) that opens `AddManualTaskSheet` (see Step 5)

---

### Step 3 — Create `PlanProgressBar`

File: `lib/features/plan/presentation/widgets/plan_progress_bar.dart`

- Takes `completed` and `total` as int parameters
- Renders a full-width rounded progress bar
- Fill colour transitions: 0–33% red-ish, 34–66% amber, 67–99% blue, 100% green
- Animate the fill width change using `flutter_animate` (TweenAnimationBuilder
  or AnimatedContainer) so it slides smoothly when a task is ticked
- Show the percentage number inside or above the bar
- At 100%, pulse the bar green once using `flutter_animate`

---

### Step 4 — Create `PlanTaskTile`

File: `lib/features/plan/presentation/widgets/plan_task_tile.dart`

- Takes a `DailyPlanTaskModel` as parameter
- Leading icon: checkmark circle (outlined when incomplete, filled green when complete)
- Tapping the icon calls `DailyPlanRepository.markComplete(task.id, !task.isCompleted)`
- Label text with strikethrough when `isCompleted = true`
- Trailing: duration in minutes ("45 min") and start time if available ("2:00 PM")
- Task type colour accent on the left edge:
  - attend = blue
  - study = green  
  - personal = amber
- If `isManual = true`, show a small "custom" chip on the tile
- Swipe-to-delete (Dismissible widget) calls `DailyPlanRepository.deleteTask(task.id)`

---

### Step 5 — Create `AddManualTaskSheet`

File: `lib/features/plan/presentation/widgets/add_manual_task_sheet.dart`

A bottom sheet with:
- Text field: Task label (required)
- Dropdown: Task type — Study / Attend / Personal
- Course picker (optional) — dropdown of courses from `CourseModel`
- Duration picker — number input in minutes
- Start time picker (optional) — time picker dialog
- Save button — creates a `DailyPlanTaskModel` with `isManual = true` and saves it

---

### Step 6 — Add Plan tab to navigation

File: `lib/core/router/app_router.dart` and the shell widget

- Add `/plan` route pointing to `PlanScreen`
- Add a "Plan" tab to the bottom navigation bar with a checklist icon
  (`Icons.checklist_rounded` or similar)
- Position it as the first tab (leftmost) — it is the daily anchor tab

---

### Step 7 — Run and verify

```bash
flutter analyze
flutter run
```

Verify:
- Tapping Generate Plan populates the task list
- Ticking a task updates the progress bar with animation
- Adding a manual task appends it to the list
- Swipe-to-delete removes a task
- Progress bar hits green and pulses at 100%

---

### Commit

```
feat: Phase 7 complete — Today's Plan UI, progress bar, manual task entry
```

---

---

# PHASE 8 — Smart Notifications

## Context

Same stack. Phases 6 and 7 are complete. Today's Plan, DailyPlanTaskModel,
and DailyPlanRepository all exist. `FreeTimeDetector` exists in the timetable
domain. `StreakCalculator` exists in the streak domain.

---

## Your task — Phase 8

Add a `NotificationService` to `core/` and wire up all smart notifications.

---

### Step 1 — Add dependencies

Add to `pubspec.yaml`:
```yaml
flutter_local_notifications: ^17.0.0
flutter_timezone: ^2.0.0
timezone: ^0.9.0
```

Run `flutter pub get`.

---

### Step 2 — Android setup

In `android/app/src/main/AndroidManifest.xml` add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Inside `<application>` add:
```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
  </intent-filter>
</receiver>
```

---

### Step 3 — Create `NotificationService`

File: `lib/core/services/notification_service.dart`

A plain Dart class (no Riverpod). Singleton pattern:
```dart
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();
}
```

**Initialisation method:** `Future<void> init()`
- Initialise `FlutterLocalNotificationsPlugin` with Android settings
  (app icon: `@mipmap/ic_launcher`)
- Configure timezone using `flutter_timezone`
- Request notification permission on Android 13+

**Notification channel IDs (constants):**
```dart
static const String _channelStudyReminder = 'study_reminder';
static const String _channelStreakAlert   = 'streak_alert';
static const String _channelMilestone     = 'milestone_alert';
static const String _channelWeeklyReview  = 'weekly_review';
```

**Notification ID ranges (to avoid collisions):**
- Free block reminders: 100–199
- Streak at risk: 200
- Haven't studied today: 201
- Milestone approaching: 300–399
- Weekly review: 400
- Planned session reminders: 500–599

---

### Step 4 — Implement notification scheduling methods

All methods on `NotificationService`:

**`scheduleFreBlockReminders(List<FreeBlock> freeBlocks)`**
- Cancel all existing notifications with IDs 100–199
- For each free block that starts in the future today and is ≥ 30 min:
  - Schedule a notification 5 minutes before the block starts
  - Title: "Free time coming up"
  - Body: "You have {duration} free — good time to study."

**`scheduleStreakAtRiskAlert(int currentStreak)`**
- Cancel notification 200
- If `currentStreak > 0`, schedule notification 200 at 8:30 PM today
- Title: "Your streak is at risk 🔥"
- Body: "You haven't studied today. Your {n}-day streak ends at midnight."

**`scheduleHaventStudiedAlert()`**
- Cancel notification 201
- Schedule notification 201 at 8:00 PM today
- Title: "No study session yet"
- Body: "You haven't logged a session today. Even 30 minutes counts."

**`scheduleMilestoneAlert(int daysToNextMilestone, int nextMilestone)`**
- Cancel notification 300
- If `daysToNextMilestone <= 3` and `daysToNextMilestone > 0`:
  - Schedule notification 300 at 9:00 AM tomorrow
  - Title: "Milestone approaching 🏆"
  - Body: "You're {n} day(s) away from your {nextMilestone}-day milestone. Keep going."

**`scheduleWeeklyReviewPrompt()`**
- Cancel notification 400
- Schedule notification 400 for next Monday at 8:00 AM
- Title: "Your weekly review is ready"
- Body: "Tap to see how your study week went."

**`schedulePlannedSessionReminder(DailyPlanTaskModel task)`**
- Only for tasks where `taskType == 'study'` and `startTime != null`
- Schedule a notification 10 minutes before `task.startTime`
- ID: 500 + task.id (clamped to 500–599 range)
- Title: "Study session starting soon"
- Body: "{task.label} is scheduled to start in 10 minutes."

**`cancelAllReminders()`**
- Cancels all pending notifications

---

### Step 5 — Call `NotificationService` from the app

**`lib/main.dart`:**
- Call `await NotificationService.instance.init()` before `runApp()`

**After a study session stops** (in `active_session_provider.dart`):
- Cancel notification 201 (student has now studied today)
- Cancel notification 200 (streak no longer at risk for today)

**On app open** (in `app.dart` or a lifecycle observer):
- Call `scheduleHaventStudiedAlert()` — reschedules every day
- Call `scheduleStreakAtRiskAlert(currentStreak)` — reads streak from provider
- Call `scheduleFreBlockReminders(todayFreeBlocks)` — reads today's timetable

**When a plan is generated** (in `generatePlanProvider`):
- For each study task with a start time, call `schedulePlannedSessionReminder(task)`

**On each app open**, also check milestone proximity:
- Read `StreakCalculator` output
- Call `scheduleMilestoneAlert(daysToNextMilestone, nextMilestone)`

**On first Monday app open each week:**
- Call `scheduleWeeklyReviewPrompt()`

---

### Step 6 — Add a Notifications settings screen

File: `lib/features/settings/presentation/screens/settings_screen.dart`

A simple screen accessible from an icon in the app bar. Contains:
- Toggle: "Study reminders" (free block alerts) — on/off
- Toggle: "Streak alerts" — on/off
- Toggle: "Milestone alerts" — on/off
- Toggle: "Weekly review prompt" — on/off
- Time picker: "Daily study reminder time" (default 8:00 PM)

Store toggle states in `UserPrefsModel` as boolean flags.
When a toggle is turned off, cancel the corresponding notification IDs.

---

### Step 7 — Run and verify

```bash
flutter analyze
flutter run
```

Test on a physical Android device (notifications do not work on emulator reliably).
Verify:
- App requests notification permission on first launch
- Notifications appear at the correct scheduled times
- Stopping a session cancels the "haven't studied" notification
- Settings toggles cancel/reschedule correctly

---

### Commit

```
feat: Phase 8 complete — Smart Notifications (free block, streak, milestone, weekly review, session reminders)
```

---

---

# PHASE 9 — Smart Insights

## Context

Same stack. Phases 6–8 are complete.

Existing data available:
- `StudySessionModel` — all study sessions with course, date, start time, duration
- `CourseModel` — all courses with credit hours and expected scores
- `TimetableSlotModel` — class schedule

---

## Your task — Phase 9

Create the `InsightAnalyser` domain class and the Insights UI tab.

---

### Step 1 — Create `Insight` value object

File: `lib/features/insights/domain/insight.dart`

```dart
enum InsightType { positive, warning, neutral, tip }

class Insight {
  final String message;
  final InsightType type;
  final String? courseCode;   // nullable — links to a specific course if relevant
  final String icon;          // emoji or icon name string, e.g. '📈', '⚠️', '💡'
}
```

---

### Step 2 — Create `InsightAnalyser`

File: `lib/features/insights/domain/insight_analyser.dart`

Pure Dart class. Zero Flutter imports.

Constructor:
```dart
InsightAnalyser({
  required List<StudySessionModel> sessions,  // all historical sessions
  required List<CourseModel> courses,
})
```

Method: `List<Insight> analyse()`

Implement all of the following checks. Each check produces zero or one `Insight`.
Run all checks and return all results as a list.

**Check 1 — Best study day of the week**
- Group sessions by `weekday` (1=Monday … 7=Sunday)
- Find the weekday with the highest total duration
- If any day has data: produce a positive insight
- Message: "You study most on {DayName}. Schedule your hardest topics then."
- Icon: 📅

**Check 2 — Neglected course**
- For each course in `courses`, find the last session date for that course
- If a course has had no session in the last 7 days (or no session ever):
  produce a warning insight per course
- Message: "You haven't studied {courseName} in {n} days. It needs attention."
- Icon: ⚠️
- Include `courseCode` on the insight

**Check 3 — Best study hour window**
- Group sessions by start hour (0–23)
- Find the hour range (window of 2 hours) with the most total study time
- If data exists: produce a positive insight
- Message: "Your most productive study window is {H:00}–{H+2:00}. Protect that time."
- Icon: ⏰

**Check 4 — Late-night consistency drop**
- If sessions starting after 21:00 (9PM) have an average duration < 30 minutes,
  and there are at least 3 such sessions:
  produce a neutral insight
- Message: "Your sessions after 9PM tend to be short. Consider studying earlier."
- Icon: 🌙

**Check 5 — Consistent course (positive reinforcement)**
- For each course, check if there has been at least one session every 3 days
  over the past 14 days (i.e. ≥ 4 sessions in 14 days)
- For the course with the most consistent attendance: produce a positive insight
- Message: "You've been consistent with {courseName}. Keep that momentum."
- Icon: 🔥

**Check 6 — Study hours trend (improving or declining)**
- Compare total study hours this week vs last week
- If this week > last week by ≥ 20%: positive insight — "You studied more this week than last. Great progress."
- If this week < last week by ≥ 30%: warning insight — "Your study hours dropped this week. Try to get back on track."
- Icon: 📈 or 📉

**Check 7 — No data fallback**
- If `sessions` is empty, return a single neutral insight:
  "Start logging study sessions to unlock personalised insights."
- Icon: 💡

---

### Step 3 — Create Riverpod provider

File: `lib/features/insights/presentation/providers/insight_provider.dart`

**`insightsProvider`** — `Provider<List<Insight>>`
- Reads all sessions and courses from existing providers
- Instantiates `InsightAnalyser` and calls `analyse()`
- Returns the list

---

### Step 4 — Create `InsightsScreen`

File: `lib/features/insights/presentation/screens/insights_screen.dart`

Layout:
- Title: "Insights" with subtitle: "What your data says about you"
- A vertically scrollable list of `InsightCard` widgets (see Step 5)
- Group by type: show warnings first, then positives, then neutrals/tips
- If no insights, show empty state: "Log more sessions to generate insights."

---

### Step 5 — Create `InsightCard`

File: `lib/features/insights/presentation/widgets/insight_card.dart`

- Takes an `Insight` as parameter
- Card with left colour strip:
  - warning = amber
  - positive = green
  - neutral = blue
  - tip = purple
- Large emoji icon (from `insight.icon`) on the left
- Message text in the body
- If `courseCode` is not null, show a small tappable course chip that could
  navigate to the CWA planner (for now just display it as a label)
- Animate in with `flutter_animate` slide-from-bottom + fade, staggered by index

---

### Step 6 — Add Insights to navigation

Add `/insights` route and an "Insights" tab to the bottom nav bar.
Icon: `Icons.insights_rounded` or `Icons.auto_awesome_rounded`.

If the bottom nav now has 5 tabs (Plan, CWA, Timetable, Sessions, Streak, Insights)
consider moving Insights into a tab inside the Sessions screen as a second page,
or behind a button, to keep the nav bar at 5 items maximum.
Use your judgement — the priority is that Insights is easily accessible.

---

### Step 7 — Run and verify

```bash
flutter analyze
flutter run
```

Verify:
- Insights screen shows correct messages based on real session data
- Cards animate in with stagger
- Warning cards appear before positive cards
- Empty state shows when no sessions logged

---

### Commit

```
feat: Phase 9 complete — InsightAnalyser domain + Insights UI with animated cards
```

---

---

# PHASE 10 — Weekly Review System

## Context

Same stack. Phases 6–9 are complete.

Existing data:
- `StudySessionModel` — all sessions
- `CourseModel` — all courses
- `UserPrefsModel` — single-row key/value store (used for storing reflection notes)
- `InsightAnalyser` — already written in Phase 9

---

## Your task — Phase 10

Build the **Weekly Review** system — a summary modal that shows on Monday
mornings and is accessible anytime from the Sessions screen.

---

### Step 1 — Create `WeeklyReviewData` value object

File: `lib/features/review/domain/weekly_review_data.dart`

Pure Dart. No Flutter imports.

```dart
class WeeklyReviewData {
  final DateTime weekStart;          // Monday of the reviewed week
  final DateTime weekEnd;            // Sunday of the reviewed week
  final int totalMinutesStudied;
  final String? bestDay;             // Name of the day with most study time, nullable
  final int bestDayMinutes;
  final String? mostNeglectedCourse; // Course with fewest study minutes this week
  final String? mostStudiedCourse;   // Course with most study minutes this week
  final int currentStreak;
  final bool streakGrew;             // true if streak is longer than last week's max
  final String? reflectionNote;      // stored from UserPrefsModel, may be null
}
```

---

### Step 2 — Create `WeeklyReviewCalculator`

File: `lib/features/review/domain/weekly_review_calculator.dart`

Pure Dart class. Zero Flutter imports.

Constructor:
```dart
WeeklyReviewCalculator({
  required List<StudySessionModel> allSessions,
  required List<CourseModel> courses,
  required int currentStreak,
})
```

Method: `WeeklyReviewData calculate(DateTime weekStart)`

Logic:
- Filter sessions to those whose date falls within `[weekStart, weekStart + 6 days]`
- `totalMinutesStudied` = sum of all session durations in that week
- `bestDay` = weekday name with the highest total session duration
- `mostNeglectedCourse` = course (from `courses`) with the fewest total session
  minutes this week (zero counts — a course not studied at all this week is the
  most neglected)
- `mostStudiedCourse` = course with the most total session minutes this week
- `streakGrew` = `currentStreak` > 0 (simple heuristic for now)
- `reflectionNote` = null (passed in from UserPrefsModel by the caller)
- Return a populated `WeeklyReviewData`

---

### Step 3 — Create Riverpod provider

File: `lib/features/review/presentation/providers/review_provider.dart`

**`currentWeekReviewProvider`** — `FutureProvider<WeeklyReviewData>`
- Computes `weekStart` = the most recent Monday at or before today
- Reads all sessions, all courses, and current streak
- Reads reflection note from `UserPrefsModel` (key: `'weekly_note_{year}_W{weekNumber}'`)
- Instantiates `WeeklyReviewCalculator` and calls `calculate(weekStart)`
- Returns the result with the reflection note attached

**`saveReflectionNoteProvider`** — `FutureProvider.family<void, String>`
- Takes the note text as the family parameter
- Saves it to `UserPrefsModel` with key `'weekly_note_{year}_W{weekNumber}'`

---

### Step 4 — Create `WeeklyReviewSheet`

File: `lib/features/review/presentation/widgets/weekly_review_sheet.dart`

A `DraggableScrollableSheet` (modal bottom sheet) with these sections:

**Header:**
- "📊 Week in Review" title
- Date range: "31 Mar – 6 Apr 2026"

**Stats row (3 cards side by side):**
- Total hours studied (convert minutes → "X h Y m")
- Best study day
- Current streak

**Highlights section:**
- "💪 Most studied: {mostStudiedCourse}" — shown in green chip
- "⚠️ Needs attention: {mostNeglectedCourse}" — shown in amber chip
- If both are null (no sessions this week): show "No sessions logged this week."

**Reflection section:**
- Heading: "What will you improve next week?"
- A `TextField` (multiline, max 3 lines) pre-filled with existing reflection note
  if one was saved
- A "Save note" button — calls `saveReflectionNoteProvider` with the text
- After saving, show a brief snackbar: "Reflection saved ✓"

**Close button** at the bottom.

Animate sections in sequentially using `flutter_animate` with staggered delays.

---

### Step 5 — Create `WeeklyReviewEntryPoint`

Add a "This Week" button to the **Sessions screen** (`session_screen.dart`).

- Place it in the app bar as a text button or icon button
- Tapping it opens `WeeklyReviewSheet` as a modal bottom sheet

---

### Step 6 — Auto-show on Monday mornings

In `app.dart` (or wherever the app lifecycle is handled):

- On app foreground / resume, check:
  - Is today Monday?
  - Has the weekly review been shown this week already?
    (Check `UserPrefsModel` for key `'review_shown_{year}_W{weekNumber}'`)
- If both conditions are true: auto-show `WeeklyReviewSheet` after a 1-second delay
- After showing, write `true` to `UserPrefsModel` under that key so it doesn't
  show again until next Monday

---

### Step 7 — Weekly Review history (optional, implement if time allows)

A simple screen listing past weekly reviews.
File: `lib/features/review/presentation/screens/review_history_screen.dart`

- List of past week ranges (go back up to 16 weeks)
- Tap any week to open a read-only version of `WeeklyReviewSheet` for that week
- Show the reflection note if one was saved

Accessible from a "History" button on the Weekly Review sheet.

---

### Step 8 — Run and verify

```bash
flutter analyze
flutter run
```

Verify:
- Weekly Review sheet opens from Sessions screen
- Stats display correctly based on session data
- Reflection note saves and persists across app restarts
- Auto-shows on Monday morning (test by temporarily changing the day check to
  today's weekday for verification, then restore)

---

### Commit

```
feat: Phase 10 complete — Weekly Review system with stats, reflection prompt, and Monday auto-show
```

---

---

## Summary Table

| Phase | Feature | New files |
|---|---|---|
| 6 | Daily Plan — data + domain | `DailyPlanTaskModel`, `DailyPlanRepository`, `PlanTask`, `PlanGenerator` |
| 7 | Daily Plan — UI | `PlanScreen`, `PlanProgressBar`, `PlanTaskTile`, `AddManualTaskSheet`, plan providers |
| 8 | Smart Notifications | `NotificationService`, settings screen, AndroidManifest changes |
| 9 | Smart Insights | `Insight`, `InsightAnalyser`, `InsightsScreen`, `InsightCard`, insight provider |
| 10 | Weekly Review | `WeeklyReviewData`, `WeeklyReviewCalculator`, `WeeklyReviewSheet`, review providers |

Run phases strictly in order. Do not start Phase N+1 until Phase N compiles and runs cleanly.
