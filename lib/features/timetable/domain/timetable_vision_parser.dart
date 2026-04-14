import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';

/// Calls the OpenAI vision API with a timetable image and returns parsed slots.
/// Pure Dart — no Flutter dependencies.
class TimetableVisionParser {
  final String apiKey;
  final String model;

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

  TimetableVisionParser({
    required this.apiKey,
    String? model,
  }) : model = model ?? dotenv.env['OPENAI_VISION_MODEL'] ?? 'gpt-4.1-nano';

  Future<List<TimetableSlotImport>> parse(String imageBase64) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final body = jsonEncode({
      'model': model,
      'max_tokens': 4096,
      'temperature': 0.1,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$imageBase64',
                'detail': 'high',
              },
            },
            {
              'type': 'text',
              'text': _prompt,
            },
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
        'OpenAI Vision error (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choice = data['choices'][0] as Map<String, dynamic>;

    // Detect token-limit truncation before trying to parse
    final finishReason = choice['finish_reason'] as String? ?? '';
    if (finishReason == 'length') {
      throw Exception(
        'Timetable is too large for one scan. '
        'Try cropping the image into two halves and importing each separately.',
      );
    }

    final rawContent = choice['message']['content'] as String;

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
