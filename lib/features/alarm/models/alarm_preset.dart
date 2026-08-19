class AlarmPreset {
  final int id;
  final String title;
  final String description;
  final int hour;
  final int minute;
  final bool isStrictBedtime;
  final bool enabled;

  const AlarmPreset({
    required this.id,
    required this.title,
    required this.description,
    required this.hour,
    required this.minute,
    this.isStrictBedtime = false,
    this.enabled = true,
  });

  static const AlarmPreset softReminder2230 = AlarmPreset(
    id: 101,
    title: 'ZENITH CUT-OFF: 22:30',
    description: 'Save commit, wrap-up IaC, shut down laptop.',
    hour: 22,
    minute: 30,
    isStrictBedtime: false,
  );

  static const AlarmPreset strictSleep2300 = AlarmPreset(
    id: 102,
    title: 'ZENITH HARD SLEEP: 23:00',
    description: 'Immediate recovery start (6hr sleep window -> 05:00 wake).',
    hour: 23,
    minute: 0,
    isStrictBedtime: true,
  );
}
