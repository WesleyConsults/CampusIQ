import 'package:isar/isar.dart';

part 'past_semester_model.g.dart';

/// One completed semester's results, imported from a result slip.
@collection
class PastSemesterModel {
  Id id = Isar.autoIncrement;

  /// Human-readable label the student assigns e.g. "Year 1 Sem 1".
  late String semesterLabel;

  /// Ordered list of courses from that semester.
  late List<PastCourseEntry> courses;

  /// Optional: what the slip actually says for semester CWA
  double? reportedSemesterCwa;

  /// Optional: what the slip actually says for cumulative CWA
  double? reportedCumulativeCwa;

  /// Credits Calc from the CUMULATIVE column of the slip summary table.
  /// When present, used directly instead of reconstructing from individual marks.
  double? cumulativeCreditsCalc;

  /// Weighted Marks from the CUMULATIVE column of the slip summary table.
  /// When present, used directly instead of reconstructing from individual marks.
  double? cumulativeWeightedMarks;

  DateTime createdAt = DateTime.now();

  PastSemesterModel();

  PastSemesterModel.create({
    required this.semesterLabel,
    required this.courses,
    this.reportedSemesterCwa,
    this.reportedCumulativeCwa,
    this.cumulativeCreditsCalc,
    this.cumulativeWeightedMarks,
  });
}

/// A single course entry embedded inside [PastSemesterModel].
@embedded
class PastCourseEntry {
  late String courseCode;
  late String courseName;
  late double creditHours;

  /// Letter grade: A, B, C, D, or F.
  late String grade;

  /// Exact number grade (e.g., 79.0) if parsed/entered, giving exact CWA.
  double? mark;

  PastCourseEntry();

  PastCourseEntry.create({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.grade,
    this.mark,
  });

  /// KNUST letter-grade → numeric score used in CWA calculation.
  /// If mark is available, use it directly (as KNUST CWA uses actual marks).
  double get score {
    if (mark != null) return mark!;
    switch (grade.trim().toUpperCase()) {
      case 'A':
        return 85.0;
      case 'B':
        return 75.0;
      case 'C':
        return 65.0;
      case 'D':
        return 55.0;
      default:
        return 45.0;
    }
  }
}
