import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthLoading()) {
    on<CheckAuthStatus>(_checkAuthStatus);
    on<LoginEvent>(_login);
    on<RegisterEvent>(_register);
    on<LogoutEvent>(_logout);
  }

  Future<void> _checkAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        emit(Authenticated(uid: user.uid, email: user.email ?? ''));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      if (user != null) {
        emit(Authenticated(uid: user.uid, email: user.email));
      } else {
        emit(AuthError('Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _register(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(event.email, event.password);
      if (user != null) {
        emit(Authenticated(uid: user.uid, email: user.email));
      } else {
        emit(AuthError('Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
