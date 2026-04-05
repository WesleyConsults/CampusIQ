# CampusIQ — PHASE1.md
## Project Scaffold + CWA Target Planner
**Package**: com.wesleyconsults.campusiq | **Stack**: Flutter + Isar + Riverpod + Go Router
**Dev machine**: Ubuntu 24 | **Storage**: `/media/edwin/18FC2827FC28021C/projects/campusiq`

---

## HOW TO USE THIS FILE

This file is your Phase 1 source of truth. You drive it in three Claude Code sessions.
Each session ends at a checkpoint — do not cross a checkpoint without verifying it first.

**Start each session with:**
> "Read `_dev/PHASE1.md`. [Session instruction below.]"

---

## PRE-FLIGHT — Run this manually in your terminal before Session 1

```bash
flutter create --org com.wesleyconsults --project-name campusiq campusiq
cd /media/edwin/18FC2827FC28021C/projects/campusiq
mkdir -p _dev
# Move this file into _dev/ before starting Claude Code
flutter run   # confirm default counter app works
git init
git add .
git commit -m "chore: flutter create scaffold"
```

Only start Claude Code after this step completes successfully.

---

---

# SESSION 1 — Foundation + Isar Schema

**Claude Code instruction:**
> "Read `_dev/PHASE1.md`. Execute Session 1 steps 1 through 5 only. After Step 5 run build_runner and confirm it succeeds. Then stop and report back."

---

## STEP 1 — pubspec.yaml

Replace the full contents of `pubspec.yaml` with:

```yaml
name: campusiq
description: Smart Academic Planning & Performance System for Ghanaian University Students
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Local storage
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3

  # Navigation
  go_router: ^14.2.0

  # UI utilities
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.3
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10

flutter:
  uses-material-design: true
  assets:
    - assets/fonts/
    - assets/images/
```

Then run:

```bash
flutter pub get
```

Confirm: no errors in output before continuing.

---

## STEP 2 — Folder Structure

Create the following folders and empty placeholder files inside `lib/`:

```
lib/
├── main.dart                          ← already exists, will replace in Step 14
├── app.dart                           ← create empty
├── core/
│   ├── router/
│   │   └── app_router.dart            ← create empty
│   ├── theme/
│   │   └── app_theme.dart             ← create empty
│   ├── constants/
│   │   └── app_constants.dart         ← create empty
│   └── providers/
│       └── isar_provider.dart         ← create empty
├── features/
│   ├── cwa/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── course_model.dart  ← create empty
│   │   │   └── repositories/
│   │   │       └── cwa_repository.dart
│   │   ├── domain/
│   │   │   └── cwa_calculator.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── cwa_screen.dart
│   │       ├── widgets/
│   │       │   ├── course_card.dart
│   │       │   ├── cwa_summary_bar.dart
│   │       │   └── add_course_sheet.dart
│   │       └── providers/
│   │           └── cwa_provider.dart
│   ├── timetable/
│   │   └── .gitkeep
│   ├── session/
│   │   └── .gitkeep
│   └── streak/
│       └── .gitkeep
└── shared/
    ├── widgets/
    │   └── empty_state_widget.dart
    └── extensions/
        └── double_extensions.dart
```

Also create:

```bash
mkdir -p assets/fonts assets/images
```

---

## STEP 3 — Android minSdk

In `android/app/build.gradle`, find the `defaultConfig` block and set:

```gradle
minSdkVersion 21
```

---

## STEP 4 — Isar Model: CourseModel

Create `lib/features/cwa/data/models/course_model.dart`:

```dart
import 'package:isar/isar.dart';

part 'course_model.g.dart';

@collection
class CourseModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String code;
  late double creditHours;
  late double expectedScore;

  /// Semester this course belongs to e.g. "2024-Sem2"
  late String semesterKey;

  DateTime createdAt = DateTime.now();

  CourseModel();

  CourseModel.create({
    required this.name,
    required this.code,
    required this.creditHours,
    required this.expectedScore,
    required this.semesterKey,
  });
}
```

---

## STEP 5 — Run Isar Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```

If that fails, try:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ⛳ CHECKPOINT 1

Before continuing, verify all three:

- [ ] `lib/features/cwa/data/models/course_model.g.dart` exists
- [ ] `build_runner` exited with code 0 (no errors in output)
- [ ] `flutter analyze` shows 0 errors

**If any check fails, do not continue. Paste the error into Claude Code and fix it first.**

When all three pass:

```bash
git add .
git commit -m "feat(cwa): Isar CourseModel schema + project structure"
```

**Tell Claude Code:** "Checkpoint 1 passed. Ready for Session 2."

---

---

# SESSION 2 — Core Logic + Providers + Theme

**Claude Code instruction:**
> "Read `_dev/PHASE1.md`. Checkpoint 1 is done. Execute Session 2 steps 6 through 13 only. After Step 13 run flutter analyze and confirm zero errors. Then stop and report back."

---

## STEP 6 — Isar Provider

Create `lib/core/providers/isar_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';

/// Opens and provides a singleton Isar instance.
/// All features share this one database.
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [CourseModelSchema],
    directory: dir.path,
  );
});
```

---

## STEP 7 — CWA Calculator (Pure Domain Logic)

Create `lib/features/cwa/domain/cwa_calculator.dart`:

```dart
/// Pure CWA calculation logic — no Flutter, no Isar, fully testable.
class CwaCalculator {
  /// CWA = sum(creditHours * score) / sum(creditHours)
  static double calculate(List<({double creditHours, double score})> courses) {
    if (courses.isEmpty) return 0.0;

    double totalWeightedScore = 0;
    double totalCredits = 0;

    for (final c in courses) {
      totalWeightedScore += c.creditHours * c.score;
      totalCredits += c.creditHours;
    }

    if (totalCredits == 0) return 0.0;
    return totalWeightedScore / totalCredits;
  }

  /// How far projected CWA is from target. Positive = below target.
  static double gap(double projected, double target) => target - projected;

  /// Returns index of course with highest credit weight — most CWA impact.
  static int highestImpactCourseIndex(List<({double creditHours, double score})> courses) {
    if (courses.isEmpty) return -1;
    int idx = 0;
    double maxCredits = 0;
    for (int i = 0; i < courses.length; i++) {
      if (courses[i].creditHours > maxCredits) {
        maxCredits = courses[i].creditHours;
        idx = i;
      }
    }
    return idx;
  }

  /// Simulates new CWA if one course score changes.
  static double whatIf({
    required List<({double creditHours, double score})> courses,
    required int index,
    required double newScore,
  }) {
    final modified = List.of(courses);
    modified[index] = (creditHours: modified[index].creditHours, score: newScore);
    return calculate(modified);
  }
}
```

---

## STEP 8 — CWA Repository

Create `lib/features/cwa/data/repositories/cwa_repository.dart`:

```dart
import 'package:isar/isar.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';

class CwaRepository {
  final Isar _isar;
  CwaRepository(this._isar);

  /// Live stream — re-emits whenever courses change in Isar.
  Stream<List<CourseModel>> watchCourses(String semesterKey) {
    return _isar.courseModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .watch(fireImmediately: true);
  }

  Future<void> addCourse(CourseModel course) async {
    await _isar.writeTxn(() => _isar.courseModels.put(course));
  }

  Future<void> updateCourse(CourseModel course) async {
    await _isar.writeTxn(() => _isar.courseModels.put(course));
  }

  Future<void> deleteCourse(Id id) async {
    await _isar.writeTxn(() => _isar.courseModels.delete(id));
  }
}
```

---

## STEP 9 — CWA Riverpod Providers

Create `lib/features/cwa/presentation/providers/cwa_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/core/constants/app_constants.dart';

/// Active semester — becomes user-configurable in a later phase.
final activeSemesterProvider = StateProvider<String>((ref) => AppConstants.defaultSemesterKey);

/// Repository — only available once Isar is open.
final cwaRepositoryProvider = Provider<CwaRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => CwaRepository(isar));
});

/// Live stream of courses for the active semester.
final coursesProvider = StreamProvider<List<CourseModel>>((ref) {
  final repo = ref.watch(cwaRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchCourses(semester);
});

/// User's target CWA — persisted to Isar in Phase 2.
final targetCwaProvider = StateProvider<double>((ref) => 70.0);

/// Computed projected CWA from current courses.
final projectedCwaProvider = Provider<double>((ref) {
  final courses = ref.watch(coursesProvider).valueOrNull ?? [];
  final pairs = courses
      .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
      .toList();
  return CwaCalculator.calculate(pairs);
});

/// Gap between target and projected. Positive = below target.
final cwaGapProvider = Provider<double>((ref) {
  final projected = ref.watch(projectedCwaProvider);
  final target = ref.watch(targetCwaProvider);
  return CwaCalculator.gap(projected, target);
});
```

---

## STEP 10 — App Constants

Create `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String appName = 'CampusIQ';
  static const String defaultSemesterKey = '2024-Sem2';

  static const double minPassScore = 50.0;
  static const double distinctionThreshold = 70.0;
  static const double minCwa = 0.0;
  static const double maxCwa = 100.0;
}
```

---

## STEP 11 — Double Extensions

Create `lib/shared/extensions/double_extensions.dart`:

```dart
extension DoubleFormatting on double {
  /// e.g. 68.3
  String toCwaString() => toStringAsFixed(1);

  /// e.g. "68.3%"
  String toPercentString() => '${toStringAsFixed(1)}%';
}
```

---

## STEP 12 — App Theme

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0B1F3A);
  static const Color accent = Color(0xFFC9A84C);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF1D9E75);
  static const Color warning = Color(0xFFE8593C);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: primary,
      ),
    );
  }
}
```

---

## STEP 13 — Go Router

Create `lib/core/router/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/cwa',
  routes: [
    GoRoute(
      path: '/cwa',
      name: 'cwa',
      builder: (context, state) => const CwaScreen(),
    ),
    // Phase 2: /timetable
    // Phase 3: /schedule
    // Phase 4: /sessions
    // Phase 5: /streak
  ],
);
```

---

## ⛳ CHECKPOINT 2

Before continuing, verify both:

- [ ] `flutter analyze` shows 0 errors
- [ ] No import errors visible in any file created in Steps 6–13

**If any check fails, fix it before continuing.**

When both pass:

```bash
git add .
git commit -m "feat(cwa): calculator, repository, providers, theme, router"
```

**Tell Claude Code:** "Checkpoint 2 passed. Ready for Session 3."

---

---

# SESSION 3 — UI Layer + Full Integration

**Claude Code instruction:**
> "Read `_dev/PHASE1.md`. Checkpoints 1 and 2 are done. Execute Session 3 steps 14 through 20. After Step 20 run the app and confirm it works end to end. Then stop and report back."

---

## STEP 14 — main.dart

Replace `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/app.dart';

void main() {
  runApp(const ProviderScope(child: CampusIQApp()));
}
```

---

## STEP 15 — app.dart

Create `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/router/app_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/constants/app_constants.dart';

class CampusIQApp extends StatelessWidget {
  const CampusIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## STEP 16 — CWA Summary Bar Widget

Create `lib/features/cwa/presentation/widgets/cwa_summary_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/shared/extensions/double_extensions.dart';

class CwaSummaryBar extends StatelessWidget {
  final double projected;
  final double target;
  final double gap;

  const CwaSummaryBar({
    super.key,
    required this.projected,
    required this.target,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    final isOnTrack = gap <= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBox(label: 'Projected CWA', value: projected.toCwaString(), valueColor: Colors.white),
              _StatBox(label: 'Target CWA', value: target.toCwaString(), valueColor: AppTheme.accent),
              _StatBox(
                label: 'Gap',
                value: isOnTrack ? 'On track' : gap.toCwaString(),
                valueColor: isOnTrack ? AppTheme.success : AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: projected.clamp(0, 100) / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOnTrack ? AppTheme.success : AppTheme.accent,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOnTrack
                ? 'Great! Your projected CWA meets your target.'
                : 'You need to improve by ${gap.toCwaString()} points.',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatBox({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
```

---

## STEP 17 — Course Card Widget

Create `lib/features/cwa/presentation/widgets/course_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final bool isHighImpact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<double> onScoreChanged;

  const CourseCard({
    super.key,
    required this.course,
    required this.isHighImpact,
    required this.onEdit,
    required this.onDelete,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            course.code,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary),
                          ),
                          if (isHighImpact) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'High impact',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.accent.withOpacity(0.9)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(course.name, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  '${course.creditHours.toInt()} cr',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Expected score:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const Spacer(),
                Text('${course.expectedScore.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            Slider(
              value: course.expectedScore,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: AppTheme.primary,
              inactiveColor: Colors.grey.shade200,
              onChanged: onScoreChanged,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 18 — Add Course Bottom Sheet

Create `lib/features/cwa/presentation/widgets/add_course_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';

class AddCourseSheet extends StatefulWidget {
  final String semesterKey;
  final CourseModel? existing;

  const AddCourseSheet({super.key, required this.semesterKey, this.existing});

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  double _creditHours = 3;
  double _expectedScore = 70;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _codeController.text = widget.existing!.code;
      _creditHours = widget.existing!.creditHours;
      _expectedScore = widget.existing!.expectedScore;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final course = widget.existing ?? CourseModel();
    course.name = _nameController.text.trim();
    course.code = _codeController.text.trim().toUpperCase();
    course.creditHours = _creditHours;
    course.expectedScore = _expectedScore;
    course.semesterKey = widget.semesterKey;

    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null ? 'Add Course' : 'Edit Course',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Course code (e.g. COE 456)'),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Course name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Credit hours', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text('${_creditHours.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            Slider(
              value: _creditHours,
              min: 1,
              max: 6,
              divisions: 5,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _creditHours = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expected score', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text('${_expectedScore.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            Slider(
              value: _expectedScore,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _expectedScore = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(widget.existing == null ? 'Add Course' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 19 — CWA Screen

Create `lib/features/cwa/presentation/screens/cwa_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/constants/app_constants.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/cwa_summary_bar.dart';
import 'package:campusiq/features/cwa/presentation/widgets/course_card.dart';
import 'package:campusiq/features/cwa/presentation/widgets/add_course_sheet.dart';

class CwaScreen extends ConsumerWidget {
  const CwaScreen({super.key});

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref, {CourseModel? existing}) async {
    final result = await showModalBottomSheet<CourseModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddCourseSheet(
        semesterKey: ref.read(activeSemesterProvider),
        existing: existing,
      ),
    );

    if (result == null) return;
    final repo = ref.read(cwaRepositoryProvider);
    if (repo == null) return;

    existing == null ? await repo.addCourse(result) : await repo.updateCourse(result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final projected = ref.watch(projectedCwaProvider);
    final target = ref.watch(targetCwaProvider);
    final gap = ref.watch(cwaGapProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(AppConstants.appName, style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Set target CWA',
            onPressed: () => _showTargetDialog(context, ref, target),
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (courses) {
          final pairs = courses
              .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
              .toList();
          final highImpactIdx = CwaCalculator.highestImpactCourseIndex(pairs);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CwaSummaryBar(projected: projected, target: target, gap: gap),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Courses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text('${courses.length} courses', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              if (courses.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 56, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('No courses yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                        SizedBox(height: 4),
                        Text('Tap + to add your first course', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final course = courses[i];
                      final repo = ref.read(cwaRepositoryProvider);
                      return CourseCard(
                        course: course,
                        isHighImpact: i == highImpactIdx,
                        onEdit: () => _openAddSheet(context, ref, existing: course),
                        onDelete: () => repo?.deleteCourse(course.id),
                        onScoreChanged: (newScore) async {
                          course.expectedScore = newScore;
                          await repo?.updateCourse(course);
                        },
                      );
                    },
                    childCount: courses.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  void _showTargetDialog(BuildContext context, WidgetRef ref, double current) {
    double temp = current;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Target CWA'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${temp.toInt()}',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.primary),
              ),
              Slider(
                value: temp,
                min: 40,
                max: 100,
                divisions: 60,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => temp = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(targetCwaProvider.notifier).state = temp;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 20 — Final Verification

Run these three commands in order:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

**Test checklist on device/emulator:**
- [ ] App launches with navy AppBar showing "CampusIQ"
- [ ] Empty state shows school icon and "No courses yet"
- [ ] Tapping + opens bottom sheet with form
- [ ] Adding a course updates the CWA summary bar immediately
- [ ] Score slider on a course card updates projected CWA in real time
- [ ] Tune icon opens target CWA dialog — changing it updates the gap
- [ ] High impact badge appears on the course with most credit hours
- [ ] Delete via popup menu removes the course and recalculates CWA
- [ ] Hot restart preserves courses (Isar persistence confirmed)

---

## ⛳ CHECKPOINT 3 — Phase 1 Complete

All 9 test items above must pass.

**If anything fails**, paste the exact error or describe the broken behaviour to Claude Code. Do not commit broken code.

When all pass:

```bash
git add .
git commit -m "feat: Phase 1 complete — CWA Target Planner"
git push -u origin main
```

---

## Phase 1 Summary

| What was built | Location |
|---|---|
| Isar schema + codegen | `features/cwa/data/models/` |
| Pure Dart CWA calculator | `features/cwa/domain/` |
| Live Riverpod stream providers | `features/cwa/presentation/providers/` |
| Repository (CRUD + stream) | `features/cwa/data/repositories/` |
| CWA summary bar widget | `features/cwa/presentation/widgets/` |
| Course card with live slider | `features/cwa/presentation/widgets/` |
| Add / edit bottom sheet | `features/cwa/presentation/widgets/` |
| Full CWA screen | `features/cwa/presentation/screens/` |
| App theme (navy + gold) | `core/theme/` |
| Go Router scaffold | `core/router/` |

**Phase 2 next:** Manual Class Timetable + Free Time Detection

---

*CampusIQ · PHASE1.md · WesleyConsults Dev · April 2026*
