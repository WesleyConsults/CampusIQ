import 'package:campusiq/features/streak/domain/milestone.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

class StreakCalculator {
  /// Computes a StreakResult from a list of dates on which the student
  /// performed the tracked activity (studied, attended, etc.).
  ///
  /// [activeDates] — the dates to analyse (unsorted is fine)
  /// [today]       — inject for testability; defaults to DateTime.now()
  static StreakResult calculate({
    required List<DateTime> activeDates,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final todayNorm = _norm(now);

    if (activeDates.isEmpty) {
      return StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        isAlive: false,
        studiedToday: false,
        unlockedMilestones: [],
        nextMilestone: Milestone.all.first,
        daysToNextMilestone: Milestone.all.first.days,
      );
    }

    // Deduplicate and sort descending
    final unique = activeDates.map(_norm).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final studiedToday = unique.first == todayNorm;

    // Current streak: walk backwards from today (or yesterday if not
    // studied today — streak is still alive until midnight)
    int current = 0;
    DateTime cursor =
        studiedToday ? todayNorm : todayNorm.subtract(const Duration(days: 1));

    for (final date in unique) {
      if (date == cursor) {
        current++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (date.isBefore(cursor)) {
        break; // gap found
      }
    }

    // Longest streak: sliding window over sorted unique dates (ascending)
    final asc = unique.reversed.toList();
    int longest = 0;
    int run = 1;
    for (int i = 1; i < asc.length; i++) {
      final diff = asc[i].difference(asc[i - 1]).inDays;
      if (diff == 1) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }
    if (longest == 0 && asc.isNotEmpty) longest = 1;
    // current might exceed historical longest (it IS the new longest)
    if (current > longest) longest = current;

    final isAlive = current > 0;
    final unlocked = Milestone.all.where((m) => longest >= m.days).toList();
    final next = Milestone.nextAfter(longest);
    final daysToNext = next == null ? 0 : next.days - current;

    return StreakResult(
      currentStreak: current,
      longestStreak: longest,
      isAlive: isAlive,
      studiedToday: studiedToday,
      unlockedMilestones: unlocked,
      nextMilestone: next,
      daysToNextMilestone: daysToNext,
    );
  }

  /// Normalise a DateTime to midnight for date-only comparison.
  static DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);
}
