import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import 'firebase_auth_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Stream<UserEntity?> authState() => _ds.authState().map(
    (u) => u == null ? null : UserEntity(uid: u.uid, email: u.email),
  );

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final u = await _ds.signIn(email, password);
    return UserEntity(uid: u.uid, email: u.email);
  }

  @override
  Future<UserEntity> signUp(String email, String password) async {
    final u = await _ds.signUp(email, password);
    return UserEntity(uid: u.uid, email: u.email);
  }

  @override
  Future<void> signOut() => _ds.signOut();
}
