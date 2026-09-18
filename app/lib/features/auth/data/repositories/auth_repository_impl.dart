import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación de producción de [AuthRepository] que autentica
/// exclusivamente contra la base de datos y sistema de usuarios de Supabase.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required AuthLocalDataSource localDataSource,
  }) : _dataSource = dataSource,
       _localDataSource = localDataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    // Autenticación estricta y directa contra Supabase (Auth + profiles)
    final userModel = await _dataSource.login(email: email, password: password);
    final user = userModel.toEntity();
    await _localDataSource.saveSession(user);
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } finally {
      await _localDataSource.clearSession();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final localUser = _localDataSource.readSession();
    if (localUser != null) return localUser;

    final userModel = await _dataSource.getCurrentUser();
    final user = userModel?.toEntity();
    if (user != null) await _localDataSource.saveSession(user);
    return user;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges.map((model) => model?.toEntity());
  }
}
