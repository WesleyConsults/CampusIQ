import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';

class OnboardingProgressDots extends StatelessWidget {
  final OnboardingStep currentStep;

  const OnboardingProgressDots({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = OnboardingStep.values;
    final currentIdx = steps.indexOf(currentStep);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (i) {
          final isActive = i == currentIdx;
          final isPast = i < currentIdx;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: AppRadii.pill,
              color: isActive || isPast
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          );
        }),
      ),
    );
  }
}
