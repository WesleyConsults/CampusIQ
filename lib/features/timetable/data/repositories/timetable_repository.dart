import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

class TimetableRepository {
  final Isar _isar;
  TimetableRepository(this._isar);

  /// Live stream of all slots for a semester — re-emits on any change.
  Stream<List<TimetableSlotModel>> watchAllSlots(String semesterKey) {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .watch(fireImmediately: true);
  }

  /// Live stream filtered to one day.
  Stream<List<TimetableSlotModel>> watchSlotsForDay(String semesterKey, int dayIndex) {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .and()
        .dayIndexEqualTo(dayIndex)
        .watch(fireImmediately: true);
  }

  Future<void> addSlot(TimetableSlotModel slot) async {
    try {
      await _isar.writeTxn(() => _isar.timetableSlotModels.put(slot));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> updateSlot(TimetableSlotModel slot) async {
    try {
      await _isar.writeTxn(() => _isar.timetableSlotModels.put(slot));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> deleteSlot(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.timetableSlotModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<List<TimetableSlotModel>> getSlotsForDayOnce(String semesterKey, int dayIndex) async {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .and()
        .dayIndexEqualTo(dayIndex)
        .findAll();
  }

  /// Returns how many slots exist — used to assign next color.
  Future<int> countSlots(String semesterKey) async {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .count();
  }
}
