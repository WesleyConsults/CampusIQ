import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_off_outlined,
                      size: 48, color: AppTheme.textSecondary),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'No sessions yet',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Start a study session to track your progress.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        // Compute weekly analytics scoped to this course
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
                padding: const EdgeInsets.only(bottom: 8),
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
