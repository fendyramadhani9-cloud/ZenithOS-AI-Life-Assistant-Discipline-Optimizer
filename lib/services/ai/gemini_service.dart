import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_service.dart';

class GeminiService implements AiService {
  final String apiKey;
  final String modelName;

  GeminiService({
    required this.apiKey,
    this.modelName = 'gemini-1.5-flash',
  });

  GenerativeModel _getModel() {
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey.trim(),
      generationConfig: GenerationConfig(temperature: 0.2),
    );
  }

  @override
  Future<bool> ping(String testKey) async {
    try {
      final model = GenerativeModel(model: modelName, apiKey: testKey.trim());
      final res = await model.generateContent([Content.text('Ping. Respond with "PONG" only.')]);
      return res.text != null && res.text!.isNotEmpty;
    } catch (e) {
      debugPrint('[GeminiService] Ping error: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeFoodVision(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) async {
    final model = _getModel();
    const prompt = '''
You are the ZenithOS Nutrition Architect.
Analyze the meal in this image.
Respond ONLY with a valid JSON object (no markdown backticks, no comments):
{
  "foodName": "Meal name",
  "calories": 450,
  "proteinGrams": 35.0,
  "carbsGrams": 40.0,
  "fatGrams": 12.0,
  "healthScore": 8.5,
  "insights": "High-protein meal optimal for muscle retention during 70kg -> 64kg cut.",
  "items": ["Chicken Breast", "Brown Rice", "Broccoli"]
}
''';

    final response = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart(mimeType, imageBytes)])
    ]);

    final raw = response.text;
    if (raw == null || raw.isEmpty) {
      throw Exception('Empty response from Gemini Vision.');
    }

    final cleaned = _cleanJsonResponse(raw);
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> generateSchedule(String userPrompt) async {
    final model = _getModel();
    final prompt = '''
You are the ZenithOS Discipline Schedule Architect.
User Prompt: "$userPrompt"
Rules:
- Deep work blocks (IaC, coding, architecture).
- Fitness / Gym sessions for 70kg -> 64kg cut.
- Mandatory 22:30 Soft Cut-off (commit code, close laptop).
- Mandatory 23:00 Hard Bedtime (6hr sleep window -> 05:00 wake).
Respond ONLY with a valid JSON array of objects (no markdown, no backticks):
[
  {
    "startTime": "06:00",
    "endTime": "08:00",
    "title": "Morning Routine & IaC Deep Work",
    "category": "work",
    "priority": "high",
    "description": "Terraform and K8s configuration with zero distraction."
  },
  {
    "startTime": "17:30",
    "endTime": "19:00",
    "title": "Gym & Hypertrophy Session",
    "category": "fitness",
    "priority": "high",
    "description": "Weight training + 15 min Zone 2 cardio."
  },
  {
    "startTime": "22:30",
    "endTime": "23:00",
    "title": "Zenith Soft Cut-off",
    "category": "recovery",
    "priority": "urgent",
    "description": "Commit & push branches, close IDE, blue light cutoff."
  },
  {
    "startTime": "23:00",
    "endTime": "05:00",
    "title": "Hard Sleep Window",
    "category": "sleep",
    "priority": "urgent",
    "description": "6 hours cellular recovery."
  }
]
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final raw = response.text;
    if (raw == null || raw.isEmpty) return [];

    final cleaned = _cleanJsonResponse(raw);
    final list = jsonDecode(cleaned) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<String> generateWeeklyRetrospective({
    required List<Map<String, dynamic>> journalEntries,
    required List<Map<String, dynamic>> mealEntries,
    required int totalWaterLiters,
  }) async {
    final model = _getModel();
    final prompt = '''
You are the ZenithOS Executive Performance Coach.
Analyze the user's 7-day data:
- Journal Entries: ${journalEntries.length}
- Notes sample: ${journalEntries.map((e) => e['unfilteredStory'] ?? '').take(5).join(' | ')}
- Logged Meals: ${mealEntries.length}
- Total Hydration: ${totalWaterLiters}L

Produce a 3-paragraph executive review:
Paragraph 1: Executive Summary & Overall Discipline Score (% score).
Paragraph 2: Detailed Wins & Critical Cut-off Compliance (Did they sleep at 23:00 consistently?).
Paragraph 3: Tactical Action Items and Focus Directives for Next Week.

Use cyber-minimalist bullet points without emojis (use [WIN], [GAP], [ACTION]).
''';

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Retrospective briefing generated.';
  }

  static String _cleanJsonResponse(String raw) {
    var text = raw.trim();
    if (text.startsWith('```json')) text = text.substring(7);
    if (text.startsWith('```')) text = text.substring(3);
    if (text.endsWith('```')) text = text.substring(0, text.length - 3);
    return text.trim();
  }
}
