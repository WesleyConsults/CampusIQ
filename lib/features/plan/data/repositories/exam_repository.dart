import 'package:isar/isar.dart';
import 'package:campusiq/features/plan/data/models/exam_model.dart';

class ExamRepository {
  final Isar _isar;
  ExamRepository(this._isar);

  Stream<List<ExamModel>> watchAll() =>
      _isar.examModels.where().watch(fireImmediately: true);

  Future<List<ExamModel>> getAll() => _isar.examModels.where().findAll();

  Future<void> save(ExamModel exam) async {
    await _isar.writeTxn(() => _isar.examModels.put(exam));
  }

  Future<void> delete(Id id) async {
    await _isar.writeTxn(() => _isar.examModels.delete(id));
  }

  Future<void> markComplete(Id id) async {
    final exam = await _isar.examModels.get(id);
    if (exam == null) return;
    exam.isComplete = true;
    await _isar.writeTxn(() => _isar.examModels.put(exam));
  }
}
