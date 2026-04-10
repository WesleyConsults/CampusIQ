import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PremiumGateWidget extends StatelessWidget {
  const PremiumGateWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 32, color: Colors.grey.shade600),
          SizedBox(height: 12),
          Text(
            'You\'ve used your 3 free messages today.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          Text(
            'Premium unlocks:',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
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
                            size: 16, color: Colors.green.shade600),
                        SizedBox(width: 8),
                        Text(
                          feature,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ))
              .toList(),
          SizedBox(height: 16),
          Text(
            'GHS 20/month · GHS 120/semester',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
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
