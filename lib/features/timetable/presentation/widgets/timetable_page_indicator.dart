import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';

/// Tappable three-label indicator for switching Class / Both / Personal view.
class TimetablePageIndicator extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const TimetablePageIndicator({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  static const _labels = ['Class', 'Both', 'Personal'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_labels.length, (i) {
        final isActive = i == currentPage;
        return GestureDetector(
          onTap: () => onPageSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _labels[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}
