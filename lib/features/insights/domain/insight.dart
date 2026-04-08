enum InsightType { positive, warning, neutral, tip }

class Insight {
  const Insight({
    required this.message,
    required this.type,
    this.courseCode,
    required this.icon,
  });

  final String message;
  final InsightType type;
  final String? courseCode;
  final String icon;
}
