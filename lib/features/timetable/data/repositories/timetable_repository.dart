import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
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
  Stream<List<TimetableSlotModel>> watchSlotsForDay(
      String semesterKey, int dayIndex) {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .and()
        .dayIndexEqualTo(dayIndex)
        .watch(fireImmediately: true);
  }

  Future<void> addSlot(TimetableSlotModel slot) async {
    try {
      slot.ensureStableIdentity();
      await _isar.writeTxn(() => _isar.timetableSlotModels.put(slot));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {'repository': 'timetable', 'operation': 'add_slot'},
      );
      rethrow;
    }
  }

  Future<void> updateSlot(TimetableSlotModel slot) async {
    try {
      slot.ensureStableIdentity();
      await _isar.writeTxn(() => _isar.timetableSlotModels.put(slot));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {'repository': 'timetable', 'operation': 'update_slot'},
      );
      rethrow;
    }
  }

  Future<void> deleteSlot(Id id) async {
    try {
      await _isar.writeTxn(() => _isar.timetableSlotModels.delete(id));
    } catch (e, stackTrace) {
      debugPrint('🔴 Isar write failed: $e');
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'isar_write_failed',
        context: {'repository': 'timetable', 'operation': 'delete_slot'},
      );
      rethrow;
    }
  }

  Future<List<TimetableSlotModel>> getSlotsForDayOnce(
      String semesterKey, int dayIndex) async {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .and()
        .dayIndexEqualTo(dayIndex)
        .findAll();
  }

  Future<List<TimetableSlotModel>> getAllSlotsOnce(String semesterKey) async {
    final slots = await _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .findAll();
    await _backfillMissingSlotIdentity(slots);
    return slots;
  }

  /// Returns how many slots exist — used to assign next color.
  Future<int> countSlots(String semesterKey) async {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .count();
  }

  Future<List<TimetableSlotModel>> getAllSlotsAcrossSemesters() async {
    final slots = await _isar.timetableSlotModels.where().findAll();
    await _backfillMissingSlotIdentity(slots);
    return slots;
  }

  Future<void> _backfillMissingSlotIdentity(
    List<TimetableSlotModel> slots,
  ) async {
    final changed = <TimetableSlotModel>[];
    for (final slot in slots) {
      final previousSlotId = slot.slotId;
      final previousNormalized = slot.normalizedCourseCode;
      slot.ensureStableIdentity();
      if (slot.slotId != previousSlotId ||
          slot.normalizedCourseCode != previousNormalized) {
        changed.add(slot);
      }
    }
    if (changed.isEmpty) return;
    await _isar.writeTxn(() => _isar.timetableSlotModels.putAll(changed));
  }
}
