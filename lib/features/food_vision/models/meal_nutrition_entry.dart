class MealNutritionEntry {
  final String id;
  final String foodName;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double healthScore;
  final String insights;
  final List<String> items;
  final DateTime timestamp;

  MealNutritionEntry({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.healthScore = 8.0,
    this.insights = '',
    this.items = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'healthScore': healthScore,
      'insights': insights,
      'items': items,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MealNutritionEntry.fromMap(Map<String, dynamic> map) {
    return MealNutritionEntry(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: map['foodName'] ?? 'Logged Meal',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (map['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (map['fatGrams'] as num?)?.toDouble() ?? 0.0,
      healthScore: (map['healthScore'] as num?)?.toDouble() ?? 8.0,
      insights: map['insights'] ?? '',
      items: (map['items'] as List?)?.map((e) => e.toString()).toList() ?? [],
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
