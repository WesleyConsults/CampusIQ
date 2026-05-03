import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// A tappable free-time indicator rendered inside the grid.
/// Tapping pre-fills the add slot form with this time range.
class FreeBlockIndicator extends StatelessWidget {
  final FreeBlock block;
  final VoidCallback onTap;

  const FreeBlockIndicator(
      {super.key, required this.block, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topOffset =
        (block.startMinutes - TimetableConstants.gridStartMinutes) *
            TimetableConstants.pixelsPerMinute;
    final height = block.durationMinutes * TimetableConstants.pixelsPerMinute;
    final showLabel = height >= 36;
    final showTimeRange = height >= 56;

    return Positioned(
      top: topOffset,
      left: 6,
      right: 6,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            alignment: showLabel ? Alignment.centerLeft : Alignment.center,
            child: showLabel
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Free · ${block.durationMinutes} min',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (showTimeRange)
                        Text(
                          '${block.startLabel} - ${block.endLabel}',
                          style: TextStyle(
                            color:
                                AppTheme.textSecondary.withValues(alpha: 0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  )
                : Container(
                    width: 22,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  )),
      ),
    );
  }
}
