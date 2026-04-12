import 'package:isar/isar.dart';

part 'course_file_model.g.dart';

@collection
class CourseFileModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String courseCode;

  late String fileName;
  late String filePath; // absolute path on device storage
  late String fileType; // 'pdf' | 'image'
  late DateTime addedAt;
}
