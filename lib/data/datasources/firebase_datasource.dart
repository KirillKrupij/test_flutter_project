import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<User?> register(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Stream<User?> getAuthStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
