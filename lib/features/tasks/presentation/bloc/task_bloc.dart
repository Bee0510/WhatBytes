import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatbytes/core/utils/toast.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_event.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_state.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/watch_tasks.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final CreateTask _create;
  final UpdateTask _update;
  final DeleteTask _delete;
  final WatchTasks _watch;

  String? _uid;
  StreamSubscription<List<TaskEntity>>? _sub;

  TaskBloc(this._create, this._update, this._delete, this._watch)
    : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<TasksStreamUpdated>(_onStreamUpdated);
    on<TasksStreamError>(_onStreamError);

    on<CreateTaskPressed>(_onCreate);
    on<UpdateTaskPressed>(_onUpdate);
    on<DeleteTaskPressed>(_onDelete);
    on<ToggleCompletedPressed>(_onToggle);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    _uid = event.uid;
    emit(TaskLoading());

    // ensure we don't create multiple listeners
    await _sub?.cancel();
    _sub = _watch(event.uid).listen(
      (items) => add(TasksStreamUpdated(items)),
      onError: (e, st) => add(TasksStreamError(e.toString())),
    );
  }

  void _onStreamUpdated(TasksStreamUpdated event, Emitter<TaskState> emit) {
    final sorted = List<TaskEntity>.from(event.items)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    emit(TaskLoaded(sorted));
  }

  void _onStreamError(TasksStreamError event, Emitter<TaskState> emit) {
    emit(TaskFailure(event.message));
  }

  Future<void> _onCreate(
    CreateTaskPressed event,
    Emitter<TaskState> emit,
  ) async {
    if (_uid == null) return;
    emit(TaskLoading()); // show spinner
    await _create(_uid!, event.task);
  }

  Future<void> _onUpdate(
    UpdateTaskPressed event,
    Emitter<TaskState> emit,
  ) async {
    if (_uid == null) return;
    emit(TaskLoading());
    await _update(_uid!, event.task);
  }

  Future<void> _onDelete(
    DeleteTaskPressed event,
    Emitter<TaskState> emit,
  ) async {
    if (_uid == null) return;
    emit(TaskLoading());
    await _delete(_uid!, event.taskId);
  }

  Future<void> _onToggle(
    ToggleCompletedPressed event,
    Emitter<TaskState> emit,
  ) async {
    if (_uid == null) return;
    emit(TaskLoading());
    final toggled = event.task.copyWith(
      completed: !event.task.completed,
      updatedAt: DateTime.now(),
    );
    await _update(_uid!, toggled);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
