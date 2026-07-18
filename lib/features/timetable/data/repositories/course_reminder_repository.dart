import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';

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
        .findAll()
        .then(_backfillNormalizedCodes);
  }

  Future<CourseReminderModel?> findByCourse({
    required String semesterKey,
    required String courseCode,
  }) {
    final normalized = normalizeCourseCode(courseCode);
    return _isar.courseReminderModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .and()
        .group((q) => q
            .normalizedCourseCodeEqualTo(normalized)
            .or()
            .courseCodeEqualTo(courseCode))
        .findFirst();
  }

  Future<void> saveReminder(CourseReminderModel reminder) async {
    try {
      reminder.normalizeForSave();
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

  Future<List<CourseReminderModel>> _backfillNormalizedCodes(
    List<CourseReminderModel> reminders,
  ) async {
    final changed = <CourseReminderModel>[];
    for (final reminder in reminders) {
      final previous = reminder.normalizedCourseCode;
      reminder.normalizeForSave();
      if (reminder.normalizedCourseCode != previous) {
        changed.add(reminder);
      }
    }
    if (changed.isNotEmpty) {
      await _isar.writeTxn(() => _isar.courseReminderModels.putAll(changed));
    }
    return reminders;
  }
}
