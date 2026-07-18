# UniMate — Claude Code Project Brief

## What this is
Flutter academic planning app for Ghanaian university students (KNUST first).
Package ID: com.wesleyconsults.campusiq
Current state: **v1.1.6 — Android + iOS, notification system hardened.**

## Tech stack
- Flutter + Dart (Android + iOS)
- State: Riverpod (riverpod_annotation + riverpod_generator)
- Storage: Isar 3.x (NOT Hive)
- Navigation: GoRouter — ShellRoute + full-screen push routes
- Fonts: Google Fonts — Inter
- Icons: Lucide-style (`LucideIcons`)
- Code gen: build_runner + isar_generator + riverpod_generator

## Design system
- Primary: deep navy (`AppColors.primary`)
- Accent: muted gold (`AppColors.goldSoft`), used sparingly
- Background: soft off-white (`AppColors.surface`)
- Cards/surfaces: white, large rounded corners
- Spacing/radii/shadows: tokenised in `lib/core/theme/app_tokens.dart`
- Typography: `lib/core/theme/app_theme.dart` (Material 3 + Inter)
- Shared widgets: `CampusCard`, `CampusButton`, `CampusChip`, `CampusSectionHeader`, `CampusModalSheet`, `ErrorRetryWidget`, `OfflineBanner`

## Architecture rule
Every feature follows: `data/` → `domain/` → `presentation/` (screens, widgets, providers)
Never mix business logic into widgets. Domain layer is pure Dart — zero Flutter deps.

## Navigation & screen flow

### Shell (4-tab floating pill bottom nav, always visible)
```
Home (/plan)    CWA (/cwa)    Table (/timetable)    Sessions (/sessions)
```

### Shell overlay (rendered in _AppShell, persists across tabs)
- **AI FAB** — gold sparkles button, bottom-right; `context.push('/ai')`
- **FloatingMiniTimer** — appears when a session is active; tap → `/sessions`

### Full-screen routes (no bottom nav, no AI FAB)
```
/ai                    ← AI FAB        → AiChatScreen
/streak                ← Today drawer  → StreakScreen
/insights              ← Today drawer  → InsightsScreen
/settings              ← Today drawer  → SettingsScreen
/ai/weekly-review      ← Today drawer  → WeeklyReviewScreen
/course/:courseCode    ← CWA / Table / Sessions → CourseHubScreen (3 tabs)
/timetable/import      ← Table scanner icon     → TimetableImportScreen
/cwa/manual-entry      ← CWA → Import → Enter Manually → CwaManualEntryScreen
/settings/timetable-notifications  ← Settings → TimetableNotificationDiagnosticsScreen
/subscribe             ← Today drawer  → SubscribeScreenStub
```

### Today screen drawer (local to PlanScreen, hamburger menu)
Today | Streak | Insights | Weekly Review | Settings | Subscribe

### Key navigation rules
- Tab switches: `context.go()` — system back from a tab exits the app
- Drill-down screens: `context.push()` — system back returns to previous screen
- Shell tabs render full height; content uses in-page overlay clearance to scroll above nav/FAB/timer

## Features & current scope

### Active features
| Feature | Route | Key details |
|---|---|---|
| Today / Home dashboard | `/plan` | Hero card (5 contextual states), academic pulse (2-col grid), today at a glance, progress, task list (3 groups) |
| CWA Target Planner | `/cwa` | Semester + Cumulative modes, hero CWA bar, compact course cards, score sliders, what-if AI, import (photo/PDF/manual) |
| Class Timetable | `/timetable` | Single-layer, full-page scroll, day selector pills + swipe, free block detection, slot detail sheet, Open Workspace |
| Study Sessions | `/sessions` | Normal (count-up) + Pomodoro (countdown, rounds, breaks), History/Plan tabs, "This Week" review sheet |
| Streak System | `/streak` | Study + attendance + per-course streaks, milestone grid, activity heatmap, attendance tracker |
| Insights | `/insights` | 7-check analyser (best day, neglected courses, late-night, weekly trend, etc.) |
| AI Chat / Coach | `/ai` | DeepSeek, Markdown + LaTeX math, chat history endDrawer, usage limits, premium gate |
| AI Weekly Review | `/ai/weekly-review` | AI-generated week narrative, 4 review sections, free/premium gating |
| Course Hub | `/course/:courseCode` | 3-tab: Overview, Sessions, Notes. Entry from CWA, Timetable, or Sessions |
| Timetable Import | `/timetable/import` | Camera/gallery → AI vision parsing → review → save |
| CWA Slip Import | (from CWA) | Registration slip + result slip import via AI vision |
| Manual Course Entry | `/cwa/manual-entry` | Full-screen form, semester + cumulative modes, keyboard-safe |
| Smart Notifications | (background) | Workmanager, streak protection, personalised alerts |
| Timetable Alert Reliability | `/settings/timetable-notifications` | Notification channel diagnostics, permission checks, sync status, test reminder, legacy cleanup, exact-alarm verification |
| Settings | `/settings` | Notification toggles, daily reminder time, cancel all, DEV premium toggle |

### Removed in v1.0
- Personal Timetable (layer 2) — all files deleted
- Exam Prep Generator (`/ai/exam-prep`) — all files deleted
- Exam Mode — all files deleted
- Course Hub: Files tab and per-course AI Chat tab removed (now 3 tabs only)

## Isar collections (active)
`CourseModel`, `TimetableSlotModel`, `ScheduledTimetableNotificationModel`, `StudySessionModel`, `UserPrefsModel`, `AiMessageModel`, `AiChatSessionModel`, `AiUsageModel`, `SubscriptionModel`, `StudyPlanModel`, `StudyPlanSlotModel`, `WeeklyReviewModel`, `DailyPlanTaskModel`, `CourseNoteModel`, `PastSemesterModel`

## Global state / Services
- `activeSessionProvider` — scoped above ShellRoute, survives tab switches
- `NotificationService` — singleton for local notifications & permissions
- `callbackDispatcher` — top-level entry point for Workmanager tasks
- Timer uses DateTime anchor (not Stopwatch) for Android reliability
- `ConnectivityService.isOnline()` — offline guard before AI/API calls
- `runZonedGuarded` + `FlutterError.onError` — global error capture in main.dart

## Notification IDs
- 100–199: Free block reminders
- 200–299: Streak at Risk (200, 201 = study-session based)
- 300: Study Reminder (Scheduled)
- 400: Weekly Review ready (Scheduled)
- 500: Milestone unlocked (Immediate)
- 600: Pomodoro timer end
- 700–999: Timetable course alerts (managed by `TimetableNotificationCoordinator`)
- 999001: Timetable test reminder (diagnostics)

## Key engineering decisions
- **Timer reliability**: DateTime anchor, not Stopwatch — survives Android pauses
- **Pomodoro**: `phaseEndsAt` DateTime anchor, `_lastFiredPhaseEnd` guard prevents double-fire, break time excluded from saved duration
- **Timetable notifications**: `TimetableNotificationCoordinator` reconciles desired alerts (slots × reminders) against OS-pending state. Each alert gets a `ScheduledTimetableNotificationModel` registry record with a stable `logicalKey`. The coordinator diffs, schedules/cancels only what changed, and persists sync results to `UserPrefsModel.lastTimetableNotificationSync*`.
- **Stable slot identity**: `TimetableSlotModel.slotId` is a random hex ID (`createStableTimetableId()`). Populated via `ensureStableIdentity()` before save; used for notification deep-linking and cross-referencing.
- **Course code normalization**: `normalizeCourseCode()` strips whitespace, uppercases, and removes non-alphanumeric chars. Both `TimetableSlotModel` and `CourseReminderModel` store a `normalizedCourseCode` (indexed) for case-insensitive, whitespace-agnostic matching between reminders and slots.
- **Streak calculation**: Pure Dart from existing data — no dedicated Isar collection
- **AI quotas**: Per-feature keys (`chat`, `whatif`) in `AiUsageModel`, not a single counter
- **Offline safety**: All 9 AI providers check `ConnectivityService.isOnline()` before API calls
- **Isar write safety**: All repositories wrap `.put()/.delete()` in try-catch with debugPrint
- **Every screen**: Handles loading, error, and empty states via `AsyncValue.when()` pattern

## Build commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # ← after ANY model change
flutter analyze
flutter run
```

## Do not
- Use Hive (we chose Isar)
- Use setState in screens (use Riverpod ConsumerWidget)
- Put logic in widgets
- Skip build_runner after editing any `@collection` or `@riverpod` annotated file
- Add new Isar collections without registering in `isar_provider.dart`
- Claim a feature exists if it was removed in v1.0 (check the removed list above)
