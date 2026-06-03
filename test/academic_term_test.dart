import 'package:campusiq/features/cwa/domain/academic_term.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Academic term keys', () {
    test('parses and formats regular semester keys', () {
      final first = ActiveSemesterSelection.fromKey('2024-Sem1');
      final second = ActiveSemesterSelection.fromKey('2024-Sem2');

      expect(first.termType, AcademicTermType.firstSemester);
      expect(first.displayLabel, '2024/2025 • First Semester');
      expect(second.termType, AcademicTermType.secondSemester);
      expect(second.displayLabel, '2024/2025 • Second Semester');
    });

    test('parses and formats supplementary semester keys', () {
      final supplementary = ActiveSemesterSelection.fromKey('2024-Supp');

      expect(supplementary.termType, AcademicTermType.supplementarySemester);
      expect(supplementary.key, '2024-Supp');
      expect(
        supplementary.displayLabel,
        '2024/2025 • Supplementary Semester',
      );
    });

    test('sorts supplementary after second semester in the same year', () {
      final first = academicTermSortValue(
        semesterKey: '2024-Sem1',
        semesterLabel: '',
        createdAt: DateTime(2024),
      );
      final second = academicTermSortValue(
        semesterKey: '2024-Sem2',
        semesterLabel: '',
        createdAt: DateTime(2024),
      );
      final supplementary = academicTermSortValue(
        semesterKey: '2024-Supp',
        semesterLabel: '',
        createdAt: DateTime(2024),
      );

      expect(first, lessThan(second));
      expect(second, lessThan(supplementary));
    });
  });
}
