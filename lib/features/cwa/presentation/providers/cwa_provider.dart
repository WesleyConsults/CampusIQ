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
        (s) => s.cumulativeWeightedMarks != null && s.cumulativeCreditsCalc != null,
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
