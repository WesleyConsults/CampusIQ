import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_tokens.dart';

class ImportSafetyNotice extends StatelessWidget {
  final String message;
  final bool requiresAttention;

  const ImportSafetyNotice({
    super.key,
    this.message =
        'Nothing has been saved yet. Review every item before you confirm.',
    this.requiresAttention = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = requiresAttention ? colors.error : AppColors.info;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              requiresAttention
                  ? LucideIcons.triangleAlert
                  : LucideIcons.shieldCheck,
              size: AppIconSizes.lg,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
