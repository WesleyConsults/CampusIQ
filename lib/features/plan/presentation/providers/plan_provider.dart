import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/data/repositories/daily_plan_repository.dart';
import 'package:campusiq/features/plan/domain/exam_prep_planner.dart';
import 'package:campusiq/features/plan/domain/plan_generator.dart';
import 'package:campusiq/features/plan/domain/plan_task.dart';
import 'package:campusiq/features/plan/presentation/providers/exam_mode_provider.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/timetable/domain/slot_expander.dart';
import 'package:campusiq/features/timetable/presentation/providers/personal_slot_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

// ── Repository ─────────────────────────────────────────────────────────────

final planRepositoryProvider = Provider<DailyPlanRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => DailyPlanRepository(isar));
});

// ── Daily study goal ────────────────────────────────────────────────────────

class DailyStudyGoalNotifier extends Notifier<int> {
  @override
  int build() => 120; // default 2 hours

  void setGoal(int minutes) => state = minutes;
}

final dailyStudyGoalMinutesProvider =
    NotifierProvider<DailyStudyGoalNotifier, int>(DailyStudyGoalNotifier.new);

// ── Today's task stream ─────────────────────────────────────────────────────

final todayPlanProvider = StreamProvider<List<DailyPlanTaskModel>>((ref) {
  final repo = ref.watch(planRepositoryProvider);
  if (repo == null) return const Stream.empty();
  final now = DateTime.now();
  return repo.watchTasksForDate(DateTime(now.year, now.month, now.day));
});

// ── Progress: (completed, total) ────────────────────────────────────────────

final planProgressProvider = Provider<(int, int)>((ref) {
  final tasks = ref.watch(todayPlanProvider).valueOrNull ?? [];
  final completed = tasks.where((t) => t.isCompleted).length;
  return (completed, tasks.length);
});

// ── Generate plan for a date ────────────────────────────────────────────────

final generatePlanProvider =
    FutureProvider.family<void, DateTime>((ref, date) async {
  final examModeActive =
      ref.read(examModeActiveProvider).valueOrNull ?? false;
  final upcomingExams = ref.read(upcomingExamsProvider);

  List<PlanTask> tasks;

  if (examModeActive && upcomingExams.isNotEmpty) {
    // Use exam planner when in exam window
    final prefsRepo = ref.read(userPrefsRepositoryProvider);
    final prefs = await prefsRepo?.getPrefs();
    final goalMinutes = prefs?.examDailyGoalMinutes ?? 360;

    final planner = ExamPrepPlanner(
      upcomingExams: upcomingExams,
      examWeekStudyGoalMinutes: goalMinutes,
      currentDate: date,
    );

    if (planner.isExamWindow(date)) {
      tasks = planner.generateExamWeekPlan(date);
    } else {
      tasks = _generateNormalPlan(ref, date);
    }
  } else {
    tasks = _generateNormalPlan(ref, date);
  }

  final repo = ref.read(planRepositoryProvider);
  if (repo == null) return;

  await repo.deleteAllTasksForDate(date);
  final models = tasks.map((t) => t.toDailyPlanTaskModel(date)).toList();
  await repo.saveTasks(models);

  for (final model in models) {
    await NotificationService.instance.schedulePlannedSessionReminder(model);
  }
});

// ── Helper: normal plan generation ─────────────────────────────────────────

List<PlanTask> _generateNormalPlan(Ref ref, DateTime date) {
  final dayIndex = date.weekday <= 6 ? date.weekday - 1 : 0;

  final allSlots = ref.read(allSlotsProvider).valueOrNull ?? [];
  final todaySlots = allSlots.where((s) => s.dayIndex == dayIndex).toList();

  final allPersonalSlots =
      ref.read(allPersonalSlotsProvider).valueOrNull ?? [];
  final expandedSlots = SlotExpander.expandForDay(
    stored: allPersonalSlots,
    targetDate: date,
    dayIndex: dayIndex,
  );

  final courses = ref.read(coursesProvider).valueOrNull ?? [];

  final allSessions = ref.read(allSessionsProvider).valueOrNull ?? [];
  final cutoff = date.subtract(const Duration(days: 14));
  final recentSessions =
      allSessions.where((s) => s.startTime.isAfter(cutoff)).toList();

  final goal = ref.read(dailyStudyGoalMinutesProvider);

  return PlanGenerator(
    todaySlots: todaySlots,
    expandedPersonalSlots: expandedSlots,
    courses: courses,
    recentSessions: recentSessions,
    dailyStudyGoalMinutes: goal,
  ).generate(date);
}
