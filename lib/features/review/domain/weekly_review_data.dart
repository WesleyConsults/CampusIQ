class WeeklyReviewData {
  const WeeklyReviewData({
    required this.weekStart,
    required this.weekEnd,
    required this.totalMinutesStudied,
    this.bestDay,
    required this.bestDayMinutes,
    this.mostNeglectedCourse,
    this.mostStudiedCourse,
    required this.currentStreak,
    required this.streakGrew,
    this.reflectionNote,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalMinutesStudied;
  final String? bestDay;
  final int bestDayMinutes;
  final String? mostNeglectedCourse;
  final String? mostStudiedCourse;
  final int currentStreak;
  final bool streakGrew;
  final String? reflectionNote;
}
