import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/presentation/providers/weekly_review_provider.dart';

class WeeklyReviewBanner extends ConsumerWidget {
  const WeeklyReviewBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(weeklyReviewProvider);

    if (!reviewState.hasReviewThisWeek || reviewState.hasViewedReview) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        ref.read(weeklyReviewProvider.notifier).markViewed();
        context.push('/ai/weekly-review');
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border(
            left: BorderSide(color: AppTheme.primary, width: 3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: AppIconSizes.lg, color: AppTheme.primary),
            const SizedBox(width: AppSpacing.xs2),
            const Expanded(
              child: Text(
                'Your week in review is ready \u2192',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
