import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

class CourseStreakList extends StatelessWidget {
  /// courseCode → StreakResult
  final Map<String, StreakResult> streaks;

  const CourseStreakList({super.key, required this.streaks});

  @override
  Widget build(BuildContext context) {
    if (streaks.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = streaks.entries.toList()
      ..sort((a, b) => b.value.currentStreak.compareTo(a.value.currentStreak));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Per-course streaks',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            ...sorted.map((entry) => _CourseStreakRow(
                  courseCode: entry.key,
                  result: entry.value,
                )),
          ],
        ),
      ),
    );
  }
}

class _CourseStreakRow extends StatelessWidget {
  final String courseCode;
  final StreakResult result;

  const _CourseStreakRow({
    required this.courseCode,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isAlive = result.isAlive && result.currentStreak > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isAlive
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            child: Text(
              courseCode.length >= 2 ? courseCode.substring(0, 2) : courseCode,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isAlive ? AppTheme.primary : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseCode,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  result.studiedToday
                      ? 'Studied today ✓'
                      : result.currentStreak > 0
                          ? 'Last studied — keep going!'
                          : 'No streak yet',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                isAlive ? '🔥' : '💤',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                '${result.currentStreak}d',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isAlive ? AppTheme.primary : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
