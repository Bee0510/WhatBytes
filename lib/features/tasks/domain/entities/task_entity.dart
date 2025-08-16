import 'priority.dart';

class TaskEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final Priority priority;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.completed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    completed: completed ?? this.completed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
