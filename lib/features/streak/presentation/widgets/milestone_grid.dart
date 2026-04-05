import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/milestone.dart';

class MilestoneGrid extends StatelessWidget {
  final List<Milestone> unlocked;
  final int currentStreak;

  const MilestoneGrid({
    super.key,
    required this.unlocked,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Badges',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text(
                  '${unlocked.length} / ${Milestone.all.length}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                    (i == 0 ||
                        unlocked.contains(Milestone.all[i - 1]));

                return _BadgeTile(
                  milestone: milestone,
                  isUnlocked: isUnlocked,
                  isNext: isNext,
                  currentStreak: currentStreak,
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
  final int currentStreak;

  const _BadgeTile({
    required this.milestone,
    required this.isUnlocked,
    required this.isNext,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.35,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppTheme.accent.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? AppTheme.accent.withValues(alpha: 0.4)
                : isNext
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : Colors.grey.shade200,
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
            const SizedBox(height: 4),
            Text(
              '${milestone.days}d',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isUnlocked ? AppTheme.primary : Colors.grey.shade400,
              ),
            ),
            if (isNext) ...[
              const SizedBox(height: 2),
              Text(
                '${milestone.days - currentStreak} left',
                style: const TextStyle(
                    fontSize: 9, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
