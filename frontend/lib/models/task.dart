enum TaskStatus { todo, inProgress, done }
enum TaskCategory { work, personal, shopping, health, other }

extension TaskStatusExtension on TaskStatus {
  String get apiValue {
    switch (this) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  static TaskStatus fromApi(String? value) {
    switch (value) {
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'DONE':
        return TaskStatus.done;
      case 'TODO':
      default:
        return TaskStatus.todo;
    }
  }
}

extension TaskCategoryExtension on TaskCategory {
  String get apiValue {
    switch (this) {
      case TaskCategory.work:
        return 'WORK';
      case TaskCategory.personal:
        return 'PERSONAL';
      case TaskCategory.shopping:
        return 'SHOPPING';
      case TaskCategory.health:
        return 'HEALTH';
      case TaskCategory.other:
        return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.other:
        return 'Other';
    }
  }

  static TaskCategory fromApi(String? value) {
    switch (value) {
      case 'WORK':
        return TaskCategory.work;
      case 'PERSONAL':
        return TaskCategory.personal;
      case 'SHOPPING':
        return TaskCategory.shopping;
      case 'HEALTH':
        return TaskCategory.health;
      case 'OTHER':
      default:
        return TaskCategory.other;
    }
  }
}

class Task {
  final int? id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskCategory? category;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Task({
    this.id,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    this.category,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: TaskStatusExtension.fromApi(json['status']?.toString()),
      category: json['category'] == null
          ? null
          : TaskCategoryExtension.fromApi(json['category']?.toString()),
      dueDate: _parseDateTime(json['dueDate']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status.apiValue,
      'category': category?.apiValue,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskCategory? category,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}
