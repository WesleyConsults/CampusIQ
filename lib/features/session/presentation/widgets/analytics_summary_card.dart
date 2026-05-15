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
    final colorScheme = Theme.of(context).colorScheme;
    final completionRate =
        (analytics.completionRate * 100).clamp(0, 200).toInt();
    final hasPlan = analytics.totalPlannedMinutes > 0;

    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs2,
      ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs2),
                    badge,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Today\'s progress',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 16,
                                ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs2),
                        badge,
                      ],
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          GridView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.xs2,
              mainAxisSpacing: AppSpacing.xs2,
              mainAxisExtent: 48,
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
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: analytics.completionRate.clamp(0, 1),
                minHeight: 4,
                backgroundColor: colorScheme.surfaceContainerHighest,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.button,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppIconSizes.xs,
            color: emphasize ? AppTheme.success : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xxs2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: emphasize
                            ? AppTheme.success
                            : colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 9,
                        height: 1.1,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
