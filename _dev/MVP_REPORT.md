# CampusIQ — MVP Completion Report

**Date:** 2026-04-15
**Package:** com.wesleyconsults.campusiq
**Status:** MVP Complete (Phases 1–15.3) + Bug Fix Pass

---

## Overview

CampusIQ is a Flutter-based academic planning app built Android-first for Ghanaian university students (KNUST target audience). The full MVP covers fifteen phases plus Phases 15.1–15.3: CWA Target Planner, Class Timetable, Personal Timetable, Study Session Tracking, Streak System, Smart Notifications, Insights System, Weekly Review, AI Chat & Coach, Exam Prep Generator, Study Plan + Exam Mode, Course Hub Workspace (per-course notes, files, sessions, AI chat, and flashcards), Timetable Image Import (OpenAI Vision), Registration Slip Import into CWA, and Cumulative CWA with Past Result Slip Import.

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
│   │   ├── models/subscription_model.dart        — premium status + subscription details
│   │   ├── repositories/user_prefs_repository.dart
│   │   └── repositories/subscription_repository.dart
│   ├── providers/isar_provider.dart               — singleton FutureProvider<Isar>
│   ├── providers/subscription_provider.dart       — isPremiumProvider
│   ├── router/app_router.dart                     — GoRouter + ShellRoute
│   ├── services/notification_service.dart         — centralized local notifications singleton
│   └── theme/app_theme.dart                       — Material 3 + Inter
├── features/
│   ├── cwa/                                       — Phase 1 + Phase 13 + Phase 15.3
│   │   ├── data/models/course_model.dart
│   │   ├── data/models/past_semester_model.dart   — Phase 15.3: @collection + embedded PastCourseEntry
│   │   ├── data/repositories/cwa_repository.dart
│   │   ├── data/repositories/past_result_repository.dart — Phase 15.3: CRUD for past semesters
│   │   ├── domain/cwa_calculator.dart             — Phase 15.3: +calculateCumulative(), +totalCredits()
│   │   ├── domain/past_course_result.dart         — Phase 15.3: PastCourseResult value object
│   │   ├── domain/registration_course_import.dart — Phase 15.3: RegistrationCourseImport value object
│   │   ├── domain/registration_slip_parser.dart   — Phase 15.3: OpenAI vision → courses
│   │   ├── domain/result_slip_parser.dart         — Phase 15.3: OpenAI vision → grades
│   │   └── presentation/
│   │       ├── providers/cwa_provider.dart        — Phase 15.3: +cwaViewModeProvider, +pastSemestersProvider
│   │       ├── providers/whatif_provider.dart     — Phase 13: WhatIfState + WhatIfNotifier
│   │       ├── providers/registration_slip_import_provider.dart — Phase 15.3: slip import state machine
│   │       ├── providers/result_slip_import_provider.dart       — Phase 15.3: result slip state machine
│   │       ├── screens/cwa_screen.dart            — Phase 15.3: view mode toggle, scan icon
│   │       ├── screens/registration_slip_import_screen.dart     — Phase 15.3: AI course import flow
│   │       ├── screens/result_slip_import_screen.dart           — Phase 15.3: AI result import flow
│   │       ├── screens/past_semesters_screen.dart               — Phase 15.3: result history list
│   │       └── widgets/
│   │           ├── add_course_sheet.dart
│   │           ├── course_card.dart
│   │           ├── cwa_coach_sheet.dart           — Phase 13: AI CWA coach bottom sheet
│   │           ├── cwa_summary_bar.dart           — Phase 15.3: cumulative CWA display
│   │           ├── whatif_explain_chip.dart       — Phase 13: AI explanation chip
│   │           └── whatif_result_card.dart        — Phase 13: what-if result display
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
│   │   │   ├── timetable_constants.dart
│   │   │   ├── timetable_slot_import.dart          — Phase 15.2: parsed slot value object
│   │   │   └── timetable_vision_parser.dart        — Phase 15.2: DeepSeek VL2 image → slots
│   │   └── presentation/
│   │       ├── providers/timetable_provider.dart
│   │       ├── providers/personal_slot_provider.dart
│   │       ├── providers/timetable_import_provider.dart — Phase 15.2: import state machine
│   │       ├── screens/timetable_screen.dart
│   │       ├── screens/timetable_import_screen.dart    — Phase 15.2: full-screen import UI
│   │       └── widgets/
│   │           ├── add_slot_sheet.dart
│   │           ├── add_personal_slot_sheet.dart
│   │           ├── day_selector.dart
│   │           ├── dual_layer_grid.dart
│   │           ├── free_block_indicator.dart
│   │           ├── import_slot_review_tile.dart         — Phase 15.2: review list tile
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
│   ├── streak/                                    — Phase 5
│   │   ├── domain/
│   │   │   ├── milestone.dart
│   │   │   ├── streak_calculator.dart
│   │   │   └── streak_result.dart
│   │   └── presentation/
│   │       ├── providers/streak_provider.dart
│   │       ├── screens/streak_screen.dart
│   │       └── widgets/
│   │           ├── activity_heatmap.dart
│   │           ├── attendance_tracker.dart
│   │           ├── course_streak_list.dart
│   │           ├── milestone_grid.dart
│   │           ├── next_milestone_card.dart
│   │           ├── streak_hero_card.dart
│   │           └── streak_summary_mini.dart
│   ├── insights/                                  — Phase 9
│   │   ├── domain/
│   │   │   ├── insight.dart                       — Insight value object (type, message, icon)
│   │   │   └── insight_analyser.dart              — 7-check pure Dart analyser
│   │   └── presentation/
│   │       ├── providers/insight_provider.dart
│   │       ├── screens/insights_screen.dart
│   │       └── widgets/insight_card.dart
│   ├── review/                                    — Phase 10
│   │   ├── domain/
│   │   │   ├── weekly_review_calculator.dart      — pure Dart: totals, best day, highlights
│   │   │   └── weekly_review_data.dart            — WeeklyReviewData value object
│   │   └── presentation/
│   │       ├── providers/review_provider.dart
│   │       └── widgets/weekly_review_sheet.dart   — draggable sheet with stats + reflection
│   ├── plan/                                      — Phase 15
│   │   ├── data/
│   │   │   ├── models/daily_plan_task_model.dart  — Isar @collection
│   │   │   ├── models/exam_model.dart             — Isar @collection
│   │   │   ├── repositories/daily_plan_repository.dart
│   │   │   └── repositories/exam_repository.dart
│   │   ├── domain/
│   │   │   ├── exam_prep_planner.dart             — exam-mode task prioritiser
│   │   │   ├── plan_generator.dart                — free-block aware daily plan generator
│   │   │   └── plan_task.dart                     — PlanTask value object
│   │   └── presentation/
│   │       ├── providers/exam_mode_provider.dart
│   │       ├── providers/plan_provider.dart
│   │       ├── screens/plan_screen.dart
│   │       └── widgets/
│   │           ├── add_manual_task_sheet.dart
│   │           ├── exam_manager_sheet.dart
│   │           ├── exam_mode_activation_sheet.dart
│   │           ├── exam_mode_transition.dart
│   │           ├── plan_progress_bar.dart
│   │           └── plan_task_tile.dart
│   ├── settings/                                  — Phase 14 / Phase 15
│   │   └── presentation/
│   │       ├── providers/settings_provider.dart
│   │       └── screens/settings_screen.dart       — notification toggles, reminder time, dev premium
│   └── ai/                                        — Phase 12 + 14 + 15
│       ├── data/
│       │   ├── models/
│       │   │   ├── ai_message_model.dart
│       │   │   ├── ai_chat_session_model.dart
│       │   │   ├── ai_usage_model.dart
│       │   │   ├── study_plan_model.dart          — Phase 15
│       │   │   ├── study_plan_slot_model.dart     — Phase 15
│       │   │   └── weekly_review_model.dart       — Phase 15
│       │   └── repositories/
│       │       ├── ai_chat_repository.dart
│       │       └── ai_usage_repository.dart
│       ├── domain/
│       │   ├── context_builder.dart
│       │   ├── deepseek_client.dart
│       │   ├── deepseek_exception.dart
│       │   ├── exam_prep_models.dart              — Phase 14: MCQ/ShortAnswer/Flashcard types
│       │   ├── latex_sanitizer.dart               — strips LaTeX from AI responses
│       │   ├── notification_scheduler.dart        — Phase 14: schedules smart alerts
│       │   └── prompt_templates.dart
│       └── presentation/
│           ├── providers/
│           │   ├── ai_chat_provider.dart
│           │   ├── ai_providers.dart
│           │   ├── ai_usage_provider.dart
│           │   ├── exam_prep_provider.dart        — Phase 14
│           │   ├── study_plan_provider.dart       — Phase 15
│           │   └── weekly_review_provider.dart    — Phase 15
│           ├── screens/
│           │   ├── ai_chat_screen.dart
│           │   ├── exam_prep_screen.dart          — Phase 14
│           │   ├── subscribe_screen_stub.dart     — premium upsell stub
│           │   └── weekly_review_screen.dart      — Phase 15: AI weekly review + free gate
│           └── widgets/
│               ├── ai_chat_history_drawer.dart
│               ├── ai_message_bubble.dart
│               ├── ai_typing_indicator.dart
│               ├── flashcard_widget.dart          — Phase 14: 3D flip animation
│               ├── mcq_card.dart                  — Phase 14: MCQ with reveal animation
│               ├── plan_day_card.dart             — Phase 15
│               ├── plan_free_gate_card.dart       — Phase 15: free-tier gate for AI plan
│               ├── plan_slot_tile.dart            — Phase 15
│               ├── premium_gate_widget.dart
│               ├── question_type_selector.dart    — Phase 14
│               ├── review_gate_overlay.dart       — Phase 15: premium gate for AI review
│               ├── review_section_card.dart       — Phase 15
│               ├── short_answer_card.dart         — Phase 14
│               ├── study_plan_tab.dart            — Phase 15
│               ├── usage_counter_chip.dart
│               └── weekly_review_banner.dart      — Phase 15: banner in AI tab
│   └── course_hub/                                — Phase 15.1 (timetable import lives in timetable/)
│       ├── data/
│       │   ├── models/course_note_model.dart      — Isar @collection: notes per course
│       │   ├── models/course_file_model.dart      — Isar @collection: attached files per course
│       │   ├── repositories/course_note_repository.dart
│       │   └── repositories/course_file_repository.dart
│       ├── domain/course_hub_context_builder.dart — pure Dart: builds AI system prompt context string
│       └── presentation/
│           ├── providers/
│           │   ├── course_note_provider.dart      — @riverpod Stream family per courseCode
│           │   ├── course_file_provider.dart      — @riverpod Stream family per courseCode
│           │   └── hub_ai_provider.dart           — HubAiNotifier.family per courseCode
│           ├── screens/course_hub_screen.dart     — 6-tab DefaultTabController screen
│           └── widgets/
│               ├── hub_overview_tab.dart          — course info, expected score, CWA impact, stats, streak
│               ├── hub_sessions_tab.dart          — course-scoped bar chart + session history
│               ├── hub_notes_tab.dart             — note list with FAB, Dismissible delete, edit sheet
│               ├── hub_files_tab.dart             — file attach (FilePicker), open (OpenFilex), delete
│               ├── hub_flashcards_tab.dart        — per-course exam prep (hubExamPrepProvider family)
│               ├── hub_ai_tab.dart                — per-course AI chat (hubAiProvider family)
│               ├── note_editor_sheet.dart         — DraggableScrollableSheet for create/edit notes
│               └── file_tile.dart                 — PDF/image file row with open + delete actions
└── shared/
    ├── extensions/double_extensions.dart
    └── widgets/empty_state_widget.dart
```

---

## Routes

| Route | Screen | Phase |
|---|---|---|
| `/plan` | Daily Plan + Exam Mode (initial route) | 15 |
| `/cwa` | CWA Target Planner | 1, 13 |
| `/timetable` | Class + Personal Timetable (dual layer, swipe) | 2, 3 |
| `/sessions` | Study Session Tracker + Analytics Dashboard | 4 |
| `/streak` | Streak System + Milestone Gallery | 5 |
| `/insights` | Insights System (accessible from Sessions screen) | 9 |
| `/ai` | AI Coach & Academic Assistant Chatbot | 12 |
| `/ai/exam-prep` | Exam Prep Question Generator | 14 |
| `/ai/weekly-review` | AI-powered Weekly Review (full screen) | 15 |
| `/settings` | Notification Settings + DEV premium toggle | 14 |
| `/subscribe` | Premium subscription upsell stub | 12+ |
| `/course/:courseCode` | Course Hub Workspace (6-tab per-course workspace) | 15.1 |
| `/timetable/import` | Timetable Image Import (full-screen, no bottom nav) | 15.2 |

Navigation uses a `ShellRoute` with a 6-destination bottom nav bar. The floating mini-timer and exam mode nav icon state are rendered inside `_AppShell` and persist across all tab switches. The bottom nav shows: Plan, CWA, Table, Sessions, Streak, AI.

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
| High-impact badge | Flags all courses tied for the highest credit hours (previously only the first) |
| Target CWA dialog | Set a personal target via slider **or** `−`/`+` buttons (±1 step); gap indicator updates accordingly |
| Isar persistence | Courses survive hot restart and app relaunch |
| What-if logic | `CwaCalculator.whatIf()` available for future scenario screens |

**Isar schemas:** `CourseModel`

---

### Phase 2 — Class Timetable + Free Time Detection

**Route:** `/timetable` (Layer 1)

| Feature | Description |
|---|---|
| Day selector | Tap pill to switch day; swipe left/right on the grid to navigate days |
| Time grid | 6AM–8PM, hourly rows at 60px/hr (1.0 px/min); 30-min resolution |
| Add class slot | Bottom sheet with fast-select CWA course chips for instant autofill (course code, name, venue, type, time, color); time picker auto-promotes sub-6AM selections to PM; end time auto-advances if ≤ start |
| Slot card | Shows course code, name, venue, and (for slots ≥ 80 min) start time · type; 3-tier layout avoids overflow on 1-hour slots |
| Slot overlap handling | Overlapping same-day class slots are split into equal side-by-side lanes via `_assignColumns` — no stacked/unreadable text |
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
| Dual layer grid | `DualLayerGrid` renders class slots (Layer 1) and personal slots (Layer 2) in the same `Stack`; overlapping cross-layer slots (e.g. a class and a study block at the same time) are split into side-by-side lanes in Both view |
| Three views | Class Only / Both / Personal Only — switched by tapping the `TimetablePageIndicator` labels |
| Page indicator | Tappable `Class` / `Both` / `Personal` labels; active view highlighted |
| Add personal slot | Bottom sheet with category, recurrence, time, color; Sunday included in weekly day picker; same AM/PM and time-order validation as class slots |
| Personal slot detail | Tap to view / delete |

**Isar schemas:** `PersonalSlotModel`

**Timetable views:**
- Index 0 = Class Only
- Index 1 = Both (default)
- Index 2 = Personal Only

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

### Phase 9 — Insights System

**Route:** `/insights` (accessible via button in Session screen)

| Feature | Description |
|---|---|
| InsightAnalyser | Pure Dart class with 7 checks against session history and CWA courses |
| Best study day | Identifies the weekday with the highest cumulative study minutes |
| Neglected courses | Warns when a course has no sessions at all or hasn't been studied in 7+ days |
| Best study window | Computes the most productive 2-hour block from session start times |
| Late-night efficiency | Flags if 3+ sessions after 9PM average under 30 min — suggests earlier studying |
| Consistent course | Highlights any course with 4+ sessions in the last 14 days |
| Weekly trend | Compares current vs last week's total study hours; reports improvement or drop |
| Sorted display | Warnings appear first, then positives, then neutrals/tips |

**Isar schemas:** None (reads `StudySessionModel` and `CourseModel`)

---

### Phase 10 — Weekly Review System

| Feature | Description |
|---|---|
| WeeklyReviewCalculator | Pure Dart: computes total study minutes, best day, most-studied and most-neglected courses for any week range |
| WeeklyReviewData | Value object: weekStart, weekEnd, totalMinutesStudied, bestDay, mostStudiedCourse, mostNeglectedCourse, currentStreak, reflectionNote |
| WeeklyReviewSheet | Draggable bottom sheet (`DraggableScrollableSheet`) with 3-stat row (studied time, best day, streak), highlight chips, and a reflection text field |
| Reflection save | User can write and persist a weekly reflection note (stored in `UserPrefsModel`) |
| Historical access | Passing a specific `weekStart` to the sheet shows read-only history for that week |
| Animated entry | Stats, highlights, and reflection field use staggered `flutter_animate` fade + slide transitions |

**Isar schemas:** `UserPrefsModel` (reflection note stored as JSON field, no new collection)

---

### Phase 12 — AI Integration & Chat History

**Route:** `/ai_chat` (accessible via bottom nav or floating action)

| Feature | Description |
|---|---|
| DeepSeek Integration | Direct integration with DeepSeek API via `dart:convert` and `http`. |
| Context Builder | Injects user's academic context implicitly into AI prompts for personalization. |
| AI Chat Interface | Streamlined messaging UI with user/assistant bubbles and a typing indicator. |
| Chat History Tracker | Automatically tracks individual conversations, storing them in Isar as unified sessions. |
| Chat Sesssion Drawer | `endDrawer` interface listing previous conversations allowing users to switch chats. |
| AI Usage Limits | Local usage counter (`ai_usage_table`) capping non-premium users to 3 generic prompts per day. |
| Premium Paywall | Gateway widget substituting chat inputs when free-tier users exceed their limit. |

### Phase 13 — CWA AI Coach + What-If Explainer

**Route:** `/cwa` (coach and what-if are bottom sheets launched from CWA screen)

| Feature | Description |
|---|---|
| CWA Coach sheet | Bottom sheet that calls DeepSeek with the student's full course context and returns personalised academic advice; "Ask a follow-up" seeds the AI chat with the coaching advice as an initial assistant message so follow-up questions have full context |
| What-If Explainer | When a course score slider is dragged away from its saved value, an "Explain" chip appears; tapping it calls DeepSeek for a concise natural-language impact explanation |
| WhatIfState | `StateNotifier` tracking per-course adjusted scores, loading states, and cached explanations — avoids redundant API calls if the slider hasn't changed |
| Usage quota | CWA coach shares the `chat` quota (3/day free); what-if uses a separate `whatif` quota (2/day free); premium bypasses both |
| Premium gate | `PremiumGateWidget` shown inline in the coach sheet when quota is exhausted |
| LaTeX sanitizer | `latex_sanitizer.dart` strips LaTeX markup (`\(...\)`, `\[...\]`, `$$...$$`) from AI responses before display |

**Isar schemas:** None (reads `CourseModel`, uses `AiUsageModel` quota via existing `ai_usage_table`)

---

### Phase 14 — Exam Prep Generator + Smart Notifications

**Route:** `/ai/exam-prep`

| Feature | Description |
|---|---|
| Exam Prep Generator | AI-powered question generator for any course with 3 formats: MCQ, Short Answer, and Flashcards. |
| MCQ Interaction | Reveal correct answer and AI explanation on selection with animations. |
| Flashcard Animation | Realistic 3D-style flip animation using `flutter_animate`. |
| Background notifications | Periodic background tasks via `Workmanager` checking steak status. |
| Personalized Alerts | DeepSeek-generated motivational messages for streak-at-risk notifications. |
| Notification Service | Centralized management of local notifications (immediate and scheduled). |
| Permission Guard | One-time custom dialog for notification permissions before enabling smart features. |

**Isar schemas:** No new schemas (uses ephemeral state for questions; updates `UserPrefsModel`).

---

### Phase 15 — Study Plan, Exam Mode & AI Weekly Review

**Routes:** `/plan` (initial route), `/ai/weekly-review`

#### Daily Study Plan

| Feature | Description |
|---|---|
| PlanGenerator | Pure Dart: scans today's timetable slots for free blocks (6AM–8PM, 30-min minimum), prioritises courses by days-since-last-session, produces a typed `PlanTask` list (attend / study / personal) |
| AI plan generation | "Generate" button calls DeepSeek to produce a structured daily plan and persists tasks as `DailyPlanTaskModel` rows |
| Plan screen | Initial app route; shows date header, progress bar, sectioned task lists (Classes, Study/Exam Prep, Personal) with completion checkboxes |
| Progress bar | `PlanProgressBar` shows completed/total tasks with a celebration message when all done |
| Manual task add | Bottom sheet to add a custom task outside AI generation |
| Task types | `attend` (class), `study` (course work), `personal` (from personal timetable) |

#### Exam Mode

| Feature | Description |
|---|---|
| ExamModel | Isar collection storing course name, course code, exam date, and estimated study hours |
| Exam manager sheet | Add/remove upcoming exams with date picker and study hours estimate |
| Exam mode activation | Modal with countdown and activation confirmation; stored in `UserPrefsModel` |
| Exam mode nav icon | Plan tab icon changes to a fire icon (`Icons.whatshot`) and label reads "Exam" when active |
| Exam mode banner | Orange gradient banner at top of plan screen showing the next exam course and countdown |
| ExamPrepPlanner | Pure Dart: prioritises exam prep tasks based on proximity and estimated study load |
| Exam progress card | Per-exam progress bar showing prep session completion for each upcoming exam |
| Deactivation | "Exit" button on banner deactivates exam mode via `UserPrefsModel` |

#### AI Weekly Review (full screen)

| Feature | Description |
|---|---|
| WeeklyReviewScreen | Full-screen route at `/ai/weekly-review`; shows AI-generated narrative summary of the week |
| WeeklyReviewModel | Isar collection: stores `weekStartDate`, `reviewText`, `generatedAt`, `weeklyNotes` |
| AI review generation | DeepSeek generates a paragraph-form weekly performance narrative injected with session stats, streak, and CWA context |
| Review sections | `ReviewSectionCard` widgets display structured review segments with animated entry |
| Free gate | `ReviewGateOverlay` blocks the AI narrative for free-tier users; stats summary remains visible |
| AI tab banner | `WeeklyReviewBanner` in the AI chat tab directs users to the full-screen review |
| Study plan tab | `StudyPlanTab` in the AI screen shows the AI-generated plan for the current day |
| Plan free gate card | `PlanFreeGateCard` blocks AI plan generation for free users; manual task adding still available |

#### Settings Screen

| Feature | Description |
|---|---|
| Notification toggles | Per-category switches: study reminders, streak alerts, milestone alerts, weekly review prompt |
| Daily reminder time | Time picker for the daily study reminder; persisted to `UserPrefsModel` |
| Cancel all button | Cancels all scheduled local notifications |
| DEV premium toggle | Debug-mode only switch to flip premium status for testing; hidden in release builds |

**Isar schemas:** `DailyPlanTaskModel`, `ExamModel`, `StudyPlanModel`, `StudyPlanSlotModel`, `WeeklyReviewModel`

---

### Phase 15.1 — Course Hub Workspace

**Route:** `/course/:courseCode` (full-screen push, no bottom nav; entered from CWA course card → Open Workspace, timetable slot detail → Open Workspace, or sessions breakdown → course row tap)

| Feature | Description |
|---|---|
| Course Hub Screen | `DefaultTabController(length: 6)` wrapping a Scaffold with a scrollable `TabBar`; resolves the route `courseCode` parameter against `coursesProvider` before rendering |
| Overview tab | Course info card, expected score with `LinearProgressIndicator` + grade chip, CWA impact card (contribution points, current CWA, weight %), study stats (session count, total time, last studied), streak mini-card |
| Sessions tab | Course-scoped `WeeklyBarChart` using `PlannedActualAnalyser` with empty class/personal slots; reverse-chronological session list; swipe-to-delete |
| Notes tab | `StreamProvider`-backed note list; FAB opens `NoteEditorSheet` (create); tap opens edit mode; `Dismissible` swipe to delete |
| Files tab | `StreamProvider`-backed file list; attach button opens `FilePicker` (PDF, images, docs); file is copied to `appDir/course_files/<courseCode>/`; `OpenFilex` opens file; swipe/delete removes record and physical file |
| Flashcards tab | Reuses `ExamPrepNotifier` via a separate `hubExamPrepProvider` family (one per courseCode); course chip is pre-seeded and fixed — no course picker shown; reuses all Phase 14 question-type widgets |
| AI Chat tab | Per-course AI chat backed by `hubAiProvider` family; blue "Focused on [Code] — [Name]" banner at top; shares `chat` quota (3/day free); `HubAiNotifier._buildSystemPrompt()` injects full course context via `CourseHubContextBuilder` |
| CourseHubContextBuilder | Pure Dart; builds a multi-line context string from `CourseModel`, filtered `StudySessionModel` list, `CourseNoteModel` list, and `StreakResult`; injected into the AI system prompt for focused, context-aware responses |
| Entry points | CWA screen: "Open Workspace" as first item in course card `PopupMenuButton`; Timetable: "Open Workspace" `OutlinedButton` in slot detail sheet; Sessions: `InkWell` tap on each course row in `CourseBreakdownCard` |
| History isolation | Hub AI sessions use feature key `'course_<code>'`; `AiChatRepository.createSession` now accepts optional `courseCode` param; `AiChatSessionModel` has a new `@Index() String? courseCode` field |

**Isar schemas:** `CourseNoteModel`, `CourseFileModel` (new); `AiChatSessionModel` (updated — added `courseCode` field)

---

### Phase 15.2 — OpenAI Vision Timetable Import

**Route:** `/timetable/import` (full-screen push, no bottom nav; entered via scanner icon in Timetable AppBar)

| Feature | Description |
|---|---|
| Image picker | `image_picker` package — student picks from device camera or gallery; `imageQuality: 85` to balance quality and payload size |
| Size guard | Rejects images over 4 MB before sending to the API — shows a user-friendly error with a retry prompt |
| TimetableVisionParser | Pure Dart; base64-encodes the image bytes and POSTs a vision-format request to the OpenAI Chat Completions API (`/v1/chat/completions`); model name loaded from `.env`; strips markdown code fences from the response before JSON decoding; detects token-limit truncation (`finish_reason: "length"`) and surfaces a user-friendly crop-and-retry message |
| TimetableSlotImport | Pure Dart value object; `fromJson` normalises day strings ("Monday", "Mon", "MON", int 0–5), parses 24-hour `HH:MM` time strings to minutes, defaults missing `slot_type` to "Lecture", skips malformed entries silently |
| Import state machine | `TimetableImportNotifier` (Riverpod `@riverpod` class notifier) drives 7 states: `idle → picking → parsing → reviewing → saving → done → error`; each state renders a different UI body automatically |
| Review screen | After parsing, shows all extracted slots in a checklist — student can toggle individual slots on/off, or select/deselect all; slot count chip updates live |
| Confirm & save | Selected slots are assigned cycling colors from `TimetableConstants.slotColorValues` and written to `TimetableRepository.addSlot()` using the active semester key from `activeSemesterProvider`; imported courses are also synced one-way to CWA (missing courses added automatically) |
| Auto-navigate | On `done`, resets provider state and `context.go('/timetable')` — no manual navigation needed |
| Error recovery | Every failure path (no internet, empty parse, oversized image, truncation) lands in `error` state with a descriptive message and a "Try Again" button that resets to `idle` |
| Entry point | Scanner icon (`Icons.document_scanner_outlined`) added to the Timetable screen AppBar alongside the existing "+" button |

**New files:** `domain/timetable_slot_import.dart`, `domain/timetable_vision_parser.dart`, `presentation/providers/timetable_import_provider.dart`, `presentation/screens/timetable_import_screen.dart`, `presentation/widgets/import_slot_review_tile.dart`

**Modified files:** `timetable_screen.dart` (scanner icon), `app_router.dart` (new route), `pubspec.yaml` (`image_picker` dependency)

**Isar schemas:** None (imports directly into existing `TimetableSlotModel`)

---

### Phase 15.3 — CWA Registration Slip Import + Cumulative CWA

**Routes:** No new GoRouter routes — all new screens pushed via `MaterialPageRoute` from the CWA screen.

#### Registration Slip Import

| Feature | Description |
|---|---|
| Entry point | Document scanner icon in CWA AppBar (visible in Semester view only) → opens `RegistrationSlipImportScreen` |
| 3 input options | Camera (take photo), Gallery (pick JPG/PNG), PDF (file picker) |
| AI extraction | `RegistrationSlipParser` base64-encodes the image/PDF page and calls OpenAI vision with a course-extraction prompt; returns a list of `RegistrationCourseImport` value objects (courseCode, courseName, creditHours) |
| State machine | `RegistrationSlipImportNotifier` drives 6 states: `idle → picking → parsing → reviewing → saving → done → error` |
| Review screen | Lists all extracted courses with checkboxes; each selected course shows an inline credit-hours stepper (1–6); student can adjust before importing |
| Select / Deselect All | Header TextButton toggles all checkboxes |
| Confirm & save | Selected courses are written directly to `CwaRepository.addCourse()` — they land in the active semester CWA list |
| Done screen | Confirms count of courses added; instructs user to set expected scores from the CWA screen |

**New files:** `domain/registration_course_import.dart`, `domain/registration_slip_parser.dart`, `presentation/providers/registration_slip_import_provider.dart`, `presentation/screens/registration_slip_import_screen.dart`

**Isar schemas:** None (imports into existing `CourseModel` via `CwaRepository`)

---

#### Cumulative CWA + Past Result Slip Import

| Feature | Description |
|---|---|
| CWA view mode toggle | CWA screen has a `SegmentedButton` (Semester / Cumulative) stored in `cwaViewModeProvider`; changes AppBar actions and the summary bar display |
| PastSemesterModel | New Isar `@collection`; stores `semesterLabel`, `List<PastCourseEntry>` (embedded), `reportedSemesterCwa?`, `reportedCumulativeCwa?`, `createdAt` |
| PastCourseEntry | Embedded object: courseCode, courseName, creditHours, grade (A–F), mark? (exact %) — `score` getter prefers `mark` over letter-grade approximation |
| PastResultRepository | CRUD: save, getAll, update, delete for `PastSemesterModel` |
| CwaCalculator updates | `+calculateCumulative()` — flat-pools all past semester course entries + current courses then calls `calculate()`; `+totalCredits()` — sums credit hours across all semesters |
| CwaSummaryBar update | In cumulative mode shows: Cumulative CWA, total credit hours, semester count |
| Result Slip Import flow | Full 7-state machine (`idle → picking → parsing → labelling → reviewing → saving → done → error`) |
| 3 input options | Camera, Gallery (JPG/PNG), PDF — consistent with Registration Slip Import |
| AI extraction | `ResultSlipParser` calls OpenAI vision; extracts course code, course name, credit hours, grade, mark (if visible), plus slip-level `reportedSemesterCwa` and `reportedCumulativeCwa` if printed on the slip |
| Label step | After AI parsing, student names the semester (text input + quick-pick chips: "Year 1 Sem 1" through "Year 4 Sem 2") |
| Review screen | Shows courses found, reported CWA chips; each selected course shows inline grade dropdown (A/B/C/D/F, colour-coded), mark input field, and credit-hours stepper; all corrections auto-save as you edit |
| Confirm & save | Selected courses are packaged into a `PastSemesterModel` and written to `PastResultRepository` |
| Done screen | Confirms label saved and prompts user to switch to Cumulative view |
| Past Semesters Screen | History list at `/cwa → history icon`; expandable semester cards showing all courses; inline grade/mark/credits editing that auto-saves; delete with confirmation dialog |
| CWA recalculation | Adding or deleting a past semester triggers a live recalculation — cumulative CWA in the summary bar updates immediately via `pastSemestersProvider` stream |

**New files:** `data/models/past_semester_model.dart`, `data/repositories/past_result_repository.dart`, `domain/past_course_result.dart`, `domain/result_slip_parser.dart`, `presentation/providers/result_slip_import_provider.dart`, `presentation/screens/result_slip_import_screen.dart`, `presentation/screens/past_semesters_screen.dart`

**Modified files:** `cwa_screen.dart` (view mode toggle, conditional AppBar icons), `cwa_provider.dart` (pastSemestersProvider, pastResultRepositoryProvider, cwaViewModeProvider), `cwa_summary_bar.dart` (cumulative display), `cwa_calculator.dart` (calculateCumulative, totalCredits), `isar_provider.dart` (registers PastSemesterModel schema)

**Isar schemas:** `PastSemesterModel` (new)

---

## Isar Collections (full list)

| Collection | Feature | Phase | Purpose |
|---|---|---|---|
| `CourseModel` | CWA | 1 | Courses with credit hours + expected scores |
| `TimetableSlotModel` | Timetable | 2 | Official class slots (Layer 1) |
| `PersonalSlotModel` | Timetable | 3 | Personal/recurring slots (Layer 2) |
| `StudySessionModel` | Sessions | 4 | Completed study session records |
| `UserPrefsModel` | Core / Streak | 5 | Single-row key/value persistent flags (attended days, notification prefs, reflection notes, exam mode, daily goal) |
| `AiMessageModel` | AI Chat | 12 | Individual user/assistant chat messages |
| `AiChatSessionModel` | AI Chat | 12 | Individual chat session containers; `courseCode` field added in 15.1 for hub session isolation |
| `AiUsageModel` | AI Limits | 12 | Tracks daily usage and limits per quota type (chat, whatif) |
| `SubscriptionModel` | Payments | 12 | Tracks premium status and subscription details |
| `StudyPlanModel` | AI Planner | 15 | Container for AI-generated study plans |
| `StudyPlanSlotModel` | AI Planner | 15 | Individual tasks/slots within a study plan |
| `WeeklyReviewModel` | AI Weekly Review | 15 | Stores AI-generated weekly review text and metadata |
| `DailyPlanTaskModel` | Daily Plan | 15 | Daily tasks and checklist items with completion state |
| `ExamModel` | Exam Mode | 15 | Exam dates, course codes, and estimated study hours |
| `CourseNoteModel` | Course Hub | 15.1 | Per-course markdown notes with title, body, timestamps |
| `CourseFileModel` | Course Hub | 15.1 | Attached file records (PDF/image) with app-local path |
| `PastSemesterModel` | CWA | 15.3 | Past semester results (embedded `PastCourseEntry` list, reported CWA fields) |

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
| http | ^1.2.0 | DeepSeek API integration |
| flutter_dotenv | ^5.1.0 | Environment Variables / API Key isolation |
| flutter_local_notifications | ^21.0.0 | Local push notifications |
| flutter_timezone | ^5.0.2 | Device timezone detection |
| timezone | ^0.11.0 | Timezone data for scheduling |
| workmanager | ^0.9.0 | Background task execution |
| file_picker | ^8.1.2 | Native file picker (PDF, images, docs) for Course Hub file attachments |
| open_filex | ^4.4.1 | Open attached files with the device's default app handler |
| image_picker | ^1.1.2 | Camera and gallery image picker for timetable image import (Phase 15.2) |

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

### 7. Timetable navigation: swipe = days, tap = view mode
Horizontal swipe on the grid navigates between days (Mon → Tue → … → Sun) via a `GestureDetector` with a 300 velocity threshold. View mode switching (Class / Both / Personal) is handled by tapping the `TimetablePageIndicator` labels. This separates the two concerns cleanly — the original `PageView` approach conflated swipe with view switching, which users found unintuitive.

### 12. Slot overlap detection with greedy column assignment
Overlapping timetable slots (same layer or cross-layer in Both view) are rendered side-by-side using a greedy column-assignment algorithm in `DualLayerGrid._assignColumns`. Slots are sorted by start time; each is assigned to the first column whose last occupant has already ended. A second pass finds the highest column index used by any overlapping slot, giving each slot its `totalColumns` count. In Both mode, class and personal slots are pooled into a single call (personal IDs encoded as `-id - 1` to avoid Isar ID collisions) so cross-layer conflicts are resolved together.

### 8. Workmanager init without auto permission request
`callbackDispatcher` is a top-level function registered with Workmanager for background streak checks. The `NotificationService.init()` call was removed from the Workmanager dispatcher's first-run hook to prevent the OS permission dialog firing before the app's custom permission dialog, which rendered the Allow button non-functional. Permission is now only requested from within the app UI flow.

### 9. Separate quotas per AI feature type
Rather than a single daily AI usage counter, each AI feature has its own quota key (`chat`, `whatif`) tracked in `AiUsageModel`. This allows fine-grained rate limiting — e.g., 3 chat calls/day vs 2 what-if explanations/day — without a new Isar collection per feature.

### 10. PlanGenerator free-block scheduling
`PlanGenerator` does not just suggest sessions per course — it first computes free gaps between class slots in the 6AM–8PM grid (minimum 30-min block), then fills those gaps with study tasks ordered by days-since-last-session. This ensures generated plans are timetable-aware and never overlap with classes.

### 11. Exam mode as UserPrefsModel flag
Exam mode state (active/inactive, exam list) is stored in `UserPrefsModel` rather than a new Isar collection. `ExamModel` stores the exam records; the mode toggle is a boolean flag + timestamp. This keeps the schema count low while supporting full persistence across app restarts.

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
| Phase 8 | `feat: Phase 8 complete — Smart Notifications (free block, streak, milestone, weekly review, session reminders)` |
| Phase 9 | `feat: Phase 9 complete — InsightAnalyser domain + Insights UI with animated cards` |
| Phase 10 | `feat: Phase 10 complete — Weekly Review system with stats, reflection prompt, and Monday auto-show` |
| Post-MVP UX | `Timetable Add Class UX Improvements (CWA Course Fast-Select)` |
| Phase 12 | `ai chat bot updated with option to choose past conversations` |
| Phase 13 | `feat: Phase 13 complete — CWA AI coach + what-if explainer` |
| Phase 14 S1 | `feat(phase-14): exam prep generator + streak-secured notification` |
| Phase 14 S2 | `feat(phase-14): smart notifications session 2 — workmanager, permission dialog, background streak check` |
| Phase 14 fix | `fix(phase-14): remove auto permission request from init()` |
| Phase 15 S1 | `feat(phase-15): weekly review — Isar schema, generation, screen, free gate, AI tab banner` |
| Phase 15 S2 | `feat(phase-15): study plan — Isar schemas, provider, plan generation, sessions tab` |
| Bug fix pass | `fix: close all 11 bugs — CWA planner UX, AI coaching context, timetable grid overhaul` |
| Phase 15.1 | `feat(phase-15.1): course hub workspace — notes, files, sessions tab, flashcards, per-course AI chat` |
| Phase 15.2 S1 | `phase 15.2 DeepSeek Timetable Vision` |
| Phase 15.2 S2 | `open ai vision intergration` / `open ai vision intergration part 2 with model name` |
| Phase 15.2 fix | `vision model 2 updated with model name from .env` |
| Phase 15.2 link | `cwa linked with timetable oneway` / `timetable model success` |
| Phase 15.3 S1 | `registration slip integrated into CWA` / `split slip import idle into 3 options` |
| Phase 15.3 S2 | `add cumulative CWA tracking with past result slip import` |
| Phase 15.3 S3 | `cumulative cwa updated` |

---

## What Comes Next (Post-Phase 15.3)

| Feature | Notes |
|---|---|
| Semester switcher | Archive/restore courses and timetable per semester |
| Onboarding flow | University + programme picker, initial target CWA setup |
| Premium payment integration | Replace `SubscribeScreenStub` with real in-app purchase flow |
| Multi-university support | Extend beyond KNUST |
| Cloud sync | Optional backup of Isar data |
| Push notifications (remote) | Server-triggered alerts via FCM for AI-personalized content |
| CWA grade scale config | Allow student to set their university's A/B/C/D score bands (currently KNUST defaults) |
