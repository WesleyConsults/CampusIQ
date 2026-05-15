import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_chip.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Simple custom bar chart — no external charting library needed.
class WeeklyBarChart extends StatelessWidget {
  final WeeklyAnalytics weekly;

  const WeeklyBarChart({
    super.key,
    required this.weekly,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxMinutes = weekly.days
        .map((day) => day.totalActualMinutes)
        .fold(0, (a, b) => a > b ? a : b);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S'];

    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CampusChip(
                label: 'This week',
                icon: LucideIcons.calendarDays,
                backgroundColor: AppColors.surfaceMuted,
                foregroundColor: AppTheme.textPrimary,
              ),
              const Spacer(),
              Text(
                _fmt(weekly.totalActualMinutes),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs2),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weekly.days.length, (index) {
                final day = weekly.days[index];
                final fill =
                    maxMinutes == 0 ? 0.0 : day.totalActualMinutes / maxMinutes;
                final isToday = day.date.weekday == DateTime.now().weekday;

                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          day.totalActualMinutes > 0
                              ? _fmt(day.totalActualMinutes)
                              : '0m',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 9,
                                    height: 1,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: (fill * 56).clamp(5, 56),
                          decoration: BoxDecoration(
                            color: isToday
                                ? colorScheme.primary
                                : colorScheme.primary.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          dayLabels[index],
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontSize: 10,
                                height: 1,
                                color: isToday
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w600,
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
            const SizedBox(height: AppSpacing.xxs2),
            Row(
              children: [
                Expanded(
                  child: _WeeklyInsight(
                    icon: LucideIcons.trendingUp,
                    label: 'Most studied',
                    value: weekly.mostStudiedCourse,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs2),
                Expanded(
                  child: _WeeklyInsight(
                    icon: LucideIcons.trendingDown,
                    label: 'Needs more time',
                    value: weekly.leastStudiedCourse,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class _WeeklyInsight extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeeklyInsight({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.button,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIconSizes.xs, color: color),
          const SizedBox(width: AppSpacing.xxs2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
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
