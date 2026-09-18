/// Excepción lanzada cuando los datos de entrada no superan la validación previa a la red.
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => message;
}

/// Reglas de validación de negocio antes de realizar llamadas de red (HTTP/Supabase).
/// Clase pura de Dart sin dependencias de paquetes de interfaz gráfica (UI) ni bibliotecas HTTP.
class AuthInputValidator {
  AuthInputValidator._();

  /// Comprueba la validez del formato de correo electrónico.
  /// Regla de producto SITRA-Luz: Debe ser no vacío, contener '@' y un dominio válido.
  static void validateEmail(String cleanEmail) {
    if (cleanEmail.isEmpty) {
      throw const ValidationException('El correo electrónico no puede estar vacío.');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      throw const ValidationException(
        'Formato de correo inválido. Debe incluir un @ y un dominio válido (ej. usuario@sitraluz.pe).',
      );
    }
  }

  /// Comprueba la validez de la contraseña antes de llamar a la red.
  /// Regla de producto SITRA-Luz: Debe ser no vacía y tener al menos 6 caracteres.
  static void validatePassword(String password) {
    if (password.isEmpty) {
      throw const ValidationException('La contraseña no puede estar vacía.');
    }
    if (password.length < 6) {
      throw const ValidationException(
        'La contraseña es demasiado corta. Debe contener al menos 6 caracteres.',
      );
    }
  }
}
