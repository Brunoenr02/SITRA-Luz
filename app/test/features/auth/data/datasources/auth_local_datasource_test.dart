import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitra_luz/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sitra_luz/features/auth/domain/entities/user_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = UserEntity(
    uid: 'usuario-01',
    nombre: 'Usuario de prueba',
    email: 'usuario@sitraluz.pe',
    rol: UserRole.farmacia,
    areasAsignadas: ['Farmacia Central'],
    activo: true,
  );

  test('guarda y restaura una sesión local', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final dataSource = AuthLocalDataSource(preferences: preferences);

    await dataSource.saveSession(user);
    final restoredUser = dataSource.readSession();

    expect(restoredUser?.uid, user.uid);
    expect(restoredUser?.nombre, user.nombre);
    expect(restoredUser?.rol, user.rol);
    expect(restoredUser?.areasAsignadas, user.areasAsignadas);
  });

  test('un JSON local corrupto no rompe la aplicación', () async {
    SharedPreferences.setMockInitialValues({
      'auth_user_id': 'usuario-01',
      'auth_user_profile': '{json-incompleto',
    });
    final preferences = await SharedPreferences.getInstance();
    final dataSource = AuthLocalDataSource(preferences: preferences);

    expect(dataSource.readSession(), isNull);
  });

  test('elimina la sesión al cerrar sesión', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final dataSource = AuthLocalDataSource(preferences: preferences);

    await dataSource.saveSession(user);
    await dataSource.clearSession();

    expect(dataSource.readSession(), isNull);
  });
}
