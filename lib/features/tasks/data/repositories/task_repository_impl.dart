import 'dart:async';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_ds.dart';
import '../datasources/task_remote_ds.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remote;
  final TaskLocalDataSource local;
  TaskRepositoryImpl(this.remote, this.local);

  @override
  Stream<List<TaskEntity>> watchTasks(String uid) async* {
    // Emit cached first
    yield await local.load(uid);
    // Then remote
    await for (final items in remote.watch(uid)) {
      unawaited(local.cache(uid, items));
      yield items;
    }
  }

  @override
  Future<void> createTask(String uid, TaskEntity task) => remote.create(uid, task);

  @override
  Future<void> deleteTask(String uid, String taskId) => remote.delete(uid, taskId);

  @override
  Future<void> updateTask(String uid, TaskEntity task) => remote.update(uid, task);
}
