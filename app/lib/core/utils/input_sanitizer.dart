/// Clase utilitaria pura de Dart (sin dependencias de UI de Flutter ni paquetes HTTP)
/// encargada de la limpieza y desinfección de datos de entrada (sanitize).
class InputSanitizer {
  InputSanitizer._();

  /// Limpia una cadena de texto:
  /// 1. Elimina caracteres de control ASCII (0x00-0x1F y 0x7F) como \r, \n, \t
  /// 2. Reemplaza múltiples espacios en blanco o tabulaciones consecutivas por un solo espacio
  /// 3. Elimina espacios en blanco de los bordes inicio/fin (trim)
  static String sanitize(String input) {
    if (input.isEmpty) return '';

    // Remover caracteres de control invisibles
    final noControlChars = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Reemplazar espacios y tabulaciones múltiples por un solo espacio
    final singleSpaced = noControlChars.replaceAll(RegExp(r'\s+'), ' ');

    // Eliminar espacios de los bordes
    return singleSpaced.trim();
  }

  /// Limpia específicamente un correo electrónico:
  /// Aplica la desinfección de espacios/caracteres de control y convierte a minúsculas.
  static String sanitizeEmail(String email) {
    return sanitize(email).toLowerCase();
  }
}
