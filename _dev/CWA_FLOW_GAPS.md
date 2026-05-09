# CWA Flow — Gaps & Improvements

Documenting issues found in the CWA (Cumulative Weighted Average) feature flow.
Each gap is self-contained and can be tackled independently.

---

## Gap 1 — Active semester is hardcoded

**File**: `lib/features/cwa/presentation/providers/cwa_provider.dart:13`

`activeSemesterProvider` always returns `"2024-Sem2"`. There is no UI to change it.
A student in any other semester cannot use the semester view correctly — all courses are grouped under the wrong semester key.

**What's needed**:
- A mechanism to configure the current semester (academic year + semester number)
- Persist it so it survives app restarts
- A simple picker UI accessible from the CWA screen

---

## Gap 2 — Target CWA resets on every app launch

**File**: `lib/features/cwa/presentation/providers/cwa_provider.dart:30`

`targetCwaProvider` defaults to `70.0` and is stored only in memory. The user sets a target, closes the app, and it's gone.

**What's needed**:
- Persist the target CWA value (e.g., in `UserPrefsModel` or a dedicated field)
- Read it back on app start

---

## Gap 3 — No path from projected courses to real results

**Files**: `cwa_provider.dart`, `course_model.dart`, `past_semester_model.dart`

When a semester ends, the user has a set of `CourseModel` entries with `expectedScore` values.
To record real grades, they must import a result slip or re-enter everything manually from scratch.
The projected courses and the real past semester are two disconnected worlds — there's no "complete this semester" flow.

**What's needed**:
- A "Complete Semester" action that takes the current courses and creates a `PastSemesterModel`
- Pre-fill course codes/names/credits from the existing `CourseModel` entries
- Let the user fill in real grades/marks
- Clear or archive the old `CourseModel` entries after completion
- Advance `activeSemesterProvider` to the next semester

---

## Gap 4 — Semester identification is inconsistent

**Files**: `course_model.dart:15`, `past_semester_model.dart:11`

- `CourseModel` identifies semesters by a simple key: `"2024-Sem2"`
- `PastSemesterModel` uses a freeform label: `"2024/2025 • First Semester • L300 • Computer Engineering"`

There's no way to link a past semester record back to the current courses from that same semester.
If both exist for the same semester, the cumulative view can't deduplicate or cross-reference them.

**What's needed**:
- A consistent semester identifier shared between both models
- Either adopt the freeform label on `CourseModel` or a structured key on `PastSemesterModel`
- Use this identifier to prevent double-counting in cumulative calculations

---

## Gap 5 — Manual entry for past semesters asks for score, not grade

**File**: `lib/features/cwa/presentation/screens/cwa_manual_entry_screen.dart:276-282`

In cumulative mode, the user types a numeric score (0-100) which gets auto-converted to a grade (A-F).
But a student looking at a result slip knows their **grade**, not necessarily the exact mark.
The flow is backwards for the most common entry scenario.

**What's needed**:
- Let the user enter either a grade (dropdown) or an exact mark (optional)
- Grade should be the primary field in cumulative mode
- Score/mark should be an optional refinement

---

## Gap 6 — No duplicate semester detection in cumulative calculation

**File**: `lib/features/cwa/presentation/providers/cwa_provider.dart:78-128`

`cumulativeCwaProvider` includes ALL `PastSemesterModel` entries with no deduplication.
If a user imports the same result slip twice, those courses are double-counted.

**What's needed**:
- A uniqueness check when importing (same semester label + same course codes = likely duplicate)
- Or a warning in the cumulative view when duplicate-like semesters are detected

---

## Gap 7 — Draft saving is a stub

**File**: `lib/features/cwa/presentation/screens/cwa_manual_entry_screen.dart:284`

The "Save draft" button shows "Draft saving is coming in a later phase."
If the user navigates away mid-entry, all work is lost.

**What's needed**:
- Persist the in-progress manual entry form state
- Restore it when the user returns
- Clear the draft on successful save

---

## Gap 8 — Import screens bypass go_router

**Files**: `cwa_screen.dart:66-72`, `cwa_screen.dart:299-306`

`PastSemestersScreen`, `RegistrationSlipImportScreen`, and `ResultSlipImportScreen` use raw `Navigator.push` with `MaterialPageRoute` instead of go_router named routes. They can't be deep-linked.

**What's needed**:
- Register these screens as go_router routes
- Use `context.push()` consistently

---

## Gap 9 — Imported current courses all default to score 70

**File**: `lib/features/cwa/presentation/providers/registration_slip_import_provider.dart`

When importing a registration slip in semester mode, every course gets `expectedScore = 70.0`.
The user must manually adjust each slider individually.

**What's needed**:
- Show the review screen with editable scores before saving
- Or allow bulk-setting a default expected score during import
- Or use a smarter default based on the course level/type

---

## Gap 10 — Credit hours clamped to 1-6

**Files**: Multiple — `AddCourseSheet`, `CwaManualEntryScreen`, `PastSemestersScreen`

Credit hour inputs are universally clamped to 1-6. Some programmes have courses that carry more than 6 credits (e.g., project work, industrial attachment).

**What's needed**:
- Raise or remove the credit hour cap, or make it configurable
- At minimum, raise it to 12

---

## Gap 11 — Silenced parse failures during AI import

**Files**: `registration_slip_parser.dart`, `result_slip_parser.dart`

Malformed entries from the OpenAI vision parser are silently skipped (`catch (_) {}`).
A course missing from the parsed result is invisible to the user during review.

**What's needed**:
- Show a warning count: "X courses could not be parsed"
- Let the user manually add any skipped courses during the review step

---

## Gap 12 — No semester overview or progression

There's no screen that shows all semesters in chronological order with their CWA trend.
The cumulative view lists past semesters but doesn't show a timeline, a trend line, or semester-to-semester change.

**What's needed**:
- A semester timeline in the cumulative view showing CWA progression
- Delta indicators (↑/↓ from previous semester)
- A visual trend (sparkline or small chart)
