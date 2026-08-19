import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../storage/storage_service.dart';

class GeminiClient {
  static const String defaultModel = 'gemini-1.5-flash';

  static Future<GenerativeModel?> getModel({String modelName = defaultModel}) async {
    final apiKey = await StorageService.instance.getApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      return null;
    }
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey.trim(),
      generationConfig: GenerationConfig(
        temperature: 0.2,
      ),
    );
  }

  /// Ping test with API key to verify validity
  static Future<bool> testApiKey(String apiKey) async {
    try {
      final model = GenerativeModel(
        model: defaultModel,
        apiKey: apiKey.trim(),
      );
      final response = await model.generateContent([
        Content.text('Ping. Respond with "PONG" only.'),
      ]);
      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      debugPrint('[GeminiClient] API Key verification failed: $e');
      return false;
    }
  }

  /// Analyze food plate image bytes to return macro nutritional breakdown in JSON format
  static Future<Map<String, dynamic>?> analyzeFoodImage(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) async {
    final model = await getModel();
    if (model == null) {
      throw Exception('Gemini API Key is not configured. Please add it in Onboarding/Settings.');
    }

    const prompt = '''
You are an expert sports nutritionist and food vision AI.
Analyze the meal shown in this image.
Respond ONLY with a valid JSON object (no markdown quotes, no backticks, no extra text):
{
  "foodName": "Descriptive meal name",
  "calories": 450,
  "proteinGrams": 35.0,
  "carbsGrams": 40.0,
  "fatGrams": 12.0,
  "healthScore": 8.5,
  "insights": "High protein meal optimal for recovery and lean muscle preservation during calorie deficit.",
  "items": ["Grilled Chicken Breast 150g", "Brown Rice 100g", "Steamed Broccoli"]
}
''';

    final promptPart = TextPart(prompt);
    final imagePart = DataPart(mimeType, imageBytes);

    final response = await model.generateContent([
      Content.multi([promptPart, imagePart])
    ]);

    final raw = response.text;
    if (raw == null || raw.isEmpty) return null;

    final cleaned = _cleanJsonResponse(raw);
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }

  /// Generate optimized daily schedule from user prompt
  static Future<List<Map<String, dynamic>>> generateSchedule(String userPrompt) async {
    final model = await getModel();
    if (model == null) {
      throw Exception('Gemini API Key is not configured.');
    }

    final prompt = '''
You are ZenithOS Schedule Architect, optimizing daily discipline, deep work, gym, and strict 23:00 sleep cutoff.
User Request/Context: "$userPrompt"

Requirements:
- Plan from morning (e.g., 05:30/06:00) until mandatory 22:30 wrap-up and 23:00 hard bedtime.
- Include deep work blocks (e.g. IaC, coding, architecture), gym/workout, healthy meals, and cutoff reminders.
- Respond ONLY with a valid JSON array of timeline blocks (no markdown backticks, no extra commentary):
[
  {
    "startTime": "06:00",
    "endTime": "07:30",
    "title": "Morning Routine & IaC Deep Work",
    "category": "work",
    "priority": "high",
    "description": "Terraform / Kubernetes infrastructure review with zero distraction."
  },
  {
    "startTime": "17:30",
    "endTime": "19:00",
    "title": "Gym & Strength Training",
    "category": "fitness",
    "priority": "high",
    "description": "Push workout + 15 min zone-2 cardio for 70kg -> 64kg cut."
  },
  {
    "startTime": "22:30",
    "endTime": "23:00",
    "title": "Zenith Soft Cutoff",
    "category": "recovery",
    "priority": "urgent",
    "description": "Commit & push git branches, close IDE, shutdown screens."
  },
  {
    "startTime": "23:00",
    "endTime": "05:00",
    "title": "Hard Sleep Window",
    "category": "sleep",
    "priority": "urgent",
    "description": "6 hours strict sleep recovery."
  }
]
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final raw = response.text;
    if (raw == null || raw.isEmpty) return [];

    final cleaned = _cleanJsonResponse(raw);
    final parsed = jsonDecode(cleaned) as List;
    return parsed.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Weekly Retrospective Briefing generator
  static Future<String> generateWeeklyRetrospective({
    required List<Map<String, dynamic>> journalEntries,
    required List<Map<String, dynamic>> mealEntries,
    required int totalWaterLiters,
  }) async {
    final model = await getModel();
    if (model == null) {
      return "AI Key is required for generating weekly retrospective briefing.";
    }

    final prompt = '''
You are the ZenithOS Executive Performance Coach.
Analyze the following user data for the past 7 days:
- Journal Entries count: ${journalEntries.length}
- Unfiltered notes preview: ${journalEntries.map((e) => e['unfilteredStory'] ?? '').take(5).join(' | ')}
- Logged Meals count: ${mealEntries.length}
- Total Hydration: ${totalWaterLiters}L

Target Goal: Weight cut from 70kg to 64kg with high discipline and strict 23:00 sleep cutoff.

Produce a crisp, executive, cyber-minimalist weekly briefing with:
1. Executive Summary & Discipline Score (out of 100%)
2. Key Wins (IaC/Work, Workout consistency, Nutrition)
3. Critical Gaps & Cut-off Compliance (Did they sleep at 23:00?)
4. 3 Tactical Action Items for Next Week.

Format with clear headers and bullet points. (Do NOT use keyboard emojis, use clean symbols like [W], [!], [-]).
''';

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Unable to generate retrospective briefing.';
  }

  static String _cleanJsonResponse(String raw) {
    var text = raw.trim();
    if (text.startsWith('```json')) {
      text = text.substring(7);
    } else if (text.startsWith('```')) {
      text = text.substring(3);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3);
    }
    return text.trim();
  }
}
