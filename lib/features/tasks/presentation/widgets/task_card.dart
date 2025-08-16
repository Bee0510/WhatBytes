import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatbytes/core/theme/app_color.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_event.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority.dart';
import '../bloc/task_bloc.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  const TaskCard({super.key, required this.task});

  Color _priorityColor(Priority p, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return switch (p) {
      Priority.high => cs.error,
      Priority.medium => cs.tertiary,
      Priority.low => cs.primary,
    };
  }

  void _toggle(BuildContext context) {
    context.read<TaskBloc>().add(ToggleCompletedPressed(task));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColor.primary.withOpacity(.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggle(context), // tap anywhere toggles
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: _RoundToggle(
            value: task.completed,
            onChanged: (_) => _toggle(context),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                style: TextStyle(
                  color: cs.onSurfaceVariant.withOpacity(.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _priorityColor(task.priority, context).withOpacity(.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              task.priority.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

/// A circular, radio-like toggle for completed state.
/// Visual only—doesn't imply mutual exclusivity like a real Radio.
class _RoundToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _RoundToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = value ? AppColor.primary : Colors.transparent;
    final border = value ? AppColor.primary : cs.outlineVariant;

    return InkResponse(
      onTap: () => onChanged(!value),
      radius: 22,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 2),
          boxShadow:
              value
                  ? [
                    BoxShadow(
                      color: AppColor.primary.withOpacity(.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        // checkmark / dot
        child: AnimatedOpacity(
          opacity: value ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: const Center(
            child: Icon(Icons.check_rounded, color: Colors.white, size: 14),
          ),
        ),
      ),
    );
  }
}
