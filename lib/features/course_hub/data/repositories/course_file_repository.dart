import 'dart:io';
import 'package:flutter/foundation.dart';
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
    try {
      await _isar.writeTxn(() => _isar.courseFileModels.put(file));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<List<CourseFileModel>> getExtractableFiles(String courseCode) async {
    return await _isar.courseFileModels
        .filter()
        .courseCodeEqualTo(courseCode)
        .and()
        .isTextExtractableEqualTo(true)
        .findAll();
  }

  Future<void> deleteFile(int id) async {
    final file = await _isar.courseFileModels.get(id);
    if (file != null) {
      final physicalFile = File(file.filePath);
      if (await physicalFile.exists()) {
        await physicalFile.delete();
      }
    }
    try {
      await _isar.writeTxn(() => _isar.courseFileModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }
}
