import 'alarm_service.dart';
import 'mobile_alarm_service.dart';

AlarmService getPlatformAlarmService() => MobileAlarmService();
