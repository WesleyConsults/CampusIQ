import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/insights/domain/insight.dart';
import 'package:campusiq/features/insights/presentation/providers/insight_provider.dart';
import 'package:campusiq/features/insights/presentation/widgets/insight_card.dart';

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
      backgroundColor: AppTheme.surface,
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
                'What your data says about you',
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
                        'Log more sessions to generate insights.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
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
