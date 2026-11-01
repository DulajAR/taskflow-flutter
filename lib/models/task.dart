class Task {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  // 0 = at due time, 10 = 10 minutes before,
  // 30 = 30 minutes before, -1 = no reminder.
  final int reminderMinutes;

  const Task({
    this.id,
    required this.title,
    this.description = '',
    this.category = 'Personal',
    this.priority = 'Medium',
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.reminderMinutes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'reminderMinutes': reminderMinutes,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      priority: map['priority'] as String,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      reminderMinutes: (map['reminderMinutes'] as int?) ?? 0,
    );
  }
}
