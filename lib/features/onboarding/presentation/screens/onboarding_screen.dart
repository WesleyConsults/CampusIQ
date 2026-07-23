import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_about_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_grades_import_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_university_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_target_screen.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_notifications_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    if (state.isRestoring) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final step = state.step;

    return switch (step) {
      OnboardingStep.welcome => const OnboardingWelcomeScreen(),
      OnboardingStep.about => const OnboardingAboutScreen(),
      OnboardingStep.university => const OnboardingUniversityScreen(),
      OnboardingStep.target => const OnboardingTargetScreen(),
      OnboardingStep.notifications => const OnboardingNotificationsScreen(),
      OnboardingStep.gradesImport => const OnboardingGradesImportScreen(),
    };
  }
}
