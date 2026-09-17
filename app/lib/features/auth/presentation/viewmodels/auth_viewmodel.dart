import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../states/auth_state.dart';

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

  /// Inicia sesión con email y contraseña
  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _setState(const AuthStateError('Por favor completa todos los campos.'));
      return;
    }
    _setState(const AuthStateLoading());
    try {
      final user = await _repository.login(email: email, password: password);
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
