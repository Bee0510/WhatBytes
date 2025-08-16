import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_state.dart';
import 'package:whatbytes/core/theme/app_color.dart';
import 'package:whatbytes/features/tasks/presentation/bloc/task_event.dart';
import 'package:whatbytes/features/tasks/presentation/pages/calender.dart';
import 'package:whatbytes/features/tasks/presentation/pages/task_list_tab.dart';
import 'package:whatbytes/features/tasks/presentation/widgets/app_drawer.dart';

import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/task_bloc.dart';

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) {
      context.read<TaskBloc>().add(LoadTasks(auth.user.uid));
    }
  }

  PreferredSizeWidget? _maybeCalendarAppBar(BuildContext context) {
    if (_index != 1)
      return null; // no app bar on Tasks; SliverAppBar lives inside
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: const Text('Calendar'),
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      appBar: _maybeCalendarAppBar(context),
      drawer: const AccountDrawer(),
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // main content
          Positioned.fill(
            child: IndexedStack(
              index: _index,
              children: const [TaskListTab(), CalendarSimplePage()],
            ),
          ),

          // bottom nav
          Positioned(
            left: 16,
            right: 16,
            bottom: 12 + bottom,
            child: _StackedNavBar(
              index: _index,
              onTap: (i) => setState(() => _index = i),
            ),
          ),

          // center action (create)
          Positioned(
            bottom: 36 + bottom,
            left: 0,
            right: 0,
            child: Center(
              child: _CenterActionButton(
                onPressed: () => context.push('/task/new'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _StackedNavBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: _NavIcon(
              icon: Icons.list,
              label: 'Tasks',
              selected: index == 0,
              onTap: () => onTap(0),
            ),
          ),
          const SizedBox(width: 72), // gap under the center button
          Expanded(
            child: _NavIcon(
              icon: Icons.calendar_month_rounded,
              label: 'Calendar',
              selected: index == 1,
              onTap: () => onTap(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CenterActionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColor.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.edit_outlined, color: Colors.white, size: 28),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? AppColor.primary : cs.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
