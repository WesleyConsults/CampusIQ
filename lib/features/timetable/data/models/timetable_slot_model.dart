import 'package:isar/isar.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

part 'timetable_slot_model.g.dart';

/// Represents one class slot in the student's official university timetable.
/// This is Layer 1 of the dual timetable system.
@collection
class TimetableSlotModel {
  Id id = Isar.autoIncrement;

  /// 0 = Monday, 1 = Tuesday ... 5 = Saturday (KNUST runs Mon–Sat)
  late int dayIndex;

  late String courseCode;
  late String courseName;
  late String venue;

  /// Minutes from midnight. e.g. 8:30AM = 510
  late int startMinutes;
  late int endMinutes;

  /// "Lecture" | "Practical" | "Tutorial"
  late String slotType;

  /// Color hex stored as int for Isar compatibility. e.g. 0xFF2196F3
  late int colorValue;

  /// Semester key — matches CWA courses. e.g. "2024-Sem2"
  late String semesterKey;

  DateTime createdAt = DateTime.now();

  TimetableSlotModel();

  /// Convenience: duration in minutes
  int get durationMinutes => endMinutes - startMinutes;

  /// Convenience: human-readable start time e.g. "8:30 AM"
  String get startTimeLabel => TimetableConstants.minutesToLabel(startMinutes);
  String get endTimeLabel => TimetableConstants.minutesToLabel(endMinutes);
}
