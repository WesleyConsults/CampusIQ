import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import '../models/course_note_model.dart';

class CourseNoteRepository {
  final Isar _isar;
  CourseNoteRepository(this._isar);

  Stream<List<CourseNoteModel>> watchNotes(String courseCode) {
    return _isar.courseNoteModels
        .filter()
        .courseCodeEqualTo(courseCode)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> saveNote(CourseNoteModel note) async {
    try {
      await _isar.writeTxn(() => _isar.courseNoteModels.put(note));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {'repository': 'course_note', 'operation': 'save_note'},
      );
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _isar.writeTxn(() => _isar.courseNoteModels.delete(id));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {'repository': 'course_note', 'operation': 'delete_note'},
      );
      rethrow;
    }
  }
}
