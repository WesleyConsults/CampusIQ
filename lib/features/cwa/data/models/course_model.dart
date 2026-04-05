import 'package:isar/isar.dart';

part 'course_model.g.dart';

@collection
class CourseModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String code;
  late double creditHours;
  late double expectedScore;

  /// Semester this course belongs to e.g. "2024-Sem2"
  late String semesterKey;

  DateTime createdAt = DateTime.now();

  CourseModel();

  CourseModel.create({
    required this.name,
    required this.code,
    required this.creditHours,
    required this.expectedScore,
    required this.semesterKey,
  });
}
