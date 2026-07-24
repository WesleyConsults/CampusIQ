import 'package:campusiq/features/streak/domain/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('meaningful study streak requirement', () {
    test('combines short sessions from the same day', () {
      final date = DateTime(2026, 7, 24);

      final qualifying = StreakCalculator.qualifyingStudyDates(
        sessions: [
          (date: date, minutes: 12),
          (date: date.add(const Duration(hours: 3)), minutes: 8),
        ],
      );

      expect(qualifying, [DateTime(2026, 7, 24)]);
    });

    test('does not qualify a day below twenty focused minutes', () {
      final qualifying = StreakCalculator.qualifyingStudyDates(
        sessions: [
          (date: DateTime(2026, 7, 24), minutes: 19),
        ],
      );

      expect(qualifying, isEmpty);
    });

    test('uses qualifying dates to calculate consecutive streaks', () {
      final qualifying = StreakCalculator.qualifyingStudyDates(
        sessions: [
          (date: DateTime(2026, 7, 23), minutes: 20),
          (date: DateTime(2026, 7, 24), minutes: 25),
        ],
      );

      final result = StreakCalculator.calculate(
        activeDates: qualifying,
        today: DateTime(2026, 7, 24),
      );

      expect(result.currentStreak, 2);
      expect(result.studiedToday, isTrue);
    });
  });
}
