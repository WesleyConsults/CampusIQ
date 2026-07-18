String normalizeCourseCode(String value) {
  return value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}
