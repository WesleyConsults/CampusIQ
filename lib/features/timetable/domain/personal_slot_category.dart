/// Categories for personal timetable slots.
/// Stored as string in Isar for readability and forward compatibility.
enum PersonalSlotCategory {
  study,
  gym,
  rest,
  meal,
  sideProject,
  devotion,
  errand,
  custom;

  String get label {
    switch (this) {
      case study:      return 'Study';
      case gym:        return 'Gym';
      case rest:       return 'Rest';
      case meal:       return 'Meal';
      case sideProject: return 'Side Project';
      case devotion:   return 'Devotion';
      case errand:     return 'Errand';
      case custom:     return 'Custom';
    }
  }

  String get emoji {
    switch (this) {
      case study:      return '📚';
      case gym:        return '💪';
      case rest:       return '😴';
      case meal:       return '🍽️';
      case sideProject: return '💻';
      case devotion:   return '🙏';
      case errand:     return '🏃';
      case custom:     return '📌';
    }
  }

  /// Light background color value for this category
  int get colorValue {
    switch (this) {
      case study:      return 0xFF1565C0; // Blue
      case gym:        return 0xFF2E7D32; // Green
      case rest:       return 0xFF6A1B9A; // Purple
      case meal:       return 0xFFE65100; // Orange
      case sideProject: return 0xFF00838F; // Cyan
      case devotion:   return 0xFFC62828; // Red
      case errand:     return 0xFF558B2F; // Light green
      case custom:     return 0xFF4527A0; // Indigo
    }
  }

  static PersonalSlotCategory fromString(String value) {
    return PersonalSlotCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => custom,
    );
  }
}
