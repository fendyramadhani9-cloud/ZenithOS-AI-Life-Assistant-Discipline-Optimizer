/// Interface for Cross-Platform Alarm System in ZenithOS
abstract class AlarmService {
  /// Initialize the underlying platform service
  Future<void> initialize();

  /// Set an exact alarm for sleep discipline / task trigger
  Future<bool> setAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
    required String description,
    bool isStrictBedtime = false,
  });

  /// Cancel an alarm by its identifier
  Future<bool> cancelAlarm(int id);

  /// Schedule mandatory ZenithOS sleep cut-off alarms:
  /// - 22:30 Soft Reminder (Save commit, close laptop)
  /// - 23:00 Strict Sleep Alarm (Recovery 6 hours -> 05:00)
  Future<void> scheduleMandatoryBedtimeAlarms();
}
