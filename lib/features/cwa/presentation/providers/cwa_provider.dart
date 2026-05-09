import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/constants/app_constants.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/cwa/data/repositories/past_result_repository.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';

enum CwaViewMode { semester, cumulative }

/// User preference repository for CWA semester settings.
final cwaPrefsRepositoryProvider = Provider<UserPrefsRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => UserPrefsRepository(isar));
});

/// Persisted active semester for semester-scoped features.
final activeSemesterPrefsProvider = StreamProvider<String>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  final repo = UserPrefsRepository(isar);
  await repo.getPrefs();

  await for (final prefs in repo.watchPrefs()) {
    final semesterKey = prefs?.activeSemesterKey.trim() ?? '';
    yield semesterKey.isEmpty ? AppConstants.defaultSemesterKey : semesterKey;
  }
});

/// Current active semester used across CWA, timetable, and sessions.
final activeSemesterProvider = Provider<String>((ref) {
  final semester = ref.watch(activeSemesterPrefsProvider).valueOrNull;
  if (semester == null || semester.isEmpty) {
    return AppConstants.defaultSemesterKey;
  }
  return semester;
});

/// Repository — only available once Isar is open.
final cwaRepositoryProvider = Provider<CwaRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => CwaRepository(isar));
});

/// Live stream of courses for the active semester.
final coursesProvider = StreamProvider<List<CourseModel>>((ref) async* {
  final semester = ref.watch(activeSemesterProvider);
  final isar = await ref.watch(isarProvider.future);
  yield* CwaRepository(isar).watchCourses(semester);
});

/// Persisted target CWA preference.
final targetCwaPrefsProvider = StreamProvider<double>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  final repo = UserPrefsRepository(isar);
  await repo.getPrefs();

  await for (final prefs in repo.watchPrefs()) {
    final target = prefs?.targetCwa ?? AppConstants.distinctionThreshold;
    yield target.clamp(40.0, AppConstants.maxCwa).toDouble();
  }
});

/// Current target CWA used by gap calculations.
final targetCwaProvider = Provider<double>((ref) {
  final target = ref.watch(targetCwaPrefsProvider).valueOrNull;
  if (target == null) return AppConstants.distinctionThreshold;
  return target;
});

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

// ─── Past results ─────────────────────────────────────────────────────────────

/// Repository for past semester results.
final pastResultRepositoryProvider = Provider<PastResultRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => PastResultRepository(isar));
});

/// Live stream of all past semester results, ordered by createdAt.
final pastSemestersProvider =
    StreamProvider<List<PastSemesterModel>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* PastResultRepository(isar).watchAll();
});

final pendingPastSemestersProvider = Provider<List<PastSemesterModel>>((ref) {
  final all = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  return all.where((semester) => semester.isPendingResults).toList();
});

final officialPastSemestersProvider = Provider<List<PastSemesterModel>>((ref) {
  final all = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  return all.where((semester) => !semester.isPendingResults).toList();
});

// ─── View mode toggle (per-session, not persisted) ────────────────────────────

final cwaViewModeProvider =
    StateProvider<CwaViewMode>((ref) => CwaViewMode.semester);

// ─── Cumulative providers ─────────────────────────────────────────────────────

/// Cumulative CWA across all past semesters + current semester.
///
/// Strategy (in priority order):
/// 1. If the most recently imported semester has slip-reported cumulative totals
///    (cumulativeWeightedMarks + cumulativeCreditsCalc), use those directly as
///    the historical baseline and add only the current semester on top.
///    This is the most accurate path — KNUST already computed the history.
/// 2. Otherwise fall back to reconstructing from individual course marks.
final cumulativeCwaProvider = Provider<double>((ref) {
  final pastSemesters = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  final currentCourses = ref.watch(coursesProvider).valueOrNull ?? [];

  final currentPairs = currentCourses
      .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
      .toList();

  // Find the most recently imported semester that has slip cumulative totals.
  // pastSemestersProvider is ordered by createdAt asc, so last = most recent.
  PastSemesterModel? anchor;
  if (pastSemesters.isNotEmpty) {
    try {
      anchor = pastSemesters.lastWhere(
        (s) =>
            s.cumulativeWeightedMarks != null &&
            s.cumulativeCreditsCalc != null,
      );
    } catch (_) {
      anchor = null;
    }
  }

  final hasSlipTotals = anchor != null;

  if (hasSlipTotals) {
    // Use KNUST's own running totals + current semester.
    double currentWeighted = 0;
    double currentCredits = 0;
    for (final c in currentPairs) {
      currentWeighted += c.creditHours * c.score;
      currentCredits += c.creditHours;
    }
    final totalWeighted = anchor.cumulativeWeightedMarks! + currentWeighted;
    final totalCredits = anchor.cumulativeCreditsCalc! + currentCredits;
    if (totalCredits == 0) return 0.0;
    return totalWeighted / totalCredits;
  }

  // Fallback: reconstruct from individual marks.
  final pastPairs = pastSemesters.map((sem) {
    return sem.courses
        .map((c) => (creditHours: c.creditHours, score: c.score))
        .toList();
  }).toList();

  return CwaCalculator.calculateCumulative(
    pastSemesters: pastPairs,
    currentCourses: currentPairs,
  );
});

/// Recorded cumulative CWA from official result history only.
final officialRecordedCwaProvider = Provider<double>((ref) {
  final pastSemesters = ref.watch(officialPastSemestersProvider);
  if (pastSemesters.isEmpty) return 0.0;

  PastSemesterModel? anchor;
  try {
    anchor = pastSemesters.lastWhere(
      (s) =>
          s.cumulativeWeightedMarks != null && s.cumulativeCreditsCalc != null,
    );
  } catch (_) {
    anchor = null;
  }

  if (anchor != null) {
    final credits = anchor.cumulativeCreditsCalc!;
    if (credits == 0) return 0.0;
    return anchor.cumulativeWeightedMarks! / credits;
  }

  final pastPairs = pastSemesters.map((sem) {
    return sem.courses
        .map((c) => (creditHours: c.creditHours, score: c.score))
        .toList();
  }).toList();

  return CwaCalculator.calculateCumulative(
    pastSemesters: pastPairs,
    currentCourses: const [],
  );
});

/// Total credit hours across all history (past + current semester).
final totalCreditsProvider = Provider<double>((ref) {
  final pastSemesters = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  final currentCourses = ref.watch(coursesProvider).valueOrNull ?? [];

  PastSemesterModel? anchor;
  if (pastSemesters.isNotEmpty) {
    try {
      anchor = pastSemesters.lastWhere((s) => s.cumulativeCreditsCalc != null);
    } catch (_) {
      anchor = null;
    }
  }

  final double currentCredits =
      currentCourses.fold(0.0, (sum, c) => sum + c.creditHours);

  if (anchor != null) {
    return anchor.cumulativeCreditsCalc! + currentCredits;
  }

  // Fallback.
  final pastPairs = pastSemesters.map((sem) {
    return sem.courses
        .map((c) => (creditHours: c.creditHours, score: c.score))
        .toList();
  }).toList();

  return CwaCalculator.totalCredits(
    pastSemesters: pastPairs,
    currentCourses: currentCourses
        .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
        .toList(),
  );
});

/// Gap between target and cumulative CWA. Positive = below target.
final cumulativeGapProvider = Provider<double>((ref) {
  final cumulative = ref.watch(cumulativeCwaProvider);
  final target = ref.watch(targetCwaProvider);
  return CwaCalculator.gap(cumulative, target);
});
