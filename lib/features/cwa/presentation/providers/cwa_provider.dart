import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/cwa/data/repositories/past_result_repository.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/core/constants/app_constants.dart';

enum CwaViewMode { semester, cumulative }

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

// ─── Past results ─────────────────────────────────────────────────────────────

/// Repository for past semester results.
final pastResultRepositoryProvider = Provider<PastResultRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => PastResultRepository(isar));
});

/// Live stream of all past semester results, ordered by createdAt.
final pastSemestersProvider = StreamProvider<List<PastSemesterModel>>((ref) {
  final repo = ref.watch(pastResultRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchAll();
});

// ─── View mode toggle (per-session, not persisted) ────────────────────────────

final cwaViewModeProvider =
    StateProvider<CwaViewMode>((ref) => CwaViewMode.semester);

// ─── Cumulative providers ─────────────────────────────────────────────────────

/// Cumulative CWA across all past semesters + current semester.
final cumulativeCwaProvider = Provider<double>((ref) {
  final pastSemesters = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  final currentCourses = ref.watch(coursesProvider).valueOrNull ?? [];

  final pastPairs = pastSemesters.map((sem) {
    return sem.courses
        .map((c) => (creditHours: c.creditHours, score: c.score))
        .toList();
  }).toList();

  final currentPairs = currentCourses
      .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
      .toList();

  return CwaCalculator.calculateCumulative(
    pastSemesters: pastPairs,
    currentCourses: currentPairs,
  );
});

/// Total credit hours earned across all history (past + current semester).
final totalCreditsProvider = Provider<double>((ref) {
  final pastSemesters = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  final currentCourses = ref.watch(coursesProvider).valueOrNull ?? [];

  final pastPairs = pastSemesters.map((sem) {
    return sem.courses
        .map((c) => (creditHours: c.creditHours, score: c.score))
        .toList();
  }).toList();

  final currentPairs = currentCourses
      .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
      .toList();

  return CwaCalculator.totalCredits(
    pastSemesters: pastPairs,
    currentCourses: currentPairs,
  );
});

/// Gap between target and cumulative CWA. Positive = below target.
final cumulativeGapProvider = Provider<double>((ref) {
  final cumulative = ref.watch(cumulativeCwaProvider);
  final target = ref.watch(targetCwaProvider);
  return CwaCalculator.gap(cumulative, target);
});
