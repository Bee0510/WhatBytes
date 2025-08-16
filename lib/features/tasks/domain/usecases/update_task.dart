import '../repositories/task_repository.dart';
import '../entities/task_entity.dart';

class UpdateTask {
  final TaskRepository repo;
  UpdateTask(this.repo);
  Future<void> call(String uid, TaskEntity task) => repo.updateTask(uid, task);
}
