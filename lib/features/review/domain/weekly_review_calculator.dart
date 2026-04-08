import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/review/domain/weekly_review_data.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';

class WeeklyReviewCalculator {
  WeeklyReviewCalculator({
    required this.allSessions,
    required this.courses,
    required this.currentStreak,
  });

  final List<StudySessionModel> allSessions;
  final List<CourseModel> courses;
  final int currentStreak;

  WeeklyReviewData calculate(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekEndInclusive = DateTime(
        weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);

    // Sessions within the week
    final weekSessions = allSessions.where((s) {
      return !s.startTime.isBefore(weekStart) &&
          !s.startTime.isAfter(weekEndInclusive);
    }).toList();

    // Total minutes studied
    final totalMinutes =
        weekSessions.fold(0, (sum, s) => sum + s.durationMinutes);

    // Best study day
    const dayNames = {
      1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
      4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday',
    };
    final dayTotals = <int, int>{};
    for (final s in weekSessions) {
      final day = s.startTime.weekday;
      dayTotals[day] = (dayTotals[day] ?? 0) + s.durationMinutes;
    }
    String? bestDay;
    int bestDayMinutes = 0;
    if (dayTotals.isNotEmpty) {
      final best =
          dayTotals.entries.reduce((a, b) => a.value >= b.value ? a : b);
      bestDay = dayNames[best.key];
      bestDayMinutes = best.value;
    }

    // Per-course totals this week
    final courseTotals = <String, int>{};
    for (final course in courses) {
      courseTotals[course.code] = 0;
    }
    for (final s in weekSessions) {
      courseTotals[s.courseCode] =
          (courseTotals[s.courseCode] ?? 0) + s.durationMinutes;
    }

    // Most studied course (highest minutes)
    String? mostStudiedCourse;
    if (courseTotals.isNotEmpty) {
      final entry = courseTotals.entries
          .where((e) => e.value > 0)
          .fold<MapEntry<String, int>?>(null,
              (best, e) => best == null || e.value > best.value ? e : best);
      if (entry != null) {
        mostStudiedCourse = courses
            .where((c) => c.code == entry.key)
            .map((c) => c.name)
            .firstOrNull;
      }
    }

    // Most neglected course (fewest minutes — zero counts)
    String? mostNeglectedCourse;
    if (courses.isNotEmpty) {
      final entry = courseTotals.entries.reduce(
          (least, e) => e.value <= least.value ? e : least);
      mostNeglectedCourse = courses
          .where((c) => c.code == entry.key)
          .map((c) => c.name)
          .firstOrNull;
    }

    return WeeklyReviewData(
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalMinutesStudied: totalMinutes,
      bestDay: bestDay,
      bestDayMinutes: bestDayMinutes,
      mostNeglectedCourse: mostNeglectedCourse,
      mostStudiedCourse: mostStudiedCourse,
      currentStreak: currentStreak,
      streakGrew: currentStreak > 0,
      reflectionNote: null, // populated by provider from UserPrefs
    );
  }
}
