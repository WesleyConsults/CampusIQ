# CampusIQ — Phase 15.4: Study From Your Notes (Source-Grounded AI)

## Context

You are working on CampusIQ, a Flutter academic planning app for Ghanaian university students.
Read `CLAUDE.md` at the project root before starting.

**Package:** `com.wesleyconsults.campusiq`
**Architecture:** Three-layer feature structure — `data/`, `domain/`, `presentation/`
**State management:** Riverpod (riverpod_annotation + riverpod_generator)
**Local DB:** Isar 3.x
**Navigation:** Go Router

---

## What This Phase Builds

A **"From My Notes" source-grounded AI mode** inside the existing Course Hub AI tab (`hub_ai_tab.dart`).

When toggled ON → the AI answers exclusively from the student's typed notes (`CourseNoteModel`) and text extracted from uploaded PDFs (`CourseFileModel`).

When toggled OFF → the AI behaves exactly as the current general Hub AI chat. No behaviour change.

**No new routes. No new screens. No new Isar collections.**

---

## This Phase Has 2 Sessions

---

# SESSION 1 — PDF Text Extraction Pipeline

**Goal:** Every PDF uploaded in the Course Hub files tab gets its text extracted and stored in Isar. No AI tab changes yet — data layer only.

---

## Step 1 — Add Dependency

In `pubspec.yaml`, add under `dependencies`:

```yaml
syncfusion_flutter_pdf: ^26.2.14
```

Run:

```bash
flutter pub get
```

This is a local extraction library. No API key. No cost. Works fully offline.

---

## Step 2 — Update `CourseFileModel`

**File:** `lib/features/course_hub/data/models/course_file_model.dart`

Add two new fields to the existing `@collection` class:

```dart
String? extractedText;   // null = not extracted or extraction failed
bool isTextExtractable = false; // true = usable text was found
```

After editing, immediately run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Migration note:** Both fields are nullable or have defaults. Isar 3.x handles this without a manual migration — existing records get `null` and `false` automatically. Do not write a migration script.

---

## Step 3 — Create `PdfTextExtractor`

**New file:** `lib/features/course_hub/domain/pdf_text_extractor.dart`

Pure Dart class. No Flutter dependencies. Logic:

```dart
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfTextExtractor {
  static const int _minTextThreshold = 150; // minimum chars to be considered "text PDF"
  static const int _maxCharsStored = 40000; // ~20-25 pages of text, storage cap

  Future<({String text, bool isExtractable})> extract(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);

      final buffer = StringBuffer();
      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        if (pageText != null && pageText.trim().isNotEmpty) {
          buffer.writeln(pageText.trim());
        }
      }

      document.dispose();

      final fullText = buffer.toString();

      if (fullText.length < _minTextThreshold) {
        return (text: '', isExtractable: false);
      }

      final capped = fullText.length > _maxCharsStored
          ? fullText.substring(0, _maxCharsStored) + '\n[...content truncated]'
          : fullText;

      return (text: capped, isExtractable: true);
    } catch (e) {
      return (text: '', isExtractable: false);
    }
  }
}
```

**Important:** `_minTextThreshold` (150 chars) handles scanned PDFs that return a few stray metadata characters but are essentially image-only. The `_maxCharsStored` cap (40,000 chars) prevents large PDFs from bloating Isar.

---

## Step 4 — Update `CourseFileRepository`

**File:** `lib/features/course_hub/data/repositories/course_file_repository.dart`

Add one new method:

```dart
Future<List<CourseFileModel>> getExtractableFiles(String courseCode) async {
  return await isar.courseFileModels
      .filter()
      .courseCodeEqualTo(courseCode)
      .and()
      .isTextExtractableEqualTo(true)
      .findAll();
}
```

---

## Step 5 — Update `hub_files_tab.dart`

**File:** `lib/features/course_hub/presentation/widgets/hub_files_tab.dart`

In the file attach flow, after copying the file to `appDir/course_files/<courseCode>/`, add PDF extraction **before** the Isar write:

```dart
// After file is copied to local path
String? extractedText;
bool isTextExtractable = false;

if (filePath.toLowerCase().endsWith('.pdf')) {
  // Show loading state on the attach button: "Reading PDF..."
  final result = await PdfTextExtractor().extract(localPath);
  extractedText = result.isExtractable ? result.text : null;
  isTextExtractable = result.isExtractable;
}

// Then write to Isar as normal, including the new fields
final fileModel = CourseFileModel()
  ..courseCode = courseCode
  ..fileName = fileName
  ..localPath = localPath
  ..extractedText = extractedText
  ..isTextExtractable = isTextExtractable
  ..addedAt = DateTime.now();
```

While extraction is running, show a loading indicator on the attach button with the label **"Reading PDF..."**. Disable the button during this time to prevent double-taps.

For non-PDF files, skip the extractor entirely — `extractedText` stays null, `isTextExtractable` stays false.

---

## Step 6 — Update `file_tile.dart`

**File:** `lib/features/course_hub/presentation/widgets/file_tile.dart`

Add a small label chip below the filename, shown only for PDF files:

```dart
// Text-extractable PDF
if (file.isTextExtractable)
  Chip(
    label: Text('📄 Text indexed', style: TextStyle(fontSize: 11)),
    backgroundColor: Colors.green.shade50,
    side: BorderSide(color: Colors.green.shade200),
    padding: EdgeInsets.zero,
  )

// Non-extractable PDF (scanned / image-only)
else if (file.fileName.toLowerCase().endsWith('.pdf'))
  Chip(
    label: Text('🖼 Visual only — AI cannot read this', style: TextStyle(fontSize: 11)),
    backgroundColor: Colors.grey.shade100,
    side: BorderSide(color: Colors.grey.shade300),
    padding: EdgeInsets.zero,
  )

// Non-PDF files: no chip shown
```

---

## Session 1 Complete — Checklist Before Finishing

- [ ] `syncfusion_flutter_pdf` added and `flutter pub get` ran successfully
- [ ] `CourseFileModel` has `extractedText` and `isTextExtractable` fields
- [ ] `build_runner` ran with no errors after model change
- [ ] `PdfTextExtractor` class created in `domain/`
- [ ] `getExtractableFiles()` added to `CourseFileRepository`
- [ ] `hub_files_tab.dart` calls extractor on PDF upload with loading state
- [ ] `file_tile.dart` shows indexed / visual-only label chip
- [ ] Upload a text PDF → "Text indexed" label appears
- [ ] Upload a scanned PDF → "Visual only" label appears, no crash
- [ ] Upload a 60-page PDF → no crash, truncation works silently
- [ ] Non-PDF file upload → no chip shown, no change in behaviour

Commit: `feat(phase-15.4): session 1 — PDF text extraction pipeline`

---

---

# SESSION 2 — Source-Grounded Mode in Hub AI Tab

**Goal:** Add the "From My Notes" toggle to the Hub AI tab. Wire it to an updated context builder. Ship the full experience.

---

## Step 1 — Update `CourseHubContextBuilder`

**File:** `lib/features/course_hub/domain/course_hub_context_builder.dart`

Add a new method alongside the existing `build()` method. Do not modify the existing method — this is additive only.

```dart
String buildSourceGroundedContext({
  required List<CourseNoteModel> notes,
  required List<CourseFileModel> extractableFiles,
  required CourseModel course,
}) {
  final buffer = StringBuffer();

  buffer.writeln('COURSE: ${course.courseCode} — ${course.courseName}');
  buffer.writeln('---');

  if (notes.isNotEmpty) {
    buffer.writeln('STUDENT NOTES (${notes.length}):');
    for (final note in notes) {
      buffer.writeln('[Note: ${note.title}]');
      buffer.writeln(note.body);
      buffer.writeln('---');
    }
  }

  if (extractableFiles.isNotEmpty) {
    buffer.writeln('UPLOADED PDF CONTENT (${extractableFiles.length} files):');
    for (final file in extractableFiles) {
      buffer.writeln('[File: ${file.fileName}]');
      buffer.writeln(file.extractedText ?? '');
      buffer.writeln('---');
    }
  }

  final full = buffer.toString();

  // Safety cap: 15,000 chars keeps well within DeepSeek context window
  if (full.length > 15000) {
    return full.substring(0, 15000) + '\n[...content truncated for length]';
  }

  return full;
}
```

---

## Step 2 — Update `HubAiNotifier`

**File:** `lib/features/course_hub/presentation/providers/hub_ai_provider.dart`

### 2a — Add `isSourceGrounded` to state

If `HubAiState` is a class or record, add:

```dart
bool isSourceGrounded = false;
```

If state is managed directly in the notifier, add the field there.

### 2b — Add toggle method

```dart
void toggleSourceGrounded() {
  state = state.copyWith(isSourceGrounded: !state.isSourceGrounded);
}
```

### 2c — Load extractable files

In the notifier's `build()` or `init()` method, load extractable files alongside existing notes:

```dart
final extractableFiles = await ref
    .read(courseFileRepositoryProvider)
    .getExtractableFiles(courseCode);
```

Store this in the notifier for use in the system prompt.

### 2d — Update `_buildSystemPrompt()`

```dart
String _buildSystemPrompt() {
  if (state.isSourceGrounded) {
    final hasNotes = _notes.isNotEmpty;
    final hasFiles = _extractableFiles.isNotEmpty;

    if (!hasNotes && !hasFiles) {
      // Empty state — no materials to ground against
      // Return a signal string; the UI handles the empty state display
      return '__EMPTY_SOURCE_CONTEXT__';
    }

    final context = CourseHubContextBuilder().buildSourceGroundedContext(
      notes: _notes,
      extractableFiles: _extractableFiles,
      course: _course,
    );

    return '''
You are a focused academic assistant for ${_course.courseCode} — ${_course.courseName}.
Answer ONLY using the student's materials provided below.
Do NOT use general knowledge from your training.
If the answer is not found in the materials, respond with:
"I don't see this in your notes. Try switching to General mode for a broader answer."
Always mention which note title or PDF filename your answer came from.

STUDENT MATERIALS:
$context
''';
  }

  // Existing general system prompt — no changes
  return _existingGeneralSystemPrompt();
}
```

---

## Step 3 — Update `hub_ai_tab.dart`

**File:** `lib/features/course_hub/presentation/widgets/hub_ai_tab.dart`

### 3a — Replace or update the existing blue "Focused on [Code]" banner

Replace the existing banner with a two-chip mode selector row at the top of the tab:

```dart
Row(
  children: [
    FilterChip(
      label: Text('📚 From My Notes'),
      selected: isSourceGrounded,
      onSelected: (_) => notifier.toggleSourceGrounded(),
    ),
    SizedBox(width: 8),
    FilterChip(
      label: Text('🌐 General'),
      selected: !isSourceGrounded,
      onSelected: (_) => notifier.toggleSourceGrounded(),
    ),
  ],
)
```

Style the selected chip with a filled background using the app's primary navy color (`Color(0xFF0A1F44)`).

### 3b — Add source summary strip

Shown only when `isSourceGrounded == true` and materials exist. Place it just above the chat message list:

```dart
if (isSourceGrounded && !isEmptyContext)
  Container(
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(
      'Reading: ${noteCount} notes · ${fileCount} PDFs indexed'
      '${visualOnlyCount > 0 ? ' ($visualOnlyCount visual only — not included)' : ''}',
      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
    ),
  )
```

Compute `noteCount`, `fileCount`, and `visualOnlyCount` from the notifier state.

### 3c — Add empty state handling

When `isSourceGrounded == true` but the student has no notes and no extractable PDFs, replace the chat input area with:

```dart
if (isSourceGrounded && isEmptyContext)
  Expanded(
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No indexed materials for this course yet.',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Add notes in the Notes tab, or attach a text-based PDF in the Files tab. Then come back here.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  )
```

Do not allow message sending when in this empty state.

---

## Step 4 — Quota Behaviour

No changes needed. Source-grounded messages share the existing `chat` quota (3/day free). The existing `PremiumGateWidget` already handles this. Do not add a new quota key.

---

## Session 2 Complete — Checklist Before Finishing

- [ ] `buildSourceGroundedContext()` added to `CourseHubContextBuilder` — existing method untouched
- [ ] `isSourceGrounded` state and `toggleSourceGrounded()` in `HubAiNotifier`
- [ ] Extractable files loaded in notifier init
- [ ] `_buildSystemPrompt()` returns source-grounded prompt when mode is ON
- [ ] Two-chip toggle (From My Notes / General) in `hub_ai_tab.dart`
- [ ] Source summary strip visible when grounded mode is ON and materials exist
- [ ] Empty state shown when grounded mode is ON but no materials exist
- [ ] Message input disabled in empty state
- [ ] Toggle OFF → AI behaves exactly as before, quota counted as before
- [ ] Toggle ON with only notes → AI answers from notes, cites note title
- [ ] Toggle ON with only PDFs → AI answers from PDF text, cites filename
- [ ] Toggle ON with both → AI uses all sources, cites correctly
- [ ] Toggle ON with 0 materials → empty state shown, no crash
- [ ] Delete a file → next AI call does not reference it (context rebuilt on each call)
- [ ] Premium gate still appears correctly when quota exhausted

Commit: `feat(phase-15.4): session 2 — source-grounded AI mode in course hub`

---

---

## Full Files Changed Reference

| File | Change Type | Description |
|---|---|---|
| `pubspec.yaml` | Modified | Add `syncfusion_flutter_pdf` |
| `course_file_model.dart` | Modified | Add `extractedText`, `isTextExtractable` |
| `course_file_model.g.dart` | Regenerated | Auto — run build_runner |
| `course_file_repository.dart` | Modified | Add `getExtractableFiles()` |
| `pdf_text_extractor.dart` | **New** | Pure Dart PDF extraction service |
| `hub_files_tab.dart` | Modified | Call extractor on PDF upload, loading state |
| `file_tile.dart` | Modified | Indexed / visual-only label chip |
| `course_hub_context_builder.dart` | Modified | Add `buildSourceGroundedContext()` |
| `hub_ai_provider.dart` | Modified | `isSourceGrounded` state, toggle, updated prompt |
| `hub_ai_tab.dart` | Modified | Toggle chips, source strip, empty state |

---

## Build Commands

```bash
# After Step 2 in Session 1 (model change):
dart run build_runner build --delete-conflicting-outputs

# After all code changes:
flutter analyze
flutter run
```

Always run `build_runner` immediately after any change to an Isar `@collection` class before writing further code.

---

## Architecture Reminders

- `PdfTextExtractor` goes in `domain/` — pure Dart, zero Flutter dependencies
- `buildSourceGroundedContext()` goes in the existing `CourseHubContextBuilder` — additive only
- Business logic stays out of widgets — notifier handles all mode state
- Do not create new routes, screens, or Isar collections for this phase
