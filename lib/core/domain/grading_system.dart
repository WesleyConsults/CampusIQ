import 'package:campusiq/core/domain/grade_scale.dart';

class GradingSystem {
  final String id;
  final String label;
  final String cumulativeLabel;
  final String plannerTitle;
  final double minScore;
  final double maxScore;
  final double targetMin;
  final double targetMax;
  final double defaultTarget;
  final int sliderDivisions;
  final int displayDecimals;
  final String scoreUnit;
  final bool usesLetterGrades;
  final GradeScale? gradeScale;

  const GradingSystem({
    required this.id,
    required this.label,
    required this.cumulativeLabel,
    required this.plannerTitle,
    required this.minScore,
    required this.maxScore,
    required this.targetMin,
    required this.targetMax,
    required this.defaultTarget,
    required this.sliderDivisions,
    required this.displayDecimals,
    required this.scoreUnit,
    required this.usesLetterGrades,
    this.gradeScale,
  });

  String get projectedLabel => 'Projected $label';
  String get cumulativeMetricLabel => 'Cumulative $cumulativeLabel';
  String get targetLabel => 'Target $label';
  String get impactTitle => '$label Impact';
  String get scoreInputLabel =>
      usesLetterGrades ? 'Expected points' : 'Expected score';

  String formatScore(double score, {bool includeUnit = false}) {
    final value =
        score.clamp(minScore, maxScore).toStringAsFixed(displayDecimals);
    if (!includeUnit || scoreUnit.isEmpty) return value;
    return scoreUnit == '%' ? '$value%' : '$value $scoreUnit';
  }

  String formatDelta(double value) =>
      value.abs().toStringAsFixed(displayDecimals);

  String? letterForScore(double score) => gradeScale?.letterForScore(score);

  String gradeForScore(double score) {
    final letter = letterForScore(score);
    if (letter != null) return letter;
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  double scoreForGrade(String grade) {
    final points = gradeScale?.pointsForLetter(grade);
    if (points != null) return points;
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

  double clampScore(double score) => score.clamp(minScore, maxScore).toDouble();

  static const cwa = GradingSystem(
    id: 'cwa',
    label: 'CWA',
    cumulativeLabel: 'CWA',
    plannerTitle: 'CWA Planner',
    minScore: 0,
    maxScore: 100,
    targetMin: 40,
    targetMax: 100,
    defaultTarget: 70,
    sliderDivisions: 100,
    displayDecimals: 2,
    scoreUnit: '%',
    usesLetterGrades: false,
    gradeScale: GradeScale([
      GradeScaleEntry(
        letter: 'A',
        minScore: 80,
        maxScore: 100,
        points: 85,
        interpretation: 'Excellent',
      ),
      GradeScaleEntry(
        letter: 'B',
        minScore: 70,
        maxScore: 79.999,
        points: 75,
        interpretation: 'Very Good',
      ),
      GradeScaleEntry(
        letter: 'C',
        minScore: 60,
        maxScore: 69.999,
        points: 65,
        interpretation: 'Good',
      ),
      GradeScaleEntry(
        letter: 'D',
        minScore: 50,
        maxScore: 59.999,
        points: 55,
        interpretation: 'Pass',
      ),
      GradeScaleEntry(
        letter: 'F',
        minScore: 0,
        maxScore: 49.999,
        points: 45,
        interpretation: 'Fail',
      ),
    ]),
  );

  static const ghanaFourPoint = GradingSystem(
    id: 'gpa_4pt',
    label: 'GPA',
    cumulativeLabel: 'CGPA',
    plannerTitle: 'GPA Planner',
    minScore: 0,
    maxScore: 4,
    targetMin: 0,
    targetMax: 4,
    defaultTarget: 3.6,
    sliderDivisions: 40,
    displayDecimals: 2,
    scoreUnit: 'pts',
    usesLetterGrades: true,
    gradeScale: GradeScale([
      GradeScaleEntry(
          letter: 'A',
          minScore: 4,
          maxScore: 4,
          points: 4,
          interpretation: 'Outstanding'),
      GradeScaleEntry(
          letter: 'B+',
          minScore: 3.5,
          maxScore: 3.999,
          points: 3.5,
          interpretation: 'Very Good'),
      GradeScaleEntry(
          letter: 'B',
          minScore: 3,
          maxScore: 3.499,
          points: 3,
          interpretation: 'Good'),
      GradeScaleEntry(
          letter: 'C+',
          minScore: 2.5,
          maxScore: 2.999,
          points: 2.5,
          interpretation: 'Fairly Good'),
      GradeScaleEntry(
          letter: 'C',
          minScore: 2,
          maxScore: 2.499,
          points: 2,
          interpretation: 'Average'),
      GradeScaleEntry(
          letter: 'D+',
          minScore: 1.5,
          maxScore: 1.999,
          points: 1.5,
          interpretation: 'Below Average'),
      GradeScaleEntry(
          letter: 'D',
          minScore: 1,
          maxScore: 1.499,
          points: 1,
          interpretation: 'Marginal Pass'),
      GradeScaleEntry(
          letter: 'E',
          minScore: 0.5,
          maxScore: 0.999,
          points: 0.5,
          interpretation: 'Unsatisfactory'),
      GradeScaleEntry(
          letter: 'F',
          minScore: 0,
          maxScore: 0.499,
          points: 0,
          interpretation: 'Fail'),
    ]),
  );

  static const gimpaFourPoint = GradingSystem(
    id: 'gpa_4pt_gimpa',
    label: 'GPA',
    cumulativeLabel: 'CGPA',
    plannerTitle: 'GPA Planner',
    minScore: 0,
    maxScore: 4,
    targetMin: 0,
    targetMax: 4,
    defaultTarget: 3.6,
    sliderDivisions: 40,
    displayDecimals: 2,
    scoreUnit: 'pts',
    usesLetterGrades: true,
    gradeScale: GradeScale([
      GradeScaleEntry(
          letter: 'A+',
          minScore: 4,
          maxScore: 4,
          points: 4,
          interpretation: 'Distinction'),
      GradeScaleEntry(
          letter: 'A',
          minScore: 3.75,
          maxScore: 3.999,
          points: 3.75,
          interpretation: 'Excellent'),
      GradeScaleEntry(
          letter: 'B+',
          minScore: 3.5,
          maxScore: 3.749,
          points: 3.5,
          interpretation: 'Very Good'),
      GradeScaleEntry(
          letter: 'B',
          minScore: 3,
          maxScore: 3.499,
          points: 3,
          interpretation: 'Good'),
      GradeScaleEntry(
          letter: 'C+',
          minScore: 2.5,
          maxScore: 2.999,
          points: 2.5,
          interpretation: 'Average'),
      GradeScaleEntry(
          letter: 'C',
          minScore: 2,
          maxScore: 2.499,
          points: 2,
          interpretation: 'Pass'),
      GradeScaleEntry(
          letter: 'D+',
          minScore: 1.75,
          maxScore: 1.999,
          points: 1.75,
          interpretation: 'Pass'),
      GradeScaleEntry(
          letter: 'D',
          minScore: 1,
          maxScore: 1.749,
          points: 1,
          interpretation: 'Below Average'),
      GradeScaleEntry(
          letter: 'F',
          minScore: 0,
          maxScore: 0.999,
          points: 0,
          interpretation: 'Fail'),
    ]),
  );

  static const ghanaFivePoint = GradingSystem(
    id: 'cgpa_5pt',
    label: 'GPA',
    cumulativeLabel: 'CGPA',
    plannerTitle: 'CGPA Planner',
    minScore: 0,
    maxScore: 5,
    targetMin: 0,
    targetMax: 5,
    defaultTarget: 4,
    sliderDivisions: 50,
    displayDecimals: 2,
    scoreUnit: 'pts',
    usesLetterGrades: true,
    gradeScale: GradeScale([
      GradeScaleEntry(
          letter: 'A+',
          minScore: 5,
          maxScore: 5,
          points: 5,
          interpretation: 'Outstanding'),
      GradeScaleEntry(
          letter: 'A',
          minScore: 4.5,
          maxScore: 4.999,
          points: 4.5,
          interpretation: 'Excellent'),
      GradeScaleEntry(
          letter: 'B+',
          minScore: 4,
          maxScore: 4.499,
          points: 4,
          interpretation: 'Very Good'),
      GradeScaleEntry(
          letter: 'B',
          minScore: 3.5,
          maxScore: 3.999,
          points: 3.5,
          interpretation: 'Good'),
      GradeScaleEntry(
          letter: 'C+',
          minScore: 3,
          maxScore: 3.499,
          points: 3,
          interpretation: 'Above Average'),
      GradeScaleEntry(
          letter: 'C',
          minScore: 2.5,
          maxScore: 2.999,
          points: 2.5,
          interpretation: 'Average'),
      GradeScaleEntry(
          letter: 'D+',
          minScore: 2,
          maxScore: 2.499,
          points: 2,
          interpretation: 'Pass'),
      GradeScaleEntry(
          letter: 'D',
          minScore: 1.5,
          maxScore: 1.999,
          points: 1.5,
          interpretation: 'Weak Pass'),
      GradeScaleEntry(
          letter: 'F',
          minScore: 0,
          maxScore: 1.499,
          points: 0,
          interpretation: 'Fail'),
    ]),
  );

  static const all = [
    cwa,
    ghanaFourPoint,
    gimpaFourPoint,
    ghanaFivePoint,
  ];

  static GradingSystem byId(String? id) {
    final normalized = id?.trim();
    if (normalized == null || normalized.isEmpty) return cwa;
    for (final system in all) {
      if (system.id == normalized) return system;
    }
    return cwa;
  }
}
