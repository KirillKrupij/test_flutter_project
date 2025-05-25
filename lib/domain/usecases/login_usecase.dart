import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity?> execute(String email, String password) {
    return repository.login(email, password);
  }
}

// lib/domain/use_cases/register_use_case.dart
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity?> execute(String email, String password) {
    return repository.register(email, password);
  }
}

// lib/domain/use_cases/logout_use_case.dart
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute() {
    return repository.logout();
  }
}
