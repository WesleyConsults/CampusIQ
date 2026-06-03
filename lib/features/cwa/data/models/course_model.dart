import 'package:isar/isar.dart';

part 'course_model.g.dart';

@collection
class CourseModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String code;
  late double creditHours;
  late double expectedScore;

  /// Semester this course belongs to e.g. "2024-Sem2" or "2024-Supp".
  late String semesterKey;

  /// Grading system used when this course projection was created.
  @Name('zzGradingSystemId')
  String gradingSystemId = 'cwa';

  DateTime createdAt = DateTime.now();

  /// Scheduled exam date for this course — nullable until exam is added.
  DateTime? examDate;

  CourseModel();

  CourseModel.create({
    required this.name,
    required this.code,
    required this.creditHours,
    required this.expectedScore,
    required this.semesterKey,
    this.gradingSystemId = 'cwa',
  });
}
