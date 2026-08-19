class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  TodoItem copyWith({String? id, String? title, bool? isCompleted}) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory TodoItem.fromMap(Map<String, dynamic> map) => TodoItem(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: map['title'] ?? '',
        isCompleted: map['isCompleted'] ?? false,
      );
}

class JournalEntry {
  final String id;
  final DateTime date;
  final List<TodoItem> todos;
  final String unfilteredStory;
  final bool isPartnerShared; // false = Private Only, true = Partner Shared

  JournalEntry({
    required this.id,
    required this.date,
    required this.todos,
    required this.unfilteredStory,
    this.isPartnerShared = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'todos': todos.map((e) => e.toMap()).toList(),
        'unfilteredStory': unfilteredStory,
        'isPartnerShared': isPartnerShared,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] ?? DateTime.now().toIso8601String(),
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        todos: (map['todos'] as List?)
                ?.map((e) => TodoItem.fromMap(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        unfilteredStory: map['unfilteredStory'] ?? '',
        isPartnerShared: map['isPartnerShared'] ?? false,
      );
}
