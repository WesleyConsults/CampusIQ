import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

/// A candidate slot parsed from a timetable image before the student confirms it.
/// Pure Dart — no Flutter, no Isar imports.
class TimetableSlotImport {
  final int dayIndex;       // 0=Mon … 5=Sat
  final String courseCode;
  final String courseName;
  final String venue;
  final int startMinutes;   // minutes from midnight
  final int endMinutes;
  final String slotType;    // "Lecture" | "Practical" | "Tutorial"

  const TimetableSlotImport({
    required this.dayIndex,
    required this.courseCode,
    required this.courseName,
    required this.venue,
    required this.startMinutes,
    required this.endMinutes,
    required this.slotType,
  });

  factory TimetableSlotImport.fromJson(Map<String, dynamic> json) {
    final dayIndex = _parseDay(json['day']);
    final start = _parseTime(json['start_time'] as String? ?? '08:00');
    var end = _parseTime(json['end_time'] as String? ?? '09:00');
    if (end <= start) end = start + 60;

    return TimetableSlotImport(
      dayIndex: dayIndex,
      courseCode: (json['course_code'] as String? ?? '').trim(),
      courseName: (json['course_name'] as String? ?? '').trim(),
      venue: (json['venue'] as String? ?? '').trim(),
      startMinutes: start,
      endMinutes: end,
      slotType: _parseSlotType(json['slot_type'] as String? ?? 'Lecture'),
    );
  }

  static int _parseDay(dynamic day) {
    if (day is int) return day.clamp(0, 5);
    final s = (day as String? ?? '').toLowerCase().trim();
    const map = <String, int>{
      'monday': 0,    'mon': 0,
      'tuesday': 1,   'tue': 1,   'tues': 1,
      'wednesday': 2, 'wed': 2,
      'thursday': 3,  'thu': 3,   'thur': 3,  'thurs': 3,
      'friday': 4,    'fri': 4,
      'saturday': 5,  'sat': 5,
    };
    return map[s] ?? 0;
  }

  static int _parseTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return 480; // default 8:00
    final h = int.tryParse(parts[0]) ?? 8;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  static String _parseSlotType(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('practical') || lower.contains('lab')) return 'Practical';
    if (lower.contains('tutorial') || lower.contains('tut')) return 'Tutorial';
    return 'Lecture';
  }

  TimetableSlotModel toModel({required int colorValue, required String semesterKey}) {
    return TimetableSlotModel()
      ..dayIndex = dayIndex
      ..courseCode = courseCode
      ..courseName = courseName
      ..venue = venue
      ..startMinutes = startMinutes
      ..endMinutes = endMinutes
      ..slotType = slotType
      ..colorValue = colorValue
      ..semesterKey = semesterKey;
  }
}
