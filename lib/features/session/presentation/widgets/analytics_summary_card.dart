import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final DayAnalytics analytics;

  const AnalyticsSummaryCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final rate = (analytics.completionRate * 100).clamp(0, 200).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(
                label: 'Studied',
                value: _fmt(analytics.totalActualMinutes),
                color: Colors.white,
              ),
              _Stat(
                label: 'Planned',
                value: _fmt(analytics.totalPlannedMinutes),
                color: AppTheme.accent,
              ),
              _Stat(
                label: 'Sessions',
                value: '${analytics.sessionCount}',
                color: Colors.white,
              ),
              _Stat(
                label: 'Completion',
                value: '$rate%',
                color: rate >= 100 ? AppTheme.success : AppTheme.warning,
              ),
            ],
          ),
          if (analytics.totalPlannedMinutes > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: analytics.completionRate.clamp(0, 1),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  rate >= 100 ? AppTheme.success : AppTheme.accent,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ],
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

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
