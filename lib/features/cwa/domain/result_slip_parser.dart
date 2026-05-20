import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:campusiq/core/config/ai_proxy_config.dart';
import 'package:campusiq/features/cwa/domain/past_course_result.dart';

class ResultSlipParseResult {
  final List<PastCourseResult> courses;
  final double? reportedSemesterCwa;
  final double? reportedCumulativeCwa;

  /// From the "Credits Calc" cumulative column in the slip summary table.
  final double? cumulativeCreditsCalc;

  /// From the "Weighted Marks" cumulative column in the slip summary table.
  final double? cumulativeWeightedMarks;

  /// Start year parsed from the slip header, e.g. 2024 for "2024/2025".
  final int? academicYearStart;

  /// 1 or 2, parsed from the slip header.
  final int? semesterNumber;

  /// e.g. 300, parsed from the slip header.
  final int? level;

  /// e.g. "Computer Engineering", parsed from the slip header.
  final String? programme;

  final int skippedCourseCount;

  const ResultSlipParseResult({
    required this.courses,
    this.reportedSemesterCwa,
    this.reportedCumulativeCwa,
    this.cumulativeCreditsCalc,
    this.cumulativeWeightedMarks,
    this.academicYearStart,
    this.semesterNumber,
    this.level,
    this.programme,
    this.skippedCourseCount = 0,
  });
}

/// Calls the AI vision proxy with an image or PDF result slip and returns
/// the list of courses with exact marks/grades and reported CWAs.
/// Pure Dart — no Flutter dependencies.
class ResultSlipParser {
  static const _timeout = Duration(seconds: 90);

  static const _prompt =
      'You are a KNUST result slip data extractor. Read every number exactly as printed — do NOT estimate or infer. '
      'Extract the following from the slip:\n\n'
      '1. HEADER METADATA — look near the top of the slip for:\n'
      '   - academic_year_start: the starting year of the academic year (e.g. 2024 for "2024/2025 Academic Year").'
      ' null if not visible.\n'
      '   - semester_number: 1 for "First Semester", 2 for "Second Semester". null if not visible.\n'
      '   - level: the student level number only (e.g. 300 for "Level 300", "L300", or "300"). null if not visible.\n'
      '   - programme: the programme name (e.g. "Computer Engineering", "BSc Computer Science"). null if not visible.\n\n'
      '2. COURSE TABLE — every row in the course table:\n'
      '   - course_code: module code (e.g. "COE 261")\n'
      '   - course_name: full title\n'
      '   - credit_hours: number from CREDITS column (default 3 only if column is missing)\n'
      '   - mark: integer/decimal from MARKS column — MUST be copied exactly. null ONLY if no MARKS column exists.\n'
      '   - grade: letter from GRADE column (use F for any failing grade)\n\n'
      '3. SUMMARY TABLE (the Semester / Cumulative box at the bottom):\n'
      '   - semester_cwa: the Weighted Average from the SEMESTER column\n'
      '   - cumulative_cwa: the Weighted Average from the CUMULATIVE column\n'
      '   - cumulative_credits_calc: the Credits Calc value from the CUMULATIVE column\n'
      '   - cumulative_weighted_marks: the Weighted Marks value from the CUMULATIVE column\n\n'
      'Return ONLY a JSON object with these exact top-level keys:\n'
      '"academic_year_start", "semester_number", "level", "programme", '
      '"courses", "semester_cwa", "cumulative_cwa", "cumulative_credits_calc", "cumulative_weighted_marks".\n'
      'All keys must be present. Use null for any value not visible on the slip.\n'
      'Return nothing except the JSON. No explanation. No markdown. No code fences.\n\n'
      'Example:\n'
      '{"academic_year_start":2024,"semester_number":2,"level":300,"programme":"Computer Engineering",'
      '"semester_cwa":65.05,"cumulative_cwa":50.03,"cumulative_credits_calc":173,"cumulative_weighted_marks":8655,'
      '"courses":['
      '{"course_code":"COE 454","course_name":"SOFTWARE ENGINEERING","credit_hours":3,"mark":79,"grade":"A"},'
      '{"course_code":"COE 480","course_name":"FAULT DIAGNOSIS AND FAILURE TOLERANCE","credit_hours":3,"mark":40,"grade":"D"}'
      ']}';

  const ResultSlipParser();

  /// [bytes] — raw file bytes. [mimeType] — "image/jpeg", "image/png", or "application/pdf".
  Future<ResultSlipParseResult> parse(
    Uint8List bytes,
    String mimeType,
  ) async {
    final base64Data = base64Encode(bytes);

    final requestBody = <String, dynamic>{
      'prompt': _prompt,
      'maxTokens': 2048,
      'temperature': 0.1,
    };
    if (mimeType == 'application/pdf') {
      requestBody.addAll({
        'base64File': 'data:application/pdf;base64,$base64Data',
        'fileName': 'result-slip.pdf',
      });
    } else {
      requestBody['base64Image'] = 'data:$mimeType;base64,$base64Data';
    }

    final body = jsonEncode(requestBody);

    try {
      final response = await http
          .post(
            Uri.parse(AiProxyConfig.openaiVisionEndpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception(
          'Vision service returned an error (${response.statusCode}). Try again later.',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if ((data['finishReason'] as String? ?? '') == 'length') {
        throw Exception(
          'Slip has too many courses for one scan. '
          'Try importing in two halves.',
        );
      }

      final rawContent = data['reply'] as String;
      final cleaned = rawContent
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final Map<String, dynamic> parsedObj =
          jsonDecode(cleaned) as Map<String, dynamic>;
      final List<dynamic> jsonList =
          (parsedObj['courses'] as List<dynamic>?) ?? [];

      final courses = <PastCourseResult>[];
      var skippedCourseCount = 0;
      for (final item in jsonList) {
        try {
          if (item is! Map) {
            skippedCourseCount++;
            continue;
          }
          final course = PastCourseResult.fromJson(
            Map<String, dynamic>.from(item),
          );
          if (course.courseCode.trim().isEmpty ||
              course.courseName.trim().isEmpty) {
            skippedCourseCount++;
            continue;
          }
          courses.add(course);
        } catch (_) {
          skippedCourseCount++;
        }
      }

      return ResultSlipParseResult(
        courses: courses,
        reportedSemesterCwa: (parsedObj['semester_cwa'] as num?)?.toDouble(),
        reportedCumulativeCwa:
            (parsedObj['cumulative_cwa'] as num?)?.toDouble(),
        cumulativeCreditsCalc:
            (parsedObj['cumulative_credits_calc'] as num?)?.toDouble(),
        cumulativeWeightedMarks:
            (parsedObj['cumulative_weighted_marks'] as num?)?.toDouble(),
        academicYearStart: (parsedObj['academic_year_start'] as num?)?.toInt(),
        semesterNumber: (parsedObj['semester_number'] as num?)?.toInt(),
        level: (parsedObj['level'] as num?)?.toInt(),
        programme: parsedObj['programme'] as String?,
        skippedCourseCount: skippedCourseCount,
      );
    } on TimeoutException {
      throw Exception(
        'Request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw Exception(
        "You're offline. Connect to use features.",
      );
    } on FormatException {
      throw Exception(
        'Received an unexpected response. Please try again.',
      );
    }
  }
}
