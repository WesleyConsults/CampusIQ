enum AcademicDocumentKind {
  registrationSlip,
  resultSlip,
  unknown;

  static AcademicDocumentKind fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    if (normalized.contains('result') ||
        normalized.contains('grade') ||
        normalized.contains('transcript')) {
      return AcademicDocumentKind.resultSlip;
    }
    if (normalized.contains('registration') ||
        normalized.contains('registered') ||
        normalized.contains('course_selection')) {
      return AcademicDocumentKind.registrationSlip;
    }
    return AcademicDocumentKind.unknown;
  }
}
