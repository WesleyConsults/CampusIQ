import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';

/// Pure Dart immutable value object representing one task in a generated plan.
/// No Isar or Flutter dependencies.
class PlanTask {
  final String taskType; // 'attend' | 'study' | 'personal'
  final String label;
  final String? courseCode;
  final int durationMinutes;
  final DateTime? startTime;
  final bool isManual;
  final int sortOrder;

  const PlanTask({
    required this.taskType,
    required this.label,
    this.courseCode,
    required this.durationMinutes,
    this.startTime,
    this.isManual = false,
    required this.sortOrder,
  });

  PlanTask copyWith({
    String? taskType,
    String? label,
    String? courseCode,
    int? durationMinutes,
    DateTime? startTime,
    bool? isManual,
    int? sortOrder,
  }) {
    return PlanTask(
      taskType: taskType ?? this.taskType,
      label: label ?? this.label,
      courseCode: courseCode ?? this.courseCode,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      isManual: isManual ?? this.isManual,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Converts this value object into a [DailyPlanTaskModel] for persistence.
  DailyPlanTaskModel toDailyPlanTaskModel(DateTime date) {
    final model = DailyPlanTaskModel()
      ..date = DateTime(date.year, date.month, date.day)
      ..taskType = taskType
      ..label = label
      ..courseCode = courseCode
      ..durationMinutes = durationMinutes
      ..startTime = startTime
      ..isCompleted = false
      ..isManual = isManual
      ..sortOrder = sortOrder;
    return model;
  }
}
