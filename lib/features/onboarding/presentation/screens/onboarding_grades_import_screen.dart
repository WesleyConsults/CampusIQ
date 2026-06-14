import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingGradesImportScreen extends ConsumerWidget {
  const OnboardingGradesImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Map selection to active visual highlights
    final isSlipSelected = state.startAction == OnboardingStartAction.importCourses;
    final isTimetableSelected = state.startAction == OnboardingStartAction.addTimetable;
    final isSkipSelected = state.startAction == null;

    final setupDestination = switch (state.startAction) {
      OnboardingStartAction.importCourses => '/cwa/import/registration',
      OnboardingStartAction.addTimetable => '/timetable/import',
      null => null,
    };
    final hasSetupShortcut = state.startAction != null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: OnboardingProgressDots(
                currentStep: state.step,
              ),
            ),
            // Header: Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    onPressed: notifier.goBack,
                    icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Scrollable Options List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    // Title
                    Text(
                      'Let\'s set',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'you up',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF636AE8), // Brand purple
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Subtitle
                    Text(
                      'Choose what you\'d like to do first.\nYou can always add more later.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Option 1: Import Registration Slip
                    _SetupOptionRow(
                      icon: LucideIcons.fileSpreadsheet,
                      iconColor: const Color(0xFF636AE8),
                      iconBgColor: const Color(0xFFEEF0FF),
                      title: 'Import Registration Slip',
                      description: 'Import your courses and current scores.',
                      isSelected: isSlipSelected,
                      onTap: () {
                        notifier.setStartAction(OnboardingStartAction.importCourses);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Option 2: Import Timetable
                    _SetupOptionRow(
                      icon: LucideIcons.calendarDays,
                      iconColor: const Color(0xFFE5A93C),
                      iconBgColor: const Color(0xFFFEF7E8),
                      title: 'Import Timetable',
                      description: 'Import your class schedule and find free study time.',
                      isSelected: isTimetableSelected,
                      onTap: () {
                        notifier.setStartAction(OnboardingStartAction.addTimetable);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Option 3: Skip for now
                    _SetupOptionRow(
                      icon: LucideIcons.star,
                      iconColor: const Color(0xFF2F8F6B),
                      iconBgColor: const Color(0xFFE8F8F0),
                      title: 'Skip for now',
                      description: 'Explore the app and set things up later.',
                      isSelected: isSkipSelected,
                      onTap: () {
                        // Clear startAction to represent skip path
                        ref.read(onboardingProvider.notifier).setStartAction(
                          // Use reflection or standard state modification to unset startAction
                          // The provider copyWith allows startAction to be unset or set to null
                          null as dynamic, 
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Private & Secure Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.lock,
                          size: 15,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Your data stays private and secure.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.lg,
                top: AppSpacing.xs,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          await notifier.complete();
                          if (!context.mounted) return;
                          context.go('/plan');
                          if (setupDestination == null) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              context.push(setupDestination);
                            }
                          });
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: const StadiumBorder(),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          hasSetupShortcut
                              ? 'Finish and open setup'
                              : 'Finish and go to Today',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupOptionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _SetupOptionRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF636AE8) 
                : colorScheme.outlineVariant.withValues(alpha: 0.8),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppIconSizes.feature - 2,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              LucideIcons.chevronRight,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}


