/// A single course from a completed (past) semester result slip.
/// Pure Dart — no Flutter or Isar dependencies.
class PastCourseResult {
  final String courseCode;
  final String courseName;
  final double creditHours;

  /// Letter grade: A, B, C, D, or F.
  final String grade;

  const PastCourseResult({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.grade,
  });

  /// KNUST letter-grade → numeric score used in CWA calculation.
  double get score => gradeToScore(grade);

  static double gradeToScore(String grade) {
    switch (grade.trim().toUpperCase()) {
      case 'A':
        return 85.0;
      case 'B':
        return 75.0;
      case 'C':
        return 65.0;
      case 'D':
        return 55.0;
      default: // F or anything unrecognised
        return 45.0;
    }
  }

  factory PastCourseResult.fromJson(Map<String, dynamic> json) {
    return PastCourseResult(
      courseCode: (json['course_code'] as String? ?? '').trim(),
      courseName: (json['course_name'] as String? ?? '').trim(),
      creditHours:
          ((json['credit_hours'] as num?) ?? 3).toDouble().clamp(1.0, 6.0),
      grade: (json['grade'] as String? ?? 'F').trim().toUpperCase(),
    );
  }

  PastCourseResult copyWith({
    String? courseCode,
    String? courseName,
    double? creditHours,
    String? grade,
  }) =>
      PastCourseResult(
        courseCode: courseCode ?? this.courseCode,
        courseName: courseName ?? this.courseName,
        creditHours: creditHours ?? this.creditHours,
        grade: grade ?? this.grade,
      );
}
