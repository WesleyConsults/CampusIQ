import 'package:flutter_test/flutter_test.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';
import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';
import 'package:campusiq/features/timetable/domain/timetable_time_parser.dart';

void main() {
  group('TimetableSlotImport', () {
    test('parses and persists a lecturer name', () {
      final slot = TimetableSlotImport.fromJson({
        'day': 'Tuesday',
        'course_code': 'COE 456',
        'course_name': 'Secure Network Systems',
        'venue': 'Lab 2',
        'lecturer_name': 'Dr. Ama Mensah',
        'start_time': '10:00',
        'end_time': '12:00',
        'slot_type': 'Lecture',
      });

      expect(slot.lecturerName, 'Dr. Ama Mensah');

      final model = slot.toModel(
        colorValue: 0xFF123456,
        semesterKey: '2025-Sem1',
      );
      expect(model.lecturerName, 'Dr. Ama Mensah');
    });

    test('uses an empty lecturer name when none is visible', () {
      final slot = TimetableSlotImport.fromJson({
        'day': 'Monday',
        'course_code': 'COE 486',
        'course_name': 'Introduction to VLSI',
        'venue': '',
        'start_time': '08:00',
        'end_time': '10:00',
        'slot_type': 'Lecture',
      });

      expect(slot.lecturerName, isEmpty);
    });

    test('normalizes common course code variants consistently', () {
      expect(normalizeCourseCode('CS201'), 'CS201');
      expect(normalizeCourseCode(' CS 201 '), 'CS201');
      expect(normalizeCourseCode('cs-201'), 'CS201');
      expect(normalizeCourseCode('CS.201'), 'CS201');
    });

    test('parses common timetable times without silent defaults', () {
      expect(parseTimetableTime('08:30').minutes, 510);
      expect(parseTimetableTime('8.30').minutes, 510);
      expect(parseTimetableTime('8:30AM').minutes, 510);
      expect(parseTimetableTime('8 AM').minutes, 480);
      expect(parseTimetableTime('9 PM').minutes, 1260);
      expect(parseTimetableTime('12:00 AM').minutes, 0);
      expect(parseTimetableTime('12:00 PM').minutes, 720);
      expect(parseTimetableTime('13.30').minutes, 810);
      expect(parseTimetableTime('25:70').isValid, isFalse);
    });

    test('marks invalid imported times instead of fabricating a class time',
        () {
      final slot = TimetableSlotImport.fromJson({
        'day': 'Monday',
        'course_code': 'CS 201',
        'course_name': 'Algorithms',
        'start_time': '25:70',
        'end_time': '10:00',
      });

      expect(slot.isValid, isFalse);
      expect(slot.rawStartTime, '25:70');
      expect(slot.validationError, contains('invalid'));
    });
  });
}
