import 'package:equatable/equatable.dart';
import 'package:whatbytes/features/tasks/domain/entities/task_entity.dart';

sealed class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  TaskLoaded(this.tasks);
}

class TaskFailure extends TaskState {
  final String message;
  TaskFailure(this.message);
}
