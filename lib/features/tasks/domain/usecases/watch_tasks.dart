import '../repositories/task_repository.dart';
import '../entities/task_entity.dart';

class WatchTasks {
  final TaskRepository repo;
  WatchTasks(this.repo);
  Stream<List<TaskEntity>> call(String uid) => repo.watchTasks(uid);
}
