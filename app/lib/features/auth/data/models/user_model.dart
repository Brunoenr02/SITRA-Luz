import '../../domain/entities/user_entity.dart';

/// DTO que mapea el documento de Firestore a la entidad de dominio.
/// Colección: /users/{uid}
class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final String rol; // almacena el valor raw de Firestore
  final List<String> areasAsignadas;
  final bool activo;

  const UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.areasAsignadas,
    required this.activo,
  });

  /// Construye un [UserModel] desde un documento de Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      nombre: data['nombre'] as String? ?? '',
      email: data['email'] as String? ?? '',
      rol: data['rol'] as String? ?? 'ENFERMERIA',
      areasAsignadas: List<String>.from(data['areasAsignadas'] ?? []),
      activo: data['activo'] as bool? ?? true,
    );
  }

  /// Convierte el modelo a un mapa para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'areasAsignadas': areasAsignadas,
      'activo': activo,
    };
  }

  /// Convierte el DTO a la entidad pura de dominio
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      nombre: nombre,
      email: email,
      rol: UserRoleExtension.fromFirestore(rol),
      areasAsignadas: areasAsignadas,
      activo: activo,
    );
  }
}
