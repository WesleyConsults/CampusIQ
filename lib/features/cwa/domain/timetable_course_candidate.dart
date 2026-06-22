import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

class TimetableCourseCandidate {
  final String code;
  final String name;

  const TimetableCourseCandidate({
    required this.code,
    required this.name,
  });
}

List<TimetableCourseCandidate> buildTimetableCourseCandidates({
  required List<TimetableSlotModel> slots,
  required List<CourseModel> existingCourses,
}) {
  final existingCodes = existingCourses
      .map((course) => course.code.trim().toUpperCase())
      .where((code) => code.isNotEmpty)
      .toSet();
  final candidatesByCode = <String, TimetableCourseCandidate>{};

  for (final slot in slots) {
    final code = slot.courseCode.trim().toUpperCase();
    if (code.isEmpty || existingCodes.contains(code)) continue;

    final name = slot.courseName.trim();
    final existing = candidatesByCode[code];
    if (existing == null ||
        (existing.name == existing.code && name.isNotEmpty)) {
      candidatesByCode[code] = TimetableCourseCandidate(
        code: code,
        name: name.isEmpty ? code : name,
      );
    }
  }

  final candidates = candidatesByCode.values.toList()
    ..sort((a, b) => a.code.compareTo(b.code));
  return candidates;
}
