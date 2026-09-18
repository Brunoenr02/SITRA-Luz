import 'package:flutter_test/flutter_test.dart';
import 'package:sitra_luz/core/utils/input_sanitizer.dart';
import 'package:sitra_luz/core/utils/auth_input_validator.dart';
import 'package:sitra_luz/features/auth/domain/entities/user_entity.dart';
import 'package:sitra_luz/features/auth/domain/repositories/auth_repository.dart';
import 'package:sitra_luz/features/auth/presentation/states/auth_state.dart';
import 'package:sitra_luz/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// SpyRepository para verificar las invocaciones exactas al repositorio
class SpyAuthRepository implements AuthRepository {
  int repositoryInvocationsCount = 0;

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    repositoryInvocationsCount++;
    return const UserEntity(
      uid: 'spy-001',
      nombre: 'Spy User',
      email: 'spy@sitraluz.pe',
      rol: UserRole.administrador,
      areasAsignadas: [],
      activo: true,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Stream<UserEntity?> get authStateChanges => const Stream.empty();
}

void main() {
  group('EXAMEN PRÁCTICO TIPO 3 - ÍTEM 5: Pruebas de Limpieza (Sanitize) y Rechazo sin Invocación a Red', () {
    test('(a) Cadena con espacios, tabuladores y caracteres de control queda en la forma limpia definida', () {
      const dirtyInput = '  \t \r\n ADMIN@SITRALUZ.PE  \t  ';
      final cleanResult = InputSanitizer.sanitizeEmail(dirtyInput);

      expect(cleanResult, equals('admin@sitraluz.pe'));
      expect(cleanResult.contains(' '), isFalse);
      expect(cleanResult.contains('\t'), isFalse);
      expect(cleanResult.contains('\r'), isFalse);
      expect(cleanResult.contains('\n'), isFalse);
      print('✅ [TEST 5(a) PASADO]: Cadena sucia: "$dirtyInput" => Cadena limpia: "$cleanResult"');
    });

    test('(b) Entrada inválida (sin @ o contraseña corta) deja las invocaciones al repositorio en CERO (0 llamadas)', () async {
      final spyRepository = SpyAuthRepository();
      final viewModel = AuthViewModel(repository: spyRepository);
      await Future.delayed(Duration.zero);

      // Intento de login con correo inválido (sin '@') y contraseña muy corta
      await viewModel.login(
        email: 'correo_invalido_sin_arroba.pe',
        password: '123',
      );

      // 1. El estado del ViewModel debe ser un error de validación local
      expect(viewModel.state, isA<AuthStateError>());
      final errorState = viewModel.state as AuthStateError;
      expect(errorState.message, contains('@'));

      // 2. REQUISITO EXIGIDO: Las invocaciones al repositorio deben ser exactamente CERO (0)
      expect(spyRepository.repositoryInvocationsCount, equals(0));
      print('✅ [TEST 5(b) PASADO]: Validación falló localmente. Invocaciones al repositorio de red = 0. Error mostrado: "${errorState.message}".');
    });
  });
}
