# Phase 15.1 — Course Hub Workspace

## Context

You are building a new feature for **CampusIQ**, a Flutter-based academic productivity app
for Ghanaian university students. The app uses:

- **Flutter** (Android-first), **Dart**
- **Riverpod** (riverpod_annotation + riverpod_generator) for state management
- **Isar 3.x** for local storage
- **Go Router** with a `ShellRoute` bottom nav
- **DeepSeek API** via `http` package for AI features
- **build_runner** for code generation

The existing codebase lives at:
`/media/edwin/18FC2827FC28021C/projects/campusiq/`

All new code must follow the established three-layer architecture:
```
lib/features/<feature>/
├── data/
│   ├── models/         — Isar @collection schemas + generated .g.dart
│   └── repositories/   — CRUD + stream methods (no Flutter deps)
├── domain/             — Pure Dart business logic only
└── presentation/
    ├── providers/       — Riverpod providers (riverpod_annotation)
    ├── screens/         — ConsumerWidget screens
    └── widgets/         — Stateless/Consumer widgets
```

Business logic never goes in widgets. Domain layer has zero Flutter dependencies.
Run `dart run build_runner build --delete-conflicting-outputs` after any model change.

---

## Objective

Build a **Course Hub** — a dedicated per-course workspace screen that a student can open
for any course in the app. It is a focused environment showing everything related to
that one course: overview stats, past sessions, personal notes, attached files,
AI-generated flashcards/questions, and a course-scoped AI chat.

---

## Entry Points

The Course Hub is navigated to by passing the `courseCode` string as a route parameter.
Add a "Open Workspace" option in these three places:

### 1. Timetable slot detail sheet
In `lib/features/timetable/presentation/widgets/slot_detail_sheet.dart`, add an
**"Open Workspace"** button alongside the existing Edit and Delete buttons.
It should push `/course/:courseCode` using the slot's `courseCode`.

### 2. CWA course card
In `lib/features/cwa/presentation/widgets/course_card.dart`, add a tap handler
(or long-press menu) that navigates to `/course/:courseCode`.

### 3. Sessions screen — course breakdown card
In `lib/features/session/presentation/widgets/course_breakdown_card.dart`, add a
tap/button that navigates to `/course/:courseCode`.

---

## New Route

Add to `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/course/:courseCode',
  builder: (context, state) {
    final courseCode = state.pathParameters['courseCode']!;
    return CourseHubScreen(courseCode: courseCode);
  },
),
```

This route lives **outside** the `ShellRoute` (no bottom nav on the Course Hub screen —
it is a full-screen push with a back arrow).

---

## New Feature Directory

Create the full directory structure:

```
lib/features/course_hub/
├── data/
│   ├── models/
│   │   ├── course_note_model.dart
│   │   └── course_file_model.dart
│   └── repositories/
│       ├── course_note_repository.dart
│       └── course_file_repository.dart
├── domain/
│   └── course_hub_context_builder.dart
└── presentation/
    ├── providers/
    │   ├── course_note_provider.dart
    │   └── course_file_provider.dart
    ├── screens/
    │   └── course_hub_screen.dart
    └── widgets/
        ├── hub_overview_tab.dart
        ├── hub_sessions_tab.dart
        ├── hub_notes_tab.dart
        ├── hub_files_tab.dart
        ├── hub_flashcards_tab.dart
        ├── hub_ai_tab.dart
        ├── note_editor_sheet.dart
        └── file_tile.dart
```

---

## Isar Models

### `CourseNoteModel`

```dart
@collection
class CourseNoteModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String courseCode;

  late String title;
  late String body;
  late DateTime createdAt;
  late DateTime updatedAt;
}
```

### `CourseFileModel`

```dart
@collection
class CourseFileModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String courseCode;

  late String fileName;
  late String filePath;   // absolute path on device storage
  late String fileType;   // 'pdf' | 'image'
  late DateTime addedAt;
}
```

Register both collections in `lib/core/providers/isar_provider.dart` alongside the
existing collections.

---

## Repositories

### `CourseNoteRepository`

Pure Dart. No Flutter imports.

Methods:
- `Stream<List<CourseNoteModel>> watchNotes(String courseCode)`
- `Future<void> saveNote(CourseNoteModel note)`
- `Future<void> deleteNote(int id)`

### `CourseFileRepository`

Pure Dart. No Flutter imports.

Methods:
- `Stream<List<CourseFileModel>> watchFiles(String courseCode)`
- `Future<void> saveFile(CourseFileModel file)`
- `Future<void> deleteFile(int id)` — also deletes the physical file from storage using `dart:io`

---

## Domain — `CourseHubContextBuilder`

Pure Dart class. No Flutter imports.

```dart
class CourseHubContextBuilder {
  /// Builds a context string injected into the AI system prompt
  /// for the course-scoped chat.
  static String build({
    required CourseModel course,
    required List<StudySessionModel> sessions,
    required List<CourseNoteModel> notes,
    required StreakResult courseStreak,
  }) {
    // Return a multi-line string like:
    // Course: MATH 301 — Engineering Mathematics (3 credit hours)
    // Expected score: 78 | Current CWA contribution: X
    // Sessions this course: N total, last studied: X days ago
    // Total study time: X hours Y minutes
    // Course streak: N days (alive/broken)
    // Student notes summary: [first 300 chars of most recent note, or 'No notes yet']
  }
}
```

---

## Providers

### `CourseNoteProvider`

```dart
@riverpod
Stream<List<CourseNoteModel>> courseNotes(
  CourseNotesRef ref,
  String courseCode,
) {
  final repo = ref.watch(courseNoteRepositoryProvider);
  return repo.watchNotes(courseCode);
}
```

### `CourseFileProvider`

```dart
@riverpod
Stream<List<CourseFileModel>> courseFiles(
  CourseFilesRef ref,
  String courseCode,
) {
  final repo = ref.watch(courseFileRepositoryProvider);
  return repo.watchFiles(courseCode);
}
```

---

## `CourseHubScreen`

A `ConsumerStatefulWidget` that accepts `courseCode` as a constructor parameter.

- Looks up the `CourseModel` from Isar via the existing `cwaProvider` or a direct
  repository call. If not found, shows an error state.
- Uses a `DefaultTabController` with 6 tabs.
- `AppBar` shows the course code + course name as title, with a back button.
- Tab bar icons + labels:

| Index | Icon | Label |
|-------|------|-------|
| 0 | `Icons.dashboard_outlined` | Overview |
| 1 | `Icons.timer_outlined` | Sessions |
| 2 | `Icons.notes_outlined` | Notes |
| 3 | `Icons.attach_file_outlined` | Files |
| 4 | `Icons.quiz_outlined` | Flashcards |
| 5 | `Icons.smart_toy_outlined` | AI Chat |

`TabBarView` renders one widget per tab (see below).

---

## Tab Widgets

### `HubOverviewTab`

Displays:
- Course name, code, credit hours
- Expected score (with a subtle chip showing grade letter equivalent)
- CWA contribution — how much this course moves the overall CWA
- `StreakSummaryMini` widget reused from the streak feature, filtered to this course
- Total sessions count + total study minutes for this course
- Days since last session (or "Not studied yet")

### `HubSessionsTab`

Displays:
- Filtered list of `StudySessionModel` where `courseName` matches this course
- Reuse the existing `SessionTile` widget
- A small weekly bar chart (reuse `WeeklyBarChart`) scoped to this course's sessions
- Empty state if no sessions yet

### `HubNotesTab`

Displays:
- A `ListView` of notes from `courseNotesProvider(courseCode)`
- Each note shows title, first line of body, and `updatedAt` timestamp
- FAB (or `+` button in top right) opens `NoteEditorSheet`
- Swipe to delete (with `Dismissible`)
- Tap a note to open `NoteEditorSheet` in edit mode
- Empty state widget if no notes

### `NoteEditorSheet`

A `DraggableScrollableSheet` (or full-screen push — your choice) with:
- `TextField` for title
- Multi-line `TextField` for body
- Save button — calls `saveNote` on the repository
- Pre-populated if editing an existing note

### `HubFilesTab`

Displays:
- A `ListView` of `CourseFileModel` rows from `courseFilesProvider(courseCode)`
- Each row: `FileTile` showing file name, type icon (PDF or image), date added, and a
  delete icon button
- "Attach File" button at the top that triggers `file_picker` to pick a PDF or image
- On pick: copy the file into the app's documents directory using `path_provider`, then
  save a `CourseFileModel` to Isar
- Tapping a `FileTile` opens the file using `open_filex`
- Empty state widget if no files

### `HubFlashcardsTab`

Reuses the **Phase 14 Exam Prep Generator** logic, scoped to this course:
- Pre-selects the course (no course picker dropdown — course is fixed)
- Shows the question type selector (MCQ / Short Answer / Flashcard)
- "Generate" button calls DeepSeek with the course context
- Renders `McqCard`, `ShortAnswerCard`, or `FlashcardWidget` — all reused from Phase 14
- Uses the existing `examPrepProvider` — pass `courseCode` to scope it
- Uses existing `AiUsageModel` quota (same `exam_prep` quota key as Phase 14)

### `HubAiTab`

A course-scoped AI chat:
- Visually identical to the existing `AiChatScreen` but scoped to this course
- On init, creates or resumes an `AiChatSessionModel` tagged with `courseCode`
  (add a nullable `courseCode` field to `AiChatSessionModel` if not already present)
- Every API call prepends a **system message** built by `CourseHubContextBuilder.build()`
  so the AI knows it is answering questions about this specific course
- The system prompt framing:
  ```
  You are a focused academic study assistant for [Course Name] ([Course Code]).
  Help the student understand concepts, review their notes, solve problems,
  and prepare for exams in this subject only. Be specific and concise.
  [CourseHubContextBuilder output injected here]
  ```
- Reuse `AiMessageBubble`, `AiTypingIndicator` from the existing AI feature
- Shares the existing `chat` usage quota from `AiUsageModel`
- Shows `PremiumGateWidget` when free quota is exhausted

---

## New Dependencies

Add to `pubspec.yaml`:

```yaml
file_picker: ^8.1.2
open_filex: ^4.4.1
```

Run `flutter pub get` after adding.

---

## File Copy Logic (for HubFilesTab)

```dart
Future<String> _copyFileToAppDir(String sourcePath, String fileName) async {
  final appDir = await getApplicationDocumentsDirectory();
  final courseDir = Directory('${appDir.path}/course_files');
  if (!await courseDir.exists()) await courseDir.create(recursive: true);
  final dest = File('${courseDir.path}/$fileName');
  await File(sourcePath).copy(dest.path);
  return dest.path;
}
```

---

## Things to NOT Change

- Do not modify any existing Isar model that already has generated `.g.dart` files
  without running `build_runner` immediately after.
- Do not change the `ShellRoute` structure or existing bottom nav destinations.
- Do not modify `AiUsageModel` schema — only add a new quota key string if needed.
- Do not break the existing `ExamPrepScreen` — `HubFlashcardsTab` should reuse its
  providers, not replace them.

---

## Build & Verify Commands

After completing all files:

```bash
cd /media/edwin/18FC2827FC28021C/projects/campusiq
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

Zero analyzer errors expected before handing back.

---

## Session Checkpoints

Complete this phase in **3 sub-sessions**:

### Session 1 — Data Layer + Routing
- [ ] `CourseNoteModel` + `CourseFileModel` Isar schemas created
- [ ] Both collections registered in `isar_provider.dart`
- [ ] `build_runner` run successfully — `.g.dart` files generated
- [ ] `CourseNoteRepository` + `CourseFileRepository` implemented
- [ ] `CourseHubContextBuilder` domain class implemented
- [ ] Route `/course/:courseCode` added to `app_router.dart`
- [ ] `CourseHubScreen` scaffold with tab bar and empty tab placeholders created
- [ ] Entry point added to `slot_detail_sheet.dart` (Timetable)
- [ ] Entry point added to `course_card.dart` (CWA)
- [ ] Entry point added to `course_breakdown_card.dart` (Sessions)
- [ ] `flutter analyze` passes with zero errors
- [ ] **Git commit:** `feat(course-hub): Session 1 — data layer, routing, entry points`

### Session 2 — Overview, Sessions, Notes, Files Tabs
- [ ] `HubOverviewTab` complete with all stats and streak mini
- [ ] `HubSessionsTab` complete with filtered session list and bar chart
- [ ] `HubNotesTab` complete with note list, swipe-to-delete, empty state
- [ ] `NoteEditorSheet` complete — add and edit modes both work
- [ ] `HubFilesTab` complete — file pick, copy, list, open, delete
- [ ] `file_picker` and `open_filex` added to `pubspec.yaml` and working
- [ ] `flutter analyze` passes with zero errors
- [ ] **Git commit:** `feat(course-hub): Session 2 — overview, sessions, notes, files tabs`

### Session 3 — Flashcards Tab + AI Chat Tab + Polish
- [ ] `HubFlashcardsTab` complete — MCQ, Short Answer, Flashcard generation working
- [ ] `HubAiTab` complete — course-scoped chat with system prompt context injection
- [ ] `AiChatSessionModel` updated with nullable `courseCode` field (if needed) + `build_runner` re-run
- [ ] Course Hub AI chat history is separated from the global AI chat history
- [ ] `CourseNoteProvider` and `CourseFileProvider` wired with `riverpod_annotation`
- [ ] All 6 tabs render without overflow or layout errors on a standard Android screen
- [ ] `flutter analyze` passes with zero errors
- [ ] **Git commit:** `feat(course-hub): Session 3 — flashcards, AI chat, Phase 15.1 complete`

---

## QA Checklist (Hand Back to Edwin)

When the phase is complete, confirm every item below before closing the session.

### Routing & Entry Points
- [ ] Tapping "Open Workspace" on a timetable slot opens the correct course hub
- [ ] Tapping a CWA course card opens the correct course hub
- [ ] Tapping a course in the Sessions breakdown opens the correct course hub
- [ ] Back button on Course Hub returns to the previous screen correctly
- [ ] Opening hub for Course A then navigating back and opening Course B shows Course B's data (no stale state)

### Overview Tab
- [ ] Course name, code, and credit hours display correctly
- [ ] Expected score matches what is set in the CWA planner
- [ ] CWA contribution figure is correct
- [ ] Session count and total study time are accurate
- [ ] "Days since last session" is correct (or shows "Not studied yet")
- [ ] Streak summary mini shows the correct streak for this course

### Sessions Tab
- [ ] Only sessions for this course appear (no sessions from other courses)
- [ ] Sessions are in reverse chronological order
- [ ] Bar chart reflects only this course's weekly data
- [ ] Empty state shows when no sessions exist for this course

### Notes Tab
- [ ] Tapping the add button opens the note editor sheet
- [ ] A new note is saved and appears in the list immediately (Isar stream updates)
- [ ] Tapping an existing note opens it in edit mode with content pre-filled
- [ ] Saving an edit updates the note in the list
- [ ] Swiping a note to delete removes it from the list
- [ ] Notes from Course A do not appear in Course B's Notes tab
- [ ] Empty state shows when no notes exist

### Files Tab
- [ ] "Attach File" button triggers the file picker
- [ ] Picking a PDF adds it to the list with a PDF icon
- [ ] Picking an image adds it to the list with an image icon
- [ ] Tapping a file tile opens the file (PDF opens in viewer, image opens full screen)
- [ ] Deleting a file removes it from the list and deletes the physical file
- [ ] Files from Course A do not appear in Course B's Files tab
- [ ] Empty state shows when no files exist

### Flashcards Tab
- [ ] Course name is pre-filled and not changeable (this course only)
- [ ] Selecting MCQ and tapping Generate produces MCQ questions for this course
- [ ] Selecting Short Answer produces short answer questions
- [ ] Selecting Flashcard produces flashcards with 3D flip animation
- [ ] Free tier usage quota is respected (shows gate when exhausted)
- [ ] Premium users bypass the gate

### AI Chat Tab
- [ ] AI chat opens and accepts a message
- [ ] AI responses are scoped — the AI references this course by name in responses
- [ ] The system prompt context is injected (verify by asking "what course are we focusing on?")
- [ ] Notes content is reflected in AI context (ask AI about a note you wrote)
- [ ] Chat history for Course A is separate from Course B and from the global AI chat
- [ ] Free tier usage quota is respected
- [ ] Typing indicator appears while waiting for a response

### Stability
- [ ] Hot restart preserves all notes and files
- [ ] Full app restart preserves all notes and files
- [ ] No red screen errors on any tab
- [ ] No overflow errors on any widget
- [ ] `flutter analyze` returns zero issues
