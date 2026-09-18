/// Roles del sistema SITRA-Luz según requerimiento RF-002
enum UserRole {
  administrador,
  jefaturaFarmacia,
  farmacia,
  almacen,
  enfermeria,
}

/// Extensión para convertir el rol a String legible y viceversa
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.jefaturaFarmacia:
        return 'Jefatura de Farmacia';
      case UserRole.farmacia:
        return 'Farmacia';
      case UserRole.almacen:
        return 'Almacén';
      case UserRole.enfermeria:
        return 'Enfermería / Técnico';
    }
  }

  String get dbValue => supabaseValue;

  String get supabaseValue {
    switch (this) {
      case UserRole.administrador:
        return 'ADMINISTRADOR';
      case UserRole.jefaturaFarmacia:
        return 'JEFATURA_FARMACIA';
      case UserRole.farmacia:
        return 'FARMACIA';
      case UserRole.almacen:
        return 'ALMACEN';
      case UserRole.enfermeria:
        return 'ENFERMERIA';
    }
  }

  String get firestoreValue => supabaseValue;

  static UserRole fromDb(String value) => fromSupabase(value);

  static UserRole fromSupabase(String value) {
    switch (value.toUpperCase()) {
      case 'ADMINISTRADOR':
        return UserRole.administrador;
      case 'JEFATURA_FARMACIA':
        return UserRole.jefaturaFarmacia;
      case 'FARMACIA':
        return UserRole.farmacia;
      case 'ALMACEN':
        return UserRole.almacen;
      case 'ENFERMERIA':
        return UserRole.enfermeria;
      default:
        return UserRole.enfermeria;
    }
  }

  static UserRole fromFirestore(String value) => fromSupabase(value);
}

/// Entidad de dominio pura — no depende de ningún framework
class UserEntity {
  final String uid;
  final String nombre;
  final String email;
  final UserRole rol;
  final List<String> areasAsignadas;
  final bool activo;

  const UserEntity({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.areasAsignadas,
    required this.activo,
  });

  @override
  String toString() =>
      'UserEntity(uid: $uid, nombre: $nombre, rol: ${rol.firestoreValue})';
}
