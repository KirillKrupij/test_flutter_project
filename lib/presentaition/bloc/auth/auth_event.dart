part of 'auth_bloc.dart';

// lib/features/auth/bloc/auth_event.dart
abstract class AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;

  RegisterEvent({required this.email, required this.password});
}

class LogoutEvent extends AuthEvent {}
