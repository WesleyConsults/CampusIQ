import 'package:campusiq/features/streak/domain/milestone.dart';

class StreakResult {
  /// Current active streak in days
  final int currentStreak;

  /// All-time longest streak
  final int longestStreak;

  /// True if the streak is still alive (studied today OR yesterday and
  /// today isn't over yet)
  final bool isAlive;

  /// True if studied today already
  final bool studiedToday;

  /// Milestones unlocked so far (longestStreak >= milestone.days)
  final List<Milestone> unlockedMilestones;

  /// Next milestone to aim for
  final Milestone? nextMilestone;

  /// Days remaining to next milestone
  final int daysToNextMilestone;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.isAlive,
    required this.studiedToday,
    required this.unlockedMilestones,
    required this.nextMilestone,
    required this.daysToNextMilestone,
  });

  /// Loss-aversion message shown when streak is alive but not studied today.
  String? get lossAversionMessage {
    if (studiedToday || currentStreak == 0) return null;
    if (currentStreak == 1) return "Study today to start your streak!";
    return "Don't lose your $currentStreak-day streak — study something today!";
  }

  /// Motivational message for the streak card header.
  String get statusMessage {
    if (currentStreak == 0) return 'Start your streak today!';
    if (studiedToday && currentStreak >= 7) return 'On fire! Keep going 🔥';
    if (studiedToday) return 'Great — streak intact!';
    return 'Study today to keep your streak alive';
  }
}
