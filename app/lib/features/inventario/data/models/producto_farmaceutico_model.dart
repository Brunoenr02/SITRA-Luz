import '../../domain/entities/producto_farmaceutico_entity.dart';

class ProductoFarmaceuticoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String laboratorio;
  final bool requiereReceta;
  final List<String> etiquetas;
  final String precioCentimos;

  const ProductoFarmaceuticoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.laboratorio,
    required this.requiereReceta,
    required this.etiquetas,
    required this.precioCentimos,
  });

  /// Convierte un payload sin perder precisión en identificadores ni dinero.
  factory ProductoFarmaceuticoModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    if (rawId == null) {
      throw const FormatException('El identificador del producto es obligatorio.');
    }

    // Conversión directa a texto: nunca pasa por int, Long o double.
    final safeId = rawId is String ? rawId : rawId.toString();
    if (safeId.trim().isEmpty) {
      throw const FormatException('El identificador del producto no es válido.');
    }

    return ProductoFarmaceuticoModel(
      id: safeId,
      // Los campos opcionales nulos, ausentes o con otro tipo reciben un valor
      // seguro. Solo se leen claves conocidas; cualquier clave extra del JSON
      // se ignora silenciosamente al no participar en este constructor.
      nombre: _readOptionalString(json['nombre']),
      descripcion: _readOptionalString(json['descripcion']),
      laboratorio: _readOptionalString(json['laboratorio']),
      requiereReceta: _readOptionalBool(json['requiere_receta']),
      etiquetas: _readOptionalStringList(json['etiquetas']),
      precioCentimos: _readPriceInCents(json),
    );
  }

  static String _readOptionalString(dynamic value) {
    return value is String ? value : '';
  }

  static bool _readOptionalBool(dynamic value) {
    return value is bool ? value : false;
  }

  static List<String> _readOptionalStringList(dynamic value) {
    if (value is! List) return const [];
    return List<String>.unmodifiable(value.whereType<String>());
  }

  static String _readPriceInCents(Map<String, dynamic> json) {
    final rawCents = json['precio_centimos'];
    if (rawCents != null) {
      return _normalizeIntegerText(rawCents.toString());
    }

    final rawPrice = json['precio'];
    if (rawPrice == null) {
      throw const FormatException('El precio del producto es obligatorio.');
    }

    // El valor se procesa como caracteres; no se realizan operaciones de
    // punto flotante que puedan redondear o alterar un monto económico.
    return _decimalTextToCents(rawPrice.toString());
  }

  static String _decimalTextToCents(String value) {
    final match = RegExp(r'^(\d+)(?:[\.,](\d{1,2}))?$').firstMatch(value.trim());
    if (match == null) {
      throw const FormatException(
        'El precio debe ser positivo y tener como máximo dos decimales.',
      );
    }

    final wholePart = _removeLeadingZeros(match.group(1)!);
    final decimalPart = (match.group(2) ?? '').padRight(2, '0');
    return _removeLeadingZeros('$wholePart$decimalPart');
  }

  static String _normalizeIntegerText(String value) {
    final trimmed = value.trim();
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      throw const FormatException(
        'El precio en céntimos debe contener únicamente dígitos.',
      );
    }
    return _removeLeadingZeros(trimmed);
  }

  static String _removeLeadingZeros(String value) {
    final normalized = value.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    return normalized.isEmpty ? '0' : normalized;
  }

  ProductoFarmaceuticoEntity toEntity() {
    return ProductoFarmaceuticoEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      laboratorio: laboratorio,
      requiereReceta: requiereReceta,
      etiquetas: etiquetas,
      precioCentimos: precioCentimos,
    );
  }
}
