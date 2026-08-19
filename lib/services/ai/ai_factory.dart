import 'package:flutter/foundation.dart';
import 'ai_service.dart';
import 'gemini_service.dart';
import 'key_vault_controller.dart';
import 'models/api_key_entry.dart';
import 'openai_service.dart';

class AiFactory {
  /// Resolve current active AI service instance
  static AiService? getService() {
    final active = KeyVaultController.instance.activeKey;
    if (active == null || active.key.isEmpty) return null;

    if (active.provider == AiProvider.openAi) {
      return OpenAiService(apiKey: active.key);
    } else {
      return GeminiService(apiKey: active.key);
    }
  }

  /// Execute with Automatic Failover Protection
  /// If the current key hits 429 (Rate limit) or Quota/Network error,
  /// rotates to the next key in the pool and retries the operation transparently.
  static Future<T> executeWithFailover<T>(
    Future<T> Function(AiService service) action,
  ) async {
    var service = getService();
    var activeKey = KeyVaultController.instance.activeKey;

    if (service == null || activeKey == null) {
      throw Exception('No active API Key found in Key Vault. Please configure your key.');
    }

    try {
      final result = await action(service);
      KeyVaultController.instance.incrementUsage(activeKey.id);
      return result;
    } catch (e) {
      final errorStr = e.toString();
      final isRateLimitOrQuota = errorStr.contains('429') ||
          errorStr.contains('Quota') ||
          errorStr.contains('ResourceExhausted') ||
          errorStr.contains('503') ||
          errorStr.contains('500');

      if (isRateLimitOrQuota) {
        debugPrint('[AiFactory] Error encountered: $errorStr. Initiating key failover...');
        final nextKey = await KeyVaultController.instance.rotateToNextKey(
          activeKey.id,
          'Rate limit or Server error: $errorStr',
        );

        if (nextKey != null) {
          final failoverService = getService();
          if (failoverService != null) {
            debugPrint('[AiFactory] Retrying request with failover key: ${nextKey.label}');
            final result = await action(failoverService);
            KeyVaultController.instance.incrementUsage(nextKey.id);
            return result;
          }
        }
      }

      // Re-throw original if failover unavailable
      rethrow;
    }
  }
}
