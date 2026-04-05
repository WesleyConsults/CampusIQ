import 'package:flutter/material.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/personal_slot_category.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// Personal slot card rendered in the grid.
/// Lighter opacity than class slots — visually recedes behind them in dual view.
class PersonalSlotCard extends StatelessWidget {
  final PersonalSlotModel slot;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  /// When true (dual view), render at reduced opacity so class slots read first
  final bool isDimmed;

  const PersonalSlotCard({
    super.key,
    required this.slot,
    required this.onTap,
    required this.onLongPress,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = PersonalSlotCategory.fromString(slot.categoryName);
    final color = Color(category.colorValue);
    final topOffset = (slot.startMinutes - TimetableConstants.gridStartMinutes) *
        TimetableConstants.pixelsPerMinute;
    final height = slot.durationMinutes * TimetableConstants.pixelsPerMinute;
    final isShort = height < 36;
    final opacity = isDimmed ? 0.45 : 1.0;

    return Positioned(
      top: topOffset,
      left: 2,
      right: 2,
      height: height,
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.10),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: color.withValues(alpha:0.5),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: isShort
                ? Text(
                    '${category.emoji} ${slot.displayLabel}',
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${category.emoji} ${slot.displayLabel}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        slot.startTimeLabel,
                        style: TextStyle(
                          color: color.withValues(alpha:0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
