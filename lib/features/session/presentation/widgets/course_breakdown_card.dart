import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';

class CourseBreakdownCard extends StatelessWidget {
  final List<CourseStats> courses;

  const CourseBreakdownCard({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('By course',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            ...courses.map((c) => _CourseRow(stats: c)),
          ],
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final CourseStats stats;
  const _CourseRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final barFill = stats.completionRate.clamp(0.0, 1.0);
    final isOver = stats.isOverStudied;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => context.push('/course/${stats.courseCode}'),
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(stats.courseCode,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                Text(
                  stats.plannedMinutes > 0
                      ? '${stats.formattedActual} / ${stats.formattedPlanned}'
                      : stats.formattedActual,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: barFill,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOver
                      ? AppTheme.success
                      : barFill > 0.7
                          ? AppTheme.accent
                          : AppTheme.warning,
                ),
              ),
            ),
            if (stats.plannedMinutes > 0) ...[
              const SizedBox(height: 3),
              Text(
                isOver
                    ? 'Extra study — great!'
                    : 'Need ${_fmt(stats.gapMinutes)} more',
                style: TextStyle(
                  fontSize: 10,
                  color: isOver ? AppTheme.success : AppTheme.textSecondary,
                ),
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
