# CampusIQ Project Context (v1.0 Lean + UI Redesign Complete)

This document provides a concise technical overview of CampusIQ for AI agents and developers.

## 1. Overview
CampusIQ is an Android-first academic productivity app for Ghanaian university students (KNUST target). It centralizes CWA tracking, timetable management, study sessions, and AI-powered assistance.

## 2. Tech Stack
- **Framework:** Flutter (Material 3)
- **State Management:** Riverpod (Generator-based)
- **Database:** Isar (Local-only, NoSQL)
- **Navigation:** GoRouter
- **AI:** DeepSeek (API via HTTP), OpenAI Vision (for image parsing)
- **Background Tasks:** Workmanager

## 3. Architecture Pattern
Strict three-layer structure per feature:
- `data/`: Isar schemas (`models/`) and repositories (`repositories/`).
- `domain/`: Pure Dart business logic (calculators, analysers, value objects).
- `presentation/`: Riverpod providers, screens, and widgets.

## 4. Core Features (v1.0)
1.  **CWA Planner:** Manual entry + registration slip import (AI Vision). Supports Semester and Cumulative tracking.
2.  **Timetable:** Single-layer class grid with a compact day summary, full-page daily timeline, image import (AI Vision), and free-time detection.
3.  **Study Sessions:** Count-up (Normal) and Count-down (Pomodoro) timers. Tracks focus time only.
4.  **Course Hub:** Per-course workspace with Overview, Sessions, and Notes only.
5.  **Daily Plan:** AI-generated task list based on timetable free blocks.
6.  **Insights & Reviews:** Automated analytics and AI-generated narrative weekly reviews.
7.  **Streak System:** Daily study and attendance tracking with milestone rewards.

## 5. Key Data Models (Isar)
- `CourseModel`: CWA courses, credits, scores.
- `TimetableSlotModel`: Class times, venues, types.
- `StudySessionModel`: Session logs (duration, course, type).
- `UserPrefsModel`: Global flags (streak, notifications, attendance).
- `CourseNoteModel`: Course-specific notes.
- `AiMessageModel` / `AiChatSessionModel`: Chat history.
- `DailyPlanTaskModel`: Generated tasks for the current day.
- `PastSemesterModel`: Archived result data for cumulative CWA.

## 6. Critical Implementation Notes
- **Timer Logic:** Stores a `DateTime` anchor (`startTime`). Elapsed time is `now.difference(startTime)` to survive app pauses.
- **AI Context:** Uses a `ContextBuilder` to inject academic stats, notes, and session history into system prompts for personalized coaching.
- **Course Hub Scope:** Course Hub Files and per-course AI chat were removed from the launch build and deferred to a later version.
- **Lean Build:** Personal Timetable, Exam Mode, Exam Prep Generator, Course Hub Files, and Course Hub AI chat were removed in v1.0 to prioritize stability.

## 7. UI Structure & Navigation
### App shell
- Initial route is `/plan`.
- The main shell uses a `ShellRoute` with a persistent bottom navigation bar and a global AI floating action button.
- Bottom navigation now shows 4 destinations: `Home` (`/plan`), `CWA` (`/cwa`), `Table` (`/timetable`), and `Sessions` (`/sessions`).
- The shell also owns the floating active-session mini timer; if a study session is active, tapping the timer returns the user to `/sessions`.
- The AI FAB opens the main AI chat at `/ai` from anywhere inside the shell.
- Shell tabs now render full height behind the floating nav instead of being permanently clipped above it.
- Each shell tab is responsible for its own trailing bottom clearance so lower content can scroll above the bottom nav, AI FAB, and active-session mini timer without leaving a persistent dead band.
- Full-screen routes outside the shell intentionally do not show the bottom nav or shell AI FAB.

### Main top-level screens a user can reach
- `Today` at `/plan`: the daily hub and main landing screen. Internally still the Plan route, but user-facing copy should prefer `Today`.
- `CWA` at `/cwa`: course management, target planning, import bottom sheet, semester/cumulative toggle, and workspace entry point.
- `Timetable` at `/timetable`: class timetable with compact day summary, calmer slot/free-block styling, slot detail sheet, timetable import entry point, and workspace entry point.
- `Sessions` at `/sessions`: timer, analytics, plan-related surfaces, and workspace entry point from course breakdown.
- `AI Chat` at `/ai`: global AI assistant only.
- `Streak` at `/streak`: streak dashboard.
- `Insights` at `/insights`: secondary destination reachable from Today drawer.
- `Settings` at `/settings`: notification settings and dev premium toggle.
- `Weekly Review` at `/ai/weekly-review`: full-screen AI weekly review.
- `Subscribe` at `/subscribe`: premium upsell stub.

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
  - lower-priority detail cards for classes, free blocks, and task groups
- The earlier `Suggested focus` section was removed during refinement; the Today screen now flows directly from hero card into academic summary content.
- Bottom-safe spacing on Today was refined so lower Home content can scroll fully above the floating shell nav.
- Long plan-task labels now wrap to 2 lines and ellipsize instead of overflowing into the time/duration column.

### Timetable screen behavior
- The Timetable AppBar prioritizes two actions only: image import (scanner) and add class.
- A compact day summary card appears near the top and can show the selected day, class count, next/first class, and free-block count.
- The `Daily timeline` is the primary content area; the whole Timetable page scrolls naturally instead of trapping the grid inside a small inner vertical scroll box.
- Class slots use calmer cards, and free blocks are intentionally lighter and less visually dominant.
- Timetable content now scrolls cleanly above the floating shell nav and AI FAB using the same shell-overlay spacing model as the other bottom-nav tabs.

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
- `CWA` has two main modes: `Semester` and `Cumulative`.
- `CWA` now shows a visible `Import` action in the AppBar.
- Tapping `Import` opens a rounded bottom sheet with:
  - `Take Photo`
  - `Upload Image`
  - `Choose PDF`
  - `Enter Manually`
- Import options reuse the existing registration-slip and result-slip import flows instead of introducing a second import system.
- `Enter Manually` opens `/cwa/manual-entry?mode=semester|cumulative`, a dedicated full-screen form outside the shell.
- `/cwa/manual-entry` intentionally does not show the bottom nav or shell AI FAB.
- The manual-entry screen supports both `Semester` and `Cumulative` modes, defaulting from the currently selected CWA mode.
- The manual-entry screen includes:
  - semester-information dropdowns
  - repeatable course cards
  - live summary updates
  - duplicate course-code warning
  - sticky `Cancel` and `Save Courses` actions
  - unsaved-changes protection on back/cancel
- Saving reuses the existing CWA persistence stack:
  - `CourseModel` / `CwaRepository` for semester mode
  - `PastSemesterModel` / `PastResultRepository` for cumulative mode
- `Timetable` can open `/timetable/import` from the scanner action.
- `AI Chat` and some other screens can open `Settings` from AppBar actions where present.
- `Weekly Review` is accessed from the global AI area, not from Course Hub.

### Regression and stability notes from this redesign session
- Phase 7 focused on spacing, consistency, semantics, touch targets, dark-mode resilience, and keyboard-safe layout behavior.
- Phase 8 focused on regression cleanup and smoke-test coverage.
- A widget regression suite now exists at `test/ui_redesign_regression_test.dart`.
- That regression suite covers:
  - shell navigation presence
  - shell AI FAB visibility
  - CWA import-sheet options
  - manual-entry rendering on small screens
  - active-session mini timer visibility
- A small-screen dropdown overflow issue in manual entry was fixed during regression cleanup.
- A later Home refinement pass also fixed small-screen Today overflows by tightening the academic pulse tiles and making long task labels wrap/ellipsis safely.

### Navigation back-button behaviour (updated 2026-05-02)
- Shell tab switches use `context.go()` — pressing Back from a tab exits the app (expected).
- Detail/drill-down screens (AI Chat, Streak, Insights, Settings, Course Hub, etc.) use `context.push()` — pressing Back returns to the previous screen inside the app.
- This matches the production pattern used by Google Pay and Nubank: `go()` for same-level tab switching, `push()` for deeper navigation.

### Navigation assumptions for future changes
- Global AI lives only in `/ai`; there is no per-course AI surface in the workspace.
- Any feature added to Course Hub should be treated as a separate tab or in-tab action inside the 3-tab workspace unless the shell structure itself is being changed.
- Workspace changes should be checked against all 3 entry points: CWA, Timetable, and Sessions.
- Any new drill-down screen must use `context.push()` to ensure proper back-button behaviour.

## 8. Key File Locations
- `lib/core/`: Providers (Isar, connectivity, notification), Router, and Theme.
- `lib/features/`: Feature-specific code.
- `lib/shared/`: Reusable widgets and extensions.
- `_dev/`: Documentation (MVP report, E2E checklist).
