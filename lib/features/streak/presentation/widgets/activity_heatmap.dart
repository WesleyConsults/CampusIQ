import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';

/// 4-week rolling activity heatmap — darker = more sessions that day.
class ActivityHeatmap extends StatelessWidget {
  /// date → number of sessions that day
  final Map<DateTime, int> activityByDay;

  const ActivityHeatmap({super.key, required this.activityByDay});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    // Build 28-day grid (4 weeks), starting from 27 days ago
    final days = List.generate(28, (i) {
      return todayNorm.subtract(Duration(days: 27 - i));
    });

    final maxActivity = activityByDay.values.fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last 4 weeks',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(4, (week) {
                return Expanded(
                  child: Column(
                    children: List.generate(7, (day) {
                      final index = week * 7 + day;
                      final date = days[index];
                      final norm = DateTime(date.year, date.month, date.day);
                      final count = activityByDay[norm] ?? 0;
                      final isToday = norm == todayNorm;

                      double intensity = 0;
                      if (maxActivity > 0 && count > 0) {
                        intensity = (count / maxActivity).clamp(0.2, 1.0);
                      }

                      return Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: count == 0
                                ? Colors.grey.shade100
                                : AppTheme.primary.withValues(alpha: intensity),
                            borderRadius: BorderRadius.circular(3),
                            border: isToday
                                ? Border.all(color: AppTheme.accent, width: 1.5)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Less',
                    style:
                        TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                const SizedBox(width: 4),
                ...List.generate(4, (i) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.primary.withValues(alpha: 0.15 + i * 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                const Text('More',
                    style:
                        TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
