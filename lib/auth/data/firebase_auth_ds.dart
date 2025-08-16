import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthDataSource {
  Stream<User?> authState();
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password);
  Future<void> signOut();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  FirebaseAuthDataSourceImpl(this._auth);

  @override
  Stream<User?> authState() => _auth.authStateChanges();

  @override
  Future<User> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  @override
  Future<User> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
