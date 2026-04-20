import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';

class PersonalSlotRepository {
  final Isar _isar;
  PersonalSlotRepository(this._isar);

  /// Live stream of ALL personal slots for a semester.
  /// The provider layer runs SlotExpander on top of this.
  Stream<List<PersonalSlotModel>> watchAllSlots(String semesterKey) {
    return _isar.personalSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .watch(fireImmediately: true);
  }

  Future<void> addSlot(PersonalSlotModel slot) async {
    try {
      await _isar.writeTxn(() => _isar.personalSlotModels.put(slot));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> updateSlot(PersonalSlotModel slot) async {
    try {
      await _isar.writeTxn(() => _isar.personalSlotModels.put(slot));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> deleteSlot(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.personalSlotModels.delete(id));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }
}
