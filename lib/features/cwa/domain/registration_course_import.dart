/// A single course parsed from a course registration slip.
/// Pure Dart — no Flutter or Isar dependencies.
class RegistrationCourseImport {
  final String courseCode;
  final String courseName;
  final double creditHours;

  const RegistrationCourseImport({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
  });

  factory RegistrationCourseImport.fromJson(Map<String, dynamic> json) {
    return RegistrationCourseImport(
      courseCode: (json['course_code'] as String? ?? '').trim(),
      courseName: (json['course_name'] as String? ?? '').trim(),
      creditHours:
          ((json['credit_hours'] as num?) ?? 3).toDouble().clamp(1.0, 6.0),
    );
  }

  RegistrationCourseImport copyWith({
    String? courseCode,
    String? courseName,
    double? creditHours,
  }) =>
      RegistrationCourseImport(
        courseCode: courseCode ?? this.courseCode,
        courseName: courseName ?? this.courseName,
        creditHours: creditHours ?? this.creditHours,
      );
}
