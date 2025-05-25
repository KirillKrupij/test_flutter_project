// lib/data/repositories/firebase_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firebase_datasource.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseDataSource _dataSource;

  FirebaseAuthRepository(this._dataSource);

  @override
  Future<UserEntity?> login(String email, String password) async {
    final User? user = await _dataSource.login(email, password);
    if (user != null) {
      return UserEntity(uid: user.uid, email: user.email ?? '');
    }
    return null;
  }

  @override
  Future<UserEntity?> register(String email, String password) async {
    final User? user = await _dataSource.register(email, password);
    if (user != null) {
      return UserEntity(uid: user.uid, email: user.email ?? '');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }

  @override
  Stream<UserEntity?> getAuthStateChanges() {
    return _dataSource.getAuthStateChanges().map((User? user) {
      if (user != null) {
        return UserEntity(uid: user.uid, email: user.email ?? '');
      }
      return null;
    });
  }
}
