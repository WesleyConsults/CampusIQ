import 'package:isar/isar.dart';

part 'study_session_model.g.dart';

/// A completed or in-progress study session.
@collection
class StudySessionModel {
  Id id = Isar.autoIncrement;

  /// Course code this session was for e.g. "COE 456"
  late String courseCode;
  late String courseName;

  late DateTime startTime;
  late DateTime endTime;

  /// Duration in minutes — stored for fast querying
  late int durationMinutes;

  /// Was this session planned (matched a timetable slot) or spontaneous?
  late bool wasPlanned;

  /// Source: "cwa" | "timetable" | "custom"
  late String courseSource;

  late String semesterKey;

  StudySessionModel();

  /// Convenience
  String get formattedDuration {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
