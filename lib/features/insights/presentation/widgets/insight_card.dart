import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:campusiq/features/insights/domain/insight.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.insight,
    required this.index,
  });

  final Insight insight;
  final int index;
  static const Color _coursePillFill = Color(0xFFE6EBF5);
  static const Color _coursePillBorder = Color(0xFFB8C4D8);
  static const Color _coursePillText = Color(0xFF14213D);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: 60 * index),
          duration: 350.ms,
        ),
        SlideEffect(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
          delay: Duration(milliseconds: 60 * index),
          duration: 350.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emoji icon
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm2,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  insight.icon,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(height: 1.0),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm2,
                    horizontal: AppSpacing.xxs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        insight.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      if (insight.courseCode != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs2,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: _coursePillFill,
                            borderRadius: BorderRadius.circular(AppRadii.md2),
                            border:
                                Border.all(color: _coursePillBorder, width: 1),
                          ),
                          child: Text(
                            insight.courseCode!,
                            style: const TextStyle(
                              color: _coursePillText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
