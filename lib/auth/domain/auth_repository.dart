import 'user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authState();
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(String email, String password);
  Future<void> signOut();
}
