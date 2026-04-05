import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_slot_card.dart';
import 'package:campusiq/features/timetable/presentation/widgets/free_block_indicator.dart';

/// The main scrollable daily grid. Renders time labels + slot cards + free blocks.
class TimetableGrid extends StatelessWidget {
  final List<TimetableSlotModel> slots;
  final List<FreeBlock> freeBlocks;
  final void Function(TimetableSlotModel) onSlotTap;
  final void Function(TimetableSlotModel) onSlotLongPress;
  final void Function(FreeBlock) onFreeBlockTap;
  final VoidCallback onEmptyCellTap;

  const TimetableGrid({
    super.key,
    required this.slots,
    required this.freeBlocks,
    required this.onSlotTap,
    required this.onSlotLongPress,
    required this.onFreeBlockTap,
    required this.onEmptyCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label column
          _TimeLabels(),
          // Slot column
          Expanded(
            child: GestureDetector(
              onTap: onEmptyCellTap,
              child: SizedBox(
                height: TimetableConstants.totalGridHeight,
                child: Stack(
                  children: [
                    // Hour separator lines
                    _HourLines(),
                    // Free blocks (rendered below slots)
                    ...freeBlocks.map((b) => FreeBlockIndicator(
                          block: b,
                          onTap: () => onFreeBlockTap(b),
                        )),
                    // Class slots
                    ...slots.map((s) => TimetableSlotCard(
                          slot: s,
                          columnWidth: double.infinity,
                          onTap: () => onSlotTap(s),
                          onLongPress: () => onSlotLongPress(s),
                        )),
                    // Current time indicator
                    _CurrentTimeIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders hour labels on the left column.
class _TimeLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hours = List.generate(
      TimetableConstants.gridEndHour - TimetableConstants.gridStartHour,
      (i) => TimetableConstants.gridStartHour + i,
    );

    return SizedBox(
      width: TimetableConstants.timeLabelWidth,
      height: TimetableConstants.totalGridHeight,
      child: Stack(
        children: hours.map((hour) {
          final topOffset = (hour - TimetableConstants.gridStartHour) *
              TimetableConstants.hourRowHeight;
          final label = hour == 0
              ? '12 AM'
              : hour < 12
                  ? '$hour AM'
                  : hour == 12
                      ? '12 PM'
                      : '${hour - 12} PM';
          return Positioned(
            top: topOffset - 6,
            left: 0,
            right: 4,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Horizontal lines at each hour boundary.
class _HourLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const hours = TimetableConstants.gridEndHour - TimetableConstants.gridStartHour;
    return SizedBox(
      height: TimetableConstants.totalGridHeight,
      child: Stack(
        children: List.generate(hours, (i) {
          final topOffset = i * TimetableConstants.hourRowHeight;
          return Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            child: Divider(height: 0.5, color: Colors.grey.shade200),
          );
        }),
      ),
    );
  }
}

/// Red line showing the current time. Only visible if today is the active day.
class _CurrentTimeIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    if (nowMinutes < TimetableConstants.gridStartMinutes ||
        nowMinutes > TimetableConstants.gridEndMinutes) {
      return const SizedBox.shrink();
    }

    final topOffset = (nowMinutes - TimetableConstants.gridStartMinutes) *
        TimetableConstants.pixelsPerMinute;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 1, color: Colors.red.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
