import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class CampusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;

  const CampusCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: _resolveCardColor(context),
        borderRadius: AppRadii.card,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07),
            blurRadius: isDark ? 22 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? AppSpacing.cardPadding,
        child: child,
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: card,
      ),
    );
  }

  Color _resolveCardColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (color == AppColors.surfaceMuted) {
      return colorScheme.surfaceContainerHighest;
    }
    if (color == AppColors.surface) {
      return colorScheme.surface;
    }
    if (color == AppColors.goldSoft) {
      return colorScheme.secondaryContainer;
    }
    return color ?? Theme.of(context).cardColor;
  }
}
