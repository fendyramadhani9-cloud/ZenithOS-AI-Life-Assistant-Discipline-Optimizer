import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// StorageService: Offline-first persistence managing Secure Storage (BYOK Key)
/// and Hive local boxes for logs, hydration, food, and schedules.
class StorageService {
  static const String _boxSettings = 'zenith_settings';
  static const String _boxJournal = 'zenith_journal';
  static const String _boxHydration = 'zenith_hydration';
  static const String _boxNutrition = 'zenith_nutrition';
  static const String _boxSchedule = 'zenith_schedule';

  static const String _keyApiKey = 'gemini_api_key';
  static const String _keyUserName = 'user_name';
  static const String _keyWeightTarget = 'weight_target';
  static const String _keyHydrationGoal = 'hydration_goal';

  final FlutterSecureStorage _secureStorage;
  late Box _settingsBox;
  late Box _journalBox;
  late Box _hydrationBox;
  late Box _nutritionBox;
  late Box _scheduleBox;

  static StorageService? _instance;
  static StorageService get instance => _instance!;

  StorageService._({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static Future<StorageService> init() async {
    if (_instance != null) return _instance!;

    await Hive.initFlutter();
    final service = StorageService._();
    
    service._settingsBox = await Hive.openBox(_boxSettings);
    service._journalBox = await Hive.openBox(_boxJournal);
    service._hydrationBox = await Hive.openBox(_boxHydration);
    service._nutritionBox = await Hive.openBox(_boxNutrition);
    service._scheduleBox = await Hive.openBox(_boxSchedule);

    _instance = service;
    return service;
  }

  // --- BYOK & Secure Credential Management ---
  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _keyApiKey, value: apiKey);
    } catch (e) {
      // Fallback for environments where secure storage is unavailable
      await _settingsBox.put(_keyApiKey, apiKey);
    }
  }

  Future<String?> getApiKey() async {
    try {
      final key = await _secureStorage.read(key: _keyApiKey);
      if (key != null && key.isNotEmpty) return key;
    } catch (_) {}
    return _settingsBox.get(_keyApiKey) as String?;
  }

  Future<void> deleteApiKey() async {
    try {
      await _secureStorage.delete(key: _keyApiKey);
    } catch (_) {}
    await _settingsBox.delete(_keyApiKey);
  }

  // --- User Profile & Settings ---
  Future<void> saveUserName(String name) async {
    await _settingsBox.put(_keyUserName, name);
  }

  String getUserName() {
    return _settingsBox.get(_keyUserName, defaultValue: 'Architect') as String;
  }

  Future<void> saveHydrationGoal(int ml) async {
    await _settingsBox.put(_keyHydrationGoal, ml);
  }

  int getHydrationGoal() {
    return _settingsBox.get(_keyHydrationGoal, defaultValue: 2500) as int;
  }

  // --- Hydration Storage ---
  Future<void> logHydration(int amountMl, {DateTime? time}) async {
    final now = time ?? DateTime.now();
    final key = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final current = getTodayHydration(date: key);
    await _hydrationBox.put(key, current + amountMl);
  }

  int getTodayHydration({String? date}) {
    final now = DateTime.now();
    final key = date ?? "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return (_hydrationBox.get(key, defaultValue: 0) as num).toInt();
  }

  // --- Journal & Daily Log Storage ---
  Future<void> saveJournalEntry(Map<String, dynamic> entry) async {
    final id = entry['id'] ?? DateTime.now().toIso8601String();
    await _journalBox.put(id, jsonEncode(entry));
  }

  List<Map<String, dynamic>> getAllJournalEntries() {
    return _journalBox.values.map((raw) {
      if (raw is String) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
      return Map<String, dynamic>.from(raw as Map);
    }).toList();
  }

  // --- Food Vision / Nutrition Storage ---
  Future<void> saveMealEntry(Map<String, dynamic> meal) async {
    final id = meal['id'] ?? DateTime.now().toIso8601String();
    await _nutritionBox.put(id, jsonEncode(meal));
  }

  List<Map<String, dynamic>> getAllMealEntries() {
    return _nutritionBox.values.map((raw) {
      if (raw is String) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
      return Map<String, dynamic>.from(raw as Map);
    }).toList();
  }

  // --- Schedule Storage ---
  Future<void> saveSchedule(List<Map<String, dynamic>> items) async {
    await _scheduleBox.put('active_schedule', jsonEncode(items));
  }

  List<Map<String, dynamic>> getActiveSchedule() {
    final raw = _scheduleBox.get('active_schedule');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Full Backup Aggregator ---
  Map<String, dynamic> exportFullBackup() {
    return {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'userName': getUserName(),
      'hydrationGoal': getHydrationGoal(),
      'hydration': _hydrationBox.toMap().map((k, v) => MapEntry(k.toString(), v)),
      'journal': _journalBox.toMap().map((k, v) => MapEntry(k.toString(), v)),
      'nutrition': _nutritionBox.toMap().map((k, v) => MapEntry(k.toString(), v)),
      'schedule': _scheduleBox.toMap().map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  Future<void> restoreBackup(Map<String, dynamic> data) async {
    if (data.containsKey('userName')) {
      await saveUserName(data['userName'] as String);
    }
    if (data.containsKey('hydrationGoal')) {
      await saveHydrationGoal(data['hydrationGoal'] as int);
    }
    if (data['hydration'] is Map) {
      await _hydrationBox.clear();
      final map = data['hydration'] as Map;
      for (final e in map.entries) {
        await _hydrationBox.put(e.key, e.value);
      }
    }
    if (data['journal'] is Map) {
      await _journalBox.clear();
      final map = data['journal'] as Map;
      for (final e in map.entries) {
        await _journalBox.put(e.key, e.value);
      }
    }
    if (data['nutrition'] is Map) {
      await _nutritionBox.clear();
      final map = data['nutrition'] as Map;
      for (final e in map.entries) {
        await _nutritionBox.put(e.key, e.value);
      }
    }
    if (data['schedule'] is Map) {
      await _scheduleBox.clear();
      final map = data['schedule'] as Map;
      for (final e in map.entries) {
        await _scheduleBox.put(e.key, e.value);
      }
    }
  }
}
