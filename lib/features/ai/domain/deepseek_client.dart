import 'dart:convert';
import 'package:http/http.dart' as http;
import 'deepseek_exception.dart';

class DeepSeekClient {
  final String apiKey;
  static const _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const _timeout = Duration(seconds: 30);

  const DeepSeekClient({required this.apiKey});

  Future<String> complete({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    String model = 'deepseek-chat',
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
        'API error: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}
