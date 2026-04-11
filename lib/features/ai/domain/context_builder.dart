import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/constants/app_constants.dart';
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

  Future<String> buildStudyPlanPrompt() async {
    final semesterKey = AppConstants.defaultSemesterKey;

    // 1. Courses sorted by (creditHours * gap) desc — proxy for CWA leverage
    final allCourses = await _getCourses(semesterKey);
    // We don't have targetCwa here so just sort by creditHours desc as best proxy
    final sortedCourses = [...allCourses]
      ..sort((a, b) => b.creditHours.compareTo(a.creditHours));

    final courseLines = sortedCourses.asMap().entries.map((e) {
      final i = e.key + 1;
      final c = e.value;
      return '$i. ${c.code} — ${c.creditHours.toInt()} credit hours, expected score ${c.expectedScore.toInt()}';
    }).join('\n');

    // 2. Free blocks per day Mon–Sat (KNUST grid)
    final dayNames = TimetableConstants.dayFullLabels; // Mon–Sat
    final freeBlockLines = <String>[];
    for (int i = 0; i < dayNames.length; i++) {
      final slots = await _getSlotsForDay(semesterKey, i);
      final blocks = FreeTimeDetector.detect(dayIndex: i, slots: slots);
      if (blocks.isEmpty) {
        freeBlockLines.add('${dayNames[i]}: (no free blocks)');
      } else {
        final blockStr = blocks.map((b) => '${b.startLabel}–${b.endLabel}').join(', ');
        freeBlockLines.add('${dayNames[i]}: $blockStr');
      }
    }
    // Sunday always free (KNUST day 6 not in grid)
    freeBlockLines.add('Sunday: (no free blocks — rest day)');

    // 3. Past 4 weeks of sessions — extract day/time preferences
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final pastSessions = await sessionRepository.getSessionsForRange(semesterKey, fourWeeksAgo, now);
    final dayCount = <int, int>{};
    for (final s in pastSessions) {
      final d = s.startTime.weekday; // 1=Mon … 7=Sun
      dayCount[d] = (dayCount[d] ?? 0) + 1;
    }
    String patternSummary = 'No past study sessions recorded.';
    if (dayCount.isNotEmpty) {
      final sorted = dayCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final dayNames2 = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final top = sorted.take(3).map((e) => dayNames2[e.key]).join(', ');
      final bottom = sorted.reversed.take(2).map((e) => dayNames2[e.key]).join(', ');
      patternSummary = 'Tends to study: $top\nRarely studies: $bottom';
    }

    return '''You are a study planner. Generate a 7-day study plan for a university student.

Course priority (highest to lowest impact on CWA):
$courseLines

Available free blocks per day (class times are already excluded):
${freeBlockLines.join('\n')}

Student's past study patterns (days/times they actually study):
$patternSummary

Rules:
- Never schedule a study session during a class time
- Prioritize high-credit courses (more impact on CWA)
- Respect past patterns where possible — don't force sessions at times they never study
- Maximum 2 study sessions per day
- Each session: 60–120 minutes
- At least 1 rest day per week
- If a day has no free blocks, mark it as a rest day

Return ONLY a JSON array. No explanation text before or after the JSON.
Each item must have exactly these fields:
{
  "day": "Monday",
  "courseCode": "EE 301",
  "courseName": "Circuit Theory",
  "startTime": "10:00",
  "durationMinutes": 90,
  "reason": "Highest CWA leverage course"
}''';
  }

  Future<List<TimetableSlotModel>> _getSlotsForDay(String semesterKey, int dayIndex) async {
    try {
      return await timetableRepository.getSlotsForDayOnce(semesterKey, dayIndex);
    } catch (_) {
      return [];
    }
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
