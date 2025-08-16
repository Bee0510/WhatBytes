import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_state.dart';
import 'package:whatbytes/auth/presentation/pages/get_started.dart';
import 'package:whatbytes/features/tasks/presentation/pages/task_home_page.dart';
import 'package:whatbytes/splash/presentation/splash.dart';

import 'auth/presentation/pages/login_page.dart';
import 'auth/presentation/pages/register_page.dart';
import 'features/tasks/presentation/pages/task_editor_page.dart';
import 'auth/presentation/bloc/auth_bloc.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, st) {
          final auth = ctx.watch<AuthBloc>().state;
          if (auth is Authenticated) return const TaskHomePage();
          if (auth is Unauthenticated || auth is AuthFailure) {
            return const GetStartedPage();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/get-started', builder: (_, __) => const GetStartedPage()),
      GoRoute(path: '/login', builder: (ctx, st) => const LoginPage()),
      GoRoute(path: '/register', builder: (ctx, st) => const RegisterPage()),
      GoRoute(path: '/task/new', builder: (ctx, st) => const TaskEditorPage()),
      GoRoute(
        path: '/task/edit',
        builder: (ctx, st) {
          final id = st.uri.queryParameters['id'];
          return TaskEditorPage(taskId: id);
        },
      ),
    ],
  );
}
