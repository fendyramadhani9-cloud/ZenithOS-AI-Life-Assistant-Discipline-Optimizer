import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import '../../../core/storage/storage_service.dart';
import '../../../services/ai/ai_factory.dart';
import '../../../services/alarm/alarm_factory.dart';
import '../models/schedule_item.dart';

class SchedulerAiService {
  final DeviceCalendarPlugin _deviceCalendar = DeviceCalendarPlugin();

  /// Step 1: Draft via Multi-Provider AI (Gemini / OpenAI with auto-failover)
  Future<List<ScheduleItem>> draftScheduleFromPrompt(String prompt) async {
    final rawList = await AiFactory.executeWithFailover(
      (service) => service.generateSchedule(prompt),
    );
    final items = rawList.map((e) => ScheduleItem.fromMap(e)).toList();
    return items;
  }

  /// Step 2: Save active schedule to local storage
  Future<void> saveActiveSchedule(List<ScheduleItem> items) async {
    final maps = items.map((e) => e.toMap()).toList();
    await StorageService.instance.saveSchedule(maps);
  }

  /// Step 3: Apply to device calendar & alarms
  Future<bool> applyToDevice(List<ScheduleItem> items) async {
    try {
      // 1. Save local state
      await saveActiveSchedule(items);

      // 2. Schedule Cut-off and Sleep Alarms via AlarmFactory
      final alarmService = AlarmFactory.create();
      await alarmService.initialize();
      await alarmService.scheduleMandatoryBedtimeAlarms();

      // 3. Sync to device calendar if available
      try {
        var permissionsGranted = await _deviceCalendar.hasPermissions();
        if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
          permissionsGranted = await _deviceCalendar.requestPermissions();
        }

        if (permissionsGranted.isSuccess && permissionsGranted.data == true) {
          final calendarsResult = await _deviceCalendar.retrieveCalendars();
          if (calendarsResult.isSuccess &&
              calendarsResult.data != null &&
              calendarsResult.data!.isNotEmpty) {
            final defaultCal = calendarsResult.data!.first;
            final now = DateTime.now();

            for (final item in items) {
              final startParts = item.startTime.split(':');
              final endParts = item.endTime.split(':');

              if (startParts.length == 2 && endParts.length == 2) {
                final start = TZDateTime.local(
                  now.year,
                  now.month,
                  now.day,
                  int.tryParse(startParts[0]) ?? 8,
                  int.tryParse(startParts[1]) ?? 0,
                );
                final end = TZDateTime.local(
                  now.year,
                  now.month,
                  now.day,
                  int.tryParse(endParts[0]) ?? 9,
                  int.tryParse(endParts[1]) ?? 0,
                );

                final event = Event(
                  defaultCal.id,
                  title: '[Zenith] ${item.title}',
                  description: item.description,
                  start: start,
                  end: end,
                );
                await _deviceCalendar.createOrUpdateEvent(event);
              }
            }
          }
        }
      } catch (e) {
        debugPrint(
          '[SchedulerAiService] Calendar sync bypassed on this platform: $e',
        );
      }

      return true;
    } catch (e) {
      debugPrint('[SchedulerAiService] Failed applying to device: $e');
      return false;
    }
  }

  List<ScheduleItem> getCachedSchedule() {
    final list = StorageService.instance.getActiveSchedule();
    if (list.isEmpty) {
      return _getDefaultSchedule();
    }
    return list.map((e) => ScheduleItem.fromMap(e)).toList();
  }

  List<ScheduleItem> _getDefaultSchedule() {
    return [
      ScheduleItem(
        id: '1',
        startTime: '06:00',
        endTime: '08:00',
        title: 'Morning Discipline & IaC Deep Work',
        description: 'Terraform / K8s configs with zero distraction.',
        category: 'work',
        priority: 'high',
      ),
      ScheduleItem(
        id: '2',
        startTime: '09:00',
        endTime: '12:00',
        title: 'Core Architecture Execution',
        description: 'Sprint objectives & critical pull requests.',
        category: 'work',
        priority: 'high',
      ),
      ScheduleItem(
        id: '3',
        startTime: '17:30',
        endTime: '19:00',
        title: 'Gym & Hypertrophy Session',
        description: 'Calorie burn for 70kg -> 64kg weight reduction.',
        category: 'fitness',
        priority: 'high',
      ),
      ScheduleItem(
        id: '4',
        startTime: '22:30',
        endTime: '23:00',
        title: 'Zenith Soft Cut-off',
        description: 'Commit code, close IDE, activate blue light filters.',
        category: 'recovery',
        priority: 'urgent',
      ),
      ScheduleItem(
        id: '5',
        startTime: '23:00',
        endTime: '05:00',
        title: 'Strict Recovery Sleep',
        description: 'Mandatory 6-hour cellular rejuvenation window.',
        category: 'sleep',
        priority: 'urgent',
      ),
    ];
  }
}
