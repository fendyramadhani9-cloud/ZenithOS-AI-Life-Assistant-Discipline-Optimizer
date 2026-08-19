import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/ai/ai_factory.dart';
import '../storage/storage_service.dart';

enum QueueItemType { foodScan, scheduleGen, retrospective }

class QueueItem {
  final String id;
  final QueueItemType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final String status; // 'pending_sync', 'processing', 'completed', 'failed'

  QueueItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.status = 'pending_sync',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory QueueItem.fromMap(Map<String, dynamic> map) {
    return QueueItem(
      id: map['id'],
      type: QueueItemType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QueueItemType.foodScan,
      ),
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'pending_sync',
    );
  }
}

class OfflineQueueService extends ChangeNotifier {
  static const String _boxName = 'zenith_offline_queue';
  late Box _box;
  StreamSubscription? _connectivitySub;
  bool _isOnline = true;
  bool _isFlushing = false;

  static OfflineQueueService? _instance;
  static OfflineQueueService get instance => _instance!;

  bool get isOnline => _isOnline;
  int get pendingCount => _box.length;

  static Future<OfflineQueueService> init() async {
    if (_instance != null) return _instance!;

    final service = OfflineQueueService();
    service._box = await Hive.openBox(_boxName);
    await service._initConnectivity();

    _instance = service;
    return service;
  }

  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);

    _connectivitySub = connectivity.onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
        if (_isOnline) {
          debugPrint('[OfflineQueueService] Connection restored. Flushing queue...');
          flushQueue();
        }
      }
    });
  }

  Future<void> enqueueItem({
    required QueueItemType type,
    required Map<String, dynamic> payload,
  }) async {
    final item = QueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await _box.put(item.id, jsonEncode(item.toMap()));
    notifyListeners();
    debugPrint('[OfflineQueueService] Queued offline action: ${type.name} (Total: ${_box.length})');

    if (_isOnline) {
      flushQueue();
    }
  }

  Future<void> flushQueue() async {
    if (_isFlushing || _box.isEmpty || !_isOnline) return;
    _isFlushing = true;
    notifyListeners();

    final keys = List.from(_box.keys);
    for (final key in keys) {
      final raw = _box.get(key);
      if (raw == null) continue;

      try {
        final itemMap = jsonDecode(raw) as Map<String, dynamic>;
        final item = QueueItem.fromMap(itemMap);

        if (item.type == QueueItemType.scheduleGen) {
          final prompt = item.payload['prompt'] as String;
          final schedule = await AiFactory.executeWithFailover(
            (service) => service.generateSchedule(prompt),
          );
          await StorageService.instance.saveSchedule(schedule);
        }

        // Successfully synced
        await _box.delete(key);
        debugPrint('[OfflineQueueService] Successfully processed queue item: $key');
      } catch (e) {
        debugPrint('[OfflineQueueService] Failed processing queue item $key ($e). Retrying next cycle.');
      }
    }

    _isFlushing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
