import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingTargetScreen extends ConsumerWidget {
  const OnboardingTargetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(onboardingProvider);
    final system = state.gradingSystem;
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
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
                    icon: const Icon(LucideIcons.arrowLeft),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set your academic target',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'UniMate will use this to show the scores you need to protect your ${system.label}.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        onTap: () => _showGradingSystemPicker(
                          context,
                          ref,
                          state.gradingSystem,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.graduationCap,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      system.plannerTitle,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      state.university == null
                                          ? 'Detected from your school'
                                          : 'Detected from ${state.university!.shortName ?? state.university!.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(LucideIcons.chevronRight),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: AppRadii.card,
                              ),
                              child: Text(
                                system.formatScore(state.target,
                                    includeUnit: true),
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            if (system.usesLetterGrades &&
                                system.letterForScore(state.target) != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: AppSpacing.xs),
                                child: Text(
                                  system.letterForScore(state.target)!,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: colorScheme.primary,
                          inactiveTrackColor:
                              colorScheme.outlineVariant.withValues(alpha: 0.3),
                          thumbColor: colorScheme.primary,
                          overlayColor:
                              colorScheme.primary.withValues(alpha: 0.12),
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
                          label: system.formatScore(state.target,
                              includeUnit: true),
                          onChanged: notifier.setTarget,
                        ),
                      ),
                      Center(
                        child: Text(
                          '${system.targetLabel}: ${system.formatScore(state.target, includeUnit: true)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () => notifier.goNext(),
                          child: const Text('Continue',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
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
