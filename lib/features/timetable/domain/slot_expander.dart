import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/recurrence_type.dart';

/// Expands stored PersonalSlotModel records into concrete instances
/// for a given day. Keeps Isar clean — no duplicate rows for recurring slots.
class SlotExpander {
  /// Returns all personal slots that are active on [targetDate] with [dayIndex].
  /// [dayIndex] is 0=Mon … 6=Sun.
  static List<PersonalSlotModel> expandForDay({
    required List<PersonalSlotModel> stored,
    required DateTime targetDate,
    required int dayIndex,
  }) {
    final result = <PersonalSlotModel>[];
    final targetDateStr = _toDateStr(targetDate);

    for (final slot in stored) {
      final type = RecurrenceType.fromString(slot.recurrenceTypeName);
      switch (type) {
        case RecurrenceType.oneOff:
          if (slot.specificDate == targetDateStr) result.add(slot);
        case RecurrenceType.daily:
          result.add(slot);
        case RecurrenceType.weekly:
          if (slot.weeklyDays.contains(dayIndex)) result.add(slot);
      }
    }

    // Sort by start time
    result.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return result;
  }

  static String _toDateStr(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
