import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatbytes/core/theme/app_color.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_event.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_state.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_card.dart';

enum _CalMode { month, day }

class CalendarSimplePage extends StatefulWidget {
  const CalendarSimplePage();

  @override
  State<CalendarSimplePage> createState() => CalendarSimplePageState();
}

class CalendarSimplePageState extends State<CalendarSimplePage> {
  _CalMode _mode = _CalMode.month;
  DateTime _focusedMonth = _dateOnly(DateTime.now());
  DateTime _selectedDay = _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _goPrevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      // keep selection within focused month range
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _goNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _goToday() {
    setState(() {
      final now = _dateOnly(DateTime.now());
      _focusedMonth = DateTime(now.year, now.month, 1);
      _selectedDay = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading || state is TaskInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TaskFailure) {
          return Center(child: Text(state.message));
        }
        final tasks = (state as TaskLoaded).tasks;

        // group tasks by date (dateOnly)
        final Map<DateTime, List<TaskEntity>> byDay = {};
        for (final t in tasks) {
          final key = _dateOnly(t.dueDate);
          (byDay[key] ??= []).add(t);
        }

        return Column(
          children: [
            const SizedBox(height: 8),
            // ---------- Header: month nav + mode switch ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HeaderBar(
                monthLabel: _monthLabel(_focusedMonth),
                onPrev: _goPrevMonth,
                onNext: _goNextMonth,
                onToday: _goToday,
                mode: _mode,
                onModeChanged: (m) => setState(() => _mode = m),
              ),
            ),

            // ---------- Weekday strip ----------
            if (_mode == _CalMode.month)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: _WeekdayStrip(),
              ),

            // ---------- Body ----------
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child:
                    _mode == _CalMode.month
                        ? _MonthGrid(
                          key: const ValueKey('month'),
                          month: _focusedMonth,
                          selected: _selectedDay,
                          onSelect:
                              (d) => setState(() {
                                _selectedDay = d;
                                _mode = _CalMode.day; // auto-jump to day view
                              }),
                          tasksByDay: byDay,
                        )
                        : _DayAgenda(
                          key: const ValueKey('day'),
                          day: _selectedDay,
                          tasks: byDay[_selectedDay] ?? const [],
                        ),
              ),
            ),

            // spacer so it never clashes with the stacked bottom bar
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// ========================= HEADER =========================

class _HeaderBar extends StatelessWidget {
  final String monthLabel;
  final VoidCallback onPrev, onNext, onToday;
  final _CalMode mode;
  final ValueChanged<_CalMode> onModeChanged;

  const _HeaderBar({
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Month nav + label
        InkWell(
          onTap: onPrev,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.chevron_left_rounded),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  monthLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(onPressed: onToday, child: const Text('Today')),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.chevron_right_rounded),
          ),
        ),
        const SizedBox(width: 8),

        // Mode segmented
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModeChip(
                label: 'Month',
                selected: mode == _CalMode.month,
                onTap: () => onModeChanged(_CalMode.month),
              ),
              _ModeChip(
                label: 'Day',
                selected: mode == _CalMode.day,
                onTap: () => onModeChanged(_CalMode.day),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withOpacity(.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ========================= WEEKDAY STRIP =========================

class _WeekdayStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(labels.length, (i) {
        return Expanded(
          child: Center(
            child: Text(
              labels[i],
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ========================= MONTH GRID =========================

class _MonthGrid extends StatelessWidget {
  final DateTime month; // any date in month (we use year/month)
  final DateTime selected;
  final Map<DateTime, List<TaskEntity>> tasksByDay;
  final ValueChanged<DateTime> onSelect;

  const _MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.tasksByDay,
    required this.onSelect,
  });

  DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final first = _firstOfMonth(month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Monday=1..Sunday=7 -> leading blanks from Monday
    final leading = (first.weekday + 6) % 7;

    // total cells to fill 6 rows * 7 cols
    final totalCells = 42;
    final startDate = first.subtract(Duration(days: leading));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisExtent: 72,
        ),
        itemCount: totalCells,
        itemBuilder: (_, i) {
          final day = startDate.add(Duration(days: i));
          final isThisMonth =
              day.month == month.month && day.year == month.year;
          final isToday = _dateOnly(day) == _dateOnly(DateTime.now());
          final isSelected = _dateOnly(day) == _dateOnly(selected);

          final entries = tasksByDay[_dateOnly(day)] ?? const <TaskEntity>[];

          Color border = Colors.transparent;
          Color bg = Colors.transparent;
          Color txt =
              isThisMonth ? cs.onSurface : cs.onSurfaceVariant.withOpacity(.6);

          if (isSelected) {
            border = AppColor.primary;
            bg = AppColor.primary.withOpacity(.10);
          }
          if (isToday && !isSelected) {
            border = cs.primary;
          }

          return Padding(
            padding: const EdgeInsets.all(4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelect(_dateOnly(day)),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // date number + today dot
                    Row(
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: txt,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _DotsRow(entries: entries),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DotsRow extends StatelessWidget {
  final List<TaskEntity> entries;
  const _DotsRow({required this.entries});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color colorFor(Priority p) => switch (p) {
      Priority.high => cs.error,
      Priority.medium => cs.tertiary,
      Priority.low => AppColor.primary,
    };

    // Show up to 4 dots; more condensed into last dot with plus if overflow.
    final dots = entries.take(4).toList();
    final overflow = entries.length - dots.length;

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        for (final t in dots)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorFor(t.priority),
              shape: BoxShape.circle,
            ),
          ),
        if (overflow > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: cs.outlineVariant.withOpacity(.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$overflow',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

// ========================= DAY AGENDA =========================

class _DayAgenda extends StatelessWidget {
  final DateTime day;
  final List<TaskEntity> tasks;
  const _DayAgenda({super.key, required this.day, required this.tasks});

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sorted = [...tasks]..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                _fmt(day),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${sorted.length} task${sorted.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),
        if (sorted.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No tasks on this day',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
              itemBuilder: (_, i) => _SwipeableTask(task: sorted[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: sorted.length,
            ),
          ),
      ],
    );
  }
}

class _SwipeableTask extends StatelessWidget {
  final TaskEntity task;
  const _SwipeableTask({required this.task});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget bg(Color c, AlignmentGeometry align, IconData icon, String label) {
      return Container(
        alignment: align,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: c,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return Dismissible(
      key: ValueKey('cal-task-${task.id}'),
      background: bg(
        cs.primary,
        Alignment.centerLeft,
        Icons.edit_rounded,
        'Edit',
      ),
      secondaryBackground: bg(
        cs.error,
        Alignment.centerRight,
        Icons.delete_rounded,
        'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // navigate to your edit route if available
          // context.push('/task/edit?id=${task.id}');
          return false;
        }
        return direction == DismissDirection.endToStart;
      },
      onDismissed: (_) {
        context.read<TaskBloc>().add(DeleteTaskPressed(task.id));
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed:
                  () => context.read<TaskBloc>().add(CreateTaskPressed(task)),
            ),
          ),
        );
      },
      child: TaskCard(task: task),
    );
  }
}
