import 'package:isar/isar.dart';

part 'course_note_model.g.dart';

@collection
class CourseNoteModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String courseCode;

  late String title;
  late String body;
  late DateTime createdAt;
  late DateTime updatedAt;
}
