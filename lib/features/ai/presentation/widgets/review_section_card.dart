import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

class ReviewSectionCard extends StatelessWidget {
  final String title;
  final String body;
  final bool isBlurred;

  const ReviewSectionCard({
    super.key,
    required this.title,
    required this.body,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRect(
              child: Stack(
                children: [
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (isBlurred)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: theme.cardColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
