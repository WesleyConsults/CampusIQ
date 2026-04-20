import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
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

  Future<void> delete(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.pastSemesterModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }
}
