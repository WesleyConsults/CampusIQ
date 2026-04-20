import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';

class SessionRepository {
  final Isar _isar;
  SessionRepository(this._isar);

  /// Save a completed session
  Future<void> saveSession(StudySessionModel session) async {
    try {
      await _isar.writeTxn(() => _isar.studySessionModels.put(session));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  /// All sessions for a semester, newest first
  Stream<List<StudySessionModel>> watchAllSessions(String semesterKey) {
    return _isar.studySessionModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .sortByStartTimeDesc()
        .watch(fireImmediately: true);
  }

  /// Sessions on a specific date
  Future<List<StudySessionModel>> getSessionsForDate(
      String semesterKey, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _isar.studySessionModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .startTimeBetween(start, end)
        .findAll();
  }

  /// Sessions within a date range — used for weekly analytics
  Future<List<StudySessionModel>> getSessionsForRange(
      String semesterKey, DateTime from, DateTime to) async {
    return _isar.studySessionModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .startTimeBetween(from, to)
        .findAll();
  }

  Future<void> deleteSession(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.studySessionModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }
}
