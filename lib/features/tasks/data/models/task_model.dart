import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority.dart';

DateTime _asDateTime(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  if (v is Timestamp) return v.toDate();
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
  return DateTime.now();
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String priority; // 'low'|'medium'|'high'
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Used for Firestore writes (DateTime is fine; plugin converts to Timestamp)
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDate': dueDate,
    'priority': priority,
    'completed': completed,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  /// Works for BOTH Firestore docs (Timestamp) and Hive/local (DateTime/String/int)
  factory TaskModel.fromMap(String id, Map<String, dynamic> json) => TaskModel(
    id: id,
    title: json['title'] as String,
    description: json['description'] as String?,
    dueDate: _asDateTime(json['dueDate']),
    priority: (json['priority'] as String?) ?? 'medium',
    completed: json['completed'] as bool? ?? false,
    createdAt: _asDateTime(json['createdAt']),
    updatedAt: _asDateTime(json['updatedAt']),
  );

  TaskEntity toEntity() => TaskEntity(
    id: id,
    title: title,
    description: description,
    dueDate: dueDate,
    priority: PriorityX.from(priority),
    completed: completed,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static TaskModel fromEntity(TaskEntity e) => TaskModel(
    id: e.id,
    title: e.title,
    description: e.description,
    dueDate: e.dueDate,
    priority: e.priority.asKey,
    completed: e.completed,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}
