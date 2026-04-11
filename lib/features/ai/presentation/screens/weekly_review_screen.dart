import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/ai/presentation/providers/weekly_review_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/review_section_card.dart';
import 'package:campusiq/features/ai/presentation/widgets/review_gate_overlay.dart';

class WeeklyReviewScreen extends ConsumerWidget {
  const WeeklyReviewScreen({super.key});

  String _formatMonday(String mondayDate) {
    try {
      final d = DateTime.parse(mondayDate);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return mondayDate;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(weeklyReviewProvider);
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Week in Review',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            if (reviewState.review != null)
              Text(
                'Week of ${_formatMonday(reviewState.review!.weekStartDate)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
              ),
          ],
        ),
      ),
      body: _buildBody(context, ref, reviewState, isPremiumAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    WeeklyReviewState reviewState,
    AsyncValue<bool> isPremiumAsync,
  ) {
    if (reviewState.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating your weekly review...',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    if (reviewState.error != null && reviewState.review == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(reviewState.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (!reviewState.hasReviewThisWeek || reviewState.review == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 56, color: AppTheme.textSecondary),
              SizedBox(height: 16),
              Text('No review yet',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text(
                'Your weekly review generates each Monday. Check back then.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final review = reviewState.review!;

    return isPremiumAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (isPremium) {
        return CustomScrollView(
          slivers: [
            // Summary — always visible
            SliverToBoxAdapter(
              child: ReviewSectionCard(
                title: 'Your week at a glance',
                body: review.summaryText,
              ),
            ),
            // Wins — blurred for free users
            SliverToBoxAdapter(
              child: ReviewSectionCard(
                title: 'Wins this week',
                body: review.wellText,
                isBlurred: !isPremium,
              ),
            ),
            // Watch out — blurred for free users
            SliverToBoxAdapter(
              child: ReviewSectionCard(
                title: 'Something to fix',
                body: review.watchText,
                isBlurred: !isPremium,
              ),
            ),
            // Focus — blurred for free users
            SliverToBoxAdapter(
              child: ReviewSectionCard(
                title: 'Your #1 priority',
                body: review.focusText,
                isBlurred: !isPremium,
              ),
            ),
            // Gate card for free users, follow-up button for premium
            SliverToBoxAdapter(
              child: !isPremium
                  ? const ReviewGateOverlay()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: TextButton.icon(
                        onPressed: () => context.push('/ai'),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Ask about this review'),
                        style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}
