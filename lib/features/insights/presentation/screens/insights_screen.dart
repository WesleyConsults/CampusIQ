import 'package:flutter/material.dart';
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'What your data says about you',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),

          if (sorted.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('💡', style: TextStyle(fontSize: 48)),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Log more sessions to generate insights.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
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
