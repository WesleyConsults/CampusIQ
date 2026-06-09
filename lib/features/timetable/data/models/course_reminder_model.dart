import 'package:isar/isar.dart';

part 'course_reminder_model.g.dart';

@collection
class CourseReminderModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String semesterKey;

  @Index()
  late String courseCode;

  late String courseName;

  /// Minutes before each matching timetable class.
  late int offsetMinutes;

  late bool isEnabled;
  late bool isAlarm;
  late DateTime createdAt;
  late DateTime updatedAt;

  CourseReminderModel();

  CourseReminderModel.create({
    required this.semesterKey,
    required this.courseCode,
    required this.courseName,
    required this.offsetMinutes,
    this.isEnabled = true,
    this.isAlarm = false,
  })  : createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  @ignore
  String get offsetLabel {
    if (offsetMinutes == 60) return '1 hour before';
    return '$offsetMinutes minutes before';
  }
}
