/// Pure CWA calculation logic — no Flutter, no Isar, fully testable.
class CwaCalculator {
  /// CWA = sum(creditHours * score) / sum(creditHours)
  static double calculate(List<({double creditHours, double score})> courses) {
    if (courses.isEmpty) return 0.0;

    double totalWeightedScore = 0;
    double totalCredits = 0;

    for (final c in courses) {
      totalWeightedScore += c.creditHours * c.score;
      totalCredits += c.creditHours;
    }

    if (totalCredits == 0) return 0.0;
    return totalWeightedScore / totalCredits;
  }

  /// How far projected CWA is from target. Positive = below target.
  static double gap(double projected, double target) => target - projected;

  /// Returns all indices of courses tied for the highest credit weight.
  static Set<int> highestImpactCourseIndices(
      List<({double creditHours, double score})> courses) {
    if (courses.isEmpty) return {};
    double maxCredits =
        courses.map((c) => c.creditHours).reduce((a, b) => a > b ? a : b);
    return {
      for (int i = 0; i < courses.length; i++)
        if (courses[i].creditHours == maxCredits) i,
    };
  }

  /// Simulates new CWA if one course score changes.
  static double whatIf({
    required List<({double creditHours, double score})> courses,
    required int index,
    required double newScore,
  }) {
    final modified = List.of(courses);
    modified[index] =
        (creditHours: modified[index].creditHours, score: newScore);
    return calculate(modified);
  }

  /// True cumulative CWA across all past semesters + current semester courses.
  /// [pastSemesters] — each entry is a list of (creditHours, score) pairs for one past semester.
  /// [currentCourses] — current semester courses (same shape as [calculate]).
  static double calculateCumulative({
    required List<List<({double creditHours, double score})>> pastSemesters,
    required List<({double creditHours, double score})> currentCourses,
  }) {
    final all = <({double creditHours, double score})>[];
    for (final sem in pastSemesters) {
      all.addAll(sem);
    }
    all.addAll(currentCourses);
    return calculate(all);
  }

  /// Total credit hours across all past semesters + current semester.
  static double totalCredits({
    required List<List<({double creditHours, double score})>> pastSemesters,
    required List<({double creditHours, double score})> currentCourses,
  }) {
    double total = 0;
    for (final sem in pastSemesters) {
      for (final c in sem) {
        total += c.creditHours;
      }
    }
    for (final c in currentCourses) {
      total += c.creditHours;
    }
    return total;
  }
}
