import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

class ReviewGateOverlay extends StatelessWidget {
  const ReviewGateOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: AppIconSizes.hero, color: Colors.grey.shade500),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Unlock your full weekly review with Premium.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.xxs2),
            Text(
              'See your wins, what to fix, and your #1 focus for next week.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'GHS 20/month · GHS 120/semester',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/subscribe'),
                icon: const Icon(Icons.arrow_forward, size: AppIconSizes.md),
                label: const Text('Upgrade to Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
