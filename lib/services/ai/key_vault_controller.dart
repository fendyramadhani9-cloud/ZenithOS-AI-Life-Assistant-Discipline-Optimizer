import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/api_key_entry.dart';

class KeyVaultController extends ChangeNotifier {
  static const String _vaultBoxName = 'zenith_key_vault';
  static const String _secureVaultKey = 'zenith_secure_key_pool';

  final FlutterSecureStorage _secureStorage;
  late Box _vaultBox;
  List<ApiKeyEntry> _keyPool = [];

  static KeyVaultController? _instance;
  static KeyVaultController get instance => _instance!;

  KeyVaultController._({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static Future<KeyVaultController> init() async {
    if (_instance != null) return _instance!;

    final controller = KeyVaultController._();
    controller._vaultBox = await Hive.openBox(_vaultBoxName);
    await controller._loadKeys();
    _instance = controller;
    return controller;
  }

  List<ApiKeyEntry> get keyPool => List.unmodifiable(_keyPool);

  ApiKeyEntry? get activeKey {
    try {
      return _keyPool.firstWhere((k) => k.isActive);
    } catch (_) {
      return _keyPool.isNotEmpty ? _keyPool.first : null;
    }
  }

  Future<void> _loadKeys() async {
    try {
      final secureData = await _secureStorage.read(key: _secureVaultKey);
      if (secureData != null && secureData.isNotEmpty) {
        final list = jsonDecode(secureData) as List;
        _keyPool = list.map((e) => ApiKeyEntry.fromMap(e)).toList();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('[KeyVaultController] Reading secure storage fallback: $e');
    }

    // Fallback to Hive box
    final raw = _vaultBox.get('keys');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _keyPool = list.map((e) => ApiKeyEntry.fromMap(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _persistKeys() async {
    final raw = jsonEncode(_keyPool.map((e) => e.toMap()).toList());
    try {
      await _secureStorage.write(key: _secureVaultKey, value: raw);
    } catch (_) {}
    await _vaultBox.put('keys', raw);
    notifyListeners();
  }

  Future<void> addKey({
    required String label,
    required String key,
    required AiProvider provider,
    bool setAsActive = true,
  }) async {
    final cleanKey = key.trim();
    if (cleanKey.isEmpty) return;

    if (setAsActive) {
      _keyPool = _keyPool.map((k) => k.copyWith(isActive: false)).toList();
    }

    final newEntry = ApiKeyEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label.isEmpty ? '${provider.name.toUpperCase()} Key' : label,
      key: cleanKey,
      provider: provider,
      isActive: setAsActive || _keyPool.isEmpty,
    );

    _keyPool.add(newEntry);
    await _persistKeys();
  }

  Future<void> setActiveKey(String keyId) async {
    _keyPool = _keyPool
        .map((k) => k.copyWith(isActive: k.id == keyId))
        .toList();
    await _persistKeys();
  }

  Future<void> removeKey(String keyId) async {
    _keyPool.removeWhere((k) => k.id == keyId);
    if (_keyPool.isNotEmpty && !_keyPool.any((k) => k.isActive)) {
      _keyPool[0] = _keyPool[0].copyWith(isActive: true);
    }
    await _persistKeys();
  }

  /// Automatic Key Failover Mechanism
  /// When a key encounters 429 / Quota / 5xx error, mark error and rotate to the next available healthy key
  Future<ApiKeyEntry?> rotateToNextKey(
    String failedKeyId,
    String reason,
  ) async {
    debugPrint(
      '[KeyVaultController] Failover triggered for key $failedKeyId. Reason: $reason',
    );
    final index = _keyPool.indexWhere((k) => k.id == failedKeyId);
    if (index != -1) {
      _keyPool[index] = _keyPool[index].copyWith(
        lastError: '$reason (${DateTime.now().toIso8601String()})',
        isActive: false,
      );
    }

    // Find next key of same or any provider
    final candidates = _keyPool.where((k) => k.id != failedKeyId).toList();
    if (candidates.isNotEmpty) {
      final nextKey = candidates.first;
      await setActiveKey(nextKey.id);
      debugPrint(
        '[KeyVaultController] Switched to failover key: ${nextKey.label} (${nextKey.provider.name})',
      );
      return nextKey;
    }

    await _persistKeys();
    return null;
  }

  void incrementUsage(String keyId) {
    final index = _keyPool.indexWhere((k) => k.id == keyId);
    if (index != -1) {
      _keyPool[index] = _keyPool[index].copyWith(
        requestCount: _keyPool[index].requestCount + 1,
      );
      _persistKeys();
    }
  }
}
