import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

class CourseStats {
  final String courseCode;
  final String courseName;
  final int actualMinutes;
  final int plannedMinutes;

  const CourseStats({
    required this.courseCode,
    required this.courseName,
    required this.actualMinutes,
    required this.plannedMinutes,
  });

  int get gapMinutes => plannedMinutes - actualMinutes;
  bool get isOverStudied => actualMinutes > plannedMinutes;
  double get completionRate =>
      plannedMinutes == 0 ? 1.0 : (actualMinutes / plannedMinutes).clamp(0, 2);

  String get formattedActual {
    final h = actualMinutes ~/ 60;
    final m = actualMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String get formattedPlanned {
    final h = plannedMinutes ~/ 60;
    final m = plannedMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class DayAnalytics {
  final DateTime date;
  final List<StudySessionModel> sessions;
  final int totalActualMinutes;
  final int totalPlannedMinutes;
  final List<CourseStats> perCourse;

  const DayAnalytics({
    required this.date,
    required this.sessions,
    required this.totalActualMinutes,
    required this.totalPlannedMinutes,
    required this.perCourse,
  });

  int get sessionCount => sessions.length;
  double get completionRate => totalPlannedMinutes == 0
      ? 1.0
      : (totalActualMinutes / totalPlannedMinutes).clamp(0, 2);
}

class WeeklyAnalytics {
  final List<DayAnalytics> days;
  final int totalActualMinutes;
  final String mostStudiedCourse;
  final String leastStudiedCourse;

  const WeeklyAnalytics({
    required this.days,
    required this.totalActualMinutes,
    required this.mostStudiedCourse,
    required this.leastStudiedCourse,
  });
}

class PlannedActualAnalyser {
  /// Computes planned minutes from timetable slots for a given date/dayIndex.
  static Map<String, int> _plannedMinutesByCourse({
    required List<TimetableSlotModel> classSlots,
    required int dayIndex,
  }) {
    final planned = <String, int>{};

    for (final s in classSlots.where((s) => s.dayIndex == dayIndex)) {
      planned[s.courseCode] = (planned[s.courseCode] ?? 0) + s.durationMinutes;
    }

    return planned;
  }

  static DayAnalytics analyseDay({
    required DateTime date,
    required List<StudySessionModel> sessions,
    required List<TimetableSlotModel> classSlots,
  }) {
    final dayIndex = date.weekday - 1; // Mon=0 … Sat=5
    final planned = _plannedMinutesByCourse(
      classSlots: classSlots,
      dayIndex: dayIndex,
    );

    // Aggregate actual minutes per course
    final actual = <String, int>{};
    final names = <String, String>{};
    for (final s in sessions) {
      actual[s.courseCode] = (actual[s.courseCode] ?? 0) + s.durationMinutes;
      names[s.courseCode] = s.courseName;
    }

    // Merge keys from both planned and actual
    final allCodes = {...planned.keys, ...actual.keys};
    final perCourse = allCodes
        .map((code) => CourseStats(
              courseCode: code,
              courseName: names[code] ?? code,
              actualMinutes: actual[code] ?? 0,
              plannedMinutes: planned[code] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.actualMinutes.compareTo(a.actualMinutes));

    return DayAnalytics(
      date: date,
      sessions: sessions,
      totalActualMinutes: actual.values.fold(0, (s, v) => s + v),
      totalPlannedMinutes: planned.values.fold(0, (s, v) => s + v),
      perCourse: perCourse,
    );
  }

  static WeeklyAnalytics analyseWeek({
    required List<StudySessionModel> allSessions,
    required List<TimetableSlotModel> classSlots,
    required DateTime weekStart, // Monday of the week
  }) {
    final days = <DayAnalytics>[];
    for (int i = 0; i < 6; i++) {
      final date = weekStart.add(Duration(days: i));
      final daySessions = allSessions.where((s) {
        final d = s.startTime;
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
      }).toList();
      days.add(analyseDay(
        date: date,
        sessions: daySessions,
        classSlots: classSlots,
      ));
    }

    // Course totals across the week
    final weekActual = <String, int>{};
    final weekNames = <String, String>{};
    for (final s in allSessions) {
      weekActual[s.courseCode] =
          (weekActual[s.courseCode] ?? 0) + s.durationMinutes;
      weekNames[s.courseCode] = s.courseName;
    }

    String mostStudied = '';
    String leastStudied = '';
    if (weekActual.isNotEmpty) {
      final sorted = weekActual.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostStudied = weekNames[sorted.first.key] ?? sorted.first.key;
      leastStudied = weekNames[sorted.last.key] ?? sorted.last.key;
    }

    return WeeklyAnalytics(
      days: days,
      totalActualMinutes: weekActual.values.fold(0, (s, v) => s + v),
      mostStudiedCourse: mostStudied,
      leastStudiedCourse: leastStudied,
    );
  }

  /// Generates a plain-language feedback string for the student.
  static String feedbackForDay(DayAnalytics analytics) {
    if (analytics.sessionCount == 0) return 'No study sessions recorded today.';

    final rate = analytics.completionRate;
    final total = analytics.totalActualMinutes;
    final h = total ~/ 60;
    final m = total % 60;
    final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';

    if (analytics.totalPlannedMinutes == 0) {
      return 'You studied $timeStr today — great spontaneous effort!';
    }

    if (rate >= 1.0)
      return 'You hit your study target today. $timeStr studied. Keep it up!';
    if (rate >= 0.7)
      return 'Almost there — $timeStr studied, ${((1 - rate) * 100).toInt()}% left to hit your plan.';

    // Find most under-studied course
    final worst = analytics.perCourse
        .where(
            (c) => c.plannedMinutes > 0 && c.actualMinutes < c.plannedMinutes)
        .fold<CourseStats?>(
            null,
            (prev, c) =>
                prev == null || c.gapMinutes > prev.gapMinutes ? c : prev);

    if (worst != null) {
      return 'You are under-studying ${worst.courseCode} — ${worst.formattedPlanned} planned, only ${worst.formattedActual} done.';
    }
    return 'Keep going — $timeStr studied today.';
  }
}
