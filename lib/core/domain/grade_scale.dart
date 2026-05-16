class GradeScaleEntry {
  final String letter;
  final double minScore;
  final double maxScore;
  final double points;
  final String interpretation;

  const GradeScaleEntry({
    required this.letter,
    required this.minScore,
    required this.maxScore,
    required this.points,
    required this.interpretation,
  });

  bool containsScore(double score) => score >= minScore && score <= maxScore;
}

class GradeScale {
  final List<GradeScaleEntry> entries;

  const GradeScale(this.entries);

  List<String> get availableGrades =>
      entries.map((entry) => entry.letter).toList();

  GradeScaleEntry? entryForLetter(String letter) {
    final normalized = letter.trim().toUpperCase();
    for (final entry in entries) {
      if (entry.letter.toUpperCase() == normalized) return entry;
    }
    return null;
  }

  GradeScaleEntry? entryForScore(double score) {
    for (final entry in entries) {
      if (entry.containsScore(score)) return entry;
    }
    return null;
  }

  double? pointsForLetter(String letter) => entryForLetter(letter)?.points;

  String? letterForScore(double score) => entryForScore(score)?.letter;
}
