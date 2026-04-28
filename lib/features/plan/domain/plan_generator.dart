import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/plan/domain/plan_task.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

/// Represents a free gap between class slots (pure Dart, no Flutter).
class _FreeBlock {
  final int startMinutes;
  final int endMinutes;

  const _FreeBlock(this.startMinutes, this.endMinutes);

  int get durationMinutes => endMinutes - startMinutes;

  DateTime toDateTime(DateTime date) => DateTime(
        date.year,
        date.month,
        date.day,
        startMinutes ~/ 60,
        startMinutes % 60,
      );
}

/// Pure Dart class — no Flutter imports.
/// Generates a prioritised list of [PlanTask] for a given day.
class PlanGenerator {
  final List<TimetableSlotModel> todaySlots;
  final List<CourseModel> courses;

  /// Study sessions from the past 14 days used to calculate priority.
  final List<StudySessionModel> recentSessions;

  /// Target total study minutes for the day (from user prefs, default 120).
  final int dailyStudyGoalMinutes;

  // Grid boundaries (minutes from midnight)
  static const int _gridStart = 360;  // 6 AM
  static const int _gridEnd = 1200;   // 8 PM
  static const int _minUsableBlock = 30;

  PlanGenerator({
    required this.todaySlots,
    required this.courses,
    required this.recentSessions,
    this.dailyStudyGoalMinutes = 120,
  });

  List<PlanTask> generate(DateTime date) {
    final tasks = <PlanTask>[];

    // ── 1. Attend tasks ──────────────────────────────────────────────────────
    final sortedSlots = [...todaySlots]
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    for (final slot in sortedSlots) {
      tasks.add(PlanTask(
        taskType: 'attend',
        label: 'Attend ${slot.courseCode} — ${slot.venue}',
        courseCode: slot.courseCode,
        durationMinutes: slot.durationMinutes,
        startTime: DateTime(
          date.year, date.month, date.day,
          slot.startMinutes ~/ 60, slot.startMinutes % 60,
        ),
        isManual: false,
        sortOrder: 0, // reassigned at the end
      ));
    }

    // ── 2. Free block detection ──────────────────────────────────────────────
    final freeBlocks = _detectFreeBlocks(sortedSlots);

    // ── 3. Course priority scoring ───────────────────────────────────────────
    final now = date;
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final scoredCourses = courses.map((course) {
      int score = (course.creditHours * 10).round();

      final lastSession = recentSessions
          .where((s) => s.courseCode == course.code)
          .map((s) => s.startTime)
          .fold<DateTime?>(null, (prev, t) => prev == null || t.isAfter(prev) ? t : prev);

      if (lastSession == null || lastSession.isBefore(sevenDaysAgo)) {
        score += 20;
      }
      if (course.expectedScore < 60) {
        score += 10;
      }
      return (course: course, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // ── 4. Study tasks ───────────────────────────────────────────────────────
    int studyMinutesAssigned = 0;
    final assignedCourseCodes = <String>{};

    for (final block in freeBlocks) {
      if (studyMinutesAssigned >= dailyStudyGoalMinutes) break;

      // Find the top priority course not yet assigned a block today
      final candidates = scoredCourses
          .where((sc) => !assignedCourseCodes.contains(sc.course.code))
          .toList();
      if (candidates.isEmpty) break;

      final candidate = candidates.first;
      assignedCourseCodes.add(candidate.course.code);
      studyMinutesAssigned += block.durationMinutes;

      tasks.add(PlanTask(
        taskType: 'study',
        label: 'Study ${candidate.course.name}',
        courseCode: candidate.course.code,
        durationMinutes: block.durationMinutes,
        startTime: block.toDateTime(date),
        isManual: false,
        sortOrder: 0,
      ));
    }


    // ── 6. Sort by start time; tasks without startTime go last ───────────────
    tasks.sort((a, b) {
      if (a.startTime == null && b.startTime == null) return 0;
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });

    // Assign sortOrder values
    return [
      for (int i = 0; i < tasks.length; i++)
        tasks[i].copyWith(sortOrder: i),
    ];
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<_FreeBlock> _detectFreeBlocks(List<TimetableSlotModel> sorted) {
    if (sorted.isEmpty) {
      // Entire grid is free
      const block = _FreeBlock(_gridStart, _gridEnd);
      return block.durationMinutes >= _minUsableBlock ? [block] : [];
    }

    final blocks = <_FreeBlock>[];

    // Gap before first class
    if (sorted.first.startMinutes > _gridStart) {
      final b = _FreeBlock(_gridStart, sorted.first.startMinutes);
      if (b.durationMinutes >= _minUsableBlock) blocks.add(b);
    }

    // Gaps between classes
    for (int i = 0; i < sorted.length - 1; i++) {
      final gapStart = sorted[i].endMinutes;
      final gapEnd = sorted[i + 1].startMinutes;
      if (gapEnd > gapStart) {
        final b = _FreeBlock(gapStart, gapEnd);
        if (b.durationMinutes >= _minUsableBlock) blocks.add(b);
      }
    }

    // Gap after last class
    if (sorted.last.endMinutes < _gridEnd) {
      final b = _FreeBlock(sorted.last.endMinutes, _gridEnd);
      if (b.durationMinutes >= _minUsableBlock) blocks.add(b);
    }

    return blocks;
  }
}
