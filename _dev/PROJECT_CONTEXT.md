# UniMate Project Context (v1.0 Lean — Production Polish)

This document provides a concise technical overview of UniMate for AI agents and developers.

## 1. Overview
UniMate is an Android-first academic productivity app for Ghanaian university students. It includes a 6-step university onboarding flow (with 20+ universities, optional programme capture, configurable grading systems, CWA/GPA and timetable import education, and optional setup shortcuts), academic target planning (CWA/GPA/CGPA), timetable management with per-course reminders, study session tracking (Normal + Pomodoro) with timer feedback, streak/insights/review systems, and focused AI assistance for import, weekly review, and study planning.

## 2. Tech Stack
- **Framework:** Flutter (Material 3)
- **State Management:** Riverpod (Generator-based)
- **Database:** Isar (Local-only, NoSQL)
- **Navigation:** GoRouter
- **AI:** Vercel serverless proxy (`campusiq-api.vercel.app`) — keyless architecture, no API keys on-device. Routes to DeepSeek (text) and OpenAI Vision (image parsing) server-side.
- **Background Tasks:** Workmanager
- **Firebase:** Android-only Firebase Core, Analytics, and Crashlytics configured for project `unimate-69516` and package `com.wesleyconsults.campusiq`.

## 3. Architecture Pattern
Strict three-layer structure per feature:
- `data/`: Isar schemas (`models/`) and repositories (`repositories/`).
- `domain/`: Pure Dart business logic (calculators, analysers, value objects).
- `presentation/`: Riverpod providers, screens, and widgets.

## 4. Core Features (v1.0)
1.  **University Onboarding:** 6-step first-run flow (welcome → university + optional programme → target/grading system → grades import preview → timetable import preview → reminders + optional setup shortcut). University picker with 20+ Ghanaian institutions and logos. The selected university auto-selects the default grading system, and the target step still allows manual grading-system override. Final setup cards can open registration-slip import or timetable import on top of Today; cards are optional and can be deselected. GoRouter redirect guard blocks all routes until completed or skipped.
2.  **Multi-Grading-System:** CWA (0–100, KNUST/UMaT), GPA 4.0 (0.0–4.0, Legon/UCC/UEW/UDS etc.), GPA 4.0 GIMPA (A+/A/B+/B/C+/C/D+/D/F), CGPA 5.0 (0.0–5.0, UPSA/UniMAC etc.). Grade scales are configurable and drive all score displays, grade dropdowns, and target dialogs. Can be changed from Settings.
3.  **Academic Planner (CWA/GPA/CGPA):** Manual entry + registration slip import (AI Vision). Supports Semester and Cumulative tracking. Includes Complete Semester flow, active semester picker, persisted target, grade-first cumulative entry, duplicate semester detection, draft auto-save, and semester progression view. Tab label adapts to active grading system.
4.  **Timetable:** Single-layer class grid with a compact day summary, full-page daily timeline, image import (AI Vision), free-time detection, and per-course reminders.
5.  **Study Sessions:** Count-up (Normal) and Count-down (Pomodoro) timers. Tracks focus time only. Vibrate and sound feedback on timer phase end.
6.  **Course Reminders:** Per-course notification reminders with configurable offsets (10/15/30/60/120 min before class). Schedules via NotificationService with IDs 700–999.
7.  **Course Hub:** Per-course workspace with Overview, Sessions, and Notes only.
8.  **Daily Plan & AI Study Plan:** Daily tasks plus an AI-generated study plan based on courses, timetable free blocks, and past study patterns.
9.  **Insights & Reviews:** Automated analytics and AI-generated narrative weekly reviews.
10. **Streak System:** Daily study and attendance tracking with milestone rewards.
11. **Dark Mode:** System / Light / Dark theme picker in Settings → Appearance. Full dark palette for all screens, cards, sheets, dialogs.
12. **Settings:** Organised into 6 sections: Academic, Timer Feedback, Notifications, Appearance, About, Dev.

## 5. Key Data Models (Isar)
- `CourseModel`: CWA/GPA/CGPA courses, credits, scores. Keyed by `semesterKey` string (e.g. `"2024-Sem2"`). Stores `gradingSystemId` for per-course grading context.
- `TimetableSlotModel`: Class times, venues, types.
- `CourseReminderModel`: Per-course class reminders with configurable notification offset. Keyed by `semesterKey` + `courseCode`.
- `StudySessionModel`: Session logs (duration, course, type).
- `UserPrefsModel`: Global flags (streak, notifications, attendance). Also stores `activeSemesterKey`, `targetCwa`, `manualCwaDraftJson`, `gradingSystemId`, `universityName`, `programmeName`, `themeModeIndex`, `vibrateOnTimerEnd`, `playSoundOnTimerEnd`, `hasCompletedOnboarding`.
- `CourseNoteModel`: Course-specific notes.
- `DailyPlanTaskModel`: Generated tasks for the current day.
- `StudyPlanModel` / `StudyPlanSlotModel`: AI-generated study plan storage.
- `WeeklyReviewModel`: AI-generated weekly review storage.
- `PastSemesterModel`: Archived result data for cumulative tracking. Has `semesterKey` for cross-referencing with `CourseModel` and duplicate detection. Stores `gradingSystemId`.

## 6. Critical Implementation Notes
- **Timer Logic:** Stores a `DateTime` anchor (`startTime`). Elapsed time is `now.difference(startTime)` to survive app pauses. Pomodoro uses `phaseEndsAt` DateTime anchor with `_lastFiredPhaseEnd` guard to prevent double-fire.
- **AI Proxy Architecture:** All AI requests go through the Vercel proxy at `campusiq-api.vercel.app` (configured in `lib/core/config/ai_proxy_config.dart`). `DeepSeekClient` is parameterless (`const DeepSeekClient()`) — no API keys, model names, or auth headers in the client. Vision parsers (`TimetableVisionParser`, `RegistrationSlipParser`, `ResultSlipParser`) use the same proxy pattern. The `flutter_dotenv` package has been removed. Internet permissions (`INTERNET` + `ACCESS_NETWORK_STATE`) are declared in `AndroidManifest.xml` for release builds.
- **AI Scope:** MVP keeps focused AI surfaces only: CWA import via OpenAI Vision (through proxy), AI Weekly Review, AI Study Plan, and AI-generated streak notification text. The global chatbot and CWA Coach were removed. No `/ai` route, no AI FAB.
- **Onboarding Guard:** GoRouter redirect checks `hasCompletedOnboardingProvider` — if `false`, all non-`/onboarding` routes redirect to `/onboarding`. Once completed, stored in `UserPrefsModel.hasCompletedOnboarding`. The final onboarding action completes onboarding, goes to Today, then optionally pushes registration-slip import or timetable import so Android Back returns to Today instead of closing the app.
- **Grading System:** Active grading system drives dynamic UI labels (bottom nav tab, CWA/GPA screen title, grade dropdowns). All grading systems are defined in `lib/core/domain/grading_system.dart`. University defaults in `lib/core/domain/university_defaults.dart`. Grade scale with colour-coded letter grades in `lib/core/domain/grade_scale.dart`.
- **Dark Mode:** Theme mode persisted as index (0=system, 1=light, 2=dark) in `UserPrefsModel.themeModeIndex`. `themeModeProvider` reads it and `app.dart` passes `themeMode` to `MaterialApp.router`. Full dark theme defined alongside light theme in `app_theme.dart`.
- **Course Hub Scope:** Course Hub Files, per-course AI chat, and the Course Hub context builder were removed from the launch build and deferred to a later version.
- **Lean Build:** Personal Timetable, Exam Mode, Exam Prep Generator, Course Hub Files, Course Hub AI chat, global AI chat, CWA Coach, AI usage/chat quotas, and the What-If AI feature were removed in v1.0 to prioritize stability.
- **Isar Database:** Schema registration is centralized in `lib/core/data/isar_database.dart` (`kCampusIqIsarSchemas` list + `openCampusIqIsar()`). 12 schemas registered including `CourseReminderModelSchema`. On 2026-06-15, the official Isar `3.1.0+1` packages were replaced with Isar Community `3.3.0-dev.1` to provide Android 16 KB page-size support. The default database name, application-documents directory, collection IDs, stored property names/types, indexes, links, and opening logic were preserved. `test/isar_community_upgrade_test.dart` opens a real version-code-13 database fixture generated by the old runtime and verifies read/update/reopen compatibility.
- **Semester Model:** `CourseModel` and `PastSemesterModel` share a common `semesterKey` format. The active semester is persisted in `UserPrefsModel.activeSemesterKey`. A Complete Semester flow bridges projected courses → real results.
- **Offline Banner:** The `OfflineBanner` is rendered once inside `_AppShell` via `isOnlineProvider` — it appears on all shell tabs when offline.
- **Credit Hours Cap:** Raised from 6 to 12 across all entry points to accommodate project work and industrial attachment courses.
- **Draft Auto-Save:** Manual entry form state is persisted to `UserPrefsModel.manualCwaDraftJson` on every change and restored on next open.
- **App Name:** Display name changed to "UniMate" (`AppConstants.appName`). Package ID remains `com.wesleyconsults.campusiq`.
- **Analyzer Baseline:** On Flutter 3.41.7 as of 2026-06-15, `flutter analyze` reports 9 pre-existing onboarding lints (one unused local, four const suggestions, three `withOpacity` deprecations, and one additional const suggestion). The Isar migration introduces no analyzer errors. `analysis_options.yaml` excludes generated `**/*.g.dart` files so Riverpod/Isar generator warnings do not obscure handwritten-code issues.
- **Firebase Crashlytics:** Android-only setup completed on 2026-05-22 using `flutterfire configure --project=unimate-69516 --platforms=android`. Generated files: `lib/firebase_options.dart`, `firebase.json`, and `android/app/google-services.json`. Android Gradle applies Google Services and Firebase Crashlytics plugins. `main.dart` initializes Firebase before app startup and records Flutter, platform, and guarded-zone fatal errors with Crashlytics. Startup initialization runs inside `runZonedGuarded` to avoid Flutter zone mismatch reports. Settings → Dev includes a debug-only `Test Crashlytics crash` action using `FirebaseCrashlytics.instance.crash()`.
- **Analytics & Non-Fatal Reporting:** Added 2026-05-22 through `AnalyticsService` and `CrashReportingService`. Tracked screen views: onboarding, Today, planner, timetable, sessions, weekly review, streak, insights, settings, course hub, timetable import, course reminders, manual entry, past semesters, registration import, and result import. Tracked product events: onboarding started/completed/skipped, grading system selection, theme change, course add/update, course import start/success/failure, timetable slot add/update, timetable import start/success/failure, study session/pomodoro start and completion, weekly review generation, and AI study plan generation. Tracked user properties are anonymous only: `grading_system`, `theme_mode`, `notifications_enabled`, `onboarding_completed`, and `university_set`. Non-fatal Crashlytics reports cover caught import/parser failures, AI generation failures, notification scheduling failures, Workmanager background task failures, Isar open/write failures in key repositories, and session/course/timetable save failures.
- **Analytics Privacy Rules:** Do not track course names, exact grades/scores, timetable venues, note contents, AI prompts/responses, uploaded image/PDF content, programme names, or personally identifying details. Use counts, modes, sources, and coarse error reasons only.

## 7. UI Structure & Navigation
### App shell
- Initial route is `/onboarding` for first-run users; after completion, `/plan` is the default.
- A GoRouter redirect guard blocks all routes until onboarding is completed or skipped.
- The main shell uses a `ShellRoute` with a persistent floating pill-shaped bottom navigation bar.
- Bottom navigation shows 4 destinations: `Home` (`/plan`), dynamic grades label (CWA/GPA/CGPA, `/cwa`), `Table` (`/timetable`), and `Sessions` (`/sessions`).
- The second tab label adapts to the active grading system (e.g. "CWA", "GPA", "CGPA").
- There is **no AI FAB** in the current MVP. The `/ai` chatbot route is removed.
- The shell owns the floating active-session mini timer; if a study session is active, tapping the timer returns the user to `/sessions`.
- Shell tabs render full height behind the floating nav.
- An `OfflineBanner` is rendered as a `Positioned` widget at the top of `_AppShell` when `isOnlineProvider` reports offline.
- Full-screen routes outside the shell intentionally do not show the bottom nav.

### Main top-level screens a user can reach
- `Onboarding` at `/onboarding`: 6-step first-run flow (welcome → university + optional programme → target/grading system → grades import preview → timetable import preview → reminders + optional setup shortcut). Skip available on welcome screen.
- `Today` at `/plan`: the daily hub and main landing screen.
- `Grades` at `/cwa`: course management, target planning (persisted), active semester picker, import bottom sheet, semester/cumulative toggle, Complete Semester flow, semester progression card, and workspace entry point. All labels adapt to grading system.
- `Timetable` at `/timetable`: class timetable with compact day summary, slot detail sheet, timetable import entry point, course reminders entry point, and workspace entry point.
- `Sessions` at `/sessions`: timer, analytics, plan-related surfaces, and workspace entry point from course breakdown.
- `Streak` at `/streak`: streak dashboard.
- `Insights` at `/insights`: secondary destination reachable from Today drawer.
- `Settings` at `/settings`: 6 sections — Academic, Timer Feedback, Notifications, Appearance, About, Dev.
- `Weekly Review` at `/ai/weekly-review`: full-screen AI weekly review.
- `Course Reminders` at `/timetable/reminders`: per-course class reminder management.

### Today screen behavior
- `/plan` is the internal route, but the screen now acts as the student's **Today** home base.
- The top-left action on Today is a **menu/drawer button**, not a Home button.
- The Today drawer is the intended path to secondary destinations:
  - `Today`
  - `Streak`
  - `Insights`
  - `Weekly Review`
  - `Settings`
  - `Subscribe`
- The Today screen preserves daily-plan logic and now presents it through a calmer dashboard hierarchy:
  - in-body greeting header
  - one premium hero card near the top
  - `Academic pulse` summary in a 2-column metric grid
  - `Today at a glance` summary rows
  - `Progress` section with the plan progress bar
  - `Today's plan` task groups with a single visible `Add task` action
- The earlier `Suggested focus` section was removed during refinement; the Today screen now flows directly from hero card into academic summary content.
- The earlier `Today in detail` block was also removed so timetable specifics live in the `Table` tab instead of competing with the Home screen's core actions.
- Bottom-safe spacing on Today was refined so lower Home content can scroll fully above the floating shell nav.
- Long plan-task labels now wrap to 2 lines and ellipsize instead of overflowing into the time/duration column.

### Timetable screen behavior
- The Timetable AppBar prioritizes two actions only: image import (scanner) and add class.
- A compact day summary card appears near the top and can show the selected day, class count, next/first class, and free-block count.
- The `Daily timeline` is the primary content area; the whole Timetable page scrolls naturally instead of trapping the grid inside a small inner vertical scroll box.
- Class slots use calmer cards, and free blocks are intentionally lighter and less visually dominant.
- Timetable content now scrolls cleanly above the floating shell nav using the same shell-overlay spacing model as the other bottom-nav tabs.

### Primary shell return pattern
- Today remains the primary home base at `/plan` and is accessible through the **Home** bottom-nav tab.
- `CWA`, `Timetable`, and `Sessions` currently rely on the shared bottom navigation for returning to Today, rather than dedicated Home actions in each AppBar.
- Secondary destinations such as `Streak`, `Insights`, `Weekly Review`, `Settings`, and `Subscribe` remain reachable from the Today drawer or their existing deep links.

### Course Hub workspace
- Route is `/course/:courseCode`.
- It is a full-screen push outside the bottom-nav shell, so the bottom bar is not shown inside the workspace.
- Current launch tab structure is 3 tabs only:
- `Overview`: course summary, expected score, CWA impact, study stats, course streak.
- `Sessions`: course-only session history and weekly chart.
- `Notes`: course-specific notes with create/edit/delete flow.

### How users enter the Course Hub
- From `CWA`: course card overflow menu -> `Open Workspace`.
- From `Timetable`: slot detail sheet -> `Open Workspace`.
- From `Sessions`: course row inside the by-course breakdown -> opens that course workspace.

### Important screen-specific navigation patterns
- The CWA/GPA screen has two main modes: `Semester` and `Cumulative`.
- CWA screen title and all labels adapt to the active grading system (e.g. "GPA Planner", "Projected GPA", "Target GPA").
- CWA screen shows a visible `Import` action in the AppBar.
- Tapping `Import` opens a rounded bottom sheet with:
  - `Take Photo`
  - `Upload Image`
  - `Choose PDF`
  - `Enter Manually`
- `Take Photo` / `Upload Image` / `Choose PDF` → navigates to GoRouter named routes:
  - `/cwa/import/registration?source=camera|gallery|pdf` (Semester mode)
  - `/cwa/import/results?source=camera|gallery|pdf` (Cumulative mode)
- `PastSemestersScreen` is at `/cwa/history` (GoRouter named route), accessed via the history icon in CWA AppBar.
- `Enter Manually` opens `/cwa/manual-entry?mode=semester|cumulative`, a dedicated full-screen form outside the shell.
- In `Cumulative` mode, manual entry uses **grade dropdown** (colour-coded, specific to the active grading system's GradeScale) as the primary field, with an optional mark/score input.
- The manual-entry screen includes semester-information dropdowns, repeatable course cards, live summary updates, duplicate course-code warning, **draft auto-save**, sticky actions, and unsaved-changes protection.
- The **Complete Semester** flow pre-fills all current courses into a grade-entry form with grading-system-aware grade dropdowns, creates a `PastSemesterModel` on save, clears the old `CourseModel` entries, and advances `activeSemesterKey`.
- Credit hour inputs are capped at **12** across all CWA entry points.
- `Timetable` AppBar has three actions: scanner icon (import), reminders icon (course reminders), and add (+).
- `Timetable` can open `/timetable/import` from the scanner action or `/timetable/reminders` from the reminders action.
- `Weekly Review` is accessed from the Today drawer/deep link, not from Course Hub.
- Grading system can be changed from Settings → Academic → Grading system. Existing records keep their original grading system.

### Regression and stability notes
- A widget regression suite exists at `test/ui_redesign_regression_test.dart` covering: shell navigation presence, CWA import-sheet options, manual-entry rendering on small screens, active-session mini timer visibility.
- On 2026-05-22, `flutter analyze` passed with no issues after source lint cleanup and generated-file analyzer exclusion.
- On 2026-05-22, Firebase Crashlytics Android test crash was confirmed visible in Firebase Console for `com.wesleyconsults.campusiq`. A startup zone mismatch issue caused by initializing Flutter bindings outside `runZonedGuarded` was fixed the same session.
- On 2026-05-22, after the Crashlytics zone fix, `flutter analyze` passed with no issues and `flutter test` passed with all 9 tests.
- On 2026-05-22, after adding analytics and non-fatal Crashlytics instrumentation, `flutter analyze` passed with no issues and `flutter test` passed with all 9 tests.
- On 2026-05-22, `flutter test test/ui_redesign_regression_test.dart` passed. The active-session mini timer regression now asserts the `FloatingMiniTimer` widget is present, matching the compact timer behaviour on non-Sessions shell tabs.
- Dark mode is tested on all screens — cards, sheets, dialogs, input fields all adapt correctly.
- Grading system dynamic labels are verified across bottom nav, CWA screen, and all grade dropdowns.
- Onboarding flow is verified end-to-end including redirect guard behaviour, optional final setup cards, import/timetable back-to-Today behavior, and small-screen overflow checks for the preview cards.
- A small-screen dropdown overflow issue in manual entry was fixed during regression cleanup.

### Navigation back-button behaviour (updated 2026-05-22)
- Onboarding: GoRouter redirect guard blocks all routes until completed.
- Onboarding final setup shortcuts first complete onboarding and land on Today, then push import/setup routes so Back from registration import or timetable import returns to Today.
- Shell tab switches use `context.go()` — pressing Back from a tab exits the app (expected).
- Detail/drill-down screens (Streak, Insights, Settings, Course Hub, Weekly Review, etc.) use `context.push()` — pressing Back returns to the previous screen inside the app.

### Navigation assumptions for future changes
- There is no global chat, AI FAB, or per-course AI surface in the workspace. AI is limited to focused import/review/planning flows.
- Any feature added to Course Hub should be treated as a separate tab or in-tab action inside the 3-tab workspace.
- Workspace changes should be checked against all 3 entry points: CWA, Timetable, and Sessions.
- Any new drill-down screen must use `context.push()` to ensure proper back-button behaviour.
- The bottom nav second tab label is dynamically driven by `gradingSystemProvider` — any new grading system must be added to `GradingSystem.all`.

## 8. Key File Locations
- `lib/core/domain/`: Pure Dart domain classes — `grading_system.dart`, `grade_scale.dart`, `university_defaults.dart`.
- `lib/core/`: Providers (Isar, connectivity, notification), Router (with onboarding guard), Theme (light + dark), AI proxy config (`lib/core/config/ai_proxy_config.dart`), and centralised Isar schema (`lib/core/data/isar_database.dart` — 12 schemas).
- `lib/core/services/analytics_service.dart`: Firebase Analytics wrapper plus `TrackedScreen` helper. Skips calls safely when Firebase is not initialized during tests.
- `lib/core/services/crash_reporting_service.dart`: Firebase Crashlytics wrapper for fatal and non-fatal error reporting. Skips calls safely when Firebase is not initialized during tests.
- `lib/firebase_options.dart`: Generated Android-only FlutterFire options for Firebase project `unimate-69516`.
- `android/app/google-services.json`: Android Firebase app configuration for package `com.wesleyconsults.campusiq`.
- `firebase.json`: FlutterFire platform mapping; currently Android-only plus Dart options.
- `lib/features/onboarding/`: 6-step onboarding flow with `OnboardingNotifier`, optional `OnboardingStartAction`, clean UI preview screens, and `hasCompletedOnboardingProvider`.
- `lib/features/`: Feature-specific code.
- `lib/shared/`: Reusable widgets and extensions.
- `assets/images/universities/`: 20+ university logo PNGs.
- `_dev/`: Documentation (MVP report, E2E checklist, CWA flow gaps, pre-launch checklist, project context).
