# CampusIQ UI Structure Redesign — Codex Implementation Prompt

Use this document as the implementation brief for the CampusIQ UI/navigation redesign.

You are working inside an existing Flutter project for **CampusIQ**, an Android-first academic productivity app for Ghanaian university students. The current app uses:

- Flutter with Material 3
- Riverpod / generator-based providers
- GoRouter for navigation
- Isar for local storage
- A feature-based architecture with `data/`, `domain/`, and `presentation/` layers

Do **not** rewrite the project from scratch. Modify the existing screens, routes, providers, and widgets carefully.

The goal is to make the app feel cleaner, simpler, and more user-friendly by restructuring the main navigation and improving the CWA flow.

---

## Important Product Direction

The new navigation philosophy is:

```text
Today = landing/home base
CWA, Table, Sessions = only bottom navigation items
Top-left Home button = return to Today
Drawer = secondary pages
AI FAB = global assistant
CWA Import = CWA-specific action
Manual entry = full-screen focused form
```

---

## Existing App Concepts To Preserve

Preserve existing app behavior unless this brief explicitly changes it.

Important existing concepts:

- The app currently has a main shell route with a persistent bottom navigation bar.
- The current landing route is likely `/plan`.
- Main top-level screens include:
  - Dashboard / Plan
  - CWA
  - Timetable
  - Sessions
  - AI Chat
  - Streak
  - Insights
  - Settings
  - Weekly Review
  - Subscribe
- The app has a global AI floating action button that opens the main AI chat.
- If a study session is active, a floating mini timer may appear above the shell.
- Course Hub is a full-screen push outside the bottom-nav shell.
- CWA already supports Semester and Cumulative concepts.
- CWA supports registration slip import and past result/history import flows.

Do not remove existing functionality. Reorganize it.

---

# Working Method

Implement this in phases.

After completing each phase:

1. Run formatting.
2. Run static analysis.
3. Run tests if available.
4. Manually verify the key user flow.
5. Stop and report what changed before continuing to the next phase.

Use commands similar to:

```bash
dart format .
flutter analyze
flutter test
```

If the project has custom scripts, use the existing project scripts instead.

Do not continue to the next phase until the current phase is stable.

---

# Phase 0 — Project Discovery And Safety Check

## Goal

Inspect the existing project structure before making changes.

## Tasks

- Locate the GoRouter configuration.
- Locate the main app shell / bottom navigation widget.
- Locate the current Plan/Dashboard screen.
- Locate the CWA screen.
- Locate the Timetable screen.
- Locate the Sessions screen.
- Locate existing CWA import flows.
- Locate existing manual course entry logic, if any.
- Locate global AI FAB implementation.
- Locate active session mini timer implementation.
- Identify existing route paths for:
  - `/plan`
  - `/cwa`
  - `/timetable`
  - `/sessions`
  - `/ai`
  - `/streak`
  - `/insights`
  - `/settings`
  - `/ai/weekly-review`
  - `/subscribe`

## Rules

- Do not delete existing routes unless the route is truly unused.
- Prefer preserving existing route paths to reduce risk.
- If the existing Dashboard route is `/plan`, it may remain `/plan` internally, but the UI should label it as **Today** or **Plan**.
- Do not rename models or database schemas unless absolutely necessary.

## Phase 0 Acceptance Criteria

- You can explain where the app shell is.
- You can explain where routes are defined.
- You can explain which widgets/screens must be changed.
- No functional code changes are required in this phase unless needed for discovery.

---

# Phase 1 — Bottom Navigation Restructure

## Goal

Reduce the bottom navigation to only three destinations:

```text
CWA
Table
Sessions
```

The Today/Dashboard/Plan screen should no longer be a bottom navigation item.

## New Behavior

When the user opens the app:

```text
App launch → Today landing screen
```

From Today, the user can use the bottom nav to enter:

```text
CWA
Table
Sessions
```

When the user is on CWA, Table, or Sessions, they should be able to return to Today using a visible top-left Home button.

## Tasks

### 1. Update bottom nav destinations

Change the persistent bottom navigation to show only:

```text
CWA
Table
Sessions
```

Remove Dashboard/Plan/Today from the bottom nav.

Use clear icons:

- CWA: chart/analytics icon
- Table: calendar/table icon
- Sessions: play/timer/focus icon

### 2. Preserve Today as landing screen

Keep the existing Dashboard/Plan functionality, but treat it as the **Today** landing screen.

Possible internal route options:

```text
/plan
```

or

```text
/today
```

Recommendation:

- Keep `/plan` if it already exists and is used widely.
- Update visible labels to “Today” where appropriate.

### 3. Keep AI FAB

The global AI floating action button should remain available inside the main shell.

Do not replace the AI FAB with an import FAB.

### 4. Preserve active session mini timer

If the active study session mini timer exists, keep it working above the shell.

## Important UX Rule

Do not rely only on Android back navigation to return to Today.

Users need a visible return path.

## Phase 1 Acceptance Criteria

- App launches into Today/Plan.
- Bottom nav has exactly 3 items:
  - CWA
  - Table
  - Sessions
- No Dashboard/Today/Plan item appears in the bottom nav.
- Tapping each bottom nav item opens the correct screen.
- AI FAB still opens the global AI chat.
- Active session mini timer still works, if applicable.
- No route crashes.

---

# Phase 2 — Visible Return-To-Today Pattern

## Goal

Add a clear top-left Home button on the main module screens so users can return to the Today landing screen.

## Screens To Update

Add a top-left Home button to:

```text
CWA
Table / Timetable
Sessions
```

## Behavior

When the user taps the Home button:

```text
Current screen → Today landing screen
```

If the Today route remains `/plan`, route to `/plan`.

## Recommended App Bar Pattern

For CWA:

```text
[Home]   CWA                         [Import] [More]
```

For Table:

```text
[Home]   Table                       [Filter/Import]
```

For Sessions:

```text
[Home]   Sessions                    [Stats/More]
```

## Implementation Notes

- The Home button should be visible, not hidden in an overflow menu.
- Use a rounded square icon button to match the soft CampusIQ design.
- Add tooltip/semantics label:
  - “Go to Today”
  - “Return to Today”
- Do not show this Home button on the Today screen itself. Today should use a menu/drawer button instead.

## Phase 2 Acceptance Criteria

- CWA has a visible Home button.
- Table/Timetable has a visible Home button.
- Sessions has a visible Home button.
- Tapping Home returns to Today/Plan.
- The user can navigate:
  - Today → CWA → Today
  - Today → Table → Today
  - Today → Sessions → Today

---

# Phase 3 — Today Landing Screen Polish

## Goal

Make the current Dashboard/Plan screen behave and feel like the student’s home base.

## Visible Name

Use one of these visible labels:

```text
Today
```

or

```text
Plan
```

Recommendation: prefer **Today** in user-facing text because it feels personal and daily.

## Today Screen Should Contain

The Today screen should show a useful daily overview, such as:

- Greeting
- Today’s classes
- Free time blocks
- Suggested study tasks
- Streak summary
- Current CWA snapshot
- Resume active session card, if a session exists
- Notification/bell action
- Menu/drawer icon

## Top-Left Pattern

On Today:

```text
[Menu]   Good morning / Today        [Notifications]
```

The menu opens the side drawer.

## Drawer Contents

The drawer should hold secondary destinations:

```text
Today
Streak
Insights
Weekly Review
Settings
Subscribe
```

Do not put CWA, Table, and Sessions only in the drawer; they already live in the bottom nav.

## Phase 3 Acceptance Criteria

- App launch screen feels like a daily dashboard/home base.
- The screen clearly communicates “Today” or “Plan.”
- Drawer/menu opens from the Today screen.
- Drawer contains secondary pages.
- Today is not hidden behind only a gesture.

---

# Phase 4 — CWA Screen Header And Mode Switcher

## Goal

Improve the CWA screen structure by adding:

1. Home button
2. Visible Import button
3. Semester / Cumulative segmented switcher

## Required CWA Header

The CWA screen should use this structure:

```text
[Home]   CWA                         [Import] [More]
```

## Required Switcher

Directly under the CWA header, add a segmented switcher:

```text
[ Semester ]   [ Cumulative ]
```

The selected mode should visibly highlight.

## Semester Mode Content

When `Semester` is selected, show current semester-focused content:

- Current Semester CWA card
- CWA percentage
- Trend / progress chart if available
- Target CWA
- Course-wise CWA list
- Credits summary
- Import Courses helper row or chip

Example sections:

```text
Current Semester CWA
Course-wise CWA
Credits Summary
Import Courses helper
```

## Cumulative Mode Content

When `Cumulative` is selected, show cumulative academic history content:

- Cumulative CWA
- Past semesters
- Trend across semesters
- Total credits earned
- Add/import past semester result entry point

Do not break existing cumulative CWA logic.

## Important Design Rule

The switcher should be near the top because it changes the whole meaning of the screen.

## Phase 4 Acceptance Criteria

- CWA screen has visible Home button.
- CWA screen has visible Import button.
- CWA screen has Semester/Cumulative segmented switcher.
- Semester mode shows semester-specific data.
- Cumulative mode shows cumulative-specific data.
- Existing CWA calculations still work.
- Existing routes into Course Hub from CWA still work.

---

# Phase 5 — CWA Import Bottom Sheet

## Goal

When the user taps the CWA Import button, show a bottom sheet menu with import options.

## Trigger

Top-right CWA button:

```text
Import
```

## Bottom Sheet Title

For Semester mode:

```text
Import Courses
```

For Cumulative mode, either:

```text
Import Results
```

or:

```text
Import Semester Record
```

## Semester Mode Options

When user is on Semester mode, bottom sheet options should be:

```text
Take Photo
Upload Image
Choose PDF
Enter Manually
```

Interpretation:

- Take Photo: use camera to scan registration slip
- Upload Image: pick registration slip image from gallery/files
- Choose PDF: pick registration slip PDF
- Enter Manually: open full-screen manual course entry page

## Cumulative Mode Options

When user is on Cumulative mode, bottom sheet options may be:

```text
Take Photo
Upload Result Image
Choose Result PDF
Enter Manually
```

or keep the labels generic if that is easier:

```text
Take Photo
Upload Image
Choose PDF
Enter Manually
```

## Bottom Sheet UX

Use a native-feeling rounded bottom sheet:

- Dim background behind the sheet.
- Show a drag handle.
- Use large tappable rows.
- Use icons:
  - Camera
  - Image
  - PDF/document
  - Pencil/edit
- Make text readable and beginner-friendly.

## Routing

The `Enter Manually` option should navigate to a full-screen manual entry screen.

Possible route:

```text
/cwa/manual-entry
```

or:

```text
/cwa/manual-entry?mode=semester
```

If using GoRouter extras, pass mode safely.

## Phase 5 Acceptance Criteria

- Tapping Import opens bottom sheet.
- Bottom sheet contains:
  - Take Photo
  - Upload Image
  - Choose PDF
  - Enter Manually
- Take Photo connects to existing camera/import flow if available.
- Upload Image connects to existing image import flow if available.
- Choose PDF connects to existing PDF import flow if available.
- Enter Manually opens manual entry screen.
- The sheet works in both Semester and Cumulative modes.
- No AI FAB conflict.

---

# Phase 6 — Enter Courses Manually Screen

## Goal

Create a dedicated full-screen manual course entry page.

This screen should open after:

```text
CWA → Import → Enter Manually
```

Do not implement it as a small bottom sheet. It should be a focused full-screen form.

## Screen Route

Suggested route:

```text
/cwa/manual-entry
```

Optional query:

```text
/cwa/manual-entry?mode=semester
```

or:

```text
/cwa/manual-entry?mode=cumulative
```

## Top App Bar

Use:

```text
[Back]   Enter Courses Manually        Save draft
```

Rules:

- Back returns to CWA.
- Save draft should preserve partial form state if draft logic exists.
- If draft logic does not exist yet, the button may be wired later, but do not crash.

## No Bottom Nav On This Screen

The manual entry screen is a focused task page.

Do not show:

- Bottom navigation
- AI FAB

The user should complete, save, cancel, or go back.

## Mode Switcher

At the top of the form, include:

```text
[ Semester ]   [ Cumulative ]
```

Default to the mode that was active on the CWA screen.

Also include helper text:

```text
Mode: Semester
Add your semester courses manually.
```

For Cumulative mode:

```text
Mode: Cumulative
Add courses from a completed semester.
```

## Semester Information Card

Add a card titled:

```text
Semester Information
```

Fields:

```text
Academic Year: 2025/2026
Semester: First Semester
Programme: Computer Engineering
Level: 400
```

Use dropdowns where appropriate.

If existing user profile/preferences contain programme or level, prefill them.

## Courses Section

Create a `Courses` section with repeatable course cards.

Each course card should contain:

```text
Course Code
Course Title
Credits
Expected Score (%)
Remove Course
```

Example Course 1:

```text
Course Code: CS301
Course Title: Operating Systems
Credits: 3
Expected Score: 75
```

Example Course 2:

```text
Course Code: MA201
Course Title: Discrete Mathematics
Credits: 3
Expected Score: 68
```

## Add Course Button

After the course cards, add:

```text
+ Add Another Course
```

This should append a new blank course card.

## Live Summary Card

Below the course list, show a live summary:

```text
Courses added: 2
Total credits: 6
Estimated CWA: 71.5%
```

The summary should update as fields change.

If required values are missing, show:

```text
Estimated CWA unavailable until required fields are filled.
```

## Sticky Bottom Actions

At the bottom, add:

```text
Cancel        Save Courses
```

Behavior:

- Cancel returns to CWA and discards unsaved changes after confirmation if changes exist.
- Save Courses validates fields and saves to the correct repository/model.
- On successful save, return to CWA and refresh displayed CWA data.

## Validation Rules

Add friendly inline validation:

- Course code cannot be empty.
- Course title cannot be empty.
- Credits must be numeric.
- Credits must be greater than 0.
- Score must be numeric.
- Score must be between 0 and 100.
- Duplicate course codes should show a warning.

## Data Handling

Use existing data models and repositories where possible.

For Semester mode:

- Save course entries into the current semester CWA course storage.
- Use existing `CourseModel` or current CWA model if available.

For Cumulative mode:

- Save into past semester / cumulative record storage.
- Use existing `PastSemesterModel` or equivalent if available.

Do not create duplicate database concepts if the existing app already has correct models.

## State Management

Use existing Riverpod patterns.

Suggested structure:

```text
presentation/providers/manual_course_entry_provider.dart
presentation/screens/manual_course_entry_screen.dart
presentation/widgets/manual_course_card.dart
presentation/widgets/manual_entry_summary_card.dart
```

Only use exact file names if they fit the existing project.

## Phase 6 Acceptance Criteria

- User can open manual entry from the import bottom sheet.
- User can switch between Semester and Cumulative mode.
- User can enter semester information.
- User can add multiple course cards.
- User can remove course cards.
- Summary updates live.
- Validation works.
- Save writes to the correct existing data model/repository.
- Cancel/back behavior is safe.
- CWA screen refreshes after saving.
- Bottom nav and AI FAB are hidden on the manual entry screen.

---

# Phase 7 — Polish, Accessibility, And Consistency

## Goal

Make the redesigned flow feel production-ready.

## Tasks

- Use consistent padding, radius, and typography.
- Match existing CampusIQ theme and Material 3 styling.
- Add semantic labels for:
  - Home button
  - Import button
  - Add course
  - Remove course
  - Save courses
- Make buttons large enough for touch.
- Make bottom sheet rows large enough for touch.
- Ensure keyboard does not cover the Save button.
- Ensure form scrolls smoothly.
- Ensure sticky bottom action area works on smaller screens.
- Ensure dark mode does not break if the app supports it.
- Ensure no overflow errors on small Android devices.
- Confirm all icons are available in the project icon set.

## Phase 7 Acceptance Criteria

- No layout overflow warnings.
- Screen works on small and large phones.
- Keyboard interactions are usable.
- All buttons have clear labels.
- UI feels consistent with existing app theme.

---

# Phase 8 — Final Regression Testing

## Critical User Flows To Test

### Navigation

```text
Launch app → Today
Today → CWA
CWA → Home → Today
Today → Table
Table → Home → Today
Today → Sessions
Sessions → Home → Today
```

### CWA Mode Switching

```text
CWA → Semester tab
CWA → Cumulative tab
CWA → Semester tab again
```

### Import

```text
CWA → Import → Take Photo
CWA → Import → Upload Image
CWA → Import → Choose PDF
CWA → Import → Enter Manually
```

### Manual Entry

```text
CWA → Import → Enter Manually
Enter Course 1
Enter Course 2
Add Another Course
Remove Course
Check live summary
Save Courses
Return to CWA
Verify CWA data refresh
```

### Error Cases

```text
Empty course code
Invalid credits
Invalid score over 100
Duplicate course code
Back with unsaved changes
Cancel with unsaved changes
```

## Final Acceptance Criteria

- Bottom nav has only CWA, Table, Sessions.
- Today is the app landing screen.
- Every core module has a visible top-left Home button.
- Drawer contains secondary pages.
- CWA has Semester/Cumulative switcher.
- CWA has Import action.
- Import opens bottom sheet.
- Manual entry opens full-screen.
- Manual entry saves correctly.
- Existing AI chat still works.
- Existing active timer mini card still works.
- Existing Course Hub routes still work.
- `flutter analyze` passes.
- Tests pass or existing failures are documented.

---

# Do Not Do These

Do **not**:

- Rewrite the whole app.
- Replace Riverpod with another state management approach.
- Replace GoRouter.
- Remove AI chat.
- Remove Course Hub.
- Remove active session mini timer.
- Hide Today behind only a swipe gesture.
- Add Today back into the bottom nav.
- Use the AI FAB for CWA import.
- Put manual course entry inside a cramped bottom sheet.
- Create duplicate models if existing models already handle the data.
- Hardcode fake data into production screens unless it is clearly placeholder/demo code already used in the project.

---

# Final Expected User Experience

After the changes, the user experience should be:

```text
User opens CampusIQ
↓
They land on Today, their daily home base
↓
Bottom nav shows only CWA, Table, Sessions
↓
User taps CWA
↓
CWA opens with a visible Home button, Import button, and Semester/Cumulative switcher
↓
User taps Import
↓
A bottom sheet opens with Take Photo, Upload Image, Choose PDF, Enter Manually
↓
User taps Enter Manually
↓
A full-screen form opens for manually adding courses
↓
User adds courses and sees a live CWA summary
↓
User saves
↓
App returns to CWA and refreshes the academic data
```

This redesign should make CampusIQ feel cleaner, easier to navigate, and more professional without removing important functionality.
