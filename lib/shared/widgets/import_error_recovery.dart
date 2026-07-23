import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_tokens.dart';

class ImportErrorRecovery extends StatelessWidget {
  final String title;
  final String explanation;
  final String dataStatus;
  final String nextStep;
  final VoidCallback onTryAgain;
  final VoidCallback? onReviewAgain;
  final VoidCallback? onEnterManually;

  const ImportErrorRecovery({
    super.key,
    required this.title,
    required this.explanation,
    required this.dataStatus,
    required this.nextStep,
    required this.onTryAgain,
    this.onReviewAgain,
    this.onEnterManually,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            children: [
              Icon(
                LucideIcons.circleAlert,
                size: AppIconSizes.error,
                color: colors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                explanation,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              _RecoveryDetail(
                icon: LucideIcons.database,
                label: 'Your data',
                value: dataStatus,
              ),
              const SizedBox(height: AppSpacing.xs),
              _RecoveryDetail(
                icon: LucideIcons.arrowRight,
                label: 'What to do next',
                value: nextStep,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (onReviewAgain != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onReviewAgain,
                    icon: const Icon(LucideIcons.listChecks),
                    label: const Text('Return to Review'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onTryAgain,
                    icon: const Icon(LucideIcons.refreshCw),
                    label: const Text('Try Another Document'),
                  ),
                ),
              if (onReviewAgain != null) ...[
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTryAgain,
                    icon: const Icon(LucideIcons.refreshCw),
                    label: const Text('Start Over'),
                  ),
                ),
              ],
              if (onEnterManually != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  onPressed: onEnterManually,
                  icon: const Icon(LucideIcons.squarePen),
                  label: const Text('Enter Manually'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecoveryDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RecoveryDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppIconSizes.lg, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(value, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
