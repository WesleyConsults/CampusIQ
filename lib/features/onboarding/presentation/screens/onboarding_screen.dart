import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_university_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_programme_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_grading_system_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_target_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_notifications_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(
      onboardingProvider.select((s) => s.step),
    );

    return switch (step) {
      OnboardingStep.welcome => const OnboardingWelcomeScreen(),
      OnboardingStep.university => const OnboardingUniversityScreen(),
      OnboardingStep.programme => const OnboardingProgrammeScreen(),
      OnboardingStep.gradingSystem => const OnboardingGradingSystemScreen(),
      OnboardingStep.target => const OnboardingTargetScreen(),
      OnboardingStep.notifications => const OnboardingNotificationsScreen(),
    };
  }
}
