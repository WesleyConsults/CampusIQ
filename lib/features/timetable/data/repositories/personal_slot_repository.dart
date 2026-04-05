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
    await _isar.writeTxn(() => _isar.personalSlotModels.put(slot));
  }

  Future<void> updateSlot(PersonalSlotModel slot) async {
    await _isar.writeTxn(() => _isar.personalSlotModels.put(slot));
  }

  Future<void> deleteSlot(Id id) async {
    await _isar.writeTxn(() => _isar.personalSlotModels.delete(id));
  }
}
