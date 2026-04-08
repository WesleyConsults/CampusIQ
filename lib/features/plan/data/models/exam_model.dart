import 'package:isar/isar.dart';

part 'exam_model.g.dart';

/// Persisted exam entry for a single course.
@collection
class ExamModel {
  Id id = Isar.autoIncrement;

  late String courseCode;
  late String courseName;

  /// Date of the exam (date component only).
  late DateTime examDate;

  /// Hour of exam start time (24h) e.g. 9 for 9 AM.
  late int examStartHour;

  /// Credit hours for this course — used to determine study session count.
  late int creditHours;

  /// Optional exam venue e.g. "Great Hall".
  String? examHall;

  /// JSON-encoded list of topics e.g.
  /// [{"name":"Circuits","priority":"high"},{"name":"Waves","priority":"low"}]
  String? topicsJson;

  /// Marked true after exam day has passed.
  bool isComplete = false;

  DateTime createdAt = DateTime.now();

  ExamModel();

  ExamModel.create({
    required this.courseCode,
    required this.courseName,
    required this.examDate,
    required this.examStartHour,
    required this.creditHours,
    this.examHall,
    this.topicsJson,
  });
}
