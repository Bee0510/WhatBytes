import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatbytes/core/utils/toast.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskEntity>> watch(String uid);
  Future<void> create(String uid, TaskEntity task);
  Future<void> update(String uid, TaskEntity task);
  Future<void> delete(String uid, String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _db;
  TaskRemoteDataSourceImpl(this._db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('tasks');

  @override
  Stream<List<TaskEntity>> watch(String uid) => _col(uid)
      .orderBy('dueDate')
      .snapshots()
      .map(
        (s) =>
            s.docs
                .map((d) => TaskModel.fromMap(d.id, d.data()).toEntity())
                .toList(),
      );

  @override
  Future<void> create(String uid, TaskEntity task) async {
    final m = TaskModel.fromEntity(task);
    await _col(uid)
        .doc(m.id)
        .set(m.toJson())
        .then(
          (value) => ToastUtils.showCustomToast('Task created successfully!'),
        )
        .catchError(
          (error) =>
              ToastUtils.showCustomToast('Failed to create task: $error'),
        );
  }

  @override
  Future<void> update(String uid, TaskEntity task) async {
    final m = TaskModel.fromEntity(task);
    await _col(uid)
        .doc(m.id)
        .update(m.toJson())
        .then(
          (value) => ToastUtils.showCustomToast('Task updated successfully!'),
        )
        .catchError(
          (error) =>
              ToastUtils.showCustomToast('Failed to update task: $error'),
        );
  }

  @override
  Future<void> delete(String uid, String taskId) => _col(uid)
      .doc(taskId)
      .delete()
      .then((value) => ToastUtils.showCustomToast('Task deleted successfully!'))
      .catchError(
        (error) => ToastUtils.showCustomToast('Failed to delete task: $error'),
      );
}
