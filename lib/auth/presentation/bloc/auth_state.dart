import 'package:equatable/equatable.dart';
import 'package:whatbytes/auth/domain/user_entity.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  Authenticated(this.user);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
