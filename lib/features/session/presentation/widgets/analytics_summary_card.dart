import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_chip.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
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
          CampusSectionHeader(
            title: 'Today\'s progress',
            subtitle: analytics.sessionCount == 0
                ? 'No study logged yet. One focused block is enough to start well.'
                : 'A quick snapshot of how your focus time is building today.',
            trailing: CampusChip(
              label: hasPlan ? '$completionRate% complete' : 'Today',
              icon: hasPlan ? LucideIcons.target : LucideIcons.sunMedium,
              backgroundColor:
                  hasPlan ? AppColors.goldSoft : AppColors.surfaceMuted,
              foregroundColor: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 18,
            color: emphasize ? AppTheme.success : AppTheme.textSecondary,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color:
                          emphasize ? AppTheme.success : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
