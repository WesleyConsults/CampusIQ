# CampusIQ — Phase 1 Completion Report

**Date:** 2026-04-05
**Phase:** 1 — CWA Target Planner
**Status:** Complete

---

## What Was Built

A fully functional CWA (Cumulative Weighted Average) Target Planner for Ghanaian university students, built Android-first with Flutter.

### Features delivered

| Feature | Description |
|---|---|
| Add / edit / delete courses | Bottom sheet form with course code, name, credit hours, expected score |
| Live CWA calculation | Updates instantly as scores change via Isar stream |
| Score slider per course | Drag to adjust expected score; CWA recalculates in real time |
| CWA summary bar | Shows projected CWA, target CWA, and gap |
| High-impact badge | Flags the course with the most credit hours |
| Target CWA dialog | Set a personal target; gap indicator updates accordingly |
| Isar persistence | Courses survive hot restart and app relaunch |
| "What-if" logic | `CwaCalculator.whatIf()` available for future scenario screens |

---

## Architecture

Follows the feature-first layered architecture defined in CLAUDE.md:

```
lib/
├── main.dart                          — ProviderScope entry point
├── app.dart                           — MaterialApp.router + theme
├── core/
│   ├── constants/app_constants.dart   — App-wide constants
│   ├── providers/isar_provider.dart   — Singleton Isar FutureProvider
│   ├── router/app_router.dart         — GoRouter (currently /cwa only)
│   └── theme/app_theme.dart           — Material 3 theme, Inter font
├── features/
│   └── cwa/
│       ├── data/
│       │   ├── models/course_model.dart       — Isar @collection schema
│       │   └── repositories/cwa_repository.dart — CRUD + live stream
│       ├── domain/
│       │   └── cwa_calculator.dart            — Pure Dart, no Flutter deps
│       └── presentation/
│           ├── providers/cwa_provider.dart    — Riverpod stream/computed providers
│           ├── screens/cwa_screen.dart        — ConsumerWidget main screen
│           └── widgets/
│               ├── add_course_sheet.dart      — Stateful bottom sheet form
│               ├── course_card.dart           — Card with inline score slider
│               └── cwa_summary_bar.dart       — Projected / target / gap display
└── shared/
    ├── extensions/double_extensions.dart      — toCwaString(), toPercentString()
    └── widgets/empty_state_widget.dart        — Placeholder for Phase 2
```

---

## Dependencies

### Runtime

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.5.1 | State management |
| riverpod_annotation | ^2.3.5 | Riverpod annotations |
| isar | ^3.1.0+1 | Local database |
| isar_flutter_libs | ^3.1.0+1 | Isar native binaries |
| path_provider | ^2.1.3 | Database directory |
| go_router | ^14.2.0 | Navigation |
| google_fonts | ^6.2.1 | Inter typeface |
| flutter_animate | ^4.5.0 | (Available, unused in Phase 1) |
| intl | ^0.19.0 | Number/date formatting |

### Dev

| Package | Version | Purpose |
|---|---|---|
| build_runner | ^2.4.11 | Code generation runner |
| isar_generator | ^3.1.0+1 | Isar schema codegen |
| riverpod_generator | ^2.3.9 | Riverpod codegen (pinned, see Issues) |

---

## Issues Resolved During Build

### 1. Dependency conflict — `isar_generator` vs `riverpod_generator`

**Problem:** `isar_generator 3.x` requires `analyzer >=4.6.0 <6.0.0`. `riverpod_generator >=2.4.2` and all versions of `riverpod_lint` require `analyzer ^6.x`. These are mutually exclusive.

**Fix:** Pinned `riverpod_generator: ^2.3.9` (resolved to 2.4.0, just below the conflict threshold). Removed `riverpod_lint` and `custom_lint` from dev_dependencies — they are optional lint tools and provide no build-time functionality.

---

### 2. Dart 3.11 dot-shorthand syntax in generated `main.dart`

**Problem:** Flutter SDK generated `main.dart` using Dart 3.11 dot-shorthand syntax (`.fromSeed(...)`, `.center`) which the pinned `analyzer 5.13.0` cannot parse, causing build_runner to fail.

**Fix:** Expanded to full class-qualified form: `ColorScheme.fromSeed(...)`, `MainAxisAlignment.center`.

---

### 3. `CardTheme` → `CardThemeData` API change

**Problem:** `ThemeData` in this Flutter SDK version expects `CardThemeData` not `CardTheme` for the `cardTheme` property.

**Fix:** Changed `CardTheme(...)` to `CardThemeData(...)` in `app_theme.dart`.

---

### 4. `isar_flutter_libs` namespace error with AGP 8.x

**Problem:** `isar_flutter_libs 3.1.0+1` ships a Groovy `build.gradle` without a `namespace` declaration. AGP 8+ requires every library module to declare a namespace explicitly.

**Fix:** Added a `plugins.withId("com.android.library")` hook in `android/build.gradle.kts` that injects the namespace from the project group before evaluation:

```kotlin
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            if (namespace == null) {
                namespace = project.group.toString()
            }
        }
    }
}
```

An earlier attempt using `afterEvaluate` failed because `evaluationDependsOn(":app")` had already triggered evaluation of sibling projects.

---

### 5. `withOpacity` deprecation

**Problem:** Flutter SDK deprecates `Color.withOpacity()` in favour of `Color.withValues(alpha:)` to avoid precision loss.

**Fix:** Replaced all three occurrences in `course_card.dart` and `cwa_summary_bar.dart`.

---

### 6. Stale widget test referencing deleted `MyApp`

**Problem:** The generated `test/widget_test.dart` still referenced the counter-app `MyApp` class which no longer exists.

**Fix:** Replaced with a no-op placeholder test. Full widget tests are scoped to Phase 2.

---

## What Comes Next (Phase 2+)

| Phase | Feature |
|---|---|
| 2 | Semester switcher + persist target CWA to Isar |
| 3 | Study session tracker |
| 4 | Timetable manager |
| 5 | Streak & habit tracker |

Router stubs for `/timetable`, `/schedule`, `/sessions`, `/streak` are already commented in `app_router.dart`. Isar schemas for those features will follow the same pattern as `CourseModel`.
