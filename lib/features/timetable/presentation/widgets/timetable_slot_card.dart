import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
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
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TimetableSlotCard({
    super.key,
    required this.slot,
    required this.left,
    required this.width,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final topOffset =
        (slot.startMinutes - TimetableConstants.gridStartMinutes) *
            TimetableConstants.pixelsPerMinute;
    final height = slot.durationMinutes * TimetableConstants.pixelsPerMinute;
    final accent = Color(slot.colorValue);
    final background = Color.lerp(Colors.white, accent, 0.12) ?? Colors.white;
    final borderColor = accent.withValues(alpha: 0.24);
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: AppSpacing.xxs,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppRadii.sm),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slot.courseCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxxs),
                            Text(
                              slot.startTimeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.courseCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (showCourseName) ...[
                              const SizedBox(height: AppSpacing.xxxs),
                              Text(
                                slot.courseName,
                                maxLines: showMeta ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (showMeta) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                secondaryMeta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (showTimeFooter) ...[
                              const Spacer(),
                              Text(
                                '${slot.startTimeLabel} - ${slot.endTimeLabel} · ${slot.slotType}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
