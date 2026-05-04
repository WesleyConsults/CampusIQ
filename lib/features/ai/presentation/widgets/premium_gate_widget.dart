import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:go_router/go_router.dart';

class PremiumGateWidget extends StatelessWidget {
  const PremiumGateWidget();

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: AppIconSizes.hero, color: Colors.grey.shade600),
          SizedBox(height: AppSpacing.sm),
          Text(
            'You\'ve used your 3 free messages today.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Premium unlocks:',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.xs),
          ...[
            'Unlimited AI coach messages',
            'Weekly personalized study plan',
            'Exam prep question generator',
            'Smart streak coaching',
          ]
              .map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: AppIconSizes.md, color: Colors.green.shade600),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          feature,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ))
              .toList(),
          SizedBox(height: AppSpacing.md),
          Text(
            'GHS 20/month · GHS 120/semester',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/subscribe'),
              icon: Icon(Icons.arrow_forward),
              label: Text('Upgrade to Premium'),
            ),
          ),
        ],
      ),
    );
  }
}
