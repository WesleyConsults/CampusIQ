import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/ai/presentation/providers/study_plan_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/plan_day_card.dart';
import 'package:campusiq/features/ai/presentation/widgets/plan_free_gate_card.dart';

class StudyPlanTab extends ConsumerWidget {
  final double bottomContentPadding;

  const StudyPlanTab({
    super.key,
    required this.bottomContentPadding,
  });

  static const _dayOrder = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final planState = ref.watch(studyPlanProvider);

    return isPremiumAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('Error loading subscription status')),
      data: (isPremium) {
        // Free users see gate card — no AI call ever happens
        if (!isPremium) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomContentPadding),
            child: const PlanFreeGateCard(),
          );
        }

        // Premium user — loading state
        if (planState.isLoading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Reading your timetable and sessions...',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        // Error state
        if (planState.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(planState.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(studyPlanProvider.notifier).generatePlan(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        // No plan generated yet
        if (!planState.isGenerated) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 56, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text(
                    'No study plan yet',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate a personalised 7-day plan based on your timetable and courses.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(studyPlanProvider.notifier).generatePlan(),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate My Study Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Plan exists — group slots by day
        final slotsByDay = <String, List<dynamic>>{};
        for (final day in _dayOrder) {
          slotsByDay[day] = planState.slots.where((s) => s.day == day).toList();
        }

        return CustomScrollView(
          slivers: [
            if (planState.plan != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Generated ${_formatDate(planState.plan!.generatedAt)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => PlanDayCard(
                  day: _dayOrder[i],
                  slots: (slotsByDay[_dayOrder[i]] ?? []).cast(),
                ),
                childCount: _dayOrder.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  bottomContentPadding,
                ),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(studyPlanProvider.notifier).generatePlan(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Regenerate Plan'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
