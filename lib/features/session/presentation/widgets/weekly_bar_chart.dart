import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';

/// Simple custom bar chart — no external charting library needed.
class WeeklyBarChart extends StatelessWidget {
  final WeeklyAnalytics weekly;

  const WeeklyBarChart({super.key, required this.weekly});

  @override
  Widget build(BuildContext context) {
    final maxMinutes = weekly.days
        .map((d) => d.totalActualMinutes)
        .fold(0, (a, b) => a > b ? a : b);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('This week',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text(
                  _fmt(weekly.totalActualMinutes),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(weekly.days.length, (i) {
                  final day = weekly.days[i];
                  final fill = maxMinutes == 0
                      ? 0.0
                      : day.totalActualMinutes / maxMinutes;
                  final isToday = day.date.weekday == DateTime.now().weekday;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (day.totalActualMinutes > 0)
                            Text(
                              _fmt(day.totalActualMinutes),
                              style: const TextStyle(
                                  fontSize: 8,
                                  color: AppTheme.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: (fill * 70).clamp(4, 70),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppTheme.primary
                                  : AppTheme.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayLabels[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isToday
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (weekly.mostStudiedCourse.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 0.5),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Insight(
                    icon: Icons.trending_up,
                    label: 'Most studied',
                    value: weekly.mostStudiedCourse,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: 16),
                  _Insight(
                    icon: Icons.trending_down,
                    label: 'Least studied',
                    value: weekly.leastStudiedCourse,
                    color: AppTheme.warning,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class _Insight extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Insight({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
