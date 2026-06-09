# CWA Feature — Complete Flow Description

## Overview

The CWA (Cumulative Weighted Average) feature is the academic grade-tracking core of CampusIQ. It lets students plan their current semester, track projected CWA, import past result slips via AI vision, and see their true cumulative CWA across all completed semesters.

The feature lives under `lib/features/cwa/` and follows the architecture rule: `data/` → `domain/` → `presentation/` (screens, widgets, providers).

### Two Modes

The CWA screen has a toggle at the top switching between two views:

| Mode | Purpose | Data source |
|---|---|---|
| **This Semester** | Plan current courses and project your semester CWA | `CourseModel` (Isar, filtered by active semester key) |
| **Overall CWA/CGPA** | See your true cumulative CWA across all history | `PastSemesterModel` + `CourseModel` combined |

The toggle state is per-session only (not persisted) — it resets to "This Semester" when the app restarts.

---

## The Active Semester

The "active semester" is a global concept used across CWA, Timetable, and Sessions. It identifies which academic term the student is currently in.

**Identifier format**: `{startYear}-{termSuffix}`
- `2024-Sem1` — First Semester of 2024/2025 academic year
- `2024-Sem2` — Second Semester of 2024/2025
- `2024-Supp` — Supplementary/Resit Semester of 2024/2025

**Where it's stored**: Persisted in `UserPrefsModel.activeSemesterKey` in Isar.

**Changing it**: Tap the "..." menu on the CWA screen → "Change active semester". A dialog lets you pick the academic year and semester (First or Second only — Supplementary is not selectable as an active semester since it's a historical concept).

**How courses are scoped**: `CourseModel` entries are tagged with `semesterKey`. The `coursesProvider` streams only courses matching the active semester. When you change the active semester, the course list changes to show that semester's courses.

---

## Grading System Support

The app supports four grading systems, selectable in Settings:

| System | ID | Score Range | Uses Letter Grades |
|---|---|---|---|
| **CWA (KNUST %)** | `cwa` | 0–100 | No (numeric slider) |
| **GPA 4-point (Ghana)** | `gpa_4pt` | 0–4 | Yes (letter dropdown) |
| **GPA 4-point (GIMPA)** | `gpa_4pt_gimpa` | 0–4 | Yes (letter dropdown) |
| **CGPA 5-point (Ghana)** | `cgpa_5pt` | 0–5 | Yes (letter dropdown) |

The grading system affects:
- Labels ("Projected CWA" vs "Projected GPA")
- Score input UI (slider 0–100 vs letter grade dropdown)
- Score clamping and formatting
- Letter-to-number mapping for cumulative calculations

When the grading system uses letter grades (`usesLetterGrades: true`), the score input becomes a `GradeValueDropdown` instead of a numeric slider.

---

## CWA Calculation Logic

### Pure calculation (`CwaCalculator`)

```
CWA = Σ(creditHours × score) / Σ(creditHours)
```

- `calculate(pairs)` — weighted average of a single set of courses
- `gap(projected, target)` — `target - projected` (positive = below target)
- `highestImpactCourseIndices(pairs)` — finds courses with the most credits (for "High Impact" badge in UI)
- `whatIf(courses, index, newScore)` — simulates CWA if one course's score changes
- `calculateCumulative(pastSemesters, currentCourses)` — flattens all past + current pairs and calculates

### KNUST grade mapping

| Grade | Numeric midpoint |
|---|---|
| A (80–100) | 85 |
| B (70–79) | 75 |
| C (60–69) | 65 |
| D (50–59) | 55 |
| F (0–49) | 45 |

When only a letter grade is known (no exact mark), the midpoint is used. This is flagged with a warning icon in the UI because it's less accurate than using the exact mark.

---

## Flow 1: This Semester (Semester Mode)

### 1a. Adding a Course

**Empty state**: The semester view shows a "Next step" card suggesting the user add courses or import a registration slip.

**Add Course sheet** (`AddCourseSheet`): A bottom modal with:
- Course code (required, auto-uppercased, e.g., "COE 456")
- Course name (required)
- Credit hours slider (1–12, defaults to 3)
- Expected score: slider (0–100 for CWA) or grade dropdown (for GPA systems)

The sheet validates all fields. On submit, a `CourseModel` is created with the active `semesterKey` and persisted to Isar via `CwaRepository.addCourse()`. The live stream re-emits, the course list updates, and the projected CWA hero bar recalculates.

**Editing**: Tap the "..." menu on any course card → "Edit". The same sheet opens pre-filled with the existing course data. On save, `CwaRepository.updateCourse()` updates the record in-place.

**Deleting**: "..." → "Delete" → confirmation dialog → `CwaRepository.deleteCourse(id)`.

### 1b. Course Cards

Each course in the list shows:
- **Course code** (bold, primary color) with optional "High Impact" badge
- **Course name** (2-line max)
- **Expected score** with letter grade if applicable (e.g., "85.00% · A")
- **Credit hours**
- **Expand toggle** ("tune" icon) to reveal the score slider

**Slider behaviour**: When expanded, a `Slider` (or `GradeValueDropdown` for letter-grade systems) lets the user adjust the expected score. During drag, the hero bar updates live via `inFlightScoreAdjustmentsProvider` (an in-memory map of course ID → temporary score). On drag end, the adjustment is removed from in-flight and the course is persisted to Isar with the new score.

This two-phase approach (in-memory during drag, persist on release) avoids writing to Isar on every slider frame.

### 1c. Hero Bar (Semester Summary Header)

A pinned sliver header that collapses as you scroll:

**Expanded state** (308px):
- Large CWA hero gauge showing projected CWA vs target
- Gap indicator ("On track" or "Gap X.XX")
- Quick stats: course count, credit total
- Mini cumulative snapshot card showing overall CWA and total credits

**Collapsed state** (96px, pinned):
- Two compact metric cards side by side: Semester CWA + Cumulative CWA
- Each shows score, gap label, and icon

### 1d. Import Registration Slip

From the "Import" button on the CWA screen (semester mode), the user chooses:
1. **Take Photo** — camera capture
2. **Upload Image** — gallery pick
3. **Choose PDF** — file picker
4. **Enter Manually** — goes to manual entry screen (semester mode)

The first three options go to `RegistrationSlipImportScreen`, which:
1. Opens the file/image picker
2. Sends the image/PDF to an AI vision endpoint (`registration_slip_parser.dart`)
3. AI extracts: academic year, semester, programme, level, and course list (code, name, credits)
4. Shows a **review screen** where each course can be toggled on/off, credits and expected score adjusted
5. On confirm, each selected course is saved as a `CourseModel` with the active semester key

The import also parses the semester identity from the slip header (academic year, semester number, level, programme) so the user doesn't have to type it.

### 1e. Completing a Semester

When courses have been added and the semester is ending, the user taps **"Save Final Results"** at the bottom of the course list. This opens `CompleteSemesterScreen`:

**Two paths**:

1. **Save Official Results & Move On** (primary button):
   - User enters the actual mark/grade for each course
   - Validates that all courses have marks
   - Shows confirmation dialog
   - Creates a `PastSemesterModel` with all course entries (exact marks, derived grades)
   - Calls `PastResultRepository.transitionSemester()` which atomically:
     - Saves the past semester record
     - Deletes all current `CourseModel` entries for this semester
     - Advances `activeSemesterKey` to the next semester
   - Returns the new semester label to display as a snackbar

2. **Start Next Semester Without Results Yet** (secondary button):
   - For when official results aren't out but the student needs to move to the next semester
   - Archives courses as a `PastSemesterModel` with `isPendingResults: true`
   - Each course entry gets `isProjectedMark: true` (marked as a placeholder)
   - Same atomic transition (save past + clear current + advance semester)
   - The pending semester appears in the cumulative view with an orange "Awaiting official marks" badge

**Next semester auto-advancement**: The app automatically picks the logical next semester (First → Second within the same year, Second → First of the next year). The user can override this with dropdown pickers on the Complete Semester screen.

---

## Flow 2: Overall CWA (Cumulative Mode)

### 2a. Getting Data Into Cumulative

The cumulative view needs past semester data. There are **four paths** to populate it:

1. **Import result slips** (AI vision) — camera/gallery/PDF of official result slips
2. **Manual entry (cumulative mode)** — type in courses from past semesters
3. **Manual academic baseline** — enter just your current cumulative CWA and total credits as a shortcut
4. **Completing a semester** (from section 1e) — archives current courses as past results

### 2b. Import Result Slip (Cumulative Mode)

From the "Import" button on the CWA screen (cumulative mode), or from the "Add Semester" FAB on the Past Semesters screen:

`ResultSlipImportScreen` has a multi-step wizard:

1. **Idle** — choose camera/gallery/PDF
2. **Picking/Parsing** — file picker opens, then AI vision endpoint (`result_slip_parser.dart`) processes the slip. The AI extracts:
   - Header metadata: academic year start, semester number (1/2/3), level, programme
   - Course table: code, name, credit hours, mark, grade for every row
   - Summary table: semester CWA, cumulative CWA, cumulative credits calc, cumulative weighted marks
3. **Labelling** ("Which semester is this?") — the parsed metadata is pre-filled. User confirms or corrects the academic year, semester type (First/Second/Supplementary), level, and programme. A "Saved as" preview shows the final label.
4. **Reviewing** — all parsed courses shown in a list. User can:
   - Toggle courses on/off (checkbox) to select which to import
   - Edit credit hours (stepper 1–12)
   - Edit grade (dropdown) and mark (text field)
   - See a warning if any course rows couldn't be parsed ("X courses could not be read cleanly")
   - Add missing courses manually via a bottom sheet
   - See reported semester CWA and cumulative CWA from the slip summary
5. **Saving** — progress indicator while writing to Isar
6. **Done** — success screen with course count, label, and prompt to switch to Cumulative view
7. **Error** — retry option

**Duplicate detection**: Before saving, the import checks if a `PastSemesterModel` with the same `semesterKey` already exists. If so, it asks whether to replace it (prevents double-counting).

### 2c. Manual Entry (Cumulative Mode)

`CwaManualEntryScreen` has a mode switcher at the top: **Semester** / **Cumulative**.

In **Cumulative mode**, the user fills in:

**Semester Information section**:
- Academic year dropdown (2023/2024 through 2026/2027)
- Semester dropdown: First Semester, Second Semester, or **Supplementary Semester**
- Programme name (free text, e.g., "Civil Engineering")
- Level dropdown (100, 200, 300, 400, 500)

When **Supplementary Semester** is selected, a helper note explains: "Use this for resits, failed courses, deferred papers, or missing-credit results."

**Courses section**: Same as semester mode — add courses with code, title, credits, and score. The "+ Add Another Course" button appends new rows.

**Live Summary section**: Shows courses added count, total credits, and estimated CWA — updates on every keystroke.

**Save behaviour**: In cumulative mode, saving creates a `PastSemesterModel` (not `CourseModel`). The semester label is constructed as:
```
{Academic Year} • {Semester} • L{Level} • {Programme}
e.g., "2024/2025 • Supplementary Semester • L300 • Civil Engineering"
```

The semester key is built as `{startYear}-Supp` for supplementary, or `{startYear}-Sem{1|2}` for regular semesters.

If a record with the same semester key already exists, the user is prompted to replace it.

### 2d. Manual Academic Baseline

A shortcut for students who know their current cumulative CWA but haven't imported individual result slips.

Accessible from the cumulative view's "Next step" card → "Enter Current CWA/CGPA".

A bottom sheet asks for:
- Current cumulative CWA/GPA (numeric)
- Completed credits so far (numeric)

This creates a `ManualAcademicBaseline` stored in `UserPrefsModel` (not as a `PastSemesterModel`). The cumulative calculation uses it as a starting point:
```
Cumulative = (baseline.score × baseline.credits + currentWeighted) / (baseline.credits + currentCredits)
```

If past semesters exist, the manual baseline is ignored in favour of the actual records.

### 2e. Cumulative View Layout

The cumulative view shows:

1. **CWA Overview Panel** — large hero gauge showing your cumulative CWA vs target, with quick stats (semester records count, total credits)
2. **Next Step card** — contextual guidance:
   - If manual baseline exists but no past semesters: "Edit Starting CWA" + "Import Results"
   - If past semesters exist: "Open History" to review saved semesters
   - If no data: "Import Results" + "Enter Current CWA"
3. **Semester Progression card** (if past semesters exist) — shows a sparkline of semester-by-semester CWA, a "Latest cumulative move" delta, and a list of semester rows each showing semester label, semester CWA, cumulative CWA after that semester, and the change from the previous semester
4. **Pending results warning** (if any semester has `isPendingResults: true`) — explains that estimates are included and shows the "official recorded" CWA (excluding pending)
5. **Academic history section** — collapsible cards for each past semester showing:
   - Semester label
   - Course count and optional slip-reported CWA
   - Semester CWA badge
   - Expand to see individual courses with marks, scores, grades, and credits
6. **Current semester section** — read-only list of current CourseModel entries (informational, linking back to the Semester view)
7. **"Add Semester" button** — navigates to the Past Semesters history screen

### 2f. How Cumulative CWA Is Calculated

The `cumulativeCwaProvider` uses a three-tier priority strategy:

1. **Slip totals (best)**: If the latest chronological semester has `cumulativeWeightedMarks` and `cumulativeCreditsCalc` from the slip summary table, use those directly. KNUST's own running totals are the most accurate — they account for any nuances in the official calculation. Then add the current semester's courses on top.

2. **Historical slip totals**: If any past semester has slip-reported cumulative totals, start from there and add subsequent semester courses individually.

3. **Reconstruction (fallback)**: Sum up all individual course (creditHours × score) pairs across every past semester and the current semester, then divide by total credits. Less accurate (midpoint estimates for letter-only grades, possible rounding differences).

**Deduplication**: The current semester's courses are only included in the cumulative total if no `PastSemesterModel` with the same `semesterKey` already exists. This prevents counting the same semester twice if it was both projected (CourseModel) and archived (PastSemesterModel).

---

## Supplementary Semesters

Supplementary (resit) semesters are a first-class concept in the data model:

- `AcademicTermType.supplementarySemester` — sort order 3 (after Second Semester)
- Semester key: `{year}-Supp` (e.g., `2024-Supp`)
- Display label: `2024/2025 • Supplementary Semester`
- Available in all semester pickers: manual entry (cumulative mode), result slip import labelling, and the past semesters filter
- A "Supplementary" badge appears on semester cards in the history view

**Use cases**: Resits, failed courses, deferred papers, or any results that arrive outside the normal First/Second semester cycle.

Supplementary semesters are **not selectable as the active semester** (only First and Second are available in the active semester dialog), because the active semester represents the current ongoing term.

---

## Past Semesters Screen (Result History)

Accessed from the "..." menu → "Manage saved semesters" (cumulative mode only), or via go_router named route `cwa-history`.

Shows all past semesters as cards sorted chronologically (by semester key, then by creation date). Each card shows:
- Semester label (expandable)
- Course count and optional reported CWA
- Computed semester CWA badge
- Supplementary badge (if applicable)
- "Awaiting official marks" badge (if `isPendingResults: true`)
- "Update Results" button (if pending) → opens card to reveal editable course rows

**Editable course rows**: Each course in an expanded card shows:
- Course code (bold, primary color)
- Course name
- Mark input field (text, orange-tinted if projected)
- Credit hours stepper (± buttons, 1–12)
- Grade display: derived from mark (read-only pill) or editable dropdown (if no mark)

Changes auto-save on every edit (mark change, credit change).

**Finalizing pending results**: When a pending semester is expanded, a "Finalize official results?" confirmation becomes available. It's blocked if any course still has a `null` mark or `isProjectedMark: true`. A red banner lists exactly which courses need attention. Once all marks are real and non-null, finalizing sets `isPendingResults = false`.

**Deleting**: Each semester card has a trash icon → confirmation dialog → removes the record from Isar. This affects cumulative CWA.

**Adding**: The FAB "Add Semester" navigates to the result slip import screen.

---

## Draft Saving (Manual Entry)

The manual entry screen supports draft persistence:

- **Save draft** button in the app bar → serializes the entire form state (mode, academic year, semester label, programme, level, and all course entries) as JSON and saves it to `UserPrefsModel.manualCwaDraftJson` via `CwaPrefsRepository`.
- **Auto-restore**: When the manual entry screen opens, it checks for a saved draft. If found, it restores the mode, metadata, and all course rows. A snackbar confirms "Draft restored."
- **Auto-clear**: On successful save, the draft is cleared.

This prevents data loss if the user navigates away mid-entry or the app is killed.

---

## Data Model Summary

### CourseModel (Isar collection — current/projected courses)
| Field | Type | Purpose |
|---|---|---|
| `id` | `Id` (auto-increment) | Primary key |
| `name` | `String` | Course name |
| `code` | `String` | Course code (e.g., "COE 456") |
| `creditHours` | `double` | Credit/contact hours |
| `expectedScore` | `double` | Projected/expected score (0–100 or 0–4/0–5) |
| `semesterKey` | `String` | Active semester identifier (e.g., "2024-Sem2") |
| `gradingSystemId` | `String` | Grading system used when created |
| `createdAt` | `DateTime` | Creation timestamp |
| `examDate` | `DateTime?` | Scheduled exam date (optional) |

### PastSemesterModel (Isar collection — completed/past semesters)
| Field | Type | Purpose |
|---|---|---|
| `id` | `Id` (auto-increment) | Primary key |
| `semesterLabel` | `String` | Human-readable label (e.g., "2024/2025 • First Semester • L300 • CE") |
| `semesterKey` | `String?` | Stable identifier (e.g., "2024-Sem1", "2024-Supp") |
| `gradingSystemId` | `String` | Grading system used |
| `courses` | `List<PastCourseEntry>` | Embedded course entries |
| `reportedSemesterCwa` | `double?` | What the slip says for semester CWA |
| `reportedCumulativeCwa` | `double?` | What the slip says for cumulative CWA |
| `isPendingResults` | `bool` | True if archived before official results |
| `cumulativeCreditsCalc` | `double?` | Credits Calc from cumulative column of slip |
| `cumulativeWeightedMarks` | `double?` | Weighted Marks from cumulative column of slip |
| `createdAt` | `DateTime` | Creation timestamp |

### PastCourseEntry (embedded in PastSemesterModel)
| Field | Type | Purpose |
|---|---|---|
| `courseCode` | `String` | Course code |
| `courseName` | `String` | Course name |
| `creditHours` | `double` | Credit hours |
| `grade` | `String` | Letter grade (A/B/C/D/F) |
| `mark` | `double?` | Exact numeric mark (null if only grade known) |
| `isProjectedMark` | `bool` | True if mark is a placeholder |

The `score` getter on `PastCourseEntry` returns `mark` if available, otherwise falls back to the grade midpoint (A=85, B=75, C=65, D=55, F=45).

---

## Repository Layer

### CwaRepository
- `watchCourses(semesterKey)` — live stream of courses for a semester
- `addCourse(course)` — insert
- `updateCourse(course)` — update (uses same `put`, Isar upserts by ID)
- `deleteCourse(id)` — delete by ID
- `courseExistsByCode(code, semesterKey)` — duplicate check before manual save

### PastResultRepository
- `watchAll()` — live stream of all past semesters, sorted by `createdAt`
- `getAll()` — one-shot fetch
- `findBySemesterKey(key)` — lookup by semester key for duplicate detection
- `add(model)` — insert
- `update(model)` — update
- `replaceForSemesterKey(key, model)` — atomically delete existing + insert new for the same key
- `delete(id)` — delete by ID
- `transitionSemester(...)` — atomic transaction: save past semester, delete current courses, advance active semester key

---

## AI Vision Parsing

Two parsers exist for the two import flows:

1. **Registration Slip Parser** (`registration_slip_parser.dart`) — for semester mode imports. Extracts course list (code, name, credits) from a registration slip. Simpler prompt, fewer fields.

2. **Result Slip Parser** (`result_slip_parser.dart`) — for cumulative mode imports. Full extraction including marks, grades, semester CWA, cumulative CWA, and cumulative totals.

Both use the same AI proxy endpoint (`AiProxyConfig.openaiVisionEndpoint`) with base64-encoded image/PDF data. The prompt instructs the model to return only JSON, no markdown, no explanation. Temperature is 0.1 for deterministic extraction.

**Error handling**: Rows with missing code/name are counted as `skippedCourseCount` and reported in the review UI. The user can manually add any missed courses.

**Length limit**: If the AI response hits the token limit (`finishReason == 'length'`), the parser throws a specific error suggesting the user split the slip into two halves.

---

## Providers Summary

All providers are in `cwa_provider.dart`:

| Provider | Type | What it provides |
|---|---|---|
| `gradingSystemProvider` | `Provider<GradingSystem>` | Current grading system object |
| `activeSemesterProvider` | `Provider<String>` | Current active semester key |
| `coursesProvider` | `StreamProvider<List<CourseModel>>` | Live course list for active semester |
| `targetCwaProvider` | `Provider<double>` | Current target CWA |
| `projectedCwaProvider` | `Provider<double>` | Semester CWA (with in-flight slider adjustments) |
| `cwaGapProvider` | `Provider<double>` | Target − projected gap |
| `pastSemestersProvider` | `StreamProvider<List<PastSemesterModel>>` | All past semesters (sorted, legacy filtered out) |
| `pendingPastSemestersProvider` | `Provider<List<PastSemesterModel>>` | Only pending semesters |
| `officialPastSemestersProvider` | `Provider<List<PastSemesterModel>>` | Only finalized semesters |
| `cumulativeCwaProvider` | `Provider<double>` | Cumulative CWA (all history + current) |
| `officialRecordedCwaProvider` | `Provider<double>` | Cumulative from finalized semesters only |
| `totalCreditsProvider` | `Provider<double>` | Total credits across all history |
| `cumulativeGapProvider` | `Provider<double>` | Target − cumulative gap |
| `semesterProgressionProvider` | `Provider<List<SemesterProgressionEntry>>` | Semester-by-semester CWA with deltas |
| `manualAcademicBaselineProvider` | `StreamProvider<ManualAcademicBaseline?>` | Current manual baseline |
| `inFlightScoreAdjustmentsProvider` | `StateProvider<Map<int, double>>` | Temp scores during slider drag |
| `cwaViewModeProvider` | `StateProvider<CwaViewMode>` | Semester vs Cumulative toggle |
| `cwaRepositoryProvider` | `Provider<CwaRepository?>` | CWA data access |
| `pastResultRepositoryProvider` | `Provider<PastResultRepository?>` | Past results data access |
| `cwaPrefsRepositoryProvider` | `Provider<UserPrefsRepository?>` | User preferences access |

---

## Navigation & Routes

| Screen | Route | How reached |
|---|---|---|
| CWA main screen | `/cwa` (shell tab) | Bottom nav pill |
| Manual entry | `/cwa/manual-entry?mode=semester\|cumulative` | Import sheet → Enter Manually |
| Registration slip import | `cwa-import-registration` (named) | Import sheet → take photo/upload/PDF (semester mode) |
| Result slip import | `cwa-import-results` (named) | Import sheet → take photo/upload/PDF (cumulative mode) |
| Past semesters history | `cwa-history` (named) | "..." menu → Manage saved semesters |
| Complete semester | Direct `Navigator.push` | "Save Final Results" button on semester view |

Note: `CompleteSemesterScreen` uses direct navigation (not go_router) because it requires in-memory data (the list of courses being completed).
