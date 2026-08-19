import 'alarm_service.dart';
import 'web_alarm_service.dart';

AlarmService getPlatformAlarmService() => WebAlarmService();
