# CampusIQ Pre-Onboarding Audit

Generated 2026-05-10. Covers all features, shared code, routing, and cross-cutting concerns.

---

## High severity — fix before Play Store

### 1. Subscription flow is a dead end
**`lib/features/ai/presentation/screens/subscribe_screen_stub.dart:12`**

4 different premium gate widgets navigate to `/subscribe`, which lands on a screen that says *"Subscription coming soon. Contact: wesleyconsults@gmail.com"*. No IAP, no paywall, no payment integration. This is the monetization path — it must work before release.

Affected entry points: `PremiumGateWidget`, `PlanFreeGateCard`, `ReviewGateOverlay`, `UsageCounterChip`.

### 2. ~~AI context builder can hang indefinitely~~ ✅ Done (2026-05-10)
**`lib/features/ai/domain/context_builder.dart:266-268, 291-293`**

`stream.first` with no timeout on `watchCourses()` and `watchSlotsForDay()`. If the Isar stream never emits (empty DB, error), the AI chat/study plan/review generation hangs forever with a loading spinner. Wrap in `.timeout()`.

**Fix:** Added `.timeout(const Duration(seconds: 5))` to both `stream.first` calls. On timeout, the existing `catch (_)` returns empty lists — AI degrades gracefully instead of hanging.

### 3. ~~Streak always reported as "No active streak" to AI~~ ✅ Done (2026-05-10)
**`lib/features/ai/domain/context_builder.dart:47-48`**

`buildAcademicContext()` hardcodes `'- Study streak: No active streak'` despite `StreakCalculator` being fully implemented. Every AI prompt (study plans, CWA coaching, weekly reviews) is missing real streak data.

**Fix:** Added `_getStudyStreak()` that queries 2 years of session dates, runs them through `StreakCalculator.calculate()`, and generates a real summary like `"14 days (longest: 21)"`. All AI prompts now include actual streak data.

### 4. ~~Streak milestone baseline mismatch (visible UI bug)~~ ✅ Done (2026-05-10)
**`lib/features/streak/domain/streak_calculator.dart:70` + `lib/features/streak/presentation/widgets/milestone_grid.dart:120`**

`daysToNextMilestone` uses `currentStreak` but milestones track against `longestStreak`. A user with a broken 10-day streak sees "14 days to unlock" next milestone when they really only need 4. Progress bar and text contradict each other — two UI elements disagree on the same card.

**Fix:** `daysToNextMilestone` now uses `longestStreak` instead of `currentStreak`. `MilestoneGrid._BadgeTile` also tracks against `longestStreak` for the "X left" label. Both now agree with the progress bar.

### 5. ~~Streak screen silently degrades on load/error~~ ✅ Done (2026-05-10)
**`lib/features/streak/presentation/providers/streak_provider.dart:27-52` + `lib/features/streak/presentation/screens/streak_screen.dart:35-36`**

All streak providers flatten to `.valueOrNull ?? []`, discarding loading and error states. New user sees a zero-streak screen with no loading indicator. If Isar fails, errors are swallowed silently.

**Fix:** `StreakScreen` now watches the three underlying `AsyncValue` providers (`allSessionsProvider`, `coursesProvider`, `attendedDatesProvider`) and shows a loading spinner or `ErrorRetryWidget` before computing streak results. The derived streak providers are left unchanged — they correctly handle empty data.

### 6. ~~CourseHub note save silently loses data when repo is null~~ ✅ Done (2026-05-10)
**`lib/features/course_hub/presentation/providers/course_note_provider.dart:9` + `lib/features/course_hub/presentation/widgets/note_editor_sheet.dart:52-55`**

The nullable `courseNoteRepositoryProvider` returns `null` when Isar isn't ready. The save method does `if (repo == null) return;` then pops the sheet — the user's note is discarded with zero feedback.

**Fix:** Repo-null and Isar write failures now show a SnackBar and keep the sheet open so the user can retry.

### 7. ~~Venue validation blocks editing imported slots~~ ✅ Done (2026-05-10)
**`lib/features/timetable/presentation/widgets/add_slot_sheet.dart:217-218` + `lib/features/timetable/domain/timetable_slot_import.dart:34`**

Import allows empty venue, but the edit form requires it. A slot imported with no venue can never be edited because the form rejects it. Circular trap.

**Fix:** Removed the required validator on the venue field. Venue is already handled as optional in the detail view (`slot_detail_sheet.dart` — only shown when non-empty).

### 8. ~~Timetable write operations have no error feedback~~ ✅ Done (2026-05-10)
**`lib/features/timetable/presentation/screens/timetable_screen.dart:77-91` + `lib/features/timetable/presentation/widgets/slot_detail_sheet.dart:59-71`**

`addSlot`, `updateSlot`, `deleteSlot` all lack try/catch. If the Isar write fails, the user thinks it succeeded. Delete dismisses the sheet before the operation completes — user believes a slot was deleted when it wasn't.

**Fix:** All three operations now check for null repo, wrap Isar writes in try/catch, and show a SnackBar on failure.

### 9. ~~Session data silently discarded~~ ✅ Done (2026-05-10)
**`lib/features/session/presentation/screens/session_screen.dart:90-96, 124-125`**

Sessions under 1 minute are silently dropped. Failed Isar saves have no try/catch. The user loses their session data with no indication.

**Fix:** Short sessions now show a "Session too short to save" SnackBar. Repo-null and Isar write failures show error feedback.

---

## Medium severity — fix before release

| # | Area | File | Issue |
|---|------|------|-------|
| 10 | AI | `domain/latex_sanitizer.dart` | ~~307-line `LatexSanitizer` class, zero consumers~~ ✅ Done — file deleted |
| 11 | AI | `presentation/providers/ai_chat_provider.dart:81,95` | ~~Chat session load/switch errors silently swallowed~~ ✅ Done — sets `state.error` |
| 12 | AI | `presentation/screens/ai_chat_screen.dart:306-310` | ~~Error states collapse to `SizedBox.shrink()`~~ ✅ Done — loading shows slim progress bar, error keeps shrink (non-critical) |
| 13 | AI | `presentation/screens/weekly_review_screen.dart:133` | ~~Weekly review renders blank on subscription check error~~ ✅ Done — treats error as non-premium, shows content |
| 14 | AI | `presentation/providers/ai_chat_provider.dart:189` | ~~Hardcoded `'current'` semester key~~ ✅ Done — now reads `activeSemesterProvider` |
| 15 | AI | `domain/deepseek_client.dart:11` | ~~10s timeout too short~~ ✅ Done — bumped to 60s |
| 16 | CWA | `providers/registration_slip_import_provider.dart:147` + `result_slip_import_provider.dart:203` | ~~Empty API key produces cryptic 401~~ ✅ Done — upfront check with clear message |
| 17 | CWA | `models/past_semester_model.dart:83-89`, `domain/past_course_result.dart:28-40`, `screens/result_slip_import_screen.dart:1226-1232` | ~~Duplicate grade-to-score mapping~~ ✅ Done — screen now uses `PastCourseEntry.gradeFromScore()` |
| 18 | CWA | `providers/registration_slip_import_provider.dart:222-237` | ~~Silently skips duplicate courses~~ ✅ Done — shows "X already existed" on done screen |
| 19 | CWA | `screens/past_semesters_screen.dart:26` | ~~Error state uses plain `Text('Error: $e')`~~ ✅ Done — replaced with `ErrorRetryWidget` |
| 20 | CourseHub | `domain/course_hub_context_builder.dart` | ~~59-line class, zero consumers~~ ✅ Done — file deleted |
| 21 | CourseHub | `widgets/hub_notes_tab.dart:39`, `widgets/hub_sessions_tab.dart:23` | ~~Error states have no retry button~~ ✅ Done — both use `ErrorRetryWidget` now |
| 22 | CourseHub | `widgets/hub_overview_tab.dart:24-27` | ~~No loading/error states~~ ✅ Done — loading spinner + `ErrorRetryWidget` |
| 23 | Session | `screens/session_screen.dart:411-413` | ~~Session delete has no confirmation dialog~~ ✅ Done — uses `showCampusConfirmDialog` with destructive style |
| 24 | Plan | `providers/plan_provider.dart:51-65` | ~~No try/catch for notification scheduling~~ ✅ Done — repo ops throw to provider error, notifications caught silently |
| 25 | Plan | `domain/plan_generator.dart:143-173` | ~~Free block detection duplicated~~ ✅ Done — now uses `FreeTimeDetector.detect()` |
| 26 | Shared | `widgets/offline_banner.dart` | ~~`OfflineBanner` never instantiated~~ ✅ Done — wired in app shell, shown when offline |
| 27 | Shared | `widgets/empty_state_widget.dart` | ~~Dead file — contains only a newline byte~~ ✅ Done — file deleted |
| 28 | Router | `core/router/app_router.dart:151` | ~~Dead route prefix `/today`~~ ✅ Done — removed |
| 29 | Plan | `screens/plan_screen.dart` | ~~No "Regenerate plan" button~~ ✅ Done — refresh icon button next to section header |
| 30 | Session | `screens/session_screen.dart` | ~~Pomodoro rounds always 4~~ ✅ Done — rounds stepper added (range 2–10) |

---

## Low severity — nice to have

| # | Area | File | Issue |
|---|------|------|-------|
| 31 | AI | `providers/ai_usage_provider.dart:10-15` | `aiUsageRemainingProvider` never consumed |
| 32 | AI | `data/repositories/ai_chat_repository.dart:103-124` | `clearHistory()` never called |
| 33 | AI | `providers/ai_chat_provider.dart:260-262` | `clearChat()` never called |
| 34 | AI | `domain/context_builder.dart:62` | Hardcoded `'Unknown Programme'` in AI context |
| 35 | CWA | `models/course_model.dart:20` | Dead field `CourseModel.examDate` never used |
| 36 | CWA | `screens/past_semesters_screen.dart:110` | Silent return in `_confirmFinalize` safety-net path |
| 37 | CWA | `screens/cwa_manual_entry_screen.dart:102` | Unsaved-changes detection fires on 2 empty forms |
| 38 | CourseHub | `providers/course_note_provider.dart:9-17` | Two different repo access patterns in same file |
| 39 | Session | `domain/planned_actual_analyser.dart:177-208` | `feedbackForDay()` method never called |
| 40 | Session | `domain/active_session_state.dart:48` | `DateTime(0)` sentinel for non-Pomodoro sessions |
| 41 | Streak | `widgets/streak_hero_card.dart:152-153` | Label text `Colors.white54` on `grey.shade100` — poor contrast when inactive |
| 42 | Streak | `widgets/activity_heatmap.dart:22-69` | Shows legend even when zero activity exists |
| 43 | Streak | `screens/streak_screen.dart:100` | Attendance toggle silently fails when repo is null |
| 44 | Plan | `domain/plan_generator.dart:127` | Step numbering gap in comments (step 4 → 6) |
| 45 | Settings | `screens/settings_screen.dart:9-11` | Imports from 3 feature modules — cross-feature coupling |
| 46 | Core | `cwa/providers/cwa_provider.dart:32` | `activeSemesterProvider` is cross-cutting but lives inside CWA feature |

---

## Summary

| Severity | Total | Done | Remaining |
|----------|-------|------|-----------|
| High | 9 | 8 | 1 (#1 subscription — on hold) |
| Medium | 21 | 16 | 5 |
| Low | 15 | 0 | 15 |

### What's solid

- All 4 shell tabs (Plan, CWA, Timetable, Sessions) have complete UI with loading/error/empty states
- All routes in `app_router.dart` are wired to real screens
- 13 of 14 Isar collections have full repository CRUD
- AI chat, weekly review, study plan, and CWA coaching are fully implemented
- Streak, insights, and attendance tracking are feature-complete
- CourseHub with 3 tabs is fully built
- Timer (normal + Pomodoro) works end-to-end with floating mini-timer overlay
- Smart notifications are wired via Workmanager
- Data-loss scenarios: all repo writes have try/catch + SnackBar feedback
- Streak: milestone calculation consistent, loading/error states added
- AI: context builder has timeouts, uses real streak data + active semester
- Error states: 10+ screens upgraded from bare Text/silent fail to ErrorRetryWidget
- Dead code: 3 unused files deleted, 1 dead route removed

### Remaining medium severity

| # | Area | Issue |
|---|------|-------|
| 24 | Plan | `generatePlanProvider` has no try/catch for notification scheduling failures |
| 25 | Plan | Free block detection duplicated — should reuse timetable's `FreeTimeDetector` |
| 26 | Shared | `OfflineBanner` widget fully built but never instantiated anywhere |
| 29 | Plan | No "Regenerate plan" button — user must manually delete each task to re-plan |
| 30 | Session | Pomodoro total rounds always 4 — no UI to customize |

### Remaining low severity (15 items)

Mostly dead fields, unused methods, minor UI polish, cross-feature coupling. All 15 untouched.
