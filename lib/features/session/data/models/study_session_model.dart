import 'package:isar/isar.dart';

part 'study_session_model.g.dart';

/// A completed study session persisted to Isar.
@collection
class StudySessionModel {
  Id id = Isar.autoIncrement;

  late String courseCode;
  late String courseName;
  late DateTime startTime;
  late DateTime endTime;

  /// Duration in minutes — focus time only (breaks excluded for Pomodoro)
  late int durationMinutes;

  /// Was this session planned (matched a timetable slot) or spontaneous?
  late bool wasPlanned;

  /// Source: "cwa" | "timetable" | "custom"
  late String courseSource;

  late String semesterKey;

  /// "normal" | "pomodoro" — null for sessions saved before this field existed
  String? sessionType;

  /// Number of complete focus rounds finished (Pomodoro sessions only)
  int? pomodoroRoundsCompleted;

  StudySessionModel();

  String get formattedDuration {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  bool get isPomodoro => sessionType == 'pomodoro';
}
