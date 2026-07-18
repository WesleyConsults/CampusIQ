import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_tokens.dart';

class WrongAcademicDocumentView extends StatelessWidget {
  final String detectedLabel;
  final String expectedLabel;
  final String actionLabel;
  final VoidCallback onSwitch;
  final VoidCallback onTryAgain;

  const WrongAcademicDocumentView({
    super.key,
    required this.detectedLabel,
    required this.expectedLabel,
    required this.actionLabel,
    required this.onSwitch,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.42),
            borderRadius: AppRadii.card,
            border: Border.all(color: colors.error.withValues(alpha: 0.32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.triangleAlert, size: 46, color: colors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This looks like $detectedLabel',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You opened $expectedLabel. Saving here would put these courses in the wrong place.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSwitch,
                  icon: const Icon(LucideIcons.arrowRightLeft),
                  label: Text(actionLabel),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: onTryAgain,
                child: const Text('Choose a different document'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
