import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/review/domain/weekly_review_calculator.dart';
import 'package:campusiq/features/review/domain/weekly_review_data.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

/// Returns the most recent Monday at or before [date], with time zeroed.
DateTime _mondayOf(DateTime date) {
  final d = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(d.year, d.month, d.day);
}

/// A simple week identifier string, e.g. "2026_W14".
String weekKey(DateTime weekStart) {
  final jan1 = DateTime(weekStart.year, 1, 1);
  final weekNum = (weekStart.difference(jan1).inDays / 7).floor() + 1;
  return '${weekStart.year}_W$weekNum';
}

/// Review data for the current week.
final currentWeekReviewProvider = FutureProvider<WeeklyReviewData>((ref) async {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final courses = ref.watch(coursesProvider).valueOrNull ?? [];
  final streak = ref.watch(studyStreakProvider);
  final prefsRepo = ref.watch(userPrefsRepositoryProvider);

  final weekStart = _mondayOf(DateTime.now());
  final key = weekKey(weekStart);

  final note = await prefsRepo?.getWeeklyNote(key);

  final data = WeeklyReviewCalculator(
    allSessions: sessions,
    courses: courses,
    currentStreak: streak.currentStreak,
  ).calculate(weekStart);

  // Attach reflection note
  return WeeklyReviewData(
    weekStart: data.weekStart,
    weekEnd: data.weekEnd,
    totalMinutesStudied: data.totalMinutesStudied,
    bestDay: data.bestDay,
    bestDayMinutes: data.bestDayMinutes,
    mostNeglectedCourse: data.mostNeglectedCourse,
    mostStudiedCourse: data.mostStudiedCourse,
    currentStreak: data.currentStreak,
    streakGrew: data.streakGrew,
    reflectionNote: note,
  );
});

/// Review data for an arbitrary week (used by history).
final weekReviewProvider =
    FutureProvider.family<WeeklyReviewData, DateTime>((ref, weekStart) async {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final courses = ref.watch(coursesProvider).valueOrNull ?? [];
  final streak = ref.watch(studyStreakProvider);
  final prefsRepo = ref.watch(userPrefsRepositoryProvider);

  final key = weekKey(weekStart);
  final note = await prefsRepo?.getWeeklyNote(key);

  final data = WeeklyReviewCalculator(
    allSessions: sessions,
    courses: courses,
    currentStreak: streak.currentStreak,
  ).calculate(weekStart);

  return WeeklyReviewData(
    weekStart: data.weekStart,
    weekEnd: data.weekEnd,
    totalMinutesStudied: data.totalMinutesStudied,
    bestDay: data.bestDay,
    bestDayMinutes: data.bestDayMinutes,
    mostNeglectedCourse: data.mostNeglectedCourse,
    mostStudiedCourse: data.mostStudiedCourse,
    currentStreak: data.currentStreak,
    streakGrew: data.streakGrew,
    reflectionNote: note,
  );
});

/// Saves a reflection note for the current week.
final saveReflectionNoteProvider =
    FutureProvider.family<void, String>((ref, note) async {
  final prefsRepo = ref.read(userPrefsRepositoryProvider);
  if (prefsRepo == null) return;
  final weekStart = _mondayOf(DateTime.now());
  await prefsRepo.setWeeklyNote(weekKey(weekStart), note);
  ref.invalidate(currentWeekReviewProvider);
});
