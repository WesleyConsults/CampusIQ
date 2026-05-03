import 'package:flutter/material.dart';

class CampusButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;

  const CampusButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        child: child,
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon!,
      label: child,
    );
  }
}
