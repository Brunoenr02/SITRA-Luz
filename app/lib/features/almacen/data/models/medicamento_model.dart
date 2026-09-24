import '../../domain/entities/medicamento_entity.dart';

/// Modelo de datos para Medicamento (mapeo con PostgreSQL / Supabase)
class MedicamentoModel extends MedicamentoEntity {
  const MedicamentoModel({
    required super.id,
    required super.gtin,
    required super.nombreComercial,
    required super.principioActivo,
    required super.formaFarmaceutica,
    required super.concentracion,
    super.registroSanitario,
    super.unidadPresentacion,
    super.cantidadPorPresentacion,
    super.requiereCadenaFrio,
    super.temperaturaMin,
    super.temperaturaMax,
    super.activo,
  });

  factory MedicamentoModel.fromMap(Map<String, dynamic> map) {
    return MedicamentoModel(
      id: map['id']?.toString() ?? '',
      gtin: map['gtin']?.toString() ?? '',
      nombreComercial: map['nombre_comercial']?.toString() ?? '',
      principioActivo: map['principio_activo']?.toString() ?? '',
      formaFarmaceutica: map['forma_farmaceutica']?.toString() ?? '',
      concentracion: map['concentracion']?.toString() ?? '',
      registroSanitario: map['registro_sanitario']?.toString(),
      unidadPresentacion: map['unidad_presentacion']?.toString() ?? 'unidad',
      cantidadPorPresentacion: (map['cantidad_por_presentacion'] as num?)?.toInt() ?? 1,
      requiereCadenaFrio: map['requiere_cadena_frio'] as bool? ?? false,
      temperaturaMin: (map['temperatura_min'] as num?)?.toDouble() ?? 2.0,
      temperaturaMax: (map['temperatura_max'] as num?)?.toDouble() ?? 8.0,
      activo: map['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gtin': gtin.trim(),
      'nombre_comercial': nombreComercial.trim(),
      'principio_activo': principioActivo.trim(),
      'forma_farmaceutica': formaFarmaceutica.trim(),
      'concentracion': concentracion.trim(),
      if (registroSanitario != null && registroSanitario!.isNotEmpty)
        'registro_sanitario': registroSanitario!.trim(),
      'unidad_presentacion': unidadPresentacion.trim(),
      'cantidad_por_presentacion': cantidadPorPresentacion,
      'requiere_cadena_frio': requiereCadenaFrio,
      'temperatura_min': temperaturaMin,
      'temperatura_max': temperaturaMax,
      'activo': activo,
    };
  }
}
