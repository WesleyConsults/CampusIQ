enum AcademicTermType {
  firstSemester,
  secondSemester,
  supplementarySemester;

  static AcademicTermType fromSemesterNumber(int number) {
    return switch (number) {
      1 => AcademicTermType.firstSemester,
      2 => AcademicTermType.secondSemester,
      3 => AcademicTermType.supplementarySemester,
      _ => AcademicTermType.secondSemester,
    };
  }

  static AcademicTermType fromLabel(String label) {
    final normalized = label.trim().toLowerCase();
    if (normalized.contains('supplementary') ||
        normalized.contains('supp') ||
        normalized.contains('resit') ||
        normalized.contains('re-sit')) {
      return AcademicTermType.supplementarySemester;
    }
    if (normalized.contains('first')) return AcademicTermType.firstSemester;
    return AcademicTermType.secondSemester;
  }

  int get sortOrder {
    return switch (this) {
      AcademicTermType.firstSemester => 1,
      AcademicTermType.secondSemester => 2,
      AcademicTermType.supplementarySemester => 3,
    };
  }

  int get semesterNumber {
    return switch (this) {
      AcademicTermType.firstSemester => 1,
      AcademicTermType.secondSemester => 2,
      AcademicTermType.supplementarySemester => 3,
    };
  }

  String get keySuffix {
    return switch (this) {
      AcademicTermType.firstSemester => 'Sem1',
      AcademicTermType.secondSemester => 'Sem2',
      AcademicTermType.supplementarySemester => 'Supp',
    };
  }

  String get label {
    return switch (this) {
      AcademicTermType.firstSemester => 'First Semester',
      AcademicTermType.secondSemester => 'Second Semester',
      AcademicTermType.supplementarySemester => 'Supplementary Semester',
    };
  }
}

class ActiveSemesterSelection {
  final int startYear;
  final AcademicTermType termType;

  ActiveSemesterSelection({
    required this.startYear,
    int semesterNumber = 2,
    AcademicTermType? termType,
  }) : termType =
            termType ?? AcademicTermType.fromSemesterNumber(semesterNumber);

  factory ActiveSemesterSelection.fromKey(String key) {
    final trimmed = key.trim();
    final regularMatch = RegExp(r'^(\d{4})-Sem([12])$').firstMatch(trimmed);
    if (regularMatch != null) {
      return ActiveSemesterSelection(
        startYear: int.parse(regularMatch.group(1)!),
        semesterNumber: int.parse(regularMatch.group(2)!),
      );
    }

    final supplementaryMatch =
        RegExp(r'^(\d{4})-Supp$', caseSensitive: false).firstMatch(trimmed);
    if (supplementaryMatch != null) {
      return ActiveSemesterSelection(
        startYear: int.parse(supplementaryMatch.group(1)!),
        termType: AcademicTermType.supplementarySemester,
      );
    }

    return ActiveSemesterSelection(startYear: 2024, semesterNumber: 2);
  }

  int get semesterNumber => termType.semesterNumber;

  String get key => '$startYear-${termType.keySuffix}';

  String get academicYearLabel => '$startYear/${startYear + 1}';

  String get semesterLabel => termType.label;

  String get displayLabel => '$academicYearLabel • $semesterLabel';

  ActiveSemesterSelection get next {
    if (termType == AcademicTermType.firstSemester) {
      return ActiveSemesterSelection(
        startYear: startYear,
        termType: AcademicTermType.secondSemester,
      );
    }

    return ActiveSemesterSelection(
      startYear: startYear + 1,
      termType: AcademicTermType.firstSemester,
    );
  }
}

String formatAcademicTermLabel(String semesterKey) {
  return ActiveSemesterSelection.fromKey(semesterKey).displayLabel;
}

int academicTermSortValue({
  required String? semesterKey,
  required String semesterLabel,
  required DateTime createdAt,
}) {
  final key = semesterKey ?? '';
  final regularKeyMatch = RegExp(r'^(\d{4})-Sem([12])$').firstMatch(key);
  if (regularKeyMatch != null) {
    final year = int.tryParse(regularKeyMatch.group(1) ?? '') ?? 0;
    final term = int.tryParse(regularKeyMatch.group(2) ?? '') ?? 0;
    return (year * 10) + term;
  }

  final supplementaryKeyMatch =
      RegExp(r'^(\d{4})-Supp$', caseSensitive: false).firstMatch(key);
  if (supplementaryKeyMatch != null) {
    final year = int.tryParse(supplementaryKeyMatch.group(1) ?? '') ?? 0;
    return (year * 10) + AcademicTermType.supplementarySemester.sortOrder;
  }

  final yearMatch = RegExp(r'(\d{4})').firstMatch(semesterLabel);
  final year = int.tryParse(yearMatch?.group(1) ?? '') ?? 0;
  final term = AcademicTermType.fromLabel(semesterLabel);
  if (year > 0) return (year * 10) + term.sortOrder;

  return createdAt.millisecondsSinceEpoch;
}
