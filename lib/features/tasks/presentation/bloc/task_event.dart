import 'package:equatable/equatable.dart';
import 'package:whatbytes/features/tasks/domain/entities/task_entity.dart';

sealed class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String uid;
  LoadTasks(this.uid);
}

class CreateTaskPressed extends TaskEvent {
  final TaskEntity task;
  CreateTaskPressed(this.task);
}

class UpdateTaskPressed extends TaskEvent {
  final TaskEntity task;
  UpdateTaskPressed(this.task);
}

class DeleteTaskPressed extends TaskEvent {
  final String taskId;
  DeleteTaskPressed(this.taskId);
}

class ToggleCompletedPressed extends TaskEvent {
  final TaskEntity task;
  ToggleCompletedPressed(this.task);
}

// Internal events (from the stream)
class TasksStreamUpdated extends TaskEvent {
  final List<TaskEntity> items;
  TasksStreamUpdated(this.items);
}

class TasksStreamError extends TaskEvent {
  final String message;
  TasksStreamError(this.message);
}
