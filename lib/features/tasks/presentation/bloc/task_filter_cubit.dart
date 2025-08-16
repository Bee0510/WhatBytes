import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/priority.dart';

class TaskFilterState extends Equatable {
  final Set<Priority> priorities;
  final bool? completed;
  final String query;

  const TaskFilterState({
    this.priorities = const {},
    this.completed,
    this.query = '',
  });

  @override
  List<Object?> get props => [priorities, completed, query];
}

class TaskFilterCubit extends Cubit<TaskFilterState> {
  TaskFilterCubit() : super(const TaskFilterState());

  void togglePriority(Priority p) {
    final next = Set<Priority>.from(state.priorities);
    if (next.contains(p)) {
      next.remove(p);
    } else {
      next.add(p);
    }
    emit(
      TaskFilterState(
        priorities: next,
        completed: state.completed,
        query: state.query,
      ),
    );
  }

  void setStatus(bool? v) {
    emit(
      TaskFilterState(
        priorities: state.priorities,
        completed: v,
        query: state.query,
      ),
    );
  }

  void setQuery(String q) {
    emit(
      TaskFilterState(
        priorities: state.priorities,
        completed: state.completed,
        query: q.trim().toLowerCase(),
      ),
    );
  }

  void reset() {
    emit(const TaskFilterState());
  }
}
