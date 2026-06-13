import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
