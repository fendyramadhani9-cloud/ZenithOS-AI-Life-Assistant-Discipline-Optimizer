class ScheduleItem {
  final String id;
  final String startTime;
  final String endTime;
  final String title;
  final String description;
  final String category; // 'work', 'fitness', 'nutrition', 'recovery', 'sleep'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
    this.category = 'work',
    this.priority = 'medium',
    this.isCompleted = false,
  });

  ScheduleItem copyWith({
    String? id,
    String? startTime,
    String? endTime,
    String? title,
    String? description,
    String? category,
    String? priority,
    bool? isCompleted,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory ScheduleItem.fromMap(Map<String, dynamic> map) {
    return ScheduleItem(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: map['startTime'] ?? '08:00',
      endTime: map['endTime'] ?? '09:00',
      title: map['title'] ?? 'Task',
      description: map['description'] ?? '',
      category: map['category'] ?? 'work',
      priority: map['priority'] ?? 'medium',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
