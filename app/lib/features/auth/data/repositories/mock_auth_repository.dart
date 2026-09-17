import 'dart:async';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Repositorio de autenticación simulado (Mock / Offline)
/// Proporciona acceso rápido a los 5 roles del sistema SITRA-Luz para pruebas inmediatas,
/// permitiendo validar el flujo de pantallas por rol incluso antes de configurar Firebase.
class MockAuthRepository implements AuthRepository {
  static final List<UserEntity> _demoUsers = [
    const UserEntity(
      uid: 'uid-admin-01',
      nombre: 'Ing. Carlos Mendoza',
      email: 'admin@sitraluz.pe',
      rol: UserRole.administrador,
      areasAsignadas: ['Sistemas', 'Dirección General', 'Auditoría'],
      activo: true,
    ),
    const UserEntity(
      uid: 'uid-jefatura-01',
      nombre: 'Dra. Elena Ramos',
      email: 'jefatura@sitraluz.pe',
      rol: UserRole.jefaturaFarmacia,
      areasAsignadas: ['Farmacia Central', 'Comité Farmacológico'],
      activo: true,
    ),
    const UserEntity(
      uid: 'uid-farmacia-01',
      nombre: 'Q.F. Manuel Flores',
      email: 'farmacia@sitraluz.pe',
      rol: UserRole.farmacia,
      areasAsignadas: ['Farmacia Central', 'Dispensación Ambulatoria / Hospitalaria'],
      activo: true,
    ),
    const UserEntity(
      uid: 'uid-almacen-01',
      nombre: 'Sr. Roberto Paredes',
      email: 'almacen@sitraluz.pe',
      rol: UserRole.almacen,
      areasAsignadas: ['Almacén General', 'Recepción de Mercadería'],
      activo: true,
    ),
    const UserEntity(
      uid: 'uid-enfermeria-01',
      nombre: 'Lic. Ana Morales',
      email: 'enfermeria@sitraluz.pe',
      rol: UserRole.enfermeria,
      areasAsignadas: ['UCI Adultos', 'Pabellón Cirugía'],
      activo: true,
    ),
  ];

  static final Map<String, String> _credentials = {
    'admin@sitraluz.pe': 'admin123',
    'jefatura@sitraluz.pe': 'jefe123',
    'farmacia@sitraluz.pe': 'farma123',
    'almacen@sitraluz.pe': 'almacen123',
    'enfermeria@sitraluz.pe': 'enfermera123',
  };

  UserEntity? _currentUser;
  final _controller = StreamController<UserEntity?>.broadcast();

  static List<UserEntity> get demoUsers => _demoUsers;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanEmail = email.trim().toLowerCase();
    final expectedPassword = _credentials[cleanEmail];

    // Permitir cualquier contraseña válida si coincide o contraseña maestra para demo
    if (expectedPassword != null &&
        (password == expectedPassword || password == '123456')) {
      final user = _demoUsers.firstWhere((u) => u.email == cleanEmail);
      _currentUser = user;
      _controller.add(user);
      return user;
    }

    // Si el correo no está registrado en los demos
    final userMatch = _demoUsers.where((u) => u.email == cleanEmail).toList();
    if (userMatch.isEmpty) {
      throw const AuthException(
        'No existe ningún usuario con este correo en el sistema SITRA-Luz.',
      );
    } else {
      throw const AuthException('Contraseña incorrecta. Inténtalo de nuevo.');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;
}
