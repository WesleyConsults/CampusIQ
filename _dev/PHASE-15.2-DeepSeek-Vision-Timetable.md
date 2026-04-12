# Phase 15.2 — DeepSeek Vision Timetable Import

## Context

You are extending **CampusIQ**, a Flutter-based academic productivity app for Ghanaian
university students (KNUST target audience). The app uses:

- **Flutter** (Android-first), **Dart**
- **Riverpod** (riverpod_annotation + riverpod_generator) for state management
- **Isar 3.x** for local storage
- **Go Router** with a `ShellRoute` bottom nav
- **DeepSeek API** via `http` package — existing `DeepSeekClient` at
  `lib/features/ai/domain/deepseek_client.dart`
- **build_runner** for code generation

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

Allow a student to take a photo of their printed/digital university timetable (or upload
one from their gallery) and have CampusIQ automatically extract all the class slots and
import them into the Class Timetable — without manual entry.

The flow is:

```
Camera / Gallery
      ↓
image_picker → File path
      ↓
base64 encode image
      ↓
DeepSeek Vision API  (deepseek-vl model)
      ↓
JSON response: List<TimetableSlotImport>
      ↓
Review screen — student confirms / edits / removes slots
      ↓
TimetableRepository.upsertSlot() for each confirmed slot
      ↓
Navigate back to /timetable
```

---

## New pubspec dependencies

Add these to `pubspec.yaml` under `dependencies:`:

```yaml
image_picker: ^1.1.2        # camera + gallery picker (Google plugin, stable)
```

No other new packages needed. `DeepSeekClient` and `http` are already present.

---

## DeepSeek Vision API — how it works

DeepSeek's vision model is called `deepseek-vl`. The messages format extends the
standard chat format by making `content` an **array** instead of a string:

```json
{
  "model": "deepseek-vl",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,<BASE64_STRING>"
          }
        },
        {
          "type": "text",
          "text": "<your prompt>"
        }
      ]
    }
  ],
  "max_tokens": 2000
}
```

The base URL and API key are the same as the existing `DeepSeekClient`.

---

## Files to create

### 1. `lib/features/timetable/domain/timetable_slot_import.dart`

Pure Dart value object. No Flutter, no Isar imports.

```dart
/// A candidate slot parsed from an image before the student confirms it.
class TimetableSlotImport {
  final int dayIndex;        // 0=Mon … 5=Sat
  final String courseCode;
  final String courseName;
  final String venue;
  final int startMinutes;    // minutes from midnight
  final int endMinutes;
  final String slotType;     // "Lecture" | "Practical" | "Tutorial"

  const TimetableSlotImport({
    required this.dayIndex,
    required this.courseCode,
    required this.courseName,
    required this.venue,
    required this.startMinutes,
    required this.endMinutes,
    required this.slotType,
  });

  /// Build from the JSON object DeepSeek returns per slot.
  factory TimetableSlotImport.fromJson(Map<String, dynamic> json) { ... }

  /// Convert to a saveable model (caller supplies colorValue + semesterKey).
  TimetableSlotModel toModel({required int colorValue, required String semesterKey}) { ... }
}
```

**Implementation notes for `fromJson`:**
- `day` key will be a string ("Monday", "MON", "Mon", 0–5 int) — normalise all to 0–5
- `start_time` and `end_time` will be "HH:MM" 24h strings — convert to minutes
- `slot_type` may be missing — default to `"Lecture"`
- Wrap the whole factory in a try/catch; invalid slots should be silently skipped

---

### 2. `lib/features/timetable/domain/timetable_vision_parser.dart`

Pure Dart. Responsible for calling DeepSeek Vision and returning parsed slots.

```dart
class TimetableVisionParser {
  final String apiKey;
  static const _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const _timeout = Duration(seconds: 60);  // vision calls are slower

  const TimetableVisionParser({required this.apiKey});

  Future<List<TimetableSlotImport>> parse(String imageBase64) async { ... }
}
```

**`parse()` implementation:**

1. Build the prompt (see Prompt section below).
2. Encode the request body using the vision message format above.
3. POST to DeepSeek with `Authorization: Bearer $apiKey`.
4. Parse response: extract `choices[0].message.content` as a string.
5. Strip any markdown code fences (` ```json ... ``` `) from the string.
6. `jsonDecode` the cleaned string — expect a JSON array.
7. Map each element through `TimetableSlotImport.fromJson`, skip nulls.
8. Return the list; throw `DeepSeekException` on HTTP errors (reuse existing class).

**Prompt to send:**

```
You are a university timetable parser. 
Extract every class slot from the timetable image and return ONLY a JSON array.
Each object must have these exact keys:
  day         — string: "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", or "Saturday"
  course_code — string: the course/module code (e.g. "CS 101", "MATH 253")
  course_name — string: the full course name or best guess from the image
  venue       — string: room or lecture hall, empty string if not visible
  start_time  — string: 24-hour format "HH:MM"
  end_time    — string: 24-hour format "HH:MM"
  slot_type   — string: one of "Lecture", "Practical", "Tutorial"

Return nothing except the JSON array. No explanation. No markdown. No code fences.
Example:
[{"day":"Monday","course_code":"CS 101","course_name":"Intro to Computing",
  "venue":"LT1","start_time":"08:00","end_time":"10:00","slot_type":"Lecture"}]
```

---

### 3. `lib/features/timetable/presentation/providers/timetable_import_provider.dart`

Riverpod provider managing the full import flow state.

```dart
enum ImportStep { idle, picking, parsing, reviewing, saving, done, error }

class TimetableImportState {
  final ImportStep step;
  final List<TimetableSlotImport> slots;   // parsed candidates
  final Set<int> selectedIndexes;          // which slots the user kept
  final String? errorMessage;
  // ...
}

@riverpod
class TimetableImportNotifier extends _$TimetableImportNotifier {
  // Methods:
  Future<void> pickAndParse(ImageSource source);   // triggers picker + vision call
  void toggleSlot(int index);                       // review screen toggles
  void selectAll();
  void deselectAll();
  Future<void> confirmImport(String semesterKey);   // saves selected slots
  void reset();
}
```

**`pickAndParse` steps:**
1. Set state to `picking`; call `ImagePicker().pickImage(source: source, imageQuality: 85)`.
2. If user cancels → reset to `idle`.
3. Set state to `parsing`; read file bytes, base64 encode.
4. Call `TimetableVisionParser.parse(base64String)`.
5. On success → set state to `reviewing` with all indexes pre-selected.
6. On error → set state to `error` with message.

**`confirmImport` steps:**
1. Set state to `saving`.
2. Filter `slots` by `selectedIndexes`.
3. Assign a random color from `TimetableConstants.defaultColors` to each slot.
4. Call `TimetableRepository.upsertSlot(slot.toModel(...))` for each.
5. Set state to `done`.

---

### 4. `lib/features/timetable/presentation/screens/timetable_import_screen.dart`

Full-screen `ConsumerWidget`. Entry is a GoRoute push from the timetable screen.

**Layout — three states:**

#### State: `idle`
- Centered column with a timetable icon
- Two large buttons: **"Take Photo"** and **"Choose from Gallery"**
- Both call `ref.read(...notifier).pickAndParse(source)`

#### State: `picking` / `parsing`
- Centered `CircularProgressIndicator`
- Status text: "Reading image…" → "Extracting timetable…"

#### State: `reviewing`
- AppBar title: "Review Imported Slots" + **Confirm** action button (enabled only when ≥1 slot selected)
- Below AppBar: `SelectAll / Deselect All` row with slot count chip
- Body: `ListView` of `ImportSlotReviewTile` widgets (see widget below)
- Bottom bar: `ElevatedButton("Import X Slots")` → calls `confirmImport`

#### State: `saving`
- Show progress indicator over the review list (use `Stack` with semi-transparent overlay)

#### State: `done`
- `context.go('/timetable')` automatically — no manual navigation needed

#### State: `error`
- Centered error icon + message + **"Try Again"** button that calls `reset()`

---

### 5. `lib/features/timetable/presentation/widgets/import_slot_review_tile.dart`

A `ListTile`-based widget for the review screen. Shows:

- **Leading:** `Checkbox` bound to `selectedIndexes`
- **Title:** `${slot.courseCode} — ${slot.courseName}`
- **Subtitle:** `${dayLabel} · ${slot.startTimeLabel} – ${slot.endTimeLabel} · ${slot.venue}`
- **Trailing:** a small colored `Chip` for slot type (Lecture / Practical / Tutorial)
- Tapping the tile toggles the checkbox via `ref.read(...notifier).toggleSlot(index)`

---

## Entry point — timetable screen

In `lib/features/timetable/presentation/screens/timetable_screen.dart`:

Add an **import button** to the AppBar actions area:

```dart
IconButton(
  icon: const Icon(Icons.document_scanner_outlined),
  tooltip: 'Import from image',
  onPressed: () => context.push('/timetable/import'),
),
```

---

## New Route

Add to `lib/core/router/app_router.dart`, **inside** the existing `timetable` GoRoute
as a child route (so the import screen inherits the shell-less full-screen behaviour):

```dart
GoRoute(
  path: '/timetable/import',
  builder: (context, state) => const TimetableImportScreen(),
),
```

Place this route **outside** the `ShellRoute` — the import screen should show no
bottom nav (same pattern as `/course/:courseCode`).

---

## API key wiring

The `TimetableVisionParser` needs the DeepSeek API key. Follow the same pattern as
the existing AI feature:

1. Read the key from `AppConstants.deepSeekApiKey` (or wherever it is stored).
2. In `timetable_import_provider.dart`, instantiate:
   ```dart
   final parser = TimetableVisionParser(apiKey: AppConstants.deepSeekApiKey);
   ```

Do NOT hardcode the key.

---

## Color assignment for imported slots

`TimetableConstants` already has a list of default slot colors. When converting an
imported slot to a `TimetableSlotModel`, assign colors by cycling through the list
using the slot's index modulo the list length:

```dart
final color = TimetableConstants.defaultColors[index % TimetableConstants.defaultColors.length];
```

---

## Semester key

Prompt the user to select a semester key before confirming import, OR default to the
most recent semester key already present in Isar (query `TimetableRepository`).
A simple bottom sheet with a `DropdownButton` is sufficient — reuse the same semester
key pattern used in `AddSlotSheet`.

---

## Error handling rules

| Scenario | Behaviour |
|---|---|
| User cancels image picker | Return to idle silently |
| Image too large (> 4MB) | Show error: "Image too large. Try a lower-resolution photo." |
| DeepSeek returns empty array | Show error: "No timetable slots found. Try a clearer photo." |
| DeepSeek HTTP error / timeout | Show error with status code; offer retry |
| Individual slot JSON malformed | Skip that slot silently; import the rest |
| All slots deselected on review | Disable the Confirm button; show hint text |

---

## Build steps after implementation

```bash
# No new Isar @collection models in this phase — build_runner only needed
# if you add @riverpod annotations (which you will in the provider):
dart run build_runner build --delete-conflicting-outputs

flutter analyze
flutter run
```

---

## Files summary

| File | Type | Notes |
|---|---|---|
| `lib/features/timetable/domain/timetable_slot_import.dart` | New | Pure Dart value object |
| `lib/features/timetable/domain/timetable_vision_parser.dart` | New | Vision API caller |
| `lib/features/timetable/presentation/providers/timetable_import_provider.dart` | New | Riverpod notifier + state |
| `lib/features/timetable/presentation/providers/timetable_import_provider.g.dart` | Generated | build_runner output |
| `lib/features/timetable/presentation/screens/timetable_import_screen.dart` | New | Full-screen import UI |
| `lib/features/timetable/presentation/widgets/import_slot_review_tile.dart` | New | Review list tile widget |
| `lib/core/router/app_router.dart` | Modified | Add `/timetable/import` route |
| `lib/features/timetable/presentation/screens/timetable_screen.dart` | Modified | Add scanner icon button |
| `pubspec.yaml` | Modified | Add `image_picker` |

No new Isar schemas. No new routes that affect the bottom nav. No changes to existing
timetable data models or repositories.

---

## Acceptance criteria

- [ ] Camera button opens device camera; gallery button opens photo library
- [ ] A real KNUST-style timetable image returns ≥ 1 parsed slot
- [ ] Review screen shows all parsed slots with correct day / time / course info
- [ ] Student can toggle individual slots on/off before confirming
- [ ] Confirmed slots appear immediately in the Class Timetable grid
- [ ] Cancelling at any step returns user to the timetable screen without saving
- [ ] Network error shows a recoverable error state (not a crash)
- [ ] `flutter analyze` reports zero issues
