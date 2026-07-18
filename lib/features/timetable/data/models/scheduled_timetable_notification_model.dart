import 'package:isar_community/isar.dart';

part 'scheduled_timetable_notification_model.g.dart';

@collection
class ScheduledTimetableNotificationModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String logicalKey;

  @Index(unique: true, replace: false)
  late int notificationId;

  @Index()
  late String slotId;

  @Index()
  late String semesterKey;

  @Index()
  late String normalizedCourseCode;

  late int dayIndex;
  late int classStartMinutes;
  late int reminderMinutesBefore;
  late bool isAlarm;
  late int scheduledWeekday;
  late int scheduledHour;
  late int scheduledMinute;
  late String title;
  late String body;
  late String payload;
  late DateTime updatedAt;

  ScheduledTimetableNotificationModel();
}
