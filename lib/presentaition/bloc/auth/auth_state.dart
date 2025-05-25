part of 'auth_bloc.dart';

abstract class AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final String uid;
  final String email;

  Authenticated({required this.uid, required this.email});
}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
