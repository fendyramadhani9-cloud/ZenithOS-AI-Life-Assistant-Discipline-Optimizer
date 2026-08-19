enum AiProvider { gemini, openAi }

class ApiKeyEntry {
  final String id;
  final String label;
  final String key;
  final AiProvider provider;
  final bool isActive;
  final int requestCount;
  final String? lastError;
  final DateTime createdAt;

  ApiKeyEntry({
    required this.id,
    required this.label,
    required this.key,
    required this.provider,
    this.isActive = false,
    this.requestCount = 0,
    this.lastError,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get maskedKey {
    if (key.length <= 8) return '••••••••';
    return '${key.substring(0, 4)}••••${key.substring(key.length - 4)}';
  }

  ApiKeyEntry copyWith({
    String? id,
    String? label,
    String? key,
    AiProvider? provider,
    bool? isActive,
    int? requestCount,
    String? lastError,
    DateTime? createdAt,
  }) {
    return ApiKeyEntry(
      id: id ?? this.id,
      label: label ?? this.label,
      key: key ?? this.key,
      provider: provider ?? this.provider,
      isActive: isActive ?? this.isActive,
      requestCount: requestCount ?? this.requestCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'key': key,
      'provider': provider.name,
      'isActive': isActive,
      'requestCount': requestCount,
      'lastError': lastError,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ApiKeyEntry.fromMap(Map<String, dynamic> map) {
    return ApiKeyEntry(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: map['label'] ?? 'API Key',
      key: map['key'] ?? '',
      provider: map['provider'] == 'openAi' ? AiProvider.openAi : AiProvider.gemini,
      isActive: map['isActive'] ?? false,
      requestCount: map['requestCount'] ?? 0,
      lastError: map['lastError'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
