import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import 'mock_auth_repository.dart';

/// Implementación concreta del [AuthRepository] que usa Firebase.
/// La capa de dominio solo conoce la interfaz, no esta clase.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final MockAuthRepository _mockFallback = MockAuthRepository();

  AuthRepositoryImpl({required AuthRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final isDemoAccount =
        MockAuthRepository.demoUsers.any((u) => u.email == cleanEmail);

    if (isDemoAccount) {
      try {
        final userModel = await _dataSource.login(email: email, password: password);
        return userModel.toEntity();
      } catch (_) {
        // Si aún no está creado en la nube de Firebase, responde con el usuario demo
        return await _mockFallback.login(email: email, password: password);
      }
    }

    final userModel = await _dataSource.login(email: email, password: password);
    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = await _dataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges.map((model) => model?.toEntity());
  }
}
