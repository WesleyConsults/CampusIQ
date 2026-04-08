import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/plan/data/models/exam_model.dart';
import 'package:campusiq/features/plan/data/repositories/exam_repository.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

// ── Exam Repository ────────────────────────────────────────────────────────

final examRepositoryProvider = Provider<ExamRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => ExamRepository(isar));
});

// ── All exams (live stream) ────────────────────────────────────────────────

final examsProvider = StreamProvider<List<ExamModel>>((ref) {
  final repo = ref.watch(examRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchAll();
});

// ── Upcoming exams sorted by date (not complete, future) ──────────────────

final upcomingExamsProvider = Provider<List<ExamModel>>((ref) {
  final all = ref.watch(examsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  return all
      .where((e) => !e.isComplete && e.examDate.isAfter(now))
      .toList()
    ..sort((a, b) => a.examDate.compareTo(b.examDate));
});

// ── Exam mode active flag (from UserPrefsModel stream) ─────────────────────

final examModeActiveProvider = StreamProvider<bool>((ref) async* {
  final repo = ref.watch(userPrefsRepositoryProvider);
  if (repo == null) {
    yield false;
    return;
  }
  await for (final prefs in repo.watchPrefs()) {
    yield prefs?.examModeActive ?? false;
  }
});

// ── Exam daily goal in minutes (from UserPrefsModel stream) ───────────────

final examDailyGoalProvider = StreamProvider<int>((ref) async* {
  final repo = ref.watch(userPrefsRepositoryProvider);
  if (repo == null) {
    yield 360;
    return;
  }
  await for (final prefs in repo.watchPrefs()) {
    yield prefs?.examDailyGoalMinutes ?? 360;
  }
});

// ── Should auto-activate (14-day window check) ────────────────────────────
//
// Returns true when the nearest upcoming exam is ≤ 14 days away and exam
// mode is not already active.

final shouldAutoActivateExamModeProvider = Provider<bool>((ref) {
  final exams = ref.watch(upcomingExamsProvider);
  if (exams.isEmpty) return false;

  final examModeActive =
      ref.watch(examModeActiveProvider).valueOrNull ?? false;
  if (examModeActive) return false;

  final daysToFirst =
      exams.first.examDate.difference(DateTime.now()).inDays;
  return daysToFirst <= 14 && daysToFirst > 0;
});
