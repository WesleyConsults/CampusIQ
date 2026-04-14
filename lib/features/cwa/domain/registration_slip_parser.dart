import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:campusiq/features/cwa/domain/registration_course_import.dart';

/// Calls the OpenAI API with an image or PDF registration slip and returns
/// the list of courses extracted from it.
/// Pure Dart — no Flutter dependencies.
class RegistrationSlipParser {
  final String apiKey;
  final String model;

  static const _timeout = Duration(seconds: 90);

  static const _prompt =
      'You are a university course registration parser. '
      'Extract every course from this registration slip and return ONLY a JSON array. '
      'Each object must have these exact keys: '
      'course_code (string: the module code, e.g. "CS 101"), '
      'course_name (string: full course title), '
      'credit_hours (number: credit units/hours for the course, e.g. 3). '
      'If credit hours are not visible, default to 3. '
      'Return nothing except the JSON array. No explanation. No markdown. No code fences. '
      'Example: [{"course_code":"CS 101","course_name":"Intro to Computing","credit_hours":3}]';

  const RegistrationSlipParser({required this.apiKey, required this.model});

  /// [bytes] — raw file bytes. [mimeType] — "image/jpeg", "image/png", or "application/pdf".
  Future<List<RegistrationCourseImport>> parse(
    Uint8List bytes,
    String mimeType,
  ) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final base64Data = base64Encode(bytes);

    // Build the file/image content block based on MIME type.
    final Map<String, dynamic> fileBlock;
    if (mimeType == 'application/pdf') {
      fileBlock = {
        'type': 'file',
        'file': {
          'filename': 'registration_slip.pdf',
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

    final List<dynamic> jsonList = jsonDecode(cleaned) as List<dynamic>;

    final courses = <RegistrationCourseImport>[];
    for (final item in jsonList) {
      try {
        courses.add(
          RegistrationCourseImport.fromJson(item as Map<String, dynamic>),
        );
      } catch (_) {
        // Skip malformed entries.
      }
    }
    return courses;
  }
}
