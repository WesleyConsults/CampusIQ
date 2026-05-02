import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/domain/streak_calculator.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

/// UserPrefs repository provider
final userPrefsRepositoryProvider = Provider<UserPrefsRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => UserPrefsRepository(isar));
});

/// Live stream of attended dates from UserPrefs
final attendedDatesProvider = StreamProvider<List<DateTime>>((ref) async* {
  final repo = ref.watch(userPrefsRepositoryProvider);
  if (repo == null) return;

  await for (final _ in repo.watchPrefs()) {
    final dates = await repo.getAttendedDates();
    yield dates;
  }
});

/// Study streak — derived from session records
final studyStreakProvider = Provider<StreakResult>((ref) {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];

  final activeDates = sessions.map((s) => s.startTime).toList();
  return StreakCalculator.calculate(activeDates: activeDates);
});

/// Per-course streak map — courseCode → StreakResult
final perCourseStreakProvider = Provider<Map<String, StreakResult>>((ref) {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final courses = ref.watch(coursesProvider).valueOrNull ?? [];

  final result = <String, StreakResult>{};
  for (final course in courses) {
    final courseDates = sessions
        .where((s) => s.courseCode == course.code)
        .map((s) => s.startTime)
        .toList();
    result[course.code] = StreakCalculator.calculate(activeDates: courseDates);
  }
  return result;
});

/// Attendance streak — derived from manually marked attended dates
final attendanceStreakProvider = Provider<StreakResult>((ref) {
  final datesAsync = ref.watch(attendedDatesProvider);
  final dates = datesAsync.valueOrNull ?? [];
  return StreakCalculator.calculate(activeDates: dates);
});
