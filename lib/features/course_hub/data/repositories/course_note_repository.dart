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
    await _isar.writeTxn(() => _isar.courseNoteModels.put(note));
  }

  Future<void> deleteNote(int id) async {
    await _isar.writeTxn(() => _isar.courseNoteModels.delete(id));
  }
}
