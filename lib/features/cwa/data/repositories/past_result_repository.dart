import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';

class PastResultRepository {
  final Isar _isar;
  PastResultRepository(this._isar);

  /// Live stream — re-emits whenever past semesters change.
  Stream<List<PastSemesterModel>> watchAll() {
    return _isar.pastSemesterModels
        .where()
        .sortByCreatedAt()
        .watch(fireImmediately: true);
  }

  Future<List<PastSemesterModel>> getAll() {
    return _isar.pastSemesterModels.where().sortByCreatedAt().findAll();
  }

  Future<PastSemesterModel?> findBySemesterKey(String semesterKey) {
    final normalized = semesterKey.trim();
    if (normalized.isEmpty) return Future.value(null);
    return _isar.pastSemesterModels
        .filter()
        .semesterKeyEqualTo(normalized)
        .findFirst();
  }

  Future<void> add(PastSemesterModel model) async {
    try {
      await _isar.writeTxn(() => _isar.pastSemesterModels.put(model));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> update(PastSemesterModel model) async {
    try {
      await _isar.writeTxn(() => _isar.pastSemesterModels.put(model));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> replaceForSemesterKey(
    String semesterKey,
    PastSemesterModel model,
  ) async {
    final normalized = semesterKey.trim();
    if (normalized.isEmpty) {
      await add(model);
      return;
    }

    final existingIds = await _isar.pastSemesterModels
        .filter()
        .semesterKeyEqualTo(normalized)
        .idProperty()
        .findAll();

    model.semesterKey = normalized;
    try {
      await _isar.writeTxn(() async {
        if (existingIds.isNotEmpty) {
          await _isar.pastSemesterModels.deleteAll(existingIds);
        }
        await _isar.pastSemesterModels.put(model);
      });
    } catch (e) {
      debugPrint('🔴 Isar replaceForSemesterKey failed: $e');
      rethrow;
    }
  }

  Future<void> delete(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.pastSemesterModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> transitionSemester({
    required String currentSemesterKey,
    required String nextSemesterKey,
    required PastSemesterModel archivedSemester,
    bool replaceExistingSemester = false,
  }) async {
    final currentCourses = await _isar.courseModels
        .filter()
        .semesterKeyEqualTo(currentSemesterKey)
        .findAll();
    if (currentCourses.isEmpty) {
      throw StateError('There are no current courses left to complete.');
    }

    final courseIds = currentCourses.map((course) => course.id).toList();
    final archivedSemesterKey = archivedSemester.semesterKey?.trim() ?? '';
    final existingPastSemesterIds =
        replaceExistingSemester && archivedSemesterKey.isNotEmpty
            ? await _isar.pastSemesterModels
                .filter()
                .semesterKeyEqualTo(archivedSemesterKey)
                .idProperty()
                .findAll()
            : <Id>[];
    final prefs = await _isar.userPrefsModels.get(1) ?? UserPrefsModel();
    prefs.activeSemesterKey = nextSemesterKey;

    try {
      await _isar.writeTxn(() async {
        if (existingPastSemesterIds.isNotEmpty) {
          await _isar.pastSemesterModels.deleteAll(existingPastSemesterIds);
        }
        await _isar.pastSemesterModels.put(archivedSemester);
        await _isar.courseModels.deleteAll(courseIds);
        await _isar.userPrefsModels.put(prefs);
      });
    } catch (e) {
      debugPrint('🔴 Isar transitionSemester failed: $e');
      rethrow;
    }
  }
}
