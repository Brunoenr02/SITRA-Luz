import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../states/auth_state.dart';

import '../../../../core/utils/input_sanitizer.dart';
import '../../../../core/utils/auth_input_validator.dart';

/// ViewModel del módulo de autenticación.
/// Implementa [ChangeNotifier] para notificar a la UI.
/// No importa nada de Firebase directamente — usa [AuthRepository].
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = const AuthStateInitial();
  AuthState get state => _state;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  AuthViewModel({required AuthRepository repository})
      : _repository = repository {
    _checkCurrentSession();
  }

  /// Verifica si hay una sesión activa al iniciar la app
  Future<void> _checkCurrentSession() async {
    _setState(const AuthStateLoading());
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _setState(AuthStateAuthenticated(user));
      } else {
        _setState(const AuthStateUnauthenticated());
      }
    } catch (_) {
      _setState(const AuthStateUnauthenticated());
    }
  }

  /// Inicia sesión con email y contraseña.
  /// Implementa limpieza (sanitize) y validación previa a la red (validate).
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // 1. Limpieza de datos (Item 2)
    final cleanEmail = InputSanitizer.sanitizeEmail(email);
    final cleanPassword = InputSanitizer.sanitize(password);

    // 2. Validación antes de la red (Item 3)
    try {
      AuthInputValidator.validateEmail(cleanEmail);
      AuthInputValidator.validatePassword(cleanPassword);
    } on ValidationException catch (e) {
      // SE NIEGA A LLAMAR AL REPOSITORIO SI LA VALIDACIÓN PREVIA FALLA
      _setState(AuthStateError(e.message));
      return;
    }

    // 3. Invocación a la red/repositorio (Sólo si superó las validaciones locales)
    _setState(const AuthStateLoading());
    try {
      final user = await _repository.login(
        email: cleanEmail,
        password: cleanPassword,
      );
      _currentUser = user;
      _setState(AuthStateAuthenticated(user));
    } on AuthException catch (e) {
      _setState(AuthStateError(e.message));
    } catch (e) {
      _setState(AuthStateError('Error inesperado. Inténtalo de nuevo.'));
    }
  }

  /// Cierra la sesión actual
  Future<void> logout() async {
    _setState(const AuthStateLoading());
    try {
      await _repository.logout();
      _currentUser = null;
      _setState(const AuthStateUnauthenticated());
    } catch (e) {
      _setState(AuthStateError('No se pudo cerrar la sesión. Inténtalo de nuevo.'));
    }
  }

  /// Limpia un error anterior para permitir reintentar
  void clearError() {
    if (_state is AuthStateError) {
      _setState(const AuthStateInitial());
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
