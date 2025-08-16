import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_event.dart';
import 'package:whatbytes/core/network/internet_cubit.dart';
import 'package:whatbytes/firebase_options.dart';
import 'core/di/service_locator.dart';
import 'router.dart';
import 'auth/presentation/bloc/auth_bloc.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/bloc/task_filter_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDI();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final sl = GetIt.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthStarted())),
        BlocProvider(create: (_) => sl<TaskBloc>()),
        BlocProvider(create: (_) => sl<TaskFilterCubit>()),
        BlocProvider(create: (_) => InternetCubit()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.light,
        ),
        routerConfig: buildRouter(),
      ),
    );
  }
}
