import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingWelcomeScreen extends ConsumerWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              OnboardingProgressDots(
                currentStep: OnboardingStep.welcome,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Main image
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.352,
                        ),
                        child: Image.asset(
                          'assets/unimate onboarding asset.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            'Welcome to',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'UniMate',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF636AE8), // Premium violet color
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () =>
                      ref.read(onboardingProvider.notifier).goNext(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
