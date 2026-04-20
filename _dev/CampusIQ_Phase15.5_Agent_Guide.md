# CampusIQ — Phase 15.5: Pre-Launch Stability & Production Hardening
## Agent Implementation Guide

> **Read this entire file before writing a single line of code.**
> This guide tells you exactly what to do, in what order, across how many sessions, and what NOT to touch.

---

## 🧠 What You Are Doing

You are hardening CampusIQ for Play Store release. The app is feature-complete (Phases 1–15.4). Your job is **not to build anything new** — it is to make the existing app bulletproof.

**Guiding principle:** *"If anything fails, the app must bend — not break."*

Every task you do must fit one of these three buckets:
1. Prevent a crash
2. Handle a failure gracefully
3. Make the failure visible (log it, show the user something useful)

If a task doesn't fit any of those three buckets, **skip it**.

---

## ⚠️ Hard Constraints

- ❌ Do NOT add new features
- ❌ Do NOT refactor architecture (the 3-layer feature structure stays as-is)
- ❌ Do NOT rename files, move folders, or restructure providers
- ❌ Do NOT change any UI that is already working correctly
- ✅ DO add try-catch, timeouts, fallback widgets, error states
- ✅ DO add `debugPrint` / structured logging for failures
- ✅ DO add connectivity checks before AI/API calls
- ✅ DO add snackbars and retry buttons where UI can get stuck

---

## 📦 Session Plan Overview

Phase 15.5 is split into **4 Claude Code sessions**. Each session has a tight scope. Do not bleed work from one session into another.

| Session | Scope | Estimated files touched |
|---|---|---|
| **15.5-S1** | Global error handling + API/AI call hardening | ~5 files |
| **15.5-S2** | Offline detection + Isar safety + Riverpod state audit | ~10–15 files |
| **15.5-S3** | UI state coverage (loading/empty/error) + Navigation safety | ~12–18 files |
| **15.5-S4** | Timer/session reliability + File/PDF/image import safety + Final checklist | ~8–12 files |

Each session ends with: `dart run build_runner build --delete-conflicting-outputs` + `flutter analyze` with zero new errors.

---

## 🔴 SESSION 1 — Global Error Handling + API Hardening

**Commit message when done:** `fix(15.5-S1): global error capture + API/AI call hardening`

### Task 1.1 — Wrap app entry in runZonedGuarded

**File:** `lib/main.dart`

```dart
// Wrap the entire runApp call:
runZonedGuarded(() {
  runApp(const ProviderScope(child: CampusIQApp()));
}, (error, stackTrace) {
  debugPrint('🔴 UNCAUGHT ERROR: $error');
  debugPrint('$stackTrace');
});
```

Also add **before** the `runZonedGuarded` call:
```dart
FlutterError.onError = (FlutterErrorDetails details) {
  debugPrint('🔴 FLUTTER ERROR: ${details.exceptionAsString()}');
  debugPrint('${details.stack}');
};
```

### Task 1.2 — Harden DeepSeek client

**File:** `lib/features/ai/domain/deepseek_client.dart`

Every HTTP call in this file must:
1. Have a `.timeout(const Duration(seconds: 10))` on the `http.post()`
2. Be wrapped in try-catch catching `TimeoutException`, `SocketException`, and the catch-all `Exception`
3. Throw a `DeepSeekException` with a human-readable message for each failure type

Failure messages to use:
- Timeout → `'Request timed out. Check your connection and try again.'`
- No internet → `'No internet connection. AI features require a connection.'`
- Invalid JSON → `'Received an unexpected response. Please try again.'`
- Non-200 status → `'AI service returned an error (${response.statusCode}). Try again later.'`

### Task 1.3 — Harden OpenAI Vision parsers

**Files:**
- `lib/features/timetable/domain/timetable_vision_parser.dart`
- `lib/features/cwa/domain/registration_slip_parser.dart`
- `lib/features/cwa/domain/result_slip_parser.dart`

Apply the same pattern as Task 1.2 to each parser:
- Timeout: 15 seconds (vision calls are slower)
- Catch `TimeoutException`, `SocketException`, `FormatException`, and `Exception`
- Return a typed error result — do NOT throw; each parser should return a sealed result or throw a named exception that the state machine catches and maps to an `error` state

### Task 1.4 — Verify DeepSeekException is caught everywhere

Search the codebase for every place `deepseek_client.dart` methods are called. Confirm each call site is wrapped in try-catch or inside an `AsyncNotifier` that routes to an error state. Fix any call site that swallows the exception silently.

### Task 1.5 — Session 1 validation

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Zero new errors before committing.

---

## 🔴 SESSION 2 — Offline Detection + Isar Safety + Riverpod State Audit

**Commit message when done:** `fix(15.5-S2): offline detection, Isar write safety, provider error state coverage`

### Task 2.1 — Add connectivity detection

**Add dependency to pubspec.yaml:**
```yaml
connectivity_plus: ^6.0.3
```

**Create file:** `lib/core/services/connectivity_service.dart`

```dart
// A simple Riverpod provider that exposes:
// - isOnline: bool (current state)
// - stream of connectivity changes

// Use ConnectivityPlus to check on app resume and on explicit check calls.
// Do NOT create a permanent stream listener — check on demand + on app resume.
```

**Create provider:** `lib/core/providers/connectivity_provider.dart`
```dart
@riverpod
Future<bool> isOnline(IsOnlineRef ref) async {
  // Return true/false from ConnectivityPlus check
}
```

### Task 2.2 — Offline banner widget

**Create file:** `lib/shared/widgets/offline_banner.dart`

A simple `AnimatedContainer` that shows a grey banner reading `"You are offline. AI features require a connection."` when `isOnline` is false. This widget is used in Task 2.3.

### Task 2.3 — Add offline check before AI calls

In each of these providers, add an `isOnline` check **before** making any API call. If offline, set the state to an error state with the message from Task 2.2 instead of calling the API:

- `lib/features/ai/presentation/providers/ai_chat_provider.dart`
- `lib/features/ai/presentation/providers/exam_prep_provider.dart`
- `lib/features/ai/presentation/providers/study_plan_provider.dart`
- `lib/features/ai/presentation/providers/weekly_review_provider.dart`
- `lib/features/cwa/presentation/providers/whatif_provider.dart`
- `lib/features/course_hub/presentation/providers/hub_ai_provider.dart`
- `lib/features/timetable/presentation/providers/timetable_import_provider.dart`
- `lib/features/cwa/presentation/providers/registration_slip_import_provider.dart`
- `lib/features/cwa/presentation/providers/result_slip_import_provider.dart`

### Task 2.4 — Isar write safety

Audit every `repository` file across all features. For every method that performs a write (`.put()`, `.putAll()`, `.delete()`):

1. Wrap in try-catch if not already wrapped
2. Add `debugPrint('🔴 Isar write failed: $e')` in catch block
3. Re-throw a typed exception so the provider can surface the error — do NOT swallow silently

Files to audit (check all `*/data/repositories/*.dart`):
- `cwa_repository.dart`
- `past_result_repository.dart`
- `timetable_repository.dart`
- `personal_slot_repository.dart`
- `session_repository.dart`
- `course_note_repository.dart`
- `course_file_repository.dart`
- `ai_chat_repository.dart`
- `ai_usage_repository.dart`
- `daily_plan_repository.dart`
- `exam_repository.dart`
- `user_prefs_repository.dart`
- `subscription_repository.dart`

### Task 2.5 — Riverpod async provider audit

For every `AsyncNotifier` and `FutureProvider` in `presentation/providers/`, verify:

1. The `build()` method has a try-catch (or uses `AsyncValue.guard`)
2. The UI that watches it handles all three `AsyncValue` states: `loading`, `error`, `data`
3. No provider silently returns an empty result on failure — it must transition to `error` state

If a provider is missing error handling in `build()`, add `AsyncValue.guard(() async { ... })` wrapping.

### Task 2.6 — Session 2 validation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Zero new errors before committing.

---

## 🔴 SESSION 3 — UI State Coverage + Navigation Safety

**Commit message when done:** `fix(15.5-S3): full loading/empty/error UI coverage + route safety`

### Task 3.1 — Audit every screen for loading/empty/error states

Go through each screen listed below. For each, verify it handles all three states. If any state is missing, add it.

**Pattern to use for async data:**
```dart
// In build():
return ref.watch(someProvider).when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => _ErrorRetry(message: e.toString(), onRetry: () => ref.invalidate(someProvider)),
  data: (items) => items.isEmpty
      ? const EmptyStateWidget(message: 'No data yet')
      : _buildContent(items),
);
```

**Create shared retry widget:** `lib/shared/widgets/error_retry_widget.dart`
```dart
// Props: String message, VoidCallback onRetry
// Shows: icon + message + "Try Again" ElevatedButton
```

**Screens to audit:**

| Screen | File | Common missing state |
|---|---|---|
| CWA Screen | `cwa/presentation/screens/cwa_screen.dart` | Error state on course load failure |
| Timetable Screen | `timetable/presentation/screens/timetable_screen.dart` | Empty state (no slots added) |
| Session Screen | `session/presentation/screens/session_screen.dart` | Empty state (no sessions yet) |
| Streak Screen | `streak/presentation/screens/streak_screen.dart` | Empty state (no study days) |
| Insights Screen | `insights/presentation/screens/insights_screen.dart` | Empty state (insufficient data) |
| AI Chat Screen | `ai/presentation/screens/ai_chat_screen.dart` | Error state on session load |
| Exam Prep Screen | `ai/presentation/screens/exam_prep_screen.dart` | Error state on generation failure |
| Weekly Review Screen | `ai/presentation/screens/weekly_review_screen.dart` | Error + loading state |
| Plan Screen | `plan/presentation/screens/plan_screen.dart` | Empty state (no tasks) |
| Course Hub Screen | `course_hub/presentation/screens/course_hub_screen.dart` | Course-not-found fallback |
| Timetable Import Screen | `timetable/presentation/screens/timetable_import_screen.dart` | Verify all 7 states render |
| Registration Slip Screen | `cwa/presentation/screens/registration_slip_import_screen.dart` | Verify all 6 states render |
| Result Slip Screen | `cwa/presentation/screens/result_slip_import_screen.dart` | Verify all 7 states render |
| Past Semesters Screen | `cwa/presentation/screens/past_semesters_screen.dart` | Empty state (no history) |

### Task 3.2 — No screen should ever be blank

After auditing, do a manual checklist:
- First app launch (empty database) → does every screen show a helpful empty state?
- Simulate a provider error → does every screen show a retry button?
- While loading → does every screen show a spinner?

If any screen shows a blank white area instead of one of the above, fix it before moving on.

### Task 3.3 — Navigation safety

**File:** `lib/core/router/app_router.dart`

For the `/course/:courseCode` route:
- If `courseCode` is null or empty, redirect to `/cwa` with a snackbar: `"Course not found."`
- If the resolved `CourseModel` doesn't exist in Isar, show a `Scaffold` with `"This course no longer exists"` and a back button — do NOT crash

For every other named route, verify parameters are non-null before building the screen.

### Task 3.4 — Add snackbars for silent failures

Anywhere a user action (button tap, swipe-to-delete, save) can fail silently, add a `ScaffoldMessenger.of(context).showSnackBar(...)` call in the catch block. The message should be human-readable, not a stack trace.

Pattern:
```dart
try {
  await repository.doThing();
} catch (e) {
  debugPrint('🔴 doThing failed: $e');
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Something went wrong. Please try again.')),
    );
  }
}
```

### Task 3.5 — Session 3 validation

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Zero new errors. Do a manual 5-minute walkthrough of every screen before committing.

---

## 🔴 SESSION 4 — Timer Reliability + File/PDF/Image Safety + Final Checklist

**Commit message when done:** `fix(15.5-S4): timer edge cases, file import safety, final stability checklist complete`

### Task 4.1 — Normal mode timer reliability

**File:** `lib/features/session/presentation/providers/active_session_provider.dart`

Verify:
- `sessionStartTime` is stored as `DateTime.now()` — NOT as a `Stopwatch` or integer counter
- Elapsed time is always computed as `DateTime.now().difference(sessionStartTime)` — NOT from a counter variable
- If `sessionStartTime` is somehow null when the timer ticks, the timer should stop gracefully rather than throwing a null check error

### Task 4.2 — Pomodoro timer reliability

**File:** `lib/features/session/presentation/widgets/active_timer_card.dart`
**File:** `lib/features/session/presentation/providers/active_session_provider.dart`

Verify:
1. `phaseRemaining` never returns a negative `Duration` — clamp to `Duration.zero` if needed
2. `_lastFiredPhaseEnd` guard prevents double-firing phase transitions — confirm this guard works even if the widget rebuilds rapidly
3. `advancePhase()` is idempotent — calling it twice in the same phase does not corrupt state
4. When the app is killed mid-Pomodoro and relaunched, the session is either correctly resumed or cleanly abandoned (no phantom timers)

Add a null-safe clamp:
```dart
Duration get phaseRemaining {
  final remaining = phaseEndsAt.difference(DateTime.now());
  return remaining.isNegative ? Duration.zero : remaining;
}
```

### Task 4.3 — File handling safety

**File:** `lib/features/course_hub/presentation/widgets/hub_files_tab.dart`

Add these guards:
1. **File size check before copy:** If file is > 50 MB, show snackbar `"File is too large. Maximum size is 50 MB."` and abort
2. **Corrupted file during copy:** Wrap file copy in try-catch; on failure, show snackbar and do NOT write a `CourseFileModel` record
3. **`open_filex` failure:** Wrap `OpenFilex.open()` in try-catch; on failure, show snackbar `"Could not open file. You may need an app to view this type of file."`

### Task 4.4 — PDF extraction safety

**File:** `lib/features/course_hub/domain/course_pdf_extractor.dart`

Add these guards:
1. Wrap the entire syncfusion extraction in try-catch — corrupted PDFs will throw
2. On extraction failure, return `null` (not empty string) so the repository sets `isTextExtractable = false`
3. The "Reading PDF…" loading state in `hub_files_tab.dart` must always resolve — either to success or failure — within 30 seconds maximum (add a `Future.timeout` wrapping the extractor call)

### Task 4.5 — Timetable image import safety

**File:** `lib/features/timetable/presentation/providers/timetable_import_provider.dart`

Verify the 4MB size guard fires before the API call (not after). If missing, add:
```dart
if (imageBytes.length > 4 * 1024 * 1024) {
  state = TimetableImportState.error('Image is too large. Please crop or compress it and try again.');
  return;
}
```

Verify empty-parse handling: if the vision API returns an empty `slots` array, transition to `error` state with `'No timetable slots could be detected. Try a clearer image.'` — do NOT transition to `reviewing` with an empty list.

### Task 4.6 — Registration and result slip import safety

**Files:**
- `lib/features/cwa/presentation/providers/registration_slip_import_provider.dart`
- `lib/features/cwa/presentation/providers/result_slip_import_provider.dart`

Apply same empty-parse guard as Task 4.5. If AI returns zero courses/results, show error state rather than an empty review screen.

### Task 4.7 — Final stability checklist

Before committing, manually verify every item below. Mark each ✅ or ❌. Do not commit with any ❌.

```
CRASH PREVENTION
[ ] App launches on fresh install (no Isar data) without crash
[ ] App recovers from a simulated API failure without crash
[ ] No null check errors in any provider under normal usage

AI FEATURES
[ ] AI chat fails gracefully offline (shows error, not spinner)
[ ] Exam prep generation fails gracefully offline
[ ] CWA coach fails gracefully offline
[ ] What-if explainer fails gracefully offline
[ ] Timetable image import fails gracefully offline
[ ] All slip imports fail gracefully offline

SCREENS
[ ] Every screen has a loading state (spinner or skeleton)
[ ] Every screen has an empty state (message + CTA)
[ ] Every screen has an error state (message + retry button)
[ ] No screen appears blank or frozen under any condition

TIMERS
[ ] Normal timer continues correctly after app backgrounded
[ ] Pomodoro countdown never goes negative
[ ] Phase transitions fire exactly once per phase
[ ] App handles being killed mid-session without crash on relaunch

FILES
[ ] Files > 50 MB are rejected with a user-facing message
[ ] Corrupted PDF extraction does not crash the app
[ ] File open failure shows a snackbar, not a crash

NAVIGATION
[ ] /course/:courseCode with invalid code shows fallback UI
[ ] Back navigation from all full-screen routes works correctly
[ ] Bottom nav is stable across all tab switches

DATABASE
[ ] All Isar writes are try-caught
[ ] Provider shows error state if Isar write fails
[ ] App works fully offline for: CWA planner, timetable, sessions, streak
```

### Task 4.8 — Session 4 validation

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run  # manual 30-minute test walk
```

Zero new errors. No new lint warnings. Commit.

---

## 📋 Dependency Summary

One new package is added in Session 2:

```yaml
# pubspec.yaml — add to dependencies:
connectivity_plus: ^6.0.3
```

Run `flutter pub get` at the start of Session 2.

---

## 🗂️ Files You Should NEVER Touch in This Phase

These files contain working business logic. Do not refactor or restructure them:

- `lib/features/*/domain/**` — domain logic is already pure Dart; only add guards, never restructure
- `lib/core/router/app_router.dart` — only add null-safety guards; do not change routes
- `lib/core/theme/app_theme.dart` — no changes
- Any `*.g.dart` file — these are generated; only regenerate via build_runner
- `pubspec.yaml` — only add `connectivity_plus`; do not upgrade existing packages

---

## 🔢 Can the Agent Handle All of This?

**Yes, but with these expectations:**

- Each session is scoped tightly enough that a single Claude Code session can handle it without context overflow
- Session 1 and 4 are the lowest risk (isolated files, clear targets)
- Session 2 is the most tedious (13 repository files to audit) but each fix is the same pattern repeated
- Session 3 requires the most judgment (deciding what "good enough" empty state looks like per screen)

**What might need a human decision:**
- If a provider has a deeply nested state machine that needs restructuring to support error states — flag it and move on rather than refactoring
- If `connectivity_plus` causes a version conflict with existing dependencies — use `dart pub deps` to inspect and resolve manually before continuing

---

## ✅ Definition of Done

Phase 15.5 is complete when:
1. All 4 sessions are committed with their commit messages
2. `flutter analyze` returns zero errors on final build
3. The final checklist in Task 4.7 is 100% ✅
4. The app survives a 30-minute continuous usage test without a single crash

**Next phase after 15.5:** Play Store release prep (signing, `build.gradle` production config, store listing assets).
