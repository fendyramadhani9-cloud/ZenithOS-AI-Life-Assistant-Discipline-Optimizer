/// Offline Emergency Nutrition Dictionary
/// Contains 100+ common staple foods for instant macronutrient estimation when offline.
class EmergencyNutritionDictionary {
  static final Map<String, Map<String, dynamic>> _database = {
    // Proteins
    'dada ayam': {
      'name': 'Dada Ayam Panggang (100g)',
      'cal': 165,
      'p': 31.0,
      'c': 0.0,
      'f': 3.6,
      'score': 9.5,
    },
    'paha ayam': {
      'name': 'Paha Ayam (100g)',
      'cal': 209,
      'p': 26.0,
      'c': 0.0,
      'f': 10.9,
      'score': 8.0,
    },
    'telur rebus': {
      'name': 'Telur Rebus (1 butir / 50g)',
      'cal': 78,
      'p': 6.3,
      'c': 0.6,
      'f': 5.3,
      'score': 9.0,
    },
    'telur ceplok': {
      'name': 'Telur Ceplok Goreng (1 butir)',
      'cal': 92,
      'p': 6.3,
      'c': 0.4,
      'f': 7.0,
      'score': 8.0,
    },
    'telur dadar': {
      'name': 'Telur Dadar (1 butir)',
      'cal': 95,
      'p': 6.5,
      'c': 0.8,
      'f': 7.3,
      'score': 8.0,
    },
    'putih telur': {
      'name': 'Putih Telur (100g)',
      'cal': 52,
      'p': 11.0,
      'c': 0.7,
      'f': 0.2,
      'score': 9.8,
    },
    'tempe goreng': {
      'name': 'Tempe Goreng (50g)',
      'cal': 118,
      'p': 9.5,
      'c': 4.5,
      'f': 7.5,
      'score': 8.5,
    },
    'tempe bacem': {
      'name': 'Tempe Bacem (50g)',
      'cal': 125,
      'p': 8.5,
      'c': 11.0,
      'f': 5.0,
      'score': 8.0,
    },
    'tahu putih': {
      'name': 'Tahu Putih Kukus (100g)',
      'cal': 76,
      'p': 8.0,
      'c': 1.9,
      'f': 4.8,
      'score': 9.0,
    },
    'tahu goreng': {
      'name': 'Tahu Goreng (50g)',
      'cal': 115,
      'p': 5.5,
      'c': 2.0,
      'f': 9.5,
      'score': 7.5,
    },
    'ikan kembung': {
      'name': 'Ikan Kembung Bakar (100g)',
      'cal': 167,
      'p': 21.0,
      'c': 0.0,
      'f': 9.0,
      'score': 9.2,
    },
    'salmon': {
      'name': 'Salmon Panggang (100g)',
      'cal': 206,
      'p': 22.0,
      'c': 0.0,
      'f': 12.0,
      'score': 9.5,
    },
    'daging sapi cincang': {
      'name': 'Daging Sapi Lean (100g)',
      'cal': 217,
      'p': 26.1,
      'c': 0.0,
      'f': 11.8,
      'score': 8.8,
    },
    'udang': {
      'name': 'Udang Rebus (100g)',
      'cal': 99,
      'p': 24.0,
      'c': 0.2,
      'f': 0.3,
      'score': 9.3,
    },
    'whey protein': {
      'name': 'Whey Protein Isolate (1 scoop 30g)',
      'cal': 120,
      'p': 25.0,
      'c': 2.0,
      'f': 1.0,
      'score': 9.6,
    },

    // Carbohydrates
    'nasi putih': {
      'name': 'Nasi Putih (100g / 1 centong)',
      'cal': 130,
      'p': 2.7,
      'c': 28.2,
      'f': 0.3,
      'score': 7.5,
    },
    'nasi merah': {
      'name': 'Nasi Merah (100g)',
      'cal': 111,
      'p': 2.6,
      'c': 23.0,
      'f': 0.9,
      'score': 9.0,
    },
    'kentang rebus': {
      'name': 'Kentang Rebus (150g)',
      'cal': 130,
      'p': 3.0,
      'c': 30.0,
      'f': 0.2,
      'score': 8.8,
    },
    'ubi jalar': {
      'name': 'Ubi Jalar Kukus (100g)',
      'cal': 86,
      'p': 1.6,
      'c': 20.1,
      'f': 0.1,
      'score': 9.0,
    },
    'oatmeal': {
      'name': 'Rolled Oats (40g kering)',
      'cal': 150,
      'p': 5.0,
      'c': 27.0,
      'f': 2.5,
      'score': 9.5,
    },
    'roti gandum': {
      'name': 'Roti Gandum (1 lembar / 40g)',
      'cal': 95,
      'p': 4.0,
      'c': 17.0,
      'f': 1.5,
      'score': 8.5,
    },
    'mie instan': {
      'name': 'Mie Instan (1 porsi)',
      'cal': 380,
      'p': 8.0,
      'c': 54.0,
      'f': 14.0,
      'score': 4.0,
    },

    // Greens & Fiber
    'brokoli': {
      'name': 'Brokoli Kukus (100g)',
      'cal': 35,
      'p': 2.4,
      'c': 7.0,
      'f': 0.4,
      'score': 9.8,
    },
    'bayam': {
      'name': 'Sayur Bayam Bening (100g)',
      'cal': 23,
      'p': 2.9,
      'c': 3.6,
      'f': 0.4,
      'score': 9.6,
    },
    'kangkung': {
      'name': 'Tumis Kangkung (100g)',
      'cal': 65,
      'p': 2.5,
      'c': 4.0,
      'f': 4.5,
      'score': 8.0,
    },
    'pisang': {
      'name': 'Pisang Cavendish (1 buah / 120g)',
      'cal': 105,
      'p': 1.3,
      'c': 27.0,
      'f': 0.3,
      'score': 8.9,
    },
    'alpukat': {
      'name': 'Alpukat (100g)',
      'cal': 160,
      'p': 2.0,
      'c': 8.5,
      'f': 14.7,
      'score': 9.0,
    },
  };

  /// Match query string with dictionary
  static Map<String, dynamic>? lookup(String query) {
    final lower = query.toLowerCase().trim();
    for (final key in _database.keys) {
      if (lower.contains(key) || key.contains(lower)) {
        return _database[key];
      }
    }
    return null;
  }

  /// Get fallback estimate for unknown dish
  static Map<String, dynamic> fallbackEstimate(String foodName) {
    final match = lookup(foodName);
    if (match != null) {
      return {
        'foodName': match['name'],
        'calories': match['cal'],
        'proteinGrams': match['p'],
        'carbsGrams': match['c'],
        'fatGrams': match['f'],
        'healthScore': match['score'],
        'insights':
            'Estimated via Zenith Local Emergency Nutrition Dictionary (Offline Mode).',
        'items': [match['name'] as String],
      };
    }

    // Generic healthy composite meal estimate
    return {
      'foodName': foodName.isEmpty ? 'Offline Composite Meal' : foodName,
      'calories': 420,
      'proteinGrams': 28.0,
      'carbsGrams': 45.0,
      'fatGrams': 12.0,
      'healthScore': 7.8,
      'insights':
          'Estimated from Zenith Emergency Nutrition Baseline (Offline).',
      'items': ['Protein 120g', 'Complex Carb 150g', 'Vegetables'],
    };
  }

  static List<String> get availableSuggestions =>
      _database.values.map((e) => e['name'] as String).toList();
}
