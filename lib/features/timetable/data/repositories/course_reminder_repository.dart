import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';

class CourseReminderRepository {
  final Isar _isar;
  CourseReminderRepository(this._isar);

  Stream<List<CourseReminderModel>> watchReminders(String semesterKey) {
    return _isar.courseReminderModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .sortByCourseCode()
        .watch(fireImmediately: true);
  }

  Future<List<CourseReminderModel>> getReminders(String semesterKey) {
    return _isar.courseReminderModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .sortByCourseCode()
        .findAll();
  }

  Future<CourseReminderModel?> findByCourse({
    required String semesterKey,
    required String courseCode,
  }) {
    return _isar.courseReminderModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .and()
        .courseCodeEqualTo(courseCode)
        .findFirst();
  }

  Future<void> saveReminder(CourseReminderModel reminder) async {
    try {
      reminder.updatedAt = DateTime.now();
      await _isar.writeTxn(() => _isar.courseReminderModels.put(reminder));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {
          'repository': 'course_reminder',
          'operation': 'save_reminder',
        },
      );
      rethrow;
    }
  }

  Future<void> deleteReminder(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.courseReminderModels.delete(id));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {
          'repository': 'course_reminder',
          'operation': 'delete_reminder',
        },
      );
      rethrow;
    }
  }
}
