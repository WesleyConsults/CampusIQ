import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/streak/domain/milestone.dart';

class MilestoneGrid extends StatelessWidget {
  final List<Milestone> unlocked;
  final int longestStreak;

  const MilestoneGrid({
    super.key,
    required this.unlocked,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Badges',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text(
                  '${unlocked.length} / ${Milestone.all.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: Milestone.all.length,
              itemBuilder: (context, i) {
                final milestone = Milestone.all[i];
                final isUnlocked = unlocked.contains(milestone);
                final isNext = !isUnlocked &&
                    (i == 0 || unlocked.contains(Milestone.all[i - 1]));

                return _BadgeTile(
                  milestone: milestone,
                  isUnlocked: isUnlocked,
                  isNext: isNext,
                  longestStreak: longestStreak,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Milestone milestone;
  final bool isUnlocked;
  final bool isNext;
  final int longestStreak;

  const _BadgeTile({
    required this.milestone,
    required this.isUnlocked,
    required this.isNext,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.35,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? colorScheme.secondaryContainer.withValues(alpha: 0.65)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: isUnlocked
                ? colorScheme.secondary.withValues(alpha: 0.45)
                : isNext
                    ? colorScheme.primary.withValues(alpha: 0.35)
                    : colorScheme.outlineVariant,
            width: isNext ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isUnlocked ? milestone.emoji : '🔒',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${milestone.days}d',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isUnlocked
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            if (isNext) ...[
              const SizedBox(height: AppSpacing.xxxs),
              Text(
                '${milestone.days - longestStreak} left',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
