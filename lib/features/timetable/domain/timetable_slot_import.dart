import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';
import 'package:campusiq/features/timetable/domain/timetable_time_parser.dart';

/// A candidate slot parsed from a timetable image before the student confirms it.
/// Pure Dart — no Flutter, no Isar imports.
class TimetableSlotImport {
  final int dayIndex; // 0=Mon … 5=Sat
  final String courseCode;
  final String courseName;
  final String venue;
  final String lecturerName;
  final int startMinutes; // minutes from midnight
  final int endMinutes;
  final String rawStartTime;
  final String rawEndTime;
  final String? validationError;
  final String slotType; // "Lecture" | "Practical" | "Tutorial"

  const TimetableSlotImport({
    required this.dayIndex,
    required this.courseCode,
    required this.courseName,
    required this.venue,
    required this.lecturerName,
    required this.startMinutes,
    required this.endMinutes,
    this.rawStartTime = '',
    this.rawEndTime = '',
    this.validationError,
    required this.slotType,
  });

  bool get isValid => validationError == null;

  TimetableSlotImport copyWith({
    int? startMinutes,
    int? endMinutes,
    String? rawStartTime,
    String? rawEndTime,
    String? validationError,
  }) {
    return TimetableSlotImport(
      dayIndex: dayIndex,
      courseCode: courseCode,
      courseName: courseName,
      venue: venue,
      lecturerName: lecturerName,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      rawStartTime: rawStartTime ?? this.rawStartTime,
      rawEndTime: rawEndTime ?? this.rawEndTime,
      validationError: validationError,
      slotType: slotType,
    );
  }

  factory TimetableSlotImport.fromJson(Map<String, dynamic> json) {
    final dayIndex = _parseDay(json['day']);
    final rawStart = json['start_time'] as String? ?? '';
    final rawEnd = json['end_time'] as String? ?? '';
    final start = parseTimetableTime(rawStart);
    final end = parseTimetableTime(rawEnd);
    String? validationError;
    if (!start.isValid) {
      validationError = 'Start time "${start.rawValue}" is invalid';
    } else if (!end.isValid) {
      validationError = 'End time "${end.rawValue}" is invalid';
    } else if (end.minutes! <= start.minutes!) {
      validationError = 'End time must be after start time';
    }

    return TimetableSlotImport(
      dayIndex: dayIndex,
      courseCode: (json['course_code'] as String? ?? '').trim(),
      courseName: (json['course_name'] as String? ?? '').trim(),
      venue: (json['venue'] as String? ?? '').trim(),
      lecturerName: (json['lecturer_name'] as String? ?? '').trim(),
      startMinutes: start.minutes ?? 0,
      endMinutes: end.minutes ?? 0,
      rawStartTime: rawStart,
      rawEndTime: rawEnd,
      validationError: validationError,
      slotType: _parseSlotType(json['slot_type'] as String? ?? 'Lecture'),
    );
  }

  static int _parseDay(dynamic day) {
    if (day is int) return day.clamp(0, 5);
    final s = (day as String? ?? '').toLowerCase().trim();
    const map = <String, int>{
      'monday': 0,
      'mon': 0,
      'tuesday': 1,
      'tue': 1,
      'tues': 1,
      'wednesday': 2,
      'wed': 2,
      'thursday': 3,
      'thu': 3,
      'thur': 3,
      'thurs': 3,
      'friday': 4,
      'fri': 4,
      'saturday': 5,
      'sat': 5,
    };
    return map[s] ?? 0;
  }

  static String _parseSlotType(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('practical') || lower.contains('lab')) {
      return 'Practical';
    }
    if (lower.contains('tutorial') || lower.contains('tut')) return 'Tutorial';
    return 'Lecture';
  }

  TimetableSlotModel toModel(
      {required int colorValue, required String semesterKey}) {
    return TimetableSlotModel()
      ..dayIndex = dayIndex
      ..courseCode = courseCode.trim().toUpperCase()
      ..normalizedCourseCode = normalizeCourseCode(courseCode)
      ..courseName = courseName
      ..venue = venue
      ..lecturerName = lecturerName
      ..startMinutes = startMinutes
      ..endMinutes = endMinutes
      ..slotType = slotType
      ..colorValue = colorValue
      ..semesterKey = semesterKey
      ..ensureStableIdentity();
  }
}
