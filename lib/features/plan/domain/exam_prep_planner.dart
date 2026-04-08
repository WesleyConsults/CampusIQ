import 'dart:convert';
import 'package:campusiq/features/plan/data/models/exam_model.dart';
import 'package:campusiq/features/plan/domain/plan_task.dart';

/// Value object for a single exam topic.
class ExamTopic {
  final String name;
  final String priority; // 'high' | 'medium' | 'low'

  const ExamTopic({required this.name, required this.priority});

  Map<String, dynamic> toJson() => {'name': name, 'priority': priority};

  factory ExamTopic.fromJson(Map<String, dynamic> json) => ExamTopic(
        name: json['name'] as String,
        priority: (json['priority'] as String?) ?? 'medium',
      );
}

/// Pure Dart class — no Flutter imports.
/// Generates spaced-repetition [PlanTask] items based on upcoming exams.
class ExamPrepPlanner {
  final List<ExamModel> upcomingExams;
  final int examWeekStudyGoalMinutes;
  final DateTime currentDate;

  /// Preferred block size for exam prep sessions (minutes).
  static const int _sessionDuration = 100; // ~90-110 min

  ExamPrepPlanner({
    required this.upcomingExams,
    required this.examWeekStudyGoalMinutes,
    required this.currentDate,
  });

  /// Returns true if [date] falls within 14 days before any upcoming exam.
  bool isExamWindow(DateTime date) {
    final d = _dateOnly(date);
    for (final exam in upcomingExams) {
      final examDay = _dateOnly(exam.examDate);
      final diff = examDay.difference(d).inDays;
      if (diff >= 0 && diff <= 14) return true;
    }
    return false;
  }

  /// Generate spaced study tasks for [date].
  ///
  /// Each exam gets sessions allocated on specific days before its exam date:
  /// - 4+ credits → 3 sessions (5, 3, 1 day before)
  /// - 3 credits   → 2 sessions (3, 1 day before)
  /// - <3 credits  → 1 session  (1 day before)
  List<PlanTask> generateExamWeekPlan(DateTime date) {
    if (upcomingExams.isEmpty) return [];

    final today = _dateOnly(date);
    final tasks = <PlanTask>[];
    int sortOrder = 0;

    // Work through exams in chronological order (soonest first).
    final sorted = [...upcomingExams]
      ..sort((a, b) => a.examDate.compareTo(b.examDate));

    // Track slot allocation within today: start sessions at 8 AM, push 2 h each.
    int startHour = 8;

    for (final exam in sorted) {
      final sessionDates = _sessionDatesFor(exam);
      if (!sessionDates.contains(today)) continue;

      final sessionIndex = sessionDates.indexOf(today);
      final topics = _parseTopics(exam.topicsJson);

      // Pick topic for this session: high priority first.
      final sortedTopics = [...topics]..sort((a, b) {
          const order = {'high': 0, 'medium': 1, 'low': 2};
          return (order[a.priority] ?? 1).compareTo(order[b.priority] ?? 1);
        });

      final topicSuffix = sortedTopics.isNotEmpty
          ? ' — ${sortedTopics[sessionIndex % sortedTopics.length].name}'
          : '';

      tasks.add(PlanTask(
        taskType: 'study',
        label: 'Exam Prep: ${exam.courseName}$topicSuffix',
        courseCode: exam.courseCode,
        durationMinutes: _sessionDuration,
        startTime: DateTime(
            today.year, today.month, today.day, startHour, 0),
        isManual: false,
        sortOrder: sortOrder++,
      ));

      startHour += 2;
      if (startHour > 18) startHour = 8;
    }

    return tasks;
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  /// Returns the list of [DateTime] (date-only) on which a prep session
  /// should occur for [exam].
  List<DateTime> _sessionDatesFor(ExamModel exam) {
    final examDay = _dateOnly(exam.examDate);
    final count = _sessionCount(exam.creditHours);
    final offsets = switch (count) {
      3 => [5, 3, 1],
      2 => [3, 1],
      _ => [1],
    };
    return offsets
        .map((d) => examDay.subtract(Duration(days: d)))
        .where((d) => !d.isBefore(_dateOnly(currentDate)))
        .toList();
  }

  int _sessionCount(int credits) {
    if (credits >= 4) return 3;
    if (credits >= 3) return 2;
    return 1;
  }

  List<ExamTopic> _parseTopics(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      return (jsonDecode(json) as List)
          .map((e) => ExamTopic.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
