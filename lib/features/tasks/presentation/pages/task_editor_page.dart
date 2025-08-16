import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatbytes/core/theme/app_color.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_event.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_state.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority.dart';
import '../bloc/task_bloc.dart';

class TaskEditorPage extends StatefulWidget {
  final String? taskId;
  const TaskEditorPage({super.key, this.taskId});

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 1));
  Priority _priority = Priority.medium;
  TaskEntity? _existing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_existing == null && widget.taskId != null) {
      final s = context.read<TaskBloc>().state;
      if (s is TaskLoaded) {
        final found = s.tasks.where((t) => t.id == widget.taskId);
        if (found.isNotEmpty) {
          _existing = found.first;
          _title.text = _existing!.title;
          _desc.text = _existing!.description ?? '';
          _due = _existing!.dueDate;
          _priority = _existing!.priority;
        }
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existing != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? 'Edit task' : 'New task',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: cs.onSurface,
          ),
        ),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.save_rounded),
            label: Text(isEditing ? 'Update Task' : 'Save Task'),
            onPressed: _onSave,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          // Adaptive width container
          final maxW = math.min(560.0, c.maxWidth);
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    // ---- Title ----
                    _SectionLabel('Title'),
                    TextFormField(
                      controller: _title,
                      textInputAction: TextInputAction.next,
                      autofocus: _existing == null,
                      decoration: _inputDecoration(
                        context,
                        hint: 'e.g. Call the client',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Title is required'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // ---- Description ----
                    _SectionLabel('Description (optional)'),
                    TextFormField(
                      controller: _desc,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: _inputDecoration(
                        context,
                        hint: 'Add a short note…',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Due date ----
                    _SectionLabel('Due date'),
                    _DueRow(
                      date: _due,
                      onPick: _pickDate,
                      onShortcut: (d) => setState(() => _due = d),
                    ),
                    const SizedBox(height: 16),

                    // ---- Priority ----
                    _SectionLabel('Priority'),
                    _PrioritySelector(
                      value: _priority,
                      onChanged: (p) => setState(() => _priority = p),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {String? hint}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(.25),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.6),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _due,
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _onSave() {
    print('Creating new task with title: ${_title.text.trim()}');
    print('Description: ${_desc.text.trim()}');
    print('Due date: $_due');
    print('Priority: $_priority');
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();

    if (_existing != null) {
      final updated = _existing!.copyWith(
        title: _title.text.trim(),
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        dueDate: _due,
        priority: _priority,
        updatedAt: now,
      );
      context.read<TaskBloc>().add(UpdateTaskPressed(updated));
      Navigator.of(context).maybePop();
      return;
    }
    print('Creating new task with title: ${_title.text.trim()}');
    print('Description: ${_desc.text.trim()}');
    print('Due date: $_due');
    print('Priority: $_priority');
    print('Created at: $now');
    final newTask = TaskEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      dueDate: _due,
      priority: _priority,
      completed: false,
      createdAt: now,
      updatedAt: now,
    );
    context.read<TaskBloc>().add(CreateTaskPressed(newTask));
    Navigator.of(context).maybePop();
  }

  void _confirmDelete() async {
    if (_existing == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete task?'),
            content: const Text('This action can’t be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (ok == true) {
      context.read<TaskBloc>().add(DeleteTaskPressed(_existing!.id));
      Navigator.of(context).maybePop();
    }
  }
}

// ==================== UI pieces ====================

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DueRow extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPick;
  final ValueChanged<DateTime> onShortcut;
  const _DueRow({
    required this.date,
    required this.onPick,
    required this.onShortcut,
  });

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final in7 = today.add(const Duration(days: 7));

    Chip chip(String label, DateTime d) => Chip(
      label: Text(label),
      side: BorderSide(color: cs.outlineVariant),
      backgroundColor: cs.surfaceContainerHigh,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date field (button style)
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPick,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded, color: cs.onSurfaceVariant),
                const SizedBox(width: 10),
                Text(
                  _fmt(date),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Quick pick chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.today_rounded, size: 16),
              label: const Text('Today'),
              onPressed: () => onShortcut(today),
            ),
            ActionChip(
              avatar: const Icon(Icons.calendar_view_day_rounded, size: 16),
              label: const Text('Tomorrow'),
              onPressed: () => onShortcut(tomorrow),
            ),
            ActionChip(
              avatar: const Icon(Icons.date_range_rounded, size: 16),
              label: const Text('In 7 days'),
              onPressed: () => onShortcut(in7),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final Priority value;
  final ValueChanged<Priority> onChanged;
  const _PrioritySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget pill(Priority p, String label, IconData icon, Color color) {
      final selected = value == p;
      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? color : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? color : cs.onSurface,
              ),
            ),
          ],
        ),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onChanged(p),
        backgroundColor: cs.surfaceContainerHigh,
        selectedColor: color.withOpacity(.14),
        side: BorderSide(color: selected ? color : cs.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
      );
    }

    Color c(Priority p) => switch (p) {
      Priority.high => cs.error,
      Priority.medium => cs.tertiary,
      Priority.low => cs.primary,
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        pill(
          Priority.low,
          'Low',
          Icons.keyboard_arrow_down_rounded,
          c(Priority.low),
        ),
        pill(
          Priority.medium,
          'Medium',
          Icons.remove_rounded,
          c(Priority.medium),
        ),
        pill(
          Priority.high,
          'High',
          Icons.keyboard_arrow_up_rounded,
          c(Priority.high),
        ),
      ],
    );
  }
}
