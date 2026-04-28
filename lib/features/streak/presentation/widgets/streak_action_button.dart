import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

class StreakActionButton extends ConsumerWidget {
  const StreakActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyStreak = ref.watch(studyStreakProvider);
    final hasLossRisk = studyStreak.lossAversionMessage != null;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: () => context.go('/streak'),
        tooltip: 'View Streak',
        icon: Badge(
          isLabelVisible: hasLossRisk,
          label: const Text('!', style: TextStyle(fontSize: 8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${studyStreak.currentStreak}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                studyStreak.currentStreak > 0
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                color: studyStreak.currentStreak > 0 ? Colors.orange : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
