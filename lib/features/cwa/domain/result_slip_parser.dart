import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:campusiq/features/cwa/domain/past_course_result.dart';

class ResultSlipParseResult {
  final List<PastCourseResult> courses;
  final double? reportedSemesterCwa;
  final double? reportedCumulativeCwa;

  /// From the "Credits Calc" cumulative column in the slip summary table.
  final double? cumulativeCreditsCalc;

  /// From the "Weighted Marks" cumulative column in the slip summary table.
  final double? cumulativeWeightedMarks;

  const ResultSlipParseResult({
    required this.courses,
    this.reportedSemesterCwa,
    this.reportedCumulativeCwa,
    this.cumulativeCreditsCalc,
    this.cumulativeWeightedMarks,
  });
}

/// Calls the OpenAI vision API with an image or PDF result slip and returns
/// the list of courses with exact marks/grades and reported CWAs.
/// Pure Dart — no Flutter dependencies.
class ResultSlipParser {
  final String apiKey;
  final String model;

  static const _timeout = Duration(seconds: 90);

  static const _prompt =
      'You are a KNUST result slip data extractor. Read every number exactly as printed — do NOT estimate or infer. '
      'Extract the following from the slip:\n\n'
      '1. COURSE TABLE — every row in the course table:\n'
      '   - course_code: module code (e.g. "COE 261")\n'
      '   - course_name: full title\n'
      '   - credit_hours: number from CREDITS column (default 3 only if column is missing)\n'
      '   - mark: integer/decimal from MARKS column — MUST be copied exactly. null ONLY if no MARKS column exists.\n'
      '   - grade: letter from GRADE column (use F for any failing grade)\n\n'
      '2. SUMMARY TABLE (the Semester / Cumulative box at the bottom):\n'
      '   - semester_cwa: the Weighted Average from the SEMESTER column\n'
      '   - cumulative_cwa: the Weighted Average from the CUMULATIVE column\n'
      '   - cumulative_credits_calc: the Credits Calc value from the CUMULATIVE column\n'
      '   - cumulative_weighted_marks: the Weighted Marks value from the CUMULATIVE column\n\n'
      'Return ONLY a JSON object with these exact top-level keys:\n'
      '"courses", "semester_cwa", "cumulative_cwa", "cumulative_credits_calc", "cumulative_weighted_marks".\n'
      'All five keys must be present. Use null for any value not visible on the slip.\n'
      'Return nothing except the JSON. No explanation. No markdown. No code fences.\n\n'
      'Example for a slip showing Weighted Marks 8655 and Credits Calc 173 in the cumulative column:\n'
      '{"semester_cwa":65.05,"cumulative_cwa":50.03,"cumulative_credits_calc":173,"cumulative_weighted_marks":8655,'
      '"courses":['
      '{"course_code":"COE 454","course_name":"SOFTWARE ENGINEERING","credit_hours":3,"mark":79,"grade":"A"},'
      '{"course_code":"COE 480","course_name":"FAULT DIAGNOSIS AND FAILURE TOLERANCE","credit_hours":3,"mark":40,"grade":"D"}'
      ']}';

  const ResultSlipParser({required this.apiKey, required this.model});

  /// [bytes] — raw file bytes. [mimeType] — "image/jpeg", "image/png", or "application/pdf".
  Future<ResultSlipParseResult> parse(
    Uint8List bytes,
    String mimeType,
  ) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final base64Data = base64Encode(bytes);

    final Map<String, dynamic> fileBlock;
    if (mimeType == 'application/pdf') {
      fileBlock = {
        'type': 'file',
        'file': {
          'filename': 'result_slip.pdf',
          'file_data': 'data:application/pdf;base64,$base64Data',
        },
      };
    } else {
      fileBlock = {
        'type': 'image_url',
        'image_url': {
          'url': 'data:$mimeType;base64,$base64Data',
          'detail': 'high',
        },
      };
    }

    final body = jsonEncode({
      'model': model,
      'max_tokens': 2048,
      'temperature': 0.1,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _prompt},
            fileBlock,
          ],
        },
      ],
    });

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'OpenAI error (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choice = data['choices'][0] as Map<String, dynamic>;

    if ((choice['finish_reason'] as String? ?? '') == 'length') {
      throw Exception(
        'Slip has too many courses for one scan. '
        'Try importing in two halves.',
      );
    }

    final rawContent = choice['message']['content'] as String;
    final cleaned = rawContent
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final Map<String, dynamic> parsedObj = jsonDecode(cleaned) as Map<String, dynamic>;
    final List<dynamic> jsonList = (parsedObj['courses'] as List<dynamic>?) ?? [];

    final courses = <PastCourseResult>[];
    for (final item in jsonList) {
      try {
        courses.add(
          PastCourseResult.fromJson(item as Map<String, dynamic>),
        );
      } catch (_) {
        // Skip malformed entries.
      }
    }
    
    return ResultSlipParseResult(
      courses: courses,
      reportedSemesterCwa: (parsedObj['semester_cwa'] as num?)?.toDouble(),
      reportedCumulativeCwa: (parsedObj['cumulative_cwa'] as num?)?.toDouble(),
      cumulativeCreditsCalc: (parsedObj['cumulative_credits_calc'] as num?)?.toDouble(),
      cumulativeWeightedMarks: (parsedObj['cumulative_weighted_marks'] as num?)?.toDouble(),
    );
  }
}
