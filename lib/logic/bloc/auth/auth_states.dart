abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String user;

  Authenticated(this.user);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class NotAuthenticated extends AuthState {
  final String message = 'No tienes permiso para ver este contenido.';

  NotAuthenticated();
}
