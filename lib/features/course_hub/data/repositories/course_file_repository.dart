import 'dart:io';
import 'package:isar/isar.dart';
import '../models/course_file_model.dart';

class CourseFileRepository {
  final Isar _isar;
  CourseFileRepository(this._isar);

  Stream<List<CourseFileModel>> watchFiles(String courseCode) {
    return _isar.courseFileModels
        .filter()
        .courseCodeEqualTo(courseCode)
        .sortByAddedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> saveFile(CourseFileModel file) async {
    await _isar.writeTxn(() => _isar.courseFileModels.put(file));
  }

  Future<void> deleteFile(int id) async {
    final file = await _isar.courseFileModels.get(id);
    if (file != null) {
      final physicalFile = File(file.filePath);
      if (await physicalFile.exists()) {
        await physicalFile.delete();
      }
    }
    await _isar.writeTxn(() => _isar.courseFileModels.delete(id));
  }
}
