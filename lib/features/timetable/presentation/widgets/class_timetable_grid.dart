import 'package:flutter/material.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_slot_card.dart';
import 'package:campusiq/features/timetable/presentation/widgets/free_block_indicator.dart';

/// Renders the class timetable grid.
class ClassTimetableGrid extends StatelessWidget {
  final List<TimetableSlotModel> classSlots;
  final List<FreeBlock> freeBlocks;
  final void Function(TimetableSlotModel) onClassSlotTap;
  final void Function(FreeBlock) onFreeBlockTap;
  final VoidCallback onEmptyTap;

  const ClassTimetableGrid({
    super.key,
    required this.classSlots,
    required this.freeBlocks,
    required this.onClassSlotTap,
    required this.onFreeBlockTap,
    required this.onEmptyTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeLabels(),
          Expanded(
            child: GestureDetector(
              onTap: onEmptyTap,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;

                  final classPositions = _assignColumns(
                    classSlots
                        .map((s) => (id: s.id, start: s.startMinutes, end: s.endMinutes))
                        .toList(),
                  );

                  return SizedBox(
                    height: TimetableConstants.totalGridHeight,
                    child: Stack(
                      children: [
                        _HourLines(),

                        // Free blocks
                        ...freeBlocks.map((b) => FreeBlockIndicator(
                              block: b,
                              onTap: () => onFreeBlockTap(b),
                            )),

                        // Class slots
                        ...classSlots.map((s) {
                          final pos = classPositions[s.id] ??
                              const _OverlapPos(0, 1);
                          final laneWidth = totalWidth / pos.totalColumns;
                          return TimetableSlotCard(
                            slot: s,
                            left: pos.columnIndex * laneWidth + 2,
                            right: totalWidth - (pos.columnIndex + 1) * laneWidth + 2,
                            onTap: () => onClassSlotTap(s),
                            onLongPress: () => onClassSlotTap(s),
                          );
                        }),

                        _CurrentTimeIndicator(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlap detection ─────────────────────────────────────────────────────────

class _OverlapPos {
  final int columnIndex;
  final int totalColumns;
  const _OverlapPos(this.columnIndex, this.totalColumns);
}

/// Assigns each slot a column index and total column count so overlapping
/// slots are rendered side-by-side instead of stacked on top of each other.
///
/// Algorithm:
/// 1. Sort by start time.
/// 2. Greedy column assignment — each slot takes the first column whose last
///    occupant has already ended.
/// 3. For each slot, scan all overlapping slots to find the highest column
///    index used — that determines the total column count for that slot.
Map<int, _OverlapPos> _assignColumns(
  List<({int id, int start, int end})> items,
) {
  if (items.isEmpty) return {};

  final sorted = [...items]..sort((a, b) => a.start.compareTo(b.start));
  final colAssign = <int, int>{}; // id → column index
  final colEnds = <int>[];        // end-minute of the last slot in each column

  for (final item in sorted) {
    // Find the first column that is free at item.start
    int col = -1;
    for (int i = 0; i < colEnds.length; i++) {
      if (colEnds[i] <= item.start) {
        col = i;
        colEnds[i] = item.end;
        break;
      }
    }
    if (col == -1) {
      col = colEnds.length;
      colEnds.add(item.end);
    }
    colAssign[item.id] = col;
  }

  // Determine totalColumns for each slot: highest column index used by any
  // slot that overlaps with this slot (including itself), plus one.
  final result = <int, _OverlapPos>{};
  for (final item in sorted) {
    int maxCol = colAssign[item.id]!;
    for (final other in sorted) {
      if (other.start < item.end && other.end > item.start) {
        final c = colAssign[other.id]!;
        if (c > maxCol) maxCol = c;
      }
    }
    result[item.id] = _OverlapPos(colAssign[item.id]!, maxCol + 1);
  }

  return result;
}

// ── Private helpers ───────────────────────────────────────────────────────────

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
        Expanded(child: Container(height: 1, color: Colors.red.withValues(alpha: 0.6))),
      ]),
    );
  }
}
