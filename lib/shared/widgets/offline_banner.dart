import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: Colors.grey.shade700,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs2, horizontal: AppSpacing.md),
      child: const Text(
        'You are offline. AI features require a connection.',
        style: TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
