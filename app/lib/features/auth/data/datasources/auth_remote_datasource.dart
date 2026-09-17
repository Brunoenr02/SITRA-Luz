import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Excepción específica del módulo de autenticación
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Fuente de datos remota — interactúa directamente con Firebase Auth y Firestore.
/// Esta clase es la ÚNICA que conoce Firebase en la capa de datos.
class AuthRemoteDataSource {
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;

  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _customAuth = firebaseAuth,
        _customFirestore = firestore;

  FirebaseAuth get _firebaseAuth => _customAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _customFirestore ?? FirebaseFirestore.instance;

  /// Inicia sesión con email y contraseña usando Firebase Auth
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('No se pudo obtener el usuario autenticado.');
      }
      return await _getUserModel(firebaseUser.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  /// Cierra la sesión activa
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Obtiene el UserModel del usuario actualmente autenticado
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;
      return await _getUserModel(firebaseUser.uid);
    } catch (_) {
      return null;
    }
  }

  /// Stream de cambios en el estado de autenticación
  Stream<UserModel?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        try {
          return await _getUserModel(firebaseUser.uid);
        } catch (_) {
          return null;
        }
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Lee el documento del usuario en Firestore y lo convierte a UserModel
  Future<UserModel> _getUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw const AuthException(
        'Perfil de usuario no encontrado. Contacta al administrador.',
      );
    }
    final model = UserModel.fromFirestore(doc.data()!, uid);
    if (!model.activo) {
      throw const AuthException(
        'Tu cuenta está deshabilitada. Contacta al administrador.',
      );
    }
    return model;
  }

  /// Traduce los códigos de error de Firebase a mensajes amigables en español
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe ningún usuario con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta de nuevo más tarde.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      default:
        return 'Error de autenticación ($code). Inténtalo de nuevo.';
    }
  }
}
