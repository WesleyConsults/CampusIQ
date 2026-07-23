import 'package:flutter/material.dart';

class CampusButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;
  final bool isLoading;
  final String? loadingLabel;

  const CampusButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveChild = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              if (loadingLabel != null) ...[
                const SizedBox(width: 12),
                Text(loadingLabel!),
              ],
            ],
          )
        : child;
    final effectiveOnPressed = isLoading ? null : onPressed;

    if (icon == null || isLoading) {
      return ElevatedButton(
        onPressed: effectiveOnPressed,
        child: effectiveChild,
      );
    }

    return ElevatedButton.icon(
      onPressed: effectiveOnPressed,
      icon: icon!,
      label: effectiveChild,
    );
  }
}
