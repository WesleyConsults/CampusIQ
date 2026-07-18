import 'package:isar_community/isar.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';

part 'course_reminder_model.g.dart';

@collection
class CourseReminderModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String semesterKey;

  @Index()
  late String courseCode;

  @Index()
  String normalizedCourseCode = '';

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
        updatedAt = DateTime.now() {
    normalizedCourseCode = normalizeCourseCode(courseCode);
  }

  void normalizeForSave() {
    normalizedCourseCode = normalizeCourseCode(courseCode);
  }

  @ignore
  String get offsetLabel {
    if (offsetMinutes == 60) return '1 hour before';
    return '$offsetMinutes minutes before';
  }
}
