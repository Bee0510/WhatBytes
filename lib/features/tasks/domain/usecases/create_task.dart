import '../repositories/task_repository.dart';
import '../entities/task_entity.dart';

class CreateTask {
  final TaskRepository repo;
  CreateTask(this.repo);
  Future<void> call(String uid, TaskEntity task) => repo.createTask(uid, task);
}
