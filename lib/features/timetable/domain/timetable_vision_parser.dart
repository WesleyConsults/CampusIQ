import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:campusiq/core/config/ai_proxy_config.dart';
import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';

/// Calls the AI vision proxy with a timetable image and returns parsed slots.
/// Pure Dart — no Flutter dependencies.
class TimetableVisionParser {
  static const _timeout = Duration(seconds: 90);

  static const _prompt = 'You are a university timetable parser. '
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

  const TimetableVisionParser();

  Future<List<TimetableSlotImport>> parse(String imageBase64) async {
    final body = jsonEncode({
      'prompt': _prompt,
      'base64Image': 'data:image/jpeg;base64,$imageBase64',
      'maxTokens': 4096,
      'temperature': 0.1,
    });

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

      // Detect token-limit truncation before trying to parse
      final finishReason = data['finishReason'] as String? ?? '';
      if (finishReason == 'length') {
        throw Exception(
          'Timetable is too large for one scan. '
          'Try cropping the image into two halves and importing each separately.',
        );
      }

      final rawContent = data['reply'] as String;

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
