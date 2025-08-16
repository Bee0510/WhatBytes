import '../entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> watchTasks(String uid);
  Future<void> createTask(String uid, TaskEntity task);
  Future<void> updateTask(String uid, TaskEntity task);
  Future<void> deleteTask(String uid, String taskId);
}
