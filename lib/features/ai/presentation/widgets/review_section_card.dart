import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRect(
              child: Stack(
                children: [
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (isBlurred)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(color: Colors.white.withValues(alpha: 0.1)),
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
