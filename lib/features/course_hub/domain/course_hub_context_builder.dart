import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/course_hub/data/models/course_note_model.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

class CourseHubContextBuilder {
  /// Builds a context string injected into the AI system prompt
  /// for the course-scoped chat.
  static String build({
    required CourseModel course,
    required List<StudySessionModel> sessions,
    required List<CourseNoteModel> notes,
    required StreakResult courseStreak,
  }) {
    final totalMinutes =
        sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    final lastSession = sessions.isNotEmpty
        ? sessions.reduce(
            (a, b) => a.startTime.isAfter(b.startTime) ? a : b)
        : null;

    final daysSinceLast = lastSession != null
        ? DateTime.now().difference(lastSession.startTime).inDays
        : -1;

    final lastStudiedStr = daysSinceLast < 0
        ? 'Never studied'
        : daysSinceLast == 0
            ? 'Studied today'
            : '$daysSinceLast days ago';

    final gradeStr = _gradeLabel(course.expectedScore);
    final streakStatus = courseStreak.isAlive ? 'alive' : 'broken';

    final noteSummary = notes.isNotEmpty
        ? notes.first.body.length > 300
            ? notes.first.body.substring(0, 300)
            : notes.first.body
        : 'No notes yet';

    return '''Course: ${course.code} — ${course.name} (${course.creditHours.toInt()} credit hours)
Expected score: ${course.expectedScore.toInt()}% ($gradeStr)
Sessions for this course: ${sessions.length} total, last studied: $lastStudiedStr
Total study time: $timeStr
Course streak: ${courseStreak.currentStreak} days ($streakStatus)
Student notes summary: $noteSummary''';
  }

  static String _gradeLabel(double score) {
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
}
