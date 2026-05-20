import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:campusiq/core/config/ai_proxy_config.dart';
import 'deepseek_exception.dart';

class DeepSeekClient {
  static const _timeout = Duration(seconds: 60);

  const DeepSeekClient();

  Future<String> complete({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    int maxTokens = 800,
  }) async {
    final body = jsonEncode({
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'maxTokens': maxTokens,
      'temperature': 0.7,
    });

    try {
      final response = await http
          .post(
            Uri.parse(AiProxyConfig.deepseekEndpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['reply'] as String;
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
        "You're offline. Connect to use features.",
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
