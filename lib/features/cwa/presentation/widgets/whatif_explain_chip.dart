import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';

class WhatifExplainChip extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const WhatifExplainChip({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isLoading
                ? Colors.grey.shade100
                : AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLoading
                  ? Colors.grey.shade300
                  : AppTheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.grey.shade400,
                  ),
                )
              else
                const Icon(Icons.auto_awesome, size: 13, color: AppTheme.primary),
              const SizedBox(width: 5),
              Text(
                isLoading ? 'Explaining...' : 'Explain this \u2197',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isLoading ? Colors.grey.shade500 : AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
