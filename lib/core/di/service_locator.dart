import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/data/firebase_auth_ds.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/data/auth_repository_impl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../features/tasks/data/datasources/task_local_ds.dart';
import '../../../features/tasks/data/datasources/task_remote_ds.dart';
import '../../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../../features/tasks/domain/repositories/task_repository.dart';
import '../../../features/tasks/domain/usecases/create_task.dart';
import '../../../features/tasks/domain/usecases/delete_task.dart';
import '../../../features/tasks/domain/usecases/update_task.dart';
import '../../../features/tasks/domain/usecases/watch_tasks.dart';
import '../../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../../features/tasks/presentation/bloc/task_filter_cubit.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  if (sl.isRegistered<FirebaseAuth>()) return;

  await Hive.initFlutter();

  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Auth
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => AuthBloc(sl(), sl()));

  // Tasks
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => WatchTasks(sl()));

  sl.registerFactory(() => TaskBloc(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => TaskFilterCubit());
}
