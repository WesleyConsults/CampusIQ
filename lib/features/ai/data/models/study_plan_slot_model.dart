import 'package:isar/isar.dart';
part 'study_plan_slot_model.g.dart';

@collection
class StudyPlanSlotModel {
  Id id = Isar.autoIncrement;

  late String day;           // 'Monday' | 'Tuesday' | ... | 'Sunday'
  late String courseCode;
  late String courseName;
  late String startTime;     // 'HH:mm' 24-hour format e.g. '14:00'
  late int durationMinutes;  // e.g. 90
  late String reason;        // short explanation from AI e.g. "Largest CWA gap"
}
