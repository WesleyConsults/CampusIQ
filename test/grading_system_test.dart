import 'package:campusiq/core/domain/grading_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GradingSystem', () {
    test('defaults unknown ids to CWA', () {
      expect(GradingSystem.byId('nope').id, GradingSystem.cwa.id);
      expect(GradingSystem.byId(null).id, GradingSystem.cwa.id);
    });

    test('formats CWA and GPA scores with the right scale', () {
      expect(GradingSystem.cwa.formatScore(72.25, includeUnit: true), '72.25%');
      expect(
        GradingSystem.ghanaFourPoint.formatScore(3.55, includeUnit: true),
        '3.55 pts',
      );
      expect(
        GradingSystem.ghanaFivePoint.formatScore(4.25, includeUnit: true),
        '4.25 pts',
      );
    });

    test('maps Ghana GPA points to letters', () {
      expect(GradingSystem.ghanaFourPoint.letterForScore(4.0), 'A');
      expect(GradingSystem.ghanaFourPoint.letterForScore(3.5), 'B+');
      expect(GradingSystem.ghanaFivePoint.letterForScore(4.5), 'A');
    });
  });
}
