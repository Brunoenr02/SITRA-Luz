/// Configuración de conexión con el backend de Supabase para SITRA-Luz.
///
/// Para conectar la app a tu propia instancia de Supabase:
/// 1. Ve a https://supabase.com -> Tu Proyecto -> Project Settings -> API
/// 2. Copia la `Project URL` y la llave `anon public`.
/// 3. Pégalas en [supabaseUrl] y [supabaseAnonKey] a continuación.
class SupabaseConfig {
  SupabaseConfig._();

  /// URL base del proyecto Supabase (sin '/rest/v1' ni barra final '/')
  static const String supabaseUrl = 'https://nedeqnvpkalrchswrapr.supabase.co';

  /// Llave pública de acceso (Anon Public Key)
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lZGVxbnZwa2FscmNoc3dyYXByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk3NTExNDIsImV4cCI6MjEwNTMyNzE0Mn0.IUCvcd5GzlJTs-jbPVDWxT4rxO3y9p5YbMqvQ4QuPXk';

  /// Retorna la URL base limpia (removiendo automáticamente '/rest/v1' o '/' si se agregaron por error)
  static String get cleanUrl {
    var url = supabaseUrl.trim();
    if (url.endsWith('/rest/v1/')) {
      url = url.substring(0, url.length - '/rest/v1/'.length);
    } else if (url.endsWith('/rest/v1')) {
      url = url.substring(0, url.length - '/rest/v1'.length);
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Verifica si las credenciales de Supabase han sido personalizadas
  /// para decidir si conectar a la nube o usar el modo simulación (Mock).
  static bool get isConfigured {
    final url = cleanUrl;
    return url.isNotEmpty &&
        !url.contains('YOUR_PROJECT_REF') &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY');
  }
}
