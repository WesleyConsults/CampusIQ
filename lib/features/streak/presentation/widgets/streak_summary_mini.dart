import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

/// Compact streak summary — used as a row of three streak types.
class StreakSummaryRow extends StatelessWidget {
  final StreakResult study;
  final StreakResult attendance;
  final int totalCourseStreaks;

  const StreakSummaryRow({
    super.key,
    required this.study,
    required this.attendance,
    required this.totalCourseStreaks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _MiniCard(
                emoji: '🔥',
                label: 'Study',
                days: study.currentStreak,
                isAlive: study.isAlive)),
        const SizedBox(width: 8),
        Expanded(
            child: _MiniCard(
                emoji: '🎓',
                label: 'Attendance',
                days: attendance.currentStreak,
                isAlive: attendance.isAlive)),
        const SizedBox(width: 8),
        Expanded(
            child: _MiniCard(
                emoji: '📚',
                label: 'Courses',
                days: totalCourseStreaks,
                isAlive: totalCourseStreaks > 0)),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int days;
  final bool isAlive;

  const _MiniCard({
    required this.emoji,
    required this.label,
    required this.days,
    required this.isAlive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            '$days${label == 'Courses' ? '' : 'd'}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isAlive ? AppTheme.primary : Colors.grey.shade400,
            ),
          ),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
