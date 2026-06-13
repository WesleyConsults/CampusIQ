import 'package:campusiq/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextWeeklyCourseReminderTime', () {
    test('schedules later on the same day', () {
      final now = DateTime(2026, 6, 15, 8);

      final result = nextWeeklyCourseReminderTime(
        now: now,
        dayIndex: DateTime.monday - 1,
        classStartMinutes: 10 * 60,
        offsetMinutes: 30,
      );

      expect(result, DateTime(2026, 6, 15, 9, 30));
    });

    test('rolls an elapsed same-day alarm to next week', () {
      final now = DateTime(2026, 6, 15, 9, 45);

      final result = nextWeeklyCourseReminderTime(
        now: now,
        dayIndex: DateTime.monday - 1,
        classStartMinutes: 10 * 60,
        offsetMinutes: 30,
      );

      expect(result, DateTime(2026, 6, 22, 9, 30));
    });

    test('handles an offset that crosses into the previous day', () {
      final now = DateTime(2026, 6, 15, 12);

      final result = nextWeeklyCourseReminderTime(
        now: now,
        dayIndex: DateTime.tuesday - 1,
        classStartMinutes: 60,
        offsetMinutes: 120,
      );

      expect(result, DateTime(2026, 6, 16).subtract(const Duration(hours: 1)));
    });
  });
}
