import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
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
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _isar.writeTxn(() => _isar.courseNoteModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }
}
