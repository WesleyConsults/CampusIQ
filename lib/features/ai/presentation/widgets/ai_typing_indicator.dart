import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

class AiTypingIndicator extends StatelessWidget {
  const AiTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadii.lg),
              topRight: Radius.circular(AppRadii.lg),
              bottomLeft: Radius.circular(AppRadii.xs),
              bottomRight: Radius.circular(AppRadii.lg),
            ),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.soft,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: AppIconSizes.md,
                color: AppTheme.primary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'CampusIQ is thinking',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              _AnimatedDot(delay: 0),
              SizedBox(width: AppSpacing.xxs),
              _AnimatedDot(delay: 100),
              SizedBox(width: AppSpacing.xxs),
              _AnimatedDot(delay: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final int delay;

  const _AnimatedDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.xs,
      height: AppSpacing.xs,
      decoration: const BoxDecoration(
        color: AppColors.info,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scaleXY(
          end: 1.2,
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
          curve: Curves.easeInOut,
        )
        .then()
        .scaleXY(
          end: 1.0,
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }
}
