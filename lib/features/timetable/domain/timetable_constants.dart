class TimetableConstants {
  /// Days shown in the timetable grid. KNUST runs Monday to Saturday.
  static const List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const List<String> dayFullLabels = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  /// Grid time range: 6AM to 8PM
  static const int gridStartHour = 6;   // 6AM = 360 minutes
  static const int gridEndHour = 20;    // 8PM = 1200 minutes
  static const int gridStartMinutes = gridStartHour * 60;
  static const int gridEndMinutes = gridEndHour * 60;
  static const int totalGridMinutes = gridEndMinutes - gridStartMinutes; // 840

  /// Height in pixels per minute in the grid
  static const double pixelsPerMinute = 1.5;

  /// Total grid height in pixels
  static const double totalGridHeight = totalGridMinutes * pixelsPerMinute; // 1260px

  /// Width of the time label column on the left
  static const double timeLabelWidth = 52.0;

  /// Height of each hour row label
  static const double hourRowHeight = 60.0 * pixelsPerMinute; // 90px

  /// Slot type options
  static const List<String> slotTypes = ['Lecture', 'Practical', 'Tutorial'];

  /// Preset slot colors (one per course, cycles through this list)
  static const List<int> slotColorValues = [
    0xFF1565C0, // Deep blue
    0xFF2E7D32, // Deep green
    0xFF6A1B9A, // Deep purple
    0xFFC62828, // Deep red
    0xFF00838F, // Deep cyan
    0xFFE65100, // Deep orange
    0xFF4527A0, // Deep indigo
    0xFF558B2F, // Light green dark
  ];

  /// Returns a color value for a new slot based on how many slots exist
  static int colorForIndex(int index) =>
      slotColorValues[index % slotColorValues.length];

  /// Converts minutes-from-midnight to a human-readable label e.g. "8:30 AM"
  static String minutesToLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final suffix = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour.toString()}:${m.toString().padLeft(2, '0')} $suffix';
  }
}
