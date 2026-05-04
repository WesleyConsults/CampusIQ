import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/session_tile.dart';
import 'package:campusiq/features/session/presentation/widgets/weekly_bar_chart.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/core/providers/isar_provider.dart';

class HubSessionsTab extends ConsumerWidget {
  final String courseCode;

  const HubSessionsTab({super.key, required this.courseCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);

    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allSessions) {
        final courseSessions = allSessions
            .where((s) => s.courseCode == courseCode)
            .toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));

        if (courseSessions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.timerOff,
                      size: AppIconSizes.hero, color: AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No sessions yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Start a study session to track your progress.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final weekStart = DateTime(monday.year, monday.month, monday.day);
        final weekly = PlannedActualAnalyser.analyseWeek(
          allSessions: courseSessions,
          classSlots: [],
          weekStart: weekStart,
        );

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.sm),
          itemCount: courseSessions.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: WeeklyBarChart(weekly: weekly),
              );
            }
            final session = courseSessions[index - 1];
            return SessionTile(
              session: session,
              onDelete: () async {
                final isarAsync = ref.read(isarProvider);
                final isar = isarAsync.valueOrNull;
                if (isar == null) return;
                final repo = SessionRepository(isar);
                await repo.deleteSession(session.id);
              },
            );
          },
        );
      },
    );
  }
}
