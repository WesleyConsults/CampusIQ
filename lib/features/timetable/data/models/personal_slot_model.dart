import 'package:isar/isar.dart';

part 'personal_slot_model.g.dart';

/// A personal timetable slot — Layer 2 of the dual timetable system.
/// Stored once; the SlotExpander resolves recurring instances for display.
@collection
class PersonalSlotModel {
  Id id = Isar.autoIncrement;

  /// Category stored as string e.g. "study", "gym"
  late String categoryName;

  /// Custom label — used when categoryName == "custom", optional otherwise
  late String customLabel;

  /// Minutes from midnight
  late int startMinutes;
  late int endMinutes;

  /// Stored as string from RecurrenceType enum
  late String recurrenceTypeName;

  /// For one-off: the specific date (stored as ISO string "2024-11-04")
  /// For daily/weekly: null
  String? specificDate;

  /// For weekly recurrence: list of day indices (0=Mon … 5=Sat)
  /// Empty for one-off and daily
  late List<int> weeklyDays;

  late String semesterKey;

  DateTime createdAt = DateTime.now();

  PersonalSlotModel();

  /// Convenience getters
  int get durationMinutes => endMinutes - startMinutes;

  String get displayLabel {
    if (categoryName == 'custom' && customLabel.isNotEmpty) return customLabel;
    // Capitalise first letter
    return categoryName[0].toUpperCase() + categoryName.substring(1).replaceAll(
      RegExp(r'([A-Z])'), r' $1',
    );
  }

  static String _minutesToLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final suffix = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour.toString()}:${m.toString().padLeft(2, '0')} $suffix';
  }

  String get startTimeLabel => _minutesToLabel(startMinutes);
  String get endTimeLabel   => _minutesToLabel(endMinutes);
}
