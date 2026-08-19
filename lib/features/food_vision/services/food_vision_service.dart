import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../../../core/network_queue/emergency_nutrition_dictionary.dart';
import '../../../core/storage/storage_service.dart';
import '../../../services/ai/ai_factory.dart';
import '../models/meal_nutrition_entry.dart';

class FoodVisionService {
  /// Pick plate image file (Web / Android compatible)
  Future<Uint8List?> pickMealImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files.first.bytes;
    }
    return null;
  }

  /// Analyze image bytes with AI Multimodal Vision (Gemini/OpenAI with failover and offline dictionary fallback)
  Future<MealNutritionEntry?> scanPlate(Uint8List imageBytes) async {
    try {
      final json = await AiFactory.executeWithFailover(
        (service) => service.analyzeFoodVision(imageBytes),
      );
      final entry = MealNutritionEntry.fromMap(json);
      await StorageService.instance.saveMealEntry(entry.toMap());
      return entry;
    } catch (e) {
      // Fallback to Emergency Nutrition Baseline when offline
      final fallback = EmergencyNutritionDictionary.fallbackEstimate('Protein Bowl');
      final entry = MealNutritionEntry.fromMap(fallback);
      await StorageService.instance.saveMealEntry(entry.toMap());
      return entry;
    }
  }

  /// Add quick manual meal log
  Future<MealNutritionEntry> logQuickMeal({
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final entry = MealNutritionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: name,
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      insights: 'Manual entry logged.',
    );
    await StorageService.instance.saveMealEntry(entry.toMap());
    return entry;
  }

  List<MealNutritionEntry> getTodayMeals() {
    final now = DateTime.now();
    final all = StorageService.instance.getAllMealEntries();
    return all
        .map((e) => MealNutritionEntry.fromMap(e))
        .where((e) =>
            e.timestamp.year == now.year &&
            e.timestamp.month == now.month &&
            e.timestamp.day == now.day)
        .toList();
  }

  int getTodayTotalCalories() {
    return getTodayMeals().fold(0, (sum, item) => sum + item.calories);
  }

  double getTodayTotalProtein() {
    return getTodayMeals().fold(0.0, (sum, item) => sum + item.proteinGrams);
  }
}
