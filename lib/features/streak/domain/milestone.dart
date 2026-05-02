/// A streak milestone — unlocked when longestStreak >= days.
class Milestone {
  final int days;
  final String label;
  final String emoji;

  const Milestone({
    required this.days,
    required this.label,
    required this.emoji,
  });

  /// All milestones in the app — ordered ascending.
  static const List<Milestone> all = [
    Milestone(days: 3, label: '3-Day Starter', emoji: '🌱'),
    Milestone(days: 7, label: 'One Week', emoji: '🔥'),
    Milestone(days: 14, label: 'Two Weeks', emoji: '⚡'),
    Milestone(days: 21, label: 'Three Weeks', emoji: '💪'),
    Milestone(days: 30, label: 'One Month', emoji: '🏆'),
    Milestone(days: 40, label: '40-Day Grind', emoji: '🦁'),
    Milestone(days: 50, label: 'Halfway to 100', emoji: '🚀'),
    Milestone(days: 60, label: '60-Day Scholar', emoji: '🎓'),
    Milestone(days: 70, label: '70-Day Warrior', emoji: '⚔️'),
    Milestone(days: 80, label: '80-Day Champion', emoji: '🥇'),
    Milestone(days: 90, label: '90-Day Legend', emoji: '👑'),
    Milestone(days: 100, label: '100-Day Master', emoji: '💯'),
  ];

  /// Next milestone the student hasn't reached yet.
  static Milestone? nextAfter(int currentStreak) {
    try {
      return all.firstWhere((m) => m.days > currentStreak);
    } catch (_) {
      return null; // all milestones unlocked
    }
  }
}
