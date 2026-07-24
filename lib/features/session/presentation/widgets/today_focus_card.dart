import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TodayFocusCard extends StatelessWidget {
  final int studiedMinutes;
  final int goalMinutes;
  final int sessionCount;
  final int streak;
  final bool streakSecured;
  final VoidCallback onStart;
  final VoidCallback onQuickStart;
  final VoidCallback onEditGoals;

  const TodayFocusCard({
    super.key,
    required this.studiedMinutes,
    required this.goalMinutes,
    required this.sessionCount,
    required this.streak,
    required this.streakSecured,
    required this.onStart,
    required this.onQuickStart,
    required this.onEditGoals,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress =
        goalMinutes == 0 ? 0.0 : (studiedMinutes / goalMinutes).clamp(0.0, 1.0);
    final remaining = (goalMinutes - studiedMinutes).clamp(0, goalMinutes);

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today’s Focus',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              IconButton(
                onPressed: onEditGoals,
                tooltip: 'Edit study goals',
                icon: const Icon(LucideIcons.settings2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              SizedBox(
                width: 86,
                height: 86,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 9,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color:
                            progress >= 1 ? AppTheme.success : scheme.primary,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_fmt(studiedMinutes)} of ${_fmt(goalMinutes)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      progress >= 1
                          ? 'Daily goal completed'
                          : '${_fmt(remaining)} remaining',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: progress >= 1
                                ? AppTheme.success
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _Pill(
                          icon: LucideIcons.timer,
                          label:
                              '$sessionCount ${sessionCount == 1 ? 'session' : 'sessions'}',
                        ),
                        _Pill(
                          icon: LucideIcons.flame,
                          label: streakSecured
                              ? '$streak-day streak secured'
                              : '$streak-day streak · ${_fmt((20 - studiedMinutes).clamp(0, 20))} left',
                          highlighted: streakSecured,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(LucideIcons.play),
              label: const Text('Start Focus Session'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onQuickStart,
              icon: const Icon(LucideIcons.zap),
              label: const Text('Quick 25 min'),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '${remainder}m';
    if (remainder == 0) return '${hours}h';
    return '${hours}h ${remainder}m';
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;

  const _Pill({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? AppTheme.success.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest,
        borderRadius: AppRadii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppIconSizes.xs,
            color: highlighted ? AppTheme.success : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
