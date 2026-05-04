import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

class NextMilestoneCard extends StatelessWidget {
  final StreakResult streak;

  const NextMilestoneCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final next = streak.nextMilestone;
    if (next == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text('💯', style: TextStyle(fontSize: 28)),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'All milestones unlocked. You are a legend.',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final progress = streak.longestStreak / next.days;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(next.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(next.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                        '${streak.daysToNextMilestone} day${streak.daysToNextMilestone == 1 ? '' : 's'} to unlock',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${next.days}d',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xs),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs2),
            Text(
              '${streak.longestStreak} / ${next.days} days',
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
