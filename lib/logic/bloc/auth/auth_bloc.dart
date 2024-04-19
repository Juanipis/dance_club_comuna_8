import 'package:dance_club_comuna_8/logic/bloc/auth/auth_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_states.dart';
import 'package:dance_club_comuna_8/logic/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      bool isAuth = await authService.signInWithEmailAndPassword(
          event.email, event.password);
      if (isAuth) {
        emit(Authenticated(event.email));
      } else {
        emit(AuthError('Sign in failed'));
      }
    });

    on<SignOutRequested>((event, emit) async {
      await authService.signOut();
      emit(AuthInitial());
    });

    on<PasswordResetRequested>((event, emit) async {
      await authService.sendPasswordResetEmail(event.email);
    });
  }
}
