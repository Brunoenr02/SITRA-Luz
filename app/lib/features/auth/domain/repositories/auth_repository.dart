import '../entities/user_entity.dart';

/// Contrato abstracto del repositorio de autenticación.
/// La capa de presentación NUNCA depende de la implementación concreta.
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña.
  /// Retorna el [UserEntity] del usuario autenticado.
  /// Lanza [AuthException] si las credenciales son inválidas.
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Cierra la sesión activa.
  Future<void> logout();

  /// Retorna el usuario actualmente autenticado, o null si no hay sesión.
  Future<UserEntity?> getCurrentUser();

  /// Stream que emite el usuario actual cada vez que cambia el estado de auth.
  Stream<UserEntity?> get authStateChanges;
}
