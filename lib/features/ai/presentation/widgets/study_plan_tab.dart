import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/presentation/providers/study_plan_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/plan_day_card.dart';

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

  Future<void> _generatePlan(WidgetRef ref) =>
      ref.read(studyPlanProvider.notifier).generatePlan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planState = ref.watch(studyPlanProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (planState.isInitializing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading your saved study plan...',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (planState.isGenerating) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(
                planState.isTakingLong
                    ? 'This is taking longer than usual. You can keep waiting or cancel and try again.'
                    : 'Creating your plan from your timetable and study history...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () =>
                    ref.read(studyPlanProvider.notifier).cancelGeneration(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    }

    if (planState.prerequisiteMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Add your academic data first',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                planState.prerequisiteMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/cwa'),
                    child: const Text('Add courses'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/timetable'),
                    child: const Text('Add timetable'),
                  ),
                  TextButton(
                    onPressed: () => _generatePlan(ref),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (planState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: AppSpacing.sm),
              Text(planState.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => _generatePlan(ref),
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
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 56,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'No study plan yet',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Generate a personalised 7-day plan based on your timetable and courses.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: () => _generatePlan(ref),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate My Study Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.xs2)),
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
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
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
              onPressed: () => _generatePlan(ref),
              icon: const Icon(Icons.refresh, size: AppIconSizes.md),
              label: const Text('Regenerate Plan'),
            ),
          ),
        ),
      ],
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
