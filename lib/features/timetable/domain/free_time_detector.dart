import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// Represents a gap between class slots — a free block the student can use.
class FreeBlock {
  final int startMinutes;
  final int endMinutes;
  final int dayIndex;

  const FreeBlock({
    required this.startMinutes,
    required this.endMinutes,
    required this.dayIndex,
  });

  int get durationMinutes => endMinutes - startMinutes;
  String get startLabel => TimetableConstants.minutesToLabel(startMinutes);
  String get endLabel => TimetableConstants.minutesToLabel(endMinutes);

  /// Only surface free blocks of 30 minutes or more
  bool get isUsable => durationMinutes >= 30;
}

class FreeTimeDetector {
  /// Returns all usable free blocks for a given day's slots.
  /// Slots must be sorted by startMinutes before calling this.
  static List<FreeBlock> detect({
    required int dayIndex,
    required List<TimetableSlotModel> slots,
    int gridStart = TimetableConstants.gridStartMinutes,
    int gridEnd = TimetableConstants.gridEndMinutes,
  }) {
    if (slots.isEmpty) return [];

    final sorted = [...slots]..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final blocks = <FreeBlock>[];

    // Gap before first class
    if (sorted.first.startMinutes > gridStart) {
      final block = FreeBlock(
        startMinutes: gridStart,
        endMinutes: sorted.first.startMinutes,
        dayIndex: dayIndex,
      );
      if (block.isUsable) blocks.add(block);
    }

    // Gaps between classes
    for (int i = 0; i < sorted.length - 1; i++) {
      final gapStart = sorted[i].endMinutes;
      final gapEnd = sorted[i + 1].startMinutes;
      if (gapEnd > gapStart) {
        final block = FreeBlock(
          startMinutes: gapStart,
          endMinutes: gapEnd,
          dayIndex: dayIndex,
        );
        if (block.isUsable) blocks.add(block);
      }
    }

    // Gap after last class
    if (sorted.last.endMinutes < gridEnd) {
      final block = FreeBlock(
        startMinutes: sorted.last.endMinutes,
        endMinutes: gridEnd,
        dayIndex: dayIndex,
      );
      if (block.isUsable) blocks.add(block);
    }

    return blocks;
  }
}
