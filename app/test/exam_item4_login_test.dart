import 'package:flutter_test/flutter_test.dart';
import 'package:sitra_luz/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sitra_luz/features/auth/domain/entities/user_entity.dart';
import 'package:sitra_luz/features/auth/domain/repositories/auth_repository.dart';
import 'package:sitra_luz/features/auth/presentation/states/auth_state.dart';
import 'package:sitra_luz/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Repository Mock para pruebas unitarias de Login sin red real ni emulador (Examen Tipo 3 - Ítem 4)
class FakeAuthRepository implements AuthRepository {
  UserEntity? mockSessionUser;
  int loginCallCount = 0;
  bool rejectLogin = false;

  @override
  Future<UserEntity?> getCurrentUser() async {
    return mockSessionUser;
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    if (rejectLogin) {
      throw const AuthException('Correo o contraseña incorrectos.');
    }
    return UserEntity(
      uid: 'usr-exam-001',
      nombre: 'Lic. Ana Morales',
      email: email,
      rol: UserRole.administrador,
      areasAsignadas: const ['UCI Adultos', 'Emergencia'],
      activo: true,
    );
  }

  @override
  Future<void> logout() async {
    mockSessionUser = null;
  }

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(mockSessionUser);
}

void main() {
  group('EXAMEN PRÁCTICO TIPO 3 - ÍTEM 4: Pruebas de Login y Carga de Entidad', () {
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
    });

    test('(a) Al arrancar no hay sesión: ViewModel inicia en estado Unauthenticated o Initial sin usuario cargado', () async {
      repository.mockSessionUser = null;

      final viewModel = AuthViewModel(repository: repository);
      await Future.delayed(Duration.zero);

      expect(viewModel.currentUser, isNull);
      expect(viewModel.state, isA<AuthStateUnauthenticated>());
      print('✅ [TEST (a) PASADO]: Al arrancar no hay sesión activa. currentUser = null.');
    });

    test('(b) Login correcto y su entidad queda cargada con datos reales del producto', () async {
      repository.mockSessionUser = null;
      repository.rejectLogin = false;

      final viewModel = AuthViewModel(repository: repository);
      await Future.delayed(Duration.zero);

      await viewModel.login(
        email: '  admin@sitraluz.pe \t ',
        password: 'admin123password',
      );

      expect(viewModel.currentUser, isNotNull);
      expect(viewModel.currentUser!.email, equals('admin@sitraluz.pe'));
      expect(viewModel.currentUser!.rol, equals(UserRole.administrador));
      expect(viewModel.state, isA<AuthStateAuthenticated>());
      expect(repository.loginCallCount, equals(1));
      print('✅ [TEST (b) PASADO]: Login exitoso. Entidad cargada: ${viewModel.currentUser}');
    });

    test('(c) Login rechazado: error sin segundo intento (1 sola llamada al repositorio)', () async {
      repository.mockSessionUser = null;
      repository.rejectLogin = true; // Simular rechazo de credenciales

      final viewModel = AuthViewModel(repository: repository);
      await Future.delayed(Duration.zero);

      await viewModel.login(
        email: 'usuario.inexistente@sitraluz.pe',
        password: 'passwordIncorrecta123',
      );

      expect(viewModel.currentUser, isNull);
      expect(viewModel.state, isA<AuthStateError>());
      final errorState = viewModel.state as AuthStateError;
      expect(errorState.message, contains('Correo o contraseña incorrectos'));
      expect(repository.loginCallCount, equals(1)); // Sin segundo intento
      print('✅ [TEST (c) PASADO]: Login rechazado correctamente. Invocaciones al repositorio = 1 (Sin segundo intento). Error: "${errorState.message}".');
    });
  });
}
