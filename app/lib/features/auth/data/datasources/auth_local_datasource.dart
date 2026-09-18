import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_entity.dart';

/// Persiste la sesión mínima necesaria para restaurar el usuario al arrancar.
class AuthLocalDataSource {
  static const _userIdKey = 'auth_user_id';
  static const _userProfileKey = 'auth_user_profile';

  final SharedPreferences _preferences;

  AuthLocalDataSource({required SharedPreferences preferences})
    : _preferences = preferences;

  Future<void> saveSession(UserEntity user) async {
    final profile = jsonEncode({
      'uid': user.uid,
      'nombre': user.nombre,
      'email': user.email,
      'rol': user.rol.supabaseValue,
      'areasAsignadas': user.areasAsignadas,
      'activo': user.activo,
    });

    await _preferences.setString(_userIdKey, user.uid);
    await _preferences.setString(_userProfileKey, profile);
  }

  UserEntity? readSession() {
    final storedId = _preferences.getString(_userIdKey);
    final storedProfile = _preferences.getString(_userProfileKey);

    if (storedId == null ||
        storedId.trim().isEmpty ||
        storedProfile == null ||
        storedProfile.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(storedProfile);
      if (decoded is! Map<String, dynamic>) return null;

      final uid = decoded['uid'];
      final nombre = decoded['nombre'];
      final email = decoded['email'];
      final rol = decoded['rol'];
      final rawAreas = decoded['areasAsignadas'];

      if (uid is! String ||
          uid != storedId ||
          nombre is! String ||
          email is! String ||
          rol is! String ||
          rawAreas is! List) {
        return null;
      }

      return UserEntity(
        uid: uid,
        nombre: nombre,
        email: email,
        rol: UserRoleExtension.fromSupabase(rol),
        areasAsignadas: rawAreas.whereType<String>().toList(),
        activo: decoded['activo'] is bool ? decoded['activo'] as bool : true,
      );
    } on FormatException catch (error) {
      debugPrint('Sesión local ignorada porque el JSON no es válido: $error');
      return null;
    } catch (error) {
      debugPrint('No se pudo leer la sesión local: $error');
      return null;
    }
  }

  Future<void> clearSession() async {
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userProfileKey);
  }
}
