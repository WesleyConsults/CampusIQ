import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:campusiq/core/config/ai_proxy_config.dart';
import 'package:campusiq/features/cwa/domain/registration_course_import.dart';

class RegistrationSlipParseResult {
  final List<RegistrationCourseImport> courses;
  final int skippedCourseCount;

  const RegistrationSlipParseResult({
    required this.courses,
    this.skippedCourseCount = 0,
  });
}

/// Calls the AI vision proxy with an image or PDF registration slip and returns
/// the list of courses extracted from it.
/// Pure Dart — no Flutter dependencies.
class RegistrationSlipParser {
  static const _timeout = Duration(seconds: 90);

  static const _prompt = 'You are a university course registration parser. '
      'Extract every course from this registration slip and return ONLY a JSON array. '
      'Each object must have these exact keys: '
      'course_code (string: the module code, e.g. "CS 101"), '
      'course_name (string: full course title), '
      'credit_hours (number: credit units/hours for the course, e.g. 3). '
      'If credit hours are not visible, default to 3. '
      'Return nothing except the JSON array. No explanation. No markdown. No code fences. '
      'Example: [{"course_code":"CS 101","course_name":"Intro to Computing","credit_hours":3}]';

  const RegistrationSlipParser();

  /// [bytes] — raw file bytes. [mimeType] — "image/jpeg", "image/png", or "application/pdf".
  Future<RegistrationSlipParseResult> parse(
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
        'fileName': 'registration-slip.pdf',
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

      final List<dynamic> jsonList = jsonDecode(cleaned) as List<dynamic>;

      final courses = <RegistrationCourseImport>[];
      var skippedCourseCount = 0;
      for (final item in jsonList) {
        try {
          if (item is! Map) {
            skippedCourseCount++;
            continue;
          }
          final course = RegistrationCourseImport.fromJson(
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
      return RegistrationSlipParseResult(
        courses: courses,
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
