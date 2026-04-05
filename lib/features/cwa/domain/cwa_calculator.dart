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

  /// Returns index of course with highest credit weight — most CWA impact.
  static int highestImpactCourseIndex(List<({double creditHours, double score})> courses) {
    if (courses.isEmpty) return -1;
    int idx = 0;
    double maxCredits = 0;
    for (int i = 0; i < courses.length; i++) {
      if (courses[i].creditHours > maxCredits) {
        maxCredits = courses[i].creditHours;
        idx = i;
      }
    }
    return idx;
  }

  /// Simulates new CWA if one course score changes.
  static double whatIf({
    required List<({double creditHours, double score})> courses,
    required int index,
    required double newScore,
  }) {
    final modified = List.of(courses);
    modified[index] = (creditHours: modified[index].creditHours, score: newScore);
    return calculate(modified);
  }
}
