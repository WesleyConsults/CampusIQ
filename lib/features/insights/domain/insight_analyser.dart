import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/insights/domain/insight.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';

class InsightAnalyser {
  InsightAnalyser({
    required this.sessions,
    required this.courses,
  });

  final List<StudySessionModel> sessions;
  final List<CourseModel> courses;

  List<Insight> analyse() {
    // Check 7 — no data fallback
    if (sessions.isEmpty) {
      return [
        const Insight(
          message: 'Start logging study sessions to unlock personalised insights.',
          type: InsightType.neutral,
          icon: '💡',
        ),
      ];
    }

    final insights = <Insight>[];
    final now = DateTime.now();

    // ── Check 1 — Best study day of the week ─────────────────────────────────
    final dayTotals = <int, int>{};
    for (final s in sessions) {
      final day = s.startTime.weekday;
      dayTotals[day] = (dayTotals[day] ?? 0) + s.durationMinutes;
    }
    if (dayTotals.isNotEmpty) {
      final best = dayTotals.entries.reduce((a, b) => a.value >= b.value ? a : b);
      const dayNames = {
        1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
        4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday',
      };
      insights.add(Insight(
        message:
            'You study most on ${dayNames[best.key]}. Schedule your hardest topics then.',
        type: InsightType.positive,
        icon: '📅',
      ));
    }

    // ── Check 2 — Neglected courses ───────────────────────────────────────────
    for (final course in courses) {
      final courseSessions =
          sessions.where((s) => s.courseCode == course.code).toList();

      if (courseSessions.isEmpty) {
        insights.add(Insight(
          message: "You haven't studied ${course.name} yet. It needs attention.",
          type: InsightType.warning,
          courseCode: course.code,
          icon: '⚠️',
        ));
      } else {
        final lastSession = courseSessions
            .reduce((a, b) => a.startTime.isAfter(b.startTime) ? a : b);
        final daysSince = now.difference(lastSession.startTime).inDays;
        if (daysSince >= 7) {
          insights.add(Insight(
            message:
                "You haven't studied ${course.name} in $daysSince days. It needs attention.",
            type: InsightType.warning,
            courseCode: course.code,
            icon: '⚠️',
          ));
        }
      }
    }

    // ── Check 3 — Best study hour window ─────────────────────────────────────
    final hourTotals = <int, int>{};
    for (final s in sessions) {
      final hour = s.startTime.hour;
      hourTotals[hour] = (hourTotals[hour] ?? 0) + s.durationMinutes;
    }
    if (hourTotals.isNotEmpty) {
      int bestWindowStart = 0;
      int bestWindowTotal = 0;
      for (int h = 0; h <= 22; h++) {
        final windowTotal = (hourTotals[h] ?? 0) + (hourTotals[h + 1] ?? 0);
        if (windowTotal > bestWindowTotal) {
          bestWindowTotal = windowTotal;
          bestWindowStart = h;
        }
      }
      final endHour = bestWindowStart + 2;
      insights.add(Insight(
        message:
            'Your most productive study window is $bestWindowStart:00–$endHour:00. Protect that time.',
        type: InsightType.positive,
        icon: '⏰',
      ));
    }

    // ── Check 4 — Late-night consistency drop ─────────────────────────────────
    final lateNight = sessions.where((s) => s.startTime.hour >= 21).toList();
    if (lateNight.length >= 3) {
      final avg =
          lateNight.fold(0, (sum, s) => sum + s.durationMinutes) / lateNight.length;
      if (avg < 30) {
        insights.add(const Insight(
          message:
              'Your sessions after 9PM tend to be short. Consider studying earlier.',
          type: InsightType.neutral,
          icon: '🌙',
        ));
      }
    }

    // ── Check 5 — Consistent course ──────────────────────────────────────────
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    CourseModel? mostConsistent;
    int maxCount = 0;
    for (final course in courses) {
      final count = sessions
          .where((s) =>
              s.courseCode == course.code &&
              s.startTime.isAfter(fourteenDaysAgo))
          .length;
      if (count >= 4 && count > maxCount) {
        maxCount = count;
        mostConsistent = course;
      }
    }
    if (mostConsistent != null) {
      insights.add(Insight(
        message:
            "You've been consistent with ${mostConsistent.name}. Keep that momentum.",
        type: InsightType.positive,
        icon: '🔥',
      ));
    }

    // ── Check 6 — Weekly hours trend ─────────────────────────────────────────
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStart = DateTime(monday.year, monday.month, monday.day);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final thisWeekMinutes = sessions
        .where((s) => !s.startTime.isBefore(thisWeekStart))
        .fold(0, (sum, s) => sum + s.durationMinutes);
    final lastWeekMinutes = sessions
        .where((s) =>
            s.startTime.isAfter(lastWeekStart) &&
            s.startTime.isBefore(thisWeekStart))
        .fold(0, (sum, s) => sum + s.durationMinutes);

    if (lastWeekMinutes > 0) {
      final changeRatio =
          (thisWeekMinutes - lastWeekMinutes) / lastWeekMinutes;
      if (changeRatio >= 0.2) {
        insights.add(const Insight(
          message: 'You studied more this week than last. Great progress.',
          type: InsightType.positive,
          icon: '📈',
        ));
      } else if (changeRatio <= -0.3) {
        insights.add(const Insight(
          message:
              'Your study hours dropped this week. Try to get back on track.',
          type: InsightType.warning,
          icon: '📉',
        ));
      }
    }

    return insights;
  }
}
