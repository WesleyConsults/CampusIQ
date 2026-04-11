import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';

class WhatifResultCard extends StatelessWidget {
  final String? explanation;

  const WhatifResultCard({super.key, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final isLimit = explanation == '__limit_reached__';
    final text = isLimit
        ? 'Daily limit reached — upgrade for unlimited what-if explanations.'
        : explanation;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: text == null
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLimit
                    ? Colors.orange.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isLimit
                      ? Colors.orange.shade200
                      : Colors.blue.shade100,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isLimit ? Icons.lock_outline : Icons.auto_awesome,
                    size: 14,
                    color: isLimit ? Colors.orange.shade600 : AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: isLimit
                            ? Colors.orange.shade800
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
