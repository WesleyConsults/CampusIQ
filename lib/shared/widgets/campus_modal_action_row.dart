import 'package:flutter/material.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

class CampusModalActionRow extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final String? destructiveLabel;
  final VoidCallback? onDestructivePressed;
  final bool isPrimaryLoading;

  const CampusModalActionRow({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.destructiveLabel,
    this.onDestructivePressed,
    this.isPrimaryLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (destructiveLabel != null && onDestructivePressed != null)
        TextButton(
          onPressed: onDestructivePressed,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.warning,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          child: Text(destructiveLabel!),
        ),
      if (secondaryLabel != null)
        OutlinedButton(
          onPressed: onSecondaryPressed,
          child: Text(secondaryLabel!),
        ),
      ElevatedButton(
        onPressed: isPrimaryLoading ? null : onPrimaryPressed,
        child: isPrimaryLoading
            ? const SizedBox(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(primaryLabel),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = constraints.maxWidth < 420;

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                buttons[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            if (destructiveLabel != null && onDestructivePressed != null) ...[
              TextButton(
                onPressed: onDestructivePressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.warning,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: Text(destructiveLabel!),
              ),
              const Spacer(),
            ] else if (secondaryLabel == null) ...[
              const Spacer(),
            ],
            if (secondaryLabel != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondaryPressed,
                  child: Text(secondaryLabel!),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: isPrimaryLoading ? null : onPrimaryPressed,
                child: isPrimaryLoading
                    ? const SizedBox(
                        width: AppSpacing.lg,
                        height: AppSpacing.lg,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(primaryLabel),
              ),
            ),
          ],
        );
      },
    );
  }
}
