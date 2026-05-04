import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

class PlanFreeGateCard extends StatelessWidget {
  const PlanFreeGateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blurred fake plan preview
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Stack(
              children: [
                // Fake content underneath
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monday',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary)),
                      const SizedBox(height: AppSpacing.xs),
                      _fakeTile('MATH 251', '09:00 – 10:30',
                          'Highest leverage course'),
                      _fakeTile('EE 301', '14:00 – 15:30', 'CWA gap: 6 points'),
                      const SizedBox(height: AppSpacing.xs2),
                      const Text('Tuesday',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary)),
                      const SizedBox(height: AppSpacing.xs),
                      _fakeTile(
                          'CHEM 101', '10:00 – 11:00', 'No sessions this week'),
                    ],
                  ),
                ),
                // Blur overlay
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child:
                        Container(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ),
                // Lock icon centred
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 36, color: Colors.grey.shade700),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Upgrade to Premium for your\npersonalized study plan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Upgrade prompt
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  'Premium plan features:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...[
                  'AI-generated 7-day study plan',
                  'Respects your timetable free blocks',
                  'Prioritises your highest-gap courses',
                  'Regenerate anytime'
                ].map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        Icon(Icons.check_circle,
                            size: AppIconSizes.md, color: Colors.green.shade600),
                        const SizedBox(width: AppSpacing.xs),
                        Text(f, style: const TextStyle(fontSize: 13)),
                      ]),
                    )),
                const SizedBox(height: AppSpacing.sm),
                const Text('GHS 20/month · GHS 120/semester',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: AppSpacing.sm),
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
        ],
      ),
    );
  }

  Widget _fakeTile(String name, String time, String reason) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppTheme.primary, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500))),
          Text(time,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
