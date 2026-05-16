import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingGradingSystemScreen extends ConsumerWidget {
  const OnboardingGradingSystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(onboardingProvider);
    final system = state.gradingSystem;
    final uniName = state.university?.name ?? 'your university';

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
                    onPressed: () =>
                        ref.read(onboardingProvider.notifier).goBack(),
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
                        'Your grading system',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$uniName uses ${system.plannerTitle}.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.graduationCap,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          system.plannerTitle,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _DetailRow(
                                    label: 'Scale',
                                    value:
                                        '${system.minScore.toStringAsFixed(0)}-${system.maxScore.toStringAsFixed(0)} ${system.scoreUnit == '%' ? '%' : 'pts'}',
                                  ),
                                  if (system.usesLetterGrades) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    const _DetailRow(
                                      label: 'Input',
                                      value: 'Letter grade',
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.xs),
                                  _DetailRow(
                                    label: 'Default target',
                                    value: system.formatScore(
                                      system.defaultTarget,
                                      includeUnit: true,
                                    ),
                                  ),
                                  if (system.gradeScale != null) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    const Divider(),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Grade scale',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Wrap(
                                      spacing: AppSpacing.xs,
                                      runSpacing: AppSpacing.xxs,
                                      children:
                                          system.gradeScale!.entries.map((e) {
                                        return Chip(
                                          label: Text(
                                            '${e.letter} = ${e.points.toStringAsFixed(1)}',
                                            style: theme.textTheme.labelSmall,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: () =>
                            _showOverridePicker(context, ref, system),
                        icon: const Icon(LucideIcons.settings, size: 18),
                        label: const Text('Not right? Change grading system'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () =>
                              ref.read(onboardingProvider.notifier).goNext(),
                          child: const Text(
                            'Looks right',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  void _showOverridePicker(
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
                  '${system.minScore.toStringAsFixed(0)}–${system.maxScore.toStringAsFixed(0)} ${system.scoreUnit == '%' ? '%' : 'pts'}',
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
