import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cache(String uid, List<TaskEntity> tasks);
  Future<List<TaskEntity>> load(String uid);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  String _boxName(String uid) => 'tasks_$uid';

  @override
  Future<void> cache(String uid, List<TaskEntity> tasks) async {
    final box = await Hive.openBox(_boxName(uid));
    final list =
        tasks.map((e) {
          final m = TaskModel.fromEntity(e);
          final map = m.toJson();
          map['id'] = m.id; // keep id in local cache
          return map;
        }).toList();
    await box.put('items', list);
  }

  @override
  Future<List<TaskEntity>> load(String uid) async {
    final box = await Hive.openBox(_boxName(uid));
    final raw = (box.get('items') as List?) ?? const [];
    return raw.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final id =
          (map['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString();
      return TaskModel.fromMap(id, map).toEntity();
    }).toList();
  }
}
