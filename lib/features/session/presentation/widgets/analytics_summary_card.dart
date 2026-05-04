import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_chip.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final DayAnalytics analytics;

  const AnalyticsSummaryCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final completionRate =
        (analytics.completionRate * 100).clamp(0, 200).toInt();
    final hasPlan = analytics.totalPlannedMinutes > 0;

    return CampusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stackHeader = constraints.maxWidth < 360;
              final badge = CampusChip(
                label: hasPlan ? '$completionRate%' : 'Today',
                icon: hasPlan ? LucideIcons.target : LucideIcons.sunMedium,
                backgroundColor:
                    hasPlan ? AppColors.goldSoft : AppColors.surfaceMuted,
                foregroundColor: AppTheme.textPrimary,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stackHeader) ...[
                    Text(
                      'Today\'s progress',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    badge,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Today\'s progress',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        badge,
                      ],
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    analytics.sessionCount == 0
                        ? 'No study logged yet. One focused block is enough to start well.'
                        : 'A quick snapshot of how your focus time is building today.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.45,
                        ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              mainAxisExtent: 112,
            ),
            children: [
              _MetricTile(
                label: 'Studied',
                value: _fmt(analytics.totalActualMinutes),
                icon: LucideIcons.clock3,
              ),
              _MetricTile(
                label: 'Sessions',
                value: '${analytics.sessionCount}',
                icon: LucideIcons.history,
              ),
              _MetricTile(
                label: hasPlan ? 'Planned' : 'Pace',
                value: hasPlan
                    ? _fmt(analytics.totalPlannedMinutes)
                    : 'Self-paced',
                icon:
                    hasPlan ? LucideIcons.calendarRange : LucideIcons.sparkles,
              ),
              _MetricTile(
                label: hasPlan ? 'Completion' : 'Mode',
                value: hasPlan ? '$completionRate%' : 'Flexible',
                icon: hasPlan ? LucideIcons.target : LucideIcons.bookOpen,
                emphasize: hasPlan && completionRate >= 100,
              ),
            ],
          ),
          if (hasPlan) ...[
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: analytics.completionRate.clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation<Color>(
                  completionRate >= 100 ? AppTheme.success : AppTheme.primary,
                ),
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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool emphasize;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: emphasize ? AppTheme.success : AppTheme.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      color:
                          emphasize ? AppTheme.success : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.2,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
