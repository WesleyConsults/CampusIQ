import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';

class CwaRepository {
  final Isar _isar;
  CwaRepository(this._isar);

  /// Live stream — re-emits whenever courses change in Isar.
  Stream<List<CourseModel>> watchCourses(String semesterKey) {
    return _isar.courseModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .watch(fireImmediately: true);
  }

  Future<void> addCourse(CourseModel course) async {
    try {
      await _isar.writeTxn(() => _isar.courseModels.put(course));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> updateCourse(CourseModel course) async {
    try {
      await _isar.writeTxn(() => _isar.courseModels.put(course));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> deleteCourse(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.courseModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<bool> courseExistsByCode(String code, String semesterKey) async {
    final count = await _isar.courseModels
        .filter()
        .codeEqualTo(code)
        .semesterKeyEqualTo(semesterKey)
        .count();
    return count > 0;
  }
}
