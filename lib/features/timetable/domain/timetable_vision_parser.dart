import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campusiq/features/ai/domain/deepseek_exception.dart';
import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';

/// Calls the DeepSeek vision API with a timetable image and returns parsed slots.
/// Pure Dart — no Flutter dependencies.
class TimetableVisionParser {
  final String apiKey;

  static const _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const _model = 'deepseek-vl2';
  static const _timeout = Duration(seconds: 60);

  static const _prompt =
      'You are a university timetable parser. '
      'Extract every class slot from the timetable image and return ONLY a JSON array. '
      'Each object must have these exact keys: '
      'day (string: "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"), '
      'course_code (string: the module code, e.g. "CS 101"), '
      'course_name (string: full course name), '
      'venue (string: room or hall, empty string if not visible), '
      'start_time (string: 24-hour "HH:MM"), '
      'end_time (string: 24-hour "HH:MM"), '
      'slot_type (string: one of "Lecture","Practical","Tutorial"). '
      'Return nothing except the JSON array. No explanation. No markdown. No code fences. '
      'Example: [{"day":"Monday","course_code":"CS 101","course_name":"Intro to Computing",'
      '"venue":"LT1","start_time":"08:00","end_time":"10:00","slot_type":"Lecture"}]';

  const TimetableVisionParser({required this.apiKey});

  Future<List<TimetableSlotImport>> parse(String imageBase64) async {
    final body = jsonEncode({
      'model': _model,
      'max_tokens': 2000,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'},
            },
            {'type': 'text', 'text': _prompt},
          ],
        },
      ],
    });

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw DeepSeekException(
        'Vision API error (${response.statusCode}): ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawContent =
        data['choices'][0]['message']['content'] as String;

    // Strip markdown code fences if the model added them
    final cleaned = rawContent
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final List<dynamic> jsonList = jsonDecode(cleaned) as List<dynamic>;

    final slots = <TimetableSlotImport>[];
    for (final item in jsonList) {
      try {
        slots.add(TimetableSlotImport.fromJson(item as Map<String, dynamic>));
      } catch (_) {
        // Skip malformed individual slots; import the rest
      }
    }
    return slots;
  }
}
