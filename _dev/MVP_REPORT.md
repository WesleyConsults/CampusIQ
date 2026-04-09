# CampusIQ — MVP Completion Report

**Date:** 2026-04-05
**Package:** com.wesleyconsults.campusiq
**Status:** MVP Complete (Phases 1–5)

---

## Overview

CampusIQ is a Flutter-based academic planning app built Android-first for Ghanaian university students (KNUST target audience). The MVP covers five phases: CWA Target Planner, Class Timetable, Personal Timetable, Study Session Tracking, and Streak System.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Android-first) |
| Language | Dart |
| State management | Riverpod (riverpod_annotation + riverpod_generator) |
| Local storage | Isar 3.x |
| Navigation | Go Router |
| Fonts | Google Fonts — Inter |
| Code generation | build_runner + isar_generator + riverpod_generator |

---

## Architecture

Every feature follows a strict three-layer structure:

```
lib/features/<feature>/
├── data/
│   ├── models/          — Isar @collection schemas + generated .g.dart
│   └── repositories/    — CRUD + stream methods (no Flutter deps)
├── domain/              — Pure Dart business logic only
└── presentation/
    ├── providers/        — Riverpod providers (riverpod_annotation)
    ├── screens/          — ConsumerWidget screens
    └── widgets/          — Stateless/Consumer widgets
```

Business logic is never placed in widgets. Domain layer has zero Flutter dependencies.

---

## Full File Tree (source files only)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/app_constants.dart
│   ├── data/
│   │   ├── models/user_prefs_model.dart          — single-row key/value Isar store
│   │   └── repositories/user_prefs_repository.dart
│   ├── providers/isar_provider.dart               — singleton FutureProvider<Isar>
│   ├── router/app_router.dart                     — GoRouter + ShellRoute
│   └── theme/app_theme.dart                       — Material 3 + Inter
├── features/
│   ├── cwa/                                       — Phase 1
│   │   ├── data/models/course_model.dart
│   │   ├── data/repositories/cwa_repository.dart
│   │   ├── domain/cwa_calculator.dart
│   │   └── presentation/
│   │       ├── providers/cwa_provider.dart
│   │       ├── screens/cwa_screen.dart
│   │       └── widgets/
│   │           ├── add_course_sheet.dart
│   │           ├── course_card.dart
│   │           └── cwa_summary_bar.dart
│   ├── timetable/                                 — Phase 2 + 3
│   │   ├── data/models/timetable_slot_model.dart
│   │   ├── data/models/personal_slot_model.dart
│   │   ├── data/repositories/timetable_repository.dart
│   │   ├── data/repositories/personal_slot_repository.dart
│   │   ├── domain/
│   │   │   ├── free_time_detector.dart
│   │   │   ├── personal_slot_category.dart
│   │   │   ├── recurrence_type.dart
│   │   │   ├── slot_expander.dart
│   │   │   └── timetable_constants.dart
│   │   └── presentation/
│   │       ├── providers/timetable_provider.dart
│   │       ├── providers/personal_slot_provider.dart
│   │       ├── screens/timetable_screen.dart
│   │       └── widgets/
│   │           ├── add_slot_sheet.dart
│   │           ├── add_personal_slot_sheet.dart
│   │           ├── day_selector.dart
│   │           ├── dual_layer_grid.dart
│   │           ├── free_block_indicator.dart
│   │           ├── personal_slot_card.dart
│   │           ├── personal_slot_detail_sheet.dart
│   │           ├── slot_detail_sheet.dart
│   │           ├── timetable_page_indicator.dart
│   │           └── timetable_slot_card.dart
│   ├── session/                                   — Phase 4
│   │   ├── data/models/study_session_model.dart
│   │   ├── data/repositories/session_repository.dart
│   │   ├── domain/
│   │   │   ├── active_session_state.dart
│   │   │   └── planned_actual_analyser.dart
│   │   └── presentation/
│   │       ├── providers/active_session_provider.dart
│   │       ├── providers/session_provider.dart
│   │       ├── screens/session_screen.dart
│   │       └── widgets/
│   │           ├── active_timer_card.dart
│   │           ├── analytics_summary_card.dart
│   │           ├── course_breakdown_card.dart
│   │           ├── course_picker_sheet.dart
│   │           ├── floating_mini_timer.dart
│   │           ├── session_tile.dart
│   │           └── weekly_bar_chart.dart
│   └── streak/                                    — Phase 5
│       ├── domain/
│       │   ├── milestone.dart
│       │   ├── streak_calculator.dart
│       │   └── streak_result.dart
│       └── presentation/
│           ├── providers/streak_provider.dart
│           ├── screens/streak_screen.dart
│           └── widgets/
│               ├── activity_heatmap.dart
│               ├── attendance_tracker.dart
│               ├── course_streak_list.dart
│               ├── milestone_grid.dart
│               ├── next_milestone_card.dart
│               ├── streak_hero_card.dart
│               └── streak_summary_mini.dart
└── shared/
    ├── extensions/double_extensions.dart
    └── widgets/empty_state_widget.dart
```

---

## Routes

| Route | Screen |
|---|---|
| `/cwa` | CWA Target Planner |
| `/timetable` | Class + Personal Timetable (dual layer, swipe) |
| `/sessions` | Study Session Tracker + Analytics Dashboard |
| `/streak` | Streak System + Milestone Gallery |

Navigation uses a `ShellRoute` so the bottom nav bar and floating mini-timer persist across tab switches.

---

## Phase Summaries

---

### Phase 1 — CWA Target Planner

**Route:** `/cwa`

| Feature | Description |
|---|---|
| Add / edit / delete courses | Bottom sheet with course code, name, credit hours, expected score |
| Live CWA calculation | Riverpod stream recalculates instantly on every change |
| Score slider per course | Drag to adjust expected score; CWA updates in real time |
| CWA summary bar | Projected CWA, target CWA, gap indicator |
| High-impact badge | Flags the course with the most credit hours |
| Target CWA dialog | Set a personal target; gap indicator updates accordingly |
| Isar persistence | Courses survive hot restart and app relaunch |
| What-if logic | `CwaCalculator.whatIf()` available for future scenario screens |

**Isar schemas:** `CourseModel`

---

### Phase 2 — Class Timetable + Free Time Detection

**Route:** `/timetable` (Layer 1)

| Feature | Description |
|---|---|
| Day selector | Swipe or tap to switch between Mon–Sat |
| Time grid | 6AM–8PM, hourly rows, 30-min resolution |
| Add class slot | Bottom sheet with fast-select CWA course chips for instant autofill (course code, name, venue, type, time, color) |
| Slot detail sheet | Tap slot to view/delete |
| Free time detector | `FreeTimeDetector` computes contiguous free blocks per day — pure Dart |
| Free block indicator | Displays free blocks in the grid when no class is scheduled |
| Slot types | Lecture / Practical / Tutorial |

**Isar schemas:** `TimetableSlotModel`

---

### Phase 3 — Personal Timetable + Dual Layer View

**Route:** `/timetable` (Layer 2, swipe to switch)

| Feature | Description |
|---|---|
| Personal slot categories | Study, Gym, Rest, Meal, Side Project, Devotion, Errand, Custom |
| Recurrence types | One-off, Daily, Weekly |
| Slot expander | `SlotExpander` expands recurring slots into concrete instances for the active day — no duplicated rows in Isar |
| Dual layer grid | `DualLayerGrid` renders class slots (Layer 1) and personal slots (Layer 2) in the same `Stack` |
| Three views | Class Only / Both / Personal Only — implemented as a `PageView` (swipe left/right) |
| Page indicator | Shows which layer view is active |
| Add personal slot | Bottom sheet with category, recurrence, time, color |
| Personal slot detail | Tap to view / delete |

**Isar schemas:** `PersonalSlotModel`

**Timetable views:**
- Page 0 = Class Only
- Page 1 = Both (default)
- Page 2 = Personal Only

---

### Phase 4 — Study Session Tracking

**Route:** `/sessions`

| Feature | Description |
|---|---|
| Course picker | Merged list of CWA courses + today's timetable slots |
| Start / stop timer | Tapping a course starts the global session timer |
| Wall-clock anchor | Timer stores `sessionStartTime` as `DateTime`; elapsed = `DateTime.now().difference(sessionStartTime)` — survives Android app pauses |
| Global session state | `activeSessionProvider` lives above `ShellRoute`, survives tab switches |
| Floating mini-timer | Visible in the `_AppShell` body overlay when a session is active; tapping returns to Sessions tab |
| Session history | Chronological list of past sessions with duration and course |
| Analytics dashboard | Daily total, weekly bar chart, per-course breakdown |
| Planned vs actual | `PlannedActualAnalyser` compares session records against timetable slots — pure Dart |

**Isar schemas:** `StudySessionModel`

---

### Phase 5 — Streak System

**Route:** `/streak`

| Feature | Description |
|---|---|
| Study streak | Consecutive days with at least one completed study session |
| Per-course streak | Streak calculated per individual course |
| Attendance streak | Days marked as attended, stored in `UserPrefsModel` |
| Streak calculator | Pure Dart `StreakCalculator` — receives sorted `List<DateTime>`, returns current streak, longest streak, alive/broken state |
| Alive vs broken logic | If student studied yesterday but not yet today, streak is still alive (day not over) |
| Milestone system | 12 milestones: 3, 7, 14, 21, 30, 40, 50, 60, 70, 80, 90, 100 days — computed as value objects, no Isar collection |
| Milestone grid | Visual gallery of locked/unlocked milestones |
| Next milestone card | Shows the next target and days remaining |
| Activity heatmap | Calendar-style heatmap of study activity |
| Course streak list | Per-course streak breakdown |
| Streak hero card | Current streak + longest streak prominently displayed |
| Streak summary mini | Compact widget reused in other screens |
| Attendance tracker | Mark/unmark class attendance days |

**Isar schemas:** `UserPrefsModel` (single-row key/value store, shared with future features)

---

## Isar Collections (full list)

| Collection | Feature | Purpose |
|---|---|---|
| `CourseModel` | CWA | Courses with credit hours + expected scores |
| `TimetableSlotModel` | Timetable | Official class slots (Layer 1) |
| `PersonalSlotModel` | Timetable | Personal/recurring slots (Layer 2) |
| `StudySessionModel` | Sessions | Completed study session records |
| `UserPrefsModel` | Core / Streak | Single-row key/value persistent flags (attended days, etc.) |

---

## Dependencies

### Runtime

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.5.1 | State management |
| riverpod_annotation | ^2.3.5 | Riverpod code-gen annotations |
| isar | ^3.1.0+1 | Local database |
| isar_flutter_libs | ^3.1.0+1 | Isar native binaries |
| path_provider | ^2.1.3 | Database directory |
| go_router | ^14.2.0 | Navigation + ShellRoute |
| google_fonts | ^6.2.1 | Inter typeface |
| flutter_animate | ^4.5.0 | Animation utilities |
| intl | ^0.19.0 | Number / date formatting |

### Dev

| Package | Version | Purpose |
|---|---|---|
| build_runner | ^2.4.11 | Code generation runner |
| isar_generator | ^3.1.0+1 | Isar schema codegen |
| riverpod_generator | ^2.3.9 | Riverpod codegen (pinned — see Issues) |

---

## Key Engineering Decisions

### 1. Timer reliability on Android
`Stopwatch` and `Timer.periodic` counters are killed when Android pauses background isolates. The session timer stores `sessionStartTime` as a `DateTime` anchor. Elapsed time is always computed as `DateTime.now().difference(sessionStartTime)`, giving correct results even after the app is paused or backgrounded.

### 2. Global session state above ShellRoute
`activeSessionProvider` is scoped to `ProviderScope` (above the `ShellRoute`), so it survives tab switches. The floating mini-timer widget reads the same provider and is rendered inside `_AppShell` as an `Overlay`/`Stack`, always visible when a session is active.

### 3. Recurring slots — no duplicated Isar rows
Recurring personal slots are stored once with a `recurrenceType` field. The pure Dart `SlotExpander` reads stored slots and expands them into concrete instances for the currently viewed day before the grid renders. Isar stays clean; the grid always receives a flat `List<PersonalSlotModel>`.

### 4. Streak calculation without a dedicated Isar schema
Streak state is computed entirely from existing data. Study streak reads `StudySessionModel`; attendance streak reads a JSON-encoded list in `UserPrefsModel`. No new collection needed. Milestones are pure value objects — computed on every provider rebuild.

### 5. Dependency conflict — `isar_generator` vs `riverpod_generator`
`isar_generator 3.x` requires `analyzer >=4.6.0 <6.0.0`. `riverpod_generator >=2.4.2` requires `analyzer ^6.x`. These are mutually exclusive. Fixed by pinning `riverpod_generator: ^2.3.9` (resolves to 2.4.0). `riverpod_lint` and `custom_lint` removed — they are optional lint tools with no build-time role.

### 6. AGP 8.x namespace error for `isar_flutter_libs`
`isar_flutter_libs 3.1.0+1` ships a Groovy `build.gradle` without a `namespace` declaration. AGP 8+ requires it. Fixed with a `plugins.withId("com.android.library")` hook in `android/build.gradle.kts` that injects the namespace from the project group before evaluation. Using `afterEvaluate` failed because `evaluationDependsOn(":app")` had already triggered sibling project evaluation.

### 7. Dual-layer timetable as PageView
Three timetable views (Class Only / Both / Personal Only) are implemented as a three-page `PageView` rather than toggle buttons. This gives a natural swipe gesture and avoids conditional render complexity in the grid.

---

## Build Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after ANY model change
flutter analyze
flutter run
```

---

## Git History (MVP milestones)

| Commit | Message |
|---|---|
| Phase 1 | `feat: Phase 1 complete — CWA Target Planner` |
| Phase 2 | `feat: Phase 2 complete — Class Timetable + Free Time Detection` |
| Phase 3 | `feat: Phase 3 complete — Personal Timetable + Dual Layer View` |
| Phase 4 S1 | `feat(session): StudySession Isar model + domain analyser + global timer state` |
| Phase 4 S2 | `feat(session): course picker, timer widgets, analytics cards, floating mini-timer` |
| Phase 4 | `feat: Phase 4 complete — Study Session Tracking + Analytics Dashboard` |
| Phase 5 S1 | `feat(streak): Phase 5 Session 1 — Streak domain models + Isar setup` |
| Phase 5 S2 | `feat(streak): Phase 5 Session 2 — Streak UI widgets` |
| Phase 5 | `feat: Phase 5 complete — Streak System. CampusIQ MVP done.` |
| Post-MVP UX | `Timetable Add Class UX Improvements (CWA Course Fast-Select)` |

---

## What Comes Next (Post-MVP)

| Feature | Notes |
|---|---|
| Notifications | Study reminders, streak-at-risk alerts |
| Semester switcher | Archive/restore courses and timetable per semester |
| What-if scenario planner | Uses `CwaCalculator.whatIf()` already in domain layer |
| Onboarding flow | University + programme picker, initial target CWA setup |
| Multi-university support | Extend beyond KNUST |
| Cloud sync | Optional backup of Isar data |
