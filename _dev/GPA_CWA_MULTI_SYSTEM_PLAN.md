# Multi-System Grade Support — Feature Plan

**Status:** Planning (no code changes yet)
**Date:** 2026-05-11

---

## Problem

CampusIQ is currently hardcoded to KNUST's CWA system (0–100 weighted average). Other Ghanaian universities use different grading systems:

| System | Example schools | Scale | Input type |
|---|---|---|---|
| CWA | KNUST | 0–100 | Percentage score per course |
| GPA (4.0 scale) | University of Ghana (Legon) | 0.0–4.0 | Grade letter → point |
| GPA (5.0 scale) | Unknown (to research) | 0.0–5.0 | Grade letter → point |
| CGPA | Variant naming | Same as GPA | Cumulative GPA across semesters |

A student from Legon opening CampusIQ today sees "CWA" everywhere — the terminology and scoring scale are wrong for them.

## Goal

Add a **per-student grading system setting** so the app adapts its terminology, input UI, score ranges, and grade mappings to the student's university system.

---

## Design Decisions (confirmed)

| Decision | Choice | Rationale |
|---|---|---|
| Scope | Per-student setting | Set once during onboarding, stored in `UserPrefsModel` |
| Past semester conversion | Deferred | Not needed for v1; past semesters stay in their original scale |
| University → system mapping | TBD | Need to research which schools use which system |
| Input method for GPA schools | TBD | Need to check what Ghanaian GPA result slips actually show (letter grades? points? percentages?) |

---

## Core Abstraction: `GradingSystem`

The entire feature hinges on one config object. Every place in the codebase that assumes "CWA 0–100" gets parameterised by this:

```dart
class GradingSystem {
  final String id;           // "cwa", "gpa_4pt", "gpa_5pt"
  final String label;        // "CWA", "GPA", "CGPA"
  final double minScore;     // 0
  final double maxScore;     // 100 for CWA, 4.0 for GPA
  final String scoreUnit;    // "%" or "pts"
  final GradeScale gradeScale; // maps A→4.0, B→3.0, etc. (null for CWA)
  final double passingThreshold;
  final double distinctionThreshold;
  final bool usesLetterGrades; // true for GPA, false for CWA
}

class GradeScale {
  final Map<String, double> letterToPoint; // {"A+": 4.0, "A": 4.0, "B+": 3.5, ...}
  final Map<double, String> pointToLetter; // 4.0 → "A", 3.5 → "B+", ...
  final List<String> availableGrades;      // ["A+", "A", "B+", ...] for dropdowns
}
```

### Why the internal score is always numeric

`CourseModel.expectedScore` stays a `double`. Whether the student enters "75%" or "A (4.0)", it's stored as a number. The `GradingSystem` handles display conversion:

- CWA: score 75 → display "75%"
- GPA: score 3.5 → display "3.5 pts (B+)"

This means the calculator, cumulative logic, Complete Semester flow, and all analytics work unchanged — they're already operating on numbers.

---

## What Changes (by layer)

### 1. Data layer

| File | Change |
|---|---|
| `UserPrefsModel` | Add `gradingSystemId` field (String, defaults to `"cwa"`) |
| `CourseModel` | No schema change — `expectedScore` stays `double` |
| `PastSemesterModel` | No schema change |
| New: `lib/core/domain/grading_system.dart` | `GradingSystem` value object + built-in presets (`GradingSystem.cwa`, `GradingSystem.gpa4pt`, `GradingSystem.gpa5pt`) |
| New: `lib/core/domain/grade_scale.dart` | `GradeScale` value object with letter↔point conversion |

### 2. Domain layer

| File | Change |
|---|---|
| `cwa_calculator.dart` | Rename to `grade_calculator.dart`. Same math, accepts `GradingSystem` for label/scale metadata. Add `scoreToGradeLetter(double score)` helper. |
| All callers | Update imports from `cwa_calculator` → `grade_calculator` |

### 3. Presentation layer — CWA screen

| File | Change |
|---|---|
| `cwa_screen.dart` | AppBar title changes: "CWA" → grading system label. Target dialog range adapts (0–100 → 0.0–4.0). |
| `cwa_summary_bar.dart` | CWA → dynamic label. "pts" unit for GPA. |
| `course_card.dart` | Score slider range adapts to grading system. For GPA systems: show grade letter next to score (e.g. "3.5 · B+"). |
| `add_course_sheet.dart` | For GPA systems: replace score slider with **grade dropdown** (A+, A, B+, ...). Optional: still allow exact point entry as secondary field. |
| `complete_semester_screen.dart` | Grade dropdown already exists here (it's already grade-first). Just wire it to the correct `GradeScale`. |
| `cwa_manual_entry_screen.dart` | Same — grade dropdown adapts to the grading system's letter list. |
| `registration_slip_import_screen.dart` | Expected score field adapts: slider for CWA, dropdown for GPA. |
| `result_slip_import_screen.dart` | Grade dropdown already exists — wire to `GradeScale`. |
| `past_semesters_screen.dart` | Grade dropdown wired to `GradeScale`. |

### 4. Presentation layer — other screens

| Screen | Change |
|---|---|
| Home (Today) — Academic Pulse | "CWA" tile → dynamic label (e.g. "GPA" or "CWA") |
| Course Hub — Overview | CWA impact card adapts label and scale |
| Insights | Any CWA reference in insight text → parameterised |
| Weekly Review | Same |
| Streak | Unchanged (streaks don't reference grading system) |

### 5. Onboarding

The onboarding flow (planned in `PRE_LAUNCH_CHECKLIST.md`, item 5) gains a step:

```
Welcome → University → Programme → Grading System (auto-selected, editable) → Target → Notifications
```

The university picker drives a default `GradingSystem`:
- KNUST → CWA
- Legon → GPA (4.0)
- UCC → (research needed)
- etc.

Student can override the default if the mapping is wrong.

### 6. Settings

A new row in Settings: **"Grading system"** → opens a picker showing available systems. Changing it updates all CWA/GPA labels app-wide.

---

## What Does NOT Change

| Area | Why |
|---|---|
| `CwaCalculator` math | Weighted average is identical across systems |
| Cumulative calculation | Same flat-pool + weighted-average logic |
| Isar schemas (except `UserPrefsModel`) | No new collections needed |
| Complete Semester flow | Already grade-first, just wire `GradeScale` |
| AI prompts | Already inject context; just swap "CWA" → grading system label |
| Streak, Sessions, Timetable | Unrelated to grading system |
| All analytics/insight maths | Operate on numeric scores, unchanged |

---

## Implementation Sequence

### Step 1 — Foundation (no visible changes)
1. Create `GradingSystem` + `GradeScale` value objects in `lib/core/domain/`
2. Add built-in presets: `GradingSystem.cwa`, `GradingSystem.gpa4pt`, `GradingSystem.gpa5pt`
3. Add `gradingSystemId` to `UserPrefsModel` (default `"cwa"`)
4. Create a `gradingSystemProvider` that reads from `UserPrefsModel`
5. Rename `CwaCalculator` → `GradeCalculator` (same math, new name)

### Step 2 — CWA screen dynamic labels
1. `cwa_summary_bar.dart`: "CWA" → `gradingSystem.label`
2. Target slider: 0–100 → `gradingSystem.minScore`–`gradingSystem.maxScore`
3. Home Academic Pulse tile label adapts
4. Course card score display adapts (show grade letter for GPA systems)

### Step 3 — Grade dropdown for GPA input
1. `add_course_sheet.dart`: conditional — slider for CWA, grade dropdown for GPA
2. `registration_slip_import_screen.dart`: same conditional logic
3. Wire existing grade dropdowns (Complete Semester, Past Semesters, Result Slip Import) to the selected `GradeScale`

### Step 4 — Onboarding + Settings
1. Onboarding: university picker auto-selects grading system
2. Settings: grading system picker row
3. Edge case: switching systems mid-use — show a one-time explanation dialog ("Your existing courses will keep their scores, but labels will change")

### Step 5 — Polish
1. Audit every screen for hardcoded "CWA" strings → replace with `gradingSystem.label`
2. Verify cumulative/semester/progression views with GPA data
3. Test: create data in CWA mode → switch to GPA → verify nothing breaks
4. Test: complete a semester in GPA mode → cumulative view shows correct GPA

---

## Open Questions (to resolve before coding)

1. **What do GPA result slips look like in Ghana?** Do they show letter grades (A, B+), grade points (3.5), or percentages? This determines whether the primary input should be a dropdown or a slider.
2. **Which schools use which system?** Need a mapping of Ghanaian universities → grading system. Starting list:
   - KNUST — CWA (confirmed)
   - University of Ghana (Legon) — GPA 4.0 (to confirm)
   - UCC — ?
   - UDS — ?
   - UEW — ?
   - Ashesi — ?
   - GIMPA — ?
3. **Does "CGPA" ever differ from "GPA" in Ghanaian usage?** In some countries CGPA means the cumulative average across all semesters vs GPA meaning per-semester. In practice the math is the same — only the label changes. Need to confirm whether any Ghanaian school distinguishes them.
4. **For GPA systems, are plus/minus grades used?** (A+, B-, etc.) Some 4.0 scales have them, some don't. This affects the `GradeScale` mapping.
5. **Should the distinction/passing thresholds differ per university?** e.g., Legon might consider 3.5 distinction while KNUST considers 70 distinction. This could be a per-university config or kept simple as a grading-system default.

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|---|---|---|
| Renaming `CwaCalculator` breaks something | Low | It's a pure Dart class with no Flutter deps; find-all-references is exhaustive |
| Students don't understand the grading system picker | Medium | Onboarding auto-selects based on university; the picker is a power-user escape hatch |
| GPA input method is wrong for Ghana | Medium | Research before building Step 3; if unsure, support both dropdown AND slider |
| Hardcoded "CWA" strings scattered everywhere | High (certain) | Grep audit in Step 5 will catch them; the compiler won't help since strings aren't typed |
| Switching systems mid-semester corrupts data | Low | Internal scores stay numeric; only display labels change |

---

## Estimated Scope

| Step | Complexity | Files touched |
|---|---|---|
| Step 1 — Foundation | Small | ~5 new + 3 modified |
| Step 2 — Dynamic labels | Medium | ~8 modified |
| Step 3 — Grade dropdown | Medium | ~5 modified |
| Step 4 — Onboarding + Settings | Medium | ~5 modified |
| Step 5 — Polish + audit | Small | ~15 modified (mostly string replacements) |

Total: roughly 30–40 files touched, ~3–5 new files. About the same scale as Phase 15.6 (CWA flow gap fixes).

---

## References

- Existing calculator: `lib/features/cwa/domain/cwa_calculator.dart`
- Existing grade handling: `lib/features/cwa/domain/past_course_result.dart` (letter→score mapping already exists for A–F)
- Semester completion flow: `lib/features/cwa/presentation/screens/complete_semester_screen.dart` (grade dropdown already built)
- Onboarding plan: `_dev/PRE_LAUNCH_CHECKLIST.md`, Part 3, item A
- User prefs: `lib/core/data/models/user_prefs_model.dart`
