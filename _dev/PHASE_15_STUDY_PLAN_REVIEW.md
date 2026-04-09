# CampusIQ — Phase 13: Auto-Generated Study Plan + Weekly AI Review

---

## Session Overview

**Phase:** 13 of 16  
**Sessions required:** 2  
**Depends on:** Phase 11 (AI infrastructure), Phase 12 (context builder patterns established)  
**Unlocks:** Phase 14

**What this phase delivers:**
- Auto-generated 7-day study plan using real timetable free block data
- Weekly AI review that caches in Isar and refreshes every Monday
- Both features are premium-only with free users seeing a teaser/gate
- New Isar schemas: `StudyPlanModel`, `StudyPlanSlotModel`, `WeeklyReviewModel`
- New tab inside `/sessions` screen (Study Plan tab)
- New screen: `/ai/weekly-review`

**What this phase does NOT touch:**
- The AI chat screen
- CWA coach or what-if features
- Streak or timetable screens

---

## Project Context

Read `CLAUDE.md` before starting. Key facts:
- `FreeTimeDetector` exists at `lib/features/timetable/domain/free_time_detector.dart` — use it to get free blocks per day
- `TimetableRepository` provides class slots
- `SessionRepository` provides `StudySessionModel` records — read week totals from it
- `StreakCalculator` in streak domain — import and call directly if needed for context
- DeepSeek will return **JSON** for the study plan — parse it into `StudyPlanSlotModel` value objects
- `isPremiumProvider` and `AiUsageRepository` available from Phase 11
- Run `dart run build_runner build --delete-conflicting-outputs` after new Isar models

---

## Session 1 — Auto-Generated Study Plan

### User Experience

1. User opens the Sessions screen (`/sessions`)
2. Existing screen has session history and analytics — this phase adds a **"Study Plan" tab** at the top, creating a 2-tab layout: "History" (existing) and "Plan" (new)
3. User taps "Plan" tab
4. **Free user:** sees a preview card showing a blurred example day with a lock overlay and upgrade prompt. No AI call made.
5. **Premium user (no plan generated yet):** sees an empty state with a "Generate My Study Plan" button
6. User taps "Generate My Study Plan"
7. Loading state: subtle progress indicator with message "Reading your timetable and sessions..."
8. Plan renders as a list of day cards (Monday → Sunday), each showing:
   - Day label (e.g., "Monday")
   - One or two study slot tiles per day, each showing: course name, time block, duration, short reason
   - If no slots for a day: "Rest day — no free blocks available"
9. **"Regenerate Plan"** button at the bottom — tapping replaces the old plan with a new one
10. Plan persists in Isar — user sees the same plan on every app open until they regenerate

### New Isar Schemas

#### `study_plan_model.dart`

```dart
import 'package:isar/isar.dart';
import 'study_plan_slot_model.dart';
part 'study_plan_model.g.dart';

@collection
class StudyPlanModel {
  Id id = 1; // single row — always replace, never append

  late DateTime generatedAt;
  late String weekStartDate; // Monday of the week this was generated for, 'yyyy-MM-dd'

  final slots = IsarLinks<StudyPlanSlotModel>();
}
```

#### `study_plan_slot_model.dart`

```dart
import 'package:isar/isar.dart';
part 'study_plan_slot_model.g.dart';

@collection
class StudyPlanSlotModel {
  Id id = Isar.autoIncrement;

  late String day;           // 'Monday' | 'Tuesday' | ... | 'Sunday'
  late String courseCode;
  late String courseName;
  late String startTime;     // 'HH:mm' 24-hour format e.g. '14:00'
  late int durationMinutes;  // e.g. 90
  late String reason;        // short explanation from AI e.g. "Largest CWA gap"
}
```

After creating both schemas: `dart run build_runner build --delete-conflicting-outputs`

Place both in `lib/features/ai/data/models/`.

---

### Context Builder — Study Plan Prompt

Add method `Future<String> buildStudyPlanPrompt()` to `ContextBuilder`.

This method:
1. Gets all courses from `CwaRepository` — sorted by (credit hours × CWA gap) descending to establish priority
2. Gets free blocks for each day Mon–Sun using `FreeTimeDetector` (call for each day)
3. Gets last 4 weeks of session records from `SessionRepository` — extract which days/times the student actually studies (preference pattern)
4. Gets today's class slots to confirm no overlaps

Assemble prompt:

```
You are a study planner. Generate a 7-day study plan for a university student.

Course priority (highest to lowest impact on CWA):
1. EE 301 — 3 credit hours, gap of 6 points to target
2. MATH 251 — 2 credit hours, gap of 0 points (on track)
[... list all courses]

Available free blocks per day (class times are already excluded):
Monday: 10:00–12:00, 16:00–18:00
Tuesday: 14:00–16:00
Wednesday: (no free blocks)
[... all days]

Student's past study patterns (days/times they actually study):
Tends to study: Tuesday afternoons, Thursday mornings
Rarely studies: Weekends

Rules:
- Never schedule a study session during a class time
- Prioritize high-gap courses
- Respect past patterns where possible — don't force sessions at times they never study
- Maximum 2 study sessions per day
- Each session: 60–120 minutes
- At least 1 rest day per week
- If a day has no free blocks, mark it as a rest day

Return ONLY a JSON array. No explanation text before or after the JSON.
Each item must have exactly these fields:
{
  "day": "Monday",
  "courseCode": "EE 301",
  "courseName": "Circuit Theory",
  "startTime": "10:00",
  "durationMinutes": 90,
  "reason": "Highest CWA leverage course"
}
```

Use `model: 'deepseek-chat'`, `maxTokens: 1000` (plan can be verbose).

---

### Study Plan Provider

```
lib/features/ai/presentation/providers/study_plan_provider.dart
```

State:
```dart
class StudyPlanState {
  final StudyPlanModel? plan;
  final List<StudyPlanSlotModel> slots;
  final bool isLoading;
  final String? error;
  final bool isGenerated; // true if a plan exists in Isar
}
```

Notifier:
- `Future<void> loadPlan()` — loads from Isar on init, populates `slots`
- `Future<void> generatePlan()`:
  1. Set `isLoading = true`
  2. Build prompt via `ContextBuilder.buildStudyPlanPrompt()`
  3. Call `DeepSeekClient.complete()`
  4. Parse JSON response — wrap in try/catch (AI can occasionally return malformed JSON; on error, show error state and allow retry)
  5. Clear all existing `StudyPlanSlotModel` records from Isar
  6. Write new `StudyPlanModel` (id: 1) and all `StudyPlanSlotModel` records
  7. Set `isLoading = false`, update `slots`

JSON parsing helper (put in `domain/` or as a private method):
```dart
List<StudyPlanSlotModel> _parseSlots(String jsonString) {
  final cleaned = jsonString.trim();
  final list = jsonDecode(cleaned) as List;
  return list.map((item) {
    final map = item as Map<String, dynamic>;
    return StudyPlanSlotModel()
      ..day = map['day'] as String
      ..courseCode = map['courseCode'] as String
      ..courseName = map['courseName'] as String
      ..startTime = map['startTime'] as String
      ..durationMinutes = map['durationMinutes'] as int
      ..reason = map['reason'] as String;
  }).toList();
}
```

---

### New Widgets

```
lib/features/ai/presentation/widgets/
├── study_plan_tab.dart       ← tab content, shown inside sessions screen
├── plan_day_card.dart        ← one card per day
├── plan_slot_tile.dart       ← individual slot within a day
└── plan_free_gate_card.dart  ← premium gate for free users
```

#### `plan_day_card.dart`
Card with day title, list of `PlanSlotTile`s inside. If no slots for the day: shows "Rest day" in muted text.

#### `plan_slot_tile.dart`
Row showing: colored course dot · course name · time range · duration · reason in small muted text below.

#### `plan_free_gate_card.dart`
A visually blurred placeholder card. Shows one fake day of plan slots with a `Stack` blur overlay (`ImageFilter.blur`) + lock icon + "Upgrade to Premium for your personalized plan" text + upgrade button.

Use `dart:ui`'s `BackdropFilter` for the blur. The fake content underneath can be hardcoded sample data.

---

### Sessions Screen Update

In `session_screen.dart`, wrap the existing content in a `TabBarView` with two tabs:
- Tab 0: "History" — all existing session screen content (no changes to existing widgets)
- Tab 1: "Plan" — `StudyPlanTab` widget

Add a `TabBar` to the `AppBar` bottom or just below the AppBar as a sticky header.

For free users on the Plan tab: render `PlanFreeGateCard` instead of the real plan content. Do not call the AI or load anything from Isar.

---

### Session 1 Checkpoint

Commit: `feat(phase-13): study plan — Isar schemas, provider, plan generation, sessions tab`

Verify:
- [ ] `dart run build_runner build --delete-conflicting-outputs` runs clean
- [ ] Plan generates without errors using real timetable data
- [ ] Generated slots never overlap class times
- [ ] Plan persists — survives app restart
- [ ] Regenerate replaces old plan correctly
- [ ] Free users see the gate card, no AI call made
- [ ] Sessions screen tab switching works without breaking existing history/analytics

---

## Session 2 — Weekly AI Review

### User Experience

1. The AI tab (from Phase 11) gets a **banner card at the top** that appears every Monday
2. Banner: "Your week in review is ready →" — tapping navigates to `/ai/weekly-review`
3. The weekly review screen shows 4 sections:

| Section | Label | Free user | Premium user |
|---|---|---|---|
| Summary | "Your week at a glance" | Visible | Visible |
| What went well | "Wins this week" | Blurred with gate | Visible |
| Watch out for | "Something to fix" | Blurred with gate | Visible |
| This week's focus | "Your #1 priority" | Blurred with gate | Visible |

4. Premium users also see a "Ask about this review →" button at the bottom that navigates to `/ai` with the review pre-loaded as context
5. Free users see 3 blurred sections with a single upgrade prompt below all three (not one per section)

### When the Review Generates

- On first app open after Monday midnight where no review exists for the current week
- "Current week" = Monday date in `'yyyy-MM-dd'` format
- If a review already exists for this Monday: load from Isar, do not call API again
- Generation is triggered from the `WeeklyReviewProvider` `init` method — check week date, generate if needed
- If the student has no sessions at all this week: still generate — the AI is instructed to be gentle

---

### New Isar Schema

#### `weekly_review_model.dart`

```dart
import 'package:isar/isar.dart';
part 'weekly_review_model.g.dart';

@collection
class WeeklyReviewModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String weekStartDate; // 'yyyy-MM-dd' of the Monday

  late String summaryText;
  late String wellText;
  late String watchText;
  late String focusText;
  late DateTime generatedAt;
}
```

Place in `lib/features/ai/data/models/`. Run `build_runner` after.

---

### Context Builder — Weekly Review Prompt

Add method `Future<String> buildWeeklyReviewPrompt()` to `ContextBuilder`.

Gather:
- Total study hours this week (from `SessionRepository`, filter by Mon–Sun of current week)
- Per-course breakdown this week
- Streak status (current streak, alive/broken)
- CWA gap (from `CwaRepository`)
- Missed class days (from `UserPrefsModel` attendance tracker if available)

Prompt:
```
You are an academic coach writing a weekly review for a university student.

This week's data:
- Total study time: 12.5 hours
- Sessions by course: EE 301 (4.2hr), MATH 251 (3.1hr), others (5.2hr)
- Study streak: 14 days, still alive
- CWA gap: 0.13 points below target (2.87 projected vs 3.0 target)
- Courses with no study sessions this week: CHEM 101

Write a weekly review with exactly 4 sections. 
Return ONLY a JSON object — no text before or after.
{
  "summary": "2-3 sentence overall summary of the week",
  "well": "1-2 sentences on what went well",
  "watch": "1-2 sentences on one specific risk or gap",
  "focus": "1 sentence with one concrete priority for next week"
}

Tone: warm, honest, encouraging. Not generic. Reference their actual numbers and courses.
Do not use markdown. Plain sentences only.
```

`maxTokens: 500`

---

### Weekly Review Provider

```
lib/features/ai/presentation/providers/weekly_review_provider.dart
```

State:
```dart
class WeeklyReviewState {
  final WeeklyReviewModel? review;
  final bool isLoading;
  final String? error;
  final bool hasReviewThisWeek;
}
```

Helper: `String _currentMondayDate()` — returns the date of this week's Monday as `'yyyy-MM-dd'`.

Notifier `init` / `build`:
1. Compute this week's Monday date
2. Query Isar for `WeeklyReviewModel` where `weekStartDate == mondayDate`
3. If found: set `review`, `hasReviewThisWeek = true`, done
4. If not found AND today is Monday (or first open of the week): call `_generateReview()`
5. If not found AND today is not Monday: show empty state (review generates next Monday)

`_generateReview()`:
1. `isLoading = true`
2. Build prompt via `ContextBuilder.buildWeeklyReviewPrompt()`
3. Call `DeepSeekClient.complete()`
4. Parse JSON → populate `WeeklyReviewModel`
5. Save to Isar
6. Set `isLoading = false`

**Note on "first open of the week":** Check `UserPrefsModel` for a `lastReviewGeneratedWeek` key. If it differs from current Monday date, trigger generation. Update it after generation.

---

### New Files

```
lib/features/ai/presentation/
├── screens/
│   └── weekly_review_screen.dart
└── widgets/
    ├── review_section_card.dart
    ├── review_gate_overlay.dart
    └── weekly_review_banner.dart
```

#### `weekly_review_screen.dart`

Route: `/ai/weekly-review`

Layout (top to bottom):
- AppBar: "Week in Review" + the Monday date (e.g., "Apr 7, 2026")
- `ReviewSectionCard` for Summary (always visible)
- `ReviewSectionCard` for "Wins this week" (blurred for free users)
- `ReviewSectionCard` for "Something to fix" (blurred for free users)
- `ReviewSectionCard` for "Your #1 priority" (blurred for free users)
- For free users: single `ReviewGateOverlay` card below the 3 blurred sections
- For premium users: "Ask about this review →" `TextButton` at the bottom

#### `review_section_card.dart`

```dart
class ReviewSectionCard extends StatelessWidget {
  final String title;
  final String body;
  final bool isBlurred; // if true, apply BackdropFilter blur

  // ...
}
```

When `isBlurred == true`: wrap content in `Stack` with `BackdropFilter(filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6))` overlay. The section title is still visible; only the body text is blurred.

#### `review_gate_overlay.dart`

A single card (not blurred) that appears below the 3 blurred sections for free users:
```
Unlock your full weekly review with Premium.
See your wins, what to fix, and your #1 focus for next week.

GHS 20/month · GHS 120/semester
[Upgrade to Premium →]
```

#### `weekly_review_banner.dart`

Banner card shown at the top of the AI chat screen (`/ai`) when `hasReviewThisWeek == true`.

Style: a card with a subtle gradient-free accent left border, review icon, and text "Your week in review is ready →". Tappable — navigates to `/ai/weekly-review`.

Disappears if the user has already opened the review (set a `hasViewedReview` flag in `UserPrefsModel`).

---

### Router Update

Add to `app_router.dart`:
```dart
GoRoute(
  path: '/ai/weekly-review',
  builder: (context, state) => const WeeklyReviewScreen(),
),
```

---

### AI Chat Screen Update

In `ai_chat_screen.dart`, add `WeeklyReviewBanner` at the very top of the screen body (above the message list). Watch `weeklyReviewProvider` — only show banner if `hasReviewThisWeek == true` and `hasViewedReview == false`.

---

### Session 2 Checkpoint

Commit: `feat(phase-13): weekly review — Isar schema, generation, screen, free gate, AI tab banner`

Verify:
- [ ] Weekly review generates correctly on first Monday open
- [ ] Review loads from Isar on subsequent opens (no API re-call)
- [ ] All 4 sections render with real content from the AI
- [ ] Free users see Summary + 3 blurred sections + gate card
- [ ] Premium users see all 4 sections + "Ask about this review" button
- [ ] Banner appears on AI chat screen and links to review screen
- [ ] Banner disappears after user views the review

---

## Phase 13 Done — Final Commit

`feat: Phase 13 complete — auto study plan + weekly AI review`

Update `CLAUDE.md` with:
- `StudyPlanModel`, `StudyPlanSlotModel`, `WeeklyReviewModel` added to Isar
- `/ai/weekly-review` route added
- Sessions screen now uses TabBar — "History" and "Plan" tabs
- `ContextBuilder` methods added: `buildStudyPlanPrompt()`, `buildWeeklyReviewPrompt()`
- Weekly review generation trigger logic (Monday check via `UserPrefsModel`)
