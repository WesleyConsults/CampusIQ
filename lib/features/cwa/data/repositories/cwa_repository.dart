import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
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
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {'repository': 'cwa', 'operation': 'add_course'},
      );
      rethrow;
    }
  }

  Future<void> updateCourse(CourseModel course) async {
    try {
      await _isar.writeTxn(() => _isar.courseModels.put(course));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {'repository': 'cwa', 'operation': 'update_course'},
      );
      rethrow;
    }
  }

  Future<void> deleteCourse(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.courseModels.delete(id));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {'repository': 'cwa', 'operation': 'delete_course'},
      );
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
