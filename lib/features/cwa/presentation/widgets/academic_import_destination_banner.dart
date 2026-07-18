import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_tokens.dart';

class AcademicImportDestinationBanner extends StatelessWidget {
  final String destination;
  final String description;
  final String? alternativeLabel;
  final VoidCallback? onAlternative;

  const AcademicImportDestinationBanner({
    super.key,
    required this.destination,
    required this.description,
    this.alternativeLabel,
    this.onAlternative,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.mapPin,
              color: colors.primary, size: AppIconSizes.lg),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adding to: $destination',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
                if (alternativeLabel != null && onAlternative != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  TextButton(
                    onPressed: onAlternative,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(alternativeLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
