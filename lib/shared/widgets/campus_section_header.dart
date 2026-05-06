import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class CampusSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double subtitleSpacing;

  const CampusSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleStyle,
    this.subtitleStyle,
    this.subtitleSpacing = AppSpacing.xs,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle ?? textTheme.titleLarge),
              if (subtitle != null) ...[
                SizedBox(height: subtitleSpacing),
                Text(
                  subtitle!,
                  style: subtitleStyle ??
                      textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}
