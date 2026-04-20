import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/features/plan/data/models/exam_model.dart';

class ExamRepository {
  final Isar _isar;
  ExamRepository(this._isar);

  Stream<List<ExamModel>> watchAll() =>
      _isar.examModels.where().watch(fireImmediately: true);

  Future<List<ExamModel>> getAll() => _isar.examModels.where().findAll();

  Future<void> save(ExamModel exam) async {
    try {
      await _isar.writeTxn(() => _isar.examModels.put(exam));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> delete(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.examModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> markComplete(Id id) async {
    final exam = await _isar.examModels.get(id);
    if (exam == null) return;
    exam.isComplete = true;
    try {
      await _isar.writeTxn(() => _isar.examModels.put(exam));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }
}
