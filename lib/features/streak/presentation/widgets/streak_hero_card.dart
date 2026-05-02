import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
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
    final isAlive = streak.isAlive && streak.currentStreak > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isAlive ? AppTheme.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
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
              const SizedBox(width: 8),
              Text(
                '${streak.currentStreak}',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: isAlive ? AppTheme.accent : Colors.grey.shade400,
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
                    color: isAlive ? Colors.white70 : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            streak.statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: isAlive ? Colors.white70 : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),

          // Loss aversion banner
          if (streak.lossAversionMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      streak.lossAversionMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAlive ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(
                label: 'Best streak',
                value: '${streak.longestStreak}d',
                color: isAlive ? AppTheme.accent : Colors.grey.shade500,
              ),
              _Divider(isAlive: isAlive),
              _Stat(
                label: 'Milestones',
                value: '${streak.unlockedMilestones.length}',
                color: isAlive ? Colors.white : Colors.grey.shade500,
              ),
              _Divider(isAlive: isAlive),
              _Stat(
                label: 'Next badge',
                value: streak.nextMilestone == null
                    ? 'All done!'
                    : '${streak.daysToNextMilestone}d',
                color: isAlive ? Colors.white : Colors.grey.shade500,
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

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isAlive;
  const _Divider({required this.isAlive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 36,
      color:
          isAlive ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade300,
    );
  }
}
