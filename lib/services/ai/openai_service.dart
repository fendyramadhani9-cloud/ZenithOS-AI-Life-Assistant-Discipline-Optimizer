import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'ai_service.dart';

class OpenAiService implements AiService {
  final String apiKey;
  final String model;

  OpenAiService({
    required this.apiKey,
    this.model = 'gpt-4o-mini',
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey.trim()}',
      };

  @override
  Future<bool> ping(String testKey) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${testKey.trim()}',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': 'Ping. Reply PONG.'}
          ],
          'max_tokens': 5,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[OpenAiService] Ping error: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeFoodVision(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) async {
    final base64Image = base64Encode(imageBytes);
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content': 'You are a sports nutritionist. Return JSON only with fields: foodName, calories (int), proteinGrams (num), carbsGrams (num), fatGrams (num), healthScore (num), insights (str), items (array of str).'
          },
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'Analyze this meal for 70kg -> 64kg cut.'},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:$mimeType;base64,$base64Image'}
              }
            ]
          }
        ],
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return jsonDecode(content) as Map<String, dynamic>;
    } else {
      throw Exception('OpenAI Error ${response.statusCode}: ${response.body}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateSchedule(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are ZenithOS Schedule Architect. Return a JSON array of objects with startTime, endTime, title, category, priority, description. Include mandatory 22:30 Soft Cutoff and 23:00 Hard Sleep.'
          },
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      final clean = _cleanJsonResponse(content);
      final list = jsonDecode(clean) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      throw Exception('OpenAI Error ${response.statusCode}: ${response.body}');
    }
  }

  @override
  Future<String> generateWeeklyRetrospective({
    required List<Map<String, dynamic>> journalEntries,
    required List<Map<String, dynamic>> mealEntries,
    required int totalWaterLiters,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are ZenithOS Executive Performance Coach. Provide a 3-paragraph weekly discipline briefing with [WIN], [GAP], [ACTION]. No keyboard emojis.'
          },
          {
            'role': 'user',
            'content': '7-day logs: Journal count ${journalEntries.length}, Meals count ${mealEntries.length}, Hydration ${totalWaterLiters}L.'
          }
        ],
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI Error ${response.statusCode}');
    }
  }

  static String _cleanJsonResponse(String raw) {
    var text = raw.trim();
    if (text.startsWith('```json')) text = text.substring(7);
    if (text.startsWith('```')) text = text.substring(3);
    if (text.endsWith('```')) text = text.substring(0, text.length - 3);
    return text.trim();
  }
}
