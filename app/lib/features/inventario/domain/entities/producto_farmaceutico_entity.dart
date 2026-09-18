/// Producto administrado por el módulo de inventario de SITRA-Luz.
class ProductoFarmaceuticoEntity {
  /// Identificador textual para conservar todos sus dígitos.
  final String id;
  final String nombre;
  final String descripcion;
  final String laboratorio;
  final bool requiereReceta;
  final List<String> etiquetas;

  /// Precio expresado en céntimos como texto entero exacto.
  ///
  /// Se usa texto para no depender del límite de precisión numérica de la
  /// plataforma, especialmente cuando la aplicación se ejecuta en web.
  final String precioCentimos;

  const ProductoFarmaceuticoEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.laboratorio,
    required this.requiereReceta,
    required this.etiquetas,
    required this.precioCentimos,
  });
}
