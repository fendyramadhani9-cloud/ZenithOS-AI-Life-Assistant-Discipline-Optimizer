import 'alarm_service.dart';
import 'alarm_factory_web.dart' if (dart.library.io) 'alarm_factory_io.dart';

class AlarmFactory {
  static AlarmService create() => getPlatformAlarmService();
}
