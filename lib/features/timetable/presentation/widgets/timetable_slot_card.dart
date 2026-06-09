import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// A positioned slot card rendered inside the timetable grid.
/// Uses absolute positioning based on startMinutes/endMinutes.
/// [left] and [right] are pixel offsets from the parent Stack edges —
/// computed by DualLayerGrid to handle overlapping slots.
class TimetableSlotCard extends StatelessWidget {
  final TimetableSlotModel slot;
  final double left;
  final double width;
  final bool hasAlarm;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TimetableSlotCard({
    super.key,
    required this.slot,
    required this.left,
    required this.width,
    required this.hasAlarm,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final topOffset =
        (slot.startMinutes - TimetableConstants.gridStartMinutes) *
                TimetableConstants.pixelsPerMinute +
            TimetableConstants.gridTopPadding;
    final height = slot.durationMinutes * TimetableConstants.pixelsPerMinute;
    final accent = Color(slot.colorValue);
    final background = isDark
        ? Color.lerp(colorScheme.surface, accent, 0.20) ?? colorScheme.surface
        : Color.lerp(Colors.white, accent, 0.12) ?? Colors.white;
    final borderColor = accent.withValues(alpha: isDark ? 0.42 : 0.24);
    final primaryText = colorScheme.onSurface;
    final secondaryText = colorScheme.onSurfaceVariant;
    final showCourseName =
        height >= TimetableConstants.minSlotHeightForCourseName;
    final showMeta = height >= TimetableConstants.minSlotHeightForMeta;
    final showTimeFooter =
        height >= TimetableConstants.minSlotHeightForTimeFooter;
    final isCompact = !showCourseName;
    final secondaryMeta = slot.venue.isNotEmpty ? slot.venue : slot.slotType;

    return Positioned(
      top: topOffset,
      left: left,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              slot.courseCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ).copyWith(color: primaryText),
                            ),
                          ),
                          if (hasAlarm) ...[
                            const SizedBox(width: 2),
                            Icon(
                              Icons.alarm,
                              size: 10,
                              color: accent,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxxs),
                      Text(
                        slot.startTimeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ).copyWith(color: secondaryText),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              slot.courseCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ).copyWith(color: primaryText),
                            ),
                          ),
                          if (hasAlarm) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.alarm,
                              size: 12,
                              color: accent,
                            ),
                          ],
                        ],
                      ),
                      if (showCourseName) ...[
                        const SizedBox(height: AppSpacing.xxxs),
                        Text(
                          slot.courseName,
                          maxLines: showMeta ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ).copyWith(color: primaryText),
                        ),
                      ],
                      if (showMeta) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          secondaryMeta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ).copyWith(color: secondaryText),
                        ),
                      ],
                      if (showTimeFooter) ...[
                        const Spacer(),
                        Text(
                          '${slot.startTimeLabel} - ${slot.endTimeLabel} · ${slot.slotType}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ).copyWith(color: secondaryText),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
