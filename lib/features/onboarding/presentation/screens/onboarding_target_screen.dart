import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingTargetScreen extends ConsumerWidget {
  const OnboardingTargetScreen({super.key});

  List<double> _getScalePoints(GradingSystem system) {
    if (system.id == 'cwa') {
      return [50.0, 60.0, 70.0, 80.0, 90.0];
    } else if (system.maxScore == 4.0) {
      return [2.0, 2.5, 3.0, 3.5, 4.0];
    } else if (system.maxScore == 5.0) {
      return [2.0, 3.0, 3.5, 4.0, 5.0];
    }
    final minVal = system.targetMin;
    final maxVal = system.targetMax;
    return List.generate(5, (i) => minVal + i * (maxVal - minVal) / 4);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(onboardingProvider);
    final system = state.gradingSystem;
    final notifier = ref.read(onboardingProvider.notifier);
    final screenHeight = MediaQuery.of(context).size.height;

    // Get dynamic scale points for under-slider labels
    final scalePoints = _getScalePoints(system);
    int closestIdx = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < scalePoints.length; i++) {
      final diff = (scalePoints[i] - state.target).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIdx = i;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              OnboardingProgressDots(currentStep: state.step),
              Row(
                children: [
                  IconButton(
                    onPressed: () => notifier.goBack(),
                    icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "What's your",
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'academic target?',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF636AE8), // Brand purple
                        height: 1.25,
                      ),
                    ),
                    const Spacer(),
                    // Centered illustration
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.22,
                        ),
                        child: Image.asset(
                          'assets/What is your academic target on boarding image.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Big Target Value Display Pill (Double tap/tap to edit grading system system)
                    Center(
                      child: InkWell(
                        onTap: () => _showGradingSystemPicker(
                          context,
                          ref,
                          system,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            system.formatScore(state.target, includeUnit: true),
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 48,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Purple target slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF636AE8),
                        inactiveTrackColor: colorScheme.outlineVariant.withValues(alpha: 0.6),
                        thumbColor: const Color(0xFF636AE8),
                        overlayColor: const Color(0xFF636AE8).withValues(alpha: 0.12),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 14,
                        ),
                      ),
                      child: Slider(
                        value: state.target,
                        min: system.targetMin.toDouble(),
                        max: system.targetMax.toDouble(),
                        divisions: system.sliderDivisions,
                        label: system.formatScore(state.target, includeUnit: true),
                        onChanged: notifier.setTarget,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    // Scale Points Labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(scalePoints.length, (i) {
                          final val = scalePoints[i];
                          final isSelected = i == closestIdx;
                          return Text(
                            system.id == 'cwa'
                                ? '${val.toStringAsFixed(0)}%'
                                : val.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF636AE8)
                                  : colorScheme.onSurfaceVariant,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Target CWA label below
                    Center(
                      child: Text(
                        '${system.targetLabel}: ${system.formatScore(state.target, includeUnit: true)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () => notifier.goNext(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Continue',
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
            ],
          ),
        ),
      ),
    );
  }

  void _showGradingSystemPicker(
    BuildContext context,
    WidgetRef ref,
    GradingSystem current,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          children: [
            Text(
              'Choose grading system',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final system in GradingSystem.all)
              ListTile(
                leading: Icon(
                  system.id == current.id
                      ? LucideIcons.circleCheck
                      : LucideIcons.circle,
                ),
                title: Text(system.plannerTitle),
                subtitle: Text(
                  '${system.minScore.toStringAsFixed(0)}-${system.maxScore.toStringAsFixed(0)} ${system.scoreUnit == '%' ? '%' : 'pts'}',
                ),
                onTap: () {
                  ref
                      .read(onboardingProvider.notifier)
                      .setGradingSystemId(system.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
