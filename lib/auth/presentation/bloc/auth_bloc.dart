import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_event.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_state.dart';
import '../../domain/auth_repository.dart';
import '../../domain/user_entity.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  AuthBloc(this._repo, AuthRepository repoEcho) : super(AuthLoading()) {
    on<AuthStarted>((event, emit) async {
      await emit.forEach<UserEntity?>(
        _repo.authState(),
        onData:
            (user) => user == null ? Unauthenticated() : Authenticated(user),
        onError: (e, st) => AuthFailure(e.toString()),
      );
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _repo.signIn(event.email, event.password);
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
        // emit(Unauthenticated());
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _repo.signUp(event.email, event.password);
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
        print('Sign up failed: $e');
        // emit(Unauthenticated());
      }
    });

    on<SignOutRequested>((event, emit) async {
      await _repo.signOut();
      emit(Unauthenticated());
    });
  }
}
