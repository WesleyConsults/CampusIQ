import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

final sessionRepositoryProvider = Provider<SessionRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => SessionRepository(isar));
});

typedef StudyGoals = ({int dailyMinutes, int weeklyMinutes});

final studyGoalsProvider = StreamProvider<StudyGoals>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  final repo = UserPrefsRepository(isar);
  final initial = await repo.getPrefs();
  yield (
    dailyMinutes: initial.dailyFocusGoalMinutes,
    weeklyMinutes: initial.weeklyFocusGoalMinutes,
  );
  await for (final prefs in repo.watchPrefs()) {
    if (prefs == null) continue;
    yield (
      dailyMinutes: prefs.dailyFocusGoalMinutes,
      weeklyMinutes: prefs.weeklyFocusGoalMinutes,
    );
  }
});

/// Live stream of all sessions newest first
final allSessionsProvider =
    StreamProvider<List<StudySessionModel>>((ref) async* {
  final semester = ref.watch(activeSemesterProvider);
  final isar = await ref.watch(isarProvider.future);
  yield* SessionRepository(isar).watchAllSessions(semester);
});

/// Today's analytics — recomputed whenever sessions or timetable changes
final todayAnalyticsProvider = Provider<DayAnalytics?>((ref) {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final classSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];

  final today = DateTime.now();
  final todaySessions = sessions.where((s) {
    final d = s.startTime;
    return d.year == today.year && d.month == today.month && d.day == today.day;
  }).toList();

  return PlannedActualAnalyser.analyseDay(
    date: today,
    sessions: todaySessions,
    classSlots: classSlots,
  );
});

/// This week's analytics
final weeklyAnalyticsProvider = Provider<WeeklyAnalytics?>((ref) {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final classSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];

  if (sessions.isEmpty) return null;

  final now = DateTime.now();
  // Monday of the current week
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final monday = DateTime(weekStart.year, weekStart.month, weekStart.day);

  return PlannedActualAnalyser.analyseWeek(
    allSessions: sessions,
    classSlots: classSlots,
    weekStart: monday,
  );
});

/// Weekly totals for every active course, including courses with no study time.
final weeklyCourseBalanceProvider = Provider<List<CourseStats>>((ref) {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final courses = ref.watch(coursesProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final end = start.add(const Duration(days: 7));
  final totals = <String, int>{};
  final names = <String, String>{};

  for (final session in sessions.where(
    (session) =>
        !session.startTime.isBefore(start) && session.startTime.isBefore(end),
  )) {
    totals[session.courseCode] =
        (totals[session.courseCode] ?? 0) + session.durationMinutes;
    names[session.courseCode] = session.courseName;
  }
  for (final course in courses) {
    totals.putIfAbsent(course.code, () => 0);
    names[course.code] = course.name;
  }

  return totals.entries
      .map(
        (entry) => CourseStats(
          courseCode: entry.key,
          courseName: names[entry.key] ?? entry.key,
          actualMinutes: entry.value,
          plannedMinutes: 0,
        ),
      )
      .toList()
    ..sort((a, b) => b.actualMinutes.compareTo(a.actualMinutes));
});
