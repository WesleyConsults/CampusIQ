import 'package:flutter/material.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_slot_card.dart';
import 'package:campusiq/features/timetable/presentation/widgets/personal_slot_card.dart';
import 'package:campusiq/features/timetable/presentation/widgets/free_block_indicator.dart';

/// Which layers to show.
enum GridLayerMode { classOnly, personalOnly, both }

/// Renders the combined timetable grid with configurable layer visibility.
class DualLayerGrid extends StatelessWidget {
  final List<TimetableSlotModel> classSlots;
  final List<PersonalSlotModel> personalSlots;
  final List<FreeBlock> freeBlocks;
  final GridLayerMode mode;
  final void Function(TimetableSlotModel) onClassSlotTap;
  final void Function(PersonalSlotModel) onPersonalSlotTap;
  final void Function(FreeBlock) onFreeBlockTap;
  final VoidCallback onEmptyTap;

  const DualLayerGrid({
    super.key,
    required this.classSlots,
    required this.personalSlots,
    required this.freeBlocks,
    required this.mode,
    required this.onClassSlotTap,
    required this.onPersonalSlotTap,
    required this.onFreeBlockTap,
    required this.onEmptyTap,
  });

  @override
  Widget build(BuildContext context) {
    final showClass    = mode == GridLayerMode.classOnly || mode == GridLayerMode.both;
    final showPersonal = mode == GridLayerMode.personalOnly || mode == GridLayerMode.both;
    final isDimmed     = mode == GridLayerMode.both;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeLabels(),
          Expanded(
            child: GestureDetector(
              onTap: onEmptyTap,
              child: SizedBox(
                height: TimetableConstants.totalGridHeight,
                child: Stack(
                  children: [
                    _HourLines(),

                    // Free blocks (only in class view or both)
                    if (showClass)
                      ...freeBlocks.map((b) => FreeBlockIndicator(
                            block: b,
                            onTap: () => onFreeBlockTap(b),
                          )),

                    // Personal slots — rendered first (below class slots)
                    if (showPersonal)
                      ...personalSlots.map((s) => PersonalSlotCard(
                            slot: s,
                            onTap: () => onPersonalSlotTap(s),
                            onLongPress: () => onPersonalSlotTap(s),
                            isDimmed: isDimmed,
                          )),

                    // Class slots — rendered on top
                    if (showClass)
                      ...classSlots.map((s) => TimetableSlotCard(
                            slot: s,
                            columnWidth: double.infinity,
                            onTap: () => onClassSlotTap(s),
                            onLongPress: () => onClassSlotTap(s),
                          )),

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

// ── Private helpers (copied from timetable_grid.dart for self-containment) ──

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
          final top = (hour - TimetableConstants.gridStartHour) * TimetableConstants.hourRowHeight;
          final label = hour == 0 ? '12 AM' : hour < 12 ? '$hour AM' : hour == 12 ? '12 PM' : '${hour - 12} PM';
          return Positioned(
            top: top - 6, left: 0, right: 4,
            child: Text(label, textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
          );
        }).toList(),
      ),
    );
  }
}

class _HourLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const hours = TimetableConstants.gridEndHour - TimetableConstants.gridStartHour;
    return SizedBox(
      height: TimetableConstants.totalGridHeight,
      child: Stack(
        children: List.generate(hours, (i) {
          final top = i * TimetableConstants.hourRowHeight;
          return Positioned(
            top: top, left: 0, right: 0,
            child: Divider(height: 0.5, color: Colors.grey.shade200),
          );
        }),
      ),
    );
  }
}

class _CurrentTimeIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    if (nowMins < TimetableConstants.gridStartMinutes || nowMins > TimetableConstants.gridEndMinutes) {
      return const SizedBox.shrink();
    }
    final top = (nowMins - TimetableConstants.gridStartMinutes) * TimetableConstants.pixelsPerMinute;
    return Positioned(
      top: top, left: 0, right: 0,
      child: Row(children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
        Expanded(child: Container(height: 1, color: Colors.red.withValues(alpha:0.6))),
      ]),
    );
  }
}
