import 'package:flutter/foundation.dart';
import '../interfaces/alarm_service.dart';
import 'mobile_alarm_service.dart';
import 'web_alarm_service.dart';

class AlarmFactory {
  static AlarmService create() {
    if (kIsWeb) {
      return WebAlarmService();
    } else {
      return MobileAlarmService();
    }
  }
}
