import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'deepseek_exception.dart';

class DeepSeekClient {
  final String apiKey;
  final String model;
  static const _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const _timeout = Duration(seconds: 10);

  const DeepSeekClient({required this.apiKey, required this.model});

  Future<String> complete({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    int maxTokens = 800,
  }) async {
    final body = jsonEncode({
      'model': model,
      'max_tokens': maxTokens,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
    });

    try {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        throw DeepSeekException(
          'AI service returned an error (${response.statusCode}). Try again later.',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw const DeepSeekException(
        'Request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw const DeepSeekException(
        'No internet connection. AI features require a connection.',
      );
    } on FormatException {
      throw const DeepSeekException(
        'Received an unexpected response. Please try again.',
      );
    } on DeepSeekException {
      rethrow;
    } catch (e) {
      throw DeepSeekException('Request failed: $e');
    }
  }
}
