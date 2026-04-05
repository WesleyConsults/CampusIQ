import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// A tappable free-time indicator rendered inside the grid.
/// Tapping pre-fills the add slot form with this time range.
class FreeBlockIndicator extends StatelessWidget {
  final FreeBlock block;
  final VoidCallback onTap;

  const FreeBlockIndicator({super.key, required this.block, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topOffset = (block.startMinutes - TimetableConstants.gridStartMinutes) *
        TimetableConstants.pixelsPerMinute;
    final height = block.durationMinutes * TimetableConstants.pixelsPerMinute;

    // Only show label if there's enough room
    final showLabel = height >= 30;

    return Positioned(
      top: topOffset,
      left: 2,
      right: 2,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppTheme.success.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: showLabel
              ? Text(
                  'Free · ${block.durationMinutes}min',
                  style: TextStyle(
                    color: AppTheme.success.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
