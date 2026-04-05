import 'package:isar/isar.dart';

part 'daily_plan_task_model.g.dart';

/// A single task in the student's daily plan.
/// Auto-generated tasks come from PlanGenerator; manual tasks are added by the student.
@collection
class DailyPlanTaskModel {
  Id id = Isar.autoIncrement;

  /// Date only — always stored as DateTime(year, month, day) with no time component.
  late DateTime date;

  /// 'attend' | 'study' | 'personal'
  late String taskType;

  /// Human-readable label e.g. "Attend MATH 151", "Study PHYSICS"
  late String label;

  /// Nullable — links to a course or timetable slot
  String? courseCode;

  /// Planned duration in minutes
  late int durationMinutes;

  /// Nullable — suggested start time for this task
  DateTime? startTime;

  /// Whether the student has checked this task off
  @Index()
  bool isCompleted = false;

  /// true if the student added this manually, false if auto-generated
  bool isManual = false;

  /// Display order; assigned by chronological start time
  late int sortOrder;

  DailyPlanTaskModel();
}
