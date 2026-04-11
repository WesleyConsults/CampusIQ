import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'prompt_templates.dart';

class WhatIfInput {
  final String courseCode;
  final String courseName;
  final int creditHours;
  final double originalScore;
  final double newScore;
  final double originalCwa;
  final double newCwa;
  final double targetCwa;

  const WhatIfInput({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.originalScore,
    required this.newScore,
    required this.originalCwa,
    required this.newCwa,
    required this.targetCwa,
  });
}

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

  Future<String> buildCwaCoachPrompt(String semesterKey) async {
    final base = await buildAcademicContext(semesterKey);
    return '''$base

Task: Give this student 3 specific, actionable recommendations about their CWA situation.
Rules:
- Identify which course has the most credit-hour leverage on their CWA
- State whether the target CWA is achievable given current projections
- Give one concrete study priority for this week
- Do NOT repeat the numbers back — the student can already see them on screen
- Do NOT use bullet points or markdown — write in plain flowing sentences
- Maximum 4 sentences total''';
  }

  Future<String> buildWhatIfPrompt(WhatIfInput input) async {
    return '''${PromptTemplates.basePersona}

The student changed their expected score for ${input.courseName} (${input.creditHours} credit hours) from ${input.originalScore.toInt()} to ${input.newScore.toInt()}.
This changes their projected CWA from ${input.originalCwa.toStringAsFixed(1)} to ${input.newCwa.toStringAsFixed(1)}. Their target is ${input.targetCwa.toStringAsFixed(1)}.

Explain the impact in exactly 1–2 sentences.
Focus on: does this help reach the target? Is this course high or low leverage?
Plain English only. No markdown.''';
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
