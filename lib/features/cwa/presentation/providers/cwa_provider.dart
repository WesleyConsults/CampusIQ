import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/constants/app_constants.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/cwa/data/repositories/past_result_repository.dart';
import 'package:campusiq/features/cwa/domain/academic_term.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';

const String _manualCwaBaselineLegacyKey = '__manual_cwa_baseline__';

enum CwaViewMode { semester, cumulative }

/// User preference repository for CWA semester settings.
final cwaPrefsRepositoryProvider = Provider<UserPrefsRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => UserPrefsRepository(isar));
});

/// Persisted grading system selected for new academic records.
final gradingSystemIdPrefsProvider = StreamProvider<String>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  final repo = UserPrefsRepository(isar);
  await repo.getPrefs();

  await for (final prefs in repo.watchPrefs()) {
    yield GradingSystem.byId(prefs?.gradingSystemId).id;
  }
});

/// Current grading system preference used by labels, ranges, and new records.
final gradingSystemProvider = Provider<GradingSystem>((ref) {
  final id = ref.watch(gradingSystemIdPrefsProvider).valueOrNull;
  return GradingSystem.byId(id);
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

/// Persisted target score preference for the active grading system.
final targetCwaPrefsProvider = StreamProvider<double>((ref) async* {
  final gradingSystem = ref.watch(gradingSystemProvider);
  final isar = await ref.watch(isarProvider.future);
  final repo = UserPrefsRepository(isar);
  await repo.getPrefs();

  await for (final prefs in repo.watchPrefs()) {
    final target = prefs?.targetCwa ?? gradingSystem.defaultTarget;
    yield target
        .clamp(gradingSystem.targetMin, gradingSystem.targetMax)
        .toDouble();
  }
});

/// Current target score used by gap calculations.
final targetCwaProvider = Provider<double>((ref) {
  final gradingSystem = ref.watch(gradingSystemProvider);
  final target = ref.watch(targetCwaPrefsProvider).valueOrNull;
  if (target == null) return gradingSystem.defaultTarget;
  return target;
});

/// In-flight score adjustments during slider drag (course id → score).
/// Applied on top of persisted scores so the hero bar updates live during a
/// drag without writing to Isar on every frame.
final inFlightScoreAdjustmentsProvider =
    StateProvider<Map<int, double>>((ref) => {});

/// Computed projected score from current courses, factoring in any in-flight
/// slider adjustments for instant UI feedback.
final projectedCwaProvider = Provider<double>((ref) {
  final courses = ref.watch(coursesProvider).valueOrNull ?? [];
  final adjustments = ref.watch(inFlightScoreAdjustmentsProvider);
  final pairs = courses.map((c) {
    final score = adjustments[c.id] ?? c.expectedScore;
    return (creditHours: c.creditHours, score: score);
  }).toList();
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

/// Live stream of all past semester results, ordered chronologically.
final pastSemestersProvider =
    StreamProvider<List<PastSemesterModel>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* PastResultRepository(isar).watchAll().map(
    (semesters) {
      final filtered = semesters
          .where(
              (semester) => semester.semesterKey != _manualCwaBaselineLegacyKey)
          .toList();
      filtered.sort(_compareSemestersChronologically);
      return filtered;
    },
  );
});

final pendingPastSemestersProvider = Provider<List<PastSemesterModel>>((ref) {
  final all = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  return all.where((semester) => semester.isPendingResults).toList();
});

final officialPastSemestersProvider = Provider<List<PastSemesterModel>>((ref) {
  final all = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  return all.where((semester) => !semester.isPendingResults).toList();
});

class ManualAcademicBaseline {
  final double score;
  final double credits;
  final String gradingSystemId;

  const ManualAcademicBaseline({
    required this.score,
    required this.credits,
    required this.gradingSystemId,
  });
}

final manualAcademicBaselineProvider =
    StreamProvider<ManualAcademicBaseline?>((ref) async* {
  final activeGradingSystem = ref.watch(gradingSystemProvider);
  final isar = await ref.watch(isarProvider.future);
  final repo = UserPrefsRepository(isar);
  await repo.getPrefs();

  await for (final prefs in repo.watchPrefs()) {
    final cwa = prefs?.manualBaselineCwa;
    final credits = prefs?.manualBaselineCredits;
    final baselineSystemId = GradingSystem.byId(
      prefs?.manualBaselineGradingSystemId ?? GradingSystem.cwa.id,
    ).id;
    if (cwa == null || credits == null || credits <= 0) {
      yield null;
    } else if (baselineSystemId != activeGradingSystem.id) {
      yield null;
    } else {
      yield ManualAcademicBaseline(
        score: cwa,
        credits: credits,
        gradingSystemId: baselineSystemId,
      );
    }
  }
});

class SemesterProgressionEntry {
  final PastSemesterModel semester;
  final double semesterCwa;
  final double cumulativeCwa;
  final double? semesterDelta;
  final double? cumulativeDelta;

  const SemesterProgressionEntry({
    required this.semester,
    required this.semesterCwa,
    required this.cumulativeCwa,
    this.semesterDelta,
    this.cumulativeDelta,
  });
}

bool _hasPastSemesterForKey(
  List<PastSemesterModel> pastSemesters,
  String semesterKey,
) {
  return pastSemesters.any((semester) => semester.semesterKey == semesterKey);
}

double _pastCourseScore(PastCourseEntry course, GradingSystem gradingSystem) {
  if (course.mark != null) return course.mark!;
  return gradingSystem.scoreForGrade(course.grade);
}

({double creditHours, double score}) _pastCoursePair(
  PastCourseEntry course,
  GradingSystem gradingSystem,
) {
  return (
    creditHours: course.creditHours,
    score: _pastCourseScore(course, gradingSystem),
  );
}

// ─── View mode toggle (per-session, not persisted) ────────────────────────────

final cwaViewModeProvider =
    StateProvider<CwaViewMode>((ref) => CwaViewMode.semester);

// ─── Cumulative providers ─────────────────────────────────────────────────────

/// Cumulative score across all past semesters + current semester.
///
/// Strategy (in priority order):
/// 1. If the latest chronological semester has slip-reported cumulative totals
///    (cumulativeWeightedMarks + cumulativeCreditsCalc), use those directly as
///    the historical baseline and add only the current semester on top.
///    This is the most accurate path — KNUST already computed the history.
/// 2. Otherwise fall back to reconstructing from individual course marks.
final cumulativeCwaProvider = Provider<double>((ref) {
  final pastSemesters = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  final manualBaseline = ref.watch(manualAcademicBaselineProvider).valueOrNull;
  final currentCourses = ref.watch(coursesProvider).valueOrNull ?? [];
  final activeSemesterKey = ref.watch(activeSemesterProvider);
  final shouldIncludeCurrentCourses =
      !_hasPastSemesterForKey(pastSemesters, activeSemesterKey);

  final currentPairs = shouldIncludeCurrentCourses
      ? currentCourses
          .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
          .toList()
      : <({double creditHours, double score})>[];

  if (pastSemesters.isEmpty && manualBaseline != null) {
    var currentWeighted = 0.0;
    var currentCredits = 0.0;
    for (final c in currentPairs) {
      currentWeighted += c.creditHours * c.score;
      currentCredits += c.creditHours;
    }

    final totalCredits = manualBaseline.credits + currentCredits;
    if (totalCredits == 0) return 0.0;
    final totalWeighted =
        (manualBaseline.score * manualBaseline.credits) + currentWeighted;
    return totalWeighted / totalCredits;
  }

  // Find the latest chronological semester that has slip cumulative totals.
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
    final gradingSystem = GradingSystem.byId(sem.gradingSystemId);
    return sem.courses.map((c) => _pastCoursePair(c, gradingSystem)).toList();
  }).toList();

  return CwaCalculator.calculateCumulative(
    pastSemesters: pastPairs,
    currentCourses: currentPairs,
  );
});

/// Recorded cumulative CWA from official result history only.
final officialRecordedCwaProvider = Provider<double>((ref) {
  final pastSemesters = ref.watch(officialPastSemestersProvider);
  final manualBaseline = ref.watch(manualAcademicBaselineProvider).valueOrNull;
  if (pastSemesters.isEmpty && manualBaseline != null) {
    return manualBaseline.score;
  }
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
    final gradingSystem = GradingSystem.byId(sem.gradingSystemId);
    return sem.courses.map((c) => _pastCoursePair(c, gradingSystem)).toList();
  }).toList();

  return CwaCalculator.calculateCumulative(
    pastSemesters: pastPairs,
    currentCourses: const [],
  );
});

/// Total credit hours across all history (past + current semester).
final totalCreditsProvider = Provider<double>((ref) {
  final pastSemesters = ref.watch(pastSemestersProvider).valueOrNull ?? [];
  final manualBaseline = ref.watch(manualAcademicBaselineProvider).valueOrNull;
  final currentCourses = ref.watch(coursesProvider).valueOrNull ?? [];
  final activeSemesterKey = ref.watch(activeSemesterProvider);
  final shouldIncludeCurrentCourses =
      !_hasPastSemesterForKey(pastSemesters, activeSemesterKey);

  PastSemesterModel? anchor;
  if (pastSemesters.isNotEmpty) {
    try {
      anchor = pastSemesters.lastWhere((s) => s.cumulativeCreditsCalc != null);
    } catch (_) {
      anchor = null;
    }
  }

  final double currentCredits = shouldIncludeCurrentCourses
      ? currentCourses.fold(0.0, (sum, c) => sum + c.creditHours)
      : 0.0;

  if (pastSemesters.isEmpty && manualBaseline != null) {
    return manualBaseline.credits + currentCredits;
  }

  if (anchor != null) {
    return anchor.cumulativeCreditsCalc! + currentCredits;
  }

  // Fallback.
  final pastPairs = pastSemesters.map((sem) {
    final gradingSystem = GradingSystem.byId(sem.gradingSystemId);
    return sem.courses.map((c) => _pastCoursePair(c, gradingSystem)).toList();
  }).toList();

  return CwaCalculator.totalCredits(
    pastSemesters: pastPairs,
    currentCourses: shouldIncludeCurrentCourses
        ? currentCourses
            .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
            .toList()
        : const [],
  );
});

/// Gap between target and cumulative CWA. Positive = below target.
final cumulativeGapProvider = Provider<double>((ref) {
  final cumulative = ref.watch(cumulativeCwaProvider);
  final target = ref.watch(targetCwaProvider);
  return CwaCalculator.gap(cumulative, target);
});

final semesterProgressionProvider =
    Provider<List<SemesterProgressionEntry>>((ref) {
  final semesters = <PastSemesterModel>[
    ...(ref.watch(pastSemestersProvider).valueOrNull ??
        const <PastSemesterModel>[]),
  ];
  semesters.sort(_compareSemestersChronologically);

  final entries = <SemesterProgressionEntry>[];
  double runningWeighted = 0;
  double runningCredits = 0;

  for (final semester in semesters) {
    final gradingSystem = GradingSystem.byId(semester.gradingSystemId);
    final semesterWeighted = semester.courses.fold<double>(
      0,
      (sum, course) =>
          sum + (course.creditHours * _pastCourseScore(course, gradingSystem)),
    );
    final semesterCredits = semester.courses.fold<double>(
      0,
      (sum, course) => sum + course.creditHours,
    );
    final semesterCwa = semester.reportedSemesterCwa ??
        (semesterCredits == 0 ? 0.0 : semesterWeighted / semesterCredits);

    if (semester.cumulativeWeightedMarks != null &&
        semester.cumulativeCreditsCalc != null &&
        semester.cumulativeCreditsCalc! > 0) {
      runningWeighted = semester.cumulativeWeightedMarks!;
      runningCredits = semester.cumulativeCreditsCalc!;
    } else {
      runningWeighted += semesterWeighted;
      runningCredits += semesterCredits;
    }

    final cumulativeCwa = semester.reportedCumulativeCwa ??
        (runningCredits == 0 ? 0.0 : runningWeighted / runningCredits);
    final previous = entries.isEmpty ? null : entries.last;

    entries.add(
      SemesterProgressionEntry(
        semester: semester,
        semesterCwa: semesterCwa,
        cumulativeCwa: cumulativeCwa,
        semesterDelta:
            previous == null ? null : semesterCwa - previous.semesterCwa,
        cumulativeDelta:
            previous == null ? null : cumulativeCwa - previous.cumulativeCwa,
      ),
    );
  }

  return entries;
});

int _compareSemestersChronologically(
  PastSemesterModel a,
  PastSemesterModel b,
) {
  final aKey = _semesterSortValue(a);
  final bKey = _semesterSortValue(b);
  final keyCompare = aKey.compareTo(bKey);
  if (keyCompare != 0) return keyCompare;
  return a.createdAt.compareTo(b.createdAt);
}

int _semesterSortValue(PastSemesterModel semester) {
  return academicTermSortValue(
    semesterKey: semester.semesterKey,
    semesterLabel: semester.semesterLabel,
    createdAt: semester.createdAt,
  );
}
