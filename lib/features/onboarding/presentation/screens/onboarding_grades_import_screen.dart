import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              IconButton(
                onPressed: notifier.goBack,
                icon: const Icon(LucideIcons.arrowLeft),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      'Know your ${system.label} before results day',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Import your registration slip or add courses manually. UniMate turns them into a live ${system.label} planner.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _GradesPreviewCard(targetLabel: system.targetLabel),
                    const SizedBox(height: AppSpacing.lg),
                    const _FeatureRow(
                      icon: LucideIcons.scanLine,
                      title: 'Import courses from a slip',
                      subtitle: 'Camera, image upload, or PDF import.',
                    ),
                    const _FeatureRow(
                      icon: LucideIcons.calculator,
                      title: 'See projected performance',
                      subtitle: 'Track course scores against your target.',
                    ),
                    const _FeatureRow(
                      icon: LucideIcons.trendingUp,
                      title: 'Plan the score you need',
                      subtitle: 'Spot gaps early instead of guessing later.',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: notifier.goNext,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

class _GradesPreviewCard extends StatelessWidget {
  final String targetLabel;

  const _GradesPreviewCard({required this.targetLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileUp, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Registration slip',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const _StatusBadge(label: 'Ready'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Expanded(
                child: _MetricBlock(label: 'Projected', value: '72.4'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricBlock(label: targetLabel, value: '70.0'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _CoursePreviewRow(code: 'CSM 251', score: '78%', progress: .78),
          const SizedBox(height: AppSpacing.sm),
          const _CoursePreviewRow(
              code: 'MATH 253', score: '71%', progress: .71),
          const SizedBox(height: AppSpacing.sm),
          const _CoursePreviewRow(
              code: 'STAT 255', score: '66%', progress: .66),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child:
                Icon(icon, color: colorScheme.primary, size: AppIconSizes.xl),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursePreviewRow extends StatelessWidget {
  final String code;
  final String score;
  final double progress;

  const _CoursePreviewRow({
    required this.code,
    required this.score,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            code,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadii.pill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.outlineVariant.withValues(
                alpha: 0.45,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          score,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs2,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: AppRadii.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
