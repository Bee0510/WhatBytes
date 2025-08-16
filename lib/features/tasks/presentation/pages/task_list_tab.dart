import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_event.dart';
import 'package:whatbytes/core/theme/app_color.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_event.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_state.dart';
import 'package:whatbytes/features/tasks/presentation/widgets/greeting.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_filter_cubit.dart';
import '../widgets/task_card.dart';

class TaskListTab extends StatelessWidget {
  const TaskListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLine = _formatDate(now); // e.g. “Today, 16 Aug”

    return NestedScrollView(
      headerSliverBuilder:
          (ctx, inner) => [
            // Blue header with title/date + search INSIDE it.
            SliverAppBar(
              pinned: true,
              centerTitle: true,
              backgroundColor: AppColor.primary,
              expandedHeight: MediaQuery.of(ctx).padding.top + 200,
              automaticallyImplyLeading: false,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),

              // Collapsed center title -> show TODAY’S DATE as you scroll
              title: _CollapsedCenterTitle(
                text: dateLine,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),

              flexibleSpace: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // inside the Row in your SliverAppBar flexibleSpace:
                          Builder(
                            builder:
                                (iconCtx) => InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap:
                                      () =>
                                          Scaffold.maybeOf(
                                            iconCtx,
                                          )?.openDrawer(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.grid_view_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                          ),

                          const Spacer(),
                          PopupMenuButton(
                            iconColor: Colors.white,
                            itemBuilder:
                                (_) => const [
                                  PopupMenuItem(
                                    value: 'logout',
                                    child: Text('Sign out'),
                                  ),
                                ],
                            onSelected: (v) {
                              if (v == 'logout')
                                ctx.read<AuthBloc>().add(SignOutRequested());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _FadeOutOnCollapse(
                        fadeStart: 0.0,
                        fadeEnd: 0.55,
                        offsetY: 10,
                        child: GreetingBanner(),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                  MediaQuery.of(context).padding.top + 68,
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _SearchBar(),
                ),
              ),
            ),
          ],
      body: const _TaskListBody(),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final today = DateTime.now();
    final isToday =
        d.year == today.year && d.month == today.month && d.day == today.day;
    final label =
        isToday ? 'Today' : '${d.day} ${months[d.month - 1]} ${d.year}';
    if (isToday) {
      return 'Today, ${d.day} ${months[d.month - 1]}';
    }
    return label;
  }
}

/// Shows its [text] only when the SliverAppBar is collapsed, using the
/// FlexibleSpaceBarSettings to compute collapse factor.
class _CollapsedCenterTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _CollapsedCenterTitle({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    double t = 0; // 0 expanded -> 1 collapsed
    if (settings != null) {
      final deltaExtent = settings.maxExtent - settings.minExtent;
      t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
          .clamp(0.0, 1.0);
    }
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: t,
      child: Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // initialize from current filter state, so it persists across rebuilds
    final q = context.read<TaskFilterCubit>().state.query;
    _ctrl.text = q;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<TaskFilterCubit>().setQuery(v);
    });
    setState(() {}); // to refresh clear button visibility
  }

  void _clear() {
    _debounce?.cancel();
    _ctrl.clear();
    context.read<TaskFilterCubit>().setQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasText = _ctrl.text.isNotEmpty;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        controller: _ctrl,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search tasks',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
          suffixIcon:
              hasText
                  ? IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _clear,
                  )
                  : null,
          contentPadding: const EdgeInsets.only(top: 10),
        ),
      ),
    );
  }
}

// ---------------- grouped list + swipe actions ----------------

class _TaskListBody extends StatelessWidget {
  const _TaskListBody();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is TaskLoading || state is TaskInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TaskFailure) {
          return Center(child: Text(state.message));
        }

        final tasks = (state as TaskLoaded).tasks;
        final filter = context.watch<TaskFilterCubit>().state;
        final q = filter.query;

        bool matchesQuery(TaskEntity t) {
          if (q.isEmpty) return true;
          final title = t.title.toLowerCase();
          final desc = (t.description ?? '').toLowerCase();
          return title.contains(q) || desc.contains(q);
        }

        final filtered =
            tasks.where((t) {
                final byStatus =
                    filter.completed == null || t.completed == filter.completed;
                final byPriority =
                    filter.priorities.isEmpty ||
                    filter.priorities.contains(t.priority);
                final byQuery = matchesQuery(t);
                return byStatus && byPriority && byQuery;
              }).toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

        // figure out if *any* filter is active
        final isFiltered =
            (filter.completed != null) ||
            filter.priorities.isNotEmpty ||
            filter.query.isNotEmpty;

        // group even if empty; we'll show sections only when non-empty
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final in7Days = today.add(const Duration(days: 7));

        final todayList = <TaskEntity>[];
        final tomorrowList = <TaskEntity>[];
        final weekList = <TaskEntity>[];
        final laterList = <TaskEntity>[];

        for (final t in filtered) {
          final d = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
          if (_isSameDay(d, today)) {
            todayList.add(t);
          } else if (_isSameDay(d, tomorrow)) {
            tomorrowList.add(t);
          } else if (d.isAfter(tomorrow) && !d.isAfter(in7Days)) {
            weekList.add(t);
          } else {
            laterList.add(t);
          }
        }

        List<Widget> section(String title, List<TaskEntity> items) {
          if (items.isEmpty) return [];
          return [
            _SectionHeader(title: title),
            ...items.map((task) => _SwipeableTask(task: task)),
            const SizedBox(height: 12),
          ];
        }

        // ✅ Always return the ListView with filters at the top.
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 140),
          children: [
            const SizedBox(height: 4),
            const _FilterRow(),
            const SizedBox(height: 8),

            if (filtered.isEmpty)
              _EmptyState(
                isFiltered: isFiltered,
                onClearFilters: () => context.read<TaskFilterCubit>().reset(),
                onCreate: () => GoRouter.of(context).push('/task/new'),
              )
            else ...[
              ...section('Today', todayList),
              ...section('Tomorrow', tomorrowList),
              ...section('This week', weekList),
              if (laterList.isNotEmpty) ...section('Later', laterList),
            ],
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onClearFilters;
  final VoidCallback onCreate;

  const _EmptyState({
    required this.isFiltered,
    required this.onClearFilters,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            isFiltered ? Icons.filter_alt_off_rounded : Icons.inbox_rounded,
            size: 40,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            isFiltered ? 'No tasks match your filters' : 'No tasks yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            isFiltered
                ? 'Try clearing filters to see more tasks.'
                : 'Tap the + button to create your first task.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isFiltered)
                OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Clear filters'),
                ),
              if (!isFiltered) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onCreate,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      AppColor.primary,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add task'),
                ),
              ],
            ],
          ),
        ],
      ),
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
      key: ValueKey('task-${task.id}'),
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
          GoRouter.of(context).push('/task/edit?id=${task.id}');
          return false; // don’t remove on edit swipe
        }
        return direction == DismissDirection.endToStart;
      },
      onDismissed: (_) {
        final deleted = task;
        context.read<TaskBloc>().add(DeleteTaskPressed(task.id));
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed:
                  () =>
                      context.read<TaskBloc>().add(CreateTaskPressed(deleted)),
            ),
          ),
        );
      },
      child: TaskCard(task: task),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TaskFilterCubit>();
    final s = cubit.state;

    // For live counts we read all tasks (if loaded).
    final taskState = context.watch<TaskBloc>().state;
    final allTasks = taskState is TaskLoaded ? taskState.tasks : <TaskEntity>[];

    return Column(
      children: [
        // --- Status segmented: All / Todo / Done ---
        _StatusSegmented(
          value: s.completed,
          onChanged: (v) => context.read<TaskFilterCubit>().setStatus(v),
        ),
        const SizedBox(height: 10),

        // --- Priority chips row + Reset ---
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _PriorityChips(
                  selected: s.priorities,
                  onToggle:
                      (p) => context.read<TaskFilterCubit>().togglePriority(p),
                  allTasks: allTasks,
                  statusFilter: s.completed,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------- STATUS SEGMENTED CONTROL ----------
class _StatusSegmented extends StatelessWidget {
  final bool? value; // null=All, false=Todo, true=Done
  final ValueChanged<bool?> onChanged;
  const _StatusSegmented({required this.value, required this.onChanged});

  int _indexOf(bool? v) => v == null ? 0 : (v ? 2 : 1);
  bool? _valueOf(int i) => i == 0 ? null : (i == 2 ? true : false);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labels = const ['All', 'Todo', 'Done'];
    final icons = const [
      Icons.filter_list_rounded,
      Icons.radio_button_unchecked,
      Icons.task_alt_rounded,
    ];
    final idx = _indexOf(value);

    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final pad = 4.0;
        final segments = 3;
        final segW = (width - pad * 2) / segments;

        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Stack(
            children: [
              // thumb
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: pad + segW * idx,
                top: pad,
                bottom: pad,
                width: segW,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColor.primary.withOpacity(.35),
                    ),
                  ),
                ),
              ),
              // taps
              Row(
                children: List.generate(segments, (i) {
                  final selected = i == idx;
                  final color =
                      selected ? AppColor.primary : cs.onSurfaceVariant;
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onChanged(_valueOf(i)),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons[i], size: 18, color: color),
                            const SizedBox(width: 6),
                            Text(
                              labels[i],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------- PRIORITY CHIPS WITH COUNTS ----------
class _PriorityChips extends StatelessWidget {
  final Set<Priority> selected;
  final ValueChanged<Priority> onToggle;
  final List<TaskEntity> allTasks;
  final bool? statusFilter;

  const _PriorityChips({
    required this.selected,
    required this.onToggle,
    required this.allTasks,
    required this.statusFilter,
  });

  int _countFor(Priority p) {
    return allTasks
        .where(
          (t) =>
              t.priority == p &&
              (statusFilter == null || t.completed == statusFilter),
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(Priority p, String label, IconData icon) {
      final isSel = selected.contains(p);
      final color = _priorityColor(cs, p);
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
          selected: isSel,
          onSelected: (_) => onToggle(p),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSel ? color : cs.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              _CountBadge(
                count: _countFor(p),
                color: isSel ? color : cs.outline,
              ),
            ],
          ),
          side: BorderSide(color: isSel ? color : cs.outlineVariant),
          selectedColor: color.withOpacity(.12),
          backgroundColor: cs.surfaceContainerHigh,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        chip(Priority.low, 'Low', Icons.keyboard_arrow_down_rounded),
        chip(Priority.medium, 'Medium', Icons.remove_rounded),
        chip(Priority.high, 'High', Icons.keyboard_arrow_up_rounded),
      ],
    );
  }

  Color _priorityColor(ColorScheme cs, Priority p) {
    switch (p) {
      case Priority.high:
        return cs.error;
      case Priority.medium:
        return cs.tertiary;
      case Priority.low:
        return AppColor.primary;
    }
  }
}

// ---------- tiny helpers ----------
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      margin: const EdgeInsets.only(left: 6),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _FadeOutOnCollapse extends StatelessWidget {
  final Widget child;
  final double fadeStart; // 0..1 (0 = fully expanded, 1 = fully collapsed)
  final double fadeEnd; // 0..1
  final double offsetY; // pixels to slide up while fading

  const _FadeOutOnCollapse({
    required this.child,
    this.fadeStart = 0.0,
    this.fadeEnd = 0.6,
    this.offsetY = 12,
  });

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    // If we can’t read collapse info, just show the child.
    if (settings == null) return child;

    final delta = settings.maxExtent - settings.minExtent;
    final t = (1.0 - (settings.currentExtent - settings.minExtent) / delta)
        .clamp(0.0, 1.0); // 0 expanded -> 1 collapsed

    // Map collapse t into 0..1 fade progress between fadeStart..fadeEnd
    final progress = ((t - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);
    final opacity = 1.0 - progress;
    final dy = -offsetY * progress; // slide up as it fades

    return Opacity(
      opacity: opacity,
      child: Transform.translate(offset: Offset(0, dy), child: child),
    );
  }
}
