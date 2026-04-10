import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'prompt_templates.dart';

class ContextBuilder {
  final CwaRepository cwaRepository;
  final SessionRepository sessionRepository;
  final TimetableRepository timetableRepository;
  final UserPrefsRepository userPrefsRepository;

  ContextBuilder({
    required this.cwaRepository,
    required this.sessionRepository,
    required this.timetableRepository,
    required this.userPrefsRepository,
  });

  Future<String> buildAcademicContext(String semesterKey) async {
    // Fetch all data
    final courses = await _getCourses(semesterKey);
    final sessionsThisWeek = await _getSessionsThisWeek(semesterKey);
    final todaySlots = await _getTodaySlots(semesterKey);

    // Build course summary
    String courseSummary = '';
    if (courses.isNotEmpty) {
      final courseLines = courses
          .take(5)
          .map((c) => '${c.code} (${c.creditHours.toInt()}cr, target ${c.expectedScore.toInt()})')
          .toList();
      courseSummary = '- Courses: ${courseLines.join(', ')}';
    }

    // Build study session summary
    final totalHours =
        sessionsThisWeek.fold<double>(0, (sum, s) => sum + (s.durationMinutes / 60.0));
    String sessionSummary = sessionsThisWeek.isEmpty
        ? '- This week: No sessions logged this week yet'
        : '- This week: ${totalHours.toStringAsFixed(1)} hours studied';

    // Build streak info — placeholder for now
    String streakSummary = '- Study streak: No active streak';

    // Build today's timetable summary
    String timetableSummary = '';
    if (todaySlots.isNotEmpty) {
      final slots = todaySlots.take(3).map((s) => '${s.title} ${s.startTime.hour}–${s.endTime.hour}').toList();
      timetableSummary = '- Today\'s classes: ${slots.join(", ")}';
    }

    // University and programme — default to KNUST for Phase 11
    const String university = 'KNUST';
    const String programme = 'Unknown Programme';

    final context = '''
Student context:
- University: $university | Programme: $programme
$courseSummary
$streakSummary
$sessionSummary
$timetableSummary''';

    return PromptTemplates.withContext(context);
  }

  Future<List<dynamic>> _getCourses(String semesterKey) async {
    try {
      // Using Future to match the stream API
      final stream = cwaRepository.watchCourses(semesterKey);
      final courses = await stream.first;
      return courses;
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> _getSessionsThisWeek(String semesterKey) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final sessions = await sessionRepository.getSessionsForRange(semesterKey, weekStart, weekEnd);
      return sessions;
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> _getTodaySlots(String semesterKey) async {
    try {
      final now = DateTime.now();
      final dayIndex = now.weekday - 1; // Isar uses 0-6
      final stream = timetableRepository.watchSlotsForDay(semesterKey, dayIndex);
      final slots = await stream.first;
      return slots;
    } catch (_) {
      return [];
    }
  }
}
