import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

/// The large flame card at the top of the Streak screen.
class StreakHeroCard extends StatelessWidget {
  final StreakResult streak;
  final String title;

  const StreakHeroCard({
    super.key,
    required this.streak,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isAlive = streak.isAlive && streak.currentStreak > 0;
    final backgroundColor = isAlive
        ? (isDark ? colorScheme.primaryContainer : AppColors.navy)
        : colorScheme.surface;
    final primaryTextColor = isAlive
        ? (isDark ? colorScheme.onPrimaryContainer : Colors.white)
        : colorScheme.onSurface;
    final secondaryTextColor = isAlive
        ? primaryTextColor.withValues(alpha: 0.76)
        : colorScheme.onSurfaceVariant;
    final mutedTextColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.md2),
        border: Border.all(
          color: isAlive && !isDark
              ? Colors.transparent
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          // Flame + count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isAlive ? '🔥' : '💤',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${streak.currentStreak}',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: isAlive ? colorScheme.secondary : mutedTextColor,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  ' days',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            streak.statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),

          // Loss aversion banner
          if (streak.lossAversionMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.xs2),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      streak.lossAversionMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isAlive ? primaryTextColor : colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(
                label: 'Best streak',
                value: '${streak.longestStreak}d',
                color: isAlive ? colorScheme.secondary : mutedTextColor,
                labelColor: secondaryTextColor,
              ),
              _Divider(color: secondaryTextColor.withValues(alpha: 0.24)),
              _Stat(
                label: 'Milestones',
                value: '${streak.unlockedMilestones.length}',
                color: isAlive ? primaryTextColor : mutedTextColor,
                labelColor: secondaryTextColor,
              ),
              _Divider(color: secondaryTextColor.withValues(alpha: 0.24)),
              _Stat(
                label: 'Next badge',
                value: streak.nextMilestone == null
                    ? 'All done!'
                    : '${streak.daysToNextMilestone}d',
                color: isAlive ? primaryTextColor : mutedTextColor,
                labelColor: secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color labelColor;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: AppSpacing.xxxs),
        Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 36,
      color: color,
    );
  }
}
