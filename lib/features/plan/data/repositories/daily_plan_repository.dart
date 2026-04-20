import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';

class DailyPlanRepository {
  final Isar _isar;

  DailyPlanRepository(this._isar);

  /// Fetch all tasks for [date] ordered by sortOrder.
  Future<List<DailyPlanTaskModel>> getTasksForDate(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    final next = day.add(const Duration(days: 1));
    return _isar.dailyPlanTaskModels
        .filter()
        .dateBetween(day, next, includeLower: true, includeUpper: false)
        .sortBySortOrder()
        .findAll();
  }

  /// Insert or update a single task.
  Future<void> saveTask(DailyPlanTaskModel task) async {
    try {
      await _isar.writeTxn(() => _isar.dailyPlanTaskModels.put(task));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  /// Batch insert/update — used when saving a generated plan.
  Future<void> saveTasks(List<DailyPlanTaskModel> tasks) async {
    try {
      await _isar.writeTxn(() => _isar.dailyPlanTaskModels.putAll(tasks));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  /// Toggle isCompleted for a task.
  Future<void> markComplete(int taskId, bool completed) async {
    try {
      await _isar.writeTxn(() async {
        final task = await _isar.dailyPlanTaskModels.get(taskId);
        if (task != null) {
          task.isCompleted = completed;
          await _isar.dailyPlanTaskModels.put(task);
        }
      });
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  /// Delete a single task by id.
  Future<void> deleteTask(int taskId) async {
    try {
      await _isar.writeTxn(() => _isar.dailyPlanTaskModels.delete(taskId));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  /// Delete all tasks for [date] (used when regenerating the plan).
  Future<void> deleteAllTasksForDate(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    final next = day.add(const Duration(days: 1));
    try {
      await _isar.writeTxn(() async {
        final ids = await _isar.dailyPlanTaskModels
            .filter()
            .dateBetween(day, next, includeLower: true, includeUpper: false)
            .idProperty()
            .findAll();
        await _isar.dailyPlanTaskModels.deleteAll(ids);
      });
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  /// Reactive stream of tasks for [date], ordered by sortOrder.
  Stream<List<DailyPlanTaskModel>> watchTasksForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final next = day.add(const Duration(days: 1));
    return _isar.dailyPlanTaskModels
        .filter()
        .dateBetween(day, next, includeLower: true, includeUpper: false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }
}
