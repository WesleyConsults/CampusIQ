import 'package:isar_community/isar.dart';
import 'package:campusiq/features/timetable/data/models/scheduled_timetable_notification_model.dart';

class ScheduledTimetableNotificationRepository {
  ScheduledTimetableNotificationRepository(this._isar);

  static const int firstTimetableNotificationId = 100000;

  final Isar _isar;

  Future<List<ScheduledTimetableNotificationModel>> getAll() {
    return _isar.scheduledTimetableNotificationModels.where().findAll();
  }

  Future<void> deleteByIds(List<Id> ids) async {
    if (ids.isEmpty) return;
    await _isar.writeTxn(
      () => _isar.scheduledTimetableNotificationModels.deleteAll(ids),
    );
  }

  Future<void> deleteById(Id id) async {
    await deleteByIds([id]);
  }

  Future<void> putAll(List<ScheduledTimetableNotificationModel> records) async {
    if (records.isEmpty) return;
    await _isar.writeTxn(
      () => _isar.scheduledTimetableNotificationModels.putAll(records),
    );
  }

  int allocateNotificationId(
    List<ScheduledTimetableNotificationModel> existing,
  ) {
    final used = existing.map((record) => record.notificationId).toSet();
    var next = used.where((id) => id >= firstTimetableNotificationId).fold<int>(
          firstTimetableNotificationId,
          (max, id) => id >= max ? id + 1 : max,
        );
    while (used.contains(next)) {
      next++;
    }
    return next;
  }
}
