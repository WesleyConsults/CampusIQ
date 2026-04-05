/// How a personal slot repeats.
enum RecurrenceType {
  /// Happens once on a specific date
  oneOff,

  /// Repeats every day
  daily,

  /// Repeats on specific days of the week (stored as List<int> in the model)
  weekly;

  String get label {
    switch (this) {
      case oneOff: return 'One-off';
      case daily:  return 'Every day';
      case weekly: return 'Weekly (specific days)';
    }
  }

  static RecurrenceType fromString(String value) {
    return RecurrenceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => oneOff,
    );
  }
}
