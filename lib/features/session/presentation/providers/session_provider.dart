import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/personal_slot_provider.dart';

final sessionRepositoryProvider = Provider<SessionRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => SessionRepository(isar));
});

/// Live stream of all sessions newest first
final allSessionsProvider = StreamProvider<List<StudySessionModel>>((ref) {
  final repo     = ref.watch(sessionRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchAllSessions(semester);
});

/// Today's analytics — recomputed whenever sessions or timetable changes
final todayAnalyticsProvider = Provider<DayAnalytics?>((ref) {
  final sessions    = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final classSlots  = ref.watch(allSlotsProvider).valueOrNull ?? [];
  final personalSlots = ref.watch(allPersonalSlotsProvider).valueOrNull ?? [];

  final today = DateTime.now();
  final todaySessions = sessions.where((s) {
    final d = s.startTime;
    return d.year == today.year && d.month == today.month && d.day == today.day;
  }).toList();

  return PlannedActualAnalyser.analyseDay(
    date: today,
    sessions: todaySessions,
    classSlots: classSlots,
    personalSlots: personalSlots,
  );
});

/// This week's analytics
final weeklyAnalyticsProvider = Provider<WeeklyAnalytics?>((ref) {
  final sessions      = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final classSlots    = ref.watch(allSlotsProvider).valueOrNull ?? [];
  final personalSlots = ref.watch(allPersonalSlotsProvider).valueOrNull ?? [];

  if (sessions.isEmpty) return null;

  final now       = DateTime.now();
  // Monday of the current week
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final monday    = DateTime(weekStart.year, weekStart.month, weekStart.day);

  return PlannedActualAnalyser.analyseWeek(
    allSessions: sessions,
    classSlots: classSlots,
    personalSlots: personalSlots,
    weekStart: monday,
  );
});
