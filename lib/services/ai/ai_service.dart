import 'dart:typed_data';

abstract class AiService {
  /// Test connectivity and key validity
  Future<bool> ping(String apiKey);

  /// Analyze food photo bytes for macronutrient breakdown
  Future<Map<String, dynamic>> analyzeFoodVision(Uint8List imageBytes, {String mimeType = 'image/jpeg'});

  /// Generate dynamic daily schedule from conversational prompt
  Future<List<Map<String, dynamic>>> generateSchedule(String prompt);

  /// Produce comprehensive 7-day retrospective briefing
  Future<String> generateWeeklyRetrospective({
    required List<Map<String, dynamic>> journalEntries,
    required List<Map<String, dynamic>> mealEntries,
    required int totalWaterLiters,
  });
}
