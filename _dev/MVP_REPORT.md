# UniMate — MVP Completion Report

**Date:** 2026-05-22
**Package:** com.wesleyconsults.campusiq
**Status:** v1.0 Lean Build — University Onboarding, Multi-Grading-System, Dark Mode, Course Reminders, AI Proxy Architecture, and Production Polish Complete. Runtime device testing required before beta release.

---

## Overview

UniMate is a Flutter-based academic planning app built Android-first for Ghanaian university students. The v1.0 build covers: redesigned 6-step University Onboarding (welcome → university + optional programme → target/grading system → grades import preview → timetable import preview → reminders + optional setup shortcut), Multi-Grading-System Support (CWA, GPA 4.0, GPA 4.0 GIMPA, CGPA 5.0 with configurable grade scales for 20+ Ghanaian universities), CWA/GPA Target Planner (semester + cumulative with complete-semester flow), Class Timetable (single-layer), Study Session Tracking (Normal + Pomodoro modes) with vibrate/sound timer feedback, Streak System, Smart Notifications, Insights System, Weekly Review, AI Weekly Review, AI Study Plan, Daily Study Plan, Course Hub Workspace (per-course overview, sessions, and notes), Timetable Image Import (OpenAI Vision), Registration Slip Import, Cumulative Result Slip Import, Course Reminders (per-course notification scheduling), Dark Mode (system/light/dark), Firebase Core/Analytics/Crashlytics for Android crash monitoring, a polished Settings screen with About section, Vercel AI Proxy (keyless architecture routing all AI requests through campusiq-api.vercel.app), and internet permissions for release builds. **Removed in v1.0:** Personal Timetable (Layer 2), Exam Prep Generator, Exam Mode, the global AI chatbot, CWA AI Coach, AI chat history/usage quotas, markdown/math chat rendering dependencies, the Course Hub Flashcards tab, the Course Hub Files tab, the Course Hub per-course AI chat, the What-If AI feature, and the flutter_dotenv package (replaced by the keyless proxy) — all cut to reduce complexity and improve stability for launch.

### Current MVP AI Scope Update

The May 2026 MVP scope keeps only focused AI features that perform a specific job. All AI requests are routed through the Vercel proxy at `campusiq-api.vercel.app` — no API keys live on-device.

- **Kept:** CWA registration/result slip import via OpenAI Vision (through proxy), AI Weekly Review, AI Study Plan, and AI-generated streak notification text.
- **Removed:** global AI Assistant FAB, `/ai` chatbot route, chat UI/history, chat storage models, chat usage limits, CWA Coach, chatbot-only markdown/math packages, and the `flutter_dotenv` package (replaced by keyless proxy).
- **Storage kept:** `StudyPlanModel`, `StudyPlanSlotModel`, and `WeeklyReviewModel`.
- **Storage removed:** `AiMessageModel`, `AiChatSessionModel`, and `AiUsageModel`.

### Firebase Crashlytics Update

**Completed:** 2026-05-22  
**Scope:** Android only for Firebase project `unimate-69516` and Android package `com.wesleyconsults.campusiq`.

- Added `firebase_core`, `firebase_crashlytics`, and `firebase_analytics`.
- Ran `flutterfire configure --project=unimate-69516 --platforms=android`.
- Generated `lib/firebase_options.dart`, `firebase.json`, and `android/app/google-services.json`.
- Added Google Services and Firebase Crashlytics Gradle plugins to the Android project.
- Initialized Firebase before `runApp` using `DefaultFirebaseOptions.currentPlatform`.
- Added Crashlytics handlers for Flutter framework errors, platform dispatcher errors, and guarded-zone uncaught errors.
- Preserved existing startup logic: `ProviderScope`, Riverpod, Isar access, notification setup, Workmanager setup, router/theme setup, and Vercel AI proxy architecture.
- Added a debug-only Settings → Dev → `Test Crashlytics crash` action that calls `FirebaseCrashlytics.instance.crash()`.
- Confirmed a test crash appears in Firebase Console under Crashlytics for the Android app.
- Fixed a startup `Zone mismatch` Crashlytics issue by moving Flutter binding initialization and the full app startup sequence inside `runZonedGuarded`.
- Removed accidental iOS `GoogleService-Info.plist` generated during an all-platform FlutterFire CLI run; Firebase remains Android-only for now.

### Analytics and Non-Fatal Reporting Update

**Completed:** 2026-05-22  
**Scope:** Privacy-safe launch health and product-flow observability for Android Firebase.

- Added `AnalyticsService` as a central Firebase Analytics wrapper.
- Added `CrashReportingService` as a central Firebase Crashlytics wrapper for fatal and non-fatal reports.
- Added `TrackedScreen` wrapper to record screen views without scattering raw Firebase calls through screens.
- Screen views tracked: onboarding, Today, planner, timetable, sessions, weekly review, streak, insights, settings, course hub, timetable import, course reminders, manual entry, past semesters, registration import, and result import.
- Product events tracked:
  - `onboarding_started`, `onboarding_completed`, `onboarding_skipped`
  - `grading_system_selected`
  - `settings_theme_changed`
  - `course_added`, `course_updated`
  - `course_import_started`, `course_import_succeeded`, `course_import_failed`
  - `timetable_slot_added`, `timetable_slot_updated`
  - `timetable_import_started`, `timetable_import_succeeded`, `timetable_import_failed`
  - `study_session_started`, `study_session_completed`
  - `pomodoro_started`, `pomodoro_completed`
  - `weekly_review_generated`, `weekly_review_failed`
  - `ai_study_plan_generated`, `ai_study_plan_failed`
- Anonymous user properties tracked: `grading_system`, `theme_mode`, `notifications_enabled`, `onboarding_completed`, and `university_set`.
- Non-fatal Crashlytics reports added for caught import/parser failures, AI generation failures, notification scheduling failures, Workmanager background task failures, Isar open/write failures in key repositories, and session/course/timetable save failures.
- Privacy rule: no course names, exact grades/scores, timetable venues, notes, AI prompts/responses, uploaded file contents, programme names, or personal identifiers are tracked.
- Services skip Firebase calls when Firebase is not initialized, keeping widget tests clean.

---

## UI Redesign and Release Polish Update

**Completed:** 2026-05-05
**Scope:** Full visual redesign of every major screen, modal, and support surface. All business logic, providers, repositories, and Isar schemas were preserved. No new features or database concepts were introduced.

The UI redesign and static QA pass are complete. Runtime device testing is still required before beta release.

### Design System

| Token | Value |
|---|---|
| Font | Inter (Google Fonts) |
| Icon style | Lucide-style |
| Background | Soft off-white (`AppColors.surface`) |
| Cards / surfaces | White with large rounded corners |
| Primary colour | Deep navy (`AppColors.primary`) |
| Accent | Muted gold (`AppColors.goldSoft`), used sparingly |
| Spacing | Generous and consistent via `AppSpacing` tokens |
| Tone | Calm, supportive, student-friendly |

Reusable token files:
- `lib/core/theme/app_tokens.dart` — colours, spacing, radii, shadows
- `lib/core/theme/app_theme.dart` — Material 3 theme with Inter typography

Reusable shared widgets delivered: cards, buttons, chips, section headers, modal components, empty state, error retry, offline banner.

---

### Phase 1 — Design System Foundation

- Inter typography scaled across all text styles
- Lucide-style icon set adopted throughout
- Deep navy / muted gold / soft off-white palette applied globally
- Reusable tokens created for colours, spacing, radii, shadows, and typography
- Reusable widgets built: cards, buttons, chips, section headers, modal header/handle/action row
- Global theme cleaned up — hardcoded colours and spacing replaced with token references

### Phase 2 — App Shell + Bottom Navigation

- 4-tab bottom nav: **Home, CWA, Table, Sessions**
- Floating rounded pill-shaped bottom navigation bar with semi-transparent background, border, and drop shadow
- `_ShellBottomNav` renders four destinations with Lucide icons; selected tab gets tinted background and bold label
- Global AI FAB removed for the focused AI MVP
- `FloatingMiniTimer` — appears above the nav bar when a session is active; pushes `/sessions` on tap
- `/ai` chatbot route removed
- Shell tabs render full height with in-page trailing overlay clearance so content scrolls above the nav and mini timer
- Safe-area and bottom-nav spacing refined — content is no longer permanently clipped above the navbar
- Contrast fixes for header action buttons

### Phase 3 — Home / Today Screen Redesign

- Premium Home dashboard at `/plan` (initial route)
- In-body greeting header with date
- Hero card driven by active session / current class / next class / "day open" state
- `Academic pulse` — 2-column grid of compact tiles (CWA metrics, streak)
- `Today at a glance` — class count, pending study tasks, progress summary
- `Progress` section with plan progress bar
- Lower detail sections: active session resume card, today's classes, free blocks, task list (Planned classes / Suggested study tasks / Personal tasks)
- `Suggested focus` section removed during refinement to reduce first-screen congestion
- Free-block metric removed from Today at a glance
- Local add-task FAB removed to reduce floating-action clutter; task creation remains available through inline actions
- Bottom-safe spacing refined so lower Home content scrolls above the floating bottom nav
- Small-screen overflows fixed: tightened academic pulse tile padding/typography, long task labels wrap to 2 lines with ellipsis, stable trailing column for task time/duration

### Phase 4 — CWA Screen Redesign

- CWA screen redesigned around academic performance
- Semester / Cumulative segmented control directly under the app bar
- CWA hero card displaying projected CWA, target, and gap
- Compact stats cards — credits summary, course count, import helper CTA
- Compact course cards with score slider, grade chip, and overflow menu (Open Workspace, Edit, Delete)
- Subtitle under CWA title removed for cleaner header
- Import action in AppBar opens a polished rounded bottom sheet (Take Photo, Upload Image, Choose PDF, Enter Manually)
- Add Course visibility and bottom-nav overlap issues fixed
- Hero card and stats overflow refinements
- CWA calculations, import, and manual entry logic preserved

### Phase 5 — Table / Timetable Screen Redesign

- Timetable redesigned to feel calmer and easier to scan
- Day selector pills polished — horizontal scrollable row of 7 days
- Compact day summary card (selected day, class count, next/first class, free-block count)
- Daily timetable restored as full-page scrollable content — no longer trapped in a small inner scroll box
- Class blocks visible and readable with calmer card styling
- Free blocks visible as lighter, less dominant indicators
- Summary card made smaller to prioritise timetable content
- Blank gap above bottom nav reduced
- Add/edit/delete slot and free-block detection logic preserved

### Phase 6 — Sessions Screen Redesign

- Sessions redesigned as a calm focus room
- Start Session card with Normal / Pomodoro segmented toggle
- Today's progress card redesigned — no overflow
- History / Plan tab controls polished
- Normal and Pomodoro flow preserved
- Active session behaviour preserved
- Mini timer preserved
- Today's progress overflow fixed
- Plan tab FormatException fixed with safe parsing and fallbacks
- Session logic and timer logic preserved

### Phase 7A — Bottom Sheets, Dialogs, and Pickers Polish

- Shared modal sheet system with consistent header, handle, and action row
- AddCourseSheet polished
- AddSlotSheet polished
- CoursePickerSheet polished
- CWA import options sheet polished
- SlotDetailSheet polished
- CWA coach sheet polished
- Confirmation dialogs standardised across the app
- Delete confirmations added where safe (courses, sessions, notes, timetable slots)
- Keyboard-safe modal behaviour improved

### ~~Phase 7B — AI Chat Screen Polish~~ *(removed from current MVP)*

- The full-screen AI Chat route (`/ai`), chat composer, chat history drawer, message bubbles, typing indicator, usage counter, and chat-only markdown/math rendering were removed in the focused AI MVP pass.
- Weekly Review and Study Plan remain active AI surfaces.

### Phase 7C — Course Hub Polish

- Course Hub (`/course/:courseCode`) polished as a focused 3-tab course workspace
- Improved course header and summary card
- Improved tab bar: Overview, Sessions, Notes
- Overview tab: course info, expected score with progress bar + grade chip, CWA impact, study stats, streak mini-card
- Sessions tab: course-scoped bar chart and session history
- Notes tab: note list with FAB, Dismissible delete, edit via NoteEditorSheet
- Note editor modal styling improved
- Course navigation logic preserved (entry from CWA course card, timetable slot, sessions breakdown)
- Files tab and per-course AI tab removed in v1.0 launch scope reduction

### Phase 7D — Import + Manual Entry Flow Polish

- Manual course entry screen (`/cwa/manual-entry`) polished — focused full-screen form, no bottom nav
- Import review, loading, and error states polished
- Past semester / history screen polished
- Validation preserved (empty fields, duplicate course codes, non-numeric values)
- Keyboard-safe form behaviour preserved
- Parsing and save logic unchanged

### Phase 7E — Settings, Streak, Insights, Weekly Review Polish

- Settings screen polished — notification toggles, daily reminder time picker, cancel all button, DEV premium toggle
- Streak screen polished — hero card, milestone grid, activity heatmap, course streak list, attendance tracker
- Insights screen polished — insight cards with animated entry
- Weekly Review sheet and full-screen route polished
- All support screens aligned to the premium design direction
- Business logic preserved throughout

### Phase 8 — Full QA, Consistency Cleanup, Release Polish

- Consistency cleanup across the entire UI
- Hardcoded colours replaced with tokens in multiple files
- Contrast bug fixed in timetable import screen
- Modal sheet pattern made more consistent
- Unused imports removed
- Bottom nav and safe-area approach inspected and hardened
- Keyboard safety inspected across all form screens
- Handwritten-source analyzer issues cleaned up: removed an unused import, added missing `const`, added braces to flagged `if` statements, and fixed an async `BuildContext` usage in timetable delete feedback
- Generated `**/*.g.dart` files excluded from analyzer so Riverpod/Isar generated warnings do not obscure maintained-code issues
- `flutter analyze` now passes with no issues
- `test/ui_redesign_regression_test.dart` updated to assert compact active-session timer presence via `FloatingMiniTimer` instead of expecting expanded course text on non-Sessions shell tabs
- App ready for on-device beta testing

### Current Navigation Summary

**Onboarding (shown before shell when first-run):**
- `/onboarding` — redesigned 6-step university onboarding flow; GoRouter redirect guard blocks all other routes until completed

**Shell route (bottom nav):**
- `Home` at `/plan` — user-facing Today dashboard
- Grades tab (dynamic label: CWA/GPA/CGPA) at `/cwa` — Academic Target Planner
- `Table` at `/timetable` — Class Timetable
- `Sessions` at `/sessions` — Study Session Tracker

**Full-screen routes (outside shell, no bottom nav):**
- `/streak` — Streak System (via drawer from Today)
- `/insights` — Insights (via drawer from Today)
- `/settings` — Settings (via drawer or bell icon from Today)
- `/ai/weekly-review` — AI Weekly Review
- `/course/:courseCode` — Course Hub Workspace
- `/timetable/import` — Timetable Image Import
- `/timetable/reminders` — Course Reminders
- `/cwa/manual-entry` — Manual Course Entry
- `/cwa/history` — Past Semesters History
- `/cwa/import/registration` — Registration Slip Import
- `/cwa/import/results` — Result Slip Import

**Navigation behaviour:**
- Onboarding guard: if `hasCompletedOnboarding == false`, all routes redirect to `/onboarding`
- Final onboarding setup shortcuts complete onboarding, go to Today, then optionally push registration-slip import or timetable import so Android Back returns to Today
- Tab switches use `context.go()` — back from a tab exits the app
- Drill-down screens use `context.push()` — back returns to the previous screen
- Today screen has a local drawer (hamburger menu) with links to Today, Streak, Insights, Weekly Review, Settings, and Subscribe
- Active-session mini timer renders inside `_AppShell` and persists across all tab switches
- Bottom nav second tab label changes dynamically with the active grading system (e.g. "CWA", "GPA", "CGPA")

### Validation Summary

- `dart format` — passed on edited source/test files
- `flutter analyze` — passed with no issues
- `flutter test test/ui_redesign_regression_test.dart` — passed (shell navigation, CWA import sheet, small-display manual entry, compact active-session mini timer)
- `flutter test` — passed after Firebase/Crashlytics setup and after the Crashlytics zone fix (9 tests)
- `flutter build apk --debug` — passed after Firebase/Crashlytics setup
- Firebase Console Crashlytics — Android debug test crash received for `com.wesleyconsults.campusiq`
- After adding AnalyticsService and CrashReportingService instrumentation: `flutter analyze` passed with no issues and `flutter test` passed with all 9 tests
- `flutter run -d macos` — not tested (xcodebuild unavailable in this environment)
- `flutter run -d chrome` — not tested (pre-existing Isar JS compile errors unrelated to redesign)
- **On-device Android testing:** Crashlytics debug crash flow confirmed; broader beta device testing still required before release

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Android-first) |
| Language | Dart |
| State management | Riverpod (riverpod_annotation + riverpod_generator) |
| Local storage | Isar 3.x |
| Navigation | GoRouter with shell + full-screen push routes |
| Fonts | Google Fonts — Inter |
| Code generation | build_runner + isar_generator + riverpod_generator |
| Crash monitoring | Firebase Crashlytics (Android-only, project `unimate-69516`) |
| Analytics | Firebase Analytics dependency added for Android Firebase setup |

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

## Current Navigation Snapshot

### Shell routes (bottom nav tabs)

- `/plan` — user-facing **Today** (Home tab)
- `/cwa` — CWA Target Planner
- `/timetable` — Class Timetable (Table tab)
- `/sessions` — Study Session Tracker

### Full-screen routes outside the shell (no bottom nav)

- `/streak` — Streak System (via drawer from Today)
- `/insights` — Insights (via drawer from Today)
- `/settings` — Settings (via drawer or bell icon from Today)
- `/ai/weekly-review` — AI Weekly Review
- `/course/:courseCode` — Course Hub Workspace
- `/timetable/import` — Timetable Image Import
- `/cwa/manual-entry` — Manual Course Entry
- `/subscribe` — Premium subscription

These full-screen routes intentionally do not show the bottom nav.

---

## Full File Tree (source files only)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/app_constants.dart              — app name "UniMate", default semester, pass/distinction thresholds
│   ├── config/
│   │   └── ai_proxy_config.dart                  — Phase 20: static proxy URLs (deepseek + openai-vision endpoints)
│   ├── data/
│   │   ├── models/user_prefs_model.dart          — single-row key/value Isar store; 17: +gradingSystemId, universityName, programmeName, themeModeIndex, vibrateOnTimerEnd, playSoundOnTimerEnd, hasCompletedOnboarding
│   │   ├── models/subscription_model.dart        — premium status + subscription details
│   │   ├── isar_database.dart                    — Phase 15.8: centralised schema list + openCampusIqIsar(); 19: +CourseReminderModelSchema
│   │   ├── repositories/user_prefs_repository.dart
│   │   └── repositories/subscription_repository.dart
│   ├── domain/
│   │   ├── grade_scale.dart                      — Phase 17: GradeScale + GradeScaleEntry value objects
│   │   ├── grading_system.dart                   — Phase 17: GradingSystem domain class (CWA, GPA 4.0, GPA 4.0 GIMPA, CGPA 5.0)
│   │   └── university_defaults.dart              — Phase 17: 20+ Ghanaian universities mapped to grading systems
│   ├── providers/isar_provider.dart               — singleton FutureProvider<Isar>; 15.8: delegates to isar_database.dart
│   ├── providers/connectivity_provider.dart       — Phase 15.5: isOnlineProvider (FutureProvider<bool>)
│   ├── providers/subscription_provider.dart       — isPremiumProvider
│   ├── router/app_router.dart                     — GoRouter + ShellRoute; 16: onboarding redirect guard + /onboarding route; 19: /timetable/reminders route
│   ├── services/connectivity_service.dart         — Phase 15.5: ConnectivityService.isOnline() via connectivity_plus
│   ├── services/notification_service.dart         — centralized local notifications singleton; 19: course reminder scheduling (IDs 700-999)
│   └── theme/app_theme.dart                       — Material 3 light + dark themes; 18: full dark palette
├── features/
│   ├── cwa/                                       — Phase 1 + Phase 13 + Phase 15.3 + 15.6
│   │   ├── data/models/course_model.dart
│   │   ├── data/models/past_semester_model.dart   — Phase 15.3: @collection + embedded PastCourseEntry; 15.6: +semesterKey
│   │   ├── data/repositories/cwa_repository.dart
│   │   ├── data/repositories/past_result_repository.dart — Phase 15.3: CRUD for past semesters; 15.6: duplicate detection
│   │   ├── domain/cwa_calculator.dart             — Phase 15.3: +calculateCumulative(), +totalCredits()
│   │   ├── domain/past_course_result.dart         — Phase 15.3: PastCourseResult value object
│   │   ├── domain/registration_course_import.dart — Phase 15.3: RegistrationCourseImport value object
│   │   ├── domain/registration_slip_parser.dart   — Phase 15.3: OpenAI vision → courses; 15.6: +skipped-row counting
│   │   ├── domain/result_slip_parser.dart         — Phase 15.3: OpenAI vision → grades; 15.6: +skipped-row counting
│   │   └── presentation/
│   │       ├── providers/cwa_provider.dart        — Phase 15.3: +cwaViewModeProvider, +pastSemestersProvider; 15.6: +activeSemester persistence, +targetCwa persistence
│   │       ├── providers/registration_slip_import_provider.dart — Phase 15.3: slip import state machine; 15.6: +editable scores
│   │       ├── providers/result_slip_import_provider.dart       — Phase 15.3: result slip state machine; 15.6: +dedup, +auto-label
│   │       ├── screens/cwa_screen.dart            — Phase 15.3: view mode toggle, scan icon; 15.6: +Complete Semester, +semester picker, +progression card, GoRouter nav
│   │       ├── screens/complete_semester_screen.dart — Phase 15.6: projected courses → real results flow
│   │       ├── screens/registration_slip_import_screen.dart     — Phase 15.3: AI course import flow; 15.6: +score sliders in review, +parse warnings
│   │       ├── screens/result_slip_import_screen.dart           — Phase 15.3: AI result import flow; 15.6: +auto-label, +dedup prompt, +parse warnings
│   │       ├── screens/cwa_manual_entry_screen.dart — Phase 15.6: +grade-first cumulative mode, +draft auto-save, +credit cap 12
│   │       ├── screens/past_semesters_screen.dart               — Phase 15.3: result history list; 15.6: +inline grade editing, +immediate CWA recalc
│   │       └── widgets/
│   │           ├── active_semester_picker.dart    — Phase 15.6: configurable semester selector
│   │           ├── add_course_sheet.dart          — 15.6: credit cap raised to 12
│   │           ├── course_card.dart               — 15.7: what-if explain chip removed
│   │           └── cwa_summary_bar.dart           — hero CWA display (semester + cumulative); 15.6: +cumulative progression
│   ├── timetable/                                 — Phase 2 + redesign + 19
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── course_reminder_model.dart      — Phase 19: @collection for per-course class reminders
│   │   │   │   └── timetable_slot_model.dart
│   │   │   └── repositories/timetable_repository.dart
│   │   ├── domain/
│   │   │   ├── free_time_detector.dart
│   │   │   ├── timetable_constants.dart
│   │   │   ├── timetable_slot_import.dart          — Phase 15.2: parsed slot value object
│   │   │   └── timetable_vision_parser.dart        — Phase 15.2: image → slots
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── course_reminder_provider.dart   — Phase 19: CRUD + notification scheduling
│   │       │   ├── timetable_import_provider.dart  — Phase 15.2: import state machine
│   │       │   └── timetable_provider.dart
│   │       ├── screens/
│   │       │   ├── course_reminders_screen.dart    — Phase 19: full-screen reminder list + add/edit sheet
│   │       │   ├── timetable_import_screen.dart    — Phase 15.2: full-screen import UI
│   │       │   └── timetable_screen.dart
│   │       └── widgets/
│   │           ├── add_slot_sheet.dart
│   │           ├── class_timetable_grid.dart
│   │           ├── day_selector.dart
│   │           ├── free_block_indicator.dart
│   │           ├── import_slot_review_tile.dart         — Phase 15.2: review list tile
│   │           ├── slot_detail_sheet.dart
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
│   ├── plan/                                      — Phase 15 + redesign
│   │   ├── data/
│   │   │   ├── models/daily_plan_task_model.dart  — Isar @collection
│   │   │   └── repositories/daily_plan_repository.dart
│   │   ├── domain/
│   │   │   ├── plan_generator.dart                — free-block aware daily plan generator
│   │   │   └── plan_task.dart                     — PlanTask value object
│   │   └── presentation/
│   │       ├── providers/plan_provider.dart
│   │       ├── screens/plan_screen.dart
│   │       └── widgets/
│   │           ├── add_manual_task_sheet.dart
│   │           ├── plan_progress_bar.dart
│   │           └── plan_task_tile.dart
│   ├── settings/                                  — Phase 14 / Phase 15 / Phase 18
│   │   └── presentation/
│   │       ├── providers/settings_provider.dart    — notificationPrefsProvider + themeModeProvider
│   │       └── screens/settings_screen.dart       — Academic, Timer Feedback, Notifications, Appearance, About, Dev sections; dark mode picker; grading system picker; about dialog; privacy/terms/feedback links; reset onboarding
│   ├── onboarding/                                — Phase 16: redesigned 6-step first-run flow
│   │   └── presentation/
│   │       ├── providers/onboarding_provider.dart  — OnboardingNotifier (StateNotifier), optional OnboardingStartAction + hasCompletedOnboardingProvider (redirect guard)
│   │       ├── screens/
│   │       │   ├── onboarding_screen.dart          — Step switcher with progress dots
│   │       │   ├── onboarding_welcome_screen.dart
│   │       │   ├── onboarding_university_screen.dart  — searchable list of 20+ universities + optional programme
│   │       │   ├── onboarding_target_screen.dart
│   │       │   ├── onboarding_grades_import_screen.dart
│   │       │   ├── onboarding_timetable_import_screen.dart
│   │       │   └── onboarding_notifications_screen.dart
│   │       └── widgets/onboarding_progress_dots.dart
│   └── ai/                                        — focused AI: DeepSeek review/planning + smart alerts
│       ├── data/
│       │   ├── models/
│       │   │   ├── study_plan_model.dart          — Phase 15
│       │   │   ├── study_plan_slot_model.dart     — Phase 15
│       │   │   └── weekly_review_model.dart       — Phase 15
│       ├── domain/
│       │   ├── context_builder.dart
│       │   ├── deepseek_client.dart
│       │   ├── deepseek_exception.dart
│       │   └── notification_scheduler.dart        — Phase 14: schedules smart alerts
│       └── presentation/
│           ├── providers/
│           │   ├── ai_providers.dart
│           │   ├── study_plan_provider.dart       — Phase 15
│           │   └── weekly_review_provider.dart    — Phase 15
│           ├── screens/
│           │   ├── subscribe_screen_stub.dart     — premium upsell stub
│           │   └── weekly_review_screen.dart      — Phase 15: AI weekly review + free gate
│           └── widgets/
│               ├── plan_day_card.dart             — Phase 15
│               ├── plan_free_gate_card.dart       — Phase 15: free-tier gate for AI plan
│               ├── plan_slot_tile.dart            — Phase 15
│               ├── review_gate_overlay.dart       — Phase 15: premium gate for AI review
│               ├── review_section_card.dart       — Phase 15
│               └── study_plan_tab.dart            — Phase 15
│   └── course_hub/                                — Phase 15.1 + 15.4 + 15.7
│       ├── data/
│       │   ├── models/course_note_model.dart      — Isar @collection: notes per course
│       │   └── repositories/course_note_repository.dart
│       └── presentation/
│           ├── providers/
│           │   └── course_note_provider.dart      — @riverpod Stream family per courseCode
│           ├── screens/course_hub_screen.dart     — 3-tab DefaultTabController screen
│           └── widgets/
│               ├── hub_overview_tab.dart          — course info, expected score, CWA impact, stats, streak
│               ├── hub_sessions_tab.dart          — course-scoped bar chart + session history
│               ├── hub_notes_tab.dart             — note list with FAB, Dismissible delete, edit sheet
│               └── note_editor_sheet.dart         — DraggableScrollableSheet for create/edit notes
└── shared/
    ├── extensions/double_extensions.dart
    ├── widgets/empty_state_widget.dart
    ├── widgets/error_retry_widget.dart            — Phase 15.5: shared error card (message + "Try Again" button)
    └── widgets/offline_banner.dart               — Phase 15.5: animated offline banner widget
```

---

## Routes

| Route | Screen | Phase |
|---|---|---|
| `/onboarding` | Redesigned University Onboarding (6 steps) | 16 |
| `/plan` | Today — Home Dashboard (initial route after onboarding) | 15 + redesign |
| `/cwa` | Academic Target Planner | 1, 13 + redesign |
| `/timetable` | Class Timetable (single-layer, full-page scroll) | 2 + redesign |
| `/sessions` | Study Session Tracker + Analytics Dashboard | 4 + redesign |
| `/streak` | Streak System + Milestone Gallery | 5 + redesign |
| `/insights` | Insights System | 9 + redesign |
| `/ai/weekly-review` | AI-powered Weekly Review (full screen) | 15 |
| `/settings` | Settings (Academic, Timer Feedback, Notifications, Appearance, About, Dev) | 14 + redesign + 18 |
| `/course/:courseCode` | Course Hub Workspace (3-tab: Overview, Sessions, Notes) | 15.1 + redesign |
| `/timetable/import` | Timetable Image Import via AI proxy (full-screen, no bottom nav) | 15.2 + 20 |
| `/timetable/reminders` | Course Reminders (full-screen, no bottom nav) | 19 |
| `/cwa/manual-entry` | Manual Course Entry (full-screen, no bottom nav) | redesign |
| `/cwa/history` | Past Semesters History (full-screen, no bottom nav) | 15.6 |
| `/cwa/import/registration` | Registration Slip Import (full-screen, no bottom nav) | 15.6 |
| `/cwa/import/results` | Result Slip Import (full-screen, no bottom nav) | 15.6 |

Navigation uses a `ShellRoute` with a 4-destination floating pill-shaped bottom nav bar: Home, CWA, Table, Sessions. Tab switches use `context.go()`; drill-down screens (Streak, Insights, Settings, Course Hub, Weekly Review, etc.) use `context.push()` for proper back-button behaviour. The floating mini-timer is rendered inside `_AppShell` and persists across all tab switches. Shell tabs render at full height and use in-page trailing overlay clearance so content scrolls above the nav/timer stack cleanly. Full-screen routes intentionally do not show the bottom nav.

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
| Day summary card | Compact top card summarizes the selected day, class count, next/first class, and free-block count when available |
| Time grid | 6AM–8PM, hourly rows at 60px/hr (1.0 px/min); 30-min resolution |
| Add class slot | Bottom sheet with fast-select CWA course chips for instant autofill (course code, name, venue, type, time, color); time picker auto-promotes sub-6AM selections to PM; end time auto-advances if ≤ start |
| Timeline layout | `Daily timeline` is the main page content; the whole page scrolls naturally instead of trapping the timetable inside a small nested vertical scroll box |
| Slot card | Uses calmer card styling while still showing course code, name, venue, and (for taller slots) time/type without overflow |
| Slot overlap handling | Overlapping same-day class slots are split into equal side-by-side lanes via `_assignColumns` — no stacked/unreadable text |
| Slot detail sheet | Tap slot to open a polished detail sheet with edit, delete, and `Open Workspace` actions |
| Free time detector | `FreeTimeDetector` computes contiguous free blocks per day — pure Dart |
| Free block indicator | Displays lighter, less dominant free blocks in the grid when no class is scheduled |
| Slot types | Lecture / Practical / Tutorial |

**Isar schemas:** `TimetableSlotModel`

---

### ~~Phase 3 — Personal Timetable + Dual Layer View~~ *(Removed in v1.0)*

> This feature was cut for v1.0 to reduce complexity. The timetable is now a single-layer Class grid only. `PersonalSlotModel`, `personal_slot_provider`, `dual_layer_grid`, and all related widgets have been deleted.

---

### Phase 4 — Study Session Tracking

**Route:** `/sessions`

| Feature | Description |
|---|---|
| Course picker | Merged list of CWA courses + today's timetable slots |
| Mode toggle | Normal / Pomodoro segmented toggle on the start card; button label and icon update to match the selected mode |
| Start / stop timer — Normal | Open-ended count-up timer; stores `startTime` as `DateTime` anchor; elapsed = `DateTime.now().difference(startTime)` — survives Android app pauses |
| Pomodoro timer | Count-down per phase (25 min focus → 5 min short break → repeat × 4 → 15 min long break); `phaseEndsAt` `DateTime` anchor used for remaining time — same Android-reliable pattern as Normal mode |
| Pomodoro round tracking | `currentRound` (1-based), `totalRounds` (default 4), `isBreak`, `isComplete` flags held in `ActiveSessionState`; `advancePhase()` / `skipBreak()` on the notifier drive transitions |
| Phase auto-transition | `ActiveTimerCard` ticker detects `phaseRemaining == Duration.zero` exactly once per phase (guarded by `_lastFiredPhaseEnd`) and calls `onPhaseExpired` → notifier advances to the next phase |
| Pomodoro UI | Focus phase: primary blue card, accent countdown, round progress dots; Break phase: green card, white countdown, "Skip Break" button; Complete state: "Session Complete!" with rounds + minutes summary |
| Floating mini-timer — Pomodoro | Pill shows "R2 Focus · 18:42" (countdown) during focus; turns green with "R2 Break · 04:31" during break |
| Focus-only save | `elapsedMinutes` returns accumulated focus seconds ÷ 60 for Pomodoro sessions — break time is never counted |
| Global session state | `activeSessionProvider` lives above `ShellRoute`, survives tab switches |
| Session history | Chronological list of past sessions; Pomodoro sessions display a hourglass icon next to the duration |
| Analytics dashboard | Daily total, weekly bar chart, per-course breakdown — Pomodoro minutes feed in identically to Normal minutes |
| Planned vs actual | `PlannedActualAnalyser` compares session records against timetable slots — pure Dart |

**Isar schemas:** `StudySessionModel` (updated: nullable `sessionType` "normal"/"pomodoro", nullable `pomodoroRoundsCompleted`)

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

### ~~Phase 12 — AI Integration & Chat History~~ *(chat removed from current MVP)*

The DeepSeek client remains active for AI Weekly Review, AI Study Plan, and AI-generated streak notification text. The global chatbot layer was removed from the current MVP:

| Removed item | Current status |
|---|---|
| `/ai` route and global AI FAB | Removed from `app_router.dart` / `_AppShell` |
| AI Chat Interface | Removed (`AiChatScreen`, composer, bubbles, typing indicator, history drawer) |
| Chat History Tracker | Removed (`AiMessageModel`, `AiChatSessionModel`, `AiChatRepository`) |
| AI Usage Limits for chat | Removed (`AiUsageModel`, usage repository/provider, usage counter chip) |
| Markdown/math chat rendering | Removed (`flutter_markdown`, `flutter_math_fork`, `markdown`) |

### ~~Phase 13 — CWA AI Coach + What-If Explainer~~ *(removed from current MVP)*

The CWA AI Coach bottom sheet and What-If Explainer were removed to keep the MVP focused on reliable CWA tracking and import. CWA import AI remains active through OpenAI Vision in `RegistrationSlipParser` and `ResultSlipParser`.

**Isar schemas:** None.

---

### ~~Phase 14 — Exam Prep Generator~~ + Smart Notifications *(Exam Prep removed in v1.0)*

> The Exam Prep Generator screen (`/ai/exam-prep`), question-type widgets (MCQ, Short Answer, Flashcard), and `exam_prep_provider` were removed in v1.0. The smart notifications infrastructure below remains active.

| Feature | Description |
|---|---|
| Background notifications | Periodic background tasks via `Workmanager` checking streak status. |
| Personalized Alerts | DeepSeek-generated motivational messages for streak-at-risk notifications. |
| Notification Service | Centralized management of local notifications (immediate and scheduled). |
| Permission Guard | One-time custom dialog for notification permissions before enabling smart features. |

**Isar schemas:** No new schemas (updates `UserPrefsModel`).

---

### Phase 15 — Study Plan, Exam Mode & AI Weekly Review

**Routes:** `/plan` (initial route), `/ai/weekly-review`

#### Daily Study Plan

| Feature | Description |
|---|---|
| PlanGenerator | Pure Dart: scans today's timetable slots for free blocks (6AM–8PM, 30-min minimum), prioritises courses by days-since-last-session, produces a typed `PlanTask` list (attend / study) |
| AI plan generation | "Generate" button calls DeepSeek to produce a structured daily plan and persists tasks as `DailyPlanTaskModel` rows |
| Plan screen | Initial app route; user-facing **Today** home screen with in-body greeting, hero card, academic pulse, today-at-a-glance summary, progress, lower detail cards, and sectioned task lists with completion checkboxes |
| Progress bar | `PlanProgressBar` shows completed/total tasks with a celebration message when all done |
| Manual task add | Bottom sheet to add a custom task outside AI generation; entered from inline Home actions rather than a competing local FAB |
| Task types | `attend` (class), `study` (course work) |
| Overflow handling | Academic pulse tiles were tightened for small screens, and long task labels now wrap to 2 lines with ellipsis instead of overflowing |

#### ~~Exam Mode~~ *(Removed in v1.0)*

> `ExamModel`, `exam_mode_provider`, `exam_manager_sheet`, `exam_mode_activation_sheet`, and all exam mode UI were removed. `UserPrefsModel` exam fields and `UserPrefsRepository.updateExamModeSettings()` have also been deleted.

#### AI Weekly Review (full screen)

| Feature | Description |
|---|---|
| WeeklyReviewScreen | Full-screen route at `/ai/weekly-review`; shows AI-generated narrative summary of the week |
| WeeklyReviewModel | Isar collection: stores `weekStartDate`, `reviewText`, `generatedAt`, `weeklyNotes` |
| AI review generation | DeepSeek generates a paragraph-form weekly performance narrative injected with session stats, streak, and CWA context |
| Review sections | `ReviewSectionCard` widgets display structured review segments with animated entry |
| Free gate | `ReviewGateOverlay` blocks the AI narrative for free-tier users; stats summary remains visible |
| Chat follow-up | Removed; the old "Ask about this review" button depended on `/ai` |
| Study plan tab | `StudyPlanTab` in the Sessions screen shows the AI-generated plan |
| Plan free gate card | `PlanFreeGateCard` blocks AI plan generation for free users; manual task adding still available |

#### Settings Screen

| Feature | Description |
|---|---|
| Notification toggles | Per-category switches: study reminders, streak alerts, milestone alerts, weekly review prompt |
| Daily reminder time | Time picker for the daily study reminder; persisted to `UserPrefsModel` |
| Cancel all button | Cancels all scheduled local notifications |
| DEV premium toggle | Debug-mode only switch to flip premium status for testing; hidden in release builds |

**Isar schemas:** `DailyPlanTaskModel`, `StudyPlanModel`, `StudyPlanSlotModel`, `WeeklyReviewModel`

---

### Phase 15.1 — Course Hub Workspace

**Route:** `/course/:courseCode` (full-screen push, no bottom nav; entered from CWA course card → Open Workspace, timetable slot detail → Open Workspace, or sessions breakdown → course row tap)

| Feature | Description |
|---|---|
| Course Hub Screen | `DefaultTabController(length: 3)` wrapping a Scaffold with a scrollable `TabBar`; resolves the route `courseCode` parameter against `coursesProvider` before rendering |
| Overview tab | Course info card, expected score with `LinearProgressIndicator` + grade chip, CWA impact card (contribution points, current CWA, weight %), study stats (session count, total time, last studied), streak mini-card |
| Sessions tab | Course-scoped `WeeklyBarChart` using `PlannedActualAnalyser` with empty class/personal slots; reverse-chronological session list; swipe-to-delete |
| Notes tab | `StreamProvider`-backed note list; FAB opens `NoteEditorSheet` (create); tap opens edit mode; `Dismissible` swipe to delete |
| CourseHubContextBuilder | Pure Dart; builds a compact course context summary from `CourseModel`, filtered `StudySessionModel` list, `CourseNoteModel` list, and `StreakResult` for any future scoped surfaces |
| Entry points | CWA screen: "Open Workspace" as first item in course card `PopupMenuButton`; Timetable: "Open Workspace" `OutlinedButton` in slot detail sheet; Sessions: `InkWell` tap on each course row in `CourseBreakdownCard` |

**Isar schemas:** `CourseNoteModel`

---

### Phase 15.2 — OpenAI Vision Timetable Import

**Route:** `/timetable/import` (full-screen push, no bottom nav; entered via scanner icon in Timetable AppBar)

| Feature | Description |
|---|---|
| Image picker | `image_picker` package — student picks from device camera or gallery; `imageQuality: 85` to balance quality and payload size |
| Size guard | Rejects images over 4 MB before sending to the API — shows a user-friendly error with a retry prompt |
| TimetableVisionParser | Pure Dart; base64-encodes the image bytes and POSTs to the Vercel AI proxy (`/api/openai-vision`); no API key or model name needed client-side; strips markdown code fences from the response before JSON decoding; detects token-limit truncation (`finishReason: "length"`) and surfaces a user-friendly crop-and-retry message |
| TimetableSlotImport | Pure Dart value object; `fromJson` normalises day strings ("Monday", "Mon", "MON", int 0–5), parses 24-hour `HH:MM` time strings to minutes, defaults missing `slot_type` to "Lecture", skips malformed entries silently |
| Import state machine | `TimetableImportNotifier` (Riverpod `@riverpod` class notifier) drives 7 states: `idle → picking → parsing → reviewing → saving → done → error`; each state renders a different UI body automatically |
| Review screen | After parsing, shows all extracted slots in a checklist — student can toggle individual slots on/off, or select/deselect all; slot count chip updates live |
| Confirm & save | Selected slots are assigned cycling colors from `TimetableConstants.slotColorValues` and written to `TimetableRepository.addSlot()` using the active semester key from `activeSemesterProvider`. Timetable import does not modify CWA/GPA courses. Students can later choose `Use Timetable` from the current-semester course import options, select unique timetable courses, and enter required credit hours before saving them to CWA/GPA. |
| Auto-navigate | On `done`, resets provider state and `context.go('/timetable')` — no manual navigation needed |
| Error recovery | Every failure path (no internet, empty parse, oversized image, truncation) lands in `error` state with a descriptive message and a "Try Again" button that resets to `idle` |
| Entry point | Scanner icon (`Icons.document_scanner_outlined`) added to the Timetable screen AppBar alongside the existing "+" button |

**New files:** `domain/timetable_slot_import.dart`, `domain/timetable_vision_parser.dart`, `presentation/providers/timetable_import_provider.dart`, `presentation/screens/timetable_import_screen.dart`, `presentation/widgets/import_slot_review_tile.dart`

**Modified files:** `timetable_screen.dart` (scanner icon), `app_router.dart` (new route), `pubspec.yaml` (`image_picker` dependency). Note: the vision parser now uses the Vercel AI proxy instead of direct OpenAI API calls (see Phase 20).

**Isar schemas:** None (imports directly into existing `TimetableSlotModel`)

---

### Phase 15.3 — CWA Registration Slip Import + Cumulative CWA

**Routes:** No new GoRouter routes — all new screens pushed via `MaterialPageRoute` from the CWA screen.

#### Registration Slip Import

| Feature | Description |
|---|---|
| Entry point | Document scanner icon in CWA AppBar (visible in Semester view only) → opens `RegistrationSlipImportScreen` |
| 3 input options | Camera (take photo), Gallery (pick JPG/PNG), PDF (file picker) |
| AI extraction | `RegistrationSlipParser` base64-encodes the image/PDF page and calls the Vercel AI proxy with a course-extraction prompt; returns a list of `RegistrationCourseImport` value objects (courseCode, courseName, creditHours) |
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
| AI extraction | `ResultSlipParser` calls the Vercel AI proxy; extracts course code, course name, credit hours, grade, mark (if visible), plus slip-level `reportedSemesterCwa` and `reportedCumulativeCwa` if printed on the slip |
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

### Phase 15.4 — Launch Scope Reduction

| Feature | Description |
|---|---|
| Course Hub simplification | The launch build removes the Course Hub Files tab and per-course AI chat, leaving a focused 3-tab workspace: Overview, Sessions, Notes |
| File feature removal | `CourseFileModel`, file repository/provider wiring, PDF extraction helpers, and file UI components were deleted from the launch branch |
| Per-course AI removal | `hub_ai_provider.dart` and `hub_ai_tab.dart` were removed; focused AI remains only in import/review/planning flows |
| Isar cleanup | `CourseFileModelSchema` was removed from `isarProvider`, so the file feature is no longer part of the active local schema set |

**Launch cleanup commit:** `Remove workspace files and AI chat`

---

### Phase 15.5 — Pre-Launch Stability & Production Hardening

**No new features. No new routes. No new Isar collections.** All changes harden existing code against crashes, silent failures, and bad UI states before Play Store release.

#### Session 1 — Global Error Capture + API/AI Call Hardening

| Change | Description |
|---|---|
| `runZonedGuarded` in `main.dart` | Wraps the entire `runApp` call; all uncaught Dart errors are logged with `🔴 UNCAUGHT ERROR:` prefix |
| `FlutterError.onError` in `main.dart` | Captures Flutter framework errors (layout overflow, null widget, etc.) before they silently disappear |
| DeepSeek client timeout | `.timeout(Duration(seconds: 60))` on every `http.post()` in `deepseek_client.dart`; `TimeoutException`, `SocketException`, and generic `Exception` all map to typed `DeepSeekException` with human-readable messages |
| Vision parser timeouts | `timetable_vision_parser.dart` (90s), `registration_slip_parser.dart`, `result_slip_parser.dart` (15s) all use the Vercel proxy and return typed error results (not bare throws) |
| DeepSeek call site audit | All call sites confirmed to route `DeepSeekException` to provider error state — none swallow silently |

#### Session 2 — Offline Detection + Isar Write Safety + Provider Audit

| Change | Description |
|---|---|
| `connectivity_plus` dependency | Added `^6.0.3` to `pubspec.yaml` |
| `ConnectivityService` | New `core/services/connectivity_service.dart`; `isOnline()` static method checks connectivity on-demand |
| `isOnlineProvider` | New `core/providers/connectivity_provider.dart`; `FutureProvider<bool>` for Riverpod-integrated connectivity checks |
| `OfflineBanner` widget | New `shared/widgets/offline_banner.dart`; `AnimatedContainer` grey banner shown when offline — used in AI screens |
| Offline guard in AI providers | All 9 AI-calling providers check `ConnectivityService.isOnline()` before making any API call; offline → error state with user-friendly message instead of a hung spinner |
| Isar write safety | All 13 repository files audited; every `.put()`, `.putAll()`, `.delete()` call wrapped in try-catch with `debugPrint('🔴 Isar write failed: $e')` and re-throw so providers surface the error |
| Riverpod async provider audit | All `AsyncNotifier` and `FutureProvider` `build()` methods verified to have `AsyncValue.guard` or try-catch; no provider returns empty data on failure |

#### Session 3 — UI State Coverage + Navigation Safety

| Change | Description |
|---|---|
| `ErrorRetryWidget` | New `shared/widgets/error_retry_widget.dart`; reusable error card with icon, message, and "Try Again" `ElevatedButton`; used across all screens |
| Full state coverage | All 14 screens audited and updated to handle `loading`, `error`, and `data.isEmpty` states via `ref.watch(provider).when(...)` pattern — no screen can appear blank |
| `/course/:courseCode` null safety | `app_router.dart`: empty/null `courseCode` redirects to `/cwa` with snackbar; unresolved `CourseModel` shows a fallback `Scaffold` with back button instead of crashing |
| Snackbars for silent failures | All user-triggered writes (save, delete, swipe-to-dismiss) that previously swallowed exceptions now show `ScaffoldMessenger` snackbars with human-readable messages |

#### Session 4 — Timer Reliability + Launch Safety

| Change | Description |
|---|---|
| Timer reliability verified | `startTime` confirmed as `DateTime.now()` anchor; `elapsed` = `DateTime.now().difference(startTime)`; `phaseRemaining` already clamped to `Duration.zero`; `_lastFiredPhaseEnd` guard confirmed preventing double phase-fire; `advancePhase()` confirmed idempotent via state checks; app-kill mid-Pomodoro cleanly abandons session on relaunch (no phantom state) |
| Course Hub launch scope verified | Stability pass now assumes the launch Course Hub surface is Overview, Sessions, and Notes only; removed Files and hub AI surfaces are no longer part of the active manual test scope |
| Timetable import error message | Updated empty-parse message to `"No timetable slots could be detected. Try a clearer image."` (aligns with guide spec) |
| Slip import guards confirmed | Both `registration_slip_import_provider.dart` and `result_slip_import_provider.dart` already route empty parse to error state — confirmed no change needed |

**New files (Phase 15.5):** `core/services/connectivity_service.dart`, `core/providers/connectivity_provider.dart`, `shared/widgets/offline_banner.dart`, `shared/widgets/error_retry_widget.dart`

**Modified files (Phase 15.5):** `main.dart`, `app_router.dart`, all 9 AI provider files (offline guard), all 13 repository files (Isar write safety), all 14 screen files (state coverage), `deepseek_client.dart`, `timetable_vision_parser.dart`, `registration_slip_parser.dart`, `result_slip_parser.dart`, `timetable_import_provider.dart`

---

### Phase 15.6 — CWA Flow Gap Fixes

**No new Isar collections. No new routes beyond gap remediation.** All changes address real CWA feature gaps discovered during flow-through testing. Twelve gaps were identified, documented in `_dev/CWA_FLOW_GAPS.md`, and systematically fixed.

#### Gap 1 — Active semester is no longer hardcoded

`activeSemesterProvider` previously returned the hardcoded string `"2024-Sem2"`. The current semester is now persisted in `UserPrefsModel.activeSemesterKey` and surfaced through an `ActiveSemesterPicker` widget accessible from the CWA screen. Changing the active semester instantly rescopes the course list, timetable, and semester-mode CWA display.

**New files:** `presentation/widgets/active_semester_picker.dart`

**Modified files:** `cwa_provider.dart` (reads `userPrefs.activeSemesterKey`), `cwa_screen.dart` (picker UI in AppBar), `user_prefs_model.dart` (new `activeSemesterKey` field), `user_prefs_repository.dart` (persist/read)

#### Gap 2 — Target CWA persisted across launches

`targetCwaProvider` previously defaulted to `70.0` in memory only. It now reads from and writes to `UserPrefsModel.targetCwa`. The user's target survives app restarts.

**Modified files:** `cwa_provider.dart` (reads/writes `userPrefs.targetCwa`), `user_prefs_model.dart` (new `targetCwa` field)

#### Gap 3 — Complete Semester flow

A new `CompleteSemesterScreen` bridges the gap between projected courses and real results. When a semester ends, the student taps "Complete Semester" from the CWA screen. All current `CourseModel` entries are pre-filled into a grade-entry form — course codes, names, and credit hours carry forward automatically. The student enters real grades (dropdown: A–F) and optional exact marks. On save, a `PastSemesterModel` is created, the old course entries are deleted, and `activeSemesterKey` advances to the next semester. A confirmation dialog with a semester-picker guards the irreversible clear action.

**New files:** `presentation/screens/complete_semester_screen.dart` (~870 lines)

**Modified files:** `cwa_screen.dart` (Complete Semester action), `cwa_provider.dart` (clearAndAdvance logic), `past_result_repository.dart` (save from completion flow)

#### Gap 4 — Consistent semester identification

`PastSemesterModel` gained a `semesterKey` field (e.g. `"2024-Sem2"`) that matches `CourseModel.semesterKey`. This enables cross-referencing between active and past semesters — the cumulative view can now identify when a past record corresponds to the current working semester, preventing double-counting.

**Modified files:** `past_semester_model.dart` (new `semesterKey` field), `result_slip_import_provider.dart` (auto-sets `semesterKey`), `past_result_repository.dart` (duplicate detection by key)

#### Gap 5 — Grade-first entry in cumulative mode

Manual entry in cumulative mode now presents a **grade dropdown** (A–F, colour-coded) as the primary field. The exact mark/score is an optional secondary field. This matches the real-world scenario: students know their letter grade from a result slip, not necessarily the exact percentage.

**Modified files:** `cwa_manual_entry_screen.dart` (grade dropdown + optional mark in cumulative mode)

#### Gap 6 — Duplicate semester detection

The cumulative result-slip import flow now checks for an existing `PastSemesterModel` with the same `semesterKey`. If found, the user is prompted to replace the existing record or cancel — they cannot silently create a duplicate that would double-count courses in the cumulative CWA.

**Modified files:** `past_result_repository.dart` (semesterKey dedup check), `result_slip_import_provider.dart` (replace-or-cancel UI)

#### Gap 7 — Draft saving for manual entry

The manual entry screen now auto-saves form state as JSON to `UserPrefsModel.manualCwaDraftJson` whenever the user makes a change. On next open, the draft is automatically restored. The draft is cleared on successful save. The stub "Draft saving is coming in a later phase" placeholder is removed.

**Modified files:** `cwa_manual_entry_screen.dart` (auto-save/restore draft), `user_prefs_model.dart` (new `manualCwaDraftJson` field), `user_prefs_repository.dart` (draft helpers)

#### Gap 8 — Import screens registered as GoRouter routes

`PastSemestersScreen`, `RegistrationSlipImportScreen`, and `ResultSlipImportScreen` were previously pushed via raw `Navigator.push(MaterialPageRoute(...))`. They are now registered as named GoRouter routes — `/cwa/history`, `/cwa/import/registration`, and `/cwa/import/results` — and navigated with `context.pushNamed()`. This enables deep linking and consistent back-button behaviour.

**Modified files:** `app_router.dart` (3 new named routes), `cwa_screen.dart` (uses `context.pushNamed()`), `past_semesters_screen.dart` (removed raw Navigator references)

#### Gap 9 — Editable expected scores on import review

The registration slip import review screen now exposes an **expected score slider** on each course row before saving. Imported courses no longer all default to 70 — the student can set each course's expected score during review. The hardcoded `70.0` at save time is replaced with the reviewed value.

**Modified files:** `registration_slip_import_provider.dart` (editable expected scores), `registration_slip_import_screen.dart` (score slider in review)

#### Gap 10 — Credit hour cap raised from 6 to 12

The universal credit-hour clamp of 1–6 was raised to 1–12 across all entry points: `AddCourseSheet`, `CwaManualEntryScreen`, `PastSemestersScreen` inline editing, and both import review screens. This accommodates project work, industrial attachment, and other high-credit courses.

**Modified files:** `add_course_sheet.dart`, `cwa_manual_entry_screen.dart`, `past_semesters_screen.dart`, `registration_slip_import_screen.dart`, `result_slip_import_screen.dart`

#### Gap 11 — Visible parse-failure warnings

Malformed entries from AI vision parsing are no longer silently dropped. Both `RegistrationSlipParser` and `ResultSlipParser` now count skipped rows. The import review screen shows a warning chip — "N courses could not be parsed" — and offers an "Add Manually" button so the student can enter missing courses before saving.

**Modified files:** `registration_slip_parser.dart` (counts skipped rows), `result_slip_parser.dart` (counts skipped rows), `registration_slip_import_screen.dart` (warning chip + add-manually), `result_slip_import_screen.dart` (warning chip + add-manually)

#### Gap 12 — Semester progression card in cumulative view

The cumulative CWA view now includes a semester progression card. It lists all past semesters in chronological order with: semester CWA, cumulative CWA after that semester, and a delta indicator (↑/↓) showing change from the previous semester. This gives students a clear academic trend line without adding a chart dependency.

**Modified files:** `cwa_screen.dart` (progression card in cumulative mode), `cwa_summary_bar.dart` (extended cumulative display)

#### Additional CWA improvements

| Change | Description |
|---|---|
| Result slip labelling auto-populated | The label step in result slip import now pre-fills the semester name from AI-parsed metadata (`reportedSemesterCwa` / `reportedCumulativeCwa` from the slip image), reducing manual typing |
| "Update Results" UX improved | The `PastSemestersScreen` inline editing is now more responsive — grade/mark changes show an immediate CWA recalc badge without needing to leave the card |
| Hardcoded programme list fixed | Programme pickers now load from a data list rather than a hardcoded inline set; new programmes can be added by updating one source |

**New files (Phase 15.6):** `presentation/screens/complete_semester_screen.dart`, `presentation/widgets/active_semester_picker.dart`

**Modified files (Phase 15.6):** `cwa_provider.dart`, `cwa_screen.dart`, `cwa_summary_bar.dart`, `cwa_manual_entry_screen.dart`, `past_semesters_screen.dart`, `registration_slip_import_screen.dart`, `result_slip_import_screen.dart`, `registration_slip_import_provider.dart`, `result_slip_import_provider.dart`, `registration_slip_parser.dart`, `result_slip_parser.dart`, `add_course_sheet.dart`, `app_router.dart`, `user_prefs_model.dart`, `user_prefs_repository.dart`, `past_semester_model.dart`, `past_result_repository.dart`

---

### Phase 15.7 — Dead Feature Removal & Code Cleanup

**Three feature areas removed** to reduce binary size, eliminate unused code paths, and simplify the pre-release audit surface.

#### What-If AI feature removed

The What-If explainer (Phase 13) was a bottom-sheet AI feature that explained how adjusting a single course score would affect the student's CWA. It was rarely discoverable, added complexity to the course card UI (explain chip that appeared on slider drag), and carried its own AI usage quota key (`whatif`). All related files deleted:

| File | Lines |
|---|---|
| `presentation/providers/whatif_provider.dart` | 141 |
| `presentation/widgets/whatif_explain_chip.dart` | 64 |
| `presentation/widgets/whatif_result_card.dart` | 59 |

The `whatif` quota key was removed during the first cleanup pass. In the later focused AI MVP pass, `AiUsageModel` itself was removed with the global chatbot and CWA Coach. The "Explain" chip on course cards was removed — dragging the score slider now simply shows the live CWA recalculation without an AI call.

#### LaTeX sanitizer removed

`latex_sanitizer.dart` (307 lines) was a utility that stripped LaTeX markup from AI responses before display in non-math surfaces. It is no longer needed in the current MVP because the global chatbot, CWA Coach, and chatbot-only markdown/math rendering pipeline were removed.

#### Course Hub context builder removed

`course_hub_context_builder.dart` (59 lines) was a pure Dart context summary builder for course-scoped AI. With the per-course AI chat tab removed in Phase 15.4, this utility was orphaned — nothing called it.

#### AI usage model cleanup

`AiUsageModel` was removed from the current MVP with the global chatbot, CWA Coach, chat quota repository/provider, and usage counter chip.

**Deleted files (Phase 15.7):**
- `lib/features/cwa/presentation/providers/whatif_provider.dart`
- `lib/features/cwa/presentation/widgets/whatif_explain_chip.dart`
- `lib/features/cwa/presentation/widgets/whatif_result_card.dart`
- `lib/features/ai/domain/latex_sanitizer.dart`
- `lib/features/course_hub/domain/course_hub_context_builder.dart`

**Modified files (Phase 15.7):** `course_card.dart` (removed explain chip), `context_builder.dart` (removed whatif references). Historical note: `ai_usage_model.dart` existed during the first cleanup pass but was later deleted in the focused AI MVP pass.

---

### Phase 15.8 — Pre-Release Audit & Production Polish

**28 audit items fixed.** No new features. All changes harden existing code against data loss, silent failures, and poor UX states.

#### Architecture improvements

| Change | Description |
|---|---|
| `isar_database.dart` extracted | Centralised Isar schema list (`kCampusIqIsarSchemas`) and `openCampusIqIsar()` function extracted from `isar_provider.dart` into a dedicated file. Makes schema registration explicit and auditable in one place. |
| Offline banner in shell | `OfflineBanner` moved from per-screen usage into `_AppShell` — a single `Positioned` banner at the top of every shell tab when offline. No per-screen wiring needed. Uses `isOnlineProvider` reactively. |
| Shell watches connectivity | `_AppShell` now watches `isOnlineProvider` and adjusts layout (banner offset, nav inset) when connectivity changes. |

#### Data-loss guards

| Change | Description |
|---|---|
| Complete Semester confirmation | The "Complete Semester" action shows a confirmation dialog with the target semester displayed. The course deletion + past-semester creation is wrapped in a single Isar `writeTxn` — either both succeed or neither does. |
| Draft auto-save | Manual entry form state is persisted to `UserPrefsModel.manualCwaDraftJson` on every change. If the app is killed mid-entry, the draft is restored on next open. |
| Duplicate semester guard | Importing a result slip for a semester that already exists prompts replace-or-cancel. Double-saving is impossible. |
| Delete confirmations hardened | All destructive actions (delete course, delete session, delete note, delete timetable slot, delete past semester) show confirmation dialogs with clear consequences. No silent deletes. |

#### Error state coverage

| Change | Description |
|---|---|
| ~~AI chat error recovery~~ | Removed from current MVP with `AiChatProvider` and `/ai` |
| Import flow error messages | All 3 import state machines (timetable, registration slip, result slip) show specific, human-readable error messages for each failure mode: no internet, oversized image, empty parse, API timeout, truncation. |
| Isar open failure | `openCampusIqIsar()` catches Isar open failures with a logged stack trace and re-throws — the app shows a meaningful error instead of a null-dereference crash. |

#### Dead code & polish

| Change | Description |
|---|---|
| Unused imports removed | Across ~15 files |
| Stale route references cleaned | `/today` alias removed from `_locationToIndex` |
| Plan generator hardened | Malformed study plan time values caught with safe fallbacks instead of crashing the Home screen |
| Streak calculator edge case | Fixed off-by-one in streak calculator for sessions logged exactly at midnight |
| Session screen pause/resume | Session screen polished with improved layout and pause support refinements |
| Timetable slot card | Refined card styling for better readability at small sizes |
| Day selector polish | Day selector pills refined for consistent tap targets |
| Course card polish | Compact course cards with improved score slider and grade chip layout |
| Milestone grid | Fixed milestone grid layout for small screens |

**New files (Phase 15.8):** `lib/core/data/isar_database.dart`

**Modified files (Phase 15.8):** `isar_provider.dart`, `app_router.dart`, `plan_generator.dart`, `plan_screen.dart`, `session_screen.dart`, `timetable_screen.dart`, `timetable_slot_card.dart`, `day_selector.dart`, `course_card.dart`, `milestone_grid.dart`, `streak_calculator.dart`, `weekly_review_screen.dart`, `add_manual_task_sheet.dart`, `add_slot_sheet.dart`, `class_timetable_grid.dart`, `free_block_indicator.dart`, `settings_screen.dart`, plus ~10 more files (unused-import cleanup). The earlier `ai_chat_provider.dart` / `ai_chat_screen.dart` changes are historical only; those files were later removed from the current MVP.

---

### Phase 15.9 — Focused AI MVP Scope Cleanup

The MVP AI surface was reduced to features with a narrow, reviewable job. CWA import AI, AI Weekly Review, and AI Study Plan remain; the broad assistant/chat layer was removed.

| Removed | Result |
|---|---|
| Global AI Assistant FAB | `_AppShell` no longer shows a gold AI button above the bottom nav |
| `/ai` route | General chatbot screen is no longer reachable |
| Chat UI | Deleted `AiChatScreen`, history drawer, message bubble, typing indicator, usage counter, and weekly review banner |
| Chat state/storage | Deleted `AiChatProvider`, `AiUsageProvider`, chat/usage repositories, `AiMessageModel`, `AiChatSessionModel`, and `AiUsageModel` |
| CWA Coach | Deleted the text-advice bottom sheet and its follow-up-to-chat path |
| Chat rendering dependencies | Removed `flutter_markdown`, `flutter_math_fork`, and `markdown` from runtime dependencies |
| Weekly Review follow-up | Removed the premium "Ask about this review" button because it depended on `/ai` |

**Kept:** `DeepSeekClient`, `ContextBuilder`, `WeeklyReviewModel`, `StudyPlanModel`, `StudyPlanSlotModel`, OpenAI Vision CWA import parsers, AI Weekly Review, AI Study Plan, and AI-generated streak notification text.

**Verification:** `flutter analyze --no-fatal-infos --no-fatal-warnings` passes with existing warnings/infos only. Full `flutter test` still has two unrelated UI regression failures around the CWA import sheet rendering and mini timer expectation.

---

### Phase 16 — University Onboarding Flow

**Route:** `/onboarding` (GoRouter redirect guard, shown before shell routes when `hasCompletedOnboarding == false`)

A redesigned 6-step onboarding flow that personalizes the app and teaches the student's first useful actions before they reach the main app. The tone is calm senior student + premium academic coach, with clean in-app UI previews instead of illustrations or real photos.

| Step | Screen | Description |
|---|---|---|
| Welcome | `OnboardingWelcomeScreen` | Clean dashboard preview, UniMate positioning, "Get Started" button, and skip option |
| University | `OnboardingUniversityScreen` | Searchable list of 20+ Ghanaian universities with logos; selecting a university auto-selects its default grading system; programme is optional on the same step |
| Target | `OnboardingTargetScreen` | Slider to set personal target score; default comes from the selected grading system; grading-system summary can be tapped to override the default |
| Grades Import | `OnboardingGradesImportScreen` | Clean CWA/GPA planner preview that sells registration-slip import, projected performance, and target planning |
| Timetable Import | `OnboardingTimetableImportScreen` | Clean timetable preview that sells timetable image import, daily classes, free blocks, and reminders; compacted to avoid small-screen overflow |
| Notifications + Start | `OnboardingNotificationsScreen` | Toggles for study reminders, streak alerts, milestone alerts, and weekly review prompt; optional setup shortcut cards for registration-slip import or timetable import |

**State management:** `OnboardingNotifier` (`StateNotifierProvider`) holds `OnboardingState` with fields for university, optional programme, gradingSystemId, target, optional `OnboardingStartAction`, and notification prefs. On completion, all values are persisted to `UserPrefsModel` and `hasCompletedOnboarding` is set to `true`.

**Navigation guard:** `app_router.dart` redirect guard checks `hasCompletedOnboardingProvider` — if `false`, any non-`/onboarding` route redirects to `/onboarding`. Once completed, `/onboarding` redirects to `/plan`.

**Final setup shortcuts:** The final cards are optional and deselectable. With no card selected, the finish button goes to Today. With a card selected, onboarding completes, the router goes to Today first, then pushes `/cwa/import/registration` or `/timetable/import` so Android Back returns to Today rather than closing the app.

**Skip:** Skip button on welcome screen calls `skip()` — sets `hasCompletedOnboarding = true` with default values.

**New files:** `lib/features/onboarding/presentation/providers/onboarding_provider.dart`, `onboarding_screen.dart`, `onboarding_progress_dots.dart`, `onboarding_welcome_screen.dart`, `onboarding_university_screen.dart`, `onboarding_target_screen.dart`, `onboarding_grades_import_screen.dart`, `onboarding_timetable_import_screen.dart`, `onboarding_notifications_screen.dart`

**Modified files:** `app_router.dart` (redirect guard + `/onboarding` route), `app.dart` (themeMode), `user_prefs_model.dart` (new fields)

---

### Phase 17 — Multi-Grading-System Support

**No new routes. No new Isar collections.** Configurable grading systems that let students from any Ghanaian university use their institution's actual grading scale.

| Feature | Description |
|---|---|
| `GradingSystem` | Pure Dart domain class in `lib/core/domain/grading_system.dart`; defines id, label, score range, target range, default target, slider divisions, display decimals, score unit, and optional letter grade scale |
| `GradeScale` / `GradeScaleEntry` | Pure Dart in `lib/core/domain/grade_scale.dart`; maps score ranges to letter grades with points and interpretation labels |
| `University` | Pure Dart in `lib/core/domain/university_defaults.dart`; maps each university to its default grading system and provides logo asset path; 20+ Ghanaian universities included |
| Systems available | **CWA** (0–100, KNUST/UMaT), **GPA 4.0** (0.0–4.0, Legon/UCC/UEW/UDS/UENR/Ashesi/Central/Valley View/Pentecost/All Nations/Academic City), **GPA 4.0 GIMPA** (A+/A/B+/B/C+/C/D+/D/F scale), **CGPA 5.0** (0.0–5.0, UPSA/UniMAC/CKT-UTAS/SD Dombo/GIJ/GIL) |
| UI adaptation | Bottom nav CWA tab label shows the active grading system's `label` (e.g. "GPA" instead of "CWA"); CWA screen title uses `plannerTitle`; target dialog score range matches grading system |
| Grade dropdowns | Complete Semester and Manual Entry (cumulative mode) show grade dropdowns specific to the active grading system's `GradeScale` — colour-coded (A=green, F=red) |
| Settings picker | Grading system can be changed from Settings → Academic → Grading system; shows all 4 systems with their target defaults |
| Persistence | Active grading system ID stored in `UserPrefsModel.gradingSystemId` |

**New files:** `lib/core/domain/grading_system.dart`, `lib/core/domain/grade_scale.dart`, `lib/core/domain/university_defaults.dart`

**Modified files:** `app_router.dart` (dynamic nav label), `cwa_screen.dart` (grading-aware labels), `cwa_manual_entry_screen.dart` (grading-aware grade dropdowns), `complete_semester_screen.dart` (grading-aware grade dropdowns), `settings_screen.dart` (grading system picker), `cwa_summary_bar.dart`, `user_prefs_model.dart` (new fields: `gradingSystemId`, `universityName`, `programmeName`, `themeModeIndex`, `vibrateOnTimerEnd`, `playSoundOnTimerEnd`, `hasCompletedOnboarding`)

**University logo assets:** `assets/images/universities/` — 20+ PNG files

---

### Phase 18 — Dark Mode, Timer Feedback, About & Settings Polish

**No new routes. No new Isar collections.** Complete dark theme, timer haptic/audio feedback toggles, and a restructured Settings screen.

#### Dark Mode

| Feature | Description |
|---|---|
| Dark theme | Full `ThemeData dark` in `app_theme.dart` with dark palette: surface (#1E2030), background (#15171E), primary (#7B9AD4), gold (#D4B55C), muted gold soft (#3D3520) |
| Theme picker | Settings → Appearance → Theme: System / Light / Dark; persisted via `UserPrefsModel.themeModeIndex` |
| Reactive switching | `themeModeProvider` (`FutureProvider<ThemeMode>`) reads `themeModeIndex`; `MaterialApp.router` uses `themeMode` |
| Shell nav dark | Bottom nav bar uses semi-transparent dark surface with adjusted shadow opacity for dark mode |
| All screens | Every screen adapts to dark mode — cards, sheets, dialogs, input fields, dividers all use `colorScheme` values |

#### Timer Feedback Toggles

| Feature | Description |
|---|---|
| Vibrate on phase end | When enabled, phone vibrates when a Pomodoro focus or break phase finishes |
| Sound on phase end | When enabled, a notification sound plays when a timer phase finishes |
| Persistence | Both toggles stored in `UserPrefsModel.vibrateOnTimerEnd` and `playSoundOnTimerEnd` |

#### Settings Restructure

The Settings screen (`/settings`) was reorganised into 6 clear sections:

| Section | Contents |
|---|---|
| Academic | Active semester picker, Grading system picker |
| Timer Feedback | Vibrate on phase end, Sound on phase end toggles |
| Notifications | Study reminders, Streak alerts, Milestone alerts, Weekly review prompt toggles; Daily study reminder time picker; Cancel all notifications button |
| Appearance | Theme picker (System / Light / Dark) |
| About | About UniMate dialog (app info, version), Privacy policy link, Terms of service link, Send feedback (email) |
| Dev | Reset onboarding (restart first-run experience) |

**Modified files:** `app_theme.dart` (dark theme), `app.dart` (themeMode wiring), `settings_screen.dart` (full restructure), `settings_provider.dart` (themeModeProvider), `user_prefs_model.dart` (new fields), `notification_service.dart` (pomodoro phase-end channel)

---

### Phase 19 — Course Reminders

**Route:** `/timetable/reminders` (full-screen push, no bottom nav)

Per-course notification reminders that alert students before their scheduled classes.

| Feature | Description |
|---|---|
| `CourseReminderModel` | New Isar `@collection`; stores `courseCode`, `courseName`, `dayIndex`, `timeMinutes` (start time in minutes from midnight), `reminderOffsetMinutes` (how many minutes before class to alert), `isEnabled` |
| `CourseRemindersScreen` | Full-screen route at `/timetable/reminders`; lists all reminders grouped by day; tap to edit, swipe to delete |
| Add/edit sheet | Bottom sheet with course picker (from timetable slots), time display, and offset selector (10, 15, 30, 60, or 120 minutes before) |
| Notification scheduling | `NotificationService` schedules course reminder notifications under notification IDs 700–999; reminders auto-reschedule on app launch via `refreshCourseReminderNotifications()` |
| Entry point | Reminders icon in Timetable AppBar alongside the scanner and + icons |

**New files:** `lib/features/timetable/data/models/course_reminder_model.dart`, `lib/features/timetable/presentation/providers/course_reminder_provider.dart`, `lib/features/timetable/presentation/screens/course_reminders_screen.dart`

**Modified files:** `isar_database.dart` (registers `CourseReminderModelSchema`), `app_router.dart` (`/timetable/reminders` route), `notification_service.dart` (course reminder scheduling), `timetable_screen.dart` (reminders icon), `app.dart` (refresh on launch)

---

---

### Phase 20 — AI Proxy Architecture (Keyless Client)

**No new routes. No new Isar collections.** All AI requests are routed through a Vercel-hosted serverless proxy at `https://campusiq-api.vercel.app`. No API keys, model names, or auth headers exist in the client app.

| Feature | Description |
|---|---|
| `AiProxyConfig` | Centralised static config in `lib/core/config/ai_proxy_config.dart`; exposes `deepseekEndpoint` (`/api/deepseek`) for text AI and `openaiVisionEndpoint` (`/api/openai-vision`) for image/PDF AI |
| `DeepSeekClient` | Simplified to `const DeepSeekClient()` with zero constructor parameters; calls the proxy instead of directly hitting DeepSeek API; parses the flattened `data['reply']` response format; timeout raised to 60s |
| `TimetableVisionParser` | POSTs base64 image to proxy endpoint instead of directly to OpenAI; sends `prompt`, `base64Image`, `maxTokens`, `temperature` in a simplified JSON body; parses `data['reply']` |
| `RegistrationSlipParser` | Same proxy pattern for registration slip images/PDFs |
| `ResultSlipParser` | Same proxy pattern for result slip images/PDFs |
| `flutter_dotenv` removed | Package and `.env` asset bundle removed from `pubspec.yaml`; no API keys remain in the client app |
| Internet permissions | `INTERNET` and `ACCESS_NETWORK_STATE` permissions added to `AndroidManifest.xml` for release builds (debug builds receive these automatically) |
| Security model | API keys live only on Vercel server-side environment variables; the proxy can enforce rate limiting and change models without an app update; extracting the APK reveals no secrets |

**New files:** `lib/core/config/ai_proxy_config.dart`

**Modified files:** `deepseek_client.dart` (parameterless constructor, proxy endpoint, 60s timeout, simplified response parsing), `timetable_vision_parser.dart` (proxy endpoint, simplified request/response), `registration_slip_parser.dart` (proxy endpoint), `result_slip_parser.dart` (proxy endpoint), `ai_providers.dart` (removed dotenv dependency), `pubspec.yaml` (removed `flutter_dotenv`, removed `.env` from assets), `AndroidManifest.xml` (added INTERNET + ACCESS_NETWORK_STATE permissions)

**Deleted files:** None (`.env` remains on disk but is no longer bundled or referenced)

### Production Polish (Ongoing)

| Change | Description |
|---|---|
| App name | Changed from "CampusIQ" to "UniMate" in `AppConstants.appName` |
| App icon | Updated launcher icon with new foreground assets (Android adaptive icon + iOS + macOS) |
| Note editor fix | Prevented keyboard overflow in note editor sheet |
| Dark mode readability | Improved contrast and readability across all screens in dark mode |
| Offline snackbar | Added offline snackbar notification when connectivity is lost |
| Old dev docs cleanup | Removed 10+ obsolete phase planning documents from `_dev/` |
| UI polish | Refined CWA, session, insights, and review sheet layouts across light and dark modes |

---

## Isar Collections (full list)

| Collection | Feature | Phase | Purpose |
|---|---|---|---|
| `CourseModel` | CWA | 1 | Courses with credit hours + expected scores |
| `TimetableSlotModel` | Timetable | 2 | Official class slots |
| ~~`PersonalSlotModel`~~ | ~~Timetable~~ | ~~3~~ | **Removed in v1.0** |
| `StudySessionModel` | Sessions | 4 | Completed study session records |
| `UserPrefsModel` | Core / Streak | 5 | Single-row key/value persistent flags (attended days, notification prefs, reflection notes, daily goal). 15.6: +activeSemesterKey, +targetCwa, +manualCwaDraftJson |
| ~~`AiMessageModel`~~ | ~~AI Chat~~ | ~~12~~ | **Removed from current MVP** |
| ~~`AiChatSessionModel`~~ | ~~AI Chat~~ | ~~12~~ | **Removed from current MVP** |
| ~~`AiUsageModel`~~ | ~~AI Limits~~ | ~~12~~ | **Removed from current MVP** |
| `SubscriptionModel` | Payments | 12 | Tracks premium status and subscription details |
| `StudyPlanModel` | AI Planner | 15 | Container for AI-generated study plans |
| `StudyPlanSlotModel` | AI Planner | 15 | Individual tasks/slots within a study plan |
| `WeeklyReviewModel` | AI Weekly Review | 15 | Stores AI-generated weekly review text and metadata |
| `DailyPlanTaskModel` | Daily Plan | 15 | Daily tasks and checklist items with completion state |
| ~~`ExamModel`~~ | ~~Exam Mode~~ | ~~15~~ | **Removed in v1.0** |
| `CourseNoteModel` | Course Hub | 15.1 | Per-course markdown notes |
| `PastSemesterModel` | CWA | 15.3 | Past semester results; 15.6: +semesterKey for dedup and cross-ref with CourseModel |
| `CourseReminderModel` | Timetable | 19 | Per-course class reminder notifications with configurable offset |

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
| http | ^1.2.0 | HTTP client (AI proxy, no direct API calls) |
| flutter_local_notifications | ^21.0.0 | Local push notifications |
| flutter_timezone | ^5.0.2 | Device timezone detection |
| timezone | ^0.11.0 | Timezone data for scheduling |
| workmanager | ^0.9.0 | Background task execution |
| open_filex | ^4.4.1 | Open attached files with the device's default app handler |
| image_picker | ^1.1.2 | Camera and gallery image picker for timetable image import (Phase 15.2) |
| connectivity_plus | ^6.0.3 | On-demand network connectivity check for offline guards before AI/API calls (Phase 15.5) |
| url_launcher | ^6.2.5 | Open privacy policy, terms of service, and mailto links from Settings (Phase 18) |

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
Horizontal swipe on the timetable screen navigates between days (Mon → Tue → … → Sun) via a `GestureDetector` with a 300 velocity threshold. The current launch build is single-layer only, so the page now focuses on one compact day summary plus a full-page `Daily timeline` instead of any class/personal layer switching UI.

### 12. Slot overlap detection with greedy column assignment
Overlapping timetable slots are rendered side-by-side using a greedy column-assignment algorithm in `ClassTimetableGrid._assignColumns`. Slots are sorted by start time; each is assigned to the first column whose last occupant has already ended. A second pass finds the highest column index used by any overlapping slot, giving each slot its `totalColumns` count so overlapping class cards remain readable.

### 8. Workmanager init without auto permission request
`callbackDispatcher` is a top-level function registered with Workmanager for background streak checks. The `NotificationService.init()` call was removed from the Workmanager dispatcher's first-run hook to prevent the OS permission dialog firing before the app's custom permission dialog, which rendered the Allow button non-functional. Permission is now only requested from within the app UI flow.

### 9. ~~Separate quotas per AI feature type~~ *(removed from current MVP)*
`AiUsageModel` and chat/CWA Coach quota tracking were removed with the global chatbot and CWA Coach. The remaining focused AI features are not using the old local chat quota table.

### 10. PlanGenerator free-block scheduling
`PlanGenerator` does not just suggest sessions per course — it first computes free gaps between class slots in the 6AM–8PM grid (minimum 30-min block), then fills those gaps with study tasks ordered by days-since-last-session. This ensures generated plans are timetable-aware and never overlap with classes.

### 11. ~~Exam mode as UserPrefsModel flag~~ *(Removed in v1.0)*

> `ExamModel` and all exam mode fields on `UserPrefsModel` have been deleted. The `UserPrefsModel` now stores only notification preferences, weekly reflection notes, and attendance data.

---

## Build Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after ANY model change
flutter analyze
flutter run
```

No `.env` file or API keys are needed — all AI requests route through the Vercel proxy.
Generated `*.g.dart` files are intentionally excluded from analyzer checks; regenerate them through build_runner rather than editing them manually.

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
| Post-MVP timetable UI | `refactor: refine timetable screen layout` |
| Post-MVP shell spacing | `refactor: unify shell nav overlay spacing` |
| Phase 15.3 S3 | `cumulative cwa updated` / `cumulative cwa patched` |
| AI rendering fix S1 | `feat: add markdown + LaTeX math rendering to AI chat bubble` |
| AI rendering fix S2 | `fix: use MarkdownStyleSheet.fromTheme to prevent null-check crash on list render` |
| AI rendering fix S3 | `fix: split display-math builder from inline-math builder to prevent _inlines crash` |
| AI rendering fix S4 | `fix: eliminate display-math crash in AI chat bubble` (pre-split $$...$$ before MarkdownBody; remove debug ErrorWidget.builder) |
| Phase 15.4 S1 | `feat(phase-15.4): session 1 — PDF text extraction pipeline` |
| Phase 15.4 S2 | `feat(phase-15.4): session 2 — source-grounded AI mode in course hub` |
| Launch cleanup | `Remove workspace files and AI chat` |
| Pomodoro | `feat(phase-15.4): PDF text extraction pipeline + source-grounded AI mode` → `feat(sessions): Pomodoro study mode — countdown timer, round tracking, focus-only save` |
| Phase 15.5 S1 | `fix(15.5-S1): global error capture + API/AI call hardening` |
| Phase 15.5 S2 | `fix(15.5-S2): offline detection, Isar write safety, provider error state coverage` |
| Phase 15.5 S3 | `fix(15.5-S3): full loading/empty/error UI coverage + route safety` |
| v1.0 refactor | `refactor: remove Personal Timetable, Exam Mode, and Exam Prep for v1.0` |
| UI redesign v1 | `ui redesign v1 done` |
| Home tab | `home screen added to navbar` |
| Nav fix | `fix: use push() for detail screen navigation so back button returns to previous screen` |
| Home/CWA simplify | `Simplify home and CWA screens` |
| Home/CWA compact | `refactor: compact home page hero and pulse cards` / `refactor: compact cwa screen cards and spacing` |
| Sessions compact | `refactor: compact sessions progress card` |
| Today refine | `Refine Today dashboard layout` |
| CWA card polish | `Polish CWA dashboard cards` |
| Timetable/Sessions polish | `Polish timetable and sessions layout` |
| Pre-launch checklist | `Add pre-launch checklist` |
| CWA gap docs | `Document gaps found in CWA feature flow` |
| Semester completion | `Improve CWA semester completion flow` |
| Result slip auto-label | `Auto-populate result slip labelling screen from AI-parsed metadata` |
| CWA flow gap fixes | `Complete CWA flow gap fixes` |
| What-if removal | `Remove dead what-if AI feature, fix hardcoded programme list, and improve "Update Results" UX` |
| Pre-release audit | `Fix 28 pre-release audit items: data-loss guards, error states, dead code, and polish` |
| Focused AI MVP cleanup | Removed global chatbot, CWA Coach, chat storage/usage models, and chat-only markdown/math dependencies; kept CWA import AI, AI Weekly Review, and AI Study Plan |
| Phase 16 S1 | `Add university onboarding and school logos` |
| Phase 16 S2 | `Add multi-grading-system support with configurable grade scales` |
| Phase 17 | `Add dark mode, timer feedback toggles, and About section to Settings` |
| Phase 18 | `Add course reminders and offline snackbar` |
| Polish | `fix: prevent note editor keyboard overflow` / `fix: improve dark mode readability` |
| Polish | `Clean up: remove old dev docs, polish UI across screens` |
| Polish | `Update app launcher icon` |
| Polish | `Fix Pomodoro default migration` / `Polish insights and review sheet UI` / `Refine MVP AI scope` |
| AI proxy | `Route AI requests through Vercel proxy` |
| AI proxy fix | `Route AI through proxy and fix release internet permissions` |

---

## What Comes Next

The codebase is now stabilised with onboarding, dark mode, multi-grading-system support, course reminders, and production hardening. CWA flow gaps are closed, dead features are removed, and all Isar write safety guards are in place. The next phase is Play Store preparation.

### Immediate — Before Beta Release

| Action | Notes |
|---|---|
| **Build APK** | `flutter build apk --debug` or `--release` |
| **Install on real device** | Physical Android device (not just emulator) |
| **Run updated E2E test checklist** | `_dev/E2E_TEST_CHECKLIST.md` — work through all sections including onboarding, course reminders, dark mode, and grading system tests |
| **Send APK to friend/tester** | Collect fresh-eyes feedback on UX, bugs, and performance |
| **Fix critical issues** | Any crash, major overflow, or broken flow found during device testing |

### Short-term — Beta → Production

| Feature | Notes |
|---|---|
| **Play Store Release** | App signing (`upload-keystore.jks`), `build.gradle` production config (minify, shrink, version codes), store listing assets (screenshots, icon, short description, privacy policy URL) |
| **Vercel API Proxy (server-side)** | Client-side proxy integration is complete; remaining server-side work: deploy Vercel functions with rate limiting, configure environment variables for API keys (see `_dev/PRE_LAUNCH_CHECKLIST.md`) |
| Premium payment integration | Replace `SubscribeScreenStub` with RevenueCat-powered paywall |
| Sentry + PostHog | Crash logging and analytics (see pre-launch checklist items 2–3) |
| Additional university logos | Add logos for remaining Ghanaian universities as assets become available |

### Longer-term

| Feature | Notes |
|---|---|
| Cloud sync | Optional backup of Isar data |
| Push notifications (remote) | Server-triggered alerts via FCM for AI-personalized content |
| Additional grading systems | Support for custom/institutional grading scales beyond the 4 built-in systems |
| Localisation | Twi, Ga, Ewe, and other Ghanaian language support |
