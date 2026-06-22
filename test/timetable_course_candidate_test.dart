import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/domain/timetable_course_candidate.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildTimetableCourseCandidates', () {
    test('deduplicates timetable slots by normalized course code', () {
      final candidates = buildTimetableCourseCandidates(
        slots: [
          _slot(code: 'coe 456', name: ''),
          _slot(code: ' COE 456 ', name: 'Secure Network Systems'),
          _slot(code: 'MATH 251', name: 'Engineering Mathematics'),
        ],
        existingCourses: const [],
      );

      expect(candidates.map((course) => course.code), [
        'COE 456',
        'MATH 251',
      ]);
      expect(candidates.first.name, 'Secure Network Systems');
    });

    test('excludes courses already in the active academic course list', () {
      final candidates = buildTimetableCourseCandidates(
        slots: [
          _slot(code: 'COE 456', name: 'Secure Network Systems'),
          _slot(code: 'MATH 251', name: 'Engineering Mathematics'),
        ],
        existingCourses: [
          CourseModel.create(
            name: 'Secure Network Systems',
            code: 'coe 456',
            creditHours: 3,
            expectedScore: 70,
            semesterKey: '2026-Sem1',
          ),
        ],
      );

      expect(candidates, hasLength(1));
      expect(candidates.single.code, 'MATH 251');
    });

    test('ignores timetable slots without a course code', () {
      final candidates = buildTimetableCourseCandidates(
        slots: [_slot(code: ' ', name: 'Unknown Course')],
        existingCourses: const [],
      );

      expect(candidates, isEmpty);
    });
  });
}

TimetableSlotModel _slot({
  required String code,
  required String name,
}) {
  return TimetableSlotModel()
    ..dayIndex = 0
    ..courseCode = code
    ..courseName = name
    ..venue = ''
    ..startMinutes = 480
    ..endMinutes = 540
    ..slotType = 'Lecture'
    ..colorValue = 0xFF000000
    ..semesterKey = '2026-Sem1';
}
