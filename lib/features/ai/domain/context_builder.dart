import 'dart:convert';
import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';

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

  Future<String> buildStudyPlanPrompt() async {
    final semesterKey = await userPrefsRepository.getActiveSemesterKey();

    // 1. Gather all unique courses from saved courses & timetable slots
    final allCourses = await _getCourses(semesterKey);
    final allSlots = await timetableRepository.getAllSlotsOnce(semesterKey);

    final coursesMap = <String, String?>{};
    final creditsMap = <String, int>{};

    for (final c in allCourses) {
      final code = c.code as String;
      final name = c.name as String;
      coursesMap[code] = name.trim().isEmpty ? null : name.trim();
      creditsMap[code] = c.creditHours.toInt();
    }

    for (final slot in allSlots) {
      final code = slot.courseCode;
      final name = slot.courseName;
      if (!coursesMap.containsKey(code) || coursesMap[code] == null) {
        coursesMap[code] = name.trim().isEmpty ? null : name.trim();
      }
    }

    final allowedCoursesList = <Map<String, dynamic>>[];
    for (final code in coursesMap.keys) {
      allowedCoursesList.add({
        'courseCode': code,
        'courseName': coursesMap[code],
        'credits': creditsMap[code] ?? 3,
      });
    }

    final allowedCoursesJson = const JsonEncoder.withIndent('  ').convert({
      'allowedCourses': allowedCoursesList,
    });

    // 2. Free blocks per day Mon–Sat (KNUST grid)
    const dayNames = TimetableConstants.dayFullLabels; // Mon–Sat
    final freeBlockLines = <String>[];
    for (int i = 0; i < dayNames.length; i++) {
      final slots = await _getSlotsForDay(semesterKey, i);
      final blocks = FreeTimeDetector.detect(dayIndex: i, slots: slots);
      if (blocks.isEmpty) {
        freeBlockLines.add('${dayNames[i]}: (no free blocks)');
      } else {
        final blockStr =
            blocks.map((b) => '${b.startLabel}–${b.endLabel}').join(', ');
        freeBlockLines.add('${dayNames[i]}: $blockStr');
      }
    }
    // 3. Past 4 weeks of sessions — extract day/time preferences
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final pastSessions = await sessionRepository.getSessionsForRange(
        semesterKey, fourWeeksAgo, now);
    final dayCount = <int, int>{};
    for (final s in pastSessions) {
      final d = s.startTime.weekday; // 1=Mon … 7=Sun
      dayCount[d] = (dayCount[d] ?? 0) + 1;
    }
    String patternSummary = 'No past study sessions recorded.';
    if (dayCount.isNotEmpty) {
      final sorted = dayCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final dayNames2 = [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      final top = sorted.take(3).map((e) => dayNames2[e.key]).join(', ');
      final bottom =
          sorted.reversed.take(2).map((e) => dayNames2[e.key]).join(', ');
      patternSummary = 'Tends to study: $top\nRarely studies: $bottom';
    }

    return '''You are a study planner. Generate a 7-day study plan for a university student.

Allowed course data (Use only the exact course codes and course names provided. Do not infer, expand, rename, or guess what a course code means):
$allowedCoursesJson

Available free blocks per day (class times are already excluded):
${freeBlockLines.join('\n')}

Student's past study patterns (days/times they actually study):
$patternSummary

Rules:
- Never schedule a study session during a class time
- Use only the exact course codes and course names provided in 'allowedCourses'. Do not infer, expand, rename, or guess what a course code means.
- If a course has a code but no name (or 'courseName' is null), display/use only the course code as the 'courseName' value. Do not invent any names.
- Never include tasks for courses that are not in the allowed list.
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

  Future<String> buildWeeklyReviewPrompt() async {
    final semesterKey = await userPrefsRepository.getActiveSemesterKey();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Sessions this week
    final sessions = await sessionRepository.getSessionsForRange(
        semesterKey, weekStart, weekEnd);
    final totalMinutes =
        sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final totalHours = totalMinutes / 60.0;

    // Per-course breakdown
    final courseMinutes = <String, int>{};
    final courseNames = <String, String>{};
    for (final s in sessions) {
      courseMinutes[s.courseCode] =
          (courseMinutes[s.courseCode] ?? 0) + s.durationMinutes;
      courseNames[s.courseCode] = s.courseName;
    }
    final courseLines = courseMinutes.entries
        .map((e) => '${e.key} — ${(e.value / 60.0).toStringAsFixed(1)}hr')
        .join(', ');

    // Courses with no study sessions this week
    final allCourses = await _getCourses(semesterKey);
    final studiedCodes = courseMinutes.keys.toSet();
    final neglected = allCourses
        .where((c) => !studiedCodes.contains(c.code))
        .map((c) => c.code)
        .toList();

    // CWA gap proxy — highest credit course with lowest expected score
    String cwaLine = 'No courses added yet';
    if (allCourses.isNotEmpty) {
      final totalCr = allCourses.fold<double>(0, (s, c) => s + c.creditHours);
      final projected = totalCr > 0
          ? allCourses.fold<double>(
                  0, (s, c) => s + c.creditHours * c.expectedScore) /
              totalCr
          : 0.0;
      cwaLine = 'Projected CWA: ${projected.toStringAsFixed(1)}';
    }

    final sessionSummary = sessions.isEmpty
        ? 'No study sessions recorded this week.'
        : 'Total: ${totalHours.toStringAsFixed(1)} hours. By course: $courseLines';
    final neglectedSummary = neglected.isEmpty
        ? 'All courses had at least one study session.'
        : 'Courses with no study sessions: ${neglected.join(', ')}';

    return '''You are an academic coach writing a weekly review for a university student.

This week's data:
- $sessionSummary
- $neglectedSummary
- $cwaLine

Write a weekly review with exactly 4 sections.
Return ONLY a JSON object — no text before or after.
{
  "summary": "2-3 sentence overall summary of the week",
  "well": "1-2 sentences on what went well",
  "watch": "1-2 sentences on one specific risk or gap",
  "focus": "1 sentence with one concrete priority for next week"
}

Tone: warm, honest, encouraging. Not generic. Reference their actual numbers and courses.
Do not use markdown. Plain sentences only.''';
  }

  Future<List<TimetableSlotModel>> _getSlotsForDay(
      String semesterKey, int dayIndex) async {
    try {
      return await timetableRepository.getSlotsForDayOnce(
          semesterKey, dayIndex);
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> _getCourses(String semesterKey) async {
    try {
      // Using Future to match the stream API
      final stream = cwaRepository.watchCourses(semesterKey);
      final courses = await stream.first.timeout(const Duration(seconds: 5));
      return courses;
    } catch (_) {
      return [];
    }
  }
}
