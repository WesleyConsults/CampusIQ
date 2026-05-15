import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CampusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CampusChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = _resolveBackground(colorScheme);
    final fg = _resolveForeground(colorScheme);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _resolveBackground(ColorScheme colorScheme) {
    if (backgroundColor == null || backgroundColor == AppColors.goldSoft) {
      return colorScheme.secondaryContainer;
    }
    if (backgroundColor == AppColors.surfaceMuted ||
        backgroundColor == AppColors.surface) {
      return colorScheme.surfaceContainerHighest;
    }
    return backgroundColor!;
  }

  Color _resolveForeground(ColorScheme colorScheme) {
    if (foregroundColor == null || foregroundColor == AppColors.navy) {
      return colorScheme.onSecondaryContainer;
    }
    if (foregroundColor == AppTheme.primary) {
      return colorScheme.primary;
    }
    if (foregroundColor == AppTheme.textPrimary) {
      return colorScheme.onSurface;
    }
    if (foregroundColor == AppTheme.textSecondary) {
      return colorScheme.onSurfaceVariant;
    }
    return foregroundColor!;
  }
}
