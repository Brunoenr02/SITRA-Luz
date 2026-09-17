import '../../domain/entities/user_entity.dart';

/// Estados posibles de la pantalla de login
sealed class AuthState {
  const AuthState();
}

/// Estado inicial — el usuario aún no ha interactuado
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Cargando — se está verificando credenciales o el estado de sesión
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// Autenticado — login exitoso con el usuario cargado
class AuthStateAuthenticated extends AuthState {
  final UserEntity user;
  const AuthStateAuthenticated(this.user);
}

/// No autenticado — no hay sesión activa
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// Error — login fallido con mensaje de error
class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}
