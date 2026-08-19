import 'package:flutter/foundation.dart';
import 'package:alarm/alarm.dart';
import 'alarm_service.dart';
import 'models/alarm_preset.dart';

/// Mobile Implementation: Leverages flutter `alarm` package for native exact alarms on Android.
class MobileAlarmService implements AlarmService {
  @override
  Future<void> initialize() async {
    try {
      await Alarm.init();
      debugPrint('[MobileAlarmService] Native alarm initialized.');
    } catch (e) {
      debugPrint('[MobileAlarmService] Native alarm init warning: $e');
    }
  }

  @override
  Future<bool> setAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
    required String description,
    bool isStrictBedtime = false,
  }) async {
    try {
      final alarmSettings = AlarmSettings(
        id: id,
        dateTime: dateTime,
        assetAudioPath: 'assets/audio/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        volume: isStrictBedtime ? 1.0 : 0.7,
        fadeDuration: 3.0,
        notificationTitle: title,
        notificationBody: description,
        enableNotificationOnKill: true,
      );

      final success = await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('[MobileAlarmService] Alarm $id scheduled for $dateTime (Success: $success)');
      return success;
    } catch (e) {
      debugPrint('[MobileAlarmService] Failed to set native alarm ($e)');
      return false;
    }
  }

  @override
  Future<bool> cancelAlarm(int id) async {
    try {
      return await Alarm.stop(id);
    } catch (e) {
      debugPrint('[MobileAlarmService] Error canceling alarm $id: $e');
      return false;
    }
  }

  @override
  Future<void> scheduleMandatoryBedtimeAlarms() async {
    final now = DateTime.now();

    // 22:30 Soft Reminder
    DateTime time2230 = DateTime(now.year, now.month, now.day, 22, 30);
    if (now.isAfter(time2230)) {
      time2230 = time2230.add(const Duration(days: 1));
    }
    await setAlarm(
      id: AlarmPreset.softReminder2230.id,
      dateTime: time2230,
      title: AlarmPreset.softReminder2230.title,
      description: AlarmPreset.softReminder2230.description,
    );

    // 23:00 Strict Sleep Alarm
    DateTime time2300 = DateTime(now.year, now.month, now.day, 23, 0);
    if (now.isAfter(time2300)) {
      time2300 = time2300.add(const Duration(days: 1));
    }
    await setAlarm(
      id: AlarmPreset.strictSleep2300.id,
      dateTime: time2300,
      title: AlarmPreset.strictSleep2300.title,
      description: AlarmPreset.strictSleep2300.description,
      isStrictBedtime: true,
    );
  }
}
