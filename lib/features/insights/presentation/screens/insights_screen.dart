import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/insights/domain/insight.dart';
import 'package:campusiq/features/insights/presentation/providers/insight_provider.dart';
import 'package:campusiq/features/insights/presentation/widgets/insight_card.dart';
import 'package:go_router/go_router.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);

    // Sort: warnings first, then positives, then neutrals/tips
    final sorted = [
      ...insights.where((i) => i.type == InsightType.warning),
      ...insights.where((i) => i.type == InsightType.positive),
      ...insights.where(
          (i) => i.type == InsightType.neutral || i.type == InsightType.tip),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Insights',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Header subtitle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxs,
              ),
              child: Text(
                'Patterns from your study sessions and academic activity',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),

          if (sorted.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('💡',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontSize: 48)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Complete study sessions to reveal useful patterns over time.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton.icon(
                        onPressed: () => context.go('/sessions'),
                        icon: const Icon(Icons.timer_outlined),
                        label: const Text('Start a Study Session'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
                bottom: AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => InsightCard(insight: sorted[i], index: i),
                  childCount: sorted.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
