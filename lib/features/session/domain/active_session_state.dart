/// Represents an in-progress session held in global provider state.
/// Uses DateTime anchor — never a running counter — for Android reliability.
class ActiveSessionState {
  final String courseCode;
  final String courseName;
  final String courseSource; // "cwa" | "timetable" | "custom"
  final DateTime startTime;

  const ActiveSessionState({
    required this.courseCode,
    required this.courseName,
    required this.courseSource,
    required this.startTime,
  });

  /// Always accurate regardless of app backgrounding
  Duration get elapsed => DateTime.now().difference(startTime);

  int get elapsedMinutes => elapsed.inMinutes;

  String get formattedElapsed {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;
    final s = elapsed.inSeconds % 60;
    if (h > 0) return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
}
