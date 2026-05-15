import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

Future<bool?> showCampusConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colorScheme = theme.colorScheme;
      final iconColor =
          destructive ? colorScheme.error : colorScheme.onSecondaryContainer;
      final iconBackground = destructive
          ? colorScheme.error.withValues(alpha: 0.12)
          : colorScheme.secondaryContainer;

      return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
        backgroundColor:
            theme.dialogTheme.backgroundColor ?? colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        titlePadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xs,
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: AppRadii.button,
              ),
              child: Icon(
                destructive
                    ? LucideIcons.triangleAlert
                    : LucideIcons.badgeCheck,
                color: iconColor,
                size: AppIconSizes.xl,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: destructive
                      ? ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warning,
                          foregroundColor: Colors.white,
                        )
                      : null,
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
