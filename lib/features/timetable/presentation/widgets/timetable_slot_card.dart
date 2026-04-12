import 'package:flutter/material.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// A positioned slot card rendered inside the timetable grid.
/// Uses absolute positioning based on startMinutes/endMinutes.
/// [left] and [right] are pixel offsets from the parent Stack edges —
/// computed by DualLayerGrid to handle overlapping slots.
class TimetableSlotCard extends StatelessWidget {
  final TimetableSlotModel slot;
  final double left;
  final double right;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TimetableSlotCard({
    super.key,
    required this.slot,
    required this.left,
    required this.right,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final topOffset = (slot.startMinutes - TimetableConstants.gridStartMinutes) *
        TimetableConstants.pixelsPerMinute;
    final height = slot.durationMinutes * TimetableConstants.pixelsPerMinute;
    final color = Color(slot.colorValue);
    final isShort      = height < 40;  // < 40 min: code only
    final showFooter   = height >= 80; // >= 80 min: show time · type footer

    return Positioned(
      top: topOffset,
      left: left,
      right: right,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: isShort
              ? Text(
                  slot.courseCode,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slot.courseCode,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      slot.courseName,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.8),
                        fontSize: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    if (slot.venue.isNotEmpty)
                      Text(
                        slot.venue,
                        style: TextStyle(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 9,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    if (showFooter) ...[
                      const Spacer(),
                      Text(
                        '${slot.startTimeLabel} · ${slot.slotType}',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
